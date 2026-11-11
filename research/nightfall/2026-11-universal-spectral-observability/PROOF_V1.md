# Universal Spectral Observability — analytic proof candidate v1

Research lead: Devin J. Wright, NIGHTFALL Constellation.
Checkpoint: 11 November 2026 UTC.
Status: analytic theorem using a specified kernel-compiled finite-product scalar result; the full product-measurable and Hilbert-adaptive lift has NOT been Lean-compiled, independently refereed, or granted global mathematical priority.

## Theorem

Let F be strongly measurable, take values in a real Hilbert space, and satisfy ||F||<=B on an arbitrary product of independent coordinate spaces. Suppose Hoeffding degree(F)<=d, d>=1. Let tau_r be the output covariance tail beyond the r leading directions. Set

    c_* = sqrt(3/12500)/pi^6,
    U   = d^7 B^3 r^(3/2)/(c_* eta^(3/2)),
    N   = ceil((40/3) U log(1+4U)).

A deterministic, measurable adaptive whole-coordinate rule achieves mean squared Hilbert risk <=tau_r+eta after at most N queries. Input dimension, alphabet cardinality, and minimum atom probability do not enter N. This is a QUERY count, not an efficient implementation. This result does not prove the universal cubic exponent-two influence conjecture.

## Proof, step 1: literal finite Lean theorem and general scalar lift

The merged pinned PR #317 (https://github.com/d3lefts/d3lefts/pull/317) compiles the finite scalar theorem

    3 Var(f)^5 <= 12500 (pi^2 d^2)^6 I_j(f)^2

for some j, when ||f||_infty<=1, coordinate masses are normalized nonnegative, a common finite input-alphabet TYPE is used, and f has indicator-monomial degree<=d. Its Lean name is Nightfall.ProductSpace.Influence.product_influence. Exact head e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb. Lean 4.33.0 receipt https://github.com/d3lefts/d3lefts/actions/runs/42929857470; only standard axioms. Do not substitute the unverified stronger constant 0.00120125 from earlier manuscripts. Turturean's original Boolean-cube proof supplies essential imported arguments.

Finite Hoeffding degree<=d implies indicator-monomial degree<=d, because each component on S is a finite linear combination of products of indicators of values for coordinates in S. Unequal finite alphabet types embed in one common disjoint union, and an invalid symbol at coordinate i is retracted to a fixed legal symbol. This preserves the degree and global boundedness, allowing zero-mass symbols.

For a general scalar h on arbitrary independent measurable product inputs, with |h|<=D and degree<=d, countable simple-function approximation gives an essentially countable coordinate support. Choose finite rectangular product partitions G_n increasing to the sigma-field used by h, and let h_n=E[h|G_n]. These converge in L2, remain bounded by D and of degree<=d (product conditional expectations commute with coordinate averaging); for every i, I_i(h_n)<=I_i(h) and Var(h_n)->Var(h). Apply the finite result to h_n/D and pass to the limit:

    SUP_i I_i(h) >= c_* D^(-3) d^(-6) Var(h)^(5/2).              (A)

The finite-to-infinite lift is an analytic proof, not a new Lean receipt.

## Proof, step 2: compress rank by random signs

For rank-r output G with ||G||<=B, put v=Var(G), A_i=E[(G-E_iG) tensor (G-E_iG)], p=sum trace(A_i), m=sup trace(A_i). ANOVA gives v<=p<=d v. In a covariance eigenbasis, for every epsilon in {-1,1}^r the scalar h_epsilon=<epsilon,G> has Var(h_epsilon)=v and norm bound sqrt(r)B. Equation (A) implies

    max_i epsilon^T A_i epsilon >= L,
    L = k v^(5/2),   k=c_* B^(-3)d^(-6)r^(-3/2).

For PSD A with trace s>0, Gaussian linearization and cosh(x)<=exp(x^2/2) give

    E_epsilon exp(epsilon^T A epsilon/(4s))
       <= det(I-A/(2s))^(-1/2) <= sqrt(2).

Write s_i=trace(A_i)<=m, z_i=epsilon^T A_i epsilon/(4m), a=sqrt(2)-1. Jensen and the convex chord inequality show E(exp(z_i)-1)<=a s_i/m. Since exp(max_i z_i)-1<=sum_i(exp(z_i)-1), Jensen yields

    L <= 4m log(1+a p/m).

The function t -> t log(1+a p/t) increases. Put H=log(1+4p/L). If m<L/(8H) the last inequality forces L<(L/(2H))log(1+8a(p/L)H)<=L, contradiction. Here a<1/2, H<=4p/L, and 1+8a(p/L)H<=(1+4p/L)^2. Thus

    m >= L/[8 log(1+4p/L)].                                    (B)

This is the rank r^(3/2) LOGARITHMIC bridge; no global optimality is claimed.

## Proof, step 3: posterior potential

At transcript t choose a remaining coordinate with maximal posterior trace influence. Define v_t, p_t, m_t as EXPECTED posterior variance, total ANOVA influence, and maximal trace influence. Jensen for z^(5/2) and concavity of the perspective map (m,p)->m log(1+a p/m) promote equation (B) to

    m_t >= k v_t^(5/2) / [8 log(1+4p_t/(k v_t^(5/2)))].

The EXACT ANOVA identity for a queried coordinate i is

    E_{X_i} T(G | X_i) = T(G)-I_i(G),   T=sum_j I_j,

hence p_{t+1}=p_t-m_t. Do not replace T by output variance.

While v_t>eta, p_t<=d v_t and the logarithm above is <=H=log(1+4U) with U=d/(k eta^(3/2)). Define

    Phi(z)=(8H/k) integral_0^z max(eta,s/d)^(-5/2) ds.

For s along [p_{t+1},p_t], max(eta,s/d)<=v_t. Therefore Phi(p_t)-Phi(p_{t+1})>=(8H/k)m_t v_t^(-5/2)>=1. The entire potential is bounded by

    sup_z Phi(z)=(8H/k)[d eta^(-3/2)+(2d/3)eta^(-3/2)]
                =(40/3) U H.

Thus after N steps expected posterior variance<=eta. Strong measurability gives an essentially countable input support. Posterior sections preserve degree a.e. by L2 closure; Fubini supplies measurable influences; nonnegative finite total influence guarantees that a positive supremum is attained. Fixed-order tie-breaking is measurable.

## Proof, step 4: spectral tail

Let G=P_r F be the leading covariance projection. The greedy observation policy for G controls its projected posterior risk by eta. Predict F with the complete conditional mean. Orthogonality and conditional-expectation contraction bound the residual orthogonal output risk by tau_r. Total mean squared risk<=tau_r+eta.

## Scientific and provenance boundaries

- KERNEL-CHECKED: only finite scalar declaration in PR #317. The original Turturean November 2026 result was on the uniform Boolean cube.
- ANALYTIC/NOT KERNEL-CHECKED: finite-type ANOVA-to-indicator bridge, arbitrary measurable product reduction, random-sign rank compression, exact posterior descent and measurable selection, Hilbert tail argument.
- OPEN: all-degree exponent-two influence theorem, unrestricted cubic variance-squared theorem, efficient computation, nonproduct inputs, and external originality/human-referee review.
- The degree-three activation supplement separately proves the sharper O(r/eta) observation law for the LINEAR interaction-support class; its repeated-pair sunflower identifies an obstruction to an unjustified unrestricted extension.

Next independent test: separate proof attack of the finite alphabet bridge, posterior-measurability step, Gaussian-sign extremal inequality, logarithmic inversion and potential integral. Preserve each artifact's precise dependencies rather than converting CI success into a novel-theorem claim.
