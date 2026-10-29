"use strict";
/* Separate checker using the website's existing field implementation rather than
   the new Python implementation. Exact finite arithmetic only. */
const assert=require("node:assert/strict");
const F=require("../docs/research-tools-core.js");
const E=Array.from({length:25},(_,i)=>[i%5,Math.floor(i/5)]);
const key=x=>x[0]+5*x[1];
let matches=0;
for(const x of E)for(const y of E){
  if(key(F.power(x,4))===key(F.power(y,4)))matches++;
}
assert.equal(matches,97);
for(const x of E){
  for(let o=1;o<=4;o++){
    const scaled=F.mul([o,0],x);
    assert.equal(key(F.power(scaled,4)),key(F.power(x,4)));
  }
}
assert.equal(97n**7n<5n**20n,true);
for(let k=1;k<=5;k++){
  const Q=25n;
  const independentPairs=((Q**BigInt(k)-1n)*(Q**BigInt(k)-Q))/32n;
  assert.equal(independentPairs*32n,(Q**BigInt(k)-1n)*(Q**BigInt(k)-Q));
}
const ambiguity=F.f25({rows:[[[1,0],[0,0]],[[0,0],[1,0]]],signal:[[1,0],[1,0]]});
assert.equal(ambiguity.phaseOrbits,4);
const zeros=F.f25({rows:[[[0,0],[0,0]]],signal:[[1,0],[1,0]]});
assert.equal(zeros.phaseOrbits,157);
console.log("PASS: independent website F25 representation, exact 97/625 collision, μ4 symmetry, rank-orbit count and negative controls");
