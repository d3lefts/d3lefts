# Chapter 2 against Turturean — dated scope comparison

**Date:** 12 November 2026. **Status:** direct theorem-statement comparison, two reduction checks, priority hazards; **not** an exhaustive novelty audit or external referee report.

## 1. Exact theorem scopes and normalization

Turturean, [arXiv:2611.09773v1](https://arxiv.org/html/2611.09773v1), Theorem 1.1, works on the **uniform binary cube**, `f:{−1,1}^n→[−1,1]` of Fourier degree `≤d≥1`. With his flip influence `Inf_i(f)=E[((f(X)−f(X^i))/2)^2]`, he proves

```text
max_i Inf_i(f) >= [sqrt(15)/(500*pi^4)] * Var(f)^(5/2) / d^6.
```

For uniform fair bits, this `Inf_i` equals the conditional resampling variance `I_i=E[(f−E_i f)^2]`. The earlier Aaronson–Ambainis convention `E[(f−f^i)^2]` is **four times** this influence. Compare theorems only after adjusting this normalization and scaling `B`.

The NIGHTFALL v9.2 **claim** (source [internal review](../../../papers/finite-product-influence/V9_2_INTERNAL_REVIEW_20261112.md)) for arbitrary independent product laws and arbitrary alphabets (categorical to nonatomic), real `|f|≤B`, and Hoeffding degree `≤2`, is

```text
V^2 <= C2 * B^2 * M,
V=Var(f), M=sup_i I_i,
C2=(10+2*sqrt(2))^2*(1+sqrt(3))^2 ≈ 1228.356323837.
```

Thus `M ≥ V²/(C2 B²)`. For the **common** Boolean-cube `d=2` special case, Turturean scaled to bound `B>0` only implies `M≥c_T V^(5/2)/(64 B³)`; with `0<V≤B²` the proposed v9.2 estimate is stronger by the factor `64 B/(c_T C2 sqrt(V))` (at least about 655). The v9.2 rate has variance exponent **2**, rather than **5/2**; exponent 2 is also sharp in the family `m^(−1)Σ_{k≤m} Z_{2k−1}Z_{2k}`, whose variance is `1/m` and maximum resampling influence is `1/m²`.

**Do not infer novelty from this comparison.** Turturean's §9.2/§9.5 discussions leave the exponent-two problem open in his **general** degree setting. Special quadratic cases and prior bilinear theory can already have exponent two; the binary case has a stronger classical Grothendieck-type coefficient in NIGHTFALL's own v8 comparison.

## 2. The prior-art gap is narrower than "biased product"

Girish, Mittal, Nehoran and Raz, [arXiv:2609.35327](https://arxiv.org/abs/2609.35327) (28 September), prove the *qualitative polynomial influence conjecture* for `Bernoulli(p)^{⊗n}` at each **fixed common** `p∈(0,1)` is equivalent to the uniform-cube form; also variants for uniform slices. This seriously limits any “biased-product extension is new” claim. Their abstract does **not** state the v9.2 exponent-two quantitative bound uniform over heterogeneous marginal laws and all alphabets. A source-to-source comparison of their actual reductions is still needed to exclude indirect quantitative derivations.

Additional named priority attack targets:

- Dinur–Friedgut–Kindler–O'Donnell (DFKO), Fourier tails/junta dichotomy, especially fixed-degree consequences;
- real Grothendieck, Littlewood mixed norm, categorical/one-hot bilinear forms, decoupling and bounded U-statistics;
- Escudero Gutiérrez, [arXiv:2304.06713](https://arxiv.org/abs/2304.06713), Fourier completely bounded polynomials (exponent-two in a restricted model);
- O'Donnell–Saks–Schramm–Servedio decision-tree influence and older query-theoretic adaptivity.

## 3. Reduction attacks performed at the representation level

**(A) Fair-bit encoding may lose degree.** If a biased Boolean coordinate `X` is encoded as an AND of `m` independent fair bits (bias `2^(−m)`), the original one-coordinate function `f(X)=X` has Hoeffding degree 1, whereas the encoded function has Fourier degree `m`. Inserting it into Turturean incurs a `d^6=m^6` loss. This blocks a **naive encoding**, not arbitrary reductions.

**(B) Two-sample selector preserves degree but the maximum fails to commute with expectation.** Draw independent `X_i,Y_i~μ_i`; for fair selectors `s_i∈{0,1}` set `g_{X,Y}(s)=f(X_i` when `s_i=0`, else `Y_i)`. For fixed `X,Y`, `g` has uniform-cube Fourier degree `≤2`, and its conditional average influence obeys `E_{X,Y} I_i(g)=I_i(f)/2`. However Turturean supplies a lower bound for `max_i I_i(g)` **for each** `X,Y`, while `E max_i I_i(g) ≥ max_i E I_i(g)`. One cannot infer a lower bound for `max_i I_i(f)` by reversing this inequality. Again this rejects only a specific straightforward reduction.

These observations do not rule out a short categorical Grothendieck or one-hot reduction, and so are not a novelty certificate.

## 4. What Chapter 3 contributes independently in scope, not in proof dependency

Turturean's result is a scalar influence inequality, not a rank-sensitive Hilbert-output adaptive coordinate-observation theorem. NIGHTFALL's [Theorem D manuscript](../2026-11-quadratic-rank-optimal/UNIVERSAL_THEOREM.md) claims a deterministic measurable policy, conditional on knowing the model and product law, with hard cap `ceil(20172*r*B²/η)` and risk `≤τ_r+η`. The v9.2 internal proof proposes a tighter `ceil(12*C2*r*B²/η)`. An additive-sign family proves a `Ω(r/η)` lower order, while the address function `f(K,Z)=Z_K` is exactly observed after two adaptive coordinate queries but requires unboundedly many nonadaptive queries at fixed error.

**Critical:** Theorem D's upper bound USES the scalar quadratic influence inequality. Independence of **historical priority** is not independence of **mathematical proof dependence**.

## 5. Lean/readiness evidence checked in GitHub main

- The [finite all-degree product transfer](../../../papers/finite-product-influence/README.md) has a pinned compiled Lean theorem importing Turturean and inheriting the `(5/2,6)` rate. It does **not** compile the degree-two exponent-two target.
- The [11 November E2E status](../formalization/observability/QUADRATIC_E2E_CERTIFICATION_STATUS.md) explicitly lists missing actual matching, ownership, ANOVA, and source-to-posterior edges; several strong finite moment lemmas are genuinely kernel-checked.
- [12 November #408 matching ledger](../formalization/product_space/ACTUAL_ES_PAIR_MATCHING_LEDGER_20261112.md) records eight strict compiled source-level Efron–Stein-pair/rectangle declarations and separately says the source-level **global parity/matching mass terminal theorem remains uncompiled**.
- v9.2's full original LaTeX source is absent from the publication directory. Internal review found a Corollary 6.2 reference/constant mismatch; the principal paper directory also lacks its full build/source archive.
- Non-author external proof review and worldwide priority are outstanding, even though finite tests and analytic arguments are substantive.

## 6. Dissertation consequence

Retain Chapter 2 as **the analytically unrefereed scalar engine** for Chapter 3, not as “the famous conjecture solved.” Lead with Theorem D, its exact lower examples and the adaptive-vs-fixed gap, which have a clearer original *scope* and mathematical narrative, subject to specialist priority review. Do not make a new theorem a precondition to writing; prioritize source custody and non-author proof review.

**Stop/promotion rule:** If a valid earlier categorical quadratic theorem subsumes v9.2, credit it and reduce Chapter 2 to a supporting lemma. If independent review invalidates the quadratic premise, demote Theorem D's dependent upper bound; retain correct explicit lower-bound examples and conditional statements. Never promote on finite stress tests or internal AI review.
