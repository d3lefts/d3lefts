import test from "node:test";
import assert from "node:assert/strict";
import {profiles,syntheticCase} from "../fixtures.mjs";
import {evaluate} from "../core.mjs";
for(const p of profiles){
 test(p.id+": complete synthetic trace is internally supported, NEVER legally certified",()=>{
   const c=syntheticCase(p);
   const r=evaluate(p,c.motion,c.evidence);
   assert.equal(r.proceduralOutcome,"SUPPORTED_IN_SIMULATION");
   assert.equal(r.officialCertification,false);
   assert.equal(r.legalAuthorization,"NOT_ASSESSED");
   assert.equal(r.checks.length,10);
 });
 for(const scenario of ["stale-rule","changed-motion","outsider","duplicate","no-quorum","cross-tenant"]){
  test(p.id+": rejects "+scenario,()=>{
    const c=syntheticCase(p,scenario);
    assert.equal(evaluate(p,c.motion,c.evidence).proceduralOutcome,"REJECTED_IN_SIMULATION");
  });
 }
 test(p.id+": missing reviewer evidence is indeterminate",()=>{
   const c=syntheticCase(p,"missing-review");
   assert.equal(evaluate(p,c.motion,c.evidence).proceduralOutcome,"INDETERMINATE");
 });
}
test("exact rational threshold accepts equality only when non-strict",()=>{
 const p={...profiles[0],threshold:{numerator:2,denominator:3,strict:false}};
 const c=syntheticCase(p);
 c.evidence.ballots=[{voter:"f1",choice:"yes"},{voter:"f2",choice:"yes"},{voter:"f3",choice:"no"}];
 assert.equal(evaluate(p,c.motion,c.evidence).proceduralOutcome,"SUPPORTED_IN_SIMULATION");
 p.threshold.strict=true;
 assert.equal(evaluate(p,c.motion,c.evidence).proceduralOutcome,"REJECTED_IN_SIMULATION");
});
test("one institution rule revision does not mutate other institution fixtures",()=>{
 const a=syntheticCase(profiles[0]);
 const changed={...profiles[0],ruleRevision:"union-rules-2026-v2"};
 assert.equal(evaluate(changed,a.motion,a.evidence).proceduralOutcome,"REJECTED_IN_SIMULATION");
 for(const other of profiles.slice(1)){
   const c=syntheticCase(other);
   assert.equal(evaluate(other,c.motion,c.evidence).proceduralOutcome,"SUPPORTED_IN_SIMULATION");
 }
});
test("client supplied synthetic checks cannot produce official certification",()=>{
 for(const p of profiles){
  const c=syntheticCase(p);
  const r=evaluate(p,c.motion,c.evidence);
  assert.equal(r.officialCertification,false);
  assert.equal(r.independentVerification,"NOT_PERFORMED");
 }
});
