# AXIOM / NIGHTFALL — Efficient *uniform* F25 phase recovery at the information-theoretic union threshold

**Date:** 29 October 2026. **Lead:** Devin J. Wright. **Mathematical derivation and checkers:** Axiom (GPT-6). **Status:** self-contained algebraic probability argument and two separately implemented finite-field checkers; external human mathematical refereeing and comprehensive global priority review **OPEN**. **Same-scope improvement:** this uses exactly the iid random measurement law in Axiom draft PR #16 and Vesper draft PR #31. This is not an unconditional worst-case guarantee for every sensing matrix.

## Theorem (new polynomial-time recovery guarantee)

Let `F=F25`, `F0=F5`, `k,s>=1`, and let `A∈F^(m×k)` have independent uniformly distributed rows. Observe `y_j=(a_j·x)^4` for an unknown `x∈F^k`, where `A` is revealed. The inevitable global phase group is `mu4=F5*`.

Define `rho=97/625`, `sigma=601/15625`, and

    c_IT = log(625)/log(625/97) = 2 log(25)/log(625/97).

**Claim.** If `m>=ceil(c_IT*k)+s`, with probability strictly larger than `1−5^(−s)` over one matrix `A`, a deterministic algorithm simultaneously recovers the `mu4`-orbit of **every** `x∈F^k`. Its per-output runtime is `O(m*k^2)` operations in the fixed prime field `F5` plus constant-cost F25 arithmetic, and the algorithm examines at most **25** candidate vectors. In particular the elementary integer-certified sufficient condition

    m >= ceil(83*k/24)+s

works, with the stronger explicit failure estimate

    Pr(any decoding failure) < (1451/12000) 5^(−s) < 5^(−s).

For the exact logarithmic `c_IT`, one can use `(617/4800) 5^(−s)` as the failure bound. Therefore the *same leading first-moment coefficient* previously known only for Vesper's exponential-time information-theoretic inversion is attained by a deterministic polynomial-time inverse on the same iid sensing law. No algorithmic optimality or publication-first claim is made.

## Algorithm: linearize into F5, then check at most 25 candidates

For every nonzero observed `y_j`, select any fourth root `r_j∈F25` of `y_j`. The equation `(a_j·z)^4=y_j` implies `a_j·z∈r_j F5*`. Drop nonzeroness temporarily to obtain the **F5-linear** condition `a_j·z∈r_j F5` (one independent scalar equation over F5). For a zero observation impose `a_j·z=0` (two independent scalar equations over F5).

Write each signal coordinate as two F5 coordinates. Assemble the resulting homogeneous F5 matrix `H_y` with `2k` columns and compute its nullspace `K_y=ker_F5 H_y` by Gaussian elimination. In the observed class the true `x` lies in `K_y`, and so do its four global F5* multiples.

If `dim_F5 K_y>2`, report decoder failure. Otherwise enumerate every element of the F5 subspace, at most `5²=25` vectors, and retain only those satisfying **all original fourth-power equations**. For a good measurement matrix, exactly the four nonzero vectors of the true phase orbit survive for `x≠0`; only the zero vector survives for `x=0`. The field is fixed, so lookup of the fourth roots and every field arithmetic operation has constant bit cost. Dense F5 RREF takes `O(mk²)` operations.

**Do not confuse:** `K_y` is a prime-subfield linear preimage superset; neither it nor Axiom's earlier 2k-column **F25** Frobenius lift must be one-dimensional for exact recovery.

## Probability proof

Write `q=25`. For a fixed nonzero signal x, define `K_x` by the above linear constraints constructed from its observation `y`. A vector z belongs to K_x if and only if, for every row a,

    (a·x)=0 => (a·z)=0,
    (a·x)!=0 => (a·z)/(a·x) ∈ F5.

This is independent of the arbitrary choice of fourth roots.

**One-row joint incidence.** Define the relation `R(t,b)` to mean `(t,b)=(0,0)` or `t!=0 and b/t∈F5`.

1. For F25-independent x,z, the pair `(t,b)=(a·x,a·z)` is uniform in F25². Exactly `1+24*5=121` of 625 pairs obey R. Thus the one-row probability z∈K_x is 121/625.
2. For F25-independent x,z,z', `(t,b,c)` is uniform in F25³. `R(t,b)` and `R(t,c)` hold for precisely `1+24*5²=601` triples out of 15,625. So the one-row probability both z,z'∈K_x is `sigma=601/15625`.
3. For F25-independent x,z with z'=α x+β z, and x,z,z' **F5-linearly independent**, `(α,β)∉F5²`. Conditional on t!=0, the first relation requires b/t∈F5. The second requires α+β(b/t)∈F5. At most **one** of the five possible ratios works: two distinct admissible ratios force β∈F5 and then α∈F5, a contradiction. Conditional on t=0, both relations require b=0. Hence the joint one-row probability is at most `(24/25)(1/25)+(1/25)(1/25)=1/25`. Equality is attained when α=0 and β∈F25\F5.

**Uniform bound on nullity.** If `dim_F5 K_x>=3`, choose F5-independent `x,z,z'` in K_x with z outside the F25 line of x (possible since that F25 line has F5 dimension exactly two). The three signal vectors have F25-span dimension either two or three. For each x,z there are at most `q²` options z' in their F25-span, and at most `q^k` outside, so a raw ordered-triple union bound gives, for k≥2,

    Pr[∃ x!=0 : dim_F5 K_x>=3]
      <= q^(2k+2) q^(−m) + 1_(k>=3) q^(3k) sigma^m.           (A)

When k=1 the nullspace is automatically at most two-dimensional. No pairwise-event independence is assumed; the estimate is intentionally a coarse all-x union bound.

**Uniform information-theoretic uniqueness.** The direct pair-count theorem in Vesper PR #31 independently gives

    Pr[∃ nonphase collision] <= (q^k−1)/24 *q^(−m)
      + (q^k−1)(q^k−q)/32 *(97/625)^m.                       (B)

For independent nonphase x,x', the one-row collision rate 97/625 follows from `u⁴=v⁴` on 97 of 625 pairs. The pair's `mu4×mu4` phase action and swapping form free orbits of size 32; the proportional nonphase/zero corner is handled by full rank A. This is information-theoretic injectivity, without any decoder assertion by itself.

If both good events hold—injectivity modulo mu4 and `dim K_x<=2` for every nonzero x—the enumerating linear decoder succeeds for every input, including x=0. Rank(A)=k follows from the injectivity event, so zero is the unique zero-output signal and `K_0=ker_F5 A` is trivial.

Combining (A) and (B) yields the **explicit valid bound**

    Pr(any failure) <= (q^k−1)/24 *q^(−m)
       + (q^k−1)(q^k−q)/32 *rho^m
       + 1_(k>=2) q^(2k+2) q^(−m)
       + 1_(k>=3) q^(3k) sigma^m.                             (C)

### Exact integer certificate for m≥ceil(83k/24)+s

The following **integer inequalities** have been checked exactly:

    97^83 < 625^59,           [q² rho^(83/24) <1]
    5^24 * 601^83 < 15625^59. [q³ sigma^(83/24) <1/5]

For every k>=2, `ceil(83k/24)>=2k+3`. Also `rho<1/5`, `sigma<1/5`. Therefore the four terms of (C) are strictly bounded by, respectively,

    (1/24) 5^(−s), (1/32) 5^(−s), (1/25) 5^(−s), (1/125) 5^(−s).

The third term is absent for k=1 and the fourth for k<=2. The sum of rational prefactors is `1451/12000<1`. This proves the headline guarantee for all integer k,s>=1 without extrapolating finite experiments.

### Exact logarithmic threshold, no rational slack

Let `c_IT=log(625)/log(625/97)`. Exactly `q² rho^c_IT=1`, so the second term remains below `(1/32)5^(−s)`. Further exact integer comparisons are

    97^69 > 625^49        => c_IT>69/20,
    4^20 *601^69 <15625^49 => q³ sigma^(69/20)<1/4.

Because sigma<1, `q³ sigma^c_IT<1/4`, so the final term, for k>=3, is below `(1/64)5^(−s)`. The rank-two term again obeys m>=2k+3+s. Summing gives

    1/24+1/32+1/25+1/64 = 617/4800<1.

This matches Vesper's exact logarithmic first-moment coefficient with a polynomial-time decoder; its oracle access/measurement model is unchanged.

## Reproducibility, falsifiers, and claims not made

1. `verify_sub35_decoder.py`: independent packed-int implementation of F5[w]/(w²−2), Gaussian elimination and exact candidate enumeration. Checks the 121/625, 601/15625, 1/25 joint probabilities, the two large integer comparisons, and the exact all-k bound at k=1..99. Decodes all 625 signals for six independent seeded k=2 designs at m=8, and 300 signals in each of two k=3 designs at m=12.
2. `verify_sub35_alt.py`: separately written tuple-field implementation F5[v]/(v²−3), trace-based F5 constraints and different Gaussian elimination. Checks the same incidence counts and **adversarial** five-row interpolation matrix (information-theoretically unique while prime-subfield nullity is two), plus the ambiguous coordinate-only matrix. It exactly decodes all 625 signals in three independent k=2 designs and 125 k=3 examples.
3. Counterexamples and boundaries: A full-rank A can still have `dim K_x=2` while the nonlinear map is injective; therefore the proof requires the **25-candidate nonlinear validation**. A coordinate-only A=I₂ yields four distinct mu4-orbits with the same observations; the list algorithm correctly reports ambiguity. Neither property is implied by a mere numerical rank sample.

**Scope:** fixed F25, iid known nonadaptive fully random rows, all-signals high-probability guarantee, noiseless fourth-power observations, global `mu4` identification. The complex magnitude phase retrieval literature uses a different field/measurement law. Nearest source within NIGHTFALL is Vesper's `PR #31`, whose direct-pair theorem is explicitly a dependency. Independent worldwide novelty evaluation—especially coding-theoretic subfield subcodes, restriction of scalars, and finite-field phase retrieval—is pending. External proof review is pending. No claim of optimality, noise tolerance, or larger-q uniform computational complexity is made.