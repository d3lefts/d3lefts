#!/usr/bin/env node
"use strict";
/* Synthetic validator fixtures only — no provider requests, trial outcomes or efficacy estimates. */
const assert=require("node:assert/strict"),M=require("./metering_core.cjs");
const clone=x=>JSON.parse(JSON.stringify(x));
const source={format:"nightfall-gate-c-identical-retrieval-v1",taskId:"FF-01",query:"Check a finite-field hypothesis",
 files:[{file:"source.md",sourceSha256:"a".repeat(64),sourceBlobSha:"b".repeat(40),
  fullBytes:16000,excerpts:[{line:1,text:"long source ".repeat(850),sha256:"c".repeat(64)}]}]};
const job={taskId:"FF-01",blindId:"B-fixture-test-only",inputSha256:"d".repeat(64),
 prompt:"Check a finite-field hypothesis",baselineRetrieval:source,
 commonNodeFacts:[{id:"node1",title:"Finite-field hypothesis",status:"conditional"}],
 graphEdges:[{id:"TR-fixture",from:"node1",to:"node2",type:"analogy"}],
 quarantinedEdgeIds:[],maxTotalTokens:2000};
const model="gpt-test-fixture",count=1800,out=40;
const payload={...M.makeBase(job,model),max_output_tokens:Math.min(550,job.maxTotalTokens-count)};
const response={id:"resp_synthetic_unit_test",model,usage:{input_tokens:count,output_tokens:out},
 output:[{type:"message",content:[{type:"output_text",text:"Run the exact finite-field experiment. A single violating rank sample disproves the proposed universal statement."}]}]};
const row={blindId:job.blindId,taskId:job.taskId,inputSha256:job.inputSha256,
 model,modelConfig:M.modelConfig,answer:M.answerFromResponse(response),executionAgentId:"RYEV-RESPONSES-API-RUNNER",
 startedAt:"2026-10-29T03:00:00Z",finishedAt:"2026-10-29T03:01:00Z",
 usageEvents:[{inputTokens:count,outputTokens:out,requestId:response.id,source:"provider.response.usage"}],
 retrievalEvents:[{query:job.prompt,response:source,responseSha256:M.sha(JSON.stringify(source))}],otherToolCalls:2,
 providerTrace:{transport:"openai-responses-http-v1",model,payload,countPayload:{model:payload.model,input:payload.input,instructions:payload.instructions,tools:payload.tools},inputCountRaw:{object:"response.input_tokens",input_tokens:count},
  inputCountRequestId:"req_fixture_input",requestId:"req_fixture_output",response,
  responseSha256:M.sha(JSON.stringify(response)),requestPayloadSha256:M.sha(JSON.stringify(payload))}};
function rejects(name,fn){
 let e;try{fn()}catch(x){e=x}
 assert.ok(e,"FAIL closed: "+name);return name;
}
assert.equal(M.verify(job,row).inputTokens,count);
const tests=[];
tests.push(rejects("Untrusted zero inputTokens despite 10KB source",()=>{
 const x=clone(row);x.providerTrace.inputCountRaw.input_tokens=0;x.providerTrace.response.usage.input_tokens=0;
 x.usageEvents[0].inputTokens=0;x.providerTrace.responseSha256=M.sha(JSON.stringify(x.providerTrace.response));M.verify(job,x)
}));
tests.push(rejects("Altered retrieved source excerpt",()=>{
 const x=clone(row);x.retrievalEvents[0].response.files[0].excerpts[0].text+=" changed";M.verify(job,x)
}));
tests.push(rejects("Altered source inside provider prompt",()=>{
 const x=clone(row);const p=JSON.parse(x.providerTrace.payload.input);
 p.originalSources.files[0].excerpts[0].text+=" fabricated";x.providerTrace.payload.input=JSON.stringify(p);
 x.providerTrace.requestPayloadSha256=M.sha(JSON.stringify(x.providerTrace.payload));M.verify(job,x)
}));
tests.push(rejects("Over-budget actual provider tokens",()=>{
 const x=clone(row);x.providerTrace.response.usage.input_tokens=2000;
 x.providerTrace.responseSha256=M.sha(JSON.stringify(x.providerTrace.response));x.usageEvents[0].inputTokens=2000;M.verify(job,x)
}));
tests.push(rejects("Fabricated user-supplied counters",()=>{
 const x=clone(row);x.usageEvents[0].inputTokens=2;M.verify(job,x)
}));
tests.push(rejects("Mismatched provider response output",()=>{
 const x=clone(row);x.answer="a plausible fabricated decision with a different result";M.verify(job,x)
}));
tests.push(rejects("Missing provider trace",()=>{
 const x=clone(row);delete x.providerTrace;M.verify(job,x)
}));
tests.push(rejects("Unapproved graph-only answer hints",()=>{
 const x=clone(row);x.providerTrace.payload.input+=" hidden answer hint";
 x.providerTrace.requestPayloadSha256=M.sha(JSON.stringify(x.providerTrace.payload));M.verify(job,x)
}));
console.log("PASS: synthetic provider-accounting schema positive control and "+tests.length+" deliberate invalid-trace refusals. ZERO actual model trials.");
