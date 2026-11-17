'use strict';
/**
 * Additional model-bound Price of Permission optimal fence Proof Passport.
 * Checks exact source custody and replays BOTH the source-to-LP rational
 * checker and a logically separate operational JavaScript state enumerator.
 * This is not a Lean compilation or remote attestation of GitHub Actions.
 */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const child = require('node:child_process');
const assert = require('node:assert/strict');

const ROOT = path.resolve(__dirname, '..');
const INPUT = 'research/nightfall/price_permission/semantic_fence_optimality_4source.json';
const CHECKER = 'research/nightfall/price_permission/check_semantic_fence_primal_dual.py';
const INDEPENDENT = 'research/nightfall/price_permission/check_semantic_fence_independent.cjs';
const LEAN = 'research/nightfall/formalization/permission/PricePermissionFenceDual.lean';
const CONTRACT = 'research/nightfall/price_permission/semantic_fence_dual_type_contract.json';
const WORKFLOW = '.github/workflows/nightfall-price-permission-primal-dual-lean.yml';

function open(rel) {
  assert.ok(typeof rel === 'string' && rel && !path.isAbsolute(rel)
            && !rel.split('/').includes('..'), 'untrusted path');
  const full = path.resolve(ROOT, rel);
  assert.ok(full.startsWith(ROOT + path.sep), 'path escapes repository');
  assert.ok(fs.existsSync(full) && fs.statSync(full).isFile(), 'missing source ' + rel);
  assert.ok(fs.realpathSync(full).startsWith(ROOT + path.sep), 'symlink escape');
  return full;
}
const read = p => fs.readFileSync(open(p), 'utf8');
function gitBlob(p) {
  const bytes = fs.readFileSync(open(p));
  return crypto.createHash('sha1').update('blob ' + bytes.length + '\0').update(bytes).digest('hex');
}
const canonical = v => Array.isArray(v) ? v.map(canonical) :
  v && typeof v === 'object'
    ? Object.fromEntries(Object.keys(v).sort().map(k => [k, canonical(v[k])])) : v;
const digest = v => crypto.createHash('sha256').update(JSON.stringify(canonical(v))).digest('hex');

function execute(cmd, args) {
  const r = child.spawnSync(cmd, args, {cwd:ROOT, encoding:'utf8', timeout:30000, maxBuffer:512000});
  assert.equal(r.status, 0, 'checker failed: ' + (r.stderr || r.stdout));
  return r.stdout;
}

function verifyRecord(record, {replay=true}={}) {
  assert.equal(record.id, 'permission-four-source-optimal-fence-v1');
  assert.equal(record.status, 'source_matched_scoped_named_lean_receipt');
  assert.equal(record.complete_certification, false);
  assert.equal(record.original_semantic_model.audited_completeness, 'synthetic_model_only');
  assert.equal(record.original_semantic_model.path, INPUT);
  assert.equal(record.original_semantic_model.embedded_key, 'source_model');
  assert.equal(record.derived_instance.embedded_key, 'derived_instance');
  assert.equal(record.derived_instance.reconstruction, 'all_baseline_to_final_unsafe_bitcube_histories');
  assert.equal(record.proof_object.embedded_key, 'certificate');
  assert.equal(record.proof_object.format, 'nightfall-price-permission-primal-dual/v1');
  assert.equal(record.proof_object.mathematical_claim, 'matching_primal_dual_exact_fence_optimality');
  assert.equal(record.proof_object.optimal_cost, '4');
  assert.equal(record.checker.path, CHECKER);
  assert.equal(record.checker.independent_path, INDEPENDENT);
  assert.deepEqual(record.checker.invocation, ['python3','-I',CHECKER,INPUT]);
  assert.equal(record.checker.negative_control_count, 14);
  assert.equal(record.checker.independent_negative_control_count, 8);
  assert.equal(record.lean.source, LEAN);
  assert.equal(record.lean.contract, CONTRACT);
  assert.equal(record.lean.compiler_lock, 'docs/lean-compiler-lock.json');
  const lock=JSON.parse(read('docs/lean-compiler-lock.json'));
  assert.deepEqual([...record.lean.axioms].sort(), [...lock.allowed_axioms].sort());
  for (const [name,sha] of [
    [INPUT,record.original_semantic_model.git_blob_sha1],
    [CHECKER,record.checker.git_blob_sha1],
    [INDEPENDENT,record.checker.independent_git_blob_sha1],
    [LEAN,record.lean.source_git_blob_sha1],
    [CONTRACT,record.lean.contract_git_blob_sha1]]) {
    assert.match(sha,/^[0-9a-f]{40}$/);
    assert.equal(gitBlob(name),sha,'source bytes mutated: '+name);
  }
  const file=JSON.parse(read(INPUT));
  assert.equal(file.schema,'nightfall-price-permission-primal-dual/v1');
  assert.equal(file.source_model.kind,'full-bitcube-semantic-fence/v1');
  assert.equal(file.source_model.history_policy,'all-baseline-to-final-world-single-epoch');
  assert.equal(digest(file.source_model),record.original_semantic_model.source_sha256);
  assert.equal(file.certificate.source_sha256,record.original_semantic_model.source_sha256);
  assert.equal(digest(file.derived_instance),record.derived_instance.sha256);
  assert.equal(file.certificate.model_sha256,record.derived_instance.sha256);
  assert.deepEqual(file.certificate.primal_fence,[0,1,1,0]);
  assert.deepEqual(file.certificate.dual_packing,['2','0','2']);
  assert.equal(file.certificate.claimed_optimal_cost,'4');

  const contract=JSON.parse(read(CONTRACT));
  assert.equal(contract.schema,'nightfall-theorem-contract/v1');
  assert.equal(contract.source,LEAN);
  assert.deepEqual(contract.targets.map(t=>t.declaration),record.lean.declarations);
  assert.equal(contract.targets.length,2);
  for (const target of contract.targets) {
    assert.ok(target.expected_type.includes('ℚ') && target.expected_type.includes('Fin m'));
    assert.match(read(LEAN),new RegExp('\\btheorem\\s+' + target.declaration.split('.').at(-1) + '\\b'));
  }
  const e=record.evidence;
  assert.equal(e.pr,783);
  assert.equal(e.exact_head,'234c4a04e8f5c48479bea0a0b835c18a57597e78');
  assert.equal(e.ci_run,44177927091);
  assert.equal(e.source,'https://github.com/d3lefts/d3lefts/actions/runs/'+e.ci_run);
  assert.equal(e.observed_result,'success_on_exact_original_pr_head');
  assert.ok(Number.isInteger(e.artifact_id)&&e.artifact_id>0);
  assert.equal(e.independent_lake_check,'not_run');
  assert.equal(e.external_human_review,'none');
  assert.deepEqual(record.claim_gates,{
    original_history_enumeration:'exact_checker_passed_on_ci',
    derived_matrix_and_dual:'exact_checker_passed_on_ci',
    feasible_fence_independent_world_scan:'independent_exhaustive_passed_on_ci',
    lean_duality_soundness:'pinned_named_kernel_receipt_passed',
    exact_type:'pinned_named_kernel_receipt_passed',
    global_joint_minimax:'open'
  });
  assert.ok(record.limitations.some(s=>s.includes('physical-world history')));
  assert.ok(record.limitations.some(s=>s.includes('JSON')));
  assert.ok(record.limitations.some(s=>s.includes('review')));
  const workflow=read(WORKFLOW);
  assert.ok(workflow.includes('--contract '+CONTRACT));
  for (const n of record.lean.declarations) assert.ok(workflow.includes('--decl '+n));
  assert.ok(workflow.includes(CHECKER+' --self-test'));
  assert.ok(workflow.includes('node '+INDEPENDENT));
  if (replay) {
    assert.match(execute('python3',['-I',CHECKER,'--self-test']),/14 negative controls/);
    const result=JSON.parse(execute('python3',['-I',CHECKER,INPUT]));
    assert.equal(result.status,'PASS');
    assert.equal(result.optimal_cost,'4');
    assert.equal(result.source_sha256,record.original_semantic_model.source_sha256);
    assert.match(execute('node',[INDEPENDENT]),/8 mutation controls rejected/);
  }
  return true;
}

function selfTest(record) {
  const clone=x=>JSON.parse(JSON.stringify(x));
  const mutations=[
    r=>r.original_semantic_model.source_sha256='0'.repeat(64),
    r=>r.derived_instance.sha256='0'.repeat(64),
    r=>r.checker.git_blob_sha1='0'.repeat(40),
    r=>r.checker.independent_git_blob_sha1='0'.repeat(40),
    r=>r.lean.source_git_blob_sha1='0'.repeat(40),
    r=>r.lean.contract_git_blob_sha1='0'.repeat(40),
    r=>r.lean.declarations[0]='Nightfall.Fake.error',
    r=>r.complete_certification=true,
    r=>r.original_semantic_model.audited_completeness='physical_world_verified',
    r=>r.evidence.independent_lake_check='passed',
    r=>r.evidence.external_human_review='done',
    r=>r.proof_object.optimal_cost='3'
  ];
  for (const [i,mut] of mutations.entries()){
    const r=clone(record);mut(r);
    assert.throws(()=>verifyRecord(r,{replay:false}),undefined,'bad passport accepted '+i);
  }
  return mutations.length;
}

if (require.main===module) {
  const data=JSON.parse(read('docs/proof-object-passport.json'));
  const rec=data.records.find(x=>x.id==='permission-four-source-optimal-fence-v1');
  assert.ok(rec,'new optimal fence record not present');
  verifyRecord(rec);
  const n=selfTest(rec);
  console.log('PASS: Price of Permission model-bound primal+dual Proof Passport; '+n+
    ' forged metadata controls rejected (not a fresh Lean compilation or non-author review)');
}
module.exports={verifyRecord,selfTest};
