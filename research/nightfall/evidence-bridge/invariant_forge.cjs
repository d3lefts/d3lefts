#!/usr/bin/env node
"use strict";
/* INVARIANT FORGE — metamorphic proof obligations for exact finite verifiers.
   Independent design by Ryev. Uses arithmetic identities, not merely wrong-output tampering. */
const C=require("../../../docs/referee-core.js"),assert=require("node:assert/strict");
function equalShiftMap(a,b,reverse){
 assert.equal(a.length,b.length);
 const lookup=new Map(b.map(x=>[x.lag,BigInt(x.numerator)]));
 for(const s of a)assert.equal(BigInt(s.numerator),lookup.get(reverse?-s.lag:s.lag),"Exact lag covariance failed at "+s.lag);
}
function transformOverlap(original,kind){
 const a=original.heights.map(String),d=BigInt(original.denominator);
 const reflect=arr=>arr.slice().reverse();
 const complement=arr=>arr.map(x=>(d-BigInt(x)).toString());
 return {denominator:original.denominator,heights:kind==="reverse"?reflect(a):kind==="complement"?complement(a):reflect(complement(a))};
}
function checkOverlapInvariant(src){
 const baseline=C.checkOverlap(src);
 assert.equal(baseline.status,"FINITE_CHECK_PASSED");
 const cases=[];
 for(const [kind,reversed] of [["reverse",true],["complement",true],["reverse-complement",false]]){
  const transformed=transformOverlap(src,kind),result=C.checkOverlap(transformed);
  assert.equal(result.status,"FINITE_CHECK_PASSED");
  assert.deepEqual(result.summary.score,baseline.summary.score,"Metamorphism changed global maximum");
  equalShiftMap(baseline.shifts,result.shifts,reversed);
  cases.push({transform:kind,score:result.summary.score,lagCovariance:reversed?"k -> -k":"k -> k",passed:true});
 }
 return {cells:src.heights.length,denominator:src.denominator,metamorphisms:cases};
}
function checkSidonInvariant(){
 const original={points:C.SIDON_WITNESS.map(String),subset:C.SIDON_SUBSET.map(String)};
 const base=C.checkSidon(original,17);assert.equal(base.status,"FINITE_CHECK_PASSED");
 const cases=[];
 for(const [a,b] of [[2n,37n],[3n,-71n],[-1n,19n]]){
  const map=x=>(a*BigInt(x)+b).toString();
  const order=xs=>xs.slice().sort((x,y)=>BigInt(x)<BigInt(y)?-1:BigInt(x)>BigInt(y)?1:0);
  const transformed={points:order(original.points.map(map)),subset:order(original.subset.map(map))};
  const r=C.checkSidon(transformed,17);
  assert.equal(r.status,"FINITE_CHECK_PASSED");
  assert.equal(r.weakSidonA.tested,base.weakSidonA.tested);
  assert.equal(r.weakSidonB.checked,base.weakSidonB.checked);
  assert.equal(r.proof.arithmeticProgressions,base.proof.arithmeticProgressions);
  // Search memoization count can depend on coordinate index ordering; it is not an invariant.
  assert.equal(r.subset.pairSums,base.subset.pairSums);
  cases.push({a:String(a),b:String(b),maxSidon:17,states:r.proof.states,progressions:r.proof.arithmeticProgressions,passed:true});
 }
 return cases;
}
let random=1729;const rand=()=>{random=(Math.imul(random,1664525)+1013904223)>>>0;return random};
const records=[checkOverlapInvariant(C.OVERLAP_DEMO)];
for(let j=0;j<40;j++){
 const n=16,d=20,first=Array.from({length:n/2},()=>rand()%(d+1)),last=first.map(x=>d-x);
 let a=first.concat(last);
 for(let i=a.length-1;i>0;i--){const k=rand()%(i+1);[a[i],a[k]]=[a[k],a[i]]}
 records.push(checkOverlapInvariant({denominator:String(d),heights:a.map(String)}));
}
const sidon=checkSidonInvariant();
assert.equal(records.length,41);assert.equal(sidon.length,3);
const report={format:"nightfall-invariant-forge-v1",seed:1729,domains:["continuous-step-overlap","weak-sidon-4-5-finite"],
 overlapInputs:records.length,overlapSymmetryChecks:records.length*3,sidonAffineChecks:sidon.length,
 algebraicIdentities:[
  "Q_rev(k)=Q(-k): reversing both cell coordinates reverses the signed shift.",
  "Q_comp(k)=Q(-k): complementing all heights reverses ordered pair product.",
  "Q_rev_comp(k)=Q(k): composition fixes every signed-lag numerator.",
  "Sidon/weak-(4,5) conditions are invariant under x -> a*x+b for a nonzero integer a."
 ],sidon,scope:"Finite exact arithmetic metamorphic test; not outside verification or a claim of new mathematical theorem."};
console.log(JSON.stringify(report,null,2));
