# Symmetric full-row orbit reduction — exact certificate operator (v1)

## New unconditional restricted theorem: exponent two for ALL symmetric binary functions

**Theorem (author mathematical proof, not yet Lean formalized).** For every n>=1, arbitrary independent Bernoulli marginals p_i in [0,1], and every real symmetric h(|x|) on the full binary cube, let K be the maximum *full pairwise fractional-row* cost over the cube, V the variance under the ORIGINAL product law, and M=max_i E Var(f|X_{-i}) the maximum original-law resampling influence. Then

    V² <= (n/(n+1))² K² M <= K² M,

**without ANY degree, range, output-level count or marginal-bias restriction.** In particular the bound c=1 (in the theorem's normalization I>=c V²/K²) holds uniformly for this entire high-degree real-valued class. For strictly positive sources K may equivalently be computed over the supported product. If some marginals are deterministic and K is defined only on the actual support, discard the frozen coordinates and translate h by their fixed number of ones; the same conclusion holds with the number of active coordinates in place of n. If no active coordinates or V=0 the conclusion is trivial.

**Proof.** Set D=max_{0<=k<n}|h(k+1)-h(k)|. If D=0 then f is constant. Otherwise let k attain D. From any source-independent full row at an x of Hamming weight k, each of its (n-k) zero coordinates has a singleton flip that changes f by D, so **each of those row entries is >=D**; hence K>=(n-k)D. At any x' of weight k+1, likewise every one of its (k+1) one coordinates has a singleton flip of size D, so K>=(k+1)D. Therefore

    K >= max(n-k,k+1) D >= (n+1) D/2.

For each i, conditional on all other coordinates, the function of X_i takes two values separated by |h(S+1)-h(S)|<=D, where S is the number of ones elsewhere. Thus **under the ORIGINAL p_i**, including p_i=0 or 1,

    I_i = p_i(1-p_i) E[(h(S+1)-h(S))²]
        <= D²/4 <= K²/(n+1)².

Consequently M<=K²/(n+1)². Ordinary Efron–Stein on independent sources gives V<=sum_i I_i<=nM. Multiply this by itself and use one factor M<=K²/(n+1)² to conclude V²<=n² M²<=n² K² M/(n+1)². QED.

**Independent consistency checks.** The exact rational primal/dual verifier includes symmetric linear, parity, majority, quadratic and oscillating multilevel controls through n=24; every case satisfies the stronger c=4 candidate, hence also this restricted c=1 theorem. Its 20 low-n full-cube LP comparisons independently confirm the K used here is the *genuine* full pairwise row cost. The proof itself does not depend on those tests.

**Sharper auxiliaries must be audited separately.** The tempting stronger bound K>=n sqrt(E_{Bin(n-1,1/2)}[(Delta h)²]) is FALSE already for the n=3 fair majority threshold h=(0,0,1,1): exact K=2, while n sqrt(E Delta²)=3 sqrt(1/2)>2. This counterexample does NOT refute the theorem above or the c=4 target. It demonstrates why the robust proof uses maximal-edge multiplicity and the (n+1)/2 factor rather than an invalid global edge RMS estimate.

**Mechanism / transfer:** an entire permutation orbit of maximum-size edges forces a distributed pointwise row budget. Combine orbit multiplicity with original-law conditional variance and Efron–Stein. For arbitrary nonsymmetric f, the maximum edge may have orbit size one (a dictator); direct-sum reduction handles isolated dictators, but no universal orbit-multiplicity lower bound holds. **The remaining target is a decomposition or cross-threshold operator covering all connected high-overlap components, not another symmetric reduction.** This result is a restricted family theorem, not a resolution of Turturean §9.5 and not yet independently reviewed or checked against full prior art.

---

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

## Exact product-feature quotient isometry (author mathematical proof)

**General lemma: arbitrary finite alphabets, not just binary.** Let each original independent coordinate X_i have an arbitrary finite alphabet A_i and probability mass, possibly with zero atoms. Restrict each coordinate to its positive-probability support A_i^+. Let φ_i:A_i^+→B_i be any surjective finite feature map. Define h on the entire supported feature product ∏B_i and f(x)=h(φ_1(x_1),...,φ_n(x_n)). Then:

1. For **every** supported categorical source point x, its optimal genuine full pairwise fractional-row cost is exactly the feature-row cost at φ(x): κ_f(x)=κ_h(φ(x)). Consequently **K(f)=K(h)** with no alphabet-size or minimum-atom factor.
2. The original source variance of f equals the variance of h under the product of feature-pushforward laws.
3. For each i, the original-law resampling influence I_i(f)=E Var(f|X_{-i}) equals I_i(h) under the feature-pushforward law, even when source-letter weights are unequal.

**Proof of (1), both directions.** If w is a feasible feature row at b=φ(x), then for every categorical y, the set of differing feature coordinates is contained in the set of differing categorical coordinates. Since w_i≥0, the feature row inequality immediately supplies a categorical row of equal cost. Conversely, given a categorical row w at x, and any feature target b', choose y_i=x_i when b'_i=b_i, and otherwise choose a letter in A_i^+ mapping to b'_i (surjectivity). Then the categorical-difference set between x and y equals the feature-difference set between b and b', exactly. The categorical row inequality therefore certifies the feature row with the SAME weights and cost. Minima agree at every point. Surjectivity of the product maps gives equality of maximal row costs.

**Proof of (2)-(3).** A coordinatewise image of independent variables is independent and has exactly the pushforward marginal. The full distribution of h(φ(X)) equals the resulting feature-product law; conditioning on the other coordinates, the two-point (or multi-feature) random variable h(b_{-i}, φ_i(X_i)) has exactly the feature-pushforward conditional variance. No positive atom floor or lift sampling is required.

**Corollary: categorical symmetric-feature all-degree exponent two.** Take B_i={0,1} on the active feature coordinates and h(b)=g(Σ_i b_i), any arbitrary real function. The full-row and original-source influence/variance identities lift the proved binary theorem to the original categorical product:

    Var_p(f)² <= [m/(m+1)]² K_p(f)² max_i Inf_i^p(f)
              <= K_p(f)² max_i Inf_i^p(f),

where m is the number of active feature coordinates (those whose pushforward gives positive mass to both bits). Frozen-feature coordinates are removed and shift g by their fixed bit sum; if m=0, f is constant. This covers independently sampled, heterogeneous alphabet sizes, zero-mass source symbols, and unbounded categorical labels. It still does NOT prove the unrestricted Turturean row conjecture: general f need not factor through one binary feature per coordinate, much less a symmetric aggregate.

**Transfer frontier:** Exact quotient invariance is reusable when a system representation really factors through independent coordinate features. It cannot be applied by claiming an arbitrary f has such a factorization, nor by replacing exact feature maps with lossy encoders. Novelty relative to classical quotient/LP symmetry literature remains unassessed.

---

## General orbit-density mechanism (author proof, conditional structural class)

The symmetric theorem is a corollary of a more general *maximal-edge multiplicity* certificate for arbitrary real functions on the binary cube with any independent product source (including heterogeneous biases).

Define D=max_{x,i}|f(x)-f(x^i)|. If D=0, f is constant. Suppose at some vertex x at least m>=1 distinct coordinates i attain the *global* maximal edge increment D. Every full fractional row at x must assign each such coordinate >=D, so K>=mD. For original-law independent binary marginals,

    I_i = p_i(1-p_i) E[(f(X_{-i},1)-f(X_{-i},0))²]
        <= D²/4 <= K²/(4m²).

Ordinary Efron–Stein yields V<=sum_i I_i<=nM. Consequently

    V² <= (n/(2m))² K² M.

For any family with m>=rho*n for a fixed rho>0, this is a dimension-free all-degree exponent-two bound with c=4*rho². Symmetric h(|x|) has m>=max(n-k,k+1)>=(n+1)/2 for an edge attaining D, recovering c=(n+1)²/n².

### Connectedness alone does not guarantee maximal-edge orbit density

**Exact adversarial family.** On the fair n-cube, for any n>=2 and 0<ε<1, take

    f_ε(x) = x_1 + ε (∏_{j=1}^n x_j),     x_j∈{0,1}.

The highest-order Fourier/ANOVA coefficient is nonzero (proportional to ε), so its interaction support hypergraph contains all n coordinates in one **connected** high-order edge. Nonetheless the largest singleton flip magnitude is D=1+ε and occurs ONLY on the edge changing x_1 while all other bits are 1. Thus **at every vertex the number of incident edges of size D is at most one**, and the maximal-edge multiplicity parameter m=1 for arbitrarily large n. This blocks any attempted implication “connected ANOVA support => m≥ρn” with universal ρ>0. It does NOT refute the row conjecture: the family approaches a dictator as ε→0 and remains covered by other mechanisms.

Exact Fraction enumeration on n=3,5,10 at ε=1/n² returned D=1+ε and m=1 in every case. Its all-n derivation is elementary, but not formally Lean checked or externally reviewed. A genuine all-degree solution must combine orbit-density and other structural operators **quantitatively**, rather than assume that connectedness forces density.


**Scope and proof-attack:** This is useful only when maximal edges have a large common-vertex orbit. A dictator has m=1 and n arbitrarily large despite satisfying the sharp row inequality by a different (direct-sum) argument. A universal conclusion cannot follow by assuming a dimension-free rho. The natural next operator is a decomposition of f into orbit-dense components and low-dimensional direct-sum components *without losing the row K budget*. This is a proposed generalization target, not an established universal decomposition theorem.

---

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
