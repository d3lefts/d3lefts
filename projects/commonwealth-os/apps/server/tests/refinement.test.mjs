import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import { createPublicKey } from 'node:crypto';
import { Store } from '../src/store.mjs';
import { signingKey, exportEvidence } from '../src/evidence.mjs';
import { verifyEvidence } from '../verify.mjs';

// Evidence/transaction refinement audit. Every fixture here is fictional.
// It tests concrete backend behavior against independent event obligations;
// it does NOT show that arbitrary JavaScript implementations refine Lean.
const policy = {quorum:2,yesNumerator:1,yesDenominator:2,strict:true};
let number = 0;
const key = ()=>'refinement-command-'+(++number).toString().padStart(8,'0');
function fixture(){
  const dir=mkdtempSync(join(tmpdir(),'cw-refine-'));
  const db=join(dir,'demo.sqlite');
  const store=new Store(db);
  store.provisionInstitution('union-demo','Fictional union',policy);
  const actors={};
  for(const [id,role,eligible] of [
    ['admin','admin',false],['chair','chair',false],['clerk','clerk',false],
    ['auditor','auditor',false],['member-a','member',true],
    ['member-b','member',true],['member-c','member',false]]){
    const token=store.provisionActor('union-demo',id,role,eligible);
    actors[id]={token,session:store.authenticate(token)};
  }
  const run=(id,action,version,payload={})=>store.command(actors[id].session,{
    institutionId:'union-demo',itemId:'test-item',action,expectedVersion:version,
    payload,key:key()
  });
  const snapshot=()=>store.snapshot(actors.auditor.session,'union-demo','test-item');
  const close=()=>{store.close();rmSync(dir,{recursive:true,force:true});};
  return {store,db,dir,actors,run,snapshot,close};
}
function freezeThroughReview(f) {
  f.run('member-a','CREATE',0,{body:'Synthetic legislative motion'});
  f.run('member-a','SUBMIT',1);
  f.run('chair','AGENDA',2);
  f.run('chair','BEGIN',3);
  f.run('clerk','ATTEND',4,{attendees:['member-a','member-b']});
  f.run('chair','LOCK',5);
  f.run('chair','OPEN',6);
  f.run('member-a','CAST',7,{choice:'yes'});
  f.run('member-b','CAST',8,{choice:'yes'});
  f.run('chair','CLOSE',9);
  f.run('clerk','REVIEW',10);
}
test('concrete event trace matches guarded epoch witnesses and portable verifier',()=>{
  const f=fixture();
  try {
    freezeThroughReview(f);
    const snap=f.snapshot();
    assert.equal(snap.item.version,11);
    const lock=snap.events.find(e=>e.action==='LOCK');
    for(const e of snap.events.filter(e=>['OPEN','CAST','CLOSE','REVIEW'].includes(e.action))){
      assert.equal(e.details.policyVersion,lock.details.policyVersion);
      assert.equal(e.details.eligibilityVersion,lock.details.eligibilityVersion);
      assert.equal(e.details.lockedRevision,lock.details.lockedRevision);
    }
    const signing=signingKey(join(f.dir,'signing.pem'));
    const pub=createPublicKey(signing).export({type:'spki',format:'pem'}).toString();
    const signed=exportEvidence(snap,signing);
    assert.equal(verifyEvidence(signed,{trustedPublicKeyPem:pub}).ok,true);
    const modifications=[
      p=>{p.item.lockedEligibilityVersion+=1},
      p=>{p.events.find(e=>e.action==='CAST').details.policyVersion+=1},
      p=>{p.events.find(e=>e.action==='REVIEW').details.eligibilityVersion+=1},
      p=>{p.policies[0].version+=1},
      p=>{p.policies[0].hash='untrusted'},
      p=>{p.revisions[0].author='another-actor'},
    ];
    for(const mutate of modifications){
      // Re-sign with the TRUSTED KEY to test actual semantic replay, not
      // merely signature mismatch.
      const tampered=structuredClone(snap);
      mutate(tampered);
      assert.throws(()=>verifyEvidence(exportEvidence(tampered,signing),
        {trustedPublicKeyPem:pub}),/CHECK_FAILED_/);
    }
  }finally{f.close();}
});
test('cross-connection SQLite snapshot does not mix epochs across reads',()=>{
  const f=fixture();
  const other=new Store(f.db);
  try {
    const admin=other.authenticate(f.actors.admin.token);
    let observed;
    f.store.readTx(()=>{
      const before=f.store.institution('union-demo');
      assert.equal(before.policy_version,1);
      other.setPolicy(admin,'union-demo',{...policy,quorum:3},key());
      const during=f.store.institution('union-demo');
      observed=during.policy_version;
      assert.equal(during.policy_version,before.policy_version,
        'read transaction must remain at pre-update snapshot');
    });
    assert.equal(observed,1);
    assert.equal(f.store.institution('union-demo').policy_version,2);
  }finally{other.close();f.close();}
});
test('failed commands do not change transition projection; changing epoch rejects stale work',()=>{
  const f=fixture();
  try{
    f.run('member-a','CREATE',0,{body:'Synthetic procedural motion'});
    f.run('member-a','SUBMIT',1);
    f.run('chair','AGENDA',2);
    f.run('chair','BEGIN',3);
    f.run('clerk','ATTEND',4,{attendees:['member-a','member-b']});
    f.run('chair','LOCK',5);
    f.run('chair','OPEN',6);
    const projection=()=>({
      item:f.store.item('union-demo','test-item'),
      events:f.store.events('union-demo','test-item'),
      votes:f.store.votes('union-demo','test-item')
    });
    const attacks=[
      ()=>f.run('member-c','CAST',7,{choice:'yes'}),
      ()=>f.run('clerk','CAST',7,{choice:'yes'}),
      ()=>f.run('member-a','CAST',6,{choice:'yes'}),
      ()=>f.run('member-a','CAST',7,{choice:'INVALID'}),
      ()=>f.run('member-a','REVISE',7,{body:'rewrite after lock'}),
    ];
    for(const act of attacks){
      const before=projection();
      assert.throws(act);
      assert.deepEqual(projection(),before,
        'rejected commands must roll back the entire transaction');
    }
    f.store.setEligibility(f.actors.admin.session,'union-demo','member-a',false,key());
    const before=projection();
    assert.throws(()=>f.run('member-b','CAST',7,{choice:'yes'}),/AUTHORITY_CHANGED/);
    assert.deepEqual(projection(),before);
    assert.equal(f.snapshot().institution.eligibilityVersion,2);
  }finally{f.close();}
});
