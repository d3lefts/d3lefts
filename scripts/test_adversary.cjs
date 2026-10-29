"use strict";
const assert=require("node:assert/strict");
const A=require("../docs/adversary-core.js");
function base(x={}){return{domain:"sidon",reach:"finite",statement:"Finite test",assumptions:"Distinct integer marks",source:"source:demo",baseline:"finite example",...x}}
const valid=A.attack(base({points:"0 1 3 7",property:"strong-sidon"}));
assert.equal(valid.status,"NO_COUNTEREXAMPLE_IN_TESTED_SCOPE");
assert.equal(valid.probe.counterexample,null);
const weak=A.attack(base({points:"1 2 3 5",property:"weak-sidon"}));
assert.equal(weak.probe.status,"FINITE_TEST_SURVIVED");
const four=A.attack(base({points:"1 2 3 5",property:"four-five"}));
assert.equal(four.status,"COUNTEREXAMPLE_FOUND");
assert.deepEqual(four.probe.counterexample.points,[1,2,3,5]);
assert(four.probe.counterexample.count<5);
const strong=A.attack(base({points:"1 2 3 5",property:"strong-sidon"}));
assert.equal(strong.status,"COUNTEREXAMPLE_FOUND");
assert.equal(BigInt(strong.probe.counterexample.first[0])+BigInt(strong.probe.counterexample.first[1]),BigInt(strong.probe.counterexample.sum));
assert.equal(BigInt(strong.probe.counterexample.second[0])+BigInt(strong.probe.counterexample.second[1]),BigInt(strong.probe.counterexample.sum));
assert.throws(()=>A.attack(base({points:"1 1 2 3"})),/distinct/);
assert.throws(()=>A.attack(base({points:"1 2 three 4"})),/integer/);
assert.throws(()=>A.attack(base({points:Array(41).fill(0).map((_,i)=>i)})),/4–40/);
const universal=A.attack(base({reach:"universal",points:"0 1 3 7"}));
assert(universal.contract.omissions.some(s=>s.includes("Universal claim")));
assert(!universal.scientificStatus.includes("THEOREM PROVED"));
const none=A.attack({domain:"general",reach:"universal",statement:"An unspecified universal lemma"});
assert.equal(none.status,"INCONCLUSIVE");
assert(none.contract.omissions.length>=3);
// Independent signed-lag oracle via pair differences, rather than the production per-shift summation.
function independent(xs,D){
 const shifts=new Map();
 for(let i=0;i<xs.length;i++)for(let j=0;j<xs.length;j++){
  const lag=i-j,k=String(lag),sum=BigInt(xs[i])*BigInt(D-xs[j]);
  shifts.set(k,(shifts.get(k)||0n)+sum);
 }
 let best=0n;for(const v of shifts.values())if(v>best)best=v;
 return [2n*best,BigInt(xs.length)*BigInt(D)*BigInt(D)];
}
function cmpFrac(x,p,q){const [a,b]=x.split("/").map(BigInt);return a*q-p*b}
let tests=0;
for(let n=2;n<=16;n+=2)for(let D of [2,4,8]){
 const xs=Array(n).fill(D/2);
 const result=A.overlap({denominator:String(D),heights:xs});
 const [num,den]=independent(xs,D);
 assert.equal(cmpFrac(result.exactMaximum,num,den),0n);
 assert(result.neighbor.movesTested<=256);
 assert.equal(result.neighbor.best===null,!result.neighbor.strictImprovementFound);
 if(result.neighbor.best){
  const ys=result.neighbor.best.heights;
  assert.equal(ys.reduce((a,b)=>a+b,0),xs.reduce((a,b)=>a+b,0));
  assert.equal(cmpFrac(result.neighbor.best.exactMaximum,...independent(ys,D)),0n);
  assert(cmpFrac(result.neighbor.best.exactMaximum,num,den)<0n);
 }
 tests++;
}
const example=A.attack({domain:"overlap",reach:"universal",statement:"Every rational step witness improves the record",assumptions:"Uniform cells",source:"fixture",baseline:"prior",denominator:"2",heights:"1 1",claimedUpper:"0"});
assert.equal(example.status,"COUNTEREXAMPLE_FOUND");
assert.equal(example.probe.upperViolated,true);
assert(example.contract.omissions.some(x=>x.includes("Universal claim")));
assert.throws(()=>A.overlap({denominator:2,heights:"2 2"}),/Mass constraint/);
assert.throws(()=>A.overlap({denominator:2,heights:"1 3"}),/heights/);
assert.throws(()=>A.overlap({denominator:2,heights:"1 1",claimedUpper:"1/0"}),/denominator/);
const noRefutation=A.attack({domain:"overlap",reach:"finite",denominator:"2",heights:"1 1",claimedUpper:"1"});
assert.equal(noRefutation.status,"NO_COUNTEREXAMPLE_IN_TESTED_SCOPE");
assert.equal(noRefutation.probe.counterexample,null);
console.log("Imaginary Adversary: exact counterexamples, boundary gates, "+tests+" independent overlap oracles and mutation controls PASS");
