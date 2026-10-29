"use strict";
/* Read-only, source-bounded impact preflight for the canonical claim registry.
   Reports DIRECT evidence and adjacency changes; never grants proof status,
   infers transitive theorems, or certifies mathematical validity. */
const assert=require("node:assert/strict");
const fs=require("node:fs");
const vm=require("node:vm");
const crypto=require("node:crypto");
const cp=require("node:child_process");
const path=require("node:path");

const fields=["statement","conditions","assumptions","open","sources",
  "validity","reproducibility","originality","significance","history"];
const relations=new Set(["finite-check","method","analogy","open-premise"]);
const dimensions=["validity","reproducibility","originality","significance"];
const hash=s=>crypto.createHash("sha256").update(s).digest("hex");

function load(js){
  const context=Object.create(null);
  vm.runInNewContext(js,context,{timeout:1200,filename:"research-registry.js"});
  return JSON.parse(JSON.stringify(context.NightfallRegistry));
}
function validate(reg){
  assert.equal(reg?.schema,"nightfall-proof-passports-v1");
  for(const kind of ["claims","mechanisms","edges"])assert.ok(Array.isArray(reg[kind]),kind);
  const claims=new Map(),mechanisms=new Map();
  for(const c of reg.claims){
    assert.ok(typeof c.id==="string"&&c.id.length>0,"nonempty claim id");
    assert.ok(!claims.has(c.id),"duplicate claim "+c.id);
    assert.ok(Array.isArray(c.sources)&&c.sources.length>0,"missing sources "+c.id);
    for(const s of c.sources)assert.ok(typeof s.url==="string"&&s.url.length>0,"missing source URL "+c.id);
    for(const d of dimensions){
      assert.ok(c[d]&&typeof c[d].level==="string"&&c[d].level.length,"unscoped status "+c.id+"."+d);
    }
    claims.set(c.id,c);
  }
  for(const m of reg.mechanisms){
    assert.ok(typeof m.id==="string"&&m.id,"mechanism id");
    assert.ok(!mechanisms.has(m.id),"duplicate mechanism "+m.id);
    assert.ok(Array.isArray(m.witnesses),"mechanism witnesses "+m.id);
    for(const id of m.witnesses)assert.ok(claims.has(id),"unknown mechanism witness "+id);
    mechanisms.set(m.id,m);
  }
  const seen=new Set();
  for(const e of reg.edges){
    assert.ok(claims.has(e.from),"unknown claim edge "+e.from);
    assert.ok(mechanisms.has(e.to),"unknown mechanism edge "+e.to);
    assert.ok(relations.has(e.relation),"unknown relation type "+e.relation);
    assert.ok(typeof e.note==="string"&&e.note.trim(),"unqualified edge "+e.from);
    assert.ok(typeof e.source==="string"&&e.source.trim(),"unsourced edge "+e.from);
    const id=[e.from,e.to,e.relation].join("|");
    assert.ok(!seen.has(id),"duplicate typed edge "+id);
    seen.add(id);
  }
  return {claims,mechanisms};
}
function sourcePath(url){
  if(typeof url!=="string")return null;
  if(/^[a-z][a-z0-9+.-]*:/i.test(url)){
    let u;try{u=new URL(url)}catch{return null}
    if(u.hostname!=="github.com"||!u.pathname.startsWith("/d3lefts/d3lefts/blob/main/"))return null;
    return decodeURIComponent(u.pathname.slice("/d3lefts/d3lefts/blob/main/".length));
  }
  if(url.startsWith("../")||url.startsWith("/")||url.startsWith("#"))return null;
  return "docs/"+url.split(/[?#]/)[0];
}
function edgeKey(e){return [e.from,e.to,e.relation].join("|")}
function changedFields(a,b,keys){
  return keys.filter(k=>JSON.stringify(a?.[k])!==JSON.stringify(b?.[k]));
}
function assess(previous,current,changedPaths=[]){
  const before=validate(previous),after=validate(current);
  const files=new Set(changedPaths);
  const reasons=new Map();
  const flag=(id,reason)=>{
    if(!reasons.has(id))reasons.set(id,new Set());
    reasons.get(id).add(reason);
  };
  const claimChanges=[],edgeChanges=[],mechanismChanges=[];
  const allClaims=new Set([...before.claims.keys(),...after.claims.keys()]);
  for(const id of [...allClaims].sort()){
    const a=before.claims.get(id),b=after.claims.get(id);
    const changes=a&&b?changedFields(a,b,fields):["record"];
    if(changes.length){claimChanges.push({id,fields:changes});flag(id,"canonical claim changed");}
    if(b){
      for(const s of b.sources||[]){
        const p=sourcePath(s.url);
        if(p&&files.has(p))flag(id,"cited source changed: "+p);
      }
    }
  }
  const bm=before.mechanisms,cm=after.mechanisms;
  for(const id of [...new Set([...bm.keys(),...cm.keys()])].sort()){
    const a=bm.get(id),b=cm.get(id);
    if(JSON.stringify(a)!==JSON.stringify(b)){
      mechanismChanges.push(id);
      for(const claimId of new Set([...(a?.witnesses||[]),...(b?.witnesses||[])])){
        flag(claimId,"connected mechanism record changed: "+id);
      }
    }
  }
  const be=new Map(previous.edges.map(e=>[edgeKey(e),e]));
  const ce=new Map(current.edges.map(e=>[edgeKey(e),e]));
  for(const key of [...new Set([...be.keys(),...ce.keys()])].sort()){
    const a=be.get(key),b=ce.get(key);
    if(JSON.stringify(a)!==JSON.stringify(b)){
      edgeChanges.push(key);
      flag((b||a).from,"direct typed edge changed: "+key);
    }
    if(b){
      const p=sourcePath(b.source);
      if(p&&files.has(p))flag(b.from,"typed-edge source changed: "+p);
    }
  }
  const statusChanges=claimChanges.filter(x=>x.fields.some(f=>dimensions.includes(f)))
    .map(x=>({id:x.id,dimensions:x.fields.filter(f=>dimensions.includes(f)),
      humanReviewRequired:true}));
  return {
    baselineClaims:previous.claims.length,currentClaims:current.claims.length,
    changedSourcePaths:[...files].sort(),
    changedClaims:claimChanges,changedMechanisms:mechanismChanges,
    changedTypedEdges:edgeChanges,statusChanges,
    directlyAffectedClaims:[...reasons].sort(([a],[b])=>a.localeCompare(b))
      .map(([id,rs])=>({id,reasons:[...rs].sort()})),
    limits:"Direct registry relationships and exact file citations only. No inferred proof dependency, global novelty, automatic status promotion, or transitive impact certificate."
  };
}
function main(){
  const file="docs/research-registry.js";
  const currentText=fs.readFileSync(file,"utf8");
  const current=load(currentText);
  validate(current);
  const base=process.env.CLAIM_IMPACT_BASE_SHA||"";
  if(!base||/^0+$/.test(base)){
    console.log("PASS claim graph integrity; no accessible comparison baseline");
    return;
  }
  assert.match(base,/^[0-9a-f]{40}$/i,"baseline must be a git commit SHA");
  const oldText=cp.execFileSync("git",["show",base+":"+file],{encoding:"utf8"});
  const paths=cp.execFileSync("git",["diff","--name-only",base,"HEAD"],
    {encoding:"utf8"}).trim().split("\n").filter(Boolean);
  const report=assess(load(oldText),current,paths);
  console.log(JSON.stringify({base,baseSha256:hash(oldText),
    currentSha256:hash(currentText),...report},null,2));
  console.log("PASS source-scoped claim impact preflight; review flags are advisory");
}
if(require.main===module)main();
module.exports={load,validate,assess,sourcePath};
