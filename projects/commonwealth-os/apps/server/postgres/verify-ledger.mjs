// Source-independent, deterministic verifier for the PostgreSQL synthetic ledger.
// No imports from the PostgreSQL adapter or its policy evaluator.
import {createHash,createPublicKey,verify as cryptoVerify} from 'node:crypto';
function canonical(v){
 if(v===null||typeof v!=='object')return JSON.stringify(v);
 if(Array.isArray(v))return '['+v.map(canonical).join(',')+']';
 return '{'+Object.keys(v).sort().map(k=>JSON.stringify(k)+':'+canonical(v[k])).join(',')+'}';
}
const digest=x=>createHash('sha256').update(canonical(x)).digest('hex');
const assert=(value,msg)=>{if(!value)throw Error('PG_REPLAY_'+msg);};
const edges={CREATE:[null,'DRAFT'],REVISE:null,SUBMIT:['DRAFT','IN_REVIEW'],AGENDA:['IN_REVIEW','AGENDA_SET'],BEGIN:['AGENDA_SET','DELIBERATING'],ATTEND:['DELIBERATING','DELIBERATING'],LOCK:['DELIBERATING','MOTION_LOCKED'],OPEN:['MOTION_LOCKED','BALLOT_OPEN'],CAST:['BALLOT_OPEN','BALLOT_OPEN'],CLOSE:['BALLOT_OPEN','BALLOT_CLOSED'],REVIEW:['BALLOT_CLOSED','REVIEWED_DEMO']};
const roles={CREATE:['member','chair'],REVISE:['member','clerk'],SUBMIT:['member','chair'],AGENDA:['chair'],BEGIN:['chair'],ATTEND:['clerk'],LOCK:['chair'],OPEN:['chair'],CAST:['member'],CLOSE:['chair'],REVIEW:['clerk']};
function meetsThreshold(policy,yes,no,abstain,presentCount,eligibleCount){
 const basis=policy.approvalBasis??'DECISIVE';const denom={DECISIVE:yes+no,CAST:yes+no+abstain,PRESENT:presentCount,ELIGIBLE:eligibleCount}[basis];
 assert(Number.isSafeInteger(denom),'THRESHOLD_BASIS');
 return denom>0&&(policy.strict?BigInt(yes)*BigInt(policy.yesDenominator)>BigInt(denom)*BigInt(policy.yesNumerator):BigInt(yes)*BigInt(policy.yesDenominator)>=BigInt(denom)*BigInt(policy.yesNumerator));
}
export function verifyPgLedger(p){
 assert(p?.officialCertification===false&&p.legalAuthority==='NOT_ASSESSED','MODE');
 assert(p?.institutionId===p?.item?.institution_id,'TENANT');
 assert(Array.isArray(p.events)&&p.events.length>0&&Array.isArray(p.authorityJournal),'EVENTS');
 const actors=new Map(),states=new Map();let authSeq=0,authHash='GENESIS',policyVersion=0,eligibilityVersion=0;
 for(const e of p.authorityJournal){
  const {hash:got,previousHash,...event}=e;
  assert(e.seq===++authSeq&&e.institutionId===p.institutionId&&previousHash===authHash&&digest({event,previousHash})===got,'AUTHORITY_CHAIN');
  const d=e.details;
  if(e.action==='INSTITUTION_PROVISIONED'){
   assert(authSeq===1&&d.policyVersion===1&&d.eligibilityVersion===1,'BOOTSTRAP');policyVersion=1;eligibilityVersion=1;
  }else if(e.action==='ACTOR_PROVISIONED'){
   assert(!actors.has(d.actorId)&&['member','chair','clerk','admin','auditor','release-reviewer'].includes(d.role)&&typeof d.eligible==='boolean'&&d.active===true,'ACTOR_GRANT');
   actors.set(d.actorId,{role:d.role,eligible:d.eligible,active:true});if(d.role==='member')eligibilityVersion++;
   assert(d.eligibilityVersion===eligibilityVersion,'ACTOR_EPOCH');
  }else if(e.action==='ELIGIBILITY_CHANGED'){
   const actor=actors.get(d.actorId),admin=actors.get(d.by);assert(actor?.active&&actor.role==='member'&&admin?.active&&admin.role==='admin','ELIGIBILITY_GRANT');
   actor.eligible=d.eligible;eligibilityVersion++;assert(d.eligibilityVersion===eligibilityVersion,'ELIGIBILITY_EPOCH');
  }else if(e.action==='POLICY_CHANGED'){
   const admin=actors.get(d.by);assert(admin?.active&&admin.role==='admin','POLICY_GRANT');
   policyVersion++;assert(d.policyVersion===policyVersion,'POLICY_EPOCH');
  }else assert(false,'AUTHORITY_ACTION');
  const snap={seq:e.seq,hash:got,policyVersion,eligibilityVersion,actors:new Map([...actors].map(([k,v])=>[k,{...v}]))};
  states.set(e.seq,snap);authHash=got;
 }
 assert(Number(p.institution.policy_version)===policyVersion&&Number(p.institution.eligibility_version)===eligibilityVersion,'CURRENT_EPOCH');
 assert(p.members.length===actors.size&&p.members.every(m=>{const a=actors.get(m.actor_id);return a?.role===m.role&&a.eligible===m.eligible&&a.active===m.active;}),'CURRENT_MEMBERS');
 assert(p.policies.length===policyVersion&&p.policies.every((row,i)=>Number(row.version)===i+1&&digest(row.policy)===row.policy_hash),'POLICY_HISTORY');
 assert(p.policies[0].policy_hash===p.authorityJournal[0].details.policyHash,'INITIAL_POLICY');
 let hash='GENESIS',state=null,seq=0,lock=null,attendance=[],votes=[],review=null;
 for(const e of p.events){
  const {hash:got,previousHash,...event}=e;
  assert(e.seq===++seq&&e.institutionId===p.institutionId&&e.itemId===p.item.item_id,'INDEX');
  assert(previousHash===hash&&digest({event,previousHash})===got,'HASH');
  const edge=edges[e.action];
  assert(Object.hasOwn(edges,e.action)&&e.from===state&&(
   e.action==='REVISE'?['DRAFT','IN_REVIEW','AGENDA_SET','DELIBERATING'].includes(state)&&e.to==='DRAFT':edge?.[0]===state&&edge?.[1]===e.to),'EDGE');
  const authority=states.get(e.details.authoritySeq);
  assert(authority?.hash===e.details.authorityHash,'AUTHORITY_POINTER');
  const actor=authority.actors.get(e.actorId);
  assert(actor?.active&&actor.role===e.actorRole&&roles[e.action].includes(actor.role),'ACTOR_AT_EFFECT');
  if(e.action==='ATTEND'){
   assert(Array.isArray(e.details.attendees)&&e.details.attendees.length===new Set(e.details.attendees).size,'ATTENDANCE_UNIQUE');
   assert(e.details.attendees.every(x=>{const a=authority.actors.get(x);return a?.active&&a.role==='member'&&a.eligible;}),'ATTENDANCE_ELIGIBLE');
   attendance=e.details.attendees;
  }
  if(e.action==='REVISE'){attendance=[];assert(e.actorId===p.item.proposer||e.actorRole==='clerk','REVISION_AUTHOR');}
  if(e.action==='LOCK'){
   lock=e;
   assert(Number(e.details.policyVersion)===authority.policyVersion&&Number(e.details.eligibilityVersion)===authority.eligibilityVersion,'LOCK_EPOCH');
   const policy=p.policies[authority.policyVersion-1];assert(e.details.policyHash===policy.policy_hash,'LOCK_POLICY');
   const roster=[...authority.actors].filter(([,a])=>a.role==='member'&&a.active&&a.eligible).map(([id])=>id).sort();
   assert(JSON.stringify(roster)===JSON.stringify([...e.details.eligibleRoster].sort()),'LOCK_ROSTER');
   assert(JSON.stringify([...attendance].sort())===JSON.stringify([...e.details.attendees].sort()),'LOCK_ATTENDANCE');
   assert(attendance.length>=policy.policy.quorum,'LOCK_QUORUM');
   if(policy.policy.quorumFraction){
    const f=policy.policy.quorumFraction;
    const left=BigInt(attendance.length)*BigInt(f.denominator),right=BigInt(roster.length)*BigInt(f.numerator);
    assert(f.strict?left>right:left>=right,'LOCK_QUORUM_FRACTION');
   }
  }
  if(['OPEN','CAST','CLOSE','REVIEW'].includes(e.action)){
   assert(lock&&e.details.policyVersion===lock.details.policyVersion&&e.details.eligibilityVersion===lock.details.eligibilityVersion&&e.details.lockedRevision===lock.details.lockedRevision,'LOCK_PIN');
   assert(authority.policyVersion===lock.details.policyVersion&&authority.eligibilityVersion===lock.details.eligibilityVersion,'CURRENT_AT_EFFECT');
  }
  if(e.action==='CAST'){
   assert(actor.role==='member'&&actor.eligible&&attendance.includes(e.actorId)&&lock.details.eligibleRoster.includes(e.actorId),'CAST_ELIGIBILITY');
   assert(!votes.some(v=>v.actorId===e.actorId)&&['yes','no','abstain'].includes(e.details.choice)&&e.details.voter===e.actorId,'CAST_UNIQUE');
   votes.push({actorId:e.actorId,choice:e.details.choice});
  }
  if(e.action==='REVIEW'){
   assert(e.actorId!==p.item.proposer&&!votes.some(v=>v.actorId===e.actorId),'INDEPENDENT_REVIEW');review=e;
   const policy=p.policies[lock.details.policyVersion-1].policy;
   const yes=votes.filter(v=>v.choice==='yes').length,no=votes.filter(v=>v.choice==='no').length,abstain=votes.filter(v=>v.choice==='abstain').length;
   const outcome=meetsThreshold(policy,yes,no,abstain,attendance.length,lock.details.eligibleRoster.length)?'SUPPORTED_IN_SIMULATION':'REJECTED_IN_SIMULATION';
   assert(e.details.outcome===outcome&&p.item.outcome===outcome&&Object.entries({yes,no,abstain}).every(([k,v])=>e.details.counts[k]===v),'REVIEW_OUTCOME');
  }
  hash=got;state=e.to;
 }
 assert(state===p.item.state&&seq===Number(p.item.version),'FINAL');
 let revision=0,previousHash='GENESIS';
 for(const r of p.revisions){
  const n=Number(r.revision);assert(n===++revision&&r.previous_hash===previousHash,'REVISION_EDGE');
  assert(digest({institutionId:p.institutionId,itemId:p.item.item_id,revision:n,body:r.body,previousHash})===r.body_hash,'REVISION_HASH');
  previousHash=r.body_hash;
 }
 assert(revision===Number(p.item.current_revision),'CURRENT_REVISION');
 assert(JSON.stringify([...p.attendance].sort())===JSON.stringify([...attendance].sort()),'ATTENDANCE_SNAPSHOT');
 assert(JSON.stringify(p.votes.map(x=>[x.actor_id,x.choice]).sort())===JSON.stringify(votes.map(x=>[x.actorId,x.choice]).sort()),'VOTE_SNAPSHOT');
 const changed=lock&&(lock.details.policyVersion!==policyVersion||lock.details.eligibilityVersion!==eligibilityVersion);
 return {ok:true,mode:'SYNTHETIC_LEDGER_ONLY',events:seq,revisions:revision,authorityEvents:authSeq,authorityStatus:changed?'RECHECK_REQUIRED':'UNCHANGED',officialCertification:false,independentLegalAuthority:'NOT_EVALUATED'};
}

/** Verifier requires an EXTERNALLY PINNED signer; key in envelope does not authenticate itself. */
export function verifySignedPgEnvelope(envelope,{trustedPublicKeyPem}){
 assert(typeof trustedPublicKeyPem==='string'&&trustedPublicKeyPem.length>0,'PIN_REQUIRED');
 assert(envelope?.envelope==='commonwealth.os.portable-evidence.v1'&&envelope.signature?.alg==='Ed25519','ENVELOPE');
 assert(envelope.signature.publicKeyPem===trustedPublicKeyPem,'PIN_MISMATCH');
 const valid=cryptoVerify(null,Buffer.from(canonical(envelope.payload)),createPublicKey(trustedPublicKeyPem),Buffer.from(envelope.signature.signature,'base64'));
 assert(valid,'SIGNATURE');
 return verifyPgLedger(envelope.payload);
}
