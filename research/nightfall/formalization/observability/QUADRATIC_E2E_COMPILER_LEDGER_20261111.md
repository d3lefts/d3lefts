# NIGHTFALL quadratic arbitrary-law end-to-end Lean gate — compiler ledger v1

Date: 2026-11-11. Compiler: **Lean 4.35.0**, Mathlib **v4.35.0**, `scripts/lean_bridge.py --strict`, accepted axioms ONLY `propext`, `Classical.choice`, `Quot.sound`. The actual finite-product Efron–Stein decomposition and actual squared posterior decrement use the separately pinned Lean **4.33.0** / original Mathlib environment. Do **not** call this stack end-to-end compiled until the two pins and their imported statements are reconciled or independently rechecked in a common pin.

## Strictly certified new components (this PR)

1. **Entire finite matching-block even/odd selector product**: `Nightfall.Observability.QuadraticMatching.global_parity_identity`. No supplied conservation equality, includes all four side orientations and arbitrary dense cross-block terms. Full named certificate PASS at [43077842636](https://github.com/d3lefts/d3lefts/actions/runs/43077842636).
2. **Global (4B) matching rectangle mass for block polynomials**: `full_matched_rectangles_le_four` and `full_oriented_matching_le_four`. Pointwise-bounded even/odd experiments imply the result; no assumed cancellation. Exact strict certificate PASS at [43078601966](https://github.com/d3lefts/d3lefts/actions/runs/43078601966).
3. **Maximum-first weighted greedy matching**: `Nightfall.Observability.WeightedGreedy.exists_weighted_dominating_matching`. Fully constructs a matching and demonstrates every input edge touches an at-least-as-heavy selected edge. Exact strict certificate PASS at [43079392649](https://github.com/d3lefts/d3lefts/actions/runs/43079392649).
4. **Constructed endpoint cover and (8B) budget**: `Nightfall.Observability.WeightedGreedyCover.matching_endpoint_cover` and `matching_budget_to_endpoint_budget`. Nonnegative graph edge weights and matching-mass bound produce endpoint costs and full edge domination without an assumed cover. Exact strict certificate PASS at [43080368002](https://github.com/d3lefts/d3lefts/actions/runs/43080368002).

Every passing job audits its named declarations and source hashes, rejects `sorryAx`, and retains full receipts. Earlier failed compilation attempts are not successful certificates. The matching budget applies **only to the explicit block polynomial model**; the graph-cover theorem is stated for graph weights with matching bound as a hypothesis.

## Recovered existing certified inputs (separate PRs, do not misclassify)

- **Actual finite-product degree-two Hoeffding decomposition**: `quadratic_hoeffding_decomposition` / `QuadraticHoeffdingBridge.lean` (PR #325 and subsequent bridge, Lean 4.33).
- **Actual all-n finite independent Hilbert fourth moments**: `arbitrary_law_many_hilbert_fourth` (PR #364, strict Lean 4.35 run [43062171542](https://github.com/d3lefts/d3lefts/actions/runs/43062171542)).
- **Function-level global two-slot quadratic parity and 4B bound**: independent draft [PR #377](https://github.com/d3lefts/d3lefts/pull/377), its source and 4.35 gate must be audited on the exact head.
- **Actual scalar and finite-dimensional Hilbert squared-resampling posterior one-step deletion**: `scalar_actual_posterior_total_mean` / `vector_actual_posterior_total_mean` in PR #377's `RealSquaredPosteriorOneStep.lean`, pinned Lean 4.33 [43078715778](https://github.com/d3lefts/d3lefts/actions/runs/43078715778).
- **Quadratic 7B interpolation and certificate composition**: `QuadraticDiscoveryCore.lean` (PR #359), **only under explicit certificate hypotheses**.

## What remains unproved in Lean for the actual headline theorem

1. Construct the *same matching-block experiment* for an **arbitrary bounded, actual ANOVA-degree-2 function** on a finite heterogeneous product, including unmatched-coordinate padding and arbitrary leaf alphabets. Apply canonical coefficient degeneracy to choose and orient rectangles with `|Δ_{ij}|≥‖h_{ij}‖∞` and conclude `∀ matching P, ∑_{(i,j)∈P} ‖h_{ij}‖∞≤4B` for the actual `f`, not just a block-polynomial model.
2. Formalize the **actual bounded quadratic switching polynomial**, endpoint Markov inequality and `∑ E‖U_i‖ ≤ 8B` sections. Derive `∑‖h_i‖₂≤7B` for actual additive projections, not an assumed value table.
3. Derive **actual ANOVA orthogonal energies and resampling influences** with exactly matching variable definitions. Relate endpoint-assigned `h_{ij}(·,X_j)` to concrete independent Hilbert increments of the all-n kernel theorem. Prove interpolation and instantiate the conditional algebraic `quadratic_certificate_closure` to create a directly stated theorem `Var(f)^2 ≤ [15(1+√3)]²B² M` over real (f), normalized weights, `ESDegreeLE p f 2`, with no implicit source-function certificate hypotheses.
4. Reconcile **pinned Lean 4.33 and 4.35 imported modules**, then certify the actual finite-rank Hilbert Rademacher lift and a concrete measurable finite-query policy/budget. The current real posterior kernel gives one-step drift, **not** the full adaptive hard cap.
5. Infinite measurable products and non-author independent mathematical/priority review remain separate gates beyond the finite theorem.

## Status

**Certification grade:** independent finite matching, parity, endpoint-cover, Hilbert moment, and posterior subtheorems certified; **overall quadratic arbitrary-product influence and rank-optimal adaptive theorem are still analytically established and NOT kernel-verified end to end**. Maintain this distinction in publications and site Proof Passports. Do not add a global original-finding passport based only on scoped green jobs.
