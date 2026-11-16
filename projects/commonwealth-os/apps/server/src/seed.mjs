import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { mkdirSync, existsSync } from 'node:fs';
import { Store } from './store.mjs';
const base=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const dbPath=process.env.COMMONWEALTH_DB??join(base,'data','commonwealth.sqlite');
mkdirSync(dirname(dbPath),{recursive:true,mode:0o700});
if(existsSync(dbPath))throw new Error('REFUSE_TO_RESEED_EXISTING_DATABASE');
const store=new Store(dbPath);
const profiles=[['union-demo','Fictional association',{quorum:2,yesNumerator:1,yesDenominator:2,strict:true}],['student-demo','Fictional student senate',{quorum:2,yesNumerator:2,yesDenominator:3,strict:false}],['municipal-demo','Fictional municipality',{quorum:2,yesNumerator:1,yesDenominator:2,strict:true}]];
for(const [id,name,policy] of profiles){
 store.provisionInstitution(id,name,policy);
 for(const [actor,role,eligible] of [['admin','admin',false],['chair','chair',false],['clerk','clerk',false],['auditor','auditor',false],['member-a','member',true],['member-b','member',true],['member-c','member',true]]){
  const token=store.provisionActor(id,actor,role,eligible);
  console.log(JSON.stringify({institution:id,id:actor,role,token})); // DEV-ONLY: do not save or commit tokens
 }
}
store.close();
console.error('DEV-ONLY fictional credentials printed above. Do not use in production.');
