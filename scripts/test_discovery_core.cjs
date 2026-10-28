"use strict";
const assert=require("node:assert/strict");
const C=require("../docs/discovery-core.js");
assert.equal(C.VERSION,"1.0.0");
assert.deepEqual(C.PROJECTS.map(p=>p.id),["ea36","sidon","pas"],"Only originality-approved preset projects are public");
assert.equal(C.FAMILIES.length,8);
let checks=0;
for(let n=5;n<=23;n++)for(let m=2;m<n;m++)for(const op of C.FAMILIES){
 const options={n,mass:m,seed:1729+n*101+m*17,steps:8,operator:op.id};
 const a=C.runToy(options),b=C.evalB(a.best_bits);
 assert.equal(C.verify(a.best_bits,{n,mass:m,max:a.best_max,hist:a.best_hist}).pass,true);
 assert.deepEqual(C.evalA(a.best_bits).hist,b.hist);
 assert.equal(a.best_max,b.max);
 assert.equal(a.gap,a.best_max-C.bound(n,m));
 assert.equal(a.negative_control,"PASS");
 assert.equal(a.best_bits.reduce((x,y)=>x+y,0),m);
 assert.equal(C.verify(a.best_bits,{n,mass:m,max:a.best_max+1,hist:a.best_hist}).pass,false);
 assert.deepEqual(C.runToy(options).best_bits,a.best_bits,"seed reproducibility");
 checks++;
}
assert.throws(()=>C.runToy({n:49,mass:8}));
assert.throws(()=>C.runToy({n:12,mass:12}));
assert.throws(()=>C.runToy({n:12,mass:3,steps:2001}));
assert.equal(C.verify([1,2,0]).pass,false);
console.log("PASS NIGHTFALL Discovery Core: "+checks+" exact deterministic operator experiments");
