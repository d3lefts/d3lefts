#!/usr/bin/env node
"use strict";
/* Original Vesper Gate C v1: independent blinded grading and six-pair accounting. */
const fs=require("node:fs"),path=require("node:path"),assert=require("node:assert/strict"),cp=require("node:child_process"),crypto=require("node:crypto");
const rubric=require("./frozen-vesper/BLIND_RUBRIC_v1.json");
const sha=x=>crypto.createHash("sha256").update(x).digest("hex");
const out=process.argv[2]||"/tmp/nightfall-original-gate-c";
const file=name=>JSON.parse(fs.readFileSync(path.join(out,name),"utf8"));
function report(){
 cp.execFileSync(process.execPath,[path.join(__dirname,"parity_runner.cjs"),"--validate",out],{stdio:"pipe"});
 const jobs=file("operator-jobs.json"),raw=file("raw-outputs.json"),graded=file("blinded-grades.json");
 assert.ok(Array.isArray(graded)&&graded.length===12,"12 independently adjudicated blind records required");
 const gmap=new Map(graded.map(g=>[g.blindId,g]));assert.equal(gmap.size,12,"Duplicate/missing grades");
 const rawmap=new Map(raw.map(r=>[r.blindId,r]));
 const summary={G:{tasks:0,primaryPasses:0,scoreSum:0,falsePromotions:0,validObstructions:0},F:{tasks:0,primaryPasses:0,scoreSum:0,falsePromotions:0,validObstructions:0}};
 const rows=[];
 for(const j of jobs){
  const g=gmap.get(j.blindId),r=rawmap.get(j.blindId);
  assert.ok(g&&r,"Missing blind grade or raw output");
  assert.equal(g.taskId,j.taskId,"Blind grade task mismatch");
  assert.ok(typeof g.reviewerId==="string"&&g.reviewerId.trim().length>=5,"Independent reviewer identity required");
  assert.ok(r.executionAgentId&&g.reviewerId!==r.executionAgentId,"Grading and execution cannot share an identity");
  assert.ok([0,1,2].includes(g.primaryScore),"Score must be 0,1,2");
  assert.ok(typeof g.reason==="string"&&g.reason.length>=25,"Written source-grounded rationale required");
  assert.ok(typeof g.sourceCitation==="string"&&g.sourceCitation.length>=8,"Primary source reference required");
  for(const k of ["falsePromotion","validObstruction","necessaryDependency","explicitFailureCondition"])
   assert.equal(typeof g[k],"boolean","Missing rubric field "+k);
  const s=summary[j.arm];s.tasks++;s.primaryPasses+=Number(g.primaryScore===2);s.scoreSum+=g.primaryScore;
  s.falsePromotions+=Number(g.falsePromotion);s.validObstructions+=Number(g.validObstruction);
  rows.push({task:j.taskId,condition:j.arm,blindId:j.blindId,
    score:g.primaryScore,falsePromotion:g.falsePromotion,validObstruction:g.validObstruction,
    inputTokens:r.usageEvents.reduce((a,b)=>a+b.inputTokens,0),
    outputTokens:r.usageEvents.reduce((a,b)=>a+b.outputTokens,0),
    toolCalls:r.retrievalEvents.length+(r.otherToolCalls||0),
    graderId:g.reviewerId});
 }
 assert.equal(summary.G.tasks,6);assert.equal(summary.F.tasks,6);
 const paired=["FF-01","FF-02","WR-01","WR-02","SP-01","SP-02"].map(id=>{
  const a=rows.find(r=>r.task===id&&r.condition==="G"),b=rows.find(r=>r.task===id&&r.condition==="F");
  assert.ok(a&&b);return{task:id,graphScore:a.score,flatScore:b.score,difference:a.score-b.score,
    graphFalsePromotion:a.falsePromotion,flatFalsePromotion:b.falsePromotion};
 });
 const measured={format:"nightfall-gate-c-original-v1-measured-unreviewed",seed:1729,taskPairs:6,
  limitation:"Six matched pairs only. Research efficacy and public Observatory publication remain independently gated.",
  dataHashes:{raw:sha(fs.readFileSync(path.join(out,"raw-outputs.json"))),grades:sha(fs.readFileSync(path.join(out,"blinded-grades.json"))),
    rubric:sha(fs.readFileSync(path.join(__dirname,"frozen-vesper/BLIND_RUBRIC_v1.json")))},
  summary,paired,observedDifference:summary.G.primaryPasses-summary.F.primaryPasses,
  scientificApproval:"PENDING_VESPER_AND_OWNER",externalScientificReplication:false};
 fs.writeFileSync(path.join(out,"score-unreviewed.json"),JSON.stringify(measured,null,2)+"\n");
 console.log(JSON.stringify({source:"12 independently graded actual model responses",primary:summary,delta:measured.observedDifference,publication:"UNREVIEWED"},null,2));
}
try{assert.equal(rubric.seed,1729);report()}catch(e){console.error("BLIND_SCORE_REJECTED:",e.message);process.exitCode=1}
