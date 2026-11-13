# Swansea V5 Q2: actual-source matching and fourth-moment execution

Date: 13 November 2026. Branch: `nightfall-q2-actual-matching-moment-20261113`.
This record explicitly distinguishes a **paper derivation**, a **finite exact audit**, and an **actual Lean theorem**. No full Q2 promotion is authorized.

## Problem and exact claimed strength

For an arbitrary independent finite (then measurable) product and a bounded real degree-two Efron–Stein observable, the V5 dossier proposes
`Var(f)^2 ≤ C2 B² max_i I_i(f)`, where
`C2=(10+2√2)^2(1+√3)^2<1229`.
The older source-side analytic proof has weaker constant
`15(1+√3)` before squaring (thus `225(1+√3)^2 ≈ 1679.42` after squaring).
**Neither universal Q2 conclusion is compiled from source hypotheses in a single Lean theorem.**

## First requested operator: source global matching-to-amplitude

Use the genuine finite-product extraction `esComp p {i,j} f`, sliced to
`actualPairKernel p f base i j a b`.
The existing `ActualESPairMatchingBridge.lean` proves source-derived
centering, dependence only on `i,j`, and simultaneous oriented four-point
witnesses. The existing `QuadraticMatchedParity.lean` proves global
even/odd cancellation for an *explicit* `BlockPolynomial` and consequently
a `4B` bound for its matched within-block rectangles. What is **not**
proved in Lean is that the actual source function, given only
`ESDegreeLE p f 2`, is exactly represented by the block polynomial used in
that parity theorem, without assuming a separate `hpoly` or matching bound.

### Universal paper-level parity derivation (not claimed Lean-compiled)

Let `F` be a matching. For each edge choose positive-support corners
`a0,a1,b0,b1` so that the oriented rectangle
`Δ_e=h_ij(a0,b0)-h_ij(a0,b1)-h_ij(a1,b0)+h_ij(a1,b1)`
is nonnegative and at least the supported maximum amplitude `b_e`.
In each matched block a fair selector `σ_e` chooses corners with common
(left/right) parity in the even law and opposite parity in the odd law.
Choose independent selectors across blocks and fix unmatched coordinates
on the positive support. Both resulting laws have the same one-coordinate
marginals, and each pair of coordinates from **distinct** matched blocks has
the same joint law under both experiments. Under source Efron–Stein degree
at most two, `f` is a sum of constant, singleton and pair terms; all
terms except the **within-matched-pair** terms cancel. Each surviving
term contributes half its mixed rectangle, yielding

`E_even f - E_odd f = (1/2) Σ_(e∈F) Δ_e ≥ (1/2) Σ_(e∈F) b_e.`

The two expectations are bounded by `B`, so
`Σ_(e∈F) b_e ≤ 4B`.
This is an analytic proof, contingent on ordinary source ANOVA
decomposition and full positive-support treatment, **not a new kernel
certificate** and not a novelty verdict. A Lean declaration must connect
the actual `esComp` terms to `BlockPolynomial.evaluate` and prove the
coupled-input identities without assuming the required equality.

### Independent exact tests

`check_actual_source_matching_v2.py` recomputes centered pair kernels
from conditional averages of the **original f**, not the generator.
90 heterogeneous models, including dense cross-block pair graphs, rare
atoms and discarded zero-mass symbols; 6,576 source reconstruction cases;
630 oriented witness checks; 1,260 independent rectangle invariance
checks; 2,124 matching-mass checks; 2,034 exact global parity checks,
all passing under Python `fractions.Fraction`.
`check_matching_parity_basis_exact.py` exhausts 115 Boolean indicator
monomial basis cases of order 0, 1 or 2 on one through three matched blocks.
The general all-block implication follows analytically from locality and
linearity; the finite script itself does **not** certify that implication
inside Lean. Finite tests cannot prove the universal theorem.

## Second requested operator: fourth-moment endpoint

**New source `QuadraticActualMomentEndpoint.lean`**:
- `weighted_l1_l2_l4`: proves `(Σμv²)^3 ≤ (Σμv)^2(Σμv⁴)` for finite nonnegative `μ,v`, directly by two Cauchy–Schwarz inequalities; no interpolation axiom.
- `actual_product_l1_l2_l4`: applies it to actual finite-product table norms.
- `actual_product_fourth_endpoint`: imports the already proved
  `arbitrary_law_many_hilbert_fourth`, derives its bound and the
  interpolation bound and concludes
  `s ≤ z(c+√(3M))` for independent centered Hilbert increments of
  norm ≤c and energy `s≤M`.

**PASS kernel**: Lean 4.35.0 / Mathlib v4.35.0, strict axiom audit
`propext`, `Classical.choice`, `Quot.sound` only;
[GitHub Actions run 43448181312](https://github.com/d3lefts/d3lefts/actions/runs/43448181312),
source SHA-256 `c1dc34d9ad598177080e41137336c3cf6532029bceda598cc3c32e373f8301df`.
The stronger subsequent CI [43449482065](https://github.com/d3lefts/d3lefts/actions/runs/43449482065) also runs the new source matching falsifier and the same strict moment gate.

**Additional source-to-moment candidate**:
`ActualESPairHilbertMoment.lean` uses
`Y_j(b)(a)=√(p_i(a)) h_{i,j}(a,b)` with genuine `actualPairKernel`
and derives its input centering and norm bound from source laws.
It connects to the full moment endpoint with displayed **amplitude**
and **energy** hypotheses. The `j` map may repeat coordinates; synthetic
draws are independent by construction, so the equality with **actual
source conditional sections** is still unproved. Its historical upstream
4.33.0 strict compilation has a separate receipt and must not be treated
as the repository's 4.35.0 pin without a matching replay.

## Still missing for true Q2

1. One typed Lean theorem deriving global `Σ matching b_e ≤ 4B`
   directly from `ESDegreeLE p f 2` and `|f|≤B`, via actual
   source-to-parity construction. Do **not** assume `BlockPolynomial`
   representation of `f` as an extra premise.
2. Source-matched greedy endpoint ownership with `Σ_i c_i≤8B`,
   actual pair energy bookkeeping, and a distinct-neighbor injection.
3. Identification of independent synthetic increment moments with
   conditional sections of the original product, plus source
   Jensen/ANOVA influence/variance equalities and scalar summation.
4. One strict terminal theorem matching its printed product,
   boundedness and degree hypotheses. The old 1679.42 constant
   and V5 1228.356 candidate must not be conflated.
5. Measurable-product closure and independent prior-art/priority review.

## Decisive next test

Build an explicit `BlockPolynomial` from the **canonical**
`quadratic_hoeffding_decomposition p hp1 f hdegree`, grouping every
unmatched, matched, and cross-block singleton/pair term. Prove
`f(even σ)=evaluate P false σ` and
`f(odd σ)=evaluate P true σ` before invoking
`global_parity_identity`; reject any interface that imports the desired
parity identity or matching bound as an assumption. Replay under the
correct compiler pin with a strict `#print axioms` receipt.

Status: fourth-moment **independent-increment endpoint certified**;
actual-source global matching **analytic + finite exact tests only**;
complete Q2 **not certified**. No human referee or novelty gate passed.
