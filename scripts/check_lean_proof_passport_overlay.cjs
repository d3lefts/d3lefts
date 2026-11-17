'use strict';
/**
 * Fail-closed metadata and Git-blob audit for the Lean-community five-gate
 * Proof Passport overlay. Does NOT execute Lean or authenticate remote CI.
 */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const load = p => JSON.parse(fs.readFileSync(path.join(root, p), 'utf8'));
function gitBlob(p) {
  const bytes = fs.readFileSync(path.join(root, p));
  return crypto.createHash('sha1').update('blob ' + bytes.length + '\0').update(bytes).digest('hex');
}
function verify(overlay, registry, receipts, frontier, contract) {
  assert.equal(overlay.schema, 'nightfall.lean-proof-passport-overlay.v1');
  assert.equal(overlay.version, 1);
  assert.equal(overlay.policy.compiler_lock, 'docs/lean-compiler-lock.json');
  const compilerLock = load(overlay.policy.compiler_lock);
  assert.equal(compilerLock.schema, 'nightfall-lean-compiler-lock/v1');
  assert.equal(compilerLock.toolchain, overlay.policy.lean_pin);
  assert.equal(compilerLock.mathlib_commit, overlay.policy.mathlib_commit);
  assert.deepEqual(compilerLock.allowed_axioms.slice().sort(), overlay.policy.allowed_axioms.slice().sort());
  assert.equal(overlay.policy.kernel_replay.ordinary, 'lake check');
  assert.equal(overlay.policy.kernel_replay.multiple_kernel, 'lake check --paranoid');
  const selected = overlay.policy.kernel_replay.selected_lake_receipt;
  assert.equal(selected.pr, 696);
  assert.equal(selected.run, 44027853225);
  assert.equal(selected.build, 'passed');
  assert.equal(selected.kernel_check, 'passed');
  assert.equal(selected.paranoid, 'not_run');
  assert.equal(selected.conditional_theorem_only, true);
  const extended = overlay.policy.kernel_replay.latest_extended_lake_receipt;
  assert.equal(extended.pr, 718);
  assert.equal(extended.head, '8e63401fcb1c40a37b9416e5413e7e96fc988307');
  assert.equal(extended.merge_commit, '836af9435cf1ef33b779ce91eafe917ce5f99edc');
  assert.equal(extended.run, 44120677824);
  assert.equal(extended.source_coverage, '107 selected Lean source modules');
  assert.equal(extended.build, 'passed');
  assert.equal(extended.kernel_check, 'passed');
  assert.equal(extended.paranoid, 'not_run');
  assert.equal(extended.conditional_theorem_only, true);
  assert.equal(overlay.policy.official_standard,
    'https://leanprover-community.github.io/did_you_prove_it.html');
  assert.deepEqual(overlay.policy.allowed_axioms.slice().sort(),
    receipts.pin.allowed_axioms.slice().sort());
  assert.equal(overlay.policy.lean_pin, receipts.pin.lean);
  assert.equal(overlay.policy.mathlib_commit, receipts.pin.mathlib_commit);
  assert.equal(contract.workspace_commit, overlay.policy.mathlib_commit);
  assert.equal(registry.schema, 'nightfall-active-proof-passports-v1');
  assert.equal(registry.lean_community_gate_overlay, 'docs/lean-proof-passport-overlay.json');
  assert.equal(registry.current_named_lean_receipts,
    'docs/current-lean-proof-receipts-20261116.json');
  assert.equal(frontier.best_unrestricted_source_q2_certified,
    'q2-unrestricted-105-416');
  assert.equal(overlay.records.length, 4);
  assert.equal(new Set(overlay.records.map(x => x.id)).size, overlay.records.length);
  const lookup = Object.fromEntries(overlay.records.map(x => [x.id, x]));
  assert.deepEqual(Object.keys(lookup).sort(),
    ['q2-finite-current', 'q2-infinite-integration',
      'f9-adaptive-pr-head', 'commonwealth-abstract-authority'].sort());
  for (const entry of overlay.records) {
    assert.ok(['main', 'pr-head'].includes(entry.source_location), entry.id);
    assert.equal(entry.complete_certification, false,
      entry.id + ': improperly promoted');
    assert.equal(entry.statement_equivalence_independently_reviewed, false, entry.id);
    assert.equal(entry.novelty_reviewed, false, entry.id);
    assert.ok(entry.kernel_replay && typeof entry.kernel_replay.status === 'string', entry.id);
    assert.ok(['not_in_this_passport_receipt', 'lake_check_receipt_referenced'].includes(entry.kernel_replay.status),
      entry.id + ': no manufactured kernel replay result permitted');
    assert.ok(entry.kernel_replay.review.includes('do_not_'), entry.id);
    assert.equal(entry.real_world_authority_verified, false, entry.id);
    assert.ok(entry.limitations.length > 40, entry.id);
    assert.deepEqual(Object.keys(entry.gates).sort(),
      ['axioms', 'build', 'inclusion', 'package', 'statement'].sort(), entry.id);
    for (const [gate, status] of Object.entries(entry.gates)) {
      assert.ok(['receipt_referenced', 'pr_head_receipt_referenced',
        'open', 'human_review_pending'].includes(status), entry.id + ': ' + gate);
    }
    assert.equal(entry.gates.statement, 'human_review_pending', entry.id);
    if (entry.source_location === 'main') {
      assert.ok(entry.source_path && entry.git_blob_sha1 &&
        entry.theorem_declaration, entry.id);
      assert.ok(!entry.source_path.startsWith('/') &&
        !entry.source_path.split('/').includes('..'), entry.id);
      assert.equal(gitBlob(entry.source_path), entry.git_blob_sha1,
        entry.id + ': source invalidated');
      const src = fs.readFileSync(path.join(root, entry.source_path), 'utf8');
      const name = entry.theorem_declaration.split('.').at(-1);
      assert.match(src, new RegExp('\\btheorem\\s+' + name + '\\b'),
        entry.id + ': declaration renamed');
    } else {
      assert.equal(entry.git_blob_sha1, null,
        entry.id + ': PR-only blob wrongly treated as merged');
      assert.equal(entry.source_path, null,
        entry.id + ': PR-only source presumed merged');
      assert.equal(entry.gates.inclusion, 'open', entry.id);
    }
  }
  const q = lookup['q2-finite-current'];
  const primary = receipts.current_unrestricted_degree_two;
  const active = registry.current_named_certificate_scope.finite_q2.strongest_merged;
  const f = frontier.claims.find(c => c.id === 'q2-unrestricted-105-416');
  assert.equal(q.passport_id, 'q2-influence');
  assert.ok(registry.claims.some(c => c.id === q.passport_id));
  assert.equal(q.source_path, primary.source);
  assert.equal(q.source_path, f.source);
  assert.equal(q.git_blob_sha1, primary.source_git_blob_sha1);
  assert.equal(q.git_blob_sha1, active.source_git_blob);
  assert.equal(q.git_blob_sha1, f.source_git_blob);
  assert.equal(q.theorem_declaration, active.declaration);
  assert.equal(q.theorem_declaration, f.declaration);
  assert.equal(q.evidence.pr, primary.pr);
  assert.equal(q.evidence.pr, active.pr);
  assert.equal(q.evidence.ci_run, primary.receipt_run);
  assert.equal(q.evidence.ci_run, f.receipt.run);
  assert.equal(q.evidence.head, primary.original_head);
  assert.equal(q.evidence.head, f.receipt.head);
  for (const gate of ['package','build','inclusion','axioms'])
    assert.equal(q.gates[gate], 'receipt_referenced');
  const inf = lookup['q2-infinite-integration'];
  assert.equal(inf.passport_id, 'q2-influence');
  assert.equal(inf.evidence.pr, 696);
  assert.equal(inf.source_location, 'main');
  assert.equal(inf.source_path,
    'research/nightfall/formalization/universal/InfinitePiQ2Limit.lean');
  assert.equal(inf.theorem_declaration,
    'Nightfall.InfinitePiQ2Limit.source_q2_quadratic_limit');
  assert.equal(inf.evidence.ci_run, selected.run);
  assert.equal(inf.evidence.head, selected.head);
  assert.equal(inf.evidence.merge_sha, selected.merge_commit);
  assert.deepEqual(inf.current_extended_lake_receipt, extended);
  assert.ok(inf.remaining_obligations.some(x =>
    x.includes('named theorem') && x.includes('missing assumptions')));
  assert.ok(inf.limitations.includes('conditional'));
  for (const gate of ['package','build','inclusion','axioms'])
    assert.equal(inf.gates[gate], 'receipt_referenced');
  assert.equal(inf.kernel_replay.status, 'lake_check_receipt_referenced');
  assert.equal(inf.complete_certification, false);
  assert.ok(inf.dependencies.includes('q2-finite-current'));
  assert.ok(inf.remaining_obligations.length >= 3);
  const f9 = lookup['f9-adaptive-pr-head'];
  assert.equal(f9.passport_id, null);
  assert.equal(f9.evidence.pr, 690);
  assert.equal(f9.source_location, 'main');
  assert.equal(f9.source_path,
    'research/nightfall/formalization/finite_field/F9ActualAdaptiveTerminal.lean');
  assert.equal(f9.theorem_declaration,
    'Nightfall.FiniteField.F9ActualAdaptiveTerminal.actual_adaptive_transcript_injective');
  assert.equal(f9.gates.inclusion, 'receipt_referenced');
  assert.equal(f9.evidence.merge_sha, 'ba5e57cf36e21df8589df82308f9a8be0ecd23d0');
  assert.ok(f9.remaining_obligations.every(x =>
    !x.includes('before merge') && !x.includes('PR head needs')));
  assert.ok(f9.limitations.includes('on main'));
  assert.equal(f9.kernel_replay.status, 'not_in_this_passport_receipt');
  const cw = lookup['commonwealth-abstract-authority'];
  assert.equal(cw.source_path, contract.source);
  assert.equal(cw.contract_path,
    'projects/commonwealth-os/assurance/lean/passport-contract.json');
  assert.equal(cw.evidence.pr, 613);
  assert.equal(contract.promoted_full, false);
  assert.ok(contract.targets.some(x => x.declaration === cw.theorem_declaration));
  assert.equal(cw.gates.inclusion, 'receipt_referenced');
  assert.equal(cw.passport_id, null);
  return true;
}
function main() {
  const overlay = load('docs/lean-proof-passport-overlay.json');
  const registry = load('docs/active-proof-passport.json');
  const receipts = load('docs/current-lean-proof-receipts-20261116.json');
  const frontier = load('research/catalogue/CURRENT_FRONTIER.json');
  const contract = load('projects/commonwealth-os/assurance/lean/passport-contract.json');
  verify(overlay, registry, receipts, frontier, contract);
  const clone = x => JSON.parse(JSON.stringify(x));
  const tampered = clone(overlay);
  tampered.records[0].git_blob_sha1 = '0'.repeat(40);
  assert.throws(() => verify(tampered, registry, receipts, frontier, contract),
    /source invalidated/);
  const promoted = clone(overlay);
  promoted.records[1].complete_certification = true;
  assert.throws(() => verify(promoted, registry, receipts, frontier, contract),
    /improperly promoted/);
  const falseParanoid = clone(overlay);
  falseParanoid.policy.kernel_replay.selected_lake_receipt.paranoid = 'passed';
  assert.throws(() => verify(falseParanoid, registry, receipts, frontier, contract));
  const falseExtended = clone(overlay);
  falseExtended.policy.kernel_replay.latest_extended_lake_receipt.kernel_check = 'pending';
  assert.throws(() => verify(falseExtended, registry, receipts, frontier, contract));
  const falseMergeF9 = clone(overlay);
  falseMergeF9.records[2].remaining_obligations.push('source PR head needs replay before merge');
  assert.throws(() => verify(falseMergeF9, registry, receipts, frontier, contract));
  const falseScope = clone(overlay);
  falseScope.records[1].theorem_declaration = 'Nightfall.InfinitePiQ2Limit.unconditional_q2';
  assert.throws(() => verify(falseScope, registry, receipts, frontier, contract));
  console.log('PASS: Lean five-gate Proof Passport overlay, source custody and six negative tests. No kernel compilation claimed.');
}
if (require.main === module) main();
module.exports = {verify};
