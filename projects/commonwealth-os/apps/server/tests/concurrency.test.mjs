import test from 'node:test';
import assert from 'node:assert/strict';
import {Worker} from 'node:worker_threads';
import {mkdtempSync,rmSync} from 'node:fs';
import {join} from 'node:path';
import {tmpdir} from 'node:os';
import {ExtendedStore} from '../src/extended-store.mjs';
const path=new URL('./command-worker.mjs',import.meta.url);
test('parallel connections serialize same-item CREATE with no duplicate journal',async()=>{
 const dir=mkdtempSync(join(tmpdir(),'cw-race-')),db=join(dir,'db.sqlite'),store=new ExtendedStore(db);
 try{
 store.provisionInstitution('race-demo','Synthetic organization',{quorum:1,yesNumerator:1,yesDenominator:2,strict:true});
 const token=store.provisionActor('race-demo','member-a','member',true);
 const attempts=Array.from({length:8},(_,i)=>new Promise((resolve,reject)=>{
   const worker=new Worker(path,{workerData:{db,token,key:`race-command-${i+1}`}});
   worker.on('message',resolve);worker.on('error',reject);worker.on('exit',code=>{if(code!==0)reject(Error('WORKER_CRASH_'+code));});
 }));
 const results=await Promise.all(attempts);
 assert.equal(results.filter(r=>r.ok).length,1,JSON.stringify(results));
 assert.equal(store.events('race-demo','race-item').length,1);
 assert.equal(store.item('race-demo','race-item').version,1);
 }finally{store.close();rmSync(dir,{recursive:true,force:true});}
});
test('bounded command perturbation does not modify journal on invalid role/state',()=>{
 const dir=mkdtempSync(join(tmpdir(),'cw-fuzz-')),store=new ExtendedStore(join(dir,'db.sqlite'));
 let seed=0x31fc8347;const rand=()=>{seed^=seed<<13;seed^=seed>>>17;seed^=seed<<5;return seed>>>0;};
 try{
 store.provisionInstitution('fuzz-demo','Fictional university',{quorum:1,yesNumerator:1,yesDenominator:2,strict:true});
 const tokenA=store.provisionActor('fuzz-demo','member-a','member',true),tokenB=store.provisionActor('fuzz-demo','auditor','auditor',false);
 const member=store.authenticate(tokenA),auditor=store.authenticate(tokenB);
 const request={institutionId:'fuzz-demo',itemId:'fuzz-item',action:'CREATE',expectedVersion:0,payload:{body:'Fictional test'},key:'init-000001'};
 store.command(member,request);
 const forbidden=['CAST','REVIEW','AGENDA','LOCK','OPEN','CLOSE','PUBLISH_PREVIEW','CORRECT_PUBLICATION','REVIEW_PUBLICATION','VOID','PREPARE_PUBLICATION'];
 for(let i=0;i<500;i++){
  const action=forbidden[rand()%forbidden.length],expectedVersion=rand()%6;
  const before=JSON.stringify(store.events('fuzz-demo','fuzz-item'));
  assert.throws(()=>store.command(auditor,{institutionId:'fuzz-demo',itemId:'fuzz-item',action,expectedVersion,payload:{choice:'yes',reason:'Bad',projectionHash:'false'},key:`fuzz-${String(i).padStart(8,'0')}`}));
  assert.equal(JSON.stringify(store.events('fuzz-demo','fuzz-item')),before,`mutation escaped ${action} ${i}`);
 }
 }finally{store.close();rmSync(dir,{recursive:true,force:true});}
});
