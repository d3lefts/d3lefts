#!/usr/bin/env node
// Independent source-level replay/checker. Imports NO application modules.
// Claims only consistency of synthetic signed input with a separately trusted key.
import { createHash, createPublicKey, verify } from 'node:crypto';
import { readFileSync } from 'node:fs';
function canonical(v){
  if(v===null||typeof v!=='object')return JSON.stringify(v);
  if(Array.isArray(v))return '['+v.map(canonical).join(',')+']';
  return '{'+Object.keys(v).sort().map(k=>JSON.stringify(k)+':'+canonical(v[k])).join(',')+'}';
}
const hash=x=>createHash('sha256').update(typeof x==='string'?x:canonical(x),'utf8').digest('hex');
function assert(c,code){if(!c)throw Error('CHECK_FAILED_'+code);}
function unique(a){return Array.isArray(a)&&new Set(a).size===a.length;}
function policyOK(p){return p&&Number.isSafeInteger(p.quorum)&&p.quorum>=1&&Number.isSafeInteger(p.yesNumerator)&&p.yesNumerator>=1&&Number.isSafeInteger(p.yesDenominator)&&p.yesDenominator>=p.yesNumerator&&typeof p.strict==='boolean'&&(!p.approvalBasis||['DECISIVE','CAST','PRESENT','ELIGIBLE'].includes(p.approvalBasis))&&(!p.quorumFraction||(Number.isSafeInteger(p.quorumFraction.numerator)&&p.quorumFraction.numerator>=1&&Number.isSafeInteger(p.quorumFraction.denominator)&&p.quorumFraction.denominator>=p.quorumFraction.numerator&&typeof p.quorumFraction.strict==='boolean'&&p.quorumFraction.basis==='ELIGIBLE'));}
function quorum(p,attendance,roster){
 if(!policyOK(p)||attendance>roster||attendance<p.quorum)return false;
 if(!p.quorumFraction)return true;
 const l=BigInt(attendance)*BigInt(p.quorumFraction.denominator),r=BigInt(roster)*BigInt(p.quorumFraction.numerator);
 return p.quorumFraction.strict?l>r:l>=r;
}
function tally(p,votes,present,eligible){
 const yes=votes.filter(v=>v.choice==='yes').length,no=votes.filter(v=>v.choice==='no').length,abstain=votes.filter(v=>v.choice==='abstain').length;
 const denominator={DECISIVE:yes+no,CAST:votes.length,PRESENT:present,ELIGIBLE:eligible}[p.approvalBasis??'DECISIVE'];
 const accepted=denominator>0&&(p.strict?BigInt(yes)*BigInt(p.yesDenominator)>BigInt(denominator)*BigInt(p.yesNumerator):BigInt(yes)*BigInt(p.yesDenominator)>=BigInt(denominator)*BigInt(p.yesNumerator));
 return {yes,no,abstain,accepted};
}
const permitted={
 CREATE:[null,'DRAFT'],SUBMIT:['DRAFT','IN_REVIEW'],AGENDA:['IN_REVIEW','AGENDA_SET'],BEGIN:['AGENDA_SET','DELIBERATING'],
 ATTEND:['DELIBERATING','DELIBERATING'],LOCK:['DELIBERATING','MOTION_LOCKED'],OPEN:['MOTION_LOCKED','BALLOT_OPEN'],
 CAST:['BALLOT_OPEN','BALLOT_OPEN'],CLOSE:['BALLOT_OPEN','BALLOT_CLOSED'],REVIEW:['BALLOT_CLOSED','REVIEWED_DEMO'],
 PREPARE_PUBLICATION:['REVIEWED_DEMO','PUBLICATION_REVIEW'],REVIEW_PUBLICATION:['PUBLICATION_REVIEW','PUBLICATION_REVIEW'],
 PUBLISH_PREVIEW:['PUBLICATION_REVIEW','PUBLISHED_PREVIEW'],CORRECT_PUBLICATION:['PUBLISHED_PREVIEW','PUBLICATION_REVIEW'],
};
const entryRoles={CREATE:['member','chair'],SUBMIT:['member','chair'],AGENDA:['chair'],BEGIN:['chair'],ATTEND:['clerk'],LOCK:['chair'],OPEN:['chair'],CAST:['member'],CLOSE:['chair'],REVIEW:['clerk'],VOID:['chair'],PREPARE_PUBLICATION:['clerk'],CORRECT_PUBLICATION:['clerk'],REVIEW_PUBLICATION:['release-reviewer'],PUBLISH_PREVIEW:['clerk'],ATTACH_SOURCE:['member','chair','clerk'],REVISE:['member','clerk']};

export function verifyExtended(envelope,{trustedPublicKeyPem}={}){
 assert(typeof trustedPublicKeyPem==='string'&&trustedPublicKeyPem.length>0,'TRUST_PIN_REQUIRED');
 assert(envelope?.envelope==='commonwealth.os.portable-evidence.v1'&&envelope?.signature?.alg==='Ed25519','ENVELOPE');
 const p=envelope.payload,s=envelope.signature;
 assert(s.publicKeyPem===trustedPublicKeyPem&&s.keyId===hash(trustedPublicKeyPem),'TRUST_PIN_MISMATCH');
 assert(verify(null,Buffer.from(canonical(p)),createPublicKey(trustedPublicKeyPem),Buffer.from(s.signature,'base64')),'BAD_SIGNATURE');
 assert(p?.format==='commonwealth.os.demo-evidence.v2'&&p.officialCertification===false&&p.legalAuthority==='NOT_ASSESSED','NOT_SYNTHETIC');
 assert(p.institution?.id&&p.item?.id&&Array.isArray(p.events)&&Array.isArray(p.authorityJournal),'STRUCTURE');
 const id=p.institution.id, iid=p.item.id;
 const auth=[],actors=new Map();let seq=0,last='GENESIS',policyVersion=0,eligibilityVersion=0;
 const sourceHeads=new Map();
 for(const e of p.authorityJournal){
   const {hash:h,previousHash,...event}=e;
   assert(e.institutionId===id&&e.seq===++seq&&previousHash===last&&h===hash({event,previousHash}),'AUTHORITY_CHAIN');
   if(e.action==='INSTITUTION_PROVISIONED'){
     assert(seq===1&&e.details.policyVersion===1&&e.details.eligibilityVersion===1,'BOOTSTRAP');
     policyVersion=1;eligibilityVersion=1;
   }else if(e.action==='ACTOR_PROVISIONED'){
     const d=e.details;assert(!actors.has(d.actorId)&&typeof d.role==='string'&&typeof d.eligible==='boolean'&&d.active===true,'ACTOR_GRANT');
     actors.set(d.actorId,{role:d.role,eligible:d.eligible,active:true});
     if(d.role==='member')eligibilityVersion++;
     assert(d.eligibilityVersion===eligibilityVersion,'GRANT_EPOCH');
   }else if(e.action==='ELIGIBILITY_CHANGED'){
     const d=e.details,a=actors.get(d.actorId);assert(a?.role==='member'&&a.active&&actors.get(d.by)?.role==='admin'&&actors.get(d.by)?.active,'ELIGIBILITY_GRANT');
     a.eligible=d.eligible;eligibilityVersion++;assert(d.eligibilityVersion===eligibilityVersion,'ELIGIBILITY_EPOCH');
   }else if(e.action==='ACTOR_REVOKED'){
     const d=e.details,a=actors.get(d.actorId);assert(a?.active&&actors.get(d.by)?.role==='admin'&&actors.get(d.by)?.active&&d.by!==d.actorId,'REVOCATION_GRANT');
     a.active=false;a.eligible=false;eligibilityVersion++;assert(d.eligibilityVersion===eligibilityVersion,'REVOCATION_EPOCH');
   }else if(e.action==='POLICY_CHANGED'){
     const d=e.details;assert(actors.get(d.by)?.role==='admin'&&actors.get(d.by)?.active,'POLICY_GRANT');
     policyVersion++;assert(d.policyVersion===policyVersion,'POLICY_EPOCH');
     const rec=p.policies[policyVersion-1];assert(rec?.hash===d.policyHash,'POLICY_HISTORY_REF');
   }else if(e.action==='SOURCE_REVISED'){
     const d=e.details;assert(actors.get(d.by)?.role==='admin'&&actors.get(d.by)?.active,'SOURCE_GRANT');
     const prev=sourceHeads.get(d.sourceId);
     assert(d.version===(prev?.version??0)+1&&p.sources.some(s=>s.sourceId===d.sourceId&&s.version===d.version&&s.hash===d.hash),'SOURCE_HISTORY_REF');
     sourceHeads.set(d.sourceId,{version:d.version,hash:d.hash});
   }else assert(false,'AUTHORITY_EVENT_TYPE');
   auth.push({hash:h,actors:new Map([...actors].map(([k,v])=>[k,{...v}])),policyVersion,eligibilityVersion,sources:new Map(sourceHeads)});
   last=h;
 }
 assert(seq>0&&p.institution.policyVersion===policyVersion&&p.institution.eligibilityVersion===eligibilityVersion,'INSTITUTION_EPOCHS');
 assert(Array.isArray(p.members)&&p.members.length===actors.size&&p.members.every(m=>{const a=actors.get(m.id);return a&&a.role===m.role&&Number(a.eligible)===m.eligible&&Number(a.active)===m.active;}),'MEMBER_HISTORY');
 assert(Array.isArray(p.policies)&&p.policies.length===policyVersion&&p.policies.every((r,i)=>r.version===i+1&&policyOK(r.policy)&&hash(r.policy)===r.hash),'POLICY_CHAIN');
 assert(p.policies[0].hash===p.authorityJournal[0].details.policyHash,'POLICY_BOOTSTRAP_REF');
 const sources=new Map();
 for(const s of p.sources){
   const prev=sources.get(s.sourceId);
   const version=(prev?.version??0)+1;
   assert(s.version===version&&s.previousHash===(prev?.hash??'GENESIS')&&s.sourceUri.startsWith('synthetic:')&&
    hash({institutionId:id,sourceId:s.sourceId,version,text:s.text,status:s.status,sourceUri:s.sourceUri,previousHash:s.previousHash})===s.hash,'SOURCE_CHAIN');
   sources.set(s.sourceId,s);
 }
 assert([...sources.entries()].every(([k,s])=>sourceHeads.get(k)?.hash===s.hash&&sourceHeads.get(k)?.version===s.version),'SOURCE_AUTHORITY_REF');
 const deps=new Map(), projections=[];let revision=0,revHash='GENESIS';
 for(const s of p.revisions){
   revision++;
   assert(s.revision===revision&&s.previousHash===revHash&&hash({institutionId:id,itemId:iid,revision,body:s.body,previousHash:revHash})===s.bodyHash,'REVISION_CHAIN');
   revHash=s.bodyHash;
 }
 let previous='GENESIS',state=null,n=0,lastAuthority=0,locked=null,attendance=[],cast=[],review=null,projected=0;
 const approvals=new Map();let currentProjection=null;
 for(const e of p.events){
   const {hash:h,previousHash,...event}=e;
   assert(e.seq===++n&&e.institutionId===id&&e.itemId===iid&&previousHash===previous&&hash({event,previousHash})===h,'EVENT_CHAIN');
   assert(e.details?.authoritySeq>=lastAuthority&&e.details.authoritySeq<=auth.length,'AUTHORITY_POINTER');
   const a=auth[e.details.authoritySeq-1];
   assert(a?.hash===e.details.authorityHash,'AUTHORITY_HASH_POINTER');
   const actor=a.actors.get(e.actorId);
   assert(actor?.active&&actor.role===e.actorRole&&entryRoles[e.action]?.includes(actor.role),'EVENT_ACTOR_ROLE');
   if(e.action==='CREATE')assert(state===null&&e.from===null&&e.to==='DRAFT','CREATE_EDGE');
   else if(e.action==='REVISE'){
     assert(['DRAFT','IN_REVIEW'].includes(state)&&e.from===state&&e.to==='DRAFT'&&(e.actorId===p.item.proposer||actor.role==='clerk'),'REVISE_EDGE');
   }else if(e.action==='ATTACH_SOURCE'){
     assert(['DRAFT','IN_REVIEW'].includes(state)&&e.from===state&&e.to==='DRAFT'&&(e.actorId===p.item.proposer||actor.role==='clerk'),'ATTACH_EDGE');
     const sc=a.sources.get(e.details.sourceId);assert(sc?.version===e.details.sourceVersion&&sc?.hash===e.details.sourceHash&&p.sources.find(s=>s.sourceId===e.details.sourceId&&s.version===sc.version)?.status!=='UNKNOWN','ATTACH_SOURCE_REF');
     deps.set(e.details.sourceId,{sourceId:e.details.sourceId,version:e.details.sourceVersion,hash:e.details.sourceHash});
   }else if(e.action==='VOID'){
     assert(['DRAFT','IN_REVIEW','AGENDA_SET','DELIBERATING','MOTION_LOCKED','BALLOT_OPEN','BALLOT_CLOSED'].includes(state)&&e.from===state&&e.to==='VOIDED'&&typeof e.details.reason==='string'&&e.details.reason.trim(),'VOID_EDGE');
   }else{
     const pair=permitted[e.action];assert(pair&&e.from===state&&e.from===pair[0]&&e.to===pair[1],'TRANSITION_EDGE');
   }
   if(e.action==='CREATE'||e.action==='REVISE'){
     const r=p.revisions.find(x=>x.revision===e.details.revision);
     assert(!!r&&r.author===e.actorId&&r.bodyHash===e.details.bodyHash,'REVISION_EVENT');
   }
   if(e.action==='ATTEND'){
     assert(unique(e.details.attendees)&&e.details.attendees.every(x=>{const v=a.actors.get(x);return v?.role==='member'&&v.eligible&&v.active;}),'ATTEND_ELIGIBILITY');
     attendance=[...e.details.attendees].sort();
   }
   if(e.action==='LOCK'){
     const roster=[...a.actors].filter(([,v])=>v.role==='member'&&v.eligible&&v.active).map(([k])=>k).sort();
     const pol=p.policies[a.policyVersion-1];
     assert(e.details.policyVersion===a.policyVersion&&e.details.eligibilityVersion===a.eligibilityVersion&&e.details.policyHash===pol.hash,'LOCK_AUTHORITY');
     assert(e.details.lockedRevision===revision&&p.revisions.length===revision&&unique(e.details.attendees)&&unique(e.details.eligibleRoster),'LOCK_REVISION');
     assert(canonical([...e.details.attendees].sort())===canonical(attendance)&&canonical([...e.details.eligibleRoster].sort())===canonical(roster),'LOCK_PARTICIPANTS');
     assert(quorum(pol.policy,attendance.length,roster.length),'LOCK_QUORUM');
     assert(canonical([...deps.values()].sort((x,y)=>x.sourceId.localeCompare(y.sourceId)))===canonical(e.details.sources),'LOCK_SOURCES');
     locked={event:e,roster,policy:pol.policy,authoritySeq:e.details.authoritySeq,policyVersion:a.policyVersion,eligibilityVersion:a.eligibilityVersion};
   }
   if(['OPEN','CAST','CLOSE','REVIEW','PUBLISH_PREVIEW'].includes(e.action)){
     assert(locked&&locked.policyVersion===a.policyVersion&&locked.eligibilityVersion===a.eligibilityVersion,'STALE_AUTHORITY_ACTION');
     for(const d of deps.values())assert(a.sources.get(d.sourceId)?.version===d.version,'STALE_SOURCE_ACTION');
   }
   if(['OPEN','CAST','CLOSE','REVIEW'].includes(e.action)){
     assert(e.details.policyVersion===locked.policyVersion&&e.details.eligibilityVersion===locked.eligibilityVersion&&e.details.lockedRevision===locked.event.details.lockedRevision,'GUARDED_EPOCH');
   }
   if(e.action==='CAST'){
     assert(actor.eligible&&locked.roster.includes(e.actorId)&&attendance.includes(e.actorId)&&['yes','no','abstain'].includes(e.details.choice)&&e.details.voter===e.actorId&&!cast.some(v=>v.actorId===e.actorId),'CAST_ELIGIBILITY');
     cast.push({actorId:e.actorId,choice:e.details.choice});
   }
   if(e.action==='REVIEW'){
     assert(e.actorId!==p.item.proposer&&!cast.some(v=>v.actorId===e.actorId),'REVIEW_SEPARATION');
     const t=tally(locked.policy,cast,attendance.length,locked.roster.length);
     const outcome=t.accepted?'SUPPORTED_IN_SIMULATION':'REJECTED_IN_SIMULATION';
     assert(e.details.outcome===outcome&&e.details.reviewer===e.actorId&&['yes','no','abstain'].every(k=>e.details.counts?.[k]===t[k]),'REVIEW_TALLY');
     review={actorId:e.actorId,outcome};
   }
   if(['PREPARE_PUBLICATION','CORRECT_PUBLICATION'].includes(e.action)){
     assert(review&&e.actorId===review.actorId&&e.details.revision===++projected,'PREPARE_ROLE');
     const pr=p.projections[projected-1];
     assert(pr&&pr.revision===projected&&e.details.projectionHash===pr.hash,'PROJECTION_EVENT');
     currentProjection=pr;approvals.set(projected,new Set());
   }
   if(e.action==='REVIEW_PUBLICATION'){
     assert(currentProjection&&e.details.revision===currentProjection.revision&&e.details.projectionHash===currentProjection.hash&&e.actorId!==p.item.proposer&&e.actorId!==review?.actorId,'PUBLICATION_REVIEW');
     const set=approvals.get(projected);assert(!set.has(e.actorId),'DUPLICATE_PUBLICATION_APPROVAL');set.add(e.actorId);
   }
   if(e.action==='PUBLISH_PREVIEW'){
     assert(currentProjection&&e.actorId===review?.actorId&&e.details.revision===projected&&e.details.projectionHash===currentProjection.hash,'PUBLISH_PROJECTION');
     assert(approvals.get(projected)?.size>=2&&canonical([...approvals.get(projected)].sort())===canonical(e.details.reviewers),'PUBLISH_DUAL_REVIEW');
   }
   state=e.to;previous=h;lastAuthority=e.details.authoritySeq;
 }
 assert(p.events.length>0&&p.item.state===state&&p.item.version===n,'FINAL_STATE');
 assert(p.item.currentRevision===p.revisions.length,'CURRENT_REVISION');
 assert(canonical([...p.attendance].sort())===canonical(attendance),'FINAL_ATTENDANCE');
 assert(canonical([...p.votes].sort((a,b)=>a.actorId.localeCompare(b.actorId)))===canonical([...cast].sort((a,b)=>a.actorId.localeCompare(b.actorId))),'FINAL_BALLOTS');
 assert((review?.actorId??null)===p.item.reviewer&&(review?.outcome??null)===p.item.outcome,'FINAL_REVIEW');
 assert((locked?.event.details.lockedRevision??null)===p.item.lockedRevision,'FINAL_MOTION_LOCK');
 assert((locked?.policyVersion??null)===p.item.lockedPolicyVersion&&(locked?.eligibilityVersion??null)===p.item.lockedEligibilityVersion,'FINAL_EPOCH_PIN');
 assert(canonical([...deps.values()].sort((a,b)=>a.sourceId.localeCompare(b.sourceId)))===canonical(p.sourceDependencies),'FINAL_SOURCES');
 let prev='GENESIS';
 for(const pr of p.projections){assert(pr.previousHash===prev&&hash({institutionId:id,itemId:iid,revision:pr.revision,content:pr.content,reason:pr.reason,previousHash:prev})===pr.hash,'PROJECTION_HASH');prev=pr.hash;}
 assert(projected===p.projections.length&&p.publicationApprovals.length===[...approvals.values()].reduce((n,s)=>n+s.size,0),'PUBLICATION_HISTORY');
 assert(p.publicationApprovals.every(x=>approvals.get(x.revision)?.has(x.actorId)),'PUBLICATION_APPROVAL_MEMBERS');
 const currentStale=!!locked&&(locked.policyVersion!==policyVersion||locked.eligibilityVersion!==eligibilityVersion||[...deps.values()].some(d=>sources.get(d.sourceId)?.version!==d.version));
 return {ok:true,signer:'EXTERNALLY_PINNED_KEY',officialCertification:false,reviewedHumanLegality:false,authorityStatus:currentStale?'STALE_RECHECK_REQUIRED':'NO_RELEVANT_CHANGE_DETECTED',eventCount:n,authorityEventCount:seq,publicationRevision:projected};
}
if(process.argv[1]?.endsWith('/verify-v2.mjs')){
 try{const [,,file,flag,keyPath]=process.argv;assert(file&&flag==='--trusted-key'&&keyPath,'CLI_USAGE');console.log(JSON.stringify(verifyExtended(JSON.parse(readFileSync(file,'utf8')),{trustedPublicKeyPem:readFileSync(keyPath,'utf8')}),null,2));}
 catch(e){console.error('EVIDENCE_REJECTED',e.message);process.exitCode=1;}
}
