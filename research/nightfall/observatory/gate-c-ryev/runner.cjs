#!/usr/bin/env node
"use strict";
/* Gate C: freeze six paired G-vs-F tasks, preserve raw receipts and forbid grade-before-run claims. */
const fs=require("node:fs"),path=require("node:path"),crypto=require("node:crypto"),cp=require("node:child_process"),assert=require("node:assert/strict");
const spec=require("./tasks.json"),rubric=require("./rubric.json");
const sha=x=>crypto.createHash("sha256").update(x).digest("hex");
function rng(seed){let x=seed>>>0;return()=>((x=(Math.imul(x,1664525)+1013904223)>>>0)/4294967296)}
function shuffled(xs,random){const a=xs.slice();for(let i=a.length-1;i>0;i--){let j=Math.floor(random()*(i+1));[a[i],a[j]]=[a[j],a[i]]}return a}
function pinnedSources(){
 const obj={};for(const [k,s] of Object.entries(spec.sources)){
  const bytes=cp.execFileSync("git",["show",spec.sourceCommit+":"+s.path],{maxBuffer:32e6});
  const blob=cp.execFileSync("git",["hash-object","--stdin"],{input:bytes,encoding:"utf8"}).trim();
  assert.equal(blob,s.blobSha,"Source drift at "+s.path);
  obj[k]={...s,size:bytes.length,sha256:sha(bytes)};
 }
 return obj
}
function makeFrozen(){
 assert.equal(spec.seed,1729);assert.equal(spec.tasks.length,6);
 const random=rng(spec.seed),sources=pinnedSources(),arms=[];
 const pairs=shuffled(spec.tasks,random);
 for(const t of pairs){
  const modes=shuffled(["G","F"],random);
  for(const mode of modes){
   const token=sha("NIGHTFALL/GateC/v1/"+spec.seed+"/"+t.id+"/"+mode).slice(0,16);
   arms.push({blindId:"A-"+token,taskId:t.id,field:t.field,condition:mode,
    prompt:t.prompt,sourceRecords:t.sourceIDs.map(k=>sources[k]),graphCue:mode==="G"?t.graphCue:null,
    maxTokens:spec.budget.maxTotalModelTokensPerArm,maxTools:spec.budget.maxExternalToolCallsPerArm});
  }
 }
 assert.equal(new Set(arms.map(x=>x.blindId)).size,12);
 for(const t of spec.tasks){
  const pair=arms.filter(x=>x.taskId===t.id);
  assert.equal(pair.length,2);
  assert.deepEqual(pair[0].sourceRecords,pair[1].sourceRecords);
  assert.notEqual(pair[0].condition,pair[1].condition);
 }
 const manifest={format:"nightfall-gate-c-freeze-v1",seed:spec.seed,sourceCommit:spec.sourceCommit,
  sourceIdentities:sources,taskCount:6,armCount:12,budget:spec.budget,preregHash:sha(JSON.stringify(spec)),rubricHash:sha(JSON.stringify(rubric)),
  status:"FROZEN_INPUTS_ONLY_NO_MODEL_OUTPUTS_NO_GRADES"};
 return {arms,manifest};
}
function write(dest,obj){fs.writeFileSync(dest,JSON.stringify(obj,null,2)+"\n")}
function runFreeze(dir){
 fs.mkdirSync(dir,{recursive:true});
 const r=makeFrozen();write(path.join(dir,"freeze.json"),r.manifest);
 write(path.join(dir,"operator-jobs.json"),r.arms);
 write(path.join(dir,"blind-grading-template.json"),shuffled(r.arms.map(x=>({blindId:x.blindId,answer:null,grade:null,adjudicatorReason:null})),rng(1729+101)));
 console.log("FROZEN 6 paired tasks / 12 arms, seed=1729, identical source bytes. No observed results.");
 return r
}
function read(fn){return JSON.parse(fs.readFileSync(fn,"utf8"))}
function blind(dir){
 const {arms}=makeFrozen(),sub=read(path.join(dir,"arm-outputs.json"));
 assert.ok(Array.isArray(sub)&&sub.length===12,"12 raw arm outputs required");
 const m=new Map(sub.map(x=>[x.blindId,x]));assert.equal(m.size,12);
 const forReview=[];
 for(const a of arms){
  const o=m.get(a.blindId);assert.ok(o,"Missing "+a.blindId);
  assert.equal(o.taskId,a.taskId);assert.equal(typeof o.answer,"string");
  assert.ok(o.answer.trim().length>=30,"Empty response");
  assert.ok(Number.isSafeInteger(o.inputTokens)&&Number.isSafeInteger(o.outputTokens)&&o.inputTokens>=0&&o.outputTokens>=0);
  assert.ok(o.inputTokens+o.outputTokens<=a.maxTokens,"Token budget exceeded");
  assert.ok(Number.isSafeInteger(o.toolCalls)&&o.toolCalls>=0&&o.toolCalls<=a.maxTools,"Tool call budget exceeded");
  assert.ok(typeof o.model==="string"&&o.model.length>3&&typeof o.modelConfig==="string"&&o.modelConfig.length>5);
  assert.ok(typeof o.sourceSnapshotHash==="string"&&o.sourceSnapshotHash===sha(JSON.stringify(a.sourceRecords)),"Source snapshot mismatch");
  forReview.push({blindId:a.blindId,taskId:a.taskId,answer:o.answer,
   inputTokens:o.inputTokens,outputTokens:o.outputTokens,toolCalls:o.toolCalls,filesRead:o.filesRead,durationMs:o.durationMs});
 }
 const models=new Set(sub.map(x=>x.model+"|"+x.modelConfig));assert.equal(models.size,1,"Conditions must share identical model/configuration");
 write(path.join(dir,"blinded-answers.json"),shuffled(forReview,rng(1729+101)));
 console.log("PASS: 12 raw answers under matched budgets; condition labels removed from reviewer file.");
}
function score(dir){
 const {arms}=makeFrozen(),sub=read(path.join(dir,"arm-outputs.json")),graded=read(path.join(dir,"blinded-grades.json"));
 const ids=new Set(arms.map(x=>x.blindId));
 assert.ok(Array.isArray(graded)&&graded.length===12,"12 blinded grades required");
 const byId=new Map(graded.map(x=>[x.blindId,x]));assert.equal(byId.size,12);
 for(const g of graded){assert.ok(ids.has(g.blindId));assert.ok([0,1,2].includes(g.grade));assert.ok(typeof g.adjudicatorReason==="string"&&g.adjudicatorReason.length>=10);assert.equal(typeof g.falsePromotion,"boolean");}
 blind(dir); // rerun complete budget and consistency validation
 const rows=arms.map(a=>({...a,output:sub.find(x=>x.blindId===a.blindId),grade:byId.get(a.blindId)}));
 const stats={G:{tests:0,primary:0,gradeSum:0,falsePromotions:0},F:{tests:0,primary:0,gradeSum:0,falsePromotions:0}};
 for(const row of rows){const s=stats[row.condition];s.tests++;s.primary+=Number(row.grade.grade===2);s.gradeSum+=row.grade.grade;s.falsePromotions+=Number(row.grade.falsePromotion);}
 assert.equal(stats.G.tests,6);assert.equal(stats.F.tests,6);
 const report={format:"nightfall-gate-c-measured-v1",dataCategory:"Six within-task comparisons; excludes any assertion of population-level impact.",
   sourceCommit:spec.sourceCommit,seed:spec.seed,rawResponseCount:12,blindGradeCount:12,results:stats,
   paired:spec.tasks.map(t=>({task:t.id,G:rows.find(r=>r.taskId===t.id&&r.condition==="G").grade,
      F:rows.find(r=>r.taskId===t.id&&r.condition==="F").grade})),
   independentGraderVerified:false,editorialGate:"UNREVIEWED"};
 write(path.join(dir,"measured-unreviewed.json"),report);
 console.log(JSON.stringify({G:stats.G,F:stats.F,externalScientificApproval:false},null,2));
}
const cmd=process.argv[2]||"--selftest",dir=process.argv[3]||"/tmp/nightfall-gate-c-ryev";
try{if(cmd==="--freeze")runFreeze(dir);else if(cmd==="--blind")blind(dir);
 else if(cmd==="--score")score(dir);
 else if(cmd==="--selftest"){const a=makeFrozen();assert.equal(a.arms.length,12);console.log("PASS Gate C prereg: six paired prompts, source blob identity, fixed seed 1729 and budget rules. Results remain pending.");}
 else throw Error("Usage: node runner.cjs --freeze|--blind|--score|--selftest [OUTPUT_DIR]")}
catch(e){console.error("GATE_C_REJECTED:",e.message);process.exitCode=1}
