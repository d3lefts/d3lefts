#!/usr/bin/env node
"use strict";
/* RYEV / Scope Faultline v1 — proof-dependency versus analogy contradiction detector.
   Audit original frozen Observatory identities without rewriting history. */
const assert=require("node:assert/strict"),fs=require("node:fs"),path=require("node:path");
const original=require("../observatory/gate-c-ryev/frozen-vesper/claims-v1.json");
const TYPES=new Set(["proven-implication","certified-computational-dependency","shared-mathematical-mechanism","proposed-transfer","falsified-transfer"]);
function audit(graph){
 assert.ok(graph&&Array.isArray(graph.nodes)&&Array.isArray(graph.edges),"Invalid frozen graph");
 const nodes=new Map(graph.nodes.map(n=>[n.id,n]));
 assert.equal(nodes.size,graph.nodes.length,"Duplicate claim identity");
 const edges=new Map(graph.edges.map(e=>[e.id,e]));
 assert.equal(edges.size,graph.edges.length,"Duplicate edge identity");
 const faults=[];
 for(const n of nodes.values()){
  const seen=new Set();
  for(const d of n.dependencies||[]){
   if(seen.has(d))faults.push({kind:"duplicate-dependency",subject:n.id,against:d,message:"Claim lists the same proof prerequisite twice."});
   seen.add(d);
   if(!nodes.has(d))faults.push({kind:"dangling-dependency",subject:n.id,against:d,message:"Proof dependency references an unknown claim identity."});
   if(d===n.id)faults.push({kind:"self-dependency",subject:n.id,against:d,message:"A claim cannot be its own prerequisite."});
  }
 }
 for(const e of edges.values()){
  assert.ok(TYPES.has(e.type),"Unknown relation type "+e.type);
  if(!nodes.has(e.from)||!nodes.has(e.to))faults.push({kind:"dangling-relation",subject:e.id,against:e.to,message:"Typed relation references absent claim identity."});
  if(e.from===e.to)faults.push({kind:"self-relation",subject:e.id,against:e.to,message:"A research transfer must identify distinct source and target identities."});
  const a=nodes.get(e.from),b=nodes.get(e.to);
  if(!a||!b)continue;
  // If e is an analogy/proposal, it is logically incompatible with an
  // independently asserted prerequisite in either direction absent a reviewed scope proof.
  if(["shared-mathematical-mechanism","proposed-transfer","falsified-transfer"].includes(e.type)){
   const dependents=[];
   if((a.dependencies||[]).includes(b.id))dependents.push(a.id);
   if((b.dependencies||[]).includes(a.id))dependents.push(b.id);
   if(dependents.length)faults.push({
    kind:"relation-dependency-conflict",subject:e.id,from:a.id,to:b.id,relation:e.type,dependents,
    message:"The typed relation is "+e.type+" yet a node simultaneously declares a direct proof dependency. Preserve original frozen evidence; require an independently reviewed new claim identity before using this link as a proof premise."
   });
  }
 }
 const ancestry=new Map();
 for(const id of nodes.keys())ancestry.set(id,[]);
 for(const n of nodes.values())for(const d of n.dependencies||[])if(nodes.has(d))ancestry.get(n.id).push(d);
 const visited=new Map(),stack=[];
 const dfs=id=>{
  if(visited.get(id)===1){const cycle=stack.slice(stack.indexOf(id)).concat(id);faults.push({kind:"cycle",subject:id,cycle,message:"Cyclic direct proof dependencies lack an acyclic foundation."});return}
  if(visited.get(id)===2)return;
  visited.set(id,1);stack.push(id);for(const d of ancestry.get(id))dfs(d);stack.pop();visited.set(id,2);
 };
 for(const id of nodes.keys())dfs(id);
 return {format:"nightfall-scope-faultline-v1",claimCount:nodes.size,edgeCount:edges.size,
  faultCount:faults.length,faults,
  evidenceTier:"STATIC_GRAPH_INTEGRITY_ONLY",
  action:"Quarantine contradictory typed edges and their purported proof dependencies from decision benchmarks. Never silently revise immutable historical claim identities."
 };
}
function test(){
 const r=audit(original);
 const failures=r.faults.filter(x=>x.kind==="relation-dependency-conflict");
 assert.ok(failures.some(x=>x.subject==="TR-007"),"Frozen TR-007 discrepancy must remain detectable");
 const e=original.edges.find(e=>e.id==="TR-007");
 assert.equal(e.type,"shared-mathematical-mechanism");
 assert.ok(original.nodes.find(n=>n.id==="NF-AXIOM-KERNEL-v1").dependencies.includes("NF-FIELD-SPAN-v1"));
 const repaired=structuredClone(original);
 repaired.nodes.find(n=>n.id==="NF-AXIOM-KERNEL-v1").dependencies=
 repaired.nodes.find(n=>n.id==="NF-AXIOM-KERNEL-v1").dependencies.filter(x=>x!=="NF-FIELD-SPAN-v1");
 const after=audit(repaired);
 assert.equal(after.faults.filter(x=>x.subject==="TR-007").length,0,"Reviewed new identity would resolve this conflict");
 const tampered=structuredClone(repaired);
 tampered.nodes.find(n=>n.id==="NF-AXIOM-KERNEL-v1").dependencies.push("NONEXISTENT");
 assert.ok(audit(tampered).faults.some(x=>x.kind==="dangling-dependency"));
 const cyclic=structuredClone(repaired);
 cyclic.nodes.find(n=>n.id==="NF-FIELD-SPAN-v1").dependencies.push("NF-AXIOM-KERNEL-v1");
 cyclic.nodes.find(n=>n.id==="NF-AXIOM-KERNEL-v1").dependencies.push("NF-FIELD-SPAN-v1");
 assert.ok(audit(cyclic).faults.some(x=>x.kind==="cycle"));
 console.log("PASS Scope Faultline: real historical TR-007 mismatch detected; reviewed-identity hypothetical removes mismatch; dangling and cyclic negative controls detected.");
 return r;
}
const mode=process.argv[2]||"--selftest";
if(mode==="--selftest")test();
else if(mode==="--json"){
 const r=test();console.log(JSON.stringify(r,null,2));
}else{
 console.error("Usage: node scope_faultline.cjs --selftest|--json");process.exitCode=2;
}
