#!/usr/bin/env node
"use strict";
/* RYEV / Gate C parity runner. Frozen original Vesper task set. No model execution is implied. */
const fs=require("node:fs"),path=require("node:path"),cp=require("node:child_process"),crypto=require("node:crypto"),assert=require("node:assert/strict");
const root=__dirname+"/frozen-vesper",tasks=require(root+"/GATE_C_TASK_SET_v1.json"),locks=require(root+"/SOURCE_BLOB_LOCK_v1.json"),graph=require(root+"/claims-v1.json");
const sha=x=>crypto.createHash("sha256").update(x).digest("hex");
const randomSeed=1729,tokenCap=2000,toolCap=20;
const Meter=require("./metering_core.cjs");
// A secret per-study key masks condition IDs. Public seed alone cannot blind an evaluator.
const key=process.env.GATE_C_BLIND_KEY||"PREVIEW_ONLY_PUBLIC_NONSECRET_ID";
const secured=typeof process.env.GATE_C_BLIND_KEY==="string"&&/^[a-f0-9]{64}$/i.test(process.env.GATE_C_BLIND_KEY);
function needSecret(){assert.ok(secured,"LIVE TRIALS REQUIRE a secret 64-hex GATE_C_BLIND_KEY, saved outside GitHub/graded exports.");}
const knownEdgeIds={
 "FF-01":["TR-007"],"FF-02":["TR-007"],"WR-01":["TR-005","TR-008"],
 "WR-02":["TR-005","TR-008"],"SP-01":["TR-004","TR-005"],"SP-02":["TR-004"]
};
const knownConflict="TR-007"; // conflicting dependency-vs-analogy in frozen graph, common explicit quarantine.
const stop=new Set("the a an in on for by and or to from of with that this what which how when before after whether into under one its over need give test source exact finite most could specified identify independent missing first claim proof only".split(" "));
function rng(seed){let x=seed>>>0;return()=>((x=(Math.imul(x,1664525)+1013904223)>>>0)/4294967296)}
function shuffle(xs,random){const a=xs.slice();for(let i=a.length-1;i>0;i--){const j=Math.floor(random()*(i+1));[a[i],a[j]]=[a[j],a[i]]}return a}
function frozen(){
 assert.equal(tasks.schema_version,"Gate-C-Freeze-v1");
 assert.equal(tasks.random_seed,randomSeed);
 assert.equal(tasks.frozen_source_commit,locks.archive_commit);
 assert.equal(tasks.tasks.length,6);
 assert.equal(locks.sources&&Object.keys(locks.sources).length,6);
 assert.equal(tasks.per_condition_budget.model_tokens_input_plus_output,tokenCap);
 assert.equal(tasks.per_condition_budget.external_tool_calls,toolCap);
 return true;
}
function fileFor(file){
 const pin=locks.sources[file];assert.ok(pin,"Unpinned source: "+file);
 const bytes=cp.execFileSync("git",["show",locks.archive_commit+":"+file],{maxBuffer:32*1024*1024});
 const blob=cp.execFileSync("git",["hash-object","--stdin"],{input:bytes,encoding:"utf8"}).trim();
 assert.equal(blob,pin,"Source Git blob mismatch: "+file);
 return {content:bytes.toString("utf8"),sha256:sha(bytes),gitBlob:blob,bytes:bytes.length};
}
function tokenTerms(query){
 return new Set((query.toLowerCase().match(/[a-z][a-z0-9-]{2,}/g)||[]).filter(w=>!stop.has(w)));
}
function retrieval(task,query){
 if(typeof query!=="string"||!query.trim()||query.length>350)throw Error("Invalid bounded retrieval query (1..350 chars).");
 const terms=tokenTerms(query);
 const slices=task.source_paths.map(file=>{
  const s=fileFor(file),lines=s.content.split(/\r?\n/);
  const candidates=lines.map((line,index)=>{
   const trimmed=line.trim(),words=new Set((trimmed.toLowerCase().match(/[a-z][a-z0-9-]{2,}/g)||[]));
   let score=0;for(const t of terms)if(words.has(t))score+=3;
   if(/(pending|condition|scope|reproduce|hypoth|constraint|exact|source|margin|theorem|obstruction|bound|projection|coupling|symmetr|rank|proof)/i.test(trimmed))score+=1;
   if(trimmed.startsWith("#"))score+=1;
   return {line:trimmed,number:index+1,score};
  }).filter(x=>x.line.length>=15&&x.line.length<=340);
  candidates.sort((a,b)=>b.score-a.score||a.number-b.number);
  const chosen=candidates.slice(0,3).sort((a,b)=>a.number-b.number);
  return {file,sourceSha256:s.sha256,sourceBlobSha:s.gitBlob,fullBytes:s.bytes,
    excerpts:chosen.map(z=>({line:z.number,text:z.line,sha256:sha(z.line)}))};
 });
 const total=slices.reduce((n,x)=>n+x.excerpts.reduce((m,z)=>m+z.text.length,0),0);
 assert.ok(total<=2040,"Retrieval result exceeds bounded source text allowance.");
 return {format:"nightfall-gate-c-identical-retrieval-v1",taskId:task.id,query,files:slices,
   textChars:total,sourceScope:"Only these original pinned source files; no graph-only mathematical claims."};
}
function graphView(task){
 const edgeIDs=knownEdgeIds[task.id];assert.ok(edgeIDs,"Unknown task graph allocation");
 const edges=edgeIDs.filter(id=>id!==knownConflict).map(id=>{
  const x=graph.edges.find(z=>z.id===id);assert.ok(x,"Missing original graph edge "+id);
  return {id:x.id,from:x.from,to:x.to,type:x.type};
 });
 const nodeIds=new Set(edges.flatMap(x=>[x.from,x.to]));
 for(const id of edgeIDs){const e=graph.edges.find(z=>z.id===id);assert.ok(e);
  nodeIds.add(e.from);nodeIds.add(e.to);}
 const nodes=[...nodeIds].sort().map(id=>{
  const x=graph.nodes.find(n=>n.id===id);assert.ok(x,"Missing graph node "+id);
  return {id,title:x.title,status:x.status};
 });
 return {nodes,edges,quarantinedEdgeIds:edgeIDs.includes(knownConflict)?[knownConflict]:[]};
}
function pairedJobs(){
 frozen();const random=rng(randomSeed);
 const sorted=shuffle(tasks.tasks,random),arr=[];
 for(const t of sorted){
  const view=graphView(t),baseline=retrieval(t,t.prompt);
  for(const arm of shuffle(["G","F"],random)){
   const id=crypto.createHmac("sha256",key).update("gate-c-original-v1:"+t.id+":"+arm+":"+randomSeed).digest("hex").slice(0,20);
   arr.push({blindId:"B-"+id,taskId:t.id,arm,sourceCommit:locks.archive_commit,
    prompt:t.prompt,baselineRetrieval:baseline,
    commonNodeFacts:view.nodes,graphEdges:arm==="G"?view.edges:[],
    quarantinedEdgeIds:view.quarantinedEdgeIds,sourceFamilies:t.source_paths,
    inputSha256:sha(JSON.stringify({taskId:t.id,prompt:t.prompt,baseline,commonNodeFacts:view.nodes,graphEdges:arm==="G"?view.edges:[],quarantinedEdgeIds:view.quarantinedEdgeIds})),
    maxTotalTokens:tokenCap,maxToolCalls:toolCap,modelConfig:"RECORD_AT_EXECUTION_NO_MODEL_STARTED"});
  }
 }
 assert.equal(arr.length,12);
 for(const t of tasks.tasks){
  const p=arr.filter(x=>x.taskId===t.id);assert.equal(p.length,2);
  assert.deepEqual(p[0].baselineRetrieval,p[1].baselineRetrieval);
  assert.deepEqual(p[0].commonNodeFacts,p[1].commonNodeFacts);
  assert.deepEqual(p[0].sourceFamilies,p[1].sourceFamilies);
  assert.deepEqual(p[0].quarantinedEdgeIds,p[1].quarantinedEdgeIds);
  assert.ok(p.some(x=>x.arm==="G")&&p.some(x=>x.arm==="F"));
 }
 return arr;
}
function write(p,v){fs.writeFileSync(p,JSON.stringify(v,null,2)+"\n")}
function freeze(out){
 fs.mkdirSync(out,{recursive:true});
 const jobs=pairedJobs(),sourceRows={};
 for(const p of Object.keys(locks.sources))sourceRows[p]=((x)=>({blob:x.gitBlob,sha256:x.sha256,bytes:x.bytes}))(fileFor(p));
 const meta={format:"nightfall-gate-c-original-v1-parity-freeze",trialStatus:"UNRUN",taskCommit:locks.archive_commit,
  graphRevision:locks.observatory_draft_commit,sourceRows,
  originalTaskSha256:sha(fs.readFileSync(root+"/GATE_C_TASK_SET_v1.json")),
  originalLockSha256:sha(fs.readFileSync(root+"/SOURCE_BLOB_LOCK_v1.json")),
  graphSha256:sha(fs.readFileSync(root+"/claims-v1.json")),
  seed:1729,arms:12,taskCount:6,blinding:secured?"SECRET_HMAC_OPERATOR_ONLY":"PUBLIC_DEVELOPMENT_FIXTURE_NOT_ELIGIBLE_FOR_LIVE_TRIALS",
  privateJobCommitmentSha256:sha(JSON.stringify(jobs)),keyCommitmentSha256:secured?sha(key):null,
  budget:{tokens:tokenCap,tools:toolCap,wallClockMinutes:30},
  matching:{sameSourceBytes:true,sameRetrievalIndex:true,samePrompt:true,sameNodeFacts:true,typedRelationshipsOnlyInGraph:true},
  caveat:"No model trial or blind adjudicator exists in this freeze."};
 write(path.join(out,"freeze.json"),meta);
 write(path.join(out,"operator-jobs.json"),jobs);
 write(path.join(out,"review-forms.json"),shuffle(jobs.map(x=>({blindId:x.blindId,taskId:x.taskId,answer:null,
    primaryScore:null,falsePromotion:null,adjudicatorEvidence:null})),rng(1729+51)));
 console.log("PASS Gate C original Vesper v1: six pairs, twelve unrun jobs, identical source text, matching node facts, edge-only graph delta.");
}
function cliRetrieve(taskId,query){
 const t=tasks.tasks.find(x=>x.id===taskId);assert.ok(t,"Unknown task");
 console.log(JSON.stringify(retrieval(t,query),null,2));
}
function validateOutputs(out){
 needSecret();
 const jobs=pairedJobs(),raw=JSON.parse(fs.readFileSync(path.join(out,"raw-outputs.json")));
 assert.ok(Array.isArray(raw)&&raw.length===12,"Exactly 12 actual model responses required");
 const map=new Map(raw.map(r=>[r.blindId,r]));assert.equal(map.size,12,"Duplicate blind IDs");
 let modelConfig=null;
 for(const j of jobs){
  const r=map.get(j.blindId);assert.ok(r,"Missing response "+j.blindId);
  Meter.verify(j,r); // Demand raw provider token counts and exact sent source/graph payload.
  assert.equal(r.inputSha256,j.inputSha256,"Frozen input mismatch for "+j.blindId);
  assert.equal(r.taskId,j.taskId,"Wrong task metadata");
  assert.ok(typeof r.answer==="string"&&r.answer.trim().length>=30,"Missing model answer");
  assert.ok(Array.isArray(r.usageEvents)&&r.usageEvents.length>0,"Actual usage event log required");
  assert.ok(Array.isArray(r.retrievalEvents),"Explicit retrieval log required");
  assert.ok(typeof r.model==="string"&&r.model.length>3,"Exact model name required");
  assert.ok(typeof r.modelConfig==="string"&&r.modelConfig.length>5,"Model config absent");
  const cur=r.model+"|"+r.modelConfig;
  if(modelConfig===null)modelConfig=cur;else assert.equal(cur,modelConfig,"Different model/config between arms");
  const totals=r.usageEvents.reduce((n,u)=>{assert.ok(Number.isSafeInteger(u.inputTokens)&&u.inputTokens>=0);assert.ok(Number.isSafeInteger(u.outputTokens)&&u.outputTokens>=0);return n+u.inputTokens+u.outputTokens},0);
  assert.ok(totals<=tokenCap,"Over 2000 actual model tokens: "+j.blindId);
  const calls=r.retrievalEvents.length+(r.otherToolCalls||0);
  assert.ok(Number.isSafeInteger(r.otherToolCalls||0)&&calls<=toolCap,"Tool budget exceeded");
  for(const e of r.retrievalEvents){
   const t=tasks.tasks.find(t=>t.id===j.taskId),expected=retrieval(t,e.query);
   assert.deepEqual(e.response,expected,"Retrieval response not byte-equal to frozen public source");
   assert.equal(e.responseSha256,sha(JSON.stringify(expected)),"Retrieval hash mismatch");
  }
  assert.ok(r.startedAt&&r.finishedAt&&Number.isFinite(Date.parse(r.startedAt))&&Number.isFinite(Date.parse(r.finishedAt))&&Date.parse(r.finishedAt)>=Date.parse(r.startedAt),"Missing timestamps");
  assert.ok(Date.parse(r.finishedAt)-Date.parse(r.startedAt)<=30*60*1000,"Wall-clock cap exceeded");
 }
 // Conditions are absent from the exported reviewer packet; no numerical result inferred here.
 const review=shuffle(jobs.map(j=>({blindId:j.blindId,taskId:j.taskId,
  answer:map.get(j.blindId).answer,sourceQuoteRefs:map.get(j.blindId).sourceQuoteRefs||[]})),rng(1729+51));
 write(path.join(out,"blind-answers.json"),review);
 console.log("PASS: 12 real metered raw outputs validated; blind reviewer packet created (results remain ungraded).");
}
const mode=process.argv[2]||"--selftest";
try{
 if(mode==="--freeze")freeze(process.argv[3]||"/tmp/nightfall-original-gate-c");
 else if(mode==="--retrieve")cliRetrieve(process.argv[3],process.argv.slice(4).join(" "));
 else if(mode==="--validate")validateOutputs(process.argv[3]||"/tmp/nightfall-original-gate-c");
 else if(mode==="--selftest"){
  const j=pairedJobs();assert.equal(j.length,12);const before=JSON.stringify(j);
  assert.equal(JSON.stringify(pairedJobs()),before,"Nondeterministic packet generation");
  assert.ok(j.filter(x=>x.arm==="F").every(x=>x.graphEdges.length===0));
  assert.ok(j.filter(x=>x.arm==="G").every(x=>x.graphEdges.every(e=>e.id!==knownConflict)));
  console.log("PASS original Vesper task-set parity: 12 arms, equal retrievals, fixed graph-only edge deltas, quarantined TR-007, source-lock integrity.");
 }else throw Error("Usage: parity_runner.cjs --selftest | --freeze DIR | --retrieve TASK QUERY | --validate DIR");
}catch(e){console.error("PARITY_REJECTED:",e.stack||e.message);process.exitCode=1}
