# Guarded-envelope exponent-two reduction (v1, 2026-11-26)

**Status:** Author-side mathematical proof of a restricted theorem, exact local finite checks. Not independently reviewed, not Lean-certified, not novelty-cleared. The unrestricted real fractional-row problem and N-UE2 remain open. No change to any manuscript's certification or to the pinned Lean infrastructure.

## 1. Contract and recovered frontier

Objective: derive a dimension-independent exponent-two estimate for nonsymmetric real functions from genuine full fractional rows, preserving the original product law. Turturean, arXiv:2611.09773v1, section 9.5, is the inherited external target; this note does not claim a new independent priority search. Repository baselines recovered this session: #814 (finite-level theorem and sharp loss for the isolated-cut method), #823 (singleton-residual R counterexample; full K remains open), #925 (symmetric/orbit-density theorem), and draft #1242 (obstruction to the proposed L1 bridge). None establishes the unrestricted L2 theorem.

Feasible setting: finite independent categorical coordinates, real f; restrict each alphabet to its positive-probability support if needed. No degree, alphabet-size, symmetry, or common marginal hypothesis. Distinguish row cost K from the maximum pointwise sum of law-weighted residuals R.

Novelty gate: establish a reusable structural reduction beyond the symmetric case; any claim of external priority needs a separate dated literature review. Significance gate: a dimension-free coefficient on a nonsymmetric class, with an exact boundary/negative control. Stop at the scoped proof and reproducible checks; do not promote a universal theorem. Non-author audit plan: attack the projection identity, conditional range bound, guard orientation/restriction argument, and independent-block cost identity; verify edge cases and rerun the checker from the exact blob.

## 2. Definitions

Let X have the product law on a finite product Omega. A full row at x is a nonnegative vector a(x) such that for EVERY y in Omega,

    |f(x)-f(y)| <= sum_{i:x_i != y_i} a_i(x).

K is the maximum over x of the minimum feasible row cost sum_i a_i(x), or any valid uniform upper bound on those costs. Define

    V = Var(f), I_i = E[(f-E_i f)^2] = (1/2) E[(f(X)-f(X^{i fresh}))^2],
    M = max_i I_i,
    D_i(h) = max{|h(x)-h(y)|: x and y differ only in i},
    D(h) = sum_i D_i(h).

Here E_i integrates coordinate i with its ORIGINAL marginal. Missing coordinates have oscillation and influence zero. Every row at x has cost at least the sum of singleton oscillations anchored at x, and K >= max f-min f. The full row definition, not the residual R, is used throughout.

## 3. Guarded-envelope theorem

For any set S of r coordinates let g=E_S f, averaging guards rather than conditioning on a rare assignment. If D(g)<=C K with C>=0, then

    V <= sum_{i in S} I_i + (D(g)/2) sqrt(M)
      <= r M + (C/2) K sqrt(M).                         (1)

In particular, for V>0,

    V/(K sqrt(M)) <= (C+sqrt(C^2+4r))/4,                 (2)
    16 V^2 <= (C+sqrt(C^2+4r))^2 K^2 M.

The r=C=0 case forces V=0. This is not a theorem that such S and C always exist with dimension-free bounds.

**Proof.** Integrations E_i are commuting orthogonal projections on L2 of the original product law. Orthogonally decompose f-E_S f by successively averaging coordinates of S. Each squared norm is no more than I_i by contraction, so V(f)-V(g)<=sum_{i in S} I_i. For i outside S, I_i(g)<=I_i(f) by commutation and contraction. Conditional on all other coordinates, the range of g is at most D_i(g), so its conditional variance is at most D_i(g)^2/4 (Popoviciu, or center the variable at its interval midpoint). Thus I_i(g)<=D_i(g)^2/4 as well. Efron-Stein gives

    V(g) <= sum_i I_i(g)
         <= sum_i sqrt(I_i(g)) D_i(g)/2
         <= D(g) sqrt(M)/2.

This proves (1). Also V<=K^2/4 from the global range bound. For V>0, Efron-Stein implies M>0 and K>0. Put t=V/(K sqrt(M)), s=sqrt(M)/K. Then t<=rs+C/2 and ts<=1/4. Therefore t<=r/(4t)+C/2, or 4t^2-2Ct-r<=0. The positive root gives (2).

Sharpness for r=0,C=1: f=sum of n fair independent 0/1 bits has V=n/4, M=1/4, K=D=n, hence K^2 M=4V^2 exactly. This establishes sharpness of that special-case coefficient, not the general guarded constant.

## 4. Structural classes satisfying the envelope premise

A slice h on a product of finite chains has decreasing differences if, for each coordinate i and values u<v, the increment h(v,x_-i)-h(u,x_-i) is nonincreasing in every other coordinate. Adjacent mixed differences suffice on finite chains. Allow independent reversal of each chain.

(a) Monotone nondecreasing decreasing-differences slices: D(h)<=K_h, where K_h is the slice's genuine full row bound. Indeed each coordinate's maximal possible increase is from its minimum to maximum value when all other coordinates are minimal. All those singleton changes are anchored at the same minimal vertex, so every full row there must pay their sum. This yields C=1, hence K^2 M>=4V^2 for unguarded slices, including nonsymmetric coverage functions.

(b) Nonmonotone binary decreasing-differences slices: D(h)<=2K_h. A coordinate increment lies between its values at the all-minimal and all-maximal contexts of the other coordinates; the absolute maximum is bounded by the sum of its absolute values there. The two sums are paid by rows at the minimal and maximal vertices. This yields C=2, hence K^2 M>=V^2.

(c) Nonmonotone arbitrary finite-chain decreasing-differences slices: D(h)<=4K_h. For each pair u<v, the increment is sandwiched between those at the two extreme contexts. Its absolute value is bounded by the larger of those two absolute values. In each extreme context the range of the one-coordinate slice is at most twice its maximum change from the corresponding extreme anchor (minimum at the minimal corner, maximum at the maximal corner). Summing the two anchored contributions gives D(h)<=2(K_min+K_max)<=4K_h, hence K^2 M>=V^2/4.

These conclusions are unaffected by a reversal of coordinates. If every slice f(s,.) after fixing S satisfies one of these envelope bounds, possibly with different orientations for different assignments s, then its restricted full rows have cost at most K. By the triangle inequality D(E_S f)<=E_S D(f(S,.))<=CK. The guarded theorem applies without enumerating assignment count in the bound.

## 5. Exact selector recovery and obstruction to a fixed global guard count

Take independent uniform addresses A,B in {1,...,m}, m>=2, and m^2 independent fair signs Z_ab. Let f=Z_AB. A feasible full row charges 2 each to A, B, and the selected sign, zero elsewhere: a changed output must differ in at least one of these coordinates. Conversely a vertex with selected sign +1 and suitable alternative addressed signs -1 has three singleton changes of size 2. Thus K=6. The exact formulas are

    V=1, I_A=I_B=1-1/m, I_Z=1/m^2, D(f)=2m^2+4.

Average the two address guards: g=m^(-2) sum_ab Z_ab and D(g)=2. Hence r=2,C=1/3 uniformly, whereas D(f)/K diverges. This explains how the operator handles selector obstructions to a direct envelope approach.

There is an exact limitation: no universal fixed pair (r,C) can ensure D(E_S f)<=CK for all finite products and all real f with |S|<=r. Form a sum of b=2r+2 disjoint copies of the above selector. A set of r guards touches at most r copies. Untouched copies retain their full oscillations. With K=6b,

    D(E_S f)/K >= (b-r)(2m^2+4)/(6b) >= m^2/6 -> infinity.

This refutes a bounded-GLOBAL-guard completeness strategy, not the actual L2 row conjecture. In particular the same disjoint example satisfies the desired E2 inequality.

## 6. Disjoint composition

For F=sum_b f_b on disjoint coordinate sets, V(F)=sum_b V(f_b), M(F)=max_b M(f_b), and the optimal full row bound satisfies K(F)=sum_b K(f_b). For the latter, changing one block at a time forces each block's restricted row to be feasible; conversely concatenate optimal block rows and use the triangle inequality. Maximize at independently chosen worst-case vertices.

Consequently if each block satisfies V_b<=T K_b sqrt(M_b) with the same T, then V(F)<=T K(F) sqrt(M(F)). Bounded guards per block suffice; no need to pay their global count. This closes the preceding independent-sum obstruction to the guard operator, but does not address connected overlapping blocks.

## 7. Certificate and actual finite experiments

Reproducer: python3 -I research/nightfall/flagship-influence/check_guarded_rows.py
Seed 20261126. Exact stdlib Fraction arithmetic, no floating-point acceptance.

SHA256: f18a8973337f087dcc28e24e95fcda408aa5c4ae6c5643e8455c24f0b56c6dd7
Git blob: 37d26e06a1666019f94861aeeef8239038ad1847

Actual local execution passed:
- 240 seeded generated exact tables (40 in each of six classes: monotone/nonmonotone binary, monotone/nonmonotone heterogeneous chains, one/two guarded coordinates).
- 8 additive sharpness tables, XOR guard-loss control, explicit two-address selector, disjoint composition, and 36 exact symbolic fixed-global-guard limitation controls.
- Two distinct exact influence formulas agree for each enumerated table; generator mixed-difference signs checked on the actual oriented tables.
- Uses the rigorous LOWER bound max(global range, max_x sum_i anchored singleton oscillations) on K, not an asserted full-row LP optimum. Passing with this smaller number implies the tested inequality with true K for these examples. Selector full K=6 is independently proved analytically above. Finite checks do not establish universality.

This checker was written and executed in the same research session as the proof. Separate formula paths are cross-checks, NOT independent non-author peer review. No new CI run or Lean certificate is claimed here.

## 8. Next decisive gate

The strongest verified result in this note is the exact structural theorem (1)-(2) plus closure under disjoint sums, not a new all-function bound. Seek a connected-overlap replacement for the disjoint composition identity: either find a row-budget-respecting decomposition into guarded-envelope components, or build an explicit connected family where all such decompositions force an unbounded budget. Test first on sparse interacting selectors with a shared address or shared leaf and compare genuine full-row dual packings, not residual R. Do not infer a universal guard count from the positive samples.

Discovery graph: full-row K -> guard projection -> conditional variance and coordinate oscillation envelope -> exact bound (2) -> decreasing differences and selector transfer -> global guard no-go -> independent-block closure -> connected overlap gate.
