#!/usr/bin/env node
// Independent implementation: deliberately does NOT import the server's codec/store/evidence.
import { readFileSync } from 'node:fs';
import { createHash,createPublicKey,verify } from 'node:crypto';
function canonical(v){
  if(v===null||typeof v!=='object')return JSON.stringify(v);
  if(Array.isArray(v))return '['+v.map(canonical).join(',')+']';
  return '{'+Object.keys(v).sort().map(k=>JSON.stringify(k)+':'+canonical(v[k])).join(',')+'}';
}
const digest=v=>createHash('sha256').update(typeof v==='string'?v:canonical(v)).digest('hex');
const requireCheck=(p,c)=>{if(!c)throw new Error('CHECK_FAILED_'+p);};
function fraction(policy,votes){
 const yes=votes.filter(v=>v.choice==='yes').length,no=votes.filter(v=>v.choice==='no').length;
 const lhs=BigInt(yes)*BigInt(policy.yesDenominator),rhs=BigInt(yes+no)*BigInt(policy.yesNumerator);
 return yes+no>0&&(policy.strict?lhs>rhs:lhs>=rhs);
}
export function verifyEvidence(envelope,{trustedPublicKeyPem}={}) {
 const checked=[];
 const check=(name,c)=>{requireCheck(name,c);checked.push(name);};
 check('ENVELOPE',envelope?.envelope==='commonwealth.os.portable-evidence.v1'&&envelope?.signature?.alg==='Ed25519');
 const p=envelope.payload,s=envelope.signature;
 check('KEY_FINGERPRINT',digest(s.publicKeyPem)===s.keyId);
 const signature=Buffer.from(s.signature,'base64');
 check('SIGNATURE',verify(null,Buffer.from(canonical(p)),createPublicKey(s.publicKeyPem),signature));
 if(trustedPublicKeyPem)check('PINNED_SIGNER',digest(trustedPublicKeyPem)===s.keyId);
 check('NONBINDING',p.format==='commonwealth.os.demo-evidence.v1'&&p.officialCertification===false&&p.legalAuthority==='NOT_ASSESSED');
 check('INSTITUTION',typeof p.institution?.id==='string'&&p.events.every(e=>e.institutionId===p.institution.id&&e.itemId===p.item.id));
 let lastHash='GENESIS',lastState=null,lastSeq=0,reviewEvent=null,locked=null;
 const castEvents=[];
 const edges={CREATE:[null,'DRAFT'],REVISE:null,SUBMIT:['DRAFT','IN_REVIEW'],AGENDA:['IN_REVIEW','AGENDA_SET'],BEGIN:['AGENDA_SET','DELIBERATING'],ATTEND:['DELIBERATING','DELIBERATING'],LOCK:['DELIBERATING','MOTION_LOCKED'],OPEN:['MOTION_LOCKED','BALLOT_OPEN'],CAST:['BALLOT_OPEN','BALLOT_OPEN'],CLOSE:['BALLOT_OPEN','BALLOT_CLOSED'],REVIEW:['BALLOT_CLOSED','REVIEWED_DEMO']};
 for(const e of p.events){
  const {hash,previousHash,...event}=e;
  check('EVENT_'+e.seq,e.seq===++lastSeq&&previousHash===lastHash&&digest({event,previousHash})===hash);
  check('EVENT_EDGE_'+e.seq,Object.hasOwn(edges,e.action)&&((e.action==='REVISE'&&e.from===e.to&&['DRAFT','IN_REVIEW'].includes(e.from))||(edges[e.action]&&edges[e.action][0]===e.from&&edges[e.action][1]===e.to))&&e.from===lastState);
  lastHash=hash;lastState=e.to;
  if(e.action==='LOCK')locked=e;
  if(e.action==='CAST')castEvents.push(e);
  if(e.action==='REVIEW')reviewEvent=e;
 }
 check('LATEST_STATE',p.events.length>0&&lastState===p.item.state&&p.item.version===p.events.length);
 let prev='GENESIS',rev=0;
 for(const r of p.revisions){
  check('REVISION_'+r.revision,r.revision===++rev&&r.previousHash===prev&&digest({institutionId:p.institution.id,itemId:p.item.id,revision:r.revision,body:r.body,previousHash:prev})===r.bodyHash);
  prev=r.bodyHash;
 }
 check('LATEST_REVISION',p.item.currentRevision===rev);
 const revEvents=p.events.filter(e=>e.action==='REVISE'||e.action==='CREATE');
 check('REVISION_EVENTS',revEvents.length===rev&&revEvents.every((e,i)=>e.details.revision===i+1&&e.details.bodyHash===p.revisions[i].bodyHash));
 if(locked){
  const d=locked.details;
  check('MOTION_PIN',p.item.lockedRevision===d.lockedRevision&&d.lockedRevision===rev&&d.policyVersion===p.item.lockedPolicyVersion);
  const active=p.policies.find(x=>x.version===d.policyVersion);
  check('POLICY_PIN',!!active&&active.hash===d.policyHash&&digest(active.policy)===active.hash);
  check('ROSTER_AT_LOCK',Array.isArray(d.eligibleRoster)&&new Set(d.eligibleRoster).size===d.eligibleRoster.length);
  check('ATTENDANCE',JSON.stringify([...p.attendance].sort())===JSON.stringify([...d.attendees].sort())&&new Set(p.attendance).size===p.attendance.length&&p.attendance.every(x=>d.eligibleRoster.includes(x))&&p.attendance.length>=active.policy.quorum);
  check('VOTES',castEvents.length===p.votes.length&&new Set(p.votes.map(v=>v.actorId)).size===p.votes.length&&p.votes.every(v=>p.attendance.includes(v.actorId)&&['yes','no','abstain'].includes(v.choice)&&castEvents.some(e=>e.actorId===v.actorId&&e.actorRole==='member'&&e.details.voter===v.actorId&&e.details.choice===v.choice)));
  if(reviewEvent){
   check('REVIEWER',reviewEvent.actorRole==='clerk'&&reviewEvent.actorId===p.item.reviewer&&reviewEvent.actorId!==p.item.proposer&&!p.votes.some(v=>v.actorId===reviewEvent.actorId));
   const outcome=fraction(active.policy,p.votes)?'SUPPORTED_IN_SIMULATION':'REJECTED_IN_SIMULATION';
   const counts={yes:p.votes.filter(v=>v.choice==='yes').length,no:p.votes.filter(v=>v.choice==='no').length,abstain:p.votes.filter(v=>v.choice==='abstain').length};
   check('REVIEW_OUTCOME',reviewEvent.details.outcome===outcome&&p.item.outcome===outcome&&Object.keys(counts).every(k=>counts[k]===reviewEvent.details.counts?.[k]));
  }
 }
 // Current rules/roster can change later, making the evidence stale, not retroactively falsifying history.
 const stale=!!locked&&(locked.details.policyVersion!==p.institution.policyVersion||locked.details.eligibilityVersion!==p.institution.eligibilityVersion);
 return {ok:true,checks:checked.length,signer:trustedPublicKeyPem?'PINNED':'SELF_ASSERTED',authorityStatus:stale?'STALE_REVIEW_REQUIRED':'NO_CHANGE_DETECTED',officialCertification:false};
}
if(process.argv[1]&&process.argv[1].endsWith('/verify.mjs')){
 try {
  const [, ,file,flag,pin]=process.argv;
  if(!file)throw new Error('USAGE: node verify.mjs evidence.json [--trusted-key public.pem]');
  if(flag&&flag!=='--trusted-key')throw new Error('UNKNOWN_OPTION');
  if(flag&&!pin)throw new Error('TRUSTED_KEY_PATH_REQUIRED');
  const result=verifyEvidence(JSON.parse(readFileSync(file,'utf8')),{trustedPublicKeyPem:pin?readFileSync(pin,'utf8'):undefined});
  console.log(JSON.stringify(result,null,2));
 }catch(e){console.error('EVIDENCE_REJECTED',e.message);process.exitCode=1;}
}
