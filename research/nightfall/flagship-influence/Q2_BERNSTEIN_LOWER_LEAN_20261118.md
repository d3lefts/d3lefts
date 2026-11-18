# Q2 original-product Bernstein lower-bound Lean candidate

Date: 2026-11-18. Status: **strict Lean kernel stage passed at source head `b49fbd3` (run 44351363272); final complete workflow receipt pending. The draft PR remains unmerged pending review.**

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
and **kernel-proves** the all-n coefficient obstruction. It also
**kernel-proves** the physical-source bridge:
- the mass-one original-world expectation of `f_n` and `f_n²`;
- the physical variance as the exact closed-form moment polynomial;
- the physical one-coordinate resampling influence as the exact closed-form moment polynomial;
- all-n coefficient necessity `C≥4` from the actual-source statistics;
- product probability support strictly interior, Boolean-cube range `[-n²,n²]`, and exact vanishing third differences/nonvanishing second differences of the quadratic polynomial.

The named Lean results compile with only the standard axiom allowlist
(`propext`, `Classical.choice`, `Quot.sound`), without `sorryAx`.
A measure-theoretic theorem identifying the additive-difference criterion
with the canonical Hoeffding/ANOVA degree-2 predicate is **not** yet
a named Lean declaration. This is an explicit remaining *definition bridge*,
not a failure of the exact finite original-source construction.

No universal upper-bound theorem is inserted as an axiom. Existing
#816 already certifies a separate full-world degree-two lower bound
9/4. The general all-degree Bernstein sharpness argument remains
outside Lean.

## Audit

Pinned Lean 4.36.0-rc2 and Mathlib 9d581dff, exact-head named
declaration allowlist, source hashes and workflow receipt.
An **independent** `Q(√2)` full-product-world enumerator
`check_q2_bernstein_sqrt2_worlds.py` passed for n=2,...,10,
with a separate centered-ANOVA reconstruction and exact ratio.
The earlier partial workflow failure was solely an unavailable checker
owned by the separate unmerged draft PR #816; the workflow dependency
has been removed. Reviewer should attack fourth moments, the
resampling factor, the original law, centered radius, the
degree definition bridge, and prior-art priority.

Classical mathematical ingredients are credited to Chebyshev /
Bernstein extremality and elementary independent Bernoulli moments.
Priority has not been established. Nothing here closes
N-UE2(2,1), N-UE2(2), N-UE2(6), or unrestricted cubic exponent two.
