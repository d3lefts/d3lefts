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
  assert.equal(inf.gates.package, 'pr_head_receipt_referenced');
  assert.equal(inf.gates.build, 'pr_head_receipt_referenced');
  assert.equal(inf.gates.inclusion, 'open');
  assert.equal(inf.gates.axioms, 'open');
  assert.ok(inf.dependencies.includes('q2-finite-current'));
  assert.ok(inf.remaining_obligations.length >= 3);
  const f9 = lookup['f9-adaptive-pr-head'];
  assert.equal(f9.passport_id, null);
  assert.equal(f9.evidence.pr, 690);
  assert.equal(f9.gates.inclusion, 'open');
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
  const premature = clone(overlay);
  premature.records[1].gates.inclusion = 'receipt_referenced';
  assert.throws(() => verify(premature, registry, receipts, frontier, contract));
  console.log('PASS: Lean five-gate Proof Passport overlay, source custody and three negative tests. No kernel compilation claimed.');
}
if (require.main === module) main();
module.exports = {verify};
