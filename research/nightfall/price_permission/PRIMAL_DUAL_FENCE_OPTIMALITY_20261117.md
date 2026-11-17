# Price of Permission — exact source-derived semantic-fence optimum

**Research checkpoint:** 2026-11-17  
**Status:** Exact synthetic finite-model construction. Two independent executable checkers and the general rational weak-duality/matching-optimality Lean theorem have passed pinned source-exact CI on [PR #783](https://github.com/d3lefts/d3lefts/pull/783), run [44177927091](https://github.com/d3lefts/d3lefts/actions/runs/44177927091). This document is *not* a claim of general joint sensing-policy optimality, exhaustive real-world change coverage, physical atomicity, scientific novelty, or non-author independent review.

## Original model (before LP construction)

There are four binary versioned sources `0..3`. The coherent certified-safe baseline state has world ID `0`, and the only unsafe final states within this **complete synthetic bitcube specification** are world IDs `3,6,12` (all remaining states are declared safe). A permitted single-epoch baseline-to-final history records all source indices whose bits differ. The version-only effect-time guard checks selected source versions; an unsafe effect is blocked if and only if at least one checked version has changed. Costs are exact: `c=(3,2,2,3)`.

The original semantic specification is stored in `semantic_fence_optimality_4source.json:source_model`. The exact checker **reconstructs** all unsafe history change supports by enumerating the 16 possible final states, rather than reading submitted incidence rows.

Under the declared semantics, the unsafe-history hyperedges are

\[
D_1=\{0,1\},\quad D_2=\{1,2\},\quad D_3=\{2,3\}.
\]

For each history, a valid fence must check at least one changed source. Introducing Boolean `x_i=1` when source `i` is checked gives the exact restricted optimization problem

\[
\min 3x_0+2x_1+2x_2+3x_3
\quad\text{subject to}\quad
x_0+x_1\ge1,\;x_1+x_2\ge1,\;x_2+x_3\ge1,
\quad x_i\in\{0,1\}.
\]

## Matching independently checkable certificates

**Feasible construction:** `x=(0,1,1,0)`, with all three covering constraints satisfied and cost `2+2=4`.

**Dual proof object:** `y=(2,0,2)`, nonnegative and satisfying `A^T y\le c`. Its per-source loads are `(2,2,2,2)`, bounded by `(3,2,2,3)`. Therefore every nonnegative fractional cover costs at least `sum(y)=4`. The feasible binary fence costs exactly 4. This is a genuine zero-integrality-gap **instance**, not an assertion that all weighted hitting-set LPs have zero integrality gap.

**Formal reusable theorem:** `PricePermissionFenceDual.lean` proves weak duality over arbitrary finite rational incidence matrices. Its second theorem proves optimality whenever a feasible covering vector and a nonnegative dual packing have matching objectives. Both exact theorem types are frozen in `semantic_fence_dual_type_contract.json` and compiled with source-exact Lean 4.36.0-rc2 and pinned Mathlib. This general implication is **not** itself a Lean evaluation of the specific JSON witness.

**Independent source-level audit:** `check_semantic_fence_independent.cjs` directly scans the original baseline-to-final states and all 16 possible version-check masks, *without consulting the LP matrix or dual*; it reaches the same optimum and runs independent mutation controls. `check_semantic_fence_primal_dual.py` uses exact `fractions.Fraction`, reconstructs the source-to-matrix encoding, checks both witnesses and their matching objectives, and rejects 14 deliberate mutations.

### Reproduce

```bash
python3 -I research/nightfall/price_permission/check_semantic_fence_primal_dual.py --self-test
python3 -I research/nightfall/price_permission/check_semantic_fence_primal_dual.py research/nightfall/price_permission/semantic_fence_optimality_4source.json
node research/nightfall/price_permission/check_semantic_fence_independent.cjs
node scripts/check_price_permission_optimality_passport.cjs
node scripts/check_proof_object_passport.cjs
```

A dedicated pinned Lean workflow is `.github/workflows/nightfall-price-permission-primal-dual-lean.yml`. It runs these actual-source checks, compiles the named Lean theorem declarations with their exact-type contract, checks allowed foundational axioms, and archives source SHA-256 receipts. The Proof Passport row is in `docs/proof-object-passport.json`. The historical original source-head receipt is run `44177927091`; if any source changes, its status must not be carried forward without revalidation.

## Scope boundaries and next mechanism

- The unsafe-world predicate and permitted history semantics are fully specified *for this synthetic bitcube*. Their adequacy for a physical or administrative institution is **not** established.
- The guard is an ideal atomic version checker with complete tracked source change, no bypass and no unsigned changes. No cloud or physical system is certified.
- This optimizes a **static version-only fence after coherent safe evidence**, not the joint sensing-policy Bellman objective from semantic-fencing-v0.3. Existing source-matched joint finite-model audits (including the 5/4 two-source example) remain separate.
- A general weighted hypergraph may have an LP integrality gap; an exact rational dual lower bound alone never certifies an integer optimum until a matching feasible integer solution is supplied.
- A lower-bound certificate is useful only if the encoding into the **actual source model** is correct and complete. Unsensed variables and missing unsafe histories remain serious failure modes.

**Next transfer:** extend model-bound primal+dual certificates to the dynamic Bellman evidence-acquisition tree. For an exact minimum-cost joint policy, require a verifiable *policy upper-bound tree* and a *state-by-state Bellman lower-bound invariant* on the same original source histories; do not infer it from the static dual witness.

**Method credit:** The checker-first, explicit proof-object approach was motivated by [Generalised Superintelligence](https://generalised.si/). Weighted hitting set, LP weak duality and finite rational certificates are classical; this checkpoint concerns source-bound integration and reproducibility, not novelty.
