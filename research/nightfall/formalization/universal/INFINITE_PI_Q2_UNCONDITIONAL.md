# Unconditional infinite-product Q2 — original-source Lean terminal

**Status:** kernel-checked, source-matched Lean theorems at the pinned
environment (Lean 4.36.0-rc2, Mathlib `9d581dfff2e41de989072ea63abf3daf69311520`).
CI receipt: [run 44167592199](https://github.com/d3lefts/d3lefts/actions/runs/44167592199) at head `5b3a598aaf3b8887328dde2675e924a1cc8347e7`: full 118-module original-source closure compiled in dependency order; strict `lean_bridge.py` audit of 10 named declarations, all `allowlisted_dependencies`. Source SHA-256: `InfinitePiQ2CellAverage.lean` `7206bcf38006e1a87d2d50e71a391e9c3163243658ca039abf3036ce818d0740`, `InfinitePiQ2UnconditionalTerminal.lean` `75b73bc7989bfced714e99d8fe699cdd71a6c087da85ba2788a88a76ae5f62f2`.
Independent human statement review, priority and novelty are **open** and are
not implied by compilation.

## Main statement — almost-everywhere L² form

`Nightfall.InfinitePiQ2UnconditionalTerminal.infinitePi_q2_105416_ae`

Let `ι` be an index type in **any universe** (uncountable allowed), `X i`
arbitrary measurable spaces (any universe), `μ i` arbitrary probability
measures, `ν = Measure.infinitePi μ`. Let `G ∈ L²(ν)` be an `L²` class with

* `|G| ≤ B` **ν-almost everywhere**;
* **L² Efron–Stein degree ≤ 2** (`CellLabels.TripleResidualZero μ G`): for all
  pairwise distinct coordinates `i, j, k`,
  `R_i (R_j (R_k G)) = 0` in `L²`, where `R_i G = G − E_ν[G | all coordinates ≠ i]`
  is the genuine original-source residual (`sourceCoordinateResidual`);
* every genuine original influence `‖R_i G‖²₂ ≤ M`.

Then

  `Var_ν(G)² ≤ (2(1+√2)√3 + 11901/6250)² · B² · M`  (constant ≈ 105.4162).

No pointwise representative, everywhere bound, finite-information inequality,
influence oracle, density statement, countability, atom floor or
finite-alphabet condition is a hypothesis. `#print axioms` reports only
`propext`, `Classical.choice` and `Quot.sound`.

**Why this is the Efron–Stein condition.** If `G = Σ_{|S| ≤ 2} G_S` is an
`L²` Efron–Stein (ANOVA) decomposition, each `G_S` with `i ∉ S` is measurable
for the other-coordinates sigma algebra, so `R_i G_S = 0`; every component is
killed by one of three distinct residuals, so `TripleResidualZero` holds.
Conversely `R_i R_j R_k` keeps exactly the components with `S ⊇ {i, j, k}`.
This equivalence is standard but is **not itself formalized here**; the Lean
hypothesis is the operator statement above.

## Also proved

* `infinitePi_q2_105416_unconditional` / `_variance`: the pointwise form
  (bounded measurable `f`, `PointwiseDegreeTwo f`), now also for any universe.
* `infinitePi_q2_core`: the composition with the table-degree requirement
  isolated as a hypothesis on every finite label table.

## Proof architecture (one checked import graph)

1. **Finite-test approximation** (`InfinitePiQ2UnconditionalTerminal`):
   the existing `sourceFiniteCellAlgebra_L2_approx`, plus
   `cellAlgebra_determined` / `span_determined` / `testLabels`. Labels are
   indexed by `Fin n` through an injective `e : Fin n → ι`, so the finite model
   lives in `Type` for any universe of `ι`; cell masses come from Mathlib's
   `iIndepFun_infinitePi` and `iIndepFun.precomp`.
2. **Original-source cell tables** (`InfinitePiQ2CellAverage`): boundedness
   (`abs_avg_le`), influence contraction against the genuine `condExpL2`
   influence (`native_influence_le`, via the exact identity `heatBath_mass_eq`),
   variance comparison (`variance_gap_le`).
3. **Table degree two from the L² hypothesis**
   (`avg_nativeSupportedDegreeTwo_of_triple`). Split `G = E_i G + R_i G`. The
   table of `E_i G` ignores every positive letter at `i` (exact site/complement
   independence of `infinitePi`), so its triple difference vanishes
   (`delta_three_peel`). Peeling `i`, `j`, `k` in turn reduces the triple
   difference to the table of `R_k R_j R_i G = 0`.
4. **A.e. → everywhere bound.** A measurable representative clamped to
   `[−B, B]` has the same `L²` class, so the core applies to it.
5. **Finite theorem**: `native_heterogeneous_q2_105416_supported_unconditional`
   bounds every table; the empty-label case is direct.
6. **Limit**: `Var(G) ≤ Var(table) + ε ≤ √(K B² M) + ε` for every `ε > 0`.

## Scope and limits — read before citing

* **Degree definition.** The hypothesis is the triple-residual operator
  condition; its equivalence with a chosen textbook ANOVA formulation is
  argued above but not formalized.
* **Constant.** `≈105.4162` is inherited from the finite C105.416 module; the
  conditional 107/99 targets and the sharp-constant problem are unaffected.
* **Replay.** Per-module compile of the full 118-module closure plus a strict
  `#print axioms` audit; not yet `lake build` + `lake check` inside the
  integrated `Nightfall` Lake package.
* **Review.** Kernel acceptance validates proofs of these Lean statements
  only. Independent audit against the community's canonical Q2 formulation,
  priority (including Grothendieck/decoupling routes) and novelty remain open.
