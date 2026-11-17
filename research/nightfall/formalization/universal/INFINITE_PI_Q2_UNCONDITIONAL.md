# Unconditional infinite-product Q2 — original-source Lean terminal

**Status:** kernel-checked, source-matched Lean theorem at the pinned
environment (Lean 4.36.0-rc2, Mathlib `9d581dfff2e41de989072ea63abf3daf69311520`).
CI receipt: [run 44151332468](https://github.com/d3lefts/d3lefts/actions/runs/44151332468) at head `578963636c36e51bc388b8f570847a3c0d8c2332`: full 118-module original-source closure compiled in dependency order; strict `lean_bridge.py` audit of 7 named declarations, all `allowlisted_dependencies`. Source SHA-256: `InfinitePiQ2CellAverage.lean` `be83afee11ebab65fa785403371a4d8ace8f4b68240639f0b3037e088848676a`, `InfinitePiQ2UnconditionalTerminal.lean` `c442d8ff2497a6cbfdd8d0ef2a45ede0de6163a13c64f44a0a70b35c2538ea55`.
Independent human statement review, priority and novelty are **open** and are
not implied by compilation.

## Statement

`Nightfall.InfinitePiQ2UnconditionalTerminal.infinitePi_q2_105416_unconditional_variance`

For any index type `ι : Type` (uncountable allowed), any measurable spaces
`X i` (any universe) and any probability measures `μ i`, let `ν = Measure.infinitePi μ`.
If `f : (∀ i, X i) → ℝ` is measurable, `|f x| ≤ B` for every `x`, every mixed
third coordinate difference of `f` vanishes at every point
(`PointwiseDegreeTwo f`), and every genuine original coordinate influence

  `sourceCoordinateInfluence μ i f = ‖f − E_ν[f | all coordinates ≠ i]‖²₂ ≤ M`,

then

  `Var_ν(f)² ≤ (2(1+√2)√3 + 11901/6250)² · B² · M`  (constant ≈ 105.4162).

`infinitePi_q2_105416_unconditional` is the same result stated for
`sourceL2Variance` of the `L²` class.

No finite-information inequality, influence oracle, density statement,
countability, atom floor or finite-alphabet condition is a hypothesis.
`#print axioms` reports only `propext`, `Classical.choice` and `Quot.sound`.

## Proof architecture (all in one checked import graph)

1. **Finite-test approximation** (`InfinitePiQ2UnconditionalTerminal`).
   The existing `sourceFiniteCellAlgebra_L2_approx` approximates `f` in `L²`
   by a finite combination of finite Boolean cells of coordinate rectangles.
   Each such combination is decided by finitely many measurable tests on
   finitely many coordinates (`cellAlgebra_determined`, `span_determined`),
   so it is constant on the cells of a finite label system (`testLabels`).
2. **Original-source cell-average tables** (`InfinitePiQ2CellAverage`).
   For finite measurable labels on finitely many original coordinates, the
   table `y ↦ (∫_{cell y} f dν)/ν(cell y)` satisfies:
   * `abs_avg_le`: bounded by `B`;
   * `avg_nativeSupportedDegreeTwo`: native supported degree two, via the
     anchored decomposition `f = A₁ + A₂ + A₃` (each `Aₛ` ignores one
     coordinate) and exact site/complement independence of `infinitePi`;
   * `native_influence_le`: each native table influence is at most the
     genuine `condExpL2` influence of `f`, via the exact identity
     `heatBath_mass_eq` (native one-site resampling of the table equals the
     cell integral of the original conditional expectation, for every word)
     and cellwise Cauchy–Schwarz;
   * `variance_gap_le`: `Var(f) − Var(table) ≤ ‖f − u‖²₂` for every `u`
     constant on cells.
3. **Finite theorem.** `native_heterogeneous_q2_105416_supported_unconditional`
   (existing original-source module) bounds every table; the empty-label case
   is handled directly (`cellAverage_q2_all`).
4. **Limit.** `Var(f) ≤ Var(table) + ε ≤ √(K B² M) + ε` for every `ε > 0`.

## Scope and limits — read before citing

* **Degree hypothesis.** `PointwiseDegreeTwo` asks every mixed third
  difference to vanish at *every* point. It is a pointwise structural
  condition, not the `L²`/a.e. Efron–Stein (ANOVA) degree ≤ 2 condition. Whether
  every bounded function of a.e. ANOVA degree ≤ 2 on an infinite product has
  an everywhere-degree-two representative is not established here; the a.e.
  formulation is a separate gate.
* **Boundedness** is required everywhere (`∀ x, |f x| ≤ B`), not only a.e.
* **Index universe.** `ι : Type` (universe 0) because the finite theorem's
  index and alphabet live in `Type`. Coordinate spaces are universe-polymorphic.
* **Constant.** `≈105.4162` is inherited from the finite C105.416 module; the
  conditional 107/99 targets and the open sharp-constant problem are unaffected.
* **Replay.** This is a per-module compile and `#print axioms` audit, not yet a
  `lake build` + `lake check` replay inside the integrated `Nightfall` Lake package.
* **Review.** Kernel acceptance validates proofs of these Lean statements only.
  Independent audit of the statement against the community's canonical Q2
  formulation, priority (including Grothendieck/decoupling routes) and novelty
  remain open.
