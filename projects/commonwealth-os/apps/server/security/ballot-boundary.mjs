// Explicit ballot threat-model and release gate. No secret-ballot algorithm is invented.
// A named synthetic roll call is NOT a voter-private election, even if encrypted at rest.
const MODES=Object.freeze({SYNTHETIC_ROLL_CALL:'SYNTHETIC_ROLL_CALL',CONFIDENTIAL:'CONFIDENTIAL',OFFICIAL:'OFFICIAL'});
export { MODES };
export function admitBallotSession({mode,institutionId,lockedRevision,policyVersion,eligibilityVersion,legalAuthority,electionProtocol}={}){
 if(mode!==MODES.SYNTHETIC_ROLL_CALL)return {allowed:false,reason:'NO_REVIEWED_E2E_BALLOT_PROTOCOL',ballotSecrecy:'NOT_ESTABLISHED',official:false};
 if(legalAuthority===true||electionProtocol!==undefined)return {allowed:false,reason:'SYNTHETIC_ONLY_NO_AUTHORITY',ballotSecrecy:'NOT_ESTABLISHED',official:false};
 if(!institutionId||!Number.isSafeInteger(lockedRevision)||!Number.isSafeInteger(policyVersion)||!Number.isSafeInteger(eligibilityVersion))return {allowed:false,reason:'MISSING_VERSION_LOCK',ballotSecrecy:'NOT_ESTABLISHED',official:false};
 return {allowed:true,reason:'SYNTHETIC_ONLY',mode,ballotSecrecy:'NONE_ROLL_CALL',official:false};
}
export function redactBallotEvidence(input,{visibility}={}){
 // Only an *allowlisted* aggregate from a separately reviewed tally is exportable.
 if(visibility!=='PUBLIC_REVIEWED' || input?.publicationApproved!==true)throw Error('PUBLICATION_NOT_APPROVED');
 const {institutionId,motionId,motionDigest,reviewDigest,counts}=input;
 if(![institutionId,motionId,motionDigest,reviewDigest].every(x=>typeof x==='string'&&x.length>0)||!counts||!['yes','no','abstain'].every(k=>Number.isSafeInteger(counts[k])&&counts[k]>=0))throw Error('PUBLICATION_EVIDENCE_INVALID');
 return Object.freeze({institutionId,motionId,motionDigest,reviewDigest,counts:{yes:counts.yes,no:counts.no,abstain:counts.abstain},voterSelectionsPublished:false,publicProofScope:'AGGREGATE_ONLY_NOT_E2E_VERIFIABLE'});
}
