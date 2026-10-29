"use strict";
/* Independent negative controls for source-scoped, non-transitive impact analysis. */
const assert=require("node:assert/strict");
const fs=require("node:fs");
const {load,validate,assess,sourcePath}=require("./claim_impact.cjs");
const original=load(fs.readFileSync("docs/research-registry.js","utf8"));
const clone=x=>JSON.parse(JSON.stringify(x));
validate(original);
assert.ok(original.claims.length>=5,"expected canonical claims");
assert.ok(original.edges.some(e=>e.relation==="analogy"),"expected typed analogy");

const before=clone(original),after=clone(original);
const target=after.claims.find(c=>c.id==="sidon30");
target.validity={...target.validity,label:"Explicit status wording correction"};
const cited=sourcePath(target.sources[0].url);
assert.ok(cited&&cited.startsWith("research/"),"cited local source must resolve");
const diff=assess(before,after,[cited,"research/unrelated.txt"]);
const change=diff.changedClaims.find(c=>c.id==="sidon30");
assert.ok(change?.fields.includes("validity"));
assert.ok(diff.statusChanges.some(c=>c.id==="sidon30"&&c.humanReviewRequired));
assert.ok(diff.directlyAffectedClaims.some(c=>c.id==="sidon30"&&
  c.reasons.some(r=>r.includes("cited source changed"))));
assert.ok(!diff.directlyAffectedClaims.some(c=>c.id==="werner"),
  "Do not infer theorem transmission through general mechanism links");
assert.ok(diff.limits.includes("No inferred proof dependency"));
assert.equal(diff.changedMechanisms.length,0);

const changedEdge=clone(original);
const edge=changedEdge.edges.find(e=>e.relation==="analogy");
edge.note+=" Distinct evidence note for impact audit.";
const eReport=assess(original,changedEdge,[]);
assert.ok(eReport.changedTypedEdges.some(k=>k.includes("analogy")));
assert.ok(eReport.directlyAffectedClaims.some(c=>c.id===edge.from));
assert.ok(!eReport.statusChanges.length,"Evidence-edge note is not status promotion");

const invalid=clone(original);
invalid.edges[0].note="";
assert.throws(()=>validate(invalid),/unqualified edge/);
invalid.edges[0].note="Reinstated";
invalid.edges[0].to="phantom-mechanism";
assert.throws(()=>validate(invalid),/unknown mechanism edge/);
const bad=clone(original);
bad.claims[0].validity.level="";
assert.throws(()=>validate(bad),/unscoped status/);
const missing=clone(original);
missing.mechanisms[0].witnesses.push("phantom-claim");
assert.throws(()=>validate(missing),/unknown mechanism witness/);
const dup=clone(original);
dup.claims.push(clone(dup.claims[0]));
assert.throws(()=>validate(dup),/duplicate claim/);
assert.equal(sourcePath("https://example.com/x"),null,"outside repo sources are opaque");
assert.equal(sourcePath("evidence.html"),"docs/evidence.html");

console.log("PASS claim impact: real registry schema, direct change attribution, "
 +"status review flags, source-path matching, non-transitivity, 5 corrupted controls");
