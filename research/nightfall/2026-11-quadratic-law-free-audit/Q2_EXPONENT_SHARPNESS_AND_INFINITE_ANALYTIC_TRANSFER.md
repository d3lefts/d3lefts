# NIGHTFALL Q2: exponent sharpness and finite-to-general-product transfer

> **PRIOR-ART RECOVERY / CORRECTION, 2026-11-15.** Our newly checked fair three-bit selector gives a valid coefficient lower bound K≥2, but this is **strictly superseded** by the ALREADY MERGED original-source biased mean-field witness from [PR #521](https://github.com/d3lefts/d3lefts/pull/521), which proves **K_opt≥4 analytically**. PR #521's Lean module certifies its scalar moment formulas and ratio, not the full original-source probability computations or infinite-n limit. The true current floor is K≥4 (analytic, exact symbolic finite checks), not 2. The n≤4 fair-Boolean enumeration is only a narrow regression test. Do not claim discovery or coefficient improvement for K≥2. This document preserves the valid small example and the more meaningful exponent-optimality/infinite-product transfer work.


**Version:** 2026-11-14 / v1.0. **Proof authority:** author-analytic derivations from exact original-source finite-Q2 theorem; **NOT** additional Lean certificates. **Author/research direction:** Devin J. Wright, AI-assisted derivation. **Independent non-author review:** not yet completed.

## 1. Source-certified starting point

The merged finite-product theorem `Nightfall.Observability.ActualSourceQ2364Terminal.actual_source_q2_364_unconditional` from PR [#525](https://github.com/d3lefts/d3lefts/pull/525) has passed strict source-specific Lean 4.36.0-rc2 check [run 43644790107](https://github.com/d3lefts/d3lefts/actions/runs/43644790107). It states for finite common alphabet, independent arbitrarily biased coordinate masses `p_i` including zero atoms, and globally bounded real `f` of pointwise Efron–Stein degree at most 2,

```
Var_p(f)^2 ≤ K ||f||_{∞,pointwise}^2 max_i I_i^p(f),
K = [5√3 + 2(1+√2)(√13−√3)+8√((5√5−11)/6)]².
```

A stronger **unmerged but strict PR-head Lean certified** coefficient `K≈353.2929930769` is available at PR [#549](https://github.com/d3lefts/d3lefts/pull/549), pinned job [43658874249](https://github.com/d3lefts/d3lefts/actions/runs/43658874249), named theorem `actual_source_q2_353_unconditional`. The arguments here work with any correctly certified finite `K`. For a main-branch-only derivation use the 364 coefficient.

### Conventions

`I_i(f)= E[(f-E_i f)^2]` where `E_i` integrates coordinate i with its original marginal while keeping all others fixed. This is the **resampling variance** definition, not a bit-flip probability, not twice this quantity.

## 2. Analytic Theorem A — the variance exponent two is optimal

For each `n≥1`, take n independent fair Rademacher signs `X_i∈{-1,+1}` and

```
f_n(x)= (1/n) Σ_{i=1}^n x_i.
```

Then f has Hoeffding degree one, `||f_n||∞=1`, `E f_n=0`. Independence and `E X_i X_j=δ_ij` imply

```
Var(f_n)= E f_n²= n/n²= 1/n.
E_i f_n= (1/n) Σ_{j≠i} X_j.
I_i(f_n)=E[(X_i/n)^2]=1/n².
max_i I_i(f_n)=Var(f_n)².
```

For every real `q<2`, a dimension-free assertion `max_i I_i(f)≥c Var(f)^q/||f||∞^{2q-2}` with universal `c>0` would give `c≤n^{q-2}` for all n and thus fail. Any valid constant in the variance-squared theorem must also satisfy `K≥1` (indeed equality for these witnesses). **This proves mathematical exponent optimality.** No Lean certificate is claimed for the family or its asymptotic limiting argument.


## 2A. Sharper exact universal coefficient floor K≥2

The degree-one family establishes exponent optimality but its coefficient floor K≥1 is superseded by a three-bit degree-two selector.

Let X₁,X₂,X₃ be independent uniform signs ±1 and define

\[
f(x_1,x_2,x_3)=\frac{x_1-x_3-x_1x_2-x_2x_3}{2}.
\]

When x₂=−1 this equals x₁, and when x₂=+1 this equals −x₃. Hence f takes values exactly ±1, so B=1, Ef=0 and V=Var(f)=1. The centered uniform Fourier/ANOVA support is {1}, {3}, {1,2}, {2,3}, each with squared coefficient 1/4; thus I₁=I₂=I₃=1/2. It follows exactly that

\[
V^2/(B^2\max_i I_i)=2,
\]

and **the best unrestricted universal Q2 coefficient is at least 2**. Any valid source upper coefficient, including C364 or the PR #549 strictly checked C353, is an upper bound; the current exact global optimum is not determined.

Independent exact exhaustive integer Walsh audit: check_q2_K2_fair_small.py, in this same folder, enumerates all Boolean-valued degree≤2 functions on n=1,2,3,4 fair bits. Numbers of such Boolean functions are 4,16,70,222. The exact maximum Var²/(B²M) within those finite classes is 1,9/8,2,2, respectively. This does NOT establish a universal upper bound K≤2 for arbitrary dimensions, real outputs, arbitrary alphabets, or biased measures. No Lean receipt is claimed for this exact 3-bit witness.

## 3. Analytic Theorem B — arbitrary-index, arbitrary-alphabet independent product extension

Let `I` be any (possibly uncountable) index set. For each `i∈I`, let `(Ω_i,Σ_i,μ_i)` be a nonempty probability space with an existing product measure `μ=⊗_{i∈I}μ_i` on the **ordinary product sigma-algebra**. No uniform bias, lower atom mass, discrete alphabet or identical-marginal condition is imposed.

Let `f:Π_i Ω_i→ℝ` be product-measurable and **pointwise bounded**, `|f(x)|≤B` for all x, with `B≥0`.

**Pointwise degree≤2 condition:** For any three distinct indices `i,j,k`, all configurations `x`, and all pairs of replacements `a_i,b_i∈Ω_i`, `a_j,b_j∈Ω_j`, `a_k,b_k∈Ω_k`, the eight-term alternating mixed difference
```
Δ_i^{a_i,b_i} Δ_j^{a_j,b_j} Δ_k^{a_k,b_k} f(x)=0.
```
This formulation explicitly controls the function even on null configurations. It implies every finite-alphabet conditional coarse-graining has pointwise Efron–Stein degree≤2. The relationship to a purely L²/ae Hoeffding-degree assumption requires a separate representative theorem and is **not claimed** here.

Define `E_i f(x)=∫ f(x_{-i},a)dμ_i(a)`, `I_i(f)=||f-E_i f||²_{L²(μ)}`, `V=Var_μ(f)` and `M=sup_i I_i(f)`.

**Claim:**
```
Var_μ(f)^2 ≤ K B² M
```
with the **same** certified finite-product constant `K`. This includes infinitely many coordinates, continuous measurable alphabets, heterogeneous laws, and zero-mass measurable cells.

### Proof, step 1 — finite partition and finite-coordinate projection

For any finite `F⊂I`, choose a finite measurable partition `𝒫_i` of `Ω_i` for each `i∈F` into nonempty cells. Let `𝒢=σ(𝒫_i(X_i):i∈F)` and `g=E[f|𝒢]`. For each cell tuple `a∈Π_{i∈F}𝒫_i`, choose an explicit representative for *all* cells, including probability-zero cells: on positive-mass cells use normalized conditional `μ_i(-|a_i)`, on zero-mass cells use any Dirac mass at a point of `a_i`. Define the finite-table `g(a)` as the integral of `f` under those independent conditional/Dirac distributions on F and the original product distribution outside F.

The table is globally bounded: `|g(a)|≤B` at **every** cell tuple, including tuples of zero probability. On the positive-probability tuples this table is exactly the usual conditional expectation.

Its alternating third cell differences vanish: by the multilinearity of the product integral and the pointwise `Δ_iΔ_jΔ_k f=0`, the eight-term alternating combination of product integrals is zero. Thus `g` has degree at most two for **every** finite cell configuration, not merely μ-almost surely.

The finite table may use different finite alphabet sizes. Embed them into one finite disjoint-union alphabet `A=⨆_{i∈F}𝒫_i`. For each i, send an invalid tag to a chosen default valid cell, assign its probability zero, and compose g with those per-coordinate retractions. This preserves global boundedness and third-difference-vanishing, and exactly preserves finite-table variance and resampling influences. Therefore the merged finite theorem applies to g with `K`.

### Proof, step 2 — influence never increases under coarse observation

Write `P_𝒢` for conditional expectation onto the finite information σ-algebra. For every `i∈F`, product independence implies the coordinate-resampling projection `E_i` commutes with `P_𝒢`: they are commuting tensor-product conditional expectations. Hence, with `D_i=1-E_i`,
```
D_i(P_𝒢 f)=P_𝒢(D_i f).
```
Since conditional expectation is an `L²` contraction,
```
I_i(g)=||D_i P_𝒢 f||²₂ ≤ ||D_i f||²₂=I_i(f).
```
For `i∉F`, `g` is independent of coordinate i, so `I_i(g)=0`. Therefore `max_{i∈F} I_i(g)≤M`. All covariance/mean quantities coincide with those of the finite cell table on positive-probability tuples.

Finite Q2 gives `Var(g)²≤K B² M`, uniformly over F and finite partitions.

### Proof, step 3 — dense cylinder closure

The finite-coordinate finite-partition simple cylinder functions generate the ordinary product σ-algebra and are dense in `L²(μ)` (standard π–λ/monotone-class argument followed by simple-function approximation). The collection of their information σ-algebras is directed under finite refinement. Orthogonal-projection contraction and an ε-approximation argument imply `P_𝒢 f→f` in `L²` along this directed family.

Since expectations are preserved, `Var(P_𝒢 f)→Var(f)`. Pass to the limit in the uniformly bounded finite-Q2 inequalities to obtain `Var(f)²≤K B²M`. QED, as an analytic argument from standard product-measure facts.

## 3A. Stronger analytic theorem — essential boundedness and L² Hoeffding degree ≤2

The pointwise-difference hypothesis in Theorem B is convenient but unnecessarily restrictive. The natural L² version follows from the same argument, with one essential zero-cell support repair.

**Theorem B′ (analytic, not Lean certified).** Under the same arbitrary-index independent product law, let f∈L∞(μ) be any bounded measurable equivalence class with essential bound ||f||∞≤B. Write E_i for integration over coordinate i and D_i=Id−E_i as commuting orthogonal projections on L²(μ). Assume D_i D_j D_k f=0 in L²(μ) for every triple of distinct indices. Then Var_μ(f)²≤K B² sup_i I_i(f), with the same finite-product K, with no global pointwise restriction or positive-atom floor.

**Proof.** Let P_G be the finite-coordinate, finite-partition conditional expectation above. For each i∈F, P_G commutes with E_i, and therefore D_iD_jD_k(P_G f)=P_G(D_iD_jD_k f)=0 for all distinct i,j,k∈F. On the finite probability table of positive-probability cell labels, every configuration has strictly positive product mass. The finite canonical Hoeffding decomposition g=m+Σh_i+Σh_{ij}+Σ_{|S|≥3}h_S is orthogonal. Each h_S with |S|≥3 is fixed by D_iD_jD_k for a triple {i,j,k}⊂S; orthogonality and the preceding zero identity force h_S=0. Thus on the full supported cell configuration set the table has a pointwise decomposition g=m+Σh_i+Σh_{ij} and, by conditional Jensen, |g|≤B.

For each coordinate, pick a positive-probability cell a_i^* and retract any zero-probability cell to a_i^*; extend g by composition with these retractions. The extended table is pointwise bounded by B on every label tuple and has pointwise Hoeffding degree≤2, because its explicit singleton/pair decomposition is preserved under coordinatewise retraction. Its nonzero distributional masses and influence/variance agree exactly with the supported table. Padding heterogeneous alphabets with an arbitrary common finite disjoint-union alphabet and zero masses preserves these properties again.

The original-source finite Lean theorem consequently yields Var(P_G f)²≤K B² sup_i I_i(f). The same conditional-expectation contraction and dense finite-cylinder limit now prove Theorem B′. QED analytically.

**Formalization distinction:** this proof requires formalizing (i) the finite supported-table chaos decomposition from the triple-centering L² condition, and (ii) bounded zero-cell retraction. These were not in the pinned Lean infinitary source. The analytic extension is stronger than Theorem B and removes its global pointwise assumptions, but is still not certified by complete Lean compilation.

## 4. Audit and unproved formalization dependencies

The proof of Theorem B uses these standard but **unformalized in the current NIGHTFALL Lean terminal** results:
1. existence and characteristic product-measure construction for arbitrary index spaces (assumed);
2. finite sigma-algebra conditional expectation with globally bounded representatives on zero-mass cells;
3. preservation of pointwise third mixed differences under independent conditional integration;
4. coordinate-resampling/finite-information conditional-projection commutation;
5. dense finite-cylinder approximation in product `L²` and limit passage;
6. correspondence between zero third mixed differences and the exact `ESDegreeLE` checker used by the finite Lean theorem; heterogeneous finite alphabet embedding.

Prior merged [#501](https://github.com/d3lefts/d3lefts/pull/501) certifies finite marginals and finite-cylinder squared-integral identities for `Measure.infinitePi`. It **does not** certify steps (2)–(6) as a complete theorem. This note is a reproducible **analytic proof target and Lean implementation specification**, not a compiler receipt.

### Assumption attack checklist

- The product σ-algebra, not an unspecified completion or non-measurable infinite-product map.
- Pointwise global boundedness and vanishing triple differences, **not** merely a.e. degree two.
- Distinguish essential `L∞` bound from globally bounded representative required to handle zero-probability atoms in the source Lean statement.
- Finite cell table chosen on zero-mass cells must preserve boundedness and degree simultaneously; the conditional/Dirac integral does.
- Do not assume countability of I or sequential martingale convergence; use the directed net/ε argument.
- Check resampling influence normalization: variance-after-coordinate-resampling convention.
- For nonempty finite partitions, representatives are selected by ordinary choice; nothing computable is asserted.
- No historical originality or formal Lean status for this transfer is claimed.

## 5. Next explicit Lean target

```
theorem infinite_q2_from_finite
  [arbitrary index/product measure]
  (hf_measurable : Measurable f)
  (hf_bounded : ∀ x, |f x|≤B)
  (hf_degree3 : ∀ i j k distinct, ∀ replacements, Δ_i Δ_j Δ_k f = 0) :
  (Variance μ f)^2 ≤ K * B^2 * ⨆ i, Influence μ f i
```

Build in separate named gates: `finite_table_retraction_degree`, `finite_info_commutes_coordinate_resampling`, `finite_info_preserves_degree2`, `finite_info_influence_le`, `finite_cylinder_L2_dense`, and the terminal. Check the exact Mathlib `Measure.infinitePi` and `L²` APIs; do not replace noncomputable facts with axiom declarations.
