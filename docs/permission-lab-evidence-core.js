"use strict";
/* Reproducible finite model; no real tool/agent enforcement. */
(function(root,make){const v=make();if(typeof module==="object"&&module.exports)module.exports=v;if(root)root.NFPermissionEvidence=v;})(typeof globalThis==="undefined"?this:globalThis,function(){
function nat(x,k){if(!Number.isSafeInteger(x)||x<0)throw new RangeError("Invalid "+k);return x;}
const presets=Object.freeze({
 tight:{title:"Revocation under deadline",N:6,cached:4,invalidated:1,K:4,raw:1,rawFee:0,direct:5,directFee:0,guards:6,summary:"One cached deployment approval is revoked; four verification slots remain."},
 ample:{title:"Ample capacity and a strong comparator",N:6,cached:4,invalidated:1,K:7,raw:1,rawFee:0,direct:5,directFee:0,guards:6,summary:"Seven slots remain. An impact-aware paired strategy can match NIGHTFALL."},
 privacy:{title:"Private predicate versus raw evidence",N:6,cached:4,invalidated:1,K:7,raw:1,rawFee:4,direct:5,directFee:0,guards:6,summary:"An abstract disclosure charge makes predicate-only verification preferable."},
 parity:{title:"No advantage when costs tie",N:6,cached:4,invalidated:1,K:7,raw:1,rawFee:0,direct:2,directFee:0,guards:6,summary:"A direct predicate check costs the same as two raw checks."}
});
const labels={full:"Full refresh · direct checks",direct:"Impact-aware · direct checks",paired:"Impact-aware · paired reads",hybrid:"NIGHTFALL · exact mixed policy"};
function assess(params){
const p={...params};for(const k of ["N","cached","invalidated","K","raw","rawFee","direct","directFee","guards"])nat(p[k],k);
if(p.cached>p.N||p.invalidated>p.cached)throw new RangeError("Bad cache/invalidation scope");
const R=p.N-p.cached+p.invalidated,cp=p.raw+p.rawFee,dp=p.direct+p.directFee,pairCost=2*cp,guardOk=p.guards>=p.N;
if(![cp,dp,pairCost].every(Number.isSafeInteger))throw new RangeError("Cost overflow");
function item(id,ops,cost,paired,direct){const feasible=guardOk&&ops<=p.K;
return {id,label:labels[id],feasible,cost:feasible?cost:null,slots:ops,paired,direct,
 reason:!guardOk?"Effect-guard shortage":ops>p.K?"Exceeds remaining slots":null};}
const full=item("full",p.N,dp*p.N,0,p.N);
const direct=item("direct",R,dp*R,0,R);
const paired=item("paired",2*R,pairCost*R,R,0);
const deep=dp<pairCost?R:Math.min(R,Math.max(0,2*R-p.K));
const hybrid=item("hybrid",2*R-deep,pairCost*(R-deep)+dp*deep,R-deep,deep);
if([full,direct,paired,hybrid].some(a=>a.cost!==null&&!Number.isSafeInteger(a.cost)))throw new RangeError("Cost overflow");
return {N:p.N,R,K:p.K,cp,dp,pairCost,full,direct,paired,hybrid,strategies:[full,direct,paired,hybrid]};
}
/* Independent finite dynamic-programming oracle: choose one or two slots at each task. */
function oracle(p){
for(const k of ["N","cached","invalidated","K","raw","rawFee","direct","directFee","guards"])nat(p[k],k);
if(p.cached>p.N||p.invalidated>p.cached)throw new RangeError("Bad counts");
if(p.guards<p.N)return null;
let states=new Map([[0,0]]);
for(let i=0;i<p.N-p.cached+p.invalidated;i++){
const next=new Map();
for(const [used,cost] of states)for(const [slots,charge] of [[1,p.direct+p.directFee],[2,2*(p.raw+p.rawFee)]]){
if(used+slots>p.K)continue;
const v=cost+charge,k=used+slots;
if(!next.has(k)||v<next.get(k))next.set(k,v);
}
states=next;
}
return states.size?Math.min(...states.values()):null;
}
function preset(name,changed){if(!Object.hasOwn(presets,name))throw new RangeError("Unknown scenario");
const p={...presets[name],invalidated:changed?presets[name].invalidated:0};
const model=assess(p),reference=oracle(p);
if(model.hybrid.cost!==reference)throw new Error("Analytic schedule differs from independent oracle");
return {name,changed,description:presets[name].summary,model,reference,
 deltaFromDirect:model.hybrid.feasible&&model.direct.feasible?model.direct.cost-model.hybrid.cost:null};
}
const empirical=Object.freeze([
{id:"narrow",name:"Narrow FSx guard",harmful:4,legitimate:2,microseconds:89.50},
{id:"selective",name:"Source-path selective audit",harmful:1,legitimate:2,microseconds:473.73},
{id:"full",name:"Full mission audit",harmful:0,legitimate:2,microseconds:643.48},
{id:"broad",name:"All-SCP baseline pin",harmful:0,legitimate:2,microseconds:1623.83}
]);
return Object.freeze({presets,assess,oracle,preset,empirical});
});
