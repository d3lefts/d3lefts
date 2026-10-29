"use strict";
/* Separate brute-force test path: enumerate all binary masks, not anchored
   combinations, then directly count cyclic shifts. */
const assert=require("node:assert/strict");
const C=require("../docs/discovery-loop-core.js");
function independent(n,m){
 let best=Infinity,total=0,example=null;
 for(let mask=0;mask<(1<<n);mask++){
  let weight=0;for(let x=mask;x;x&=x-1)weight++;
  if(weight!==m)continue;
  total++;
  const bits=Array.from({length:n},(_,i)=>(mask>>i)&1);
  let max=0;
  for(let shift=1;shift<n;shift++){
   let count=0;
   for(let i=0;i<n;i++)count+=bits[i]*bits[(i+shift)%n];
   if(count>max)max=count;
  }
  if(max<best){best=max;example=bits;}
 }
 return {best,total,example};
}
assert.equal(C.SCHEMA,"nightfall-discovery-loop-v1");
assert.equal(C.TARGETS.length,36);
assert.equal(C.choose(15,5),3003);
assert.deepEqual(C.next(C.empty()).target,{n:15,mass:6});
let s=C.advance(C.empty());
assert.equal(s.records.length,1);
assert.deepEqual(s.records[0].target,{n:15,mass:6});
assert.equal(s.records[0].result.lower_bound,3);
assert.equal(s.records[0].result.exact_minimax,3);
assert.equal(s.records[0].surprise,false);
assert.deepEqual(C.next(s).target,{n:16,mass:6});
s=C.advance(s);
assert.equal(s.records[1].result.lower_bound,2);
assert.equal(s.records[1].result.exact_minimax,3);
assert.equal(s.records[1].result.gap,1);
assert.equal(s.records[1].surprise,true);
assert.equal(s.records[1].verdict,"LOCAL_PREDICTION_FALSIFIED");
assert.ok(s.residues.some(r=>r.target.n===16&&r.target.mass===6&&r.kind==="PREDICTION_FALSIFIED"));
assert.equal(C.replay(s).status,"LOCALLY_REPLAYED");
for(const [n,m] of [[8,3],[9,5],[13,4],[15,6],[16,6]]){
 const a=C.enumerate(n,m),b=independent(n,m);
 assert.equal(a.exact_minimax,b.best,n+":"+m+" unanchored independent minimax");
 assert.equal(b.total,C.choose(n,m),n+":"+m+" all binary subsets");
 assert.equal(a.anchored_subsets,C.choose(n-1,m-1),n+":"+m+" anchor count");
 assert.equal(a.witness_shift_counts.reduce((x,y)=>x+y,0),m*(m-1));
 assert.deepEqual(C.histogram(n,a.one_optimal_set),C.directHistogram(n,a.one_optimal_set));
}
const fixedBaseline=[C.enumerate(15,6),C.enumerate(14,6)];
assert.ok(fixedBaseline.every(r=>r.gap===0),"Illustrative static two-case schedule misses the n16 strict gap");
assert.equal(s.records[1].result.gap,1,"Adaptive adjacent-case schedule detects the strict gap on its second case");
for(const mutate of [
 t=>t.records[1].result.exact_minimax=2,
 t=>t.records[1].surprise=false,
 t=>t.records[0].target.mass=5,
 t=>t.residues.splice(0,1),
 t=>t.records.push(JSON.parse(JSON.stringify(t.records[0])))
]){
 const poisoned=structuredClone(s);mutate(poisoned);
 let rejected=false;try{rejected=C.replay(poisoned).status!=="LOCALLY_REPLAYED"}catch{rejected=true}
 assert.equal(rejected,true,"Tainted pilot packet must not replay");
}
// Human approval is a real input to experiment selection, not a decorative UI.
let reviewed=C.empty();
assert.deepEqual(C.candidates(reviewed,4).map(v=>v.target),[{n:15,mass:6}]);
assert.throws(()=>C.advance(reviewed,{target:{n:15,mass:6},note:""}),/explicit approval/);
reviewed=C.advance(reviewed,{action:"APPROVE_ONE",target:{n:15,mass:6},note:""});
assert.equal(reviewed.records[0].decision.source,"RECOMMENDED");
assert.equal(reviewed.records[0].decision.rank_at_approval,1);
assert.equal(C.replay(reviewed).status,"LOCALLY_REPLAYED");
const ranked=C.candidates(reviewed,4);
assert.deepEqual(ranked[0].target,{n:16,mass:6});
assert.ok(ranked.some(v=>v.target.n===14&&v.target.mass===6));
assert.throws(()=>C.advance(reviewed,{action:"APPROVE_ONE",target:{n:14,mass:6},note:""}),/requires an explanatory note/);
reviewed=C.advance(reviewed,{action:"APPROVE_ONE",target:{n:14,mass:6},note:"Check whether sharpness persists on the smaller neighboring cycle."});
assert.equal(reviewed.records[1].decision.source,"HUMAN_REDIRECTION");
assert.equal(C.metrics(reviewed).user_redirected_steps,1);
assert.equal(C.metrics(reviewed).user_approved_steps,2);
assert.equal(C.replay(reviewed).status,"LOCALLY_REPLAYED");
assert.equal(C.metrics(reviewed).anchored_subsets_checked,
 C.choose(14,5)+C.choose(13,5));
for(const corrupt of [
 t=>t.records[1].decision.note="",
 t=>t.records[1].decision.rank_at_approval=1,
 t=>t.records[1].decision.target.n=16,
 t=>t.records[1].decision.source="RECOMMENDED",
 t=>t.independent_audit=true,
 t=>t.peer_review=true,
 t=>t.original_finding=true,
 t=>t.step_budget=100000
]){
 const poisoned=structuredClone(reviewed);corrupt(poisoned);
 let rejected=false;try{rejected=C.replay(poisoned).status!=="LOCALLY_REPLAYED"}catch{rejected=true}
 assert.equal(rejected,true,"Human-decision or trust-status tampering rejected");
}
assert.throws(()=>C.advance(reviewed,{action:"APPROVE_ONE",target:{n:14,mass:6},note:"Repeated approved target"}),/already used/);
assert.throws(()=>C.candidates(reviewed,100),/limit/);
while(C.next(reviewed)){
 const target=C.next(reviewed).target;
 reviewed=C.advance(reviewed,{action:"APPROVE_ONE",target,note:""});
}
assert.equal(reviewed.records.length,C.MAX_STEPS);
assert.equal(C.replay(reviewed).status,"LOCALLY_REPLAYED");
assert.equal(C.metrics(reviewed).user_approved_steps,C.MAX_STEPS);
assert.throws(()=>C.enumerate(17,6),/Pilot scope/);
assert.throws(()=>C.enumerate(16,7),/Pilot scope/);
for(let i=2;i<C.MAX_STEPS;i++)s=C.advance(s);
assert.equal(s.records.length,C.MAX_STEPS);
assert.equal(C.next(s),null);
assert.equal(C.replay(s).status,"LOCALLY_REPLAYED");
assert.throws(()=>C.advance(s),/stop rule/);
console.log("PASS: bounded deterministic discovery loop, adjacent prediction falsification, independent all-mask arithmetic, poisoning tests, and stop rule");