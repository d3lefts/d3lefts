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

## Continuation: actual product-increment bridge (2026-11-11 evening, US Eastern)

The original 23-declaration strict receipt (run 43149018301) remains intact and is a **passed historical checkpoint**. Additional sources were staged without modifying those exact proof blobs:

- `WrightFiniteIntervalRho.lean`: interval scaling; `sharp_rho_finite_interval` and `radius_abs_eq_max` passed strict Lean in run 43150495662, although that full workflow later failed on the product-fiber identity. `sharp_rho_finite_closed_interval` now includes degenerate fibers; its separate named receipt is checked by the updated workflow.
- `WrightProductFiberIdentity.lean`: `pincr_eq_fiber_pair_average` uses the **actual imported** product-space increment and the exact iid coordinate resampling identity. The fixed-universe and double-update corrections are in the branch. **Pending a successful named declaration receipt.**
- `WrightActualIncrementRho.lean`: `actual_pincr_le_rho_radius` consumes the two prior results with coordinatewise invariant fiber endpoints. **Pending strict compiler receipt.**
- `WrightTotalIncrementFromEnergy.lean`: `total_increment_of_pointwise_sensitivity` derives `2∑ pincr_j ≤ 4ρ d²` from an explicitly stated pointwise radius sensitivity bound and fiber endpoints. **Pending strict compiler receipt.** This does *not* prove the FHKL pointwise bound or construct canonical extremal fiber endpoints.
- Pin and same-source workflow: `.github/workflows/nightfall-wright-sharp-limit-lean.yml`. Most recent run to inspect: https://github.com/d3lefts/d3lefts/actions/runs/43153099818 (status must be checked, never inferred from this note).

**Formalization objective unchanged:** the full Wright manuscript theorem requires, in addition, a proof of the improved finite row cost `π²d²/2`, the strengthened median/certificate-to-influence bound for actual product functions, and the exact finite-to-measurable conditional-expectation passage on arbitrary completed product spaces. No combination of successful sharp-rho sublemmas is itself that theorem. Rejected intermediate compiler attempts are preserved in GitHub Actions; their `sorryAx` receipts are explicitly invalid and superseded by the passing versions, where applicable.

**Stop rule:** Do not claim the all-measurable theorem is end-to-end kernel-certified until a single declaration states only the original boundedness/product-law/degree hypotheses and the manuscript constant, with the exact source-checked Lean 4.33.0 receipt. Do not merge into main as a full theorem based on conditional bridge proofs.

### Verified continuation checkpoint

**Successful strictly checked run:** https://github.com/d3lefts/d3lefts/actions/runs/43152951697  
**Immutable receipt artifact:** https://github.com/d3lefts/d3lefts/actions/runs/43152951697/artifacts/13914677463

This run additionally compiled, with standard axiom allowlist only:
- `Nightfall.Wright.ProductFiber.update_twice`
- `Nightfall.Wright.ProductFiber.pincr_eq_fiber_pair_average`
- `Nightfall.Wright.ActualIncrement.actual_pincr_le_rho_radius`
- `Nightfall.Wright.FiniteInterval.sharp_rho_finite_closed_interval`

It constructed the direct `pincr` operator path from the pinned product source and sharp finite-marginal rho bound. The total increment `L(f)` with the pointwise sensitivity budget remains a **separate, later CI gate**, and neither the FHKL budget itself nor the stronger median/row inequalities nor the completed-measurable transfer are proved by these receipts. Earlier lines describing these direct `pincr` declarations as pending are superseded by this checkpoint.

## Final continuation receipt: sharp total increment composition (PASS)

**Run:** https://github.com/d3lefts/d3lefts/actions/runs/43153099818  
**Artifact:** https://github.com/d3lefts/d3lefts/actions/runs/43153099818/artifacts/13915325295  
**Compiler:** pinned Lean 4.33.0 and Turturean upstream `2a6ceaef872ae993708950f951989134084b851a`.  
**Status:** every strict step succeeded, including full imported Turturean finite-product chain and **32 named declarations** across the five scoped Lean modules plus the arithmetic/limit companion. All newly checked declarations had exactly standard axioms `Classical.choice`, `Quot.sound`, `propext`; no `sorryAx` survived.

New named theorem receipts:
- `Nightfall.Wright.ProductFiber.pincr_eq_fiber_pair_average` — actual product resampling equals conditional independent-fiber pair expectation.
- `Nightfall.Wright.ActualIncrement.actual_pincr_le_rho_radius` — the exact `pincr` is bounded by `rho=4-2 sqrt(3)` times product-average maximal fiber distance under explicit finite fiber endpoint hypotheses.
- `Nightfall.Wright.TotalIncrement.radius_energy_of_pointwise_budget` — from a pointwise `sum_j D_j(x)≤2d²` premise to the correct product-law average radius budget.
- `Nightfall.Wright.TotalIncrement.total_increment_of_radius_energy` and `total_increment_of_pointwise_sensitivity` — conditional Wright total increment bound, in manuscript's `L(f)=2 ∑_j pincr_j` normalization:
  `2 ∑_j pincr_j ≤ 4 (4-2 sqrt(3)) d²`.

**Proof-strength distinction:** The global increment theorem is **conditioned** on actual invariant bounding fiber endpoints and the crucial pointwise `2d²` sensitivity inequality. The original manuscript derives this via FHKL on binary restrictions, but that step and automatic construction of the optimal endpoints have **NOT** been kernel-certified. A conditionally valid Lean declaration is not the full unconditioned degree-d theorem.

**Remaining material work** before the manuscript's main theorem can be declared fully certified:
1. Formalize unrestricted finite-product sensitivity `∑D_i(x)≤2d²` from the actual bounded degree-d function, including zero-atom support reduction and the optimal fiber endpoint construction.
2. Formalize the stronger competing-symbol row cost `K≤π² d²/2` (prior pinned proof has `π²d²`).
3. Formalize the two-sided median / mixed third moment certificate bound needed for the stronger numerator `(8/5)^{3/2}` for actual f.
4. Formalize finite-to-arbitrary-completed-measurable-product approximation with actual commuting conditional expectations, degree preservation, influence contraction and maximal-coordinate attainment; abstract limit and attainment endpoints alone are insufficient.
5. Compile one genuine no-extra-assumptions named theorem with the precise manuscript constant and scope.

**No novelty, peer-review, manuscript-complete Lean, or external publication promotion is authorized.** The frozen repository certificate registry is untouched. These sources remain isolated under `research/formalization_candidates/wright/` in draft PR #404.


## Canonical finite fiber endpoints — strict receipt (2026-11-12 UTC)

**New exact checkpoint:** [Actions run 43156633571](https://github.com/d3lefts/d3lefts/actions/runs/43156633571), [immutable receipt 13915978479](https://github.com/d3lefts/d3lefts/actions/runs/43156633571/artifacts/13915978479), tested pull-request head `7ebc5989bac9116a60906773be2d9ab76460afa8`. The complete pinned workflow **PASSED**, now requesting 37 named declarations (32 historical plus five canonical-fiber declarations). Lean **4.33.0**, upstream `2a6ceaef872ae993708950f951989134084b851a`. The final module receipt reports source SHA-256 `859b924e70c1a24bff4b6ec89607346a13d91946bcfcde89d729d2e37c4492c7`; `check_receipts.py` accepted only `Classical.choice`, `Quot.sound`, `propext`, with no `sorryAx`.

**New five kernel-checked named declarations:**
- `Nightfall.Wright.CanonicalFiber.fiberLo_le`
- `Nightfall.Wright.CanonicalFiber.le_fiberHi`
- `Nightfall.Wright.CanonicalFiber.fiberLo_update`
- `Nightfall.Wright.CanonicalFiber.fiberHi_update`
- `Nightfall.Wright.CanonicalFiber.total_increment_of_canonical_sensitivity`

**Precisely certified mathematical advance:** for any finite common alphabet `α` with `Nonempty α`, and any actual finite-product `f : (ι → α) → ℝ`, canonical finite fiber minima/maxima are defined as finite infima/suprema of `f` on the coordinate fiber. Their bound and resampling-invariance hypotheses are proved outright. Consequently, the actual `pincr` satisfies
`2 ∑_j pincr p f j ≤ 4(4−2√3)d²`, assuming **only the still-open pointwise condition**
`∀x, ∑_j max(f(x)−min_b f(x[j←b]), max_b f(x[j←b])−f(x)) ≤ 2d²`
on the function side. No external endpoint data are assumed.

**Important remaining scientific scope:** This new declaration does **not** derive the pointwise FHKL sensitivity inequality from bounded Hoeffding degree `≤ d`. It is a genuine functional-premise theorem, not the full Wright theorem. Its canonical inf/sup range includes zero-mass alphabet symbols; for merely a.e.-bounded functions, support-restricted representatives or a proof of support reduction are still required. Also missing are the sharp `π²d²/2` actual row-cost inequality, the stronger mixed-median/certificate functional estimate, the construction/convergence of finite rectangular conditional expectations on arbitrary (including completed, uncountably indexed) measurable products, and single-declaration end-to-end composition.

**Certification classification:** a strict kernel-certified **conditional finite-product construction**; full arbitrary-measurable theorem **UNCERTIFIED**. Initial failed source attempts (a Lean type-inference error with detected `sorryAx`) are rejected and superseded by the passed exact-source receipt above. No novelty or external referee claim, and do not merge or announce a complete Wright certificate.
