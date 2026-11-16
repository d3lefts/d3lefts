// Deterministically emit bounded, all-choice three-voter traces for a source-different Python checker.
import { ExtendedStore } from '../src/extended-store.mjs';
import { signingKey,exportEvidence } from '../src/evidence.mjs';
import { verifyExtended } from '../verify-v2.mjs';
import { createPublicKey } from 'node:crypto';
import { mkdtempSync,rmSync } from 'node:fs';import {tmpdir} from 'node:os';import {join} from 'node:path';
const directory=mkdtempSync(join(tmpdir(),'cwos-finite-refinement-'));
const key=signingKey(join(directory,'audit-key.pem'));
const trustedPublicKeyPem=createPublicKey(key).export({format:'pem',type:'spki'}).toString();
let emitted=0;
try {
 for(const basis of ['DECISIVE','CAST','PRESENT','ELIGIBLE'])for(const strict of [false,true])for(let i=0;i<27;i++){
  const choices=[];let n=i;for(let x=0;x<3;x++){choices.push(['yes','no','abstain'][n%3]);n=Math.floor(n/3);}
  const store=new ExtendedStore(':memory:');
  try{
   const policy={quorum:2,yesNumerator:2,yesDenominator:3,strict,approvalBasis:basis};
   const id='fixture-union',itemId='fixture-decision';store.provisionInstitution(id,'Fictional union',policy);
   const actors={};for(const [a,r,e] of [['member-a','member',true],['member-b','member',true],['member-c','member',true],['chair','chair',false],['clerk','clerk',false],['auditor','auditor',false]]){const t=store.provisionActor(id,a,r,e);actors[a]=store.authenticate(t);}
   let version=0,serial=0;const command=(a,action,payload={})=>{const result=store.command(actors[a],{institutionId:id,itemId,action,expectedVersion:version,key:'finite-audit-'+(++serial).toString().padStart(5,'0'),payload});version=result.version;};
   command('member-a','CREATE',{body:'A fictional procedural motion'});command('member-a','SUBMIT');command('chair','AGENDA');command('chair','BEGIN');
   command('clerk','ATTEND',{attendees:['member-a','member-b','member-c']});command('chair','LOCK');command('chair','OPEN');
   for(let k=0;k<3;k++)command(['member-a','member-b','member-c'][k],'CAST',{choice:choices[k]});
   command('chair','CLOSE');command('clerk','REVIEW');
   const snap=store.snapshot(actors.auditor,id,itemId);const envelope=exportEvidence(snap,key);
   const report=verifyExtended(envelope,{trustedPublicKeyPem});if(!report.ok)throw Error('INDEPENDENT_JS_CHECK_REJECTED');
   process.stdout.write(JSON.stringify({basis,strict,choices,policy,trace:snap.events.map(e=>({action:e.action,actor:e.actorId,role:e.actorRole,from:e.from,to:e.to,details:e.details})),outcome:snap.item.outcome})+'\n');emitted++;
  } finally {store.close();}
 }
}finally{rmSync(directory,{recursive:true,force:true});}
console.error(`Generated ${emitted} synthetic signed and replay-checked traces`);
