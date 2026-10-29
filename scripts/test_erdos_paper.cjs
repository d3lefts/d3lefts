"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const root=path.resolve(__dirname,"..");
const core=require(path.join(root,"docs/erdos-paper-core.js"));
const referee=require(path.join(root,"docs/referee-core.js"));
const manifest=JSON.parse(fs.readFileSync(path.join(root,"docs/reproduction-manifest.json"),"utf8"));
const entry=manifest.claims.find(x=>x.id==="erdos36");
assert.ok(entry);
assert.equal(entry.witnessSha256,"a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e");
assert.equal(entry.maximizingSignedLag,-17280);
assert.equal(entry.exactScore,"34788888032212764146872525963225147703298526879/91343852333181432387730302044767688728495783936");
const base=core.FIXTURE.slice(),proof=core.audit(base),profile=core.profile(base);
assert.equal(proof.status,"EXACT_TOY_CHECK_PASSED");
assert.equal(proof.rectangleIntersections,61);
assert.equal(proof.shifts,31);
assert.equal(proof.mass,64);
assert.deepEqual(profile.winners,[-7]);
assert.equal(String(profile.maxRaw),"259");
assert.equal(String(profile.numerator),"518");
assert.equal(String(profile.denominator),"1024");
assert.equal(core.decimal(profile.numerator,profile.denominator,9),"0.505859375");
const checked=referee.checkOverlap({heights:base.map(String),denominator:"8"});
assert.equal(checked.dualPathAgreement,true);
assert.equal(checked.status,"FINITE_CHECK_PASSED");
assert.deepEqual(checked.summary.maxLags,[-7]);
assert.equal(BigInt(checked.summary.score.numerator)*profile.denominator,BigInt(checked.summary.score.denominator)*profile.numerator);
for(let i=0;i<31;i++){
 const k=i-15;
 assert.equal(core.geometry(base,2*k),2n*profile.points[i].raw);
 if(i<30)assert.equal(core.geometry(base,2*k+1),profile.points[i].raw+profile.points[i+1].raw);
}
assert.equal(referee.overlapAttacks({heights:base.map(String),denominator:"8"},checked).scoreTamperRejected,true);
assert.throws(()=>core.validate(base.slice(1)),/16/);
assert.throws(()=>core.validate(base.map((x,i)=>i===0?x+1:x)),/mass/i);
assert.throws(()=>core.validate(base.map((x,i)=>i===0?9:x)),/integer heights/i);
assert.throws(()=>core.transfer(base,0,0),/different/);
assert.throws(()=>core.transfer(base,0,3),/blocked/); // 4th cell is full
let mutations=0;
for(let i=0;i<16;i++)for(let j=0;j<16;j++){
 if(i===j||base[i]===0||base[j]===8)continue;
 const next=core.transfer(base,i,j);
 assert.equal(next.reduce((x,y)=>x+y,0),64);
 assert.equal(next[i],base[i]-1);assert.equal(next[j],base[j]+1);
 const evidence=core.audit(next);
 const r=referee.checkOverlap({heights:next.map(String),denominator:"8"});
 assert.equal(BigInt(r.summary.score.numerator)*BigInt(evidence.maximumDenominator),
  BigInt(r.summary.score.denominator)*BigInt(evidence.maximumNumerator));
 mutations++;
}
assert.ok(mutations>190);
const html=fs.readFileSync(path.join(root,"docs/erdos-paper.html"),"utf8");
assert.match(html,/educational fixture/i);
assert.match(html,/research witness/i);
assert.match(html,/external expert review is open/i);
assert.match(html,/erdos-paper-core.js/);
assert.match(html,/ep-hash-button/);
console.log("PASS Living Paper 002: 31 correlations, 61 exact geometric checks, "+mutations+" mass-preserving perturbation audits, source identity and fail-closed mutations.");
