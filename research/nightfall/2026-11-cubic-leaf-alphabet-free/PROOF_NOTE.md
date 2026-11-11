# Cubic influence without leaf-alphabet dependence — top-degree covers and independent selector networks

**Checkpoint:** 10 November 2026 ET / 11 November UTC. **Research lead:** Devin J. Wright / NIGHTFALL Constellation. **Status:** analytic deduction from the quadratic product-space influence theorem in [spectral observability v3/v4](../2026-11-spectral-observability/README.md). The new deductions have not been independently refereed or Lean-compiled and are not certified globally original results. The unrestricted degree-three exponent-two bound is still OPEN.

## Exact theorem

Let f be a real function with |f|<=B and Hoeffding degree at most three on a product of arbitrary independent probability spaces. Put V=Var(f), M=sup_i I_i(f), with Efron–Stein I_i=E[(f-E_i f)^2]. Assume that a set H of t coordinates intersects every nonzero cubic Hoeffding support. **Only cubic interactions must be covered; pair interactions may be arbitrarily dense.** Set D=16(1+sqrt(3)), the v3 quadratic constant.

Then

    V <= D B sqrt(M) + t M <= (D+t) B sqrt(M),
    M >= V^2 / [(D+t)^2 B^2].

No dependence on leaf alphabets, number of leaves, or marginal atom sizes. The exponent of V is **two**, unlike the all-degree (5/2) theorem.

### Proof

Let g=E[f | X_(J\H)]. By ANOVA, g=sum_(S disjoint H) f_S, so deg(g)<=2. Conditional expectation preserves |g|<=B and satisfies I_i(g)<=I_i(f) for i outside H; I_i(g)=0 for i in H. Therefore the quadratic theorem gives Var(g)<=D B sqrt(M). ANOVA orthogonality yields

    V-Var(g) = sum_(S meeting H) ||f_S||_2^2
             <= sum_(i in H) I_i(f) <= tM.

Moreover M<=Var(f)<=B^2, proving the displayed result. Rectangular finite-partition L2 approximation extends the argument to non-atomic alphabets and arbitrary coordinate index sets; the H-cover property survives coarsening.

This strengthens the earlier restricted vertex-cover theorem in Wright_Restricted_Exponent_Two_Proof_Note.tex: its cover met *every* interaction of order >=2, leaving an additive function. This theorem needs to cover **only size-three supports**, leaving the entire quadratic interaction network intact.

## Stronger structural result: any number of independent cubic stars

Suppose, in L2,

    f=c+sum_b f_b(X_(S_b))

with disjoint independent blocks S_b. Each f_b has degree<=3 and its cubic supports admit a cover of at most t coordinates (different hubs for different blocks are permitted), where t is fixed; the number of blocks, the block dimensions, and leaf alphabets are unrestricted. Then

    Var(f) <= (D+t) B sqrt(M).

Proof: let R_b be the essential range width of f_b. Independence and |f|<=B imply sum_b R_b<=2B, even with countably many blocks by finite conditional projections. Shift f_b to its range midpoint, making |f_b|<=B_b=R_b/2 without affecting variance/influences. Apply the preceding theorem blockwise with M_b<=M and M_b<=B_b^2:

    Var(f_b) <= (D+t) B_b sqrt(M_b)
              <= (D+t) B_b sqrt(M).

Sum; sum_b B_b<=B. Thus *even arbitrarily many disconnected repeated-pair sunflower blocks* retain the same alphabet-free exponent-two coefficient. This class is not covered by the original linear-support theorem, whose distinct cubic hyperedges may intersect in at most one vertex.

## Exact categorical witness and sharp exponent

For m>=2 let A,B be independent uniform addresses in [m], and let D_(a,b) be independent **uniformly distributed** leaves, each on any even alphabet of cardinality L>=2. Choose phi to take +1 on exactly half of its alphabet and -1 on the other half, so E[phi(D_ab)]=0 and E[phi(D_ab)^2]=1 and define

    h(A,B,D)=phi(D_(A,B)).

This is bounded by one and has Hoeffding degree exactly three. Cubic supports all meet A (or B), regardless of m or L. Direct conditional variance shows

    Var(h)=1,
    I_A(h)=I_B(h)=1-1/m,
    I_(D_ab)(h)=1/m^2.

The total *leaf* root-sum influence is sum_(a,b) sqrt(I_(D_ab))=m, which diverges. Hence the all-alphabet proof cannot go through a universal sum_i sqrt(I_i) bound.

For k independent copies h_b let f_k=k^(-1)sum_b h_b. Then |f_k|<=1, deg(f_k)=3, and

    Var(f_k)=1/k,
    M(f_k)=(1-1/m)/k^2=(1-1/m)Var(f_k)^2.

This establishes sharpness of exponent two even within the covered cubic selector class, with unbounded number of blocks, leaf coordinates, and alphabet cardinality. It does not prove the optimal leading constant.

## Nonadaptive impossibility / adaptive transition

For h alone, a fixed nonadaptive observer that queries q leaves has squared risk >=1-q/m^2, even if both address values are disclosed to it after its query set is fixed for free. Therefore achieving eta<1 needs q>=(1-eta)m^2. The same holds for query sets randomized independently of input values. In contrast an adaptive observer exactly determines h after three queries: A, B, and then the selected leaf. Thus **removing alphabet dependence from the unrestricted nonadaptive categorical theorem is impossible**, although the new adaptive influence and cover results are alphabet-free.

## Adaptive scalar prediction

Cubic top-cover and independent-block conditions persist under conditioning on any queried coordinates. At every reached posterior apply V<=C B sqrt(M) with C=D+t. The total ANOVA influence T obeys V<=T<=3V and the exact decrement E_(X_i) T(f|X_i)=T(f)-I_i(f). Greedy maximum-influence querying yields

    p_(n+1)<=p_n-p_n^2/(9 C^2 B^2),
    p_n<=9 C^2 B^2/n.

The conditional-mean squared risk is at most eta after at most ceil(9(D+t)^2 B^2/eta) whole-coordinate queries, **independent of the number and alphabet sizes of leaf variables**. No bound on the computational cost of choosing coordinates is claimed.

For Hilbert outputs with rank r and a **single global top-degree cover H**, importing the separate v3 quadratic Hilbert theorem gives

    V(F) <= [D/a_r+t] B sqrt(M(F)),
    N <= ceil(9 [D/a_r+t]^2 B^2/eta),

where a_r=Gamma(r/2)/(sqrt(pi) Gamma((r+1)/2)), and leading-r covariance projection adds tail error tau_r. Fixed t implies O(r/eta) observation order. This last vector assertion requires the Hilbert quadratic premise; it is **not** automatically asserted for the independent-block variant.

## New Hilbert extension for arbitrarily many independent covered blocks

Let F be a bounded B, real Hilbert-valued observable, decomposable into independent disjoint degree-three blocks, each with a top-degree cover of at most t inputs. Set C=D+t. For any r>=1 and eta>0, **even when the number of blocks and all leaf alphabets are unbounded**, there exists a deterministic measurable adaptive observer with

    E||F-E[F|transcript]||^2 <= tau_r + eta,

after at most

    N=ceil[48 C^2 B^2 r / eta * log(1+12 C^2 B^2 r/eta)]

whole-coordinate queries. This gives rank-sensitive O_t((r/eta)log(2+r/eta)) observation without alphabet factors; the remaining logarithm is not claimed optimal.

**Proof:** Project to the first r covariance directions. On every posterior, choose a covariance eigenbasis for the proof, and for each fair-sign vector eps define scalar h_eps=<eps,G>. It has |h_eps|<=sqrt(r)B, preserves the independent-block/top-cover premise, and has Var(h_eps)=v=Var(G). The scalar theorem gives

    max_i eps^T A_i eps >= k v^2,   k=1/(C^2 r B^2),

where A_i are PSD influence matrices and p=sum_i tr A_i. Gaussian linearization and cosh(x)<=exp(x^2/2) imply E exp(eps^T A_i eps/(4 tr A_i))<=sqrt(2). Convexity and Jensen give

    kv^2 <= 4m log(1+(sqrt(2)-1)p/m),

for m=max_i tr A_i, and inversion yields m>=kv^2/[8 log(1+4p/(kv^2))]. The perspective function (m,p)->m log(1+a p/m) is concave, so the same inequality survives averaging posterior transcripts. Since v<=p<=3v, choose the coordinate of maximum trace influence and use the exact ANOVA potential decrement p_next=p-m. For U=3/(k eta), H=log(1+4U), the capped integral Phi(z)=(8H/k)integral_0^z max(eta,s/3)^(-2)ds loses >=1 per query while v>eta, and its supremum is 16UH. This gives the displayed N. The orthogonal output tail adds tau_r. The eigenbasis is only a mathematical witness; the decision policy does not require a measurably chosen eigenbasis.

This is an analytic reuse of the v4/v1 random-sign transfer. It is NOT separately Lean-compiled or externally refereed, and does not prove O(r/eta) for general independent covered-block Hilbert outputs.

## Verification, source boundary, and next gate

The local independent standard-library exact checker ran 212 checks: 128 random heterogeneous finite cubic-star product laws, 60 address/leaf alphabet families, 24 disjoint network formulas. It checks ANOVA variance split and influence contraction via *direct conditional expectations*, not the analytic proof mechanism. No violations; numerical testing does NOT certify global mathematical validity.

Original PDF and ZIP inputs and detailed proof with executable checker are supplied in the associated session artifact (not a GitHub release asset). The previous quadratic theorem is the cited mathematical premise; the full open cubic conjecture, interlocking repeated-pair links with no bounded top-degree cover or independent-block decomposition, human referee review, and worldwide priority are unresolved.

**Next operator:** use the top-degree-core averaging to peel identifiable sunflower cores, then attack the interlocking residual. A universal cost bound for that peeling—independent of core count—would remove the remaining structural restriction; neither this note nor finite tests establishes it. Relevant published antecedent: David Turturean, arXiv:2611.09773 (2026-11-06), whose general Boolean-cube result has variance exponent 5/2.
