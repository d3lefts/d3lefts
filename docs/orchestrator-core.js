/* Pure deterministic orchestration planner. No remote execution or proof promotion. */
(function(root,factory){const api=factory();if(typeof module==="object"&&module.exports)module.exports=api;else root.NIGHTFALL_ORCHESTRATOR=api;})(typeof globalThis==="object"?globalThis:this,function(){"use strict";
const ROLES=["constructor","reproducer","adversary","formalizer"];
function validText(s){return typeof s==="string"&&s.trim().length>0&&s.length<=2000}
function plan(input){
if(!input||!validText(input.claim)||!validText(input.source)||!validText(input.falsifier))throw Error("A claim, source reference and falsification condition are required.");
const id=String(input.id||"UNASSIGNED").trim().slice(0,80);
const frozen={id,claim:input.claim.trim(),source:input.source.trim(),falsifier:input.falsifier.trim(),digest:validText(input.digest)?input.digest.trim():"PENDING: source hash"};
const tasks=[
{id:"A",role:"constructor",depends:[],brief:"Derive a candidate or witness and publish all assumptions, source code, input bytes and hashes."},
{id:"B",role:"reproducer",depends:["freeze"],brief:"Rebuild from the frozen claim and original inputs. Exclude construction code, expected intermediate values and source checker internals."},
{id:"C",role:"adversary",depends:["freeze"],brief:"Try to falsify the precise claim; check quantifiers, counterexamples, normalization, prior art and numerical error."},
{id:"D",role:"formalizer",depends:["freeze"],brief:"Reconstruct the proof obligations; disclose every imported axiom and unresolved lemma. Never count admitted axioms as a complete proof."},
{id:"E",role:"integrator",depends:["A","B","C","D"],brief:"Compare evidence artifacts and provenance. Disagreement yields INCONCLUSIVE; require independent review for external-verification status."}
];
return {schema:"nightfall-orchestrator-plan-v1",mode:"local planning only",frozen,tasks,requiredReceipt:["frozen source commit and SHA-256","checker commit and SHA-256","exact command and environment","output and scope","PASS/FAIL/INCONCLUSIVE","counterexample or unresolved obligations"],gate:"No automatic promotion of scientific status."};
}
function assess(items){if(!Array.isArray(items)||!items.length)return "INCONCLUSIVE";const values=items.map(x=>String(x).toUpperCase());if(values.includes("FAIL"))return "FAIL";if(values.every(x=>x==="PASS"))return "PASS — task checks only; no theorem promotion";return "INCONCLUSIVE";}
return Object.freeze({plan,assess,ROLES});
});