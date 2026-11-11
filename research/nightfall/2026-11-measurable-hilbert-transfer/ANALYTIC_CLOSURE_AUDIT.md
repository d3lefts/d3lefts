# Analytic closure and adversarial audit: measurable-product -> Hilbert -> adaptive observation

**NIGHTFALL Constellation · 2026-11-11 · research lead Devin J. Wright.**
**Status:** complete author-side mathematical reconstruction, conditional on pinned finite scalar Lean declaration; **not** external non-author refereeing, end-to-end measurable-product Lean certification, global priority, or authorization to publish a novelty claim.
**Distinct value from v1 supplement:** a single quantifier-complete transfer lemma with arbitrary completed products and a precise adaptive section construction, including all zero/degenerate cases. See papers/universal-observability/PROOF_SUPPLEMENT_v1.md for the earlier derivation. This note is an adversarial reconstruction, not an independently authored outside referee report.

## Statement and constants

Let I be any index set, and let (Omega_i, A_i, mu_i) be arbitrary probability spaces with product measure mu, possibly completed. Let H be a real Hilbert space and F:Omega -> H strongly measurable, ||F|| <= B almost surely, B>0. Assume L2 Hoeffding interaction degree at most d>=1 (all higher centered mixed differences vanish in L2). Let C=E[(F-EF) tensor (F-EF)] be its trace-class covariance, tau_r=tr(C)-sum_{j=1}^r lambda_j(C).

Write c_*=sqrt(3/12500)/pi^6 and U=d^7 B^3 r^(3/2)/(c_* eta^(3/2)), for eta>0 and integer r>=1. There exists a deterministic measurable nonanticipating policy that observes at most ceil((40/3) U log(1+4U)) DISTINCT whole-coordinate values and achieves

    E ||F-E[F | transcript]||^2 <= tau_r + eta.

Knowledge of the law and observable is assumed. No running-time bound, general correlated-law result, or quantum algorithm is asserted.

### Imported finite scalar premise: precise scope

Nightfall.ProductSpace.Influence.product_influence at pinned source e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb, CI 42929857470, establishes: for a finite product of a common finite alphabet with coordinate-dependent normalized masses and pointwise bounded indicator-monomial degree-d scalar h,

    max_i I_i(h) >= c_* A^(-3) d^(-6) Var(h)^(5/2),  |h| <= A,

where I_i(h)=||h-E_i h||_2^2, and E_i averages ONLY coordinate i. Merged PR #325, receipt 42932085109, certifies dependent alphabets and finite Hoeffding-degree equivalence. The inherited Boolean-cube theorem and level/certificate method are David Turturean's, arXiv:2611.09773.

## Lemma A. Countable support under arbitrary completion

Any event E in the raw product sigma field is measurable relative to a countable subproduct: the collection of such events is a sigma field containing the finite-cylinder generators. A completed-product event is equal mod mu-null sets to a raw-product event. A strongly measurable H-valued F is almost everywhere the limit of countably many finite-range simple functions; replace their measurable level sets by raw-product representatives. This gives a raw-product strongly measurable version F' that is a.e. equal to F and has one countable active coordinate set J, irrespective of the cardinality of I or separability of any individual A_i. Its essential Hilbert range is separable.

For each countably many required cylinder sets, choose a countable expression in finite cylinders. Collect the coordinate events from these expressions. Therefore there are countably many coordinate events across J whose associated sigma field makes F' measurable. Enumerate them, build finite rectangular product partitions G_n over finitely many coordinates, and arrange G_n increasing to the relevant sigma field.

**Null-set scope:** every identity below is in L2 or outside a joint countable union of null sets. Arbitrary values on sections in these null sets never change the policy's risk.

## Lemma B. Finite-to-measurable scalar transfer without loss

Let h be real, |h|<=A mu-a.s., interaction degree <=d and Var(h)=v. For rectangular G_n above, define h_n=E[h|G_n]. Then h_n -> h in L2 by martingale convergence; |h_n|<=A on every positive-mass cell. Let Q_n denote this orthogonal conditional-expectation projection. By tensor-product independence, Q_n E_i=E_i Q_n for every i: on an observed coordinate, finite partition averaging and full coordinate averaging commute; on an omitted coordinate, Q_n already averages that coordinate. Thus

    I_i(h_n)=||Q_n (Id-E_i)h||_2^2 <= I_i(h).

Moreover Q_n commutes with each centered mixed operator D_S=prod_{i in S}(Id-E_i). Hence D_S h_n=0 for all |S|>d. In the finite categorical space, after dropping zero-mass cells, this is equivalent to a POINTWISE indicator-monomial degree <=d representation (finite ANOVA components expanded in coordinate value indicators). The pointwise bound holds on all retained cells, so the pinned finite theorem applies. Therefore

    c_* A^(-3) d^(-6) Var(h_n)^(5/2) <= max_i I_i(h_n) <= sup_i I_i(h).

Pass to the limit. If v=0 the inequality is trivial. If A=0 then h is a.s. zero and likewise trivial. There is no atom floor, no countability assumption on ambient coordinate sigma fields, and no requirement for pointwise degrees on zero-probability cells.

## Lemma C. Countable Hilbert ANOVA and exact coordinate drift

For any strongly measurable bounded G with degree <=d, its countable-coordinate Hilbert ANOVA is the L2-orthogonal sum of G_S over finite S subset J. The finite-dimensional tensor decompositions converge by the product martingale theorem; all |S|>d energies vanish. Defining v(G)=E||G-EG||^2, I_i(G)=||G-E_iG||_2^2, and T(G)=sum_i I_i(G),

    v(G)=sum_{S nonempty} ||G_S||_2^2,
    I_i(G)=sum_{S contains i} ||G_S||_2^2,
    v(G)<=T(G)<=d v(G)<infinity.

After observing j, let G_xj be the residual section. Fubini/Tonelli gives for every i != j

    E_{xj} I_i(G_xj)=I_i(G).

After fixing j its influence is exactly zero. Consequently

    E_{xj} T(G_xj)=T(G)-I_j(G).

This identity is for the ACTUAL revealed coordinate value, not a simulated posterior kernel. It follows before applying any scalar influence inequality.

## Lemma D. Measurable adaptive coordinates without a regular conditional probability assumption

Fix an enumeration of J. On any finite index sequence (i_1,...,i_t), the corresponding section G_{x_i1,...,x_it} is jointly measurable on observed values and all remaining coordinates for a.e. history, by Fubini. Its residual law is the original product on unqueried coordinates because the indices are chosen nonanticipatingly. Scalar/Hilbert conditional moments and I_j of each remaining coordinate are measurable functions of observed values, obtained by section integration. Countably many finite index sequences and countably many centered mixed differences permit ONE union of null sets in which all degree and boundedness requirements may fail; redefine the algorithm arbitrarily there.

At any valid history, (I_i)_i is summable and nonnegative. If T>0, its positive supremum m is attained: infinitely many indices exceeding m/2 would contradict summability. Select the first maximizing index in the enumeration; its selection event is a countable intersection of measurable comparisons, hence measurable. If T=0, stop. The posterior section remains degree <=d for almost every valid branch by commuting the residual mixed operators with section evaluation and Fubini. Iterate for any fixed finite horizon. No regular conditional probability on a nonstandard Borel coordinate space, measurable eigenbasis selection, or simultaneous null-set choice over uncountably many indices is invoked.

## Lemma E. Hilbert rank-r influence: a PSD inequality with exact constants

First assume G has values in an r-dimensional real Hilbert space and ||G||<=B a.s. At any particular posterior choose an eigenbasis of its covariance, padding with zero eigenvalues; this basis need NOT vary measurably with the transcript. With v=Var(G), let

    A_i=E[(G-E_iG) tensor (G-E_iG)] >= 0,
    s_i=tr A_i=I_i(G), p=sum_i s_i, m=max_i s_i.

For every signs eps in {-1,+1}^r, scalar h_eps=<eps,G> has variance exactly v, absolute bound sqrt(r)B, and I_i(h_eps)=eps^T A_i eps. Lemma B yields

    sup_i eps^T A_i eps >= L := k v^(5/2),
    k=c_* B^(-3) d^(-6) r^(-3/2).

If A>=0 has trace s>0, write Z~N(0,A). The identity E_Z exp(eps.Z / sqrt(2s))=exp(eps^T A eps/(4s)) and cosh(u)<=exp(u^2/2) show

    E_eps exp(eps^T A eps/(4s))
    <= E_Z exp(||Z||^2/(4s))
    =det(Id-A/(2s))^(-1/2)<=sqrt(2).

The last comparison follows by expanding the nonnegative eigenvalues: prod_j(1-lambda_j/(2s))>=1-sum_j lambda_j/(2s)=1/2; valid even if A is singular. For s_i=0 we have A_i=0. For 0<s_i<=m, the convex exponential chord bound gives

    E_eps [exp(eps^T A_i eps/(4m))-1] <=(sqrt(2)-1)s_i/m.

Since all eps^T A_i eps >=0, exp(sup_i z_i)-1 <=sum_i(exp(z_i)-1). Use monotone convergence for countably many coordinates and then the lower bound L for EVERY eps:

    exp(L/(4m))-1 <=(sqrt(2)-1)p/m.

Taking logs gives

    k v^(5/2) <= 4m log(1+(sqrt(2)-1)p/m).

For v>0, m>0. Put t=L/(4m), y=4p/L. The function (exp(t)-1)/t increases strictly for t>0. At t0=2log(1+y), exp(t0)-1=y(y+2)>2(sqrt(2)-1)y log(1+y). Thus t<t0, and

    m >= k v^(5/2) / [8 log(1+4p/(k v^(5/2)))].

If v=0 then p=m=0. The proof does NOT exchange E max_i with max_i E.

## Lemma F. Expected posterior contraction, including degenerate histories

Let G have rank at most r. At time t define the random posterior variance v_t, total influence p_t and maximum influence m_t; denote EXPECTATIONS V_t, P_t, M_t. The posterior laws satisfy 0<=v_t<=p_t<=d v_t and p_t,m_t finite. A zero-variance history has p_t=m_t=0; extend m log(1+a p/m) continuously by zero at (0,0).

The map (m,p) -> m log(1+a p/m) for a=sqrt(2)-1 is jointly concave (the perspective of the concave logarithm), while v -> v^(5/2) is convex. Jensen applied in the proper direction gives

    k V_t^(5/2) <=4 M_t log(1+a P_t/M_t).

The exact measurable selection and Lemma C give the deterministic expectation identity

    P_(t+1)=P_t-M_t.

Let eta>0; if V_t>eta, P_t<=d V_t implies

    M_t >= k V_t^(5/2) / [8 H0],  H0=log(1+4U), U=d/(k eta^(3/2)).

Define the increasing concave potential

    Phi(z)=(8H0/k) integral_0^z max(eta,s/d)^(-5/2) ds.

For V_t>eta, concavity, the exact drift identity, and P_t/d<=V_t imply

    Phi(P_t)-Phi(P_(t+1))
      >=Phi'(P_t) M_t
      >=(V_t/max(eta,P_t/d))^(5/2)>=1.

Integrating explicitly gives Phi(infinity)=(40/3)U log(1+4U). The expected conditional risk V_t is nonincreasing by conditional expectation projection. If V_N>eta at N=ceil(Phi(infinity)), all previous steps cost at least one unit of nonnegative potential, contradicting N<=(Phi(P_0)-Phi(P_N))<Phi(infinity)<=N. Thus V_N<=eta with a hard deterministic query cap. If a particular history exhausts its active coordinates or reaches zero variance earlier, it stops; this does not affect the expectation identities.

## Lemma G. Orthogonal spectral tail and full Hilbert risk

Since C_F is positive trace class, choose a FIXED projection P_r onto the first r covariance eigenvectors (or its available rank). Let G=P_rF and R=(Id-P_r)F. Then G has finite rank <=r, ||G||<=B, degree <=d, and R has covariance trace tau_r. Query according to G's posterior trace influences, but predict the FULL F by the Bochner conditional expectation given the final transcript. Orthogonality of the projected ranges gives pointwise squared-norm splitting, while conditional-expectation contraction gives

    E||F-E[F|T]||^2 =
       E||G-E[G|T]||^2 + E||R-E[R|T]||^2
    <= eta + Var(R)=eta+tau_r.

No posterior eigenbasis is selected by the policy. This proves the stated theorem at the ANALYTIC level.

## Sharp scope, independent attack and reusable transfer

- The proof has the exact Lean coefficient c_*, not the stronger uncompiled manuscript coefficient. It is an analytic theorem depending on an imported finite kernel result; the infinite/Hilbert/adaptive composition is NOT kernel checked.
- An arbitrary correlated source product is NOT assumed. Changes of measure to correlated target laws require additional hypotheses and are separate.
- The proof does not upgrade the general cubic exponent-two conjecture, the arbitrary-law quadratic candidate, or any external novelty status.
- Test cases: null-mass categorical symbols; nonuniform marginals; singular PSD Gram matrices; non-diagonal A_i; all positive branches of finite adaptive query trees; continuous coordinates via finite rectangular partitions. A finite checker can falsify local identities, but cannot certify all measurable spaces.
- **General operator:** if finite bounded scalar degree-d functions have max influence >= a_d A^(2-2q) Var^q for q>1, the same completed-product lemma and PSD bridge give Hilbert rank-r adaptive bound ceil([8q/(q-1)] U_q log(1+4U_q)), U_q=d r^(q-1) B^(2q-2)/(a_d eta^(q-1)). No proof of such an exponent-q base is manufactured here.
- **Credit and prior art:** David Turturean (2026), Hoeffding/Efron-Stein, Grimmett–Janson–Norris (2016) general product influences, Gaussian/Rademacher quadratic forms, classical martingale conditional expectation. A dated source search here does not certify worldwide originality.
- **Remaining gate:** an external non-author line-by-line proof review and a separate actual end-to-end Lean/measure-theory formalization are necessary for upgraded certificates. Exact computational replay is not that review.


## Adversarial control: expectation and maximum cannot be exchanged

A concrete two-dimensional PSD pair is

    A_+ = (1/2) [[1,1],[1,1]],   A_- = (1/2) [[1,-1],[-1,1]].

Both have trace 1. For every eps in {-1,+1}^2,

    max(eps^T A_+ eps, eps^T A_- eps) = 2,

but

    max(E_eps eps^T A_+ eps, E_eps eps^T A_- eps) = 1.

Thus E max_i Q_i = 2 > 1 = max_i E Q_i, an exact counterexample to the tempting swapped-max shortcut. The Gaussian-moment union estimate in Lemma E is genuinely required. This control was separately replayed by exact Fraction enumeration; it is an elementary matrix identity, not a novel research theorem.
