import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {Store} from '../src/store.mjs';
import {ParticipationStore} from '../src/participation-store.mjs';
import {createServer} from '../src/http.mjs';

let count=0;const key=()=>('participation-test-'+(++count));
const policy={quorum:2,yesNumerator:1,yesDenominator:2,strict:true};
function setup(){
 const dir=mkdtempSync(join(tmpdir(),'cw-part-'));
 const dbPath=join(dir,'test.sqlite');
 const store=new Store(dbPath),tokens={};
 for(const [tenant,name] of [['student-demo','UAH'],['hoa-demo','HOA'],['municipal-demo','HSV']]){
  store.provisionInstitution(tenant,'Fictional '+name,policy);tokens[name]={};
  for(const role of ['member','clerk','admin','auditor']){
   const token=store.provisionActor(tenant,role+'-fictional',role,role==='member');
   tokens[name][role]={token,actor:store.authenticate(token)};
  }
 }
 const part=new ParticipationStore(store);
 return {dir,dbPath,store,tokens,part,
  read:(group='UAH',role='member')=>part.read(tokens[group][role].actor,group),
  command:(group,role,version,command,k=key())=>part.command(tokens[group][role].actor,group,{key:k,expectedVersion:version,command}),
  cleanup(){try{store.close();}catch{}rmSync(dir,{recursive:true,force:true});}
 };
}
test('tenant-isolated fictional seed; no real identity or official voting',()=>{
 const x=setup();try{
  assert.equal(x.read('UAH').version,0);assert.equal(x.read('UAH').board.proposals.length,2);
  assert.deepEqual(x.read('HOA').board.proposals.map(p=>p.institution),['HOA','HOA']);
  assert.equal(x.read('HSV').officialVoting,false);
  assert.throws(()=>x.part.read(x.tokens.UAH.member.actor,'HOA'),/FORBIDDEN_TENANT/);
 }finally{x.cleanup();}
});
test('restart replay preserves amendments, comments, corrections and version chains',()=>{
 const x=setup();try{
  let r=x.command('UAH','member',0,{type:'CREATE',title:'Fictional library access plan',text:'Explore extending fictional campus library access during examination weeks.'});
  const id=r.board.proposals[0].id;
  r=x.command('UAH','member',1,{type:'COMMENT',id,stance:'QUESTION',text:'Can the fictional operations budget support the extended opening hours?'});
  r=x.command('UAH','member',2,{type:'AMEND',id,text:'Evaluate access to the fictional library after nine and publish a student review.',reason:'Clarify the scope of the trial'});
  r=x.command('UAH','clerk',3,{type:'REVIEW_AMEND',id,amendmentId:'A-1',decision:'ACCEPT',reason:'This proposal specifies a clearer reviewable action.'});
  assert.equal(r.board.proposals[0].revision,2);
  r=x.command('UAH','member',4,{type:'CORRECTION',id,reason:'Check the fictional reporting deadline'});
  assert.equal(x.read().version,5);
  x.store.close();
  const y=new Store(x.dbPath),p=new ParticipationStore(y);
  assert.equal(p.read(x.tokens.UAH.member.actor,'UAH').version,5);
  assert.equal(p.read(x.tokens.UAH.member.actor,'UAH').board.proposals[0].revisions.length,2);
  y.close();
 }finally{x.cleanup();}
});
test('idempotency and optimistic concurrency prevent duplicate and stale changes',()=>{
 const x=setup();try{
  const cmd={type:'COMMENT',id:'P-UAH-01',stance:'QUESTION',text:'What are the fictional transportation costs?'};
  const id=key();const r=x.command('UAH','member',0,cmd,id);
  assert.equal(x.command('UAH','member',0,cmd,id).headHash,r.headHash);
  assert.equal(x.read().version,1);
  assert.throws(()=>x.command('UAH','member',0,{...cmd,text:'A different fictional cost question'},id),/IDEMPOTENCY_CONFLICT/);
  assert.throws(()=>x.command('UAH','member',0,cmd),/STALE_PARTICIPATION_VERSION/);
  assert.equal(x.read().version,1);
 }finally{x.cleanup();}
});
test('actor-controlled authority blocks steward forgery, cross-tenant and personal stance storage',()=>{
 const x=setup();try{
  assert.throws(()=>x.command('UAH','member',0,{type:'STAGE',role:'DEMO_STEWARD',id:'P-UAH-01',target:'REVIEW',reason:'An invalid fake reviewer assertion'}),/STEWARD_REQUIRED/);
  assert.throws(()=>x.command('UAH','member',0,{type:'ADVISE',id:'P-UAH-01',choice:'SUPPORT'}),/ACTION_NOT_DURABLE_OR_AUTHORIZED/);
  assert.throws(()=>x.command('UAH','member',0,{type:'COMMENT',institution:'HSV',id:'P-UAH-01',stance:'CONCERN',text:'A different tenant should not write here'}),/CROSS_INSTITUTION_COMMAND/);
  assert.throws(()=>x.part.command(x.tokens.UAH.member.actor,'HOA',{key:key(),expectedVersion:0,command:{type:'BUDGET',selected:['B-H1']}}),/FORBIDDEN_TENANT/);
  assert.throws(()=>x.command('UAH','auditor',0,{type:'CREATE',title:'Fictional library proposal',text:'This is a fictional proposal of sufficient length'}),/PARTICIPATION_READ_ONLY_ROLE/);
 }finally{x.cleanup();}
});
test('reasoned steward decisions, budget limits and monotonic progress',()=>{
 const x=setup();try{
  assert.throws(()=>x.command('HOA','member',0,{type:'BUDGET',selected:['B-H1']}),/STEWARD_REQUIRED/);
  assert.throws(()=>x.command('HOA','clerk',0,{type:'BUDGET',selected:['B-H1','B-H2','B-H4']}),/BUDGET_OVER_CEILING/);
  assert.equal(x.command('HOA','clerk',0,{type:'BUDGET',selected:['B-H1','B-H2']}).board.budgetSubmission.total,18000);
  x.command('UAH','clerk',0,{type:'STAGE',id:'P-UAH-01',target:'REVIEW',reason:'Fictional agenda is reviewed with reasons.'});
  x.command('UAH','clerk',1,{type:'STAGE',id:'P-UAH-01',target:'ACCEPTED',reason:'The fictional institution accepted a trial.'});
  x.command('UAH','clerk',2,{type:'STAGE',id:'P-UAH-01',target:'IMPLEMENTING',reason:'The fictional institution has begun a study.'});
  assert.throws(()=>x.command('UAH','clerk',3,{type:'STAGE',id:'P-UAH-01',target:'COMPLETED',reason:'Skipping evidence and progress.'}),/PARTICIPATION_REJECTED/);
  x.command('UAH','clerk',3,{type:'MILESTONE',id:'P-UAH-01',percent:100,text:'The fictional milestone has documentary support.'});
  assert.equal(x.command('UAH','clerk',4,{type:'STAGE',id:'P-UAH-01',target:'COMPLETED',reason:'This concludes the illustrative study.'}).board.proposals[0].stage,'COMPLETED');
 }finally{x.cleanup();}
});
test('stored snapshot tampering is detected and event edits are rejected',()=>{
 const x=setup();try{
  x.command('UAH','member',0,{type:'COMMENT',id:'P-UAH-01',stance:'CONCERN',text:'Synthetic budget impact should be explained.'});
  assert.throws(()=>x.store.db.exec("UPDATE participation_events SET command_hash='bad' WHERE institution_id='UAH'"),/IMMUTABLE_PARTICIPATION_EVENT/);
  x.store.db.prepare('UPDATE participation_boards SET board_json=? WHERE institution_id=?').run('{"mode":"SYNTHETIC_ONLY","proposals":[]}', 'UAH');
  assert.throws(()=>x.read(),/PARTICIPATION_SNAPSHOT_MISMATCH/);
 }finally{x.cleanup();}
});
test('same-origin localhost web app, authenticated API, and redacted fictional dossier',async()=>{
 const x=setup(),{server}=createServer({store:x.store,keyPath:join(x.dir,'local-signing.pem')});
 await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
 try{
  const base='http://127.0.0.1:'+server.address().port;
  const page=await fetch(base+'/demo/');assert.equal(page.status,200);
  assert.match(await page.text(),/cwpart-app/);
  assert.match(page.headers.get('content-security-policy'),/connect-src 'self'/);
  const denied=await fetch(base+'/demo/%2e%2e/src/store.mjs');assert.ok([401,404].includes(denied.status));assert.equal((await denied.text()).includes('class Store'),false);
  assert.equal((await fetch(base+'/api/v1/participation/UAH')).status,401);
  const headers={Authorization:'Bearer '+x.tokens.UAH.member.token,'Content-Type':'application/json'};
  const first=await fetch(base+'/api/v1/participation/UAH',{headers});
  assert.equal(first.status,200);assert.equal((await first.json()).version,0);
  const write=await fetch(base+'/api/v1/participation/UAH/commands',{method:'POST',headers,body:JSON.stringify({key:key(),expectedVersion:0,command:{type:'COMMENT',id:'P-UAH-01',stance:'QUESTION',text:'A fictional question about the budget proposal'}})});
  assert.equal(write.status,200);assert.equal((await write.json()).version,1);
  assert.equal((await fetch(base+'/api/v1/participation/HOA',{headers})).status,403);
  const dossier=await fetch(base+'/api/v1/participation/UAH/dossiers/P-UAH-01',{headers});
  assert.equal(dossier.status,200);const text=JSON.stringify(await dossier.json());
  assert.equal(text.includes('A fictional question about the budget proposal'),false);
  assert.equal(text.includes('NOT_ASSESSED'),true);
  const wrongType=await fetch(base+'/api/v1/participation/UAH/commands',{method:'POST',headers:{Authorization:'Bearer '+x.tokens.UAH.member.token},body:'{}'});
  assert.equal(wrongType.status,415);
 }finally{await new Promise(resolve=>server.close(resolve));x.cleanup();}
});
