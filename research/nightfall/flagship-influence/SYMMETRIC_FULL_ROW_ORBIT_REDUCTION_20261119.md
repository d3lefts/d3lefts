# Symmetric full-row orbit reduction — exact certificate operator (v1)

**2026-11-19 · NIGHTFALL research.** Status: elementary exact symmetry reduction plus reproducible finite falsification. **NOT** a proof of Turturean §9.5, the optimal exponent-two polynomial-degree conjecture, or its product-law strengthening. No independent human review or novelty sign-off.

## Exact theorem (finite combinatorics, author proof)

For any real h:{0,...,n}->R put f(x)=h(|x|) on {0,1}^n. At an input x with exactly k ones, define a *genuine full fractional row* a_i>=0 with

    |f(x)-f(y)| <= Σ_{i:x_i!=y_i} a_i     for EVERY y.

The minimum total row cost at x equals the two-variable LP

    K_k = min_{u,v>=0} k*u+(n-k)*v
    such that r*u+s*v >= |h(k)-h(k-r+s)|
    for all 0<=r<=k, 0<=s<=n-k, r+s>0.

The global maximum is **K(f)=max_{0<=k<=n} K_k**. This is an *identity*, not a relaxation.

**Proof:** The stabilizer S_k×S_{n-k} permutes the ones and zeroes of x and leaves f(y), coordinate-difference patterns, and the cost invariant. Average any feasible row over this group. The resulting feasible row has exactly two weights u (ones of x) and v (zeroes of x) and the same cost. For any target y, let r count ones flipped to zero and s count zeroes flipped to one; then |y|=k-r+s, and its row inequality is precisely the displayed LP constraint. Conversely any two-variable feasible solution gives a full feasible row by replicating the two weights. Both directions prove the equality.

No distribution is used in the row LP. Under iid Bernoulli(p) source, independently and separately evaluate genuine original-source conditional-resampling influence

    V=Σ_k Bin(n,p)[k]*(h(k)-E h)^2,
    M= p*(1-p)*Σ_{j=0}^{n-1} Bin(n-1,p)[j]*(h(j+1)-h(j))^2.

At p=1/2, M=(1/4) E_{Bin(n-1,1/2)}[(Δh)^2]. For any nonconstant h, the candidate sharp row inequality is K²M/V²>=4; ***this remains unproved*** even for all symmetric profiles.

## Search and independently certified finite evidence

Run `python3 row_symmetric_operator.py` (numpy/scipy) for numerical stress and `python3 check_symmetric_row_exact.py` (numpy/scipy for candidate generation, `fractions.Fraction` for acceptance). Numeric solver values alone are **never accepted** for the rational certificate:

- 432 fair symmetric profile/dimension pairs, n in {8,12,16,24,32,48}; 72 profiles per n, including majority, symmetric thresholds, point masses, Chebyshev, parity, tanh/Gaussian profiles, random Hamming-level assignments and random walks. Zero cases below ratio 4; equal-weight linear controls attain 4.
- 2,538 iid-bias tests on n in {8,12,16,24} with p in {.01,.05,.1,.25,.5,.75,.9,.95,.99}, some rare-zero variance cases omitted; zero below 4.
- **40 exact Fraction cases** on n in {3,4,5,6,8,12,16,24}, five integer-valued profile families per n. Primal feasibility, dual feasibility and matching objectives verified with **48,810 exact rational checks**; in 20 n<=6 cases, an independently enumerated full 2^n-vertex LP agrees with the quotient cost. Minimum ratio is exactly 4 (linear equality).
- Original 930 general fair-cube functions and 263,900 original-product function–bias cases from earlier checkpoint remain *separate* evidence; do not sum these counts without tracking sample overlap.

**Positive result:** exact exponential-to-polynomial state-space reduction for symmetric row-cost calculation, independent of source p, with checked finite rational witnesses. Orbit-averaging is standard symmetry/LP methodology, so this is a reusable research **operator**, not a novelty priority claim.

**Limitation / next gate:** n growing does not test arbitrary nonsymmetric interacting f. Neither a finite search nor an LP symmetry quotient establishes the missing universal *cross-threshold bilinear routing* inequality. Next attempt should test a concrete PSD/row-dual cross-level operator on connected ANOVA high-overlap examples, then prove (or falsify) that operator. Do NOT substitute singleton residual R for full K: the R bridge is already false on original biased products. Turturean arXiv:2611.09773v1 §9.5 is the external reference; earlier NIGHTFALL scope notes: `FULL_ROW_COUPLING_TENSORIZATION_20261118.md` and `REAL_ROW_R_BRIDGE_NO_GO_20261118.md`.

## Certification ladder
Orbit-averaging is an author mathematical argument. Finite primal/dual feasibility is an independently coded **exact rational** replay, after solver candidate generation. No Lean formalization, non-author proof review, unrestricted theorem, novel contribution, or submission is claimed.
