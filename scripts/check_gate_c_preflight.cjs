#!/usr/bin/env node
"use strict";
/* Source-byte scientific preflight, no model inference or network.
   CI must fetch pinned archive and Observatory draft commits before running.
   This checks byte identity and structural fairness constraints, not Gate C results. */
const fs=require("node:fs"),path=require("node:path");
const crypto=require("node:crypto"),cp=require("node:child_process"),assert=require("node:assert/strict");
const ROOT=path.resolve(__dirname,"..");
const DIR=path.join(ROOT,"research/nightfall/evaluations/gate_c");
const lock=JSON.parse(fs.readFileSync(path.join(DIR,"SOURCE_BLOB_LOCK_v1.json"),"utf8"));
const taskBytes=fs.readFileSync(path.join(DIR,"GATE_C_TASK_SET_v1.json"));
const tasks=JSON.parse(taskBytes.toString("utf8"));
const git=(...argv)=>cp.execFileSync("git",argv,{cwd:ROOT,encoding:"utf8",maxBuffer:32*1024*1024}).trim();
const cat=(rev,file)=>cp.execFileSync("git",["show",rev+":"+file],{cwd:ROOT,maxBuffer:32*1024*1024});
function blob(rev,file){const line=git("ls-tree",rev,"--",file);if(!line)throw Error("Source file unavailable: "+rev+":"+file);return line.split(/\s+/)[2]}
function audit(now=lock){
 assert.equal(now.schema,"nightfall-gate-c-source-lock-v1");
 assert.equal(now.archive_commit,tasks.frozen_source_commit);
 assert.equal(now.observatory_draft_commit.length,40);
 assert.deepEqual(tasks.condition_arms,["graph","flat"]);
 assert.equal(tasks.random_seed,1729);
 assert.equal(tasks.per_condition_budget.model_tokens_input_plus_output,2000);
 assert.equal(tasks.per_condition_budget.external_tool_calls,20);
 assert.equal(tasks.per_condition_budget.wall_clock_minutes,30);
 assert.equal(tasks.tasks.length,6);
 assert.equal(tasks.no_results_or_answer_keys_in_manifest,true);
 assert.equal(tasks.available_scientific_sources_identical,true);
 const tally={}; const pinned=new Set();
 for(const task of tasks.tasks){
   tally[task.family]=(tally[task.family]||0)+1;
   assert.match(task.id,/^(FF|WR|SP)-0[12]$/);
   assert.ok(task.prompt.length>30 && !/answer[_ -]?key/i.test(task.prompt));
   assert.equal(task.source_paths.length,2);
   for(const file of task.source_paths){assert.ok(now.sources[file],"Unpinned task source: "+file);pinned.add(file)}
 }
 assert.deepEqual(tally,{"finite-field":2,"werner":2,"spectral":2});
 assert.equal(Object.keys(now.sources).length,pinned.size);
 for(const name of Object.keys(now.sources))assert.ok(pinned.has(name),"unused scientific source: "+name);
 const records=[];
 for(const [file,expect] of Object.entries(now.sources)){
   assert.equal(blob(now.archive_commit,file),expect,"archive source blob changed: "+file);
   const bytes=cat(now.archive_commit,file);
   records.push({path:file,git_blob_sha1:expect,sha256:crypto.createHash("sha256").update(bytes).digest("hex"),bytes:bytes.length});
 }
 const draft=[];
 for(const [file,expect] of Object.entries(now.observatory_files)){
   assert.equal(blob(now.observatory_draft_commit,file),expect,"Observatory source blob changed: "+file);
   const b=cat(now.observatory_draft_commit,file);
   draft.push({path:file,git_blob_sha1:expect,sha256:crypto.createHash("sha256").update(b).digest("hex"),bytes:b.length});
 }
 assert.equal(blob(now.observatory_draft_commit,"research/nightfall/observatory/GATE_C_TASK_SET_v1.json"),now.observatory_files["research/nightfall/observatory/GATE_C_TASK_SET_v1.json"]);
 assert.deepEqual(taskBytes,cat(now.observatory_draft_commit,"research/nightfall/observatory/GATE_C_TASK_SET_v1.json"),"frozen task bytes differ from original");
 const graph=JSON.parse(cat(now.observatory_draft_commit,"research/nightfall/observatory/claims-v1.json"));
 assert.equal(graph.nodes.length,14);
 assert.equal(graph.edges.length,9);
 const kernel=graph.nodes.find(x=>x.id==="NF-AXIOM-KERNEL-v1");
 const edge=graph.edges.find(x=>x.id==="TR-007");
 assert.ok(kernel && edge);
 // This is a historical graph inconsistency flag, not a certificate of its truth.
 const discrepancy={historical_node_dependency:kernel.dependencies.includes("NF-FIELD-SPAN-v1"),
   typed_edge_is_shared_mechanism:edge.type==="shared-mathematical-mechanism",
   requires_new_identity_or_explicit_scope_review:true};
 return {status:"FROZEN_INPUT_INTEGRITY_PASSED_EVALUATION_PENDING",
   scientific_release_gate:"BLOCKED_PENDING_FAIRNESS_AND_REAL_PAIRED_TRIALS",
   source_snapshot_commit:now.archive_commit,graph_snapshot_commit:now.observatory_draft_commit,
   task_count:tasks.tasks.length,arms:tasks.condition_arms,task_families:tally,budgets:tasks.per_condition_budget,
   raw_sources:records,graph_sources:draft,graph_dependency_scope_review:discrepancy,
   source_retrieval_required:true,semantic_fact_parity_independently_approved:false,
   graph_versus_flat_trial_outputs:0,blind_adjudications:0,
   spectral_primary_proof_inputs:0,notes:now.limitations};
}
function testMutations(){
 const corrupted=structuredClone(lock);
 corrupted.sources[Object.keys(corrupted.sources)[0]]="0".repeat(40);
 assert.throws(()=>audit(corrupted),/archive source blob changed/);
 const missing=structuredClone(lock);
 delete missing.sources[Object.keys(missing.sources)[0]];
 assert.throws(()=>audit(missing),/Unpinned task source|unused scientific source/);
 const wrongGraph=structuredClone(lock);
 wrongGraph.observatory_files["research/nightfall/observatory/claims-v1.json"]="f".repeat(40);
 assert.throws(()=>audit(wrongGraph),/Observatory source blob changed/);
 return 3;
}
const result=audit();
if(process.argv.includes("--self-test"))result.negative_control_mutations_rejected=testMutations();
const output=JSON.stringify(result,null,2)+"\n";
if(process.argv.includes("--json"))process.stdout.write(output);
else console.log("PASS: six frozen task packets; pinned scientific source SHA-256s; graph snapshot locked; three adversarial controls. Gate C experiments PENDING.");
