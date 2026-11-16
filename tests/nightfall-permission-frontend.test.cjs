"use strict";
const {test}=require("node:test");
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const core=require("../docs/permission-lab-core.js");
const sample={N:3,initialCache:1,invalidated:1,workers:2,slotsPerWorker:2,spentSlots:0,guards:3,
 rawBaseCost:1,rawDisclosure:0,directBaseCost:5,directDisclosure:0,verifierFee:4,
 guardFee:1,effectFee:1,sunkCost:0};
test("Certified no-disclosure finite checkpoint witness",()=>{
 const x=core.price(sample);
 assert.equal(x.R,3);assert.equal(x.K,4);assert.equal(x.paired,1);assert.equal(x.direct,2);
 assert.equal(x.evidence,12);assert.equal(x.total,26);
});
test("Large disclosure price switches to predicate-only",()=>{
 const x=core.price({...sample,rawDisclosure:7,directDisclosure:0});
 assert.equal(x.direct,3);assert.equal(x.paired,0);assert.equal(x.evidence,15);
});
test("Infeasibility and invalid input fail closed",()=>{
 assert.equal(core.price({...sample,spentSlots:2}).feasible,false);
 assert.equal(core.price({...sample,guards:2}).feasible,false);
 assert.throws(()=>core.price({...sample,initialCache:4}),RangeError);
 assert.throws(()=>core.price({...sample,invalidated:2}),RangeError);
 assert.throws(()=>core.price({...sample,spentSlots:99}),RangeError);
 assert.throws(()=>core.price({...sample,N:-1}),RangeError);
});
test("All pair/direct plan counts match independent brute-force reference",()=>{
 let cases=0;
 for(let N=0;N<=6;N++)for(let cache=0;cache<=N;cache++)for(let invalidated=0;invalidated<=cache;invalidated++)
 for(let m=0;m<=3;m++)for(let H=0;H<=4;H++)for(let spent=0;spent<=m*H;spent++)
 for(let raw=0;raw<=4;raw++)for(let direct=0;direct<=5;direct++){
  const p={...sample,N,initialCache:cache,invalidated,workers:m,slotsPerWorker:H,
    spentSlots:spent,guards:N,rawBaseCost:raw,rawDisclosure:0,directBaseCost:direct,directDisclosure:0,
    verifierFee:0,guardFee:0,effectFee:0,sunkCost:0};
  const R=N-cache+invalidated,K=m*H-spent;
  let brute=Infinity;
  for(let pair=0;pair<=R;pair++){let deep=R-pair;if(2*pair+deep<=K)
    brute=Math.min(brute,pair*2*raw+deep*direct);}
  const observed=core.price(p);
  assert.equal(observed.feasible,Number.isFinite(brute));
  if(observed.feasible)assert.equal(observed.evidence,brute);
  cases++;
 }
 assert.ok(cases>100000);
});
test("Correlated world expansion invalidates right-only certificate",()=>{
 const before=core.leastDisclosure(false,{left:true,right:true,direct:true},{left:4,right:4,direct:9});
 const after=core.leastDisclosure(true,{left:true,right:true,direct:true},{left:4,right:4,direct:9});
 assert.equal(before.validRightOnly,true);assert.equal(before.best.cost,4);
 assert.equal(after.validRightOnly,false);assert.deepEqual(after.rightOnlyIndistinguishable,["10"]);
 assert.equal(after.best.cost,8);assert.deepEqual(after.best.channels,["left","right"]);
});
test("No available complete evidence must not authorize",()=>{
 const x=core.leastDisclosure(true,{left:false,right:true,direct:false},{left:4,right:4,direct:9});
 assert.equal(x.best,null);
 assert.match(x.status,/NO AVAILABLE/);
});
test("Every chosen finite certificate distinguishes all unsafe current worlds",()=>{
 for(const changed of [false,true])for(let mask=0;mask<8;mask++){
  const enabled={left:Boolean(mask&1),right:Boolean(mask&2),direct:Boolean(mask&4)};
  const x=core.leastDisclosure(changed,enabled,{left:4,right:4,direct:9});
  if(x.best)assert.equal(core.checkCertificate(core.worlds(changed)[0],core.worlds(changed),x.best.channels).valid,true);
 }
});
test("Page and JavaScript wiring are present, dependencies locally resolvable",()=>{
 const base=path.resolve(__dirname,"../docs");
 const html=fs.readFileSync(path.join(base,"permission-lab.html"),"utf8");
 for(const f of ["permission-lab-core.js","permission-lab.js","permission-lab.css"]) {
   assert.match(html,new RegExp(f.replaceAll(".","\\.")));
   assert.ok(fs.existsSync(path.join(base,f)));
 }
 for(const id of ["pl-cost-form","pl-world-form","pl-changed","pl-cost-result","pl-proof-result"])
   assert.ok(html.includes('id="'+id+'"'));
 for(const file of ["index.html","research.html","active-proof-passport.html",
 "cost-of-knowing.html","review.html","commonwealth-os.html","commonwealth.html",
 "constellation.html","atlas.html"])
  assert.ok(fs.readFileSync(path.join(base,file),"utf8").includes("permission-lab.html"),file);
});
