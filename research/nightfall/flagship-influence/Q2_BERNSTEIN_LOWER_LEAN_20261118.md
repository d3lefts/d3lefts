# Q2 original-product Bernstein lower-bound Lean candidate

Date: 2026-11-18. Status: **draft until pinned strict Lean CI passes**.

## Objective

For the original resampling-influence convention, show that the optimal
constant in the universal real degree-at-most-two product inequality
`V² ≤ C B² M` must be at least **4**, even on i.i.d. biased two-point
sources. This is a necessary lower bound, **not** a proof that `C=4`
suffices, and **not** the full each-degree `C_d ≥ d²` Lean certificate.

## Source, mechanism, analytic identity

For `n≥2`, let `X_i∈{−1,+1}` be independent with mean
`r=1/√2`, probability `p=(1+r)/2` of `+1`, and
`S=∑ X_i`. The real-valued degree-two function
`f_n=2S²−n²` is bounded by `B≤n²` (in fact the centered
half-range is `n²` for even `n`).

The original-product resampling influence is
`p(1−p) E[(f(S_{−i}+1)−f(S_{−i}−1))²]` because the
conditional variance of a two-point function is
`p(1−p)*(difference)²`. The finite difference is `8S_{−i}`.

Exact finite independent-source moments give, for every integer n≥2,
`V_n = 2n(n−1)(2n−1)`,
`M_n = 4n(n−1)`, and hence

`V_n²/(n⁴ M_n) = (n−1)(2n−1)²/n³ = 4−8/n+5/n²−1/n³ → 4`.

The key feature is that there is **no irrational asymptotic estimate
and no CLT**: every finite-n moment is an exact polynomial in n,
obtained by two-way source branching.

## Certificate scope

`Q2BernsteinFamilySharpLower.lean` builds the original product
source as weighted ±1 branches, proves moments through order four,
derives the variance/influence *formulas*, and shows that their
all-n coefficient must be at least 4. A complete claim that the
original physical function-space statistics equal these moment
formulas additionally requires an explicit Lean bridge from
`f_n=2S²−n²` to squared centered expectation and conditional
variance, plus the bound and degree proof. Until this bridge is
kernel-checked, treat the coefficient-4 physical consequence as
**mathematically derived but only partially Lean-formalized**.

No universal upper-bound theorem is inserted as an axiom. Existing
#816 already certifies a separate full-world degree-two lower bound
9/4. The general all-degree Bernstein sharpness argument remains
outside Lean.

## Audit

Pinned Lean compiler and Mathlib, exact-head named declaration
allowlist, source hashes and workflow receipt, plus independent
rational source enumeration and exact asymptotic formulas. Reviewer
should attack: arithmetic of fourth moments, resampling factor,
the original source versus a uniform surrogate, the centered radius,
the degree-two assertion, and the remaining function-space bridge.

Classical mathematical ingredients are credited to Chebyshev /
Bernstein extremality and elementary independent Bernoulli moments.
Priority has not been established. Nothing here closes
N-UE2(2,1), N-UE2(2), N-UE2(6), or unrestricted cubic exponent two.
