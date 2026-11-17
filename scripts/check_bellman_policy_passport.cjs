'use strict';
/**
 * Fail-closed chain custody for the original-world finite Bellman policy.
 * Trust boundaries: Git-hash and exact offline replay ≠ GitHub CI attestation
 * ≠ general Lean formalization of this JSON ≠ authentic physical authority.
 */
const fs=require('node:fs');
const path=require('node:path');
const crypto=require('node:crypto');
const child=require('node:child_process');
const assert=require('node:assert/strict');
const ROOT=path.resolve(__dirname,'..');
const INPUT='research/nightfall/price_permission/bellman_two_source_policy_certificate.json';
const CHECKER='research/nightfall/price_permission/check_bellman_policy_certificate.py';
const INDEPENDENT='research/nightfall/price_permission/check_bellman_policy_independent.cjs';
const GENERATOR='research/nightfall/price_permission/generate_bellman_policy_certificate.py';
const FORMAL='research/nightfall/formalization/agent_safety/SemanticBellmanPotential.lean';
const BASE='research/nightfall/formalization/agent_safety/SemanticFencing.lean';
const SOLVER='research/nightfall/assurance/semantic-fencing-v0.3/semantic_fence.py';
const CONTRACT='research/nightfall/price_permission/bellman_policy_type_contract.json';
const WORKFLOW='.github/workflows/nightfall-bellman-policy-passport-lean.yml';
const sha=x=>crypto.createHash('sha256').update(x).digest('hex');
function checkedPath(rel){
  assert.ok(typeof rel==='string'&&rel&&!path.isAbsolute(rel)&&
            rel.split('/').every(p=>p&&p!=='.'&&p!=='..'),'unsafe file path');
  const full=path.resolve(ROOT,rel);
  assert.ok(full.startsWith(ROOT+path.sep)&&fs.statSync(full).isFile());
  assert.ok(fs.realpathSync(full).startsWith(ROOT+path.sep));
  return full;
}
const read=p=>fs.readFileSync(checkedPath(p));
const json=p=>JSON.parse(read(p));
function blob(p){
  const bytes=read(p);
  return crypto.createHash('sha1').update('blob '+bytes.length+'\0').update(bytes).digest('hex');
}
const canonical=x=>Array.isArray(x)?x.map(canonical):
  x&&typeof x==='object'?Object.fromEntries(Object.keys(x).sort().map(k=>[k,canonical(x[k])])):x;
function digest(x){return sha(JSON.stringify(canonical(x)))}
function run(cmd,args){
  const r=child.spawnSync(cmd,args,{cwd:ROOT,encoding:'utf8',timeout:40000,maxBuffer:1e6});
  assert.equal(r.status,0,(r.stderr||r.stdout||'')+' [command failure]');
  return r.stdout;
}
function verifyRecord(r,{replay=true}={}){
  assert.equal(r.id,'permission-two-source-bellman-policy-v1');
  assert.equal(r.programme,'The Price of Permission / adaptive observation and semantic fencing');
  assert.ok(['source_matched_pending_lean_receipt','source_matched_scoped_named_lean_receipt'].includes(r.status));
  assert.equal(r.complete_certification,false);
  assert.equal(r.original_semantic_model.path,INPUT);
  assert.equal(r.original_semantic_model.embedded_key,'source_model');
  assert.equal(r.original_semantic_model.audited_completeness,'synthetic_model_only');
  assert.equal(r.proof_object.embedded_key,'certificate');
  assert.equal(r.proof_object.format,'nightfall-semantic-bellman-certificate/v1');
  assert.equal(r.proof_object.mathematical_claim,'all_belief_minimax_upper_and_lower_match');
  assert.equal(r.proof_object.optimal_cost,'5');
  assert.equal(r.proof_object.belief_states,7);
  assert.equal(r.checker.path,CHECKER);
  assert.equal(r.checker.independent_path,INDEPENDENT);
  assert.equal(r.checker.generator_path,GENERATOR);
  assert.equal(r.checker.generator_dependency,SOLVER);
  assert.equal(r.checker.negative_controls,19);
  assert.equal(r.checker.independent_negative_controls,11);
  assert.equal(r.lean.source,FORMAL);
  assert.equal(r.lean.depends_on,BASE);
  assert.equal(r.lean.contract,CONTRACT);
  assert.equal(r.lean.compiler_lock,'docs/lean-compiler-lock.json');
  const lock=json('docs/lean-compiler-lock.json');
  assert.deepEqual([...r.lean.axioms].sort(),[...lock.allowed_axioms].sort());
  assert.equal(r.lean.declarations.length,2);
  const map=[
    [INPUT,r.original_semantic_model.git_blob_sha1],
    [CHECKER,r.checker.git_blob_sha1],
    [INDEPENDENT,r.checker.independent_git_blob_sha1],
    [GENERATOR,r.checker.generator_git_blob_sha1],
    [SOLVER,r.checker.generator_dependency_git_blob_sha1],
    [FORMAL,r.lean.source_git_blob_sha1],
    [BASE,r.lean.depends_on_git_blob_sha1],
    [CONTRACT,r.lean.contract_git_blob_sha1]
  ];
  for(const [file,digestExpected] of map){
    assert.match(digestExpected,/^[0-9a-f]{40}$/);
    assert.equal(blob(file),digestExpected,'source invalidated '+file);
  }
  const sample=json(INPUT);
  assert.equal(sample.schema,'nightfall-semantic-bellman-certificate/v1');
  assert.equal(sample.source_model.kind,'nightfall-complete-bitcube-evidence/v1');
  assert.equal(sample.source_model.change_history,'complete-baseline-to-final-xor');
  assert.equal(digest(sample.source_model),r.original_semantic_model.source_sha256);
  assert.equal(sample.certificate.source_sha256,r.original_semantic_model.source_sha256);
  assert.equal(sample.certificate.root_belief,7);
  assert.equal(sample.certificate.claimed_optimal_cost,'5');
  assert.equal(Object.keys(sample.certificate.states).length,7);
  const contract=json(CONTRACT);
  assert.equal(contract.schema,'nightfall-theorem-contract/v1');
  assert.equal(contract.source,FORMAL);
  assert.deepEqual(contract.targets.map(x=>x.declaration),r.lean.declarations);
  for(const target of contract.targets){
    assert.ok(target.expected_type.includes('BellmanLowerCertificate')&&
      target.expected_type.includes('PlanValid')&&target.expected_type.includes('worstCost'));
    assert.match(read(FORMAL).toString(),new RegExp('\\btheorem\\s+'+target.declaration.split('.').at(-1)+'\\b'));
  }
  const work=read(WORKFLOW).toString();
  for(const used of [CHECKER,INDEPENDENT,GENERATOR,FORMAL,BASE,CONTRACT,SOLVER]){
    assert.ok(work.includes(used),'workflow missing custody '+used);
  }
  assert.ok(work.includes('--contract '+CONTRACT));
  for(const theorem of r.lean.declarations)assert.ok(work.includes('--decl '+theorem));
  assert.ok(Array.isArray(r.limitations)&&r.limitations.length>=4);
  assert.ok(r.limitations.some(x=>x.includes('JSON')));
  assert.ok(r.limitations.some(x=>x.includes('physical')));
  const evidence=r.evidence;
  assert.equal(evidence.pr,784);
  assert.equal(evidence.independent_lake_check,'not_run');
  assert.equal(evidence.external_human_review,'none');
  assert.equal(evidence.semantic_model_verified_externally,false);
  if(r.status==='source_matched_pending_lean_receipt'){
    assert.equal(evidence.ci_run,null);
    assert.equal(evidence.artifact_id,null);
    assert.equal(evidence.exact_head,null);
    assert.equal(evidence.observed_result,'pending');
    assert.equal(r.claim_gates.lean_soundness,'pending_pinned_kernel');
  } else {
    assert.ok(Number.isInteger(evidence.ci_run)&&evidence.ci_run>0);
    assert.ok(Number.isInteger(evidence.artifact_id)&&evidence.artifact_id>0);
    assert.match(evidence.exact_head,/^[a-f0-9]{40}$/);
    assert.equal(evidence.observed_result,'success_on_exact_original_pr_head');
    assert.equal(evidence.source,'https://github.com/d3lefts/d3lefts/actions/runs/'+evidence.ci_run);
    assert.equal(r.claim_gates.lean_soundness,'pinned_named_kernel_receipt_passed');
  }
  assert.equal(r.claim_gates.original_history_model,'source_bound_exact_checker_passed');
  assert.equal(r.claim_gates.all_belief_local_inequalities,'source_bound_exact_checker_passed');
  assert.equal(r.claim_gates.independent_budget_decision,'independent_exact_checker_passed');
  assert.equal(r.claim_gates.JSON_to_Lean_instance,'not_formalized');
  assert.equal(r.claim_gates.global_physical_safety,'open');
  if(replay){
    const proposed=JSON.parse(run('python3',['-I',CHECKER,INPUT]));
    assert.equal(proposed.status,'PASS');
    assert.equal(proposed.cost,'5');
    assert.equal(proposed.belief_states,7);
    assert.equal(proposed.source_sha256,r.original_semantic_model.source_sha256);
    assert.match(run('python3',['-I',CHECKER,'--self-test']),/19 rejected mutations/);
    assert.match(run('python3',['-I',GENERATOR,'--check']),/joint_value/);
    assert.match(run('node',[INDEPENDENT]),/11 negative controls/);
  }
  return true;
}
function selfTest(rec){
  const clone=x=>JSON.parse(JSON.stringify(x));
  const mutants=[
    x=>x.original_semantic_model.source_sha256='0'.repeat(64),
    x=>x.original_semantic_model.git_blob_sha1='0'.repeat(40),
    x=>x.checker.git_blob_sha1='0'.repeat(40),
    x=>x.checker.independent_git_blob_sha1='0'.repeat(40),
    x=>x.checker.generator_dependency_git_blob_sha1='0'.repeat(40),
    x=>x.lean.source_git_blob_sha1='0'.repeat(40),
    x=>x.lean.depends_on_git_blob_sha1='0'.repeat(40),
    x=>x.lean.contract_git_blob_sha1='0'.repeat(40),
    x=>x.proof_object.optimal_cost='4',
    x=>x.proof_object.belief_states=6,
    x=>x.complete_certification=true,
    x=>x.claim_gates.JSON_to_Lean_instance='formally_verified',
    x=>x.evidence.independent_lake_check='passed',
    x=>x.evidence.external_human_review='complete'
  ];
  mutants.forEach((mut,i)=>{
    const d=clone(rec);mut(d);
    assert.throws(()=>verifyRecord(d,{replay:false}),undefined,'accepted forged Bellman passport '+i);
  });
  return mutants.length;
}
if(require.main===module){
  const manifest=json('docs/proof-object-passport.json');
  const record=manifest.records.find(x=>x.id==='permission-two-source-bellman-policy-v1');
  assert.ok(record,'source-bound Bellman passport record missing');
  verifyRecord(record);
  const n=selfTest(record);
  console.log('PASS: all-belief policy proof-object chain, '+n+
    ' forged passport controls rejected; status='+record.status+
    ' (historical source binding, not new remote CI attestation)');
}
module.exports={verifyRecord,selfTest};
