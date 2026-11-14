# Proof Passport v2 — Quadratic influence and rank-optimal adaptive observation

**Claim IDs:** active registry q2-influence, q2-observation; catalogue NF-PS-QUADRATIC-20261110 and NF-OBS-QUADRATIC-20261110.  
**Checkpoint:** 2026-11-14 current-scope update; 2026-11-12 manuscript history retained. **Status:** finite scalar source Q2 kernel-certified at 1064.958; Hilbert/adaptive and measure-theoretic extensions remain analytic; externally refereed and global priority gates open. This dossier updates the live scope without rewriting immutable v7/v8 source evidence.

## 14 November 2026 — current scoped proof status (supersedes the old finite-scalar status below)

**Finite original-source scalar Q2 is now STRICT LEAN-CERTIFIED** at coefficient
`C₂ = 407 + 138√2 + 188√3 + 56√6 ≈ 1064.958449026294`,
with no extra caller-supplied moment, matching or additive-budget hypothesis.
Merged [PR #494](https://github.com/d3lefts/d3lefts/pull/494) gives
`Nightfall.Observability.ActualSourceQ2CoupledUnconditional.actual_source_q2_coupled_unconditional`,
[successful current-head pinned Lean run 43627249467](https://github.com/d3lefts/d3lefts/actions/runs/43627249467).
The finite coordinate set has a **common finite alphabet**, but marginals may differ
and may have zero-weight atoms; degree ≤2 and |f|≤B are pointwise. The influence
is the original-source `E[(f−E_i f)²]` exactly.

The old manuscript coefficient `(10+2√2)²(1+√3)²≈1228.356` remains
historical, not the strongest presently certified value. The source-level
[SCIF PR #496](https://github.com/d3lefts/d3lefts/pull/496), [run 43630623548](https://github.com/d3lefts/d3lefts/actions/runs/43630623548),
adds independently verified finite pair recentering, pointwise Efron–Stein
degree preservation, canonical graph invariance and fixed-owner amplitude bounds
`1+min(2TV,1)` and `4` under two-endpoint recentering. Its complete
original-source *influence-delta* and generated-owner recertification bridges are
**not** terminally Lean-certified.

**Still open:** genuinely different finite alphabet types in the Q2 theorem,
the infinite/measurable product L² transfer, a jointly compiled rank-r Hilbert
adaptive-observation theorem, external human review and novelty. Source
receipt index: [current 14 November scoped Lean certificates](../../../docs/current-lean-proof-receipts-20261114.json).
Nothing in the revised scalar proof automatically upgrades an adaptive
query policy, physical observability, or operational authority.

### Historical manuscript checkpoint — 12 November 2026 (superseded finite-scalar status)

## Mathematical statements and exact model

For independent product coordinates with potentially heterogeneous and arbitrarily biased laws, a real function f bounded by |f|≤B, and Hoeffding degree at most two, let V=Var(f) and I_i=E[(f−E_i f)^2], M=sup_i I_i. NIGHTFALL v9.2 proposes

$$ V^2 \le C_2 B^2 M,\qquad C_2=(10+2\sqrt2)^2(1+\sqrt3)^2\approx1228.356323837. $$

A separate analytic rank-r output extension for Hilbert-valued F with ||F||≤B proposes V(F)^2≤3 C_2 r B^2 M(F) on an r-dimensional output space, and risk ≤τ_r+η after at most ⌈12 C_2 r B²/η⌉ **adaptive whole-input-coordinate** reads. This is **known-model observation**, not identification, physical quantum measurement or an efficient running-time theorem.

The older v7 bound V²≤225(1+√3)²B²M and Theorem D's conservatively rounded hard cap ⌈20172 r B²/η⌉ remain source-valid historical variants; the v9.2 manuscript is the latest proposed sharper coefficient, not a new Lean theorem. A finite rank-r additive-sign construction gives an Ω(r/η) order lower bound; an addressed sign family has exact two-read adaptive observation and unbounded alphabet-uniform fixed-query gap. Fixed-query Θ(rm/η) is a *separately scoped candidate* whose full categorical source archive is still incomplete.

## Proof dependency graph (do not infer missing arrows)

1. Actual bounded degree-two f → genuine Hoeffding pair components h_ij and centered conditional sections U_i.
2. Matched-pair rectangular orientation → globally coupled even/odd distributions → ∑matching ||h_ij||∞≤4B.
3. Greedy endpoint ownership ∑c_i≤8B; additive noise-interpolation projection and actual conditional switching give first-order and section budgets.
4. Independently centered Hilbert increments → fourth-moment bound and square-root interpolation → scalar V² bound.
5. Scalarization / Hilbert rank transfer with explicit pointwise output bound → rank-r influence; posterior product law, ANOVA potential descent, and hard stopping → adaptive risk.
6. Finite-coordinate proof → finite-cylinder/conditional expectation approximation for arbitrary measurable product factors (analytic passage, not Lean).
7. Theorem statement plus same-oracle dated prior art plus non-author attack → possible publication. Steps 1–6 do **not** establish step 7.

**Recent real scoped Lean closure:** PR #407 source-binds finite quadratic row/sections; PR #408's [actual Efron–Stein pair matching ledger](../formalization/product_space/ACTUAL_ES_PAIR_MATCHING_LEDGER_20261112.md) reports **eight named compiled declarations** for true ES components, coordinate centering, genuine pair kernels and oriented rectangles, with a strict pinned Lean 4.33.0 Actions [receipt 43167542367](https://github.com/d3lefts/d3lefts/actions/runs/43167542367) and source SHA-256 4d59e9bf872f89a3310b6c3a5203d9256e4b85bfab65cfc60c0a065bca0bffea. Earlier separately checked many-increment fourth-moment [receipt 43062171542](https://github.com/d3lefts/d3lefts/actions/runs/43062171542) is a genuine all-finite-n lemma under the literal table premises.

**Still missing a terminal Lean declaration:** construct global coupled parity **from the same actual source f** rather than assuming a polynomial/matching certificate; compose true weighted assignment, actual oscillation, centered increments and influence identity into the unconditional scalar exponent-two theorem. The rank transfer, all measurable products, posterior selection and hard stopping are also not jointly compiled. Different Lean 4.33/4.35 receipts do not constitute a single same-pin theorem. Recheck current-source provenance at [certificate index](../formalization/CERTIFICATE_INDEX.md).

## Strongest external comparators, priority risk

- David Turturean, [arXiv:2611.09773](https://arxiv.org/abs/2611.09773), claims an all-degree uniform Boolean-cube influence theorem with variance exponent **5/2** and degree denominator d^6; available Lean source is his. The v9.2 exponent **2** is quantitatively stronger at degree two, but this comparison cannot establish first discovery.
- Girish–Mittal–Nehoran–Raz, [arXiv:2609.35327](https://arxiv.org/abs/2609.35327), treat **fixed common** biased Bernoulli products; merely saying "biased product" is not a novelty test.
- Classical binary quadratic Grothendieck arguments already yield exponent two and a better numerical constant on binary inputs. Categorical/one-hot Grothendieck, Littlewood, Bohnenblust–Hille, DFKO and completely bounded polynomial comparisons remain unresolved. The v9.2 [internal review](../../../papers/finite-product-influence/V9_2_INTERNAL_REVIEW_20261112.md) flags an actual Corollary 6.2 reference/constant mismatch and missing exact LaTeX source.

The [dated detailed comparison](../2026-11-information-cost-dissertation/CHAPTER2_TURTUREAN_SCOPE_AUDIT_20261112.md) documents why naive fair-bit encoding can raise degree and why a two-sample selector does not commute with max influence. Those are **obstructions to two simple reductions**, not proof that a shorter or stronger reduction is impossible.

## Certificate, falsifiers and decisive next test

**Certificate available:** complete *written* scalar/rank analytic chains in the v8 sources, deposited v9.2 PDF and internal review, finite rational checker receipts, scoped Lean dependencies. **Unavailable:** v9.2 original exact TeX and reproducible source build; an independent non-author mathematical review; end-to-end Lean; worldwide priority adjudication.

**Adversarial falsifiers:** construct a degree-two bounded categorical f that violates V²≤C₂B²M; a rank-r vector model where spherical/finite-sign transfer loses the asserted r scaling; a posterior where the proposed greedy potential fails or needs inaccessible zero-measure selections; or a categorical bilinear theorem already implying all stated claims with an equal or stronger constant. Keep every such counterexample and demote descendants.

**Next cheapest decisive work:** deposit v9.2 source, fix Cor. 6.2, and have a non-author audit the actual matching parity-to-fourth-moment proof under zero-mass and nonuniform coordinates while a separate reviewer searches categorical Grothendieck prior art. Publishing or elevating status requires explicit owner authorization.

**Source graph:** [Theorem D](../2026-11-quadratic-rank-optimal/UNIVERSAL_THEOREM.md) → [v9.2 internal review](../../../papers/finite-product-influence/V9_2_INTERNAL_REVIEW_20261112.md) → [PR #408 ledger](../formalization/product_space/ACTUAL_ES_PAIR_MATCHING_LEDGER_20261112.md) → [main claim registry](../../catalogue/CLAIMS.json). Imported classical machinery receives full credit.

## Source-custody note — immutable v8 Proof Passport

The historical [v8 Proof Passport](../../../papers/finite-product-influence/V8_PROOF_PASSPORT.md) is hash-pinned inside the v8 source manifest and remains byte-for-byte unchanged. The later v9.2 narrative is in a separate [dated supplementary passport](../../../papers/finite-product-influence/V9_2_PASSPORT_SUPPLEMENT_20261112.md). Neither file itself constitutes new Lean or external referee certification.
