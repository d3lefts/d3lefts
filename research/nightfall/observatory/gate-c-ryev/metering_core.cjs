"use strict";
/* Provider payload and usage accounting validator shared between live runner and preflight.
   A JSON trace can be forged; only a trusted direct runner and provider logs establish origin. */
const assert=require("node:assert/strict"),crypto=require("node:crypto");
const sha=x=>crypto.createHash("sha256").update(x).digest("hex");
const modelConfig="openai-responses-v1|tools-none|truncation-disabled|store-false";
function makeBase(job,model){
 const prompt={
  task:job.taskId,question:job.prompt,originalSources:job.baselineRetrieval,
  sourceClaimFacts:job.commonNodeFacts,typedRelationships:job.graphEdges,
  quarantinedEdges:job.quarantinedEdgeIds,
  constraints:"Name one decisive next test with exact falsification criterion. Source evidence and proof scope are mandatory. No theorem-status promotion without source proof."
 };
 return{model,input:JSON.stringify(prompt),
  instructions:"Answer the supplied scientific decision question. Use only the listed original source excerpts. Make uncertainty explicit, cite the file and line when possible. Treat analogies and proposed transfers as unproved.",
  store:false,tools:[],truncation:"disabled"};
}
function answerFromResponse(v){
 return(v.output||[]).filter(x=>x.type==="message").flatMap(x=>(x.content||[]).filter(y=>y.type==="output_text").map(y=>y.text||"")).join("\n").trim();
}
function verify(job,r){
 assert.ok(job&&r&&r.providerTrace,"Real provider accounting trace is mandatory.");
 const p=r.providerTrace;assert.equal(p.transport,"openai-responses-http-v1");
 assert.ok(typeof r.model==="string"&&r.model.length>4);
 assert.equal(r.modelConfig,modelConfig,"Model configuration differs from frozen trial schema.");
 assert.equal(p.model,r.model);assert.equal(r.executionAgentId,"RYEV-RESPONSES-API-RUNNER");
 assert.equal(r.inputSha256,job.inputSha256,"Tampered treatment packet fingerprint.");
 assert.equal(r.taskId,job.taskId);assert.equal(r.blindId,job.blindId);
 assert.deepEqual(p.payload.model,r.model);
 const expected=makeBase(job,r.model);
 for(const k of Object.keys(expected))assert.deepEqual(p.payload[k],expected[k],"Changed prompt/source/graph field "+k);
 assert.deepEqual(Object.keys(p.payload).sort(),[...Object.keys(expected),"max_output_tokens"].sort(),"Unrecognized provider request fields.");
 assert.ok(Number.isSafeInteger(p.inputCountRaw?.input_tokens)&&p.inputCountRaw.input_tokens>0,"Input-token counter must be provider captured, never zero/estimated.");
 assert.equal(p.inputCountRaw.object,"response.input_tokens","Wrong token-count endpoint response type");
 assert.equal(p.requestPayloadSha256,sha(JSON.stringify(p.payload)),"Provider request digest changed.");
 assert.equal(p.responseSha256,sha(JSON.stringify(p.response)),"Provider body digest changed.");
 const u=p.response?.usage;
 assert.ok(p.response?.id&&p.response?.model,"Missing raw provider response identity.");
 assert.equal(p.response.model,r.model);
 assert.ok(Number.isSafeInteger(u?.input_tokens)&&u.input_tokens>0,"Missing nonzero provider input-token count.");
 assert.ok(Number.isSafeInteger(u?.output_tokens)&&u.output_tokens>=0,"Missing provider output-token count.");
 assert.equal(p.inputCountRaw.input_tokens,u.input_tokens,"Token count endpoint disagrees with response.");
 assert.equal(p.payload.max_output_tokens,Math.min(550,job.maxTotalTokens-u.input_tokens),"Unfrozen or overbroad output cap.");
 assert.ok(u.input_tokens+u.output_tokens<=job.maxTotalTokens,"Measured model tokens exceed 2000 total budget.");
 assert.ok(p.payload.max_output_tokens>=16&&u.output_tokens<=p.payload.max_output_tokens,"Generated output exceeds requested bound.");
 assert.deepEqual(r.usageEvents,[{inputTokens:u.input_tokens,outputTokens:u.output_tokens,requestId:p.response.id,source:"provider.response.usage"}],
   "Caller-declared usage must equal captured raw response usage.");
 assert.equal(r.answer,answerFromResponse(p.response),"Answer differs from captured provider output.");
 assert.ok(r.answer.trim().length>=30,"Scientific response is empty.");
 assert.equal(r.retrievalEvents.length,1,"Frozen study permits only one bounded identical retrieval.");
 const e=r.retrievalEvents[0];
 assert.equal(e.query,job.prompt);
 assert.deepEqual(e.response,job.baselineRetrieval,"Source excerpt bytes changed.");
 assert.equal(e.responseSha256,sha(JSON.stringify(job.baselineRetrieval)),"Source excerpt fingerprint changed.");
 assert.equal(r.otherToolCalls,2,"Count both token-counter API and response calls.");
 assert.equal(r.retrievalEvents.length+r.otherToolCalls,3);
 assert.equal(r.startedAt&&Number.isFinite(Date.parse(r.startedAt)),true);
 assert.equal(r.finishedAt&&Number.isFinite(Date.parse(r.finishedAt)),true);
 assert.ok(Date.parse(r.finishedAt)>=Date.parse(r.startedAt)&&Date.parse(r.finishedAt)-Date.parse(r.startedAt)<=1800000,"Wall clock outside 30 minutes.");
 return{inputTokens:u.input_tokens,outputTokens:u.output_tokens,providerRequestId:p.response.id,model:p.response.model};
}
module.exports={sha,modelConfig,makeBase,answerFromResponse,verify};
