# Proof Passport — Finite complex quantum circuit to product-source simulation

**Claim ID:** `quantum-product-bridge`  
**Snapshot:** 2026-11-19  
**Evidence tier:** PR-head / named Lean  
**PR:** https://github.com/d3lefts/d3lefts/pull/866  
**Exact PR source head:** `424c0a821e9458e0a39f00ea5f89e09d6f9de59f`  
**Named theorem:** `Nightfall.ProductSpace.QuantumCircuitSimulation.circuit_uniform_simulation`  
**Pinned CI run:** https://github.com/d3lefts/d3lefts/actions/runs/44460308357

## Formal claim and domain

For a T-query finite complex matrix-oracle circuit with indicator-linear input oracles and bounded Born acceptance, degree ≤2T is derived and product-source classical simulation follows when 384√2π⁶T⁶ ≤ n ε³δ²√δ.

**Feasible set / hypotheses.** Finite dimensional matrix-oracle model, T≥1, bounded acceptance on inputs; fixed matrices are general, and Born [0,1] is an explicit terminal hypothesis unless normalization is composed.

## Representation and mechanism

Path expansion of query matrices, squared-amplitude polynomial degree ≤2T and product simulator composition.

## Certificate and current validation

Exact-source pinned Lean run 44460308357 reported PASS on PR #866 head; PR remains unmerged/draft on a stacked branch.

**Checker/replay.** Inspect pinned named-declaration workflow https://github.com/d3lefts/d3lefts/actions/runs/44460308357, exact theorem type, imported axioms and source hash; this passport is an evidence index, not an independent rerun.

## Boundary, novelty and review

Do not infer arbitrary quantum oracle conventions, efficient classical runtime, or merged-main certification.

**Attribution / prior art.** NIGHTFALL query-degree formalization; standard polynomial-method antecedents and product simulator acknowledged.

**Audit status.** No independent human mathematical referee sign-off or novelty priority clearance asserted by this passport.

## Cheapest decisive next step

Reconcile normalized circuit imports and merge only after independent proof-scope audit.

## Provenance and version policy

- Source: https://github.com/d3lefts/d3lefts/pull/866
- Source-head custody: `424c0a821e9458e0a39f00ea5f89e09d6f9de59f`
- If theorem statement, input distribution, source bytes, toolchain or dependency changes, revalidate this passport; do not silently promote evidence tiers.
- No independent exact/interval checker was executed by this website-update operation. The source PR's cited evidence remains authoritative within its stated scope.
