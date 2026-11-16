import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {ExtendedStore} from '../src/extended-store.mjs';
import {createServer} from '../src/http.mjs';
const policy={quorum:1,yesNumerator:1,yesDenominator:2,strict:true};
let k=0;const key=()=>`api-${String(++k).padStart(8,'0')}`;
test('extended authenticated HTTP supports source, publication, evidence and recertification without public PII',async()=>{
 const dir=mkdtempSync(join(tmpdir(),'cw-http-')),store=new ExtendedStore(join(dir,'test.sqlite'));
 const server=createServer({store,keyPath:join(dir,'signing.pem')}).server;
 const creds={};
 try{
  store.provisionInstitution('demo-union','Fictional union',policy);
  for(const [id,role,eligible] of [['admin','admin',false],['member-a','member',true],['chair','chair',false],['clerk','clerk',false],['auditor','auditor',false],['release-one','release-reviewer',false],['release-two','release-reviewer',false]])creds[id]=store.provisionActor('demo-union',id,role,eligible);
  await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));const base='http://127.0.0.1:'+server.address().port;
  const post=(who,path,payload)=>fetch(base+path,{method:'POST',headers:{Authorization:`Bearer ${creds[who]}`,'Content-Type':'application/json'},body:JSON.stringify(payload)});
  const cmd=(who,action,version,payload={})=>post(who,'/api/v1/commands',{institutionId:'demo-union',itemId:'decision-a',action,expectedVersion:version,payload,key:key()});
  let r=await post('admin','/api/v1/sources',{institutionId:'demo-union',sourceId:'bylaws-a',text:'Entirely invented rules',status:'ENACTED',sourceUri:'synthetic:bylaws-a',key:key()});assert.equal(r.status,200);
  const steps=[['member-a','CREATE',0,{body:'Synthetic internal motion'}],['member-a','ATTACH_SOURCE',1,{sourceId:'bylaws-a'}],['member-a','SUBMIT',2],['chair','AGENDA',3],['chair','BEGIN',4],['clerk','ATTEND',5,{attendees:['member-a']}],['chair','LOCK',6],['chair','OPEN',7],['member-a','CAST',8,{choice:'yes'}],['chair','CLOSE',9],['clerk','REVIEW',10],['clerk','PREPARE_PUBLICATION',11,{content:'Nonbinding fictional summary',reason:'First'}]];
  for(const [who,action,v,payload={}] of steps){r=await cmd(who,action,v,payload);assert.equal(r.status,200,`${action}: ${await r.text()}`);}
  let snap=store.snapshot(store.authenticate(creds.auditor),'demo-union','decision-a');const projection=snap.projections[0];
  assert.equal((await cmd('member-a','REVIEW_PUBLICATION',12,{projectionHash:projection.hash})).status,403);
  assert.equal((await cmd('release-one','REVIEW_PUBLICATION',12,{projectionHash:projection.hash})).status,200);
  assert.equal((await cmd('release-two','REVIEW_PUBLICATION',13,{projectionHash:projection.hash})).status,200);
  assert.equal((await cmd('clerk','PUBLISH_PREVIEW',14)).status,200);
  r=await fetch(`${base}/api/v1/institutions/demo-union/items/decision-a/public-preview`,{headers:{Authorization:`Bearer ${creds['member-a']}`}});assert.equal(r.status,200);
  const preview=await r.json();assert.equal(preview.content,'Nonbinding fictional summary');assert.ok(!JSON.stringify(preview).includes('member-a'));
  assert.equal((await fetch(`${base}/api/v1/institutions/demo-union/items/decision-a/evidence`,{headers:{Authorization:`Bearer ${creds['member-a']}`}})).status,403);
  const evidenceResponse=await fetch(`${base}/api/v1/institutions/demo-union/items/decision-a/evidence`,{headers:{Authorization:`Bearer ${creds.auditor}`}});assert.equal(evidenceResponse.status,200);
  const evidence=await evidenceResponse.json();assert.equal(evidence.payload.format,'commonwealth.os.demo-evidence.v2');
  r=await post('auditor','/api/v1/recertify',{envelope:evidence,changes:[{type:'ELIGIBILITY_CHANGED',institutionId:'demo-union',epoch:999}]});assert.equal(r.status,200);assert.equal((await r.json()).impact.status,'RECHECK_REQUIRED');
  r=await post('member-a','/api/v1/recertify',{envelope:evidence,changes:[]});assert.equal(r.status,403);
  r=await post('admin','/api/v1/actors/revoke',{institutionId:'demo-union',memberId:'member-a',key:key()});assert.equal(r.status,200);
  assert.equal((await fetch(base+'/api/v1/me',{headers:{Authorization:`Bearer ${creds['member-a']}`}})).status,401);
 }finally{await new Promise(res=>server.close(res));store.close();rmSync(dir,{recursive:true,force:true});}
});
