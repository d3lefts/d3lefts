// Commonwealth OS procedural evidence checker — SYNTHETIC demonstrations only.
// Pure function; deterministic, independent of UI rendering. Never a legal certification.
export function evaluate(profile, motion, evidence) {
  const checks=[];
  const check=(code,value,ok,bad)=>{
    const status=value==null?"UNKNOWN":value?"PASS":"FAIL";
    checks.push({code,status,detail: status==="PASS"?ok:status==="FAIL"?bad:"Required evidence is missing."});
  };
  const present=Array.isArray(evidence.present)?evidence.present:null;
  const ballots=Array.isArray(evidence.ballots)?evidence.ballots:null;
  const eligible=Array.isArray(profile.eligible)?profile.eligible:null;
  check("SYNTHETIC_SCOPE",profile.mode==="SYNTHETIC" && evidence.kind==="SYNTHETIC","Demo-only evidence; not a legal vote.","Real or differently classified evidence is not admitted by this demo.");
  check("TENANT_ISOLATION",profile.id&&evidence.institutionId&&motion.institutionId?profile.id===evidence.institutionId&&profile.id===motion.institutionId:null,"All records name the same institution.","Cross-institution records are not accepted.");
  check("RULE_REVISION",profile.ruleRevision&&evidence.ruleRevision?profile.ruleRevision===evidence.ruleRevision:null,"Evidence references the current synthetic rule revision.","Evidence references a different or stale rule revision.");
  check("MOTION_LOCK",motion.revision&&evidence.motionRevision&&motion.status&&evidence.status?motion.revision===evidence.motionRevision&&motion.status==="MOTION_LOCKED"&&evidence.status==="BALLOT_CLOSED":null,"The closed ballot references the locked proposal revision.","Proposal version or ballot state does not match.");
  check("ROSTER_ATTESTATION",evidence.rosterAttested==null?null:evidence.rosterAttested===true && eligible!==null,"Synthetic eligibility roster marked attested.","Eligibility roster not attested.");
  const attendanceValid=present&&eligible?new Set(present).size===present.length&&present.every(id=>eligible.includes(id)):null;
  check("ATTENDANCE",evidence.attendanceAttested==null||attendanceValid==null?null:evidence.attendanceAttested===true&&attendanceValid,"Attested attendance contains only eligible unique members.","Attendance is not attested, duplicated, or contains ineligible members.");
  check("QUORUM",present&&Number.isInteger(profile.quorum)?present.length>=profile.quorum:null,"Synthetic quorum requirement is met.","Quorum requirement not met.");
  const validBallots=ballots&&present&&eligible?ballots.every(b=>b&&typeof b.voter==="string"&&["yes","no","abstain"].includes(b.choice)&&present.includes(b.voter)&&eligible.includes(b.voter))&&new Set(ballots.map(b=>b.voter)).size===ballots.length:null;
  check("BALLOT_ELIGIBILITY",validBallots,"Each synthetic ballot belongs to a distinct attending eligible member.","Duplicate, ineligible, absent, or malformed ballot.");
  const counts=ballots?{yes:ballots.filter(b=>b?.choice==="yes").length,no:ballots.filter(b=>b?.choice==="no").length,abstain:ballots.filter(b=>b?.choice==="abstain").length}:null;
  const t=profile.threshold;
  const validThreshold=t&&Number.isInteger(t.numerator)&&Number.isInteger(t.denominator)&&t.denominator>0&&t.numerator>0&&t.numerator<=t.denominator;
  const cast=counts?counts.yes+counts.no:0;
  const thresholdMet=validThreshold&&counts?cast>0&&(t.strict?counts.yes*t.denominator>cast*t.numerator:counts.yes*t.denominator>=cast*t.numerator):null;
  check("APPROVAL_THRESHOLD",thresholdMet,"Synthetic yes/no tally meets the configured exact rational threshold.","Required approval threshold not met, or there are no decisive votes.");
  const reviewValid=evidence.reviewApproved==null?null:evidence.reviewApproved===true&&evidence.reviewerRole==="clerk"&&evidence.reviewerId&&evidence.reviewerId!==motion.proposer;
  check("SEPARATE_REVIEW",reviewValid,"A distinct synthetic clerk review is recorded.","Clerk review missing, rejected, or not separated from proposal author.");
  const proceduralOutcome=checks.some(x=>x.status==="FAIL")?"REJECTED_IN_SIMULATION":checks.some(x=>x.status==="UNKNOWN")?"INDETERMINATE":"SUPPORTED_IN_SIMULATION";
  return {schemaVersion:"0.1.0",institutionId:profile.id,motionId:motion.id,motionRevision:motion.revision,ruleRevision:evidence.ruleRevision??null,mode:"SYNTHETIC",proceduralOutcome,counts,checks,officialCertification:false,legalAuthorization:"NOT_ASSESSED",independentVerification:"NOT_PERFORMED",limitations:["Client-side synthetic fixtures are not authenticated records.","A successful procedural check does not establish legal authority or ballot secrecy.","No official voting, real identities, or municipal records are processed."]};
}
