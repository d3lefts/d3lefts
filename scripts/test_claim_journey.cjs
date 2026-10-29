"use strict";
const assert=require("node:assert/strict");
require("../docs/research-registry.js");
const C=require("../docs/claim-journey-core.js"),R=global.NightfallRegistry;
assert.ok(R&&R.claims.length>=6);
let count=0;
for(const claim of R.claims){
 assert.ok(C.isClaim(R,claim.id));
 for(let i=0;i<claim.open.length;i++){
  const c=C.get(R,claim.id,i);
  assert.ok(c);assert.equal(c.obligation,claim.open[i]);
  assert.equal(C.parse(R,"?claim="+claim.id+"&obligation="+i).contract.key,c.key);
  assert.equal(C.parse(R,"?claim="+claim.id).contract.key,claim.id+"|0");
  assert.match(C.brief(c,"attempted contradiction"),/UNREVIEWED/);
  assert.match(C.brief(c,"attempted contradiction"),/attempted contradiction/);
  assert.ok(decodeURIComponent(C.issue(c,"test falsifier")).includes("/ obligation "+(i+1)));
  assert.ok(!/\bcertified\b/i.test(C.issue(c,"test falsifier")),"No false approval in review proposal");
  assert.equal(C.url(claim.id,i),"join.html?claim="+claim.id+"&obligation="+i+"#claim-investigation");
  count++;
 }
 assert.equal(C.get(R,claim.id,claim.open.length),null);
}
assert.equal(C.parse(R,"").requested,false);
assert.equal(C.parse(R,"?claim=totally_unknown").contract,null);
for(const invalid of ["-1","999","0x0","1.0","000","constructor","%3Cimg%3E"]){
 assert.equal(C.parse(R,"?claim=erdos36&obligation="+invalid).contract,null,invalid);
}
const a=C.get(R,"erdos36",2),notes="Independent SHA and accepted payload provenance.";
const clean={version:1,selected:{claimId:"erdos36",index:2},entries:{[a.key]:{snapshot:a.snapshot,note:notes,savedAt:"2026-10-29T00:00:00Z"}}};
const restored=C.sanitize(R,clean);
assert.equal(restored.selected.claimId,"erdos36");
assert.equal(restored.selected.index,2);
assert.equal(restored.entries[a.key].note,notes);
assert.equal(C.sanitize(R,{...clean,selected:{claimId:"unknown",index:0}}).selected,null);
assert.deepEqual(C.sanitize(R,{...clean,entries:{[a.key]:{...clean.entries[a.key],snapshot:"forged"}}}).entries,{});
assert.deepEqual(C.sanitize(R,{...clean,entries:{[a.key]:{...clean.entries[a.key],note:100}}}).entries,{});
assert.deepEqual(C.sanitize(R,{...clean,entries:{["__proto__|0"]:{...clean.entries[a.key]}}}).entries,{});
assert.equal(C.sanitize(R,{...clean,entries:{[a.key]:{...clean.entries[a.key],note:"x".repeat(9000)}}}).entries[a.key].note.length,4000);
assert.match(decodeURIComponent(C.issue(a,notes)),/Recover accepted competition input identity/);
assert.match(decodeURIComponent(C.issue(a,notes)),/No theorem, novelty, competition status/);
console.log("PASS claim continuity: "+count+" registry obligations, fail-closed deep links, source fingerprint, unreviewed notes and prefilled issue scope.");
