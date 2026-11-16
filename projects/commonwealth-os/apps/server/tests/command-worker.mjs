import {parentPort,workerData} from 'node:worker_threads';
import {ExtendedStore} from '../src/extended-store.mjs';
const store=new ExtendedStore(workerData.db);
try{
 const actor=store.authenticate(workerData.token);
 const result=store.command(actor,{institutionId:'race-demo',itemId:'race-item',action:'CREATE',expectedVersion:0,payload:{body:'Concurrent fictional motion'},key:workerData.key});
 parentPort.postMessage({ok:true,result});
}catch(e){parentPort.postMessage({ok:false,error:e.code||e.message});}finally{store.close();}
