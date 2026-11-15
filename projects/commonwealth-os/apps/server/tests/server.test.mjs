import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync,readFileSync,rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createPublicKey } from 'node:crypto';
import { Store } from '../src/store.mjs';
import { createServer } from '../src/http.mjs';
import { signingKey, exportEvidence } from '../src/evidence.mjs';
import { verifyEvidence } from '../verify.mjs';
const policy={quorum:2,yesNumerator:2,yesDenominator:3,strict:false};
let seq=0;
const unique=()=>`cmd-${String(++seq).padStart(8,'0')}`;
function setup(){
 const dir=mkdtempSync(join(tmpdir(),'cwos-'));
 const store=new Store(join(dir,'test.sqlite'));
 store.provisionInstitution('union-demo','Fictional Union',policy);
 store.provisionInstitution('student-demo','Fictional Student Council',policy);
 const creds={};
 for(const inst of ['union-demo','student-demo']){
  creds[inst]={};
  for(const [id,role,eligible] of [['admin','admin',false],['chair','chair',false],['clerk','clerk',false],['auditor','auditor',false],['member-a','member',true],['member-b','member',true],['member-c','member',true],['member-d','member',false]]){
    const token=store.provisionActor(inst,id,role,eligible);
    creds[inst][id]={token,actor:store.authenticate(token)};
  }
 }
 const actor=(name='member-a',inst='union-demo')=>creds[inst][name].actor;
 const command=(name,action,expectedVersion,payload={},itemId='item-one',inst='union-demo',key=unique())=>store.command(actor(name,inst),{institutionId:inst,itemId,action,expectedVersion,payload,key});
 const cleanup=()=>{store.close();rmSync(dir,{recursive:true,force:true});};
 const moveToVote=(itemId='item-one',inst='union-demo')=>{
  command('member-a','CREATE',0,{body:'New fictional committee procedure'},itemId,inst);
  command('member-a','REVISE',1,{body:'Revised fictional committee procedure'},itemId,inst);
  command('member-a','SUBMIT',2,{},itemId,inst);
  command('chair','AGENDA',3,{},itemId,inst);
  command('chair','BEGIN',4,{},itemId,inst);
  command('clerk','ATTEND',5,{attendees:['member-a','member-b','member-c']},itemId,inst);
  command('chair','LOCK',6,{},itemId,inst);
  command('chair','OPEN',7,{},itemId,inst);
 };
 return {dir,store,creds,actor,command,cleanup,moveToVote};
}

test('transactional lifecycle, immutable revisions, independent evidence replay, pinned signer',()=>{
 const c=setup();try{
  c.moveToVote();
  c.command('member-a','CAST',8,{choice:'yes'});
  c.command('member-b','CAST',9,{choice:'yes'});
  c.command('member-c','CAST',10,{choice:'no'});
  c.command('chair','CLOSE',11);
  const review=c.command('clerk','REVIEW',12);
  assert.equal(review.outcome,'SUPPORTED_IN_SIMULATION');
  const item=c.store.item('union-demo','item-one');assert.equal(item.state,'REVIEWED_DEMO');
  assert.equal(item.current_revision,2);
  assert.throws(()=>c.store.db.exec("UPDATE revisions SET body='edited' WHERE item_id='item-one'"),/IMMUTABLE_REVISION/);
  assert.throws(()=>c.store.db.exec("UPDATE events SET hash='forged' WHERE item_id='item-one'"),/IMMUTABLE_EVENT/);
  const key=signingKey(join(c.dir,'signing-key.pem'));
  const evidence=exportEvidence(c.store.snapshot(c.actor('auditor'),'union-demo','item-one'),key);
  const trustedPublicKeyPem=createPublicKey(key).export({type:'spki',format:'pem'}).toString();
  const verdict=verifyEvidence(evidence,{trustedPublicKeyPem});
  assert.equal(verdict.ok,true);assert.equal(verdict.signer,'PINNED');assert.equal(verdict.authorityStatus,'NO_CHANGE_DETECTED');
  assert.equal(verdict.officialCertification,false);
  const tamper=structuredClone(evidence);tamper.payload.votes[0].choice='no';
  assert.throws(()=>verifyEvidence(tamper,{trustedPublicKeyPem}),/SIGNATURE/);
  const forgedSigner=signingKey(join(c.dir,'attacker.pem'));
  const forged=exportEvidence(evidence.payload,forgedSigner);
  assert.throws(()=>verifyEvidence(forged,{trustedPublicKeyPem}),/PINNED_SIGNER/);
 }finally{c.cleanup();}
});

test('idempotency: same request replays, key conflict rejects; version conflict prevents writes',()=>{
 const c=setup();try{
  const key=unique();
  const req={institutionId:'union-demo',itemId:'item-one',action:'CREATE',expectedVersion:0,payload:{body:'Demo'},key};
  const actor=c.actor();
  const a=c.store.command(actor,req);const b=c.store.command(actor,req);assert.deepEqual(a,b);
  assert.equal(c.store.events('union-demo','item-one').length,1);
  assert.throws(()=>c.store.command(actor,{...req,payload:{body:'Different'}}),/IDEMPOTENCY_CONFLICT/);
  assert.throws(()=>c.command('member-a','REVISE',0,{body:'Oops'}),/VERSION_CONFLICT/);
  assert.equal(c.store.revisions('union-demo','item-one').length,1);
 }finally{c.cleanup();}
});

test('cross-institution access and eligibility are server-controlled',()=>{
 const c=setup();try{
  assert.throws(()=>c.command('member-a','CREATE',0,{body:'Cross'},'item-one','union-demo',unique()) && c.store.snapshot(c.actor('auditor','student-demo'),'union-demo','item-one'),/FORBIDDEN_TENANT/);
  const admin=c.actor('admin');
  assert.throws(()=>c.store.setEligibility(c.actor('chair'),'union-demo','member-d',true,unique()),/ADMIN_REQUIRED/);
  const updated=c.store.setEligibility(admin,'union-demo','member-d',true,unique());
  assert.equal(updated.eligible,true);
  assert.equal(c.store.authenticate(c.creds['union-demo']['member-d'].token).eligible,1);
  assert.throws(()=>c.store.setEligibility(c.actor('admin','student-demo'),'union-demo','member-c',false,unique()),/FORBIDDEN_TENANT/);
 }finally{c.cleanup();}
});

test('unauthorized motion changes and invalid votes reject atomically',()=>{
 const c=setup();try{
  c.moveToVote();
  assert.throws(()=>c.command('member-b','REVISE',8,{body:'Post lock'}),/REVISION_LOCKED/);
  assert.throws(()=>c.command('member-d','CAST',8,{choice:'yes'}),/NOT_ELIGIBLE/);
  assert.throws(()=>c.command('chair','CAST',8,{choice:'yes'}),/NOT_ELIGIBLE/);
  c.command('member-a','CAST',8,{choice:'yes'});
  assert.throws(()=>c.command('member-a','CAST',9,{choice:'no'}),/DUPLICATE_CAST/);
  assert.equal(c.store.votes('union-demo','item-one').length,1);
 }finally{c.cleanup();}
});

test('rule changes invalidate locked motion; independent report flags stale evidence',()=>{
 const c=setup();try{
  c.moveToVote();
  const before=exportEvidence(c.store.snapshot(c.actor('auditor'),'union-demo','item-one'),signingKey(join(c.dir,'key.pem')));
  assert.equal(verifyEvidence(before).authorityStatus,'NO_CHANGE_DETECTED');
  c.store.setPolicy(c.actor('admin'),'union-demo',{...policy,quorum:3},unique());
  assert.throws(()=>c.command('member-a','CAST',8,{choice:'yes'}),/AUTHORITY_CHANGED/);
  const after=exportEvidence(c.store.snapshot(c.actor('auditor'),'union-demo','item-one'),signingKey(join(c.dir,'key.pem')));
  assert.equal(verifyEvidence(after).authorityStatus,'STALE_REVIEW_REQUIRED');
 }finally{c.cleanup();}
});

test('eligibility revocation invalidates open decision, stale actor snapshots rejected',()=>{
 const c=setup();try{
  c.moveToVote();
  const stale=c.actor('member-a');
  c.store.setEligibility(c.actor('admin'),'union-demo','member-a',false,unique());
  assert.throws(()=>c.store.command(stale,{institutionId:'union-demo',itemId:'item-one',action:'CAST',expectedVersion:8,payload:{choice:'yes'},key:unique()}),/ACTOR_SESSION_STALE/);
  assert.throws(()=>c.command('member-b','CAST',8,{choice:'yes'}),/AUTHORITY_CHANGED/);
 }finally{c.cleanup();}
});

test('missing quorum and incorrect role checks reject before any ledger mutation',()=>{
 const c=setup();try{
  c.command('member-a','CREATE',0,{body:'Test'});
  c.command('member-a','SUBMIT',1);c.command('chair','AGENDA',2);c.command('chair','BEGIN',3);
  assert.throws(()=>c.command('member-a','ATTEND',4,{attendees:['member-a']}),/CLERK_REQUIRED/);
  c.command('clerk','ATTEND',4,{attendees:['member-a']});
  assert.throws(()=>c.command('chair','LOCK',5),/QUORUM_UNMET/);
  assert.equal(c.store.events('union-demo','item-one').length,5);
 }finally{c.cleanup();}
});

test('HTTP authenticated API enforces tenant boundary and keeps evidence behind auditor role',async()=>{
 const c=setup();const {server}=createServer({store:c.store,keyPath:join(c.dir,'key.pem')});
 try{
  await new Promise(ok=>server.listen(0,'127.0.0.1',ok));
  const base=`http://127.0.0.1:${server.address().port}`;
  const unauthorized=await fetch(base+'/api/v1/me');assert.equal(unauthorized.status,401);
  const token=c.creds['union-demo']['member-a'].token;
  const auth={Authorization:'Bearer '+token,'Content-Type':'application/json'};
  let response=await fetch(base+'/api/v1/commands',{method:'POST',headers:auth,body:JSON.stringify({institutionId:'union-demo',itemId:'item-one',action:'CREATE',expectedVersion:0,payload:{body:'Synthetic proposal'},key:unique()})});
  assert.equal(response.status,200);
  response=await fetch(base+'/api/v1/institutions/student-demo/items/item-one',{headers:auth});assert.equal(response.status,403);
  response=await fetch(base+'/api/v1/institutions/union-demo/items/item-one/evidence',{headers:auth});assert.equal(response.status,403);
  response=await fetch(base+'/api/v1/institutions/union-demo/items/item-one/evidence',{headers:{Authorization:'Bearer '+c.creds['union-demo']['auditor'].token}});
  assert.equal(response.status,200);assert.equal(verifyEvidence(await response.json()).ok,true);
 }finally{await new Promise(resolve=>server.close(resolve));c.cleanup();}
});
