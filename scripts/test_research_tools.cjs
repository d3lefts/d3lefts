"use strict";
/* Two independent finite correctness paths: direct tensor kernel in the app,
   signed partial-trace subset expansion in this test file. All BigInt. */
const assert = require("node:assert/strict");
const E = require("../docs/research-tools-core.js");
const words=[];
for(let a=0;a<3;a++)for(let b=0;b<3;b++)for(let c=0;c<3;c++)for(let d=0;d<3;d++)words.push(""+a+b+c+d);
function independent16(x,y) {
  const [a,b]=x,[c,d]=y;
  let ans=0n;
  for(let mask=0;mask<16;mask++){
    let count=0,term=1n;
    for(let j=0;j<4;j++)if(mask&(1<<j))count++;
    term=BigInt((count%2)?-1:1)*2n**BigInt(4-count);
    for(let j=0;j<4;j++){
      const match=(mask&(1<<j))?(a[j]===b[j]&&c[j]===d[j]):(a[j]===c[j]&&b[j]===d[j]);
      if(!match){term=0n;break;}
    }
    ans+=term;
  }
  return ans;
}
assert.equal(E.werner([["0000","0000",1],["1011","1011",1],["0112","0112",1]]).qExact,"-3/16");
assert.equal(E.werner([["0000","0000",1],["1011","1011",1],["0112","0112",1]]).rankAtMostTwo,false);
const lemnis=[["0000","0000",4],["0000","1111",1],["1000","2121",1],["0000","0121",1]];
const check=E.werner(lemnis);
assert.equal(check.qExact,"7/2");
assert.equal(check.rank,2);
assert.equal(E.werner([["0000","0000",2],["1000","1000",1]]).qExact,"1/16");
assert.equal(E.werner([["0000","0000",4],["0000","0000",-4],["1111","2222",1]]).rank,1);
assert.equal(E.werner([["0000","0000",4],["0000","0000",-4],["1111","2222",1]]).qExact,"1");
assert.throws(()=>E.werner([["9999","0000",1]]),/four ternary/);
assert.throws(()=>E.werner([["0000","0000","1.1"]]),/bounded signed integers/);
assert.throws(()=>E.werner(Array.from({length:49},()=>["0000","0000",1])),/1–48/);
let seed=113;
function draw(n){seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed%n;}
for(let i=0;i<180;i++){
  const a=[words[draw(81)],words[draw(81)]],b=[words[draw(81)],words[draw(81)]];
  const fromKernel=E.kernel16({row:a[0],col:a[1]},{row:b[0],col:b[1]});
  assert.equal(fromKernel,independent16(a,b), "kernel/partial-trace disagree at trial "+i);
}
const U=[0,1];
assert.deepEqual(E.mul([0,1],[0,1]),[2,0]);
for(let a=0;a<5;a++)for(let b=0;b<5;b++){
 if(a===0&&b===0)continue;
 assert.deepEqual(E.power([a,b],24),[1,0],"F25 nonzero multiplicative order");
}
const coords=E.f25({rows:[[[1,0],[0,0]],[[0,0],[1,0]]],signal:[[1,0],[1,0]]});
assert.equal(coords.preimages,16);
assert.equal(coords.phaseOrbits,4);
assert.equal(coords.identifiableUpToPhase,false);
const zero=E.f25({rows:[[[0,0],[0,0]]],signal:[[1,0],[1,0]]});
assert.equal(zero.preimages,625);
assert.equal(zero.phaseOrbits,157);
assert.equal(zero.identifiableUpToPhase,false);
const identityZero=E.f25({rows:[[[1,0],[0,0]],[[0,0],[1,0]]],signal:[[0,0],[0,0]]});
assert.equal(identityZero.preimages,1);
assert.equal(identityZero.phaseOrbits,1);
assert.throws(()=>E.f25({rows:[[[5,0],[0,0]]],signal:[[1,0],[1,0]]}),/F25 element/);
assert.throws(()=>E.f25({rows:Array(21).fill([[[1,0],[0,0]]]),signal:[[1,0],[1,0]]}),/1–20/);
console.log("PASS: four-qutrit rational Q, exact rank/negative rank-3, 180 independently expanded physical kernels, F25 arithmetic, complete 625-signal ambiguity and tampered-input rejection");
