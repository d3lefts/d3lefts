# Poly-d exponent-two (fair cube): dyadic two-replica quadratic proxy, v0.1

2026-11-18. **Status: author-side analytic reduction plus an exact counterexample to a stronger intermediate inequality; not a proof of exponent two, not Lean-checked or independently refereed.** Research direction NIGHTFALL / Devin J. Wright; AI-assisted mathematical derivation. No priority claim.

## Objective and checked external reference

Target: for every n,d>=1 and real degree<=d function f on independent fair signs, with centered essential radius B=(max f-min f)/2, variance V and genuine fair resampling influence M=max_i sum_{S containing i} fhat(S)^2, prove V^2 <= C d^beta B^2 M with polynomial d and alpha=2. In particular beta<=6 would strengthen the variance exponent of Turturean (arXiv:2611.09773, section 9.5), whose theorem has alpha=5/2, beta=6. Defant--Mastylo--Perez (Math. Ann. 2019; cited in Turturean section 1.4) already established alpha=2 with d^4 exp(4d). This note claims no novel fixed-d exponent-two result. Consult merged flagship PR #805 and cubic draft #807. This is **the uniform-cube branch, not the arbitrary-product Q3 branch**.

## Exact construction

Let f be a Walsh polynomial of degree<=d and let h=f-c, where c is the midpoint of its range, so |h|<=B. For d>=2 let m=ceil(log2 d). Independently sample K uniformly from {1,...,m}; put t=2^(-K). Sample X uniformly on {-1,1}^n, and independently flip every site of X with probability t to obtain Y. (This is exactly a *fair original-law refresh* of probability 2t, not an arbitrary biased auxiliary source.) For selector sigma in {-1,1}^n independently uniform, set W_i(sigma)=X_i if sigma_i=+1 and Y_i if sigma_i=-1. Define g_{X,Y}(sigma)=h(W(sigma)) and Q_{X,Y}=Pi_{sigma,levels 1 and 2}g_{X,Y}. All Q are fair-cube quadratic polynomials in selector sigma.

For a Walsh support S of size s>=1, write

w_s(t)=s t (1-t)^(s-1) + binom(s,2) t^2(1-t)^(s-2), with the second term zero for s=1;

v_s(t)=t (1-t)^(s-1) + (s-1)t^2(1-t)^(s-2), with the second term zero for s=1.

Set U=E_{K,X,Y} Var_sigma(Q), J_i=E_{K,X,Y} Inf_i^sigma(Q), and A=esssup_{K,X,Y,sigma}|Q|.

**Proposition A (author-side derivation, exact spectral identities).**

(1) U=sum_{nonempty S} fhat(S)^2 E_K[w_|S|(t)].

(2) J_i=sum_{S containing i} fhat(S)^2 E_K[v_|S|(t)].

(3) V/(6m) <= U <= V, J_i <= (1/m) Inf_i(f), and A <= d(d+2) B/2.

Proof of (1),(2): If D={i:X_i != Y_i}, then W_i(sigma)=X_i sigma_i on D and X_i otherwise. Thus each chi_S(W(sigma)) equals chi_S(X)chi_{S intersect D}(sigma). When averaging over uniform X, distinct S Fourier cross terms vanish. |S intersect D| is Binomial(s,t), giving w_s and v_s exactly. The identity concerns genuine source-coupled replicas; no artificial independent site coefficients.

For (3), for each 1<=s<=d select k=max(1,ceil(log2 s))<=m, so st is in [1/2,1] and (1-t)^(s-1)>1/3 (for s=1 this is 1). Hence w_s(t)>=1/6, and the uniform mixture supplies at least 1/(6m). For each i, v_s(t)<=t by the event interpretation: i lies in D and |S intersect D|<=2. Since sum_{k=1}^m 2^(-k)<1, J_i <= Inf_i(f)/m. For amplitude: for fixed sigma, P(rho)=T_rho g(sigma) is a polynomial in rho of degree<=d, bounded by B on [-1,1]. The trigonometric polynomial P(cos theta) has sup<=B, hence classical trig Bernstein at theta=pi/2 gives |P'(0)|<=dB and |P''(0)|<=d^2 B. Since Q=P'(0)+P''(0)/2 at sigma, A<=d(d+2)B/2. All inequalities are exact, with no n in the bound.

## Conditional exponent-two reduction, one remaining gate

**Proposition B (conditional, NOT a theorem about all f).** If a universal constant C exists such that **every source-coupled dyadic Q from this construction** satisfies

    (DYADIC-ANNEALED-Q2-d): U^2 <= C*d*A^2*max_i J_i,

then the full degree-d uniform-cube polynomial exponent-two bound follows:

    V^2 <= 36*C*d^6*B^2*M   (d>=2).

Indeed V<=6mU and max J_i<=M/m imply
V^2<=36 C m d A^2 M<=9 C m d^3(d+2)^2 B^2 M<=36 C d^6 B^2 M, using m<=d, d+2<=2d. Degree 1 already has V^2<=B^2 M exactly. Thus the **unproved** problem is a *source-coupled annealed quadratic energy inequality with linear degree loss*, not a naive unconditional annealed Q2 inequality.

## Exact falsifier for the too-strong degree-free gate

**Proposition C (analytic counterexample, exact).** For every d>=2, take h(x)=prod_{i=1}^d x_i (pure parity, B=V=M=1), with a single refresh-disagreement probability t=1/d rather than the dyadic mixture. For any (X,Y), g(sigma) is exactly a character on D={i:X_i!=Y_i}; Q is that character iff |D|=1 or 2, and is 0 otherwise. Hence A=1 and

    U=(3/2)(1-1/d)^(d-1),
    J_i=(2/d)(1-1/d)^(d-1),
    U^2/(A^2 max_i J_i)=(9d/8)(1-1/d)^(d-1) ~ 9d/(8e).

So no universal dimension-free C can satisfy U^2<=C*A^2*Jmax, **even for authentic source-coupled families**. On the actual dyadic mixture, J_i<=2U/d and U>=1/(6m), so U^2/Jmax >= d/(12m), which diverges at least as d/log d. The linear-degree gate in Proposition B is therefore appropriately relaxed; the present counterexample does NOT refute it or the underlying UE2 conjectures. This also does not refute the specialized cubic source-coupled gate in PR #803, where d is fixed to 3.

## Reproducible exact finite certificate and limitations

Run `python3 -I research/nightfall/flagship-influence/check_poly_d_dyadic_proxy.py`. The checker constructs selector tables independently from the original Walsh support-binomial formulas and compares exact Fraction U/J for d=1,3,5 on fair cubes n<=5, including pure parity, and checks rational-safe amplitude and energy bounds. It also computes the parity no-go ratio exactly through d=128. A green arithmetic replay verifies finite fixtures, not Proposition A for every n or the missing Proposition B. No independent proof auditor or Lean formalization has been run.

**Adversarial next experiment (pre-registered):** attempt to refute the linear-degree gate by evaluating exact U^2/(d A^2 Jmax) on coherent address/leaf selectors, tribes, pure parity, Chebyshev, and dense overlapping random Walsh supports, first n<=7. If a counterexample grows with n or d, abandon the gate and seek a variance-conditioned or block-congestion replacement; if finite tests pass, prove the source-coupled routing inequality before any formalization. Stop after these five adversarial families without a structural mechanism. No publish/merge until independent math audit and prior-art screening.

**Discovery graph:** fair Walsh representation -> random paired flip/selector -> dyadic spectral filter -> finite spectral certificate -> parity no-go for degree-free annealing -> open linear-d source-coupled quadratic gate -> potential transfer to N-UE2(6).


## v0.2 exact adversarial test of the UNPROVED linear-d gate (2026-11-18)

A **separate exact Fraction/Walsh checker** (`check_poly_d_proxy_gate_stress.py`) reconstructs the true maximum amplitude A by enumerating every live/fixed selector subset and complete signed cube, *not* estimating A from the upper Bernstein envelope. It tests the exact necessary coefficient `C_required=U^2/(d*A^2*max_i J_i)` on 110 source-compatible n=6 models: additive, degree-2 parity, degree-6 parity, a 2-address/4-leaf selector, width-2 tribes, Chebyshev degrees 2..6, and 100 deterministic sparse mixed-degree Walsh stress samples (seed 20261118). The maximum was **9/16**, attained by degree-2 parity; additive gave 1/2, selector 5041/18792, and tribes 2164905728118005/25471012030119936. All arithmetic exact rational; the main dyadic checker independently compares selector tables to binomial spectral identities.

This is **finite counterexample hunting only**. It does NOT prove C=1, any finite universal C, or the reduction's mathematical novelty. It demonstrates that the parity counterexample to degree-FREE annealing is *compatible* with the conjectured linear-d gate in these tested models. The low-cost next decisive test is exact/symbolic analysis of address-gated rare-event families where instantaneous influential coordinate routing is much more dispersed than averaged influences; never use an unproved E(max_i j_i) <= O(d) max_i E(j_i) shortcut.


## v0.3 analytic structural gates and exponential-leaf selector certificate (2026-11-18)

**Scope:** new author-side *restricted-family* proofs of the still-unproved DYADIC-ANNEALED-Q2-d with C=1, and a C=4 direct-sum transfer. None proves polynomial-d exponent two for unrestricted bounded f. The underlying fractional-cover argument overlaps and credits NIGHTFALL #809/#813; no priority or external referee claim. The proof uses the exact existing source-coupled construction above, not arbitrary independent random quadratic families.

### Binomial two-level lemma (elementary, exact)

For every integer s>=1 and 0<t<=1/2, let L~Binomial(s,t). Then

    P(1 <= L <= 2) = w_s(t) <= 3/4.

For s=1, w_1=t<=1/2. For s=2 and s=3, w_2=2t-t^2<=3/4 and w_3=3t(1-t)<=3/4. For s>=4, set q=t/(1-t) in [0,1], z=sq. Then

    w_s=(s q + binom(s,2) q^2)/(1+q)^s,

and the binomial expansion gives

    3(1+q)^s-4[s q+binom(s,2)q^2]
    >= 3-sq-binom(s,2)q^2+3 binom(s,3)q^3
    >= 3-z-z^2/2+3 z^3/16 > 0.

The last strict inequality follows from the polynomial certificate

    48-16z-8z^2+3z^3
    = 3z(z-3)^2 + 10(z-43/20)^2 + 71/40 > 0 (z>=0).

The coefficient of z^3 is bounded below by 3/16 since 3 binom(s,3)/s^3=(s-1)(s-2)/(2s^2)>=3/16 for s>=4. This proves the all-s lemma by exact algebra.

### Theorem S: common-source-site support, C=1

If every nonconstant Walsh support S with fhat(S) != 0 contains a fixed site i0, then for *any* distribution of source-pair flip probabilities t in (0,1), including the dyadic mixture,

    U^2 <= d A^2 J_i0 <= d A^2 max_i J_i.

Indeed w_s=Pr(L=1)+Pr(L=2), s v_s=Pr(L=1)+2 Pr(L=2), hence w_s<=s v_s<=d v_s. Spectral Parseval gives U<=d J_i0. Independently, |Q|<=A and E_sigma Q=0 give U<=A^2. Multiply. This is a restricted support case only.

### Theorem M: disjoint Walsh monomial supports, C=1

If f=c+sum_a c_a chi_{S_a} with pairwise *disjoint*, nonempty S_a, |S_a|<=d, then for any mixture of source-pair probabilities t in (0,1),

    U^2 <= d A^2 max_i J_i.

Choose a disagreement set D containing exactly one distinct representative from each S_a. The corresponding quadratic projection Q is a linear selector polynomial with mutually independent selector signs, and its amplitude equals sum_a |c_a|; because every D has positive probability, A>=sum_a|c_a|. Put w_a=E_t w_|S_a|(t), v_a=E_t v_|S_a|(t). Exact Parseval gives U=sum_a c_a^2 w_a and Jmax=max_a c_a^2 v_a. Since 0<=w_a<=1 and w_a<=|S_a| v_a<=d v_a,

    U <= (sum_a |c_a|) max_a (|c_a| w_a)
      <= A sqrt(Jmax) sqrt(d).

This is an exact coefficient-one subclass.

### Theorem T: direct-sum closure with factor four

Suppose f=sum_a f_a on pairwise disjoint nonempty coordinate blocks, all degrees <=d, with the *same* dyadic distribution K and the same global degree parameter d used for every proxy. If each block satisfies U_a^2<=C d A_a^2 Jmax_a, then

    U^2 <= 4 C d A^2 Jmax.

Conditional on K,X,Y, each Q_a has zero selector mean and depends on disjoint selector bits. Hence U=sum_a U_a and Jmax=max_a Jmax_a. All disagreement sets have positive probability at each dyadic t, so the full source-pair/sample *range* of the sum of Q_a is the sum of individual ranges. Each individual range is at least A_a (zero-mean selector polynomial), while the global range is at most 2A; therefore A >= (1/2)sum_a A_a. Cauchy/triangle completes the stated inequality. This gives, for example, C=4 for arbitrary disjoint sums of star-supported components, even with an unbounded number of blocks. A factor-four transfer is not a claim that C=4 is sharp.

### Theorem ASEL: k-bit address chooses 2^k fair leaves, C=1 for every k

For each k>=1 let A=(A_1,...,A_k) be independent fair address bits and Y_a (a in {0,1}^k) be 2^k independent fair leaves. Set f(A,Y)=Y_A, with Walsh degree d=k+1 and B=V=1. For a source-pair flip probability t in (0,1/2], define a=1-t/2 and u=1-t. Directly summing the Fourier levels 1+Bin(k,1/2) yields exactly

    U_t=t a^k +(k t/2)a^(k-1) +[k(k-1)t^2 u/8] a^(k-2),
    J_addr,t=(t/2)a^(k-1) +[(k-1)t^2 u/4] a^(k-2).

Terms with a prefactor k-1 are defined to be zero when k=1. Every address coordinate has the same J_addr. The formulas follow independently by summing 2^(-k)binom(k,r) w_(r+1) and 2^(-k)binom(k-1,r-1) v_(r+1) over r. Their difference gives

    U_t <= k J_addr,t + t a^k <= (k+2) J_addr,t,

since J_addr,t >= (t/2) a^(k-1) and a<=1. The inequality survives any mixture of source-pair t in (0,1/2]. Moreover A>=1: choose identical address words in the source pair and flip only the selected leaf, giving a selector dictator Q=+/-sigma_leaf.

For k>=2, the above binomial lemma and total Fourier mass sum=1 imply U<=3/4. Therefore

    U^2 <= (3/4)(k+2) J_addr <= (k+1) A^2 J_addr.

For k=1, U_t=(3t-t^2)/2<=5/8 on (0,1/2], and U<=3 J_addr. Consequently U^2<=15/8 J_addr <2 A^2 J_addr. Thus **for every k>=1 and any dyadic (or other supported 0<t<=1/2) mixture**,

    U^2 <= (k+1) A^2 max_i J_i = d A^2 Jmax.

This analytically excludes the canonical exponential-leaf address family as a counterexample to the C=1 linear-degree proxy gate. It does not exclude other connected high-overlap supports or prove C=1 universally.

### Independent arithmetic replay and next falsification priority

The updated exact checker compares the two *separately derived* address spectral formulas for k=1..16 at five rational scales, verifies the exact C<=1 consequence for all dyadic selector families k=1..128, verifies the nonnegative integer/rational SOS identity, and adds star/matching finite fixtures. These tests support and challenge the written author-side proof but are **not** Lean or human-independent proof review.

Remaining decisive search: connected high fractional-cover support hypergraphs without a common vertex, with substantial interacting overlaps not decomposable into disjoint monomials or selector address blocks. Optimize the actual A over every supported source-disagreement set; do not substitute the d^2 B amplitude upper bound. If no structural counterexample emerges, look for a global source-coupled overlap-congestion operator. The universal C=1 gate and unrestricted exponent-two claim both remain **OPEN**.
