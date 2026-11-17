'use strict';
/**
 * Independent operational audit of a finite bitcube version-only fence.
 * Does NOT read the LP matrix or trust its dual: enumerate every initial-safe
 * baseline, every declared final world and every possible version-check mask.
 * This certifies an exact finite *model*, not authentic physical histories.
 */
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const F = path.resolve(__dirname, 'semantic_fence_optimality_4source.json');

function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value !== null && typeof value === 'object')
    return Object.fromEntries(Object.keys(value).sort().map(k => [k, canonical(value[k])]));
  return value;
}
function digest(value) {
  return crypto.createHash('sha256').update(JSON.stringify(canonical(value))).digest('hex');
}
function verify(witness) {
  assert.equal(witness.schema, 'nightfall-price-permission-primal-dual/v1');
  const s = witness.source_model;
  assert.equal(s.kind, 'full-bitcube-semantic-fence/v1');
  assert.equal(s.history_policy, 'all-baseline-to-final-world-single-epoch');
  const n = s.num_sources;
  assert.ok(Number.isInteger(n) && n > 0 && n <= 12);
  assert.ok(Array.isArray(s.baseline_worlds) && s.baseline_worlds.length);
  assert.ok(Array.isArray(s.unsafe_worlds) && s.unsafe_worlds.length);
  assert.equal(s.version_check_costs.length, n);
  const maxworld = 2 ** n;
  for (const arr of [s.baseline_worlds, s.unsafe_worlds]) {
    assert.equal(new Set(arr).size, arr.length);
    for (const j of arr) assert.ok(Number.isInteger(j) && 0 <= j && j < maxworld);
  }
  const bad = new Set(s.unsafe_worlds);
  for (const base of s.baseline_worlds) assert.ok(!bad.has(base), 'baseline must be safe');
  assert.deepEqual(witness.certificate.source_sha256, digest(s));
  assert.deepEqual(witness.certificate.model_sha256, digest(witness.derived_instance));
  // Deliberately use independent exhaustive world-to-world semantics, not the
  // LP or Farkas code. This audit is source-matched, not a reproduction of GSI.
  const costs = s.version_check_costs.map(v => {
    assert.match(v, /^[1-9][0-9]*$/);
    return BigInt(v);
  });
  const allowed = [];
  for (let mask = 0; mask < 2 ** n; mask++) {
    let protectedEffect = true;
    for (const base of s.baseline_worlds) {
      for (let final = 0; final < maxworld; final++) {
        if (bad.has(final) && ((base ^ final) & mask) === 0) protectedEffect = false;
      }
    }
    if (protectedEffect) {
      let price = 0n;
      for (let i = 0; i < n; i++) if ((mask >> i) & 1) price += costs[i];
      allowed.push({mask, price});
    }
  }
  assert.ok(allowed.length > 0, 'no valid guard under declared semantics');
  const best = allowed.reduce((a,b) => a.price <= b.price ? a : b);
  const bits = witness.certificate.primal_fence;
  assert.equal(bits.length, n);
  assert.ok(bits.every(b => b === 0 || b === 1));
  const candidate = bits.reduce((v, b, i) => v | (b << i), 0);
  const feasible = allowed.find(x => x.mask === candidate);
  assert.ok(feasible, 'claimed guard misses source-derived unsafe history');
  assert.equal(feasible.price, best.price, 'guard is not source-model optimal');
  assert.match(witness.certificate.claimed_optimal_cost, /^(0|[1-9][0-9]*)$/);
  assert.equal(best.price, BigInt(witness.certificate.claimed_optimal_cost));
  return {status:'PASS',num_sources:n,number_of_final_worlds:maxworld,
    candidate_guard:bits.join(''),optimum:best.price.toString(),source_sha256:digest(s)};
}
function selfTest(witness) {
  const clone = x => JSON.parse(JSON.stringify(x));
  const variants = [
    x => x.certificate.primal_fence = [1,0,0,0],
    x => x.certificate.claimed_optimal_cost = '3',
    x => x.certificate.model_sha256 = '0'.repeat(64),
    x => x.source_model.unsafe_worlds.push(9),
    x => x.source_model.version_check_costs[1] = '3',
    x => x.source_model.baseline_worlds.push(3),
    x => x.source_model.history_policy = 'unbounded-write-paths',
    x => x.source_model.version_check_costs[0] = '1.25'
  ];
  variants.forEach((mutation, i) => {
    const changed=clone(witness);
    mutation(changed);
    assert.throws(()=>verify(changed), undefined, 'accepted forged source history or optimum ' + i);
  });
  return variants.length;
}
if (require.main === module) {
  const model = JSON.parse(fs.readFileSync(F,'utf8'));
  const result = verify(model);
  const n = selfTest(model);
  console.log('PASS: independent direct-source exhaustive guard scan, ' +
    result.number_of_final_worlds + ' possible final worlds and ' +
    2 ** result.num_sources + ' candidate fences; optimum=' + result.optimum +
    '; ' + n + ' mutation controls rejected');
}
module.exports = {verify,selfTest};
