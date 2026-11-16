"use strict";
const test=require("node:test");
const a=require("node:assert/strict");
const fs=require("node:fs"),path=require("node:path");
const core=require("../docs/permission-lab-evidence-core.js");
const evidence=JSON.parse(fs.readFileSync(path.join(__dirname,"../docs/permission-lab-evidence.json"),"utf8"));
test("Reproducible preregistered scenario comparisons",()=>{
for(const [name,p] of Object.entries(evidence.cases)){
const x=core.assess(p);
a.deepEqual(x.strategies.map(z=>z.cost),p.expected,name);
a.equal(x.hybrid.cost,core.oracle(p));
}});
test("Independent dynamic programming agrees with every exact finite setting",()=>{
let total=0,wins=0,ties=0;
for(let N=0;N<=8;N++)for(let cached=0;cached<=N;cached++)
for(let invalidated=0;invalidated<=cached;invalidated++)
for(let K=0;K<=2*N+2;K++)for(const raw of [0,1,3])
for(const rawFee of [0,2])for(const direct of [0,2,5])
for(const directFee of [0,2]){
const p={N,cached,invalidated,K,raw,rawFee,direct,directFee,guards:N};
const x=core.assess(p),y=core.oracle(p);a.equal(x.hybrid.cost,y,JSON.stringify(p));
if(x.hybrid.cost!==null){a.ok(x.direct.cost>=x.hybrid.cost);
if(x.direct.cost>x.hybrid.cost)wins++;else ties++;}
total++;
}
a.ok(total>80000&&wins>0&&ties>0,JSON.stringify({total,wins,ties}));
});
test("The change causes exact invalidation amplification with no overclaim",()=>{
const before=core.preset("tight",false).model,after=core.preset("tight",true).model;
a.equal(before.hybrid.cost,4);a.equal(after.hybrid.cost,12);
a.equal(after.hybrid.cost-before.hybrid.cost,8);
a.equal(after.full.feasible,false);
a.equal(core.preset("ample",true).model.paired.cost,6);
a.equal(core.preset("privacy",true).model.direct.cost,15);
a.equal(core.preset("parity",true).deltaFromDirect,0);
});
test("Any insufficient guard or impact-overflow scenario fails closed",()=>{
const x=core.assess({...core.presets.tight,guards:5});
a.equal(x.hybrid.feasible,false);
a.throws(()=>core.assess({...core.presets.tight,invalidated:8}),RangeError);
});
test("Empirical mixed results retain exact author-fixture scope",()=>{
a.deepEqual(evidence.observed.rows,core.empirical.map(x=>[x.name,x.harmful,x.legitimate,x.microseconds]));
a.equal(evidence.observed.rows[1][1],1);
a.equal(evidence.observed.rows[2][1],0);
a.match(evidence.observed.context,/investigator-authored/);
});
