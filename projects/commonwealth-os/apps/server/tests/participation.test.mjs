import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { Store } from '../src/store.mjs';
import { ParticipationLedger } from '../src/participation.mjs';
import { createServer } from '../src/http.mjs';
import { verifyLocalParticipationChain } from '../verify-participation.mjs';
import { verifySyntheticParticipationReceipt } from '../verify-participation-receipt.mjs';
import { signingKey, exportEvidence } from '../src/evidence.mjs';
import { createPublicKey } from 'node:crypto';

function setup(){
  const dir=mkdtempSync(join(tmpdir(),'cw-participation-'));
  const file=join(dir,'ledger.sqlite');
  const store=new Store(file);
  const policy={quorum:2,yesNumerator:1,yesDenominator:2,strict:false};
  const tokens={};
  for(const id of ['student-demo','union-demo']){
    store.provisionInstitution(id,'Fictional '+id,policy);
    tokens[id]={};
    for(const [name,role,eligible] of [['a','member',true],['b','member',true],['clerk','clerk',false],['chair','chair',false],['auditor','auditor',false]]){
      // Actor IDs must be at least two characters.
      const actorId=name==='a'?'member-a':name==='b'?'member-b':name;
      tokens[id][name]=store.provisionActor(id,actorId,role,eligible);
    }
  }
  const ledger=new ParticipationLedger(store);
  let n=0;
  const actor=(name,inst='student-demo')=>store.authenticate(tokens[inst][name]);
  const submit=(name,command,seq,revision,inst='student-demo',key)=>{
    return ledger.command(actor(name,inst),{institutionId:inst,expectedSequence:seq,expectedRevision:revision,command,key:key||'test-command-'+(++n)});
  };
  return {dir,file,store,ledger,actor,submit,tokens,cleanup(){store.close();rmSync(dir,{recursive:true,force:true});}};
}
const amend={type:'AMEND',id:'P-UAH-01',text:'Evaluate a fictional evening shuttle route with a published accessibility review and verified price range.',reason:'Specify cost and accessibility conditions'};
const reply='This fictional review has recorded an explicit documented reason.';

test('durable replay, optimistic sequence/revision fences, scoped roles and old advice invalidation',()=>{
  const t=setup();
  try{
    const first=t.ledger.view(t.actor('a'),'student-demo');
    assert.equal(first.sequence,0);assert.equal(first.board.proposals.length,2);
    assert.equal(t.ledger.view(t.actor('a','union-demo'),'union-demo').board.proposals.length,2);
    assert.throws(()=>t.ledger.view(t.actor('a','union-demo'),'student-demo'),/FORBIDDEN_TENANT/);
    const advisory=t.submit('a',{type:'ADVISE',id:'P-UAH-01',choice:'SUPPORT'},0,1);
    assert.equal(advisory.sequence,1);
    const own=t.ledger.view(t.actor('a'),'student-demo');
    assert.equal(own.board.proposals[0].positions[0].choice,'SUPPORT');
    assert.equal(t.ledger.view(t.actor('b'),'student-demo').board.proposals[0].positions.length,0);
    const changed=t.submit('b',amend,1,1);
    assert.equal(changed.sequence,2);
    assert.throws(()=>t.submit('a',{type:'COMMENT',id:'P-UAH-01',text:'Please explain the public cost estimate.',stance:'QUESTION'},1,1),/PARTICIPATION_SEQUENCE_CONFLICT/);
    assert.throws(()=>t.submit('a',{type:'REVIEW_AMEND',id:'P-UAH-01',amendmentId:'A-1',decision:'ACCEPT',reason:reply},2,1),/CLERK_REQUIRED/);
    const accepted=t.submit('clerk',{type:'REVIEW_AMEND',id:'P-UAH-01',amendmentId:'A-1',decision:'ACCEPT',reason:reply,role:'DEMO_VISITOR'},2,1);
    assert.equal(accepted.revision,2);
    assert.throws(()=>t.submit('a',{type:'ADVISE',id:'P-UAH-01',choice:'OPPOSE'},3,1),/PARTICIPATION_REVISION_CONFLICT/);
    const s=t.ledger.view(t.actor('a'),'student-demo');
    assert.equal(s.board.proposals[0].revision,2);
    assert.equal(s.board.proposals[0].positions.filter(x=>x.revision===2).length,0);
    assert.equal(s.board.proposals[0].positions.filter(x=>x.revision===1).length,1);
    const dossier=t.ledger.dossier(t.actor('b'),'student-demo','P-UAH-01');
    const json=JSON.stringify(dossier);
    assert.equal(dossier.official,false);
    assert.equal(dossier.ledger.sequence,3);
    assert.equal(json.includes('"choice":"SUPPORT"'),false);
    assert.equal(json.includes('member-a'),false);
    assert.equal(json.includes('PRIVATE'),false);
    t.store.close();
    const reopened=new Store(t.file),again=new ParticipationLedger(reopened);
    assert.equal(again.view(reopened.authenticate(t.tokens['student-demo'].b),'student-demo').sequence,3);
    assert.equal(again.view(reopened.authenticate(t.tokens['student-demo'].a),'student-demo').board.proposals[0].revision,2);
    reopened.close();
  }finally{rmSync(t.dir,{recursive:true,force:true});}
});

test('private contribution bodies withheld from other members and public export',()=>{
  const t=setup();try{
    t.submit('a',{type:'COMMENT',id:'P-UAH-01',text:'Synthetic private concern: do not publish my exact words.',stance:'CONCERN'},0,1);
    const own=t.ledger.view(t.actor('a'),'student-demo');
    const other=t.ledger.view(t.actor('b'),'student-demo');
    const reviewer=t.ledger.view(t.actor('clerk'),'student-demo');
    assert.match(own.board.proposals[0].comments[0].text,/do not publish/);
    assert.match(reviewer.board.proposals[0].comments[0].text,/do not publish/);
    assert.doesNotMatch(JSON.stringify(other),/do not publish/);
    assert.doesNotMatch(JSON.stringify(t.ledger.dossier(t.actor('b'),'student-demo','P-UAH-01')),/do not publish/);
    assert.throws(()=>t.submit('b',{type:'STAGE',id:'P-UAH-01',target:'REVIEW',reason:reply},1,1),/CHAIR_REQUIRED/);
    assert.throws(()=>t.store.db.exec("DELETE FROM participation_events WHERE institution_id='student-demo'"),/IMMUTABLE_PARTICIPATION_EVENT/);
  }finally{t.cleanup();}
});

test('tampering detected under independent replay and idempotency survives retries',()=>{
  const t=setup();try{
    const command={type:'COMMENT',id:'P-UAH-01',text:'Please explain the simulated shuttle safety review.',stance:'QUESTION'};
    const key='stable-request-001';
    const a=t.submit('a',command,0,1,'student-demo',key);
    const b=t.submit('a',command,0,1,'student-demo',key);
    assert.deepEqual(a,b);
    assert.equal(t.ledger.view(t.actor('b'),'student-demo').sequence,1);
    assert.equal(verifyLocalParticipationChain(t.file,'student-demo').sequence,1);
    assert.throws(()=>t.submit('a',{...command,text:'Different comment text provided for retry.'},0,1,'student-demo',key),/IDEMPOTENCY_CONFLICT/);
    t.store.db.exec('DROP TRIGGER participation_events_no_update');
    t.store.db.exec("UPDATE participation_events SET event_json='{}' WHERE institution_id='student-demo' AND seq=1");
    assert.throws(()=>t.ledger.view(t.actor('a'),'student-demo'),/PARTICIPATION_(CHAIN|SEQUENCE)_CORRUPT/);
    assert.throws(()=>verifyLocalParticipationChain(t.file,'student-demo'),/INDEPENDENT_/);
  }finally{t.cleanup();}
});

test('independently verified signed synthetic receipt requires a pinned key for provenance',()=>{
  const t=setup();try{
    t.submit('a',{type:'ADVISE',id:'P-UAH-01',choice:'SUPPORT'},0,1);
    const payload=t.ledger.dossier(t.actor('a'),'student-demo','P-UAH-01');
    const key=signingKey(join(t.dir,'key.pem'));
    const envelope=exportEvidence(payload,key);
    const defaultVerdict=verifySyntheticParticipationReceipt(envelope);
    assert.equal(defaultVerdict.authenticity,'SELF_ASSERTED_KEY');
    const pinned=createPublicKey(key).export({type:'spki',format:'pem'}).toString();
    assert.equal(verifySyntheticParticipationReceipt(envelope,{trustedPublicKeyPem:pinned}).authenticity,'PINNED_LOCAL_KEY');
    const corrupted=structuredClone(envelope);corrupted.payload.revision=999;
    assert.throws(()=>verifySyntheticParticipationReceipt(corrupted,{trustedPublicKeyPem:pinned}),/RECEIPT_SIGNATURE_INVALID/);
    assert.equal(JSON.stringify(envelope).includes('"choice":"SUPPORT"'),false);
  }finally{t.cleanup();}
});

test('HTTP integration serves same-origin browser and enforces bearer roles',async()=>{
  const t=setup();
  const {server}=createServer({store:t.store,keyPath:join(t.dir,'key.pem')});
  try{
    await new Promise(ok=>server.listen(0,'127.0.0.1',ok));
    const base='http://127.0.0.1:'+server.address().port;
    let r=await fetch(base+'/browser/');
    assert.equal(r.status,200);
    assert.match(await r.text(),/Commonwealth/);
    r=await fetch(base+'/api/v1/participation/student-demo/board');
    assert.equal(r.status,401);
    const ha={Authorization:'Bearer '+t.tokens['student-demo'].a,'Content-Type':'application/json'};
    r=await fetch(base+'/api/v1/participation/student-demo/board',{headers:ha});
    assert.equal(r.status,200);
    const view=await r.json();
    assert.equal(view.sequence,0);
    r=await fetch(base+'/api/v1/participation/union-demo/board',{headers:ha});
    assert.equal(r.status,403);
    r=await fetch(base+'/api/v1/participation/commands',{method:'POST',headers:ha,body:JSON.stringify({institutionId:'student-demo',expectedSequence:0,expectedRevision:1,key:'http-command-001',command:{type:'ADVISE',id:'P-UAH-01',choice:'SUPPORT'}})});
    assert.equal(r.status,200);
    assert.equal((await r.json()).sequence,1);
    r=await fetch(base+'/api/v1/participation/student-demo/dossiers/P-UAH-01',{headers:ha});
    assert.equal(r.status,200);
    assert.equal((await r.json()).individualAdviceIncluded,false);
    r=await fetch(base+'/api/v1/participation/student-demo/receipts/P-UAH-01',{headers:ha});
    assert.equal(r.status,200);
    assert.equal(verifySyntheticParticipationReceipt(await r.json()).officialCertification,false);
  }finally{await new Promise(ok=>server.close(ok));t.cleanup();}
});
