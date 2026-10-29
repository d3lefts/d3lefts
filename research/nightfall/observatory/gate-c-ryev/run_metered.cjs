#!/usr/bin/env node
"use strict";
/* Gate C / direct OpenAI Responses execution; provider usage captured from actual HTTP body.
   Never fabricates tokens or trials. Requires explicit API credentials and frozen secret allocation.
   Does NOT run inside GitHub Actions or publish raw responses before blind grading. */
const fs=require("node:fs"),path=require("node:path"),crypto=require("node:crypto"),cp=require("node:child_process"),assert=require("node:assert/strict");
const dir=process.argv[2],url="https://api.openai.com/v1/responses";
const key=process.env.OPENAI_API_KEY,model=process.env.GATE_C_MODEL,blind=process.env.GATE_C_BLIND_KEY;
const sha=x=>crypto.createHash("sha256").update(x).digest("hex");
const M=require("./metering_core.cjs");
function requireValid(){
 assert.ok(dir&&path.isAbsolute(dir),"Usage: node run_metered.cjs /absolute/private/frozen/study (requires OPENAI_API_KEY, GATE_C_MODEL and GATE_C_BLIND_KEY)");
 assert.ok(key&&key.startsWith("sk-")&&key.length>18,"Missing real OPENAI_API_KEY; study cannot run with invented accounting.");
 assert.ok(model&&/^[a-z0-9][a-z0-9.-]{3,70}$/i.test(model),"Set an explicit single GATE_C_MODEL before inference.");
 assert.ok(/^[0-9a-f]{64}$/i.test(blind||""),"Set the frozen private 64-hex GATE_C_BLIND_KEY.");
 const freeze=JSON.parse(fs.readFileSync(path.join(dir,"freeze.json"),"utf8"));
 assert.equal(freeze.blinding,"SECRET_HMAC_OPERATOR_ONLY","Public development IDs cannot be used as trials.");
 assert.equal(freeze.keyCommitmentSha256,sha(blind),"Blind key differs from the frozen allocation commitment.");
 assert.equal(freeze.taskCount,6);assert.equal(freeze.arms,12);
 assert.ok(!fs.existsSync(path.join(dir,"raw-outputs.json")),"Raw study output already exists; overwrite forbidden.");
}
async function post(endpoint,payload){
 const started=Date.now(),res=await fetch(endpoint,{
  method:"POST",headers:{"Authorization":"Bearer "+key,"Content-Type":"application/json"},
  body:JSON.stringify(payload),signal:AbortSignal.timeout(120000)
 });
 const body=await res.text();
 let response;try{response=JSON.parse(body)}catch(e){throw Error("Provider returned non-JSON body for "+endpoint+" (HTTP "+res.status+").")}
 if(!res.ok)throw Error("OpenAI API "+endpoint+" HTTP "+res.status+" / "+String(response.error?.type||"request failed").slice(0,160));
 return {response,requestId:res.headers.get("x-request-id"),elapsedMs:Date.now()-started};
}
async function run(){
 requireValid();
 const jobs=JSON.parse(fs.readFileSync(path.join(dir,"operator-jobs.json"),"utf8"));
 assert.equal(jobs.length,12,"Frozen jobs missing.");
 const rows=[],tmp=path.join(dir,"raw-outputs.partial.json");
 assert.ok(!fs.existsSync(tmp),"Partial raw output exists; resolve it before starting a new study.");
 for(const job of jobs){
  const base=M.makeBase(job,model);
  const inputCount=await post(url+"/input_tokens",base);
  const count=inputCount.response.input_tokens;
  assert.ok(Number.isSafeInteger(count)&&count>0,"Provider did not return an exact input-token count.");
  assert.ok(count+16<=job.maxTotalTokens,"Prompt consumes 2000-token budget: "+job.taskId);
  const max_output_tokens=Math.min(550,job.maxTotalTokens-count);
  assert.ok(max_output_tokens>=16);
  const payload={...base,max_output_tokens};
  // Counted prompt shape is unchanged by max_output_tokens; only upper output bound differs.
  const now=new Date().toISOString(),called=await post(url,payload),response=called.response;
  assert.ok(typeof response.id==="string"&&response.id.length>6,"Missing provider-generated response ID.");
  assert.equal(response.model,model,"Provider served a different model than the frozen configuration.");
  const usage=response.usage;
  assert.ok(usage&&Number.isSafeInteger(usage.input_tokens)&&Number.isSafeInteger(usage.output_tokens),"Actual provider usage missing.");
  assert.equal(usage.input_tokens,count,"Preflight provider input-token count differs from generation usage.");
  assert.ok(usage.input_tokens+usage.output_tokens<=job.maxTotalTokens,"Over-budget actual provider usage; mark trial invalid.");
  const answer=M.answerFromResponse(response);
  assert.ok(answer.length>=30,"Provider produced no adequately readable scientific decision.");
  const record={
   blindId:job.blindId,taskId:job.taskId,inputSha256:job.inputSha256,
   answer,model,modelConfig:M.modelConfig,
   executionAgentId:"RYEV-RESPONSES-API-RUNNER",
   startedAt:now,finishedAt:new Date().toISOString(),
   usageEvents:[{inputTokens:usage.input_tokens,outputTokens:usage.output_tokens,requestId:response.id,source:"provider.response.usage"}],
   retrievalEvents:[{query:job.prompt,response:job.baselineRetrieval,responseSha256:sha(JSON.stringify(job.baselineRetrieval))}],
   otherToolCalls:2, // conservative: include token-count and Responses API calls
   filesRead:job.sourceFamilies.slice(),
   providerTrace:{
    transport:"openai-responses-http-v1",model,payload,inputCountRaw:inputCount.response,
    inputCountRequestId:inputCount.requestId,response,requestId:called.requestId,
    responseSha256:sha(JSON.stringify(response)),requestPayloadSha256:sha(JSON.stringify(payload))
   }
  };
  M.verify(job,record); // Validate provider raw trace against exact sent prompt and matched source.
  rows.push(record);
  fs.writeFileSync(tmp,JSON.stringify(rows,null,2)+"\n",{mode:0o600});
  console.log("Captured provider-metered "+rows.length+"/12, blindId "+job.blindId+"; tokens="+(usage.input_tokens+usage.output_tokens));
 }
 fs.renameSync(tmp,path.join(dir,"raw-outputs.json"));
 cp.execFileSync(process.execPath,[path.join(__dirname,"parity_runner.cjs"),"--validate",dir],{stdio:"inherit",env:process.env});
 console.log("Twelve real provider-metered trials captured. Human blind grading remains pending.");
}
run().catch(e=>{console.error("GATE_C_PROVIDER_RUN_REJECTED:",e.message);process.exitCode=1});
