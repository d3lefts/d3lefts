import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,rmSync,copyFileSync,readFileSync} from 'node:fs';
import {join} from 'node:path';
import {tmpdir} from 'node:os';
import {createPublicKey} from 'node:crypto';
import {ExtendedStore} from '../src/extended-store.mjs';
import {signingKey,exportEvidence} from '../src/evidence.mjs';
import {verifyExtended} from '../verify-v2.mjs';
import {quorumCheck,tallyCheck} from '../src/policy.mjs';
let serial=0;
const key=()=>`command-${String(++serial).padStart(8,'0')}`;
const policy={quorum:2,quorumFraction:{numerator:2,denominator:3,strict:false,basis:'ELIGIBLE'},yesNumerator:2,yesDenominator:3,strict:false,approvalBasis:'ELIGIBLE'};
function make(){
 const dir=mkdtempSync(join(tmpdir(),'cw04-')),db=join(dir,'inst.sqlite');
 const store=new ExtendedStore(db);store.provisionInstitution('union-demo','Entirely fictional union',policy);
 store.provisionInstitution('student-demo','Fictional senate',policy);
 const creds={};
 for(const institutionId of ['union-demo','student-demo']){
  creds[institutionId]={};
  for(const [id,role,eligible] of [['admin','admin',false],['chair','chair',false],['clerk','clerk',false],['auditor','auditor',false],['review-one','release-reviewer',false],['review-two','release-reviewer',false],['member-a','member',true],['member-b','member',true],['member-c','member',true],['member-d','member',false]]){
   const token=store.provisionActor(institutionId,id,role,eligible);
   creds[institutionId][id]={token,actor:store.authenticate(token)};
  }
 }
 const actor=(name,inst='union-demo')=>store.authenticate(creds[inst][name].token);
 const cmd=(name,action,expectedVersion,payload={},inst='union-demo',itemId='item-demo')=>store.command(actor(name,inst),{institutionId:inst,itemId,action,expectedVersion,payload,key:key()});
 const snapshot=(inst='union-demo')=>store.snapshot(actor('auditor',inst),inst,'item-demo');
 const signing=signingKey(join(dir,'key.pem'));
 const pub=createPublicKey(signing).export({type:'spki',format:'pem'}).toString();
 const evidence=()=>exportEvidence(snapshot(),signing);
 const close=()=>{store.close();rmSync(dir,{force:true,recursive:true})};
 return {dir,db,store,actor,cmd,snapshot,signing,pub,evidence,close};
}
function reviewed(f){
 f.cmd('member-a','CREATE',0,{body:'Synthetic first decision'});
 f.cmd('member-a','SUBMIT',1);
 f.cmd('chair','AGENDA',2);
 f.cmd('chair','BEGIN',3);
 f.cmd('clerk','ATTEND',4,{attendees:['member-a','member-b','member-c']});
 f.cmd('chair','LOCK',5);
 f.cmd('chair','OPEN',6);
 f.cmd('member-a','CAST',7,{choice:'yes'});
 f.cmd('member-b','CAST',8,{choice:'yes'});
 f.cmd('chair','CLOSE',9);
 f.cmd('clerk','REVIEW',10);
}
function published(f){
 reviewed(f);
 f.cmd('clerk','PREPARE_PUBLICATION',11,{content:'Synthetic approved decision summary',reason:'Initial version'});
 const p=f.store.projections('union-demo','item-demo')[0];
 f.cmd('review-one','REVIEW_PUBLICATION',12,{projectionHash:p.hash});
 f.cmd('review-two','REVIEW_PUBLICATION',13,{projectionHash:p.hash});
 f.cmd('clerk','PUBLISH_PREVIEW',14);
}
function accepts(f){return verifyExtended(f.evidence(),{trustedPublicKeyPem:f.pub});}

test('full fictional approval and portable verified publication with independent key pin',()=>{
 const f=make();try{published(f);const s=f.snapshot(),r=accepts(f);
 assert.equal(r.ok,true);assert.equal(r.publicationRevision,1);assert.equal(s.item.state,'PUBLISHED_PREVIEW');
 assert.equal(f.store.publicPreview(f.actor('auditor'),'union-demo','item-demo').content,'Synthetic approved decision summary');
 assert.ok(!JSON.stringify(f.store.publicPreview(f.actor('auditor'),'union-demo','item-demo')).includes('member-a'));
 assert.equal(s.item.outcome,'SUPPORTED_IN_SIMULATION');
 assert.throws(()=>verifyExtended(f.evidence()),/TRUST_PIN_REQUIRED/);
 }finally{f.close();}
});
test('two independent reviewers and exact version/author gate enforced',()=>{
 const f=make();try{reviewed(f);f.cmd('clerk','PREPARE_PUBLICATION',11,{content:'Public synthetic record',reason:'First'});
 const hash=f.store.projections('union-demo','item-demo')[0].hash;
 assert.throws(()=>f.cmd('clerk','PUBLISH_PREVIEW',12),/TWO_APPROVALS_REQUIRED/);
 assert.throws(()=>f.cmd('member-a','REVIEW_PUBLICATION',12,{projectionHash:hash}),/INDEPENDENT_REVIEWER_REQUIRED/);
 f.cmd('review-one','REVIEW_PUBLICATION',12,{projectionHash:hash});
 assert.throws(()=>f.cmd('review-one','REVIEW_PUBLICATION',13,{projectionHash:hash}),/DUPLICATE_APPROVAL/);
 assert.throws(()=>f.cmd('clerk','PUBLISH_PREVIEW',13),/TWO_APPROVALS_REQUIRED/);
 f.cmd('review-two','REVIEW_PUBLICATION',13,{projectionHash:hash});
 assert.throws(()=>f.cmd('chair','PUBLISH_PREVIEW',14),/CERTIFYING_CLERK_REQUIRED/);
 f.cmd('clerk','PUBLISH_PREVIEW',14);assert.equal(accepts(f).ok,true);
 }finally{f.close();}
});
test('immutable publication corrections append new source and require fresh approvals',()=>{
 const f=make();try{published(f);
 f.cmd('clerk','CORRECT_PUBLICATION',15,{content:'Corrected fictional public record',reason:'Typographical correction'});
 const p=f.store.projections('union-demo','item-demo');assert.equal(p.length,2);assert.equal(p[1].previousHash,p[0].hash);
 assert.throws(()=>f.cmd('clerk','PUBLISH_PREVIEW',16),/TWO_APPROVALS_REQUIRED/);
 f.cmd('review-one','REVIEW_PUBLICATION',16,{projectionHash:p[1].hash});
 f.cmd('review-two','REVIEW_PUBLICATION',17,{projectionHash:p[1].hash});
 f.cmd('clerk','PUBLISH_PREVIEW',18);
 assert.equal(accepts(f).publicationRevision,2);
 assert.throws(()=>f.store.db.prepare('DELETE FROM projections').run(),/IMMUTABLE_PROJECTION/);
 }finally{f.close();}
});
test('void from active decision is final and cannot be published or cast',()=>{
 const f=make();try{
 f.cmd('member-a','CREATE',0,{body:'Synthetic cancellation'});f.cmd('member-a','SUBMIT',1);
 f.cmd('chair','VOID',2,{reason:'Withdrawn by chair in simulation'});
 assert.equal(f.snapshot().item.state,'VOIDED');assert.equal(accepts(f).ok,true);
 assert.throws(()=>f.cmd('chair','AGENDA',3),/INVALID_TRANSITION/);
 assert.throws(()=>f.cmd('clerk','PREPARE_PUBLICATION',3,{content:'x',reason:'y'}),/PUBLICATION_STATE_INVALID/);
 }finally{f.close();}
});
test('policy basis and rational quorum use exact integer arithmetic',()=>{
 assert.equal(quorumCheck(policy,2,3),true);
 assert.equal(quorumCheck(policy,1,3),false);
 const p={...policy,approvalBasis:'PRESENT',strict:true};
 assert.equal(tallyCheck(p,[{choice:'yes'},{choice:'yes'}],3,3).accepted,false);
 assert.equal(tallyCheck({...p,strict:false},[{choice:'yes'},{choice:'yes'}],3,3).accepted,true);
 assert.equal(tallyCheck({...policy,approvalBasis:'ELIGIBLE'},[{choice:'yes'},{choice:'no'}],2,3).accepted,false);
});
test('source fixture version hashing, citation lock and synthetic-only prohibition',()=>{
 const f=make();try{
 const adm=f.actor('admin');
 assert.throws(()=>f.store.addSource(adm,'union-demo','policy-one','Actual city record','DRAFT','https://example.org',key()),/INVALID_SYNTHETIC_SOURCE/);
 const src=f.store.addSource(adm,'union-demo','policy-one','Imaginary policy','ENACTED','synthetic:union-bylaws',key());
 f.cmd('member-a','CREATE',0,{body:'Synthetic proposal'});
 f.cmd('member-a','ATTACH_SOURCE',1,{sourceId:'policy-one'});
 f.cmd('member-a','SUBMIT',2);f.cmd('chair','AGENDA',3);f.cmd('chair','BEGIN',4);
 f.cmd('clerk','ATTEND',5,{attendees:['member-a','member-b','member-c']});f.cmd('chair','LOCK',6);
 const snap=f.snapshot();assert.equal(snap.events.find(e=>e.action==='LOCK').details.sources[0].hash,src.hash);
 assert.equal(accepts(f).ok,true);
 f.store.addSource(adm,'union-demo','policy-one','Imaginary updated policy','ENACTED','synthetic:union-bylaws',key());
 assert.throws(()=>f.cmd('chair','OPEN',7),/SOURCE_SUPERSEDED/);
 assert.equal(accepts(f).authorityStatus,'STALE_RECHECK_REQUIRED');
 }finally{f.close();}
});
test('change of roster freezes in-flight decision and is independently visible',()=>{
 const f=make();try{reviewed(f);const before=accepts(f);assert.equal(before.authorityStatus,'NO_RELEVANT_CHANGE_DETECTED');
 f.store.setEligibility(f.actor('admin'),'union-demo','member-a',false,key());
 assert.equal(accepts(f).authorityStatus,'STALE_RECHECK_REQUIRED');
 assert.equal(f.store.institution('student-demo').eligibility_version,5);
 }finally{f.close();}
});
test('adversarial re-signed tampering fails semantic replay, not merely Ed25519 verification',()=>{
 const f=make();try{published(f);const original=f.snapshot();
 const corruptions=[
   x=>{x.events.find(e=>e.action==='CAST').actorRole='chair';},
   x=>{x.events.find(e=>e.action==='CAST').details.authoritySeq=1;},
   x=>{x.events.find(e=>e.action==='REVIEW_PUBLICATION').details.reviewer='member-a';},
   x=>{x.projections[0].content='Backdated alteration';},
   x=>{x.authorityJournal.at(-1).hash='tampered';},
   x=>{x.members.find(m=>m.id==='member-a').eligible=0;},
   x=>{x.item.outcome='REJECTED_IN_SIMULATION';},
   x=>{x.policies[0].policy.approvalBasis='CAST';},
   x=>{x.publicationApprovals.pop();},
 ];
 for(const mutate of corruptions){const x=structuredClone(original);mutate(x);assert.throws(()=>verifyExtended(exportEvidence(x,f.signing),{trustedPublicKeyPem:f.pub}),/CHECK_FAILED_/);}
 }finally{f.close();}
});
test('repeated idempotent commands do not duplicate journal or approvals',()=>{
 const f=make();try{
 const actor=f.actor('member-a');const req={institutionId:'union-demo',itemId:'item-demo',action:'CREATE',expectedVersion:0,key:key(),payload:{body:'Synthetic'}};
 const a=f.store.command(actor,req),b=f.store.command(actor,req);assert.deepEqual(a,b);assert.equal(f.snapshot().events.length,1);
 assert.throws(()=>f.store.command(actor,{...req,payload:{body:'Different'}}),/IDEMPOTENCY_CONFLICT/);
 }finally{f.close();}
});
test('actor revocation is append-only and blocks stale sessions',()=>{
 const f=make();try{
 const stale=f.actor('member-c');f.store.revokeActor(f.actor('admin'),'union-demo','member-c',key());
 assert.throws(()=>f.store.command(stale,{institutionId:'union-demo',itemId:'new-motion',action:'CREATE',expectedVersion:0,payload:{body:'Not allowed'},key:key()}),/ACTOR_SESSION_STALE/);
 assert.equal(f.store.authority('union-demo').at(-1).action,'ACTOR_REVOKED');
 }finally{f.close();}
});
test('transactional crash/reopen retains revisions, authority and hash chains',()=>{
 const f=make();try{published(f);const snap=f.snapshot();
 f.store.db.exec('PRAGMA wal_checkpoint(TRUNCATE)');
 const backup=join(f.dir,'copy.sqlite');copyFileSync(f.db,backup);
 const other=new ExtendedStore(backup);
 try{assert.deepEqual(other.events('union-demo','item-demo'),snap.events);assert.equal(other.institution('union-demo').policy_version,1);assert.equal(other.authority('union-demo').length,snap.authorityJournal.length);}finally{other.close();}
 }finally{f.close();}
});

test('amendment after agenda or deliberation resets to DRAFT and invalidates old attendance',()=>{
 const f=make();try{
 f.cmd('member-a','CREATE',0,{body:'Initial fictional resolution'});
 f.cmd('member-a','SUBMIT',1);
 f.cmd('chair','AGENDA',2);
 f.cmd('chair','BEGIN',3);
 f.cmd('clerk','ATTEND',4,{attendees:['member-a','member-b']});
 const revised=f.cmd('member-a','REVISE',5,{body:'Material amendment while deliberating'});
 assert.equal(revised.state,'DRAFT');assert.deepEqual(f.snapshot().attendance,[]);
 assert.equal(accepts(f).ok,true);
 assert.throws(()=>f.cmd('chair','LOCK',6),/INVALID_TRANSITION/);
 f.cmd('member-a','SUBMIT',6);
 f.cmd('chair','AGENDA',7);
 const again=f.cmd('clerk','REVISE',8,{body:'Second fictional amendment'});
 assert.equal(again.state,'DRAFT');
 assert.equal(accepts(f).ok,true);
 }finally{f.close();}
});
