# NIGHTFALL v8 — CLOSED research campaign / preserved proof passport

**Campaign state:** CLOSED to new coefficient-optimization work, 2026-11-21 (US Central). **Mathematical status:** certified unconditional finite-product influence endpoint, plus separately certified scalar/mixed lemmas. **Integration state:** archival source branch, not merged into main. **No broader theorem/novelty/priority claim.**

## Immutable custody
- **Certified source commit:** `f4f8a59029a228a3174ee0e867678c7b2d1ac1e4`.
- **Retained source branch:** [`archive/nightfall-v8-certified-20261121`](https://github.com/d3lefts/d3lefts/tree/archive/nightfall-v8-certified-20261121). This is a frozen pointer at the certified git commit, separate from the PR branch.
- **Original research PR:** [#986](https://github.com/d3lefts/d3lefts/pull/986) (closed without merge as a completed research *campaign*; source preserved in archive branch). All historical CI failures and corrections remain in PR history.
- **Exact-head CI:** [GitHub Actions run 44984780267](https://github.com/d3lefts/d3lefts/actions/runs/44984780267), all four jobs `success`: `unconditional-four`, `product-mixed`, `median-scalar`, `moment346`.
- **Active compiler**: Lean `leanprover/lean4:v4.36.0-rc2`, Mathlib commit `9d581dfff2e41de989072ea63abf3daf69311520`. Source-dependent named declarations audited with only `Classical.choice`, `propext`, `Quot.sound`; mandatory `lake env leanchecker -v` passed. Not a human review.

## Verified construction and numerical gain
Use the existing certified finite-product influence theorem and original row `K≤π²d²`. The new canonical worst-replacement argument chooses one single-coordinate symbol per coordinate. Each replacement differs from the anchor in at most one coordinate; applying the existing unconditional `4d²` cube/block sensitivity supplies

`Σ_j radius_j(x) ≤ 4d²`

for every bounded finite-product degree-≤d function. Combine with the previously certified finite-law sharp-resampling ratio `ρ=4−2√3` to obtain

`2 Σ_j pincr_j(f) ≤ 8(4−2√3)d²`.

The composed named theorem is `Nightfall.Wright.UnconditionalFour.finite_product_influence_rho_four`, with source `research/nightfall/formalization/aa_v8/WrightV8FiniteFourEndpoint.lean`.

Compared with the old finite-product influence coefficient `√(3/12500)/π⁶`, the unconditional certified endpoint coefficient is

`√(3/12500) / [4(4−2√3)π⁴]`,

a multiplicative gain of `π²/[4(4−2√3)]≈4.60`. It improves a previously established **constant**, not the variance exponent or degree exponent.

## Proof files and artifacts
Archived at the exact commit under `research/nightfall/formalization/aa_v8/`:
- `WrightV8PointwiseFour.lean` — unconditional pointwise four-radius and actual total increment; [CI artifact 14738718770](https://github.com/d3lefts/d3lefts/actions/runs/44984780267/artifacts/14738718770).
- `WrightV8FiniteFourEndpoint.lean` — unconditional improved finite-product influence endpoint; same artifact.
- `WrightV8MixedFunctional.lean` and `WrightV8MixedWeightRemoval.lean` — actual finite-product weighted mixed crossing / moment bounds; [CI artifact 14738813592](https://github.com/d3lefts/d3lefts/actions/runs/44984780267/artifacts/14738813592).
- `WrightV8MedianMixed.lean` — scalar median inequalities; [CI artifact 14738763423](https://github.com/d3lefts/d3lefts/actions/runs/44984780267/artifacts/14738763423).
- `WrightV8Moment346.lean` — exact mixed `3,4,6` power interpolation; [CI artifact 14739133859](https://github.com/d3lefts/d3lefts/actions/runs/44984780267/artifacts/14739133859).
- `WrightV8RowConditional.lean` — conditional stronger row endpoint, explicitly **depends on an unproved sharper cube sensitivity hypothesis**; do not promote.
- `.github/workflows/nightfall-v8-sharp-bridges.yml` — exact-head compilation, named axiom audit and kernel-replay setup.
- The four GitHub Actions evidence archives contain detailed SHA-256 manifests. Artifacts can expire under Actions retention rules; the pinned source commit and this certificate index remain the durable reference.

## Exclusions, stop rule and transfer
**Not proved by v8:** unconditional sharp `2d²` cube sensitivity, unconditional `K≤π²d²/2` row, a fully composed stronger median endpoint, arbitrary infinite product index, prior-art novelty, or independent non-author verification. Unvalidated conditional modules remain conditional.

**Stop decision:** do not reopen constants polishing solely for sub-error coefficient gains. New mathematically substantive counterexamples, incorrect certificates or a general theorem may justify reopening with explicit new evidence; routine constant search does not.

**Next priority:** [draft PR #987](https://github.com/d3lefts/d3lefts/pull/987) explores density-aware Route 1 representations. Its Simon static-block result has a **task-independent resource mismatch:** the arbitrary score `κR(1+ln M)` has order `N` while classical hidden-shift queries have order `√N`. Prioritize *task-aware, transcript-adaptive, stopping-aware* representation certificates that can recognize an observed collision and stop once the hidden shift is known. The Simon score-`1/2` limit is only a property of a chosen metric, not a universal law.
