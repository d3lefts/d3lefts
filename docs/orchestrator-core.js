/* Pure deterministic orchestration planner. No remote execution or proof promotion. */
(function(root,factory){const api=factory();if(typeof module==="object"&&module.exports)module.exports=api;else root.NIGHTFALL_ORCHESTRATOR=api;})(typeof globalThis==="object"?globalThis:this,function(){"use strict";
const ROLES=["constructor","reproducer","adversary","formalizer"];
function validText(s){return typeof s==="string"&&s.trim().length>0&&s.length<=2000}
function plan(input){
if(!input||!validText(input.claim)||!validText(input.source)||!validText(input.falsifier))throw Error("A claim, source reference and falsification condition are required.");
const id=String(input.id||"UNASSIGNED").trim().slice(0,80);
if(input.digest&& !/^[a-f0-9]{64}$/i.test(input.digest.trim()))throw Error("Source digest must be a 64-character SHA-256 hex string.");
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
function audit(receipts){if(!Array.isArray(receipts))throw Error("Receipts must be an array.");const required=["A","B","C","D"];const ids=new Set();const issues=[];for(const r of receipts){if(!r||!required.includes(r.id)||ids.has(r.id)){issues.push("Invalid or duplicate lane receipt");continue;}ids.add(r.id);if(!["PASS","FAIL","INCONCLUSIVE"].includes(r.outcome))issues.push(r.id+": invalid outcome");if(typeof r.command!=="string"||!r.command.trim())issues.push(r.id+": missing executable command");if(typeof r.output!=="string"||!r.output.trim())issues.push(r.id+": missing recorded output");if(!/^[a-f0-9]{64}$/i.test(r.sha256||""))issues.push(r.id+": missing SHA-256 digest");}for(const id of required)if(!ids.has(id))issues.push(id+": missing receipt");const verdict=issues.length?"INCONCLUSIVE":assess(receipts.map(r=>r.outcome));return {verdict,issues,scope:"Receipt structure and task outcomes only; no mathematical proof or external independence certified."};}
function assess(items){if(!Array.isArray(items)||!items.length)return "INCONCLUSIVE";const values=items.map(x=>String(x).toUpperCase());if(values.includes("FAIL"))return "FAIL";if(values.every(x=>x==="PASS"))return "PASS — task checks only; no theorem promotion";return "INCONCLUSIVE";}
return Object.freeze({plan,assess,audit,ROLES});
});