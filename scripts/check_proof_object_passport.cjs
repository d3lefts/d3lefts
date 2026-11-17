'use strict';
/**
 * Machine-check the new source-bound proof-object Proof Passport chain.
 *
 * This is a metadata/source-integrity auditor, NOT a Lean compiler, remote CI
 * attestation, independent external reviewer, or real-world completeness audit.
 * The exact-rational proof is replayed by its separately pinned Python checker.
 */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const child = require('node:child_process');
const assert = require('node:assert/strict');

const ROOT = path.resolve(__dirname, '..');
const MANIFEST = 'docs/proof-object-passport.json';
const FARKAS = 'nightfall-farkas-infeasibility/v1';
const SOURCE = 'papers/certifying-algorithms/two_source_fence.json';
const CHECKER = 'papers/certifying-algorithms/check_farkas.py';
const LEAN = 'papers/certifying-algorithms/lean/RationalFarkasCertificate.lean';
const CONTRACT = 'papers/certifying-algorithms/exact_type_contract.json';
const WORKFLOW = '.github/workflows/nightfall-gsi-farkas-certificate-lean.yml';

function file(rel) {
  assert.ok(typeof rel === 'string' && rel.length && !path.isAbsolute(rel), 'absolute/empty source path');
  const pieces = rel.split('/');
  assert.ok(!pieces.includes('..') && !pieces.includes('.') && pieces.every(Boolean), 'unsafe path');
  const full = path.resolve(ROOT, rel);
  assert.ok(full.startsWith(ROOT + path.sep), 'source outside repo');
  assert.ok(fs.statSync(full).isFile(), 'source not file: ' + rel);
  assert.ok(fs.realpathSync(full).startsWith(ROOT + path.sep), 'source symlink outside repo');
  return full;
}
const load = rel => JSON.parse(fs.readFileSync(file(rel), 'utf8'));
function gitBlob(rel) {
  const b = fs.readFileSync(file(rel));
  return crypto.createHash('sha1').update('blob ' + b.length + '\0').update(b).digest('hex');
}
function canonical(obj) {
  if (Array.isArray(obj)) return obj.map(canonical);
  if (obj && typeof obj === 'object')
    return Object.fromEntries(Object.keys(obj).sort().map(k => [k, canonical(obj[k])]));
  return obj;
}
function digest(obj) {
  return crypto.createHash('sha256').update(JSON.stringify(canonical(obj))).digest('hex');
}
function fullHex(s, n) { return typeof s === 'string' && new RegExp('^[0-9a-f]{' + n + '}$').test(s); }
function runPython(args) {
  const out = child.spawnSync('python3', ['-I', ...args], {
    cwd: ROOT, encoding: 'utf8', timeout: 30000, maxBuffer: 512 * 1024
  });
  assert.equal(out.status, 0, 'exact checker failed: ' + (out.stderr || out.stdout));
  return out.stdout;
}
function verify(passport, {replay=true}={}) {
  assert.equal(passport.schema, 'nightfall.proof-object-passport.v1');
  assert.equal(passport.version, 1);
  const policy = passport.policy;
  assert.equal(policy.no_automatic_promotion, true);
  assert.equal(policy.historical_claims_unchanged, true);
  assert.equal(policy.exact_checker_required, true);
  assert.equal(policy.negative_controls_required, true);
  assert.equal(policy.independent_reproduction_required_for_full_certification, true);
  assert.deepEqual(policy.required_chain, [
    'original_model', 'derived_instance', 'proof_object', 'exact_checker',
    'lean_type_contract', 'source_pinned_kernel_receipt'
  ]);
  assert.ok(policy.invalidation_rule.includes('authority version'));
  assert.ok(Array.isArray(passport.records) && passport.records.length >= 1);
  assert.equal(new Set(passport.records.map(x => x.id)).size, passport.records.length);
  const lock = load('docs/lean-compiler-lock.json');
  assert.equal(lock.schema, 'nightfall-lean-compiler-lock/v1');

  for (const r of passport.records) {
    assert.ok(typeof r.id === 'string' && r.id.length > 6);
    // Additional scientific proof-object families use their own exact,
    // source-derived validation. Keep the historical Farkas receipt immutable.
    if (r.proof_object?.format === 'nightfall-semantic-bellman-certificate/v1') {
      require('./check_bellman_policy_passport.cjs').verifyRecord(r, {replay});
      continue;
    }
    if (r.proof_object?.format === 'nightfall-price-permission-primal-dual/v1') {
      require('./check_price_permission_optimality_passport.cjs').verifyRecord(r, {replay});
      continue;
    }
    assert.equal(r.id, 'permission-two-source-farkas-v1', 'unknown proof-object family');
    assert.equal(r.status, 'source_matched_scoped_named_lean_receipt', r.id);
    assert.equal(r.complete_certification, false, r.id);
    assert.equal(r.original_semantic_model.audited_completeness, 'not_verified', r.id);
    assert.equal(r.original_semantic_model.path, SOURCE);
    assert.equal(r.original_semantic_model.embedded_key, 'source_model');
    assert.equal(r.derived_instance.embedded_key, 'model');
    assert.equal(r.derived_instance.reconstruction, 'from_unsafe_change_supports_and_budget');
    assert.equal(r.proof_object.embedded_key, 'certificate');
    assert.equal(r.proof_object.format, FARKAS);
    assert.equal(r.proof_object.mathematical_claim, 'exact_rational_linear_system_infeasible');
    assert.equal(r.checker.path, CHECKER);
    assert.deepEqual(r.checker.invocation, ['python3','-I',CHECKER,SOURCE]);
    assert.equal(r.checker.mutation_suite, '--self-test');
    assert.ok(r.checker.negative_control_count >= 11, 'mutation tests absent');
    assert.equal(r.lean.source, LEAN);
    assert.equal(r.lean.contract, CONTRACT);
    assert.equal(r.lean.compiler_lock, 'docs/lean-compiler-lock.json');
    assert.deepEqual([...r.lean.axioms].sort(), [...lock.allowed_axioms].sort());

    for (const [p, hash] of [
      [SOURCE, r.original_semantic_model.git_blob_sha1],
      [CHECKER, r.checker.git_blob_sha1],
      [LEAN, r.lean.source_git_blob_sha1],
      [CONTRACT, r.lean.contract_git_blob_sha1]
    ]) {
      assert.ok(fullHex(hash, 40), 'invalid Git blob digest');
      assert.equal(gitBlob(p), hash, 'source invalidated: ' + p);
    }
    const witness = load(SOURCE);
    assert.equal(witness.schema, FARKAS);
    assert.ok(witness.source_model && witness.model && witness.certificate, 'missing source/model/proof chain');
    assert.equal(witness.source_model.kind, 'weighted-hitting-set-budget/v1');
    assert.equal(r.original_semantic_model.source_sha256, witness.certificate.source_sha256);
    assert.equal(r.original_semantic_model.source_sha256, digest(witness.source_model), 'original model fingerprint mismatch');
    assert.equal(r.derived_instance.sha256, witness.certificate.model_sha256);
    assert.equal(r.derived_instance.sha256, digest(witness.model), 'derived matrix fingerprint mismatch');

    // Independent of the solver: reconstruct the structured *source* model, via
    // the separately reviewed exact rational verifier. Hashes alone cannot
    // establish that the encoding preserves every unsafe history.
    const contract = load(CONTRACT);
    assert.equal(contract.schema, 'nightfall-theorem-contract/v1');
    assert.equal(contract.source, LEAN);
    assert.deepEqual(contract.targets.map(t => t.declaration), r.lean.declarations);
    assert.equal(new Set(r.lean.declarations).size, r.lean.declarations.length);
    assert.equal(r.lean.declarations.length, 2);
    for (const t of contract.targets) {
      assert.ok(typeof t.expected_type === 'string' && t.expected_type.includes('ℚ'));
      assert.ok(t.expected_type.includes('Fin m') && t.expected_type.includes('Fin n'));
      const stem = t.declaration.split('.').at(-1);
      assert.match(fs.readFileSync(file(LEAN), 'utf8'), new RegExp('\\btheorem\\s+' + stem + '\\b'));
    }

    const e = r.evidence;
    assert.equal(e.pr, 775); // immutable audited historical example, not a dynamic remote CI fetch
    assert.equal(e.ci_run, 44171429696);
    assert.equal(e.exact_head, '9d96452c76fa7cb87a5ae204f71bb61b651fd21d');
    assert.equal(e.merge_commit, '530ad862208fd47dece70d63dbe9317f69ea5c80');
    assert.equal(e.source, 'https://github.com/d3lefts/d3lefts/actions/runs/' + e.ci_run);
    assert.ok(Number.isInteger(e.artifact_id) && e.artifact_id > 0);
    assert.equal(e.observed_result, 'success_on_exact_original_pr_head');
    assert.equal(e.independent_lake_check, 'not_run');
    assert.equal(e.external_human_review, 'none');
    assert.deepEqual(r.claim_gates, {
      source_model_to_matrix: 'exact_checker_passed_on_ci',
      matrix_to_proof_object: 'exact_checker_passed_on_ci',
      proof_object_to_formal_soundness: 'separate_named_lean_soundness_theorem',
      exact_type: 'pinned_named_kernel_receipt_passed',
      full_research_claim: 'open'
    });
    assert.ok(Array.isArray(r.limitations) && r.limitations.length >= 4);
    assert.ok(r.limitations.some(x => x.includes('Lean source theorems establish')));
    assert.ok(r.limitations.some(x => x.includes('not query GitHub')));

    const workflow = fs.readFileSync(file(WORKFLOW), 'utf8');
    assert.ok(workflow.includes('--contract ' + CONTRACT));
    assert.ok(workflow.includes('--decl ' + r.lean.declarations[0]));
    assert.ok(workflow.includes('--decl ' + r.lean.declarations[1]));
    assert.ok(workflow.includes(CHECKER + ' --self-test'));
    assert.ok(workflow.includes(CHECKER + ' ' + SOURCE));
    assert.ok(workflow.includes('scripts/lean_bridge.py'));

    if (replay) {
      assert.match(runPython([CHECKER,'--self-test']), /11 negative controls/);
      const result = JSON.parse(runPython([CHECKER, SOURCE]));
      assert.equal(result.status, 'PASS');
      assert.equal(result.source_bound, true);
      assert.equal(result.model_sha256, r.derived_instance.sha256);
      assert.equal(result.certificate_rhs, '-1');
    }
  }
  return {status:'PASS',records:passport.records.length,
    scope:'offline proof-object and provenance audit; historical CI reference, not kernel replay'};
}
function selfTest(original) {
  const clone = x => JSON.parse(JSON.stringify(x));
  const cases = [
    x => x.records[0].original_semantic_model.source_sha256 = '0'.repeat(64),
    x => x.records[0].derived_instance.sha256 = '0'.repeat(64),
    x => x.records[0].checker.git_blob_sha1 = '0'.repeat(40),
    x => x.records[0].lean.contract_git_blob_sha1 = '0'.repeat(40),
    x => x.records[0].lean.declarations[1] = 'Nightfall.Fake.sorry',
    x => x.records[0].status = 'kernel_closed',
    x => x.records[0].complete_certification = true,
    x => x.records[0].original_semantic_model.audited_completeness = 'verified',
    x => x.records[0].evidence.independent_lake_check = 'passed',
    x => x.records[0].evidence.external_human_review = 'complete',
    x => x.records[0].evidence.ci_run = 1,
    x => x.policy.no_automatic_promotion = false
  ];
  cases.forEach((mutation, i) => {
    const changed = clone(original);
    mutation(changed);
    assert.throws(() => verify(changed, {replay:false}), undefined,
      'accepted forged proof-object passport mutation ' + i);
  });
  return cases.length;
}
if (require.main === module) {
  const manifest = load(MANIFEST);
  const audit = verify(manifest);
  const count = selfTest(manifest);
  const optimum = manifest.records.find(r=>r.id==='permission-four-source-optimal-fence-v1');
  assert.ok(optimum, 'missing Price of Permission optimum record');
  const extra = require('./check_price_permission_optimality_passport.cjs').selfTest(optimum);
  const bellman = manifest.records.find(r=>r.id==='permission-two-source-bellman-policy-v1');
  assert.ok(bellman,'missing source-bound Bellman policy record');
  const policyNegative = require('./check_bellman_policy_passport.cjs').selfTest(bellman);
  console.log('PASS: ' + audit.records + ' original-model proof-object passports, ' +
    (count + extra + policyNegative) + ' independent metadata mutations rejected; original rational, Bellman, and operational checkers and exact Lean types linked.');
  console.log('STATUS: offline chain audit only; historical pinned Lean named receipt, not a fresh kernel replay.');
}
module.exports = { verify, selfTest };
