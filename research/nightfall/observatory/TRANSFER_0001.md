# Transfer 0001 — weighted quadratic-form coupling

**Owner:** Vesper. **Date:** 2026-10-28.  
**Classification:** Established classical weighted diagonal dominance / Schur-complement technique; original NIGHTFALL research application **pending**.  
**Related programs:** finite-copy Werner positivity; reciprocal-Hankel finite-to-infinite positivity.

## Criterion (classical, scope explicit)

Let a symmetric block quadratic form have diagonal block lower bounds `<x_i,A_i x_i> >= a_i ||x_i||^2`, positive `a_i`, and off-diagonal coupling norm ceilings `||B_ij|| <= b_ij=b_ji` with `b_ii=0`. For a positive weight vector `w`, set

`delta_i = a_i - sum_(j != i) b_ij w_j/w_i`.

If every `delta_i >= delta > 0`, then the full quadratic form obeys `Q(x) >= delta sum_i ||x_i||^2` for all finite-support vectors. For infinitely many blocks, the quadratic form, the interaction sums and a suitable closed operator realization must also exist; the estimate then extends by closure when these hypotheses hold. This statement is an instance of standard weighted diagonal-dominance / quadratic-form estimates.

**Proof.** Cauchy-Schwarz and the coupling bound give
`Q(x) >= sum_i a_i ||x_i||^2 - 2 sum_(i<j) b_ij ||x_i|| ||x_j||`.
Apply `2uv <= (w_j/w_i)u^2 + (w_i/w_j)v^2` to every pair. Collecting coefficients produces the lower bound `sum_i delta_i ||x_i||^2`. Every step is exact. There is no new all-rank spectral theorem here.

For two blocks, the familiar stronger scalar norm condition is `b^2 < a_1 a_2`; a Schur complement gives positivity. A quantitative small-eigenvalue bound is `[(a_1+a_2)-sqrt((a_1-a_2)^2+4b^2)]/2` in the corresponding 2-by-2 scalar comparison model.

## Exact 3-sector demonstration

Consider the real rational matrix

```
A = [[2, 4/5, 0],
     [4/5, 1, 4/5],
     [0, 4/5, 2]]
```

Choose `w=(1,2,1)`. The three weighted diagonal margins are
`delta_1=2-(4/5)*2=2/5`,
`delta_2=1-[(4/5)+(4/5)]/2=1/5`,
`delta_3=2/5`.
Thus `A >= (1/5) I` as a quadratic form.

The unweighted row-sum test at the middle block gives `1-8/5=-3/5`, so that sufficient test fails on this positive example. Direct leading principal minors are `2`, `34/25` and `36/25`, all positive. The exact rational identities are independently reconstructed by `python3 scripts/verify_observatory.py`.

**Interpretation:** optimized weights can recover a positivity certificate where uniform row dominance is inconclusive. This is a teaching-scale demonstration of a classical mechanism, **not** a certified improvement to any NIGHTFALL Werner threshold or infinite-rank spectral positivity claim.

## Proposed cross-program transfer and obstruction

For a Werner witness extension, identify an encoded source subspace with positive quadratic-form margin `a`, an outside subspace with a separately proved margin `d`, and cross-coupling operator bound `b`. The two-block bridge requires `b^2 < ad`. If the outside block has no independent positive lower bound, this method alone cannot establish the extension.

For the spectral program, decompose finite certified blocks from their unverified tail. Require a **scale-uniform** lower margin on the tail and a finite-to-infinite coupling estimate `b(t,N)^2 < a(t,N)d(t,N)`, plus closure of the infinite form. The existing finite-rank computations do not establish these conditions.

**Cheapest discriminating experiments:**
1. Lemnis supplies one exact outside-encoded Werner witness and rigorous interval/rational bounds `a,d,b`. Reproduce with two independent paths. A negative Schur complement is an obstruction.
2. Vesper supplies a rank-doubling spectral cutoff and the complete small/middle/large scale partition. Compare interval bounds on the worst `a d-b^2` against zero. Any uncovered scale invalidates a global claim.

**Quantitative registry status:** teaching example passes exactly; gain on original research targets remains **zero measured / pending evaluation**. No implication edge between Werner and the spectral problem is authorized.
