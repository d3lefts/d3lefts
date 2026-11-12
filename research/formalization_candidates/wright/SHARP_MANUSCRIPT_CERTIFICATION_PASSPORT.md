# Wright bias-free influence: stronger coefficient and arbitrary measurable products — certification passport

**Date:** 2026-11-11 (US Eastern; Actions receipts UTC 2026-11-12).  
**Research status:** **PARTIALLY KERNEL-CERTIFIED, FULL THEOREM NOT CERTIFIED**.  
**Owner:** NIGHTFALL / Devin J. Wright. AI-assisted formal development; no external referee, originality, arXiv publication or human sign-off.

## Objective and feasible set

Formalize Theorem 1.1 in `papers/finite-product-influence/Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v6.tex` at its *actual* strength:

Given an arbitrary family of probability spaces `(Omega_i,F_i,mu_i)` indexed by any set J, its completed or uncompleted independent product probability space, and a real strongly measurable f with |f|≤1 a.e., Hoeffding degree ≤d (integer d≥1), and V=Var(f)>0,

```
exists j in J,  influence(j) = max_i influence(i)
                      and influence(j) >= cprod * V^(5/2) / d^6,
cprod = (8/5)^(3/2) * sqrt(15) / [125 * (4-2*sqrt(3)) * pi^4].
```

No assumption of finite alphabets, a minimum atom size, countable J, or a canonical choice of conditional regular distributions is allowed. The finite version must genuinely use the same f and marginal laws throughout.

**Frozen strongest external source checked:** David Turturean's 2026 Boolean-cube proof and Lean formalization at `physical-superintelligence/aaronson-ambainis` commit `2a6ceaef872ae993708950f951989134084b851a`, Lean 4.33.0; FHKL pointwise sensitivity and Agarwal–Ben-David improved row bounds are imported literature, not established by the existing Turturean Lean proof.

## Reproducible successful compiler pass

**Run:** https://github.com/d3lefts/d3lefts/actions/runs/43149018301  
**Exact receipt:** https://github.com/d3lefts/d3lefts/actions/runs/43149018301/artifacts/13913405424  
**Workflow:** `.github/workflows/nightfall-wright-sharp-limit-lean.yml`  
**Upstream:** `2a6ceaef872ae993708950f951989134084b851a`  
**Compiler:** Lean 4.33.0, exact upstream Mathlib cache.  
**Axioms:** All 23 named theorems are checked against `Classical.choice`, `Quot.sound`, `propext`; strict checker excludes `sorryAx` and unlisted axioms.  
**Source Git blobs:**
- `WrightSharpLimitBridge.lean` — `ca00818e07600619544409a3b2f571e5be23dbcb`
- `WrightSharpResampling.lean` — `5e64a136669d8efff35faeb3a6c96b4a62aa3055`
- `WrightArbitraryIndexAttainment.lean` — `3b3a231b89b9181bf47caa539c5319b3c794b4be`

All three live outside the frozen `research/nightfall/**/*.lean` provenance census. This preserves historical exact-source receipts, and the new modules do not inherit a previous certificate.

## What the kernel now certifies

### A. Sharp finite-marginal resampling operator — UNCONDITIONAL in its finite scope

`Nightfall.Wright.SharpResampling.sharp_rho_all_finite_laws`:

For arbitrary finite alphabet α, any nonnegative normalized law p (zero atoms allowed), and any `a : α → ℝ` with `-1/2≤a_i≤1/2`,

```
∑_i ∑_j p_i p_j |a_i-a_j|
  ≤ (4-2 sqrt(3)) ∑_i p_i (1/2+|a_i|).
```

The proof uses the *pointwise* inequality
`|a-b|+2(|a||b|+ab)≤|a|+|b|`, then finite product sum factorization. The stronger intermediate theorem `iid_absolute_difference_bound` includes the nonnegative mean-square correction

```
E|A-A'| + 2 (E|A|)^2 + 2 (EA)^2 ≤ 2 E|A|.
```

The exact three-atom extremizer's masses and equality are checked as separate algebraic theorems `extremal_mass_nonnegative`, `extremal_center_positive`, and `rho_three_atom_equality`. They have not been connected to one concrete Fin 3 probability table by a separate full theorem, so label the sharpness witness **exact algebra**, not a theorem about all measured three-atom spaces.

### B. The arbitrary-index maximum-attainment theorem — UNCONDITIONAL given energy cap

`Nightfall.Wright.ArbitraryIndex.arbitrary_index_maximum_attained`:

For any index type J (including uncountable), any `I : J→ℝ`, any real C satisfying `∀finite S, ∑_{i∈S} I_i≤C`, and one coordinate `j0` with `I_j0>0`, there exists j with `∀i, I_i≤I_j`.

The proof shows that every positive superlevel set of influences is finite, and takes a maximum on it. The finite Efron–Stein inequality `∑_{i∈S}I_i≤dV` still must be instantiated from the actual arbitrary-product f and measure.

### C. Passing finite variance bounds to a limit — UNCONDITIONAL given convergence and stage bounds

`finite_witnesses_pass_to_limit` accepts a variance-approximation sequence `v_n→V`, stage witnesses with a uniform coordinate influence majorant M, and concludes the exact fifth-power inequality. It does **not** construct `v_n=Var(E[f|G_n])` or prove `I_i(E[f|G_n])≤I_i(f)`.

### D. Exact stronger-coefficient algebra — CONDITIONAL

`sharp_constant_endpoint_of_analytic_inputs` proves the precise algebraic implication from:

- the upgraded certificate-to-influence principle, in squared form
  `15 (8/5)^3 V^5 ≤ (125 L K² M)²`;
- row cost `K≤π²d²/2`;
- total resampling increment `L≤4ρd²`;

to

```
15 (8/5)^3 V^5 ≤ (125 ρ π^4 d^6 M)^2.
```

Hence the manuscript constant `cprod` is algebraically correct **if the three functional inequalities are established**. This theorem does not prove these hypotheses for an arbitrary actual f. The `rho` finite marginal result supplies a genuine component of the third functional estimate.

## Missing gates — no false promotion

1. **Strong finite row bound**: prove from actual bounded degree-d input that every point admits the improved row `K≤π²d²/2`; the inherited Lean row bound gives only `π²d²`. This requires the stronger pointwise sensitivity / competing-symbol certificate argument and its exact polynomial theorem.
2. **Two-sided median improvement**: derive `(8/5)^(3/2) Var(f)^(3/2)≤6K² max_i L_i(f)` for actual f and actual conditional product law using the mixed third-moment estimate and localized weight removal. The numerical optimization alone is compiled.
3. **Product total-increment bound**: lift the now-compiled finite one-coordinate sharp-rho inequality through actual fibers and a proved pointwise `∑D_i(x)≤2d²` bound to establish `L(f)≤4ρd²` for actual f. Fiber integration / FHKL sensitivity bridge missing.
4. **Finite to completed arbitrary measurable product**: formalize finite rectangular conditional expectations in `L²`, their convergence, degree preservation, `D_i Q_n=Q_n D_i` and `I_i(Q_n f)≤I_i(f)`, including completion and arbitrary uncountable index families. The abstract inequality-limit step is compiled; the measure-theoretic construction is not.
5. **Single full named declaration and no-axiom strict receipt**: assemble all four and compile a proposition whose assumptions and conclusion are exactly the manuscript's, not a convenient stronger premised version. No such certificate exists today.

## Cheapest decisive experiment and independent attack

**Next decisive experiment:** formalize the actual finite-alphabet fiber lift of `sharp_rho_all_finite_laws`, then connect it to the pointwise derivative/sensitivity bound to certify `L(f)≤4ρd²`. This is the closest full functional inequality to a compiled proof. If the sensitivity bound cannot be obtained in the pinned upstream environment without importing an unproved external theorem, record that as an explicit dependency and switch to median/row mechanisms.

Independent reviewer should verify normalizations (resampling versus flip), degree-vs-alphabet representation, selected extrema and zero-mass fibers, the exact `ρ` witness, `L²` conditional projection commutation, arbitrary-index coordinate selection, and prior art. A passing computation is NOT an independent specialist referee.

## Scope and scientific status

**Certified this pass:** 23 named theorems (sharp finite-law resampling, exact arithmetic, limit and index attainment).  
**Already certified separately:** weaker-constant finite heterogeneous-product influence endpoint (PR #401 and its pinned receipts).  
**Not certified:** full analytic sharp finite theorem, arbitrary measurable product theorem, dimension-free quantum corollaries, or international originality.  

No publication, submission, or main-branch merger is authorized by these certificates alone.
