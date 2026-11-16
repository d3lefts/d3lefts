// All institutions, names, motion text and voters below are fictional test fixtures.
export const profiles=[
  {
    "id": "firefighters",
    "short": "Union",
    "name": "Firefighter association",
    "subheading": "Membership governance · synthetic",
    "mode": "SYNTHETIC",
    "ruleRevision": "union-rules-2026-v1",
    "quorum": 4,
    "threshold": {
      "numerator": 1,
      "denominator": 2,
      "strict": true
    },
    "eligible": [
      "f1",
      "f2",
      "f3",
      "f4",
      "f5",
      "f6",
      "f7"
    ],
    "authority": "Illustrative association bylaws; not IAFF Local 1833 bylaws.",
    "scope": "Nonbinding internal motion simulation.",
    "motion": {
      "id": "UNION-MOTION-001",
      "revision": "amendment-v2",
      "title": "Committee selection rule",
      "summary": "Synthetic proposal to revise a committee selection procedure."
    },
    "attendance": [
      "f1",
      "f2",
      "f3",
      "f4",
      "f5"
    ],
    "votes": [
      "yes",
      "yes",
      "yes",
      "no",
      "abstain"
    ],
    "reviewer": "union-clerk",
    "proposer": "union-chair"
  },
  {
    "id": "student",
    "short": "Student Council",
    "name": "University student senate",
    "subheading": "Representative governance · synthetic",
    "mode": "SYNTHETIC",
    "ruleRevision": "student-rules-2026-v1",
    "quorum": 5,
    "threshold": {
      "numerator": 2,
      "denominator": 3,
      "strict": false
    },
    "eligible": [
      "s1",
      "s2",
      "s3",
      "s4",
      "s5",
      "s6",
      "s7"
    ],
    "authority": "Illustrative student senate rules; not UAH bylaws.",
    "scope": "Nonbinding senate resolution simulation.",
    "motion": {
      "id": "STUDENT-RESOLUTION-001",
      "revision": "resolution-v3",
      "title": "Campus service resolution",
      "summary": "Synthetic resolution proposing a student-service evaluation."
    },
    "attendance": [
      "s1",
      "s2",
      "s3",
      "s4",
      "s5"
    ],
    "votes": [
      "yes",
      "yes",
      "yes",
      "yes",
      "no"
    ],
    "reviewer": "senate-clerk",
    "proposer": "senate-sponsor"
  },
  {
    "id": "municipal",
    "short": "Municipality",
    "name": "Municipal council",
    "subheading": "Statutory governance · synthetic",
    "mode": "SYNTHETIC",
    "ruleRevision": "municipal-rules-2026-v1",
    "quorum": 3,
    "threshold": {
      "numerator": 1,
      "denominator": 2,
      "strict": true
    },
    "eligible": [
      "m1",
      "m2",
      "m3",
      "m4",
      "m5"
    ],
    "authority": "Illustrative council rules; not verified Huntsville law.",
    "scope": "Nonbinding shadow ordinance review simulation.",
    "motion": {
      "id": "MUNICIPAL-ITEM-001",
      "revision": "ordinance-v1",
      "title": "Public records procedure",
      "summary": "Synthetic ordinance change used only to test legislative provenance."
    },
    "attendance": [
      "m1",
      "m2",
      "m3",
      "m4",
      "m5"
    ],
    "votes": [
      "yes",
      "yes",
      "yes",
      "no",
      "no"
    ],
    "reviewer": "city-clerk-demo",
    "proposer": "council-member-demo"
  }
];
export function syntheticCase(profile, scenario="valid"){
  const motion={...profile.motion,institutionId:profile.id,status:"MOTION_LOCKED",proposer:profile.proposer};
  const evidence={kind:"SYNTHETIC",institutionId:profile.id,ruleRevision:profile.ruleRevision,motionRevision:motion.revision,status:"BALLOT_CLOSED",rosterAttested:true,attendanceAttested:true,present:[...profile.attendance],ballots:profile.attendance.map((voter,i)=>({voter,choice:profile.votes[i]})),reviewApproved:true,reviewerRole:"clerk",reviewerId:profile.reviewer};
  if(scenario==="stale-rule")evidence.ruleRevision="superseded-"+profile.ruleRevision;
  if(scenario==="changed-motion")evidence.motionRevision="superseded-"+motion.revision;
  if(scenario==="outsider")evidence.ballots[0]={voter:"unregistered-person",choice:"yes"};
  if(scenario==="duplicate")evidence.ballots.push({...evidence.ballots[0]});
  if(scenario==="missing-review")evidence.reviewApproved=null;
  if(scenario==="no-quorum")evidence.present=[];
  if(scenario==="cross-tenant")evidence.institutionId="other-institution";
  return {motion,evidence};
}
export const scenarios=[["valid","Complete synthetic evidence"],["stale-rule","Superseded authority rule"],["changed-motion","Changed motion version"],["outsider","Ineligible ballot"],["duplicate","Duplicate ballot"],["missing-review","Missing clerk review"],["no-quorum","Missing quorum"],["cross-tenant","Cross-institution evidence"]];
