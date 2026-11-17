/* Commonwealth Experience: deliberately fictional, read-only onboarding model.
 * No user data, authority, live public opinion, or actual MCP service is represented here.
 */
export const ROLES = Object.freeze(["resident", "representative", "developer"]);
export const RESPONSES = Object.freeze([
  Object.freeze({id:"support", label:"Support"}),
  Object.freeze({id:"oppose", label:"Do not support"}),
  Object.freeze({id:"need_information", label:"Need more information"}),
  Object.freeze({id:"no_preference", label:"No preference"})
]);
export const FICTIONAL_ISSUE = Object.freeze({
  id:"DEMO-EX-014", revision:"v2", authority:"FICTIONAL STUDENT SENATE",
  title:"Should a fictional campus trial extended library hours?",
  description:"A hypothetical six-week evening-access pilot would use a capped demonstration budget. This is not a proposal at any actual institution.",
  sourceStatus:"SYNTHETIC_UNVERIFIED",
  publicStatus:"ILLUSTRATIVE_ONLY"
});
export const FICTIONAL_VIEWPOINTS = Object.freeze([
  Object.freeze({id:"access", label:"Expand access", count:11, stance:"Support",
    concern:"Commuting students could benefit from later hours.",
    common:"Publish costs and evaluate usage."}),
  Object.freeze({id:"staffing", label:"Protect staffing", count:7, stance:"Do not support",
    concern:"Staff safety and working hours need explicit protections.",
    common:"Publish costs and evaluate usage."}),
  Object.freeze({id:"evidence", label:"Request evidence", count:6, stance:"Need more information",
    concern:"Estimate usage, staffing costs and accessibility before proceeding.",
    common:"Publish costs and evaluate usage."})
]);
export const FICTIONAL_STEPS = Object.freeze([
  Object.freeze({label:"Source", title:"Establish the governing rule",
    narrative:"A fictional senate ruleset establishes who can introduce, amend and decide a resolution. No real authority has been checked.",
    evidence:"SIMULATED RULESET / not authenticated"}),
  Object.freeze({label:"Proposal", title:"Publish the exact proposed text",
    narrative:"DEMO-EX-014 v1 proposes later library hours. Its wording is visible instead of being reduced to an issue label.",
    evidence:"FICTIONAL DOCUMENT / v1"}),
  Object.freeze({label:"Deliberation", title:"Keep disagreement and amendments visible",
    narrative:"In the example, staffing concerns lead to a revised six-week trial with a capped budget. This is an invented scenario, not measured consensus.",
    evidence:"FICTIONAL AMENDMENT / v2"}),
  Object.freeze({label:"Response", title:"Require a reasoned institutional response",
    narrative:"An imaginary committee records conditional support for studying the pilot. This is not an actual ballot, government authorization, or completed policy.",
    evidence:"ILLUSTRATIVE RESPONSE / nonbinding"}),
  Object.freeze({label:"Follow-through", title:"Track what happened—and what is missing",
    narrative:"Implementation and impact evidence do not exist. The example deliberately stops at an unresolved milestone rather than claiming delivery.",
    evidence:"IMPLEMENTATION UNKNOWN / no completion evidence"})
]);
export function fictionalTotal(viewpoints=FICTIONAL_VIEWPOINTS) {
  if (!Array.isArray(viewpoints) || viewpoints.some(x=>!Number.isSafeInteger(x.count)||x.count<0))
    throw new TypeError("Viewpoint counts must be nonnegative integers");
  return viewpoints.reduce((sum,x)=>sum+x.count,0);
}
export function chooseResponse(id) {
  if (!RESPONSES.some(r=>r.id===id)) throw new RangeError("Unrecognized advisory preference");
  return Object.freeze({id, label:RESPONSES.find(r=>r.id===id).label, officialVote:false, persisted:false});
}
export function validateRole(role) {
  if (!ROLES.includes(role)) throw new RangeError("Unknown audience role");
  return role;
}
export function stepAt(index) {
  if (!Number.isSafeInteger(index)||index<0||index>=FICTIONAL_STEPS.length)
    throw new RangeError("Unknown evidence step");
  return FICTIONAL_STEPS[index];
}
