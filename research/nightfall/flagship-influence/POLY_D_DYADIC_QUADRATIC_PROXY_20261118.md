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


## v0.4 STRUCTURAL PIVOT: linear-only dyadic source proxy (preferred conditional target)

**Research status:** Exact author-side spectral reduction and three analytically proved restricted families; all-degree linear-annealed gate remains **OPEN**. This improves the *conditional* d-dependence from O(d^5 log d) of the quadratic projection to **O(d^3 log d)**, NOT an unconditional influence theorem. Never represent the conditional theorem as a completed proof. Earlier quadratic results v0.1–v0.3 remain archived; this is a representation change, not a retrospective claim of solving the main conjecture.

### Proposition L (exact source-coupled first-chaos representation)

Keep the genuine two-replica paired construction and dyadic K from v0.1 but replace Q by

    L_(X,Y)(sigma) = Pi_{selector Fourier level 1} h(W(sigma)).

Let U1=E_{K,X,Y} Var_sigma L, J1_i=E_{K,X,Y} Inf_i^sigma L, and A1=esssup |L| over all supported K,X,Y,sigma. Write

    w1_s(t)=s t (1-t)^(s-1),    v1_s(t)=t (1-t)^(s-1).

The same source-orthogonal Fourier derivation gives the *exact* identities

    U1=sum_{S != empty} fhat(S)^2 E_K w1_|S|(t),
    J1_i=sum_{S containing i} fhat(S)^2 E_K v1_|S|(t).

For m=ceil(log2 d), d>=2, the source-consistent invariants improve to

    V/(6m) <= U1 <= V,
    J1_i <= Inf_i(f)/m,
    A1 <= d B.

For each 1<=s<=d choose dyadic t in [1/(2s),1/s]; then w1_s(t)>=1/6, because (1-1/s)^(s-1)>=1/e>1/3. The sum of dyadic t is <1. For the amplitude, if P_x(rho)=T_rho(g_(X,Y))(sigma) on the fair selector cube, then L=P_x'(0); P_x is a degree-d polynomial bounded by B on [-1,1], so the classical trigonometric Bernstein derivative bound gives |P_x'(0)|<=dB. No source-independent fake coefficient distribution is used.

### Sharper sufficient gate: polynomial d^3 log d, CONDITIONAL

The new unknown source-coupled inequality is

    (LIN-ANNEALED-d): U1^2 <= C*d*A1^2*max_i J1_i

for one absolute C for **all original bounded degree<=d fair-cube sources**, using the dyadic paired construction above. If it holds, then

    V^2 <= 36 C m d^3 B^2 M,  m=ceil(log2 d),

which is O(d^3 log d) in degree at variance exponent two. Proof: V<=6m U1, J1max<=M/m, and A1<=dB. In contrast the previous quadratic gate only conditionally gave 36 C m d^5 B^2 M (and its coarser 36 C d^6 statement). Neither gate has been proved universally; this reduction is a **research target, not a universal theorem**.

### Sharpness of the linear gate's degree loss within this representation

For pure parity f=chi_[d], A1=1, U1=d J1_i and U1>=1/(6m). Therefore

    U1^2/(A1^2 J1max) = d U1 >= d/(6m).

No linear-proxy annealed gate with degree loss o(d/log d) can hold universally, even for source-coupled families. Thus a linear-d loss is within a logarithmic factor of necessary for this *particular proxy method*. This does not establish that the original influence theorem needs a degree exponent 3.

### Restricted-family theorem L-S: common hub, C=1

When all nonconstant Walsh supports meet a fixed site i0, the exact identity w1_s=s v1_s<=d v1_s gives U1<=d J1_i0. Since L is selector-mean-zero and |L|<=A1, U1<=A1^2. Multiply:

    U1^2 <= d A1^2 J1_i0.

### Restricted-family theorem L-M: disjoint Walsh monomials, C=1/2

For f=c+sum_a c_a chi_(S_a) with pairwise disjoint nonempty supports, choose a source-disagreement set meeting each S_a exactly once. The resulting linear selector projection has amplitude sum_a|c_a|, so A1>=sum_a|c_a|. With averaged w_a,v_a, we have U1=sum c_a^2 w_a and J1max=max_a c_a^2 v_a. The binomial one-success estimate

    w1_s(t)=P(Bin(s,t)=1) <= 1/2   for 0<t<=1/2, s>=1

follows for s=1 directly, and for s>=2 by maximizing at t=1/s and using Bernoulli's inequality (1+1/(s-1))^(s-1)>=2. Hence w_a^2/v_a=s w_a<=d/2. Therefore

    U1^2 <= (d/2) A1^2 J1max.

This coefficient 1/2 is attained for a single degree-one fair dictator under the d=1, t=1/2 convention, so this restricted normalization cannot improve universally below 1/2.

### Restricted-family theorem L-T: exact no-loss direct-sum tensorization

For f=sum_a f_a on pairwise disjoint coordinate blocks under the *same* global d and K distribution, each L_a is a mean-zero **linear** selector polynomial on its own disjoint selector block. For each source pair, sup_sigma |L|=sum_a sup_sigma |L_a|, because the linear coefficients can be aligned independently. Every source-disagreement set has positive support at each K, so

    A1(f) = sum_a A1(f_a),    U1(f)=sum_a U1(f_a),
    J1max(f)=max_a J1max(f_a).

Consequently, if each block has L-gate constant C, then their disjoint sum has the **same C**, without the quadratic proxy's factor-four loss. In particular, an unrestricted number of disjoint common-hub components satisfies C=1, and an unrestricted number of disjoint-monomial components satisfies C=1/2. This is a conditional/direct-sum operator, not unrestricted LIN-ANNEALED-d.

### Restricted-family theorem L-ASEL: exponential leaves, C=1

For the k-bit address selector f(A,Y)=Y_A of v0.3, d=k+1, put a=1-t/2 and u=1-t. The original Fourier distribution of order 1+Bin(k,1/2) yields exactly

    U1_t=t a^k + (k t u/2)a^(k-1),
    J1_addr,t=(t u/2)a^(k-1).

Equivalently U1_t=(k+2a/u)J1_addr,t <= (k+3)J1_addr,t, since 0<t<=1/2 gives a/u<=3/2. Every source degree has w1_s(t)<=1/2 and the selector's source variance is exactly 1, giving U1<=1/2. The source pair with fixed address and only the selected leaf different gives a linear selector dictator, so A1>=1. Hence any mixture of t in (0,1/2], including the dyadic K, satisfies

    U1^2 <= ((k+3)/2) J1_addr <= (k+1) A1^2 J1max
         = d A1^2 J1max.

Thus the same coefficient-one gate holds for ALL k>=1, despite 2^k distinct leaf coordinates. Exact direct Fourier-binomial and closed-form replay accompanies this proof.

### Independent attacks, reviewer gates and proof status

The existing exact checker now also checks 110 signed finite Walsh models against the *actual* linear-projection amplitude (all discrepancy sets), and compares independent address Fourier/binomial formulas at rational t. A separate numpy numerical sweep of 2,600 sparse Walsh draws across n=6,8 and d=2..n found no linear-gate ratio >1; that sweep is **author-side exploratory only and is not an exact CI receipt**. Its current best ratio 1/2 arises from disjoint degree-two parities; do not interpret finite optimization as universal proof.

**Independent proof B (pre-specified attacks):** verify the first-chaos coefficient extraction and Bernstein bound at every supported pair; check tensorization with shared K (not independent K per block); look for connected overlap patterns that are neither hub supports nor disjoint monomials; optimize amplitude using *every* supported D before evaluating a candidate; compare with established fixed-degree DMP and Turturean quantitative statements. A formal kernel theorem and an external expert review remain absent. The conjectures N-UE2(6), N-UE2(2) and LIN-ANNEALED-d are all **OPEN**.

**Mechanism/transfer:** two-replica fair source -> first-chaos selector filter -> dyadic log-band energy preservation -> dB (rather than d^2B) amplitude -> no-loss block tensorization -> O(d^3 log d) **conditional** variance-exponent-two target; parity witnesses near-sharp proxy cost, address selectors exclude the simplest exponential routing obstruction.
