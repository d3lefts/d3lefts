# NIGHTFALL | Two reusable cubic proof operators (review draft v1)

Date: 2026-11-10 (US Eastern). Research direction: Devin J. Wright / NIGHTFALL. Status: analytic deductions with independent finite exact checks; not externally refereed, not a new proof of the unrestricted cubic exponent-two conjecture, and no novelty priority claimed.

## Operator A. Optimal independent-color one-leaf extraction (all fixed degrees)

Let f be essentially bounded by B on a product of independent coordinates (not necessarily finite or identically distributed), with Hoeffding degree at most d >= 2. Write f = sum_{|S|<=d} f_S. Independently label each coordinate *leaf* with probability p and *control* otherwise. For a label set L define

    Q_L f = sum_{S : |S cap L|=1} f_S.

Then for every L:

1. Q_L f is a generalized (d-1)-degree selector: it is centered and additive across leaf coordinates, with coefficient functions of control degree <= d-1.
2. ||Q_L f||_infty <= 2 d^2 B.
3. I_i(Q_L f) <= I_i(f) for every coordinate.
4. E_L Var(Q_L f) = sum_{1<=|S|<=d} |S| p (1-p)^(|S|-1) ||f_S||_2^2.

Choose p_d = 1 - d^(-1/(d-1)) and alpha_d=p_d. Then

    E_L Var(Q_L f) >= alpha_d Var(f).

This alpha_d is the BEST possible uniform variance-retention factor among independent, identically distributed Bernoulli leaf colorings, since all energy may sit on support size 1 or size d. To prove optimality, w_s(p)=s p (1-p)^(s-1) is unimodal in integer s, hence min_{1<=s<=d} w_s(p)=min{p,d p(1-p)^(d-1)}. These endpoints cross at p_d; the second is decreasing on [p_d,1], since p_d>=1/d. Consequently sup_p min_s w_s(p) = p_d. At p_d, for intermediate s, log[w_s(p_d)/p_d]=log s - (s-1)/(d-1) log d >= 0 by concavity of log on [1,d].

For d=3, p_3=1-1/sqrt(3) and alpha_3=p_3 ~ 0.422649730810, improving the earlier p=1/2 factor 3/8. If every such generalized quadratic selector g obeys

    Var(g) <= C ||g||_infty sqrt(sup_i I_i(g)),

then every bounded cubic satisfies

    Var(f) <= [18/(1-1/sqrt(3))] C B sqrt(M)
           = (27+9 sqrt(3)) C B sqrt(M)  (~42.588 C B sqrt(M)),

where M=sup_i I_i(f). The earlier unoptimized transfer factor was 48. Conversely every generalized quadratic selector has overall Hoeffding degree at most 3; hence the universal cubic exponent-two conjecture is equivalent, up to this factor, to an alphabet-independent generalized quadratic-selector inequality. **The missing selector inequality is not proved by this reduction.**

Proof of the supnorm bound: for fixed L, let T_t = product_{i in L}(E_i+t(Id-E_i)), with 0<=t<=1. Each coordinate operator is Markov, so ||T_t f||_infty<=B. On degree <=d, the polynomial q_x(t)=(T_t f)(x) has degree <=d and q_x'(0)=(Q_L f)(x). Markov's endpoint derivative inequality on [0,1] yields |q_x'(0)|<=2d^2B. Influence contraction and the variance formula follow from orthogonality of the Hoeffding components. For arbitrary product measures use countable-coordinate support and finite rectangular conditional approximations.

The same proof holds for real Hilbert-valued f, replacing absolute value by norm (scalarize with unit functionals). The variance and influence statements use squared Hilbert norms.

**Prior art warning:** one-block decoupling and a related Boolean-cube equivalence appear in O'Donnell--Zhao, *Polynomial Bounds for Decoupling, with Applications*, CCC 2016, https://arxiv.org/abs/1512.01603. This note records a quantitative arbitrary-product projection and an optimized coloring constant; neither worldwide priority nor distinction from all earlier decoupling literature has been independently established.

## Operator B. Influence-weighted cubic transversal certificate

Let |f|<=B, deg f<=3, V=Var(f), and M=sup_i I_i(f). Let H intersect every nonzero cubic Hoeffding support (H need not have bounded cardinality). Set

    g_H=E[f | X_{J\H}],
    Delta_H=V-Var(g_H)=sum_{S : S cap H != empty} ||f_S||_2^2,
    Lambda_H=sum_{i in H} I_i(f).

By quadratic product-space influence with D=16(1+sqrt(3)) and by orthogonality,

    V <= D B sqrt(M)+Delta_H <= D B sqrt(M)+Lambda_H.

Thus if a *possibly growing* hitting set H satisfies Lambda_H <= kappa B sqrt(M), then

    M >= V^2 / [(D+kappa)^2 B^2].

This is an alphabet-independent exponent-two sufficient condition in terms of **weighted deletion cost**, not cover size. The earlier PR #335 bound D B sqrt(M)+|H|M follows because Lambda_H<=|H|M, but the weighted criterion also applies when every cubic cover has unbounded size and its coordinate influences have bounded total normalized cost. For finite systems Delta_H is an exact tighter deletion certificate computable from ANOVA data; Lambda_H is easier to estimate from coordinate influences.

The stronger exact energy formulation is the natural one for optimization:

    Lambda_energy(f)= inf_{H hits all cubic supports} Delta_H,
    V <= D B sqrt(M)+Lambda_energy(f).

**Example outside fixed-cover and linear-hypergraph subclasses.** Let independent X_j,Y_j,Z_j, j mod k, be fair signs, k>=3. Set

    f_k=(1/(2k)) sum_{j=1}^k X_j Y_j (Z_j+Z_{j+1}).

Then B=1; degree is exactly 3; each pair {X_j,Y_j} occurs in two distinct triples, so support intersections have size 2; and the cubic hypergraph is connected through the Z variables. There are 2k triples, with each vertex covering at most two, so every vertex cover has at least k coordinates. However H={X_1,...,X_k} is a cover with

    V=1/(2k), M=1/(2k^2), Lambda_H=1/(2k)=(1/sqrt(2)) B sqrt(M).

The weighted certificate therefore has kappa=1/sqrt(2), independent of k. This is a *scope separation* from PR #335's bounded-|H| and independent-block hypotheses; it does not establish the universal cubic theorem. The displayed example itself has direct influence computations, and the certificate need not be quantitatively tight.

## Operator C. Log-free cubic selectors with arbitrary control interaction networks

**Independent source:** the user's `NIGHTFALL_Degree3_ExponentTwo_Partial_Proofs_v2.zip`, section "dimension-free quadratic influence under an l1 output bound" and follow-up alphabet-free rank-one note. The repo's existing spectral selector note (PR #329) instead states a logarithmic-loss result.

Let G=(g_1,...,g_K) on arbitrary independent control inputs, with each g_k of Hoeffding degree at most 2 and pointwise sum_k |g_k|<=B. Put W=E||G-EG||_2^2, J_i=E||G-E_iG||_2^2 and M_X=sup_i J_i. The existing quadratic matching proof extends from scalar to finite-dimensional vector outputs **without a dimension factor** under this l1 output restriction:

    W <= D sqrt(2) B sqrt(M_X),  D=16(1+sqrt(3)).

The proof uses the sharp p=1 Khintchine inequality (for every PSD Q, E_eps sqrt(eps^T Q eps)>=sqrt(tr Q/2)) to replace the usual spherical factor 1/a_r: parity-coupled matching costs total <=4sqrt(2)B, the section oscillation budget totals <=8sqrt(2)B, and the independent Hilbert-increment fourth-moment estimate finishes the original quadratic argument. This is an analytic dependency on that original proof, not a separately Lean-checked theorem.

**Fair-sign cubic selector.** If Y_k are independent fair signs and f(X,Y)=sum_k Y_k g_k(X) obeys |f|<=B, then sum_k |g_k(X)|<=B a.s. (all finite sign patterns have positive probability). The leaf influences equal E g_k^2. Thus, splitting sum_k E g_k^2 into sum_k Var(g_k) plus sum_k(E g_k)^2, one obtains

    Var(f) <= [1+D sqrt(2)] B sqrt(M),   M=sup_i I_i(f).

**Arbitrary leaf alphabets with rank-one relevant sections.** The same conclusion holds for f(X,Y)=sum_k u_k(X) phi_k(Y_k), where phi_k is any fixed centered square-integrable feature of its leaf Y_k. Condition on X: independence plus |f|<=B yields sum_k |u_k(X)| ||phi_k||_2 <=B (ranges and Popoviciu). Set g_k=u_k ||phi_k||_2 and apply the vector quadratic theorem; control influences match, while each leaf influence equals E g_k^2. No atom mass, alphabet dimension, or L4/L2 ratio enters. For arbitrary infinitely many leaves, justify by finite truncations and bounded conditional expectations.

Unlike a bounded top-degree vertex cover, this result allows arbitrary *dense*, interlocking quadratic interactions among the controls. It is therefore not subsumed by PR #335. Unlike the uniform-L4/L2 general selector note, it permits arbitrarily rare events in the rank-one leaf features. It still does **not** cover arbitrary high-dimensional leaf section spaces, so it does not settle unrestricted cubic exponent two.

The local exact checkers `verify_l1_quadratic.py` and `verify_bounded_controls.py` were replayed in this session and are included here for audit. The sharp Khintchine inequality and underlying l1 influence machinery have substantial prior literature; no standalone novelty or independent referee certification is claimed.

## Proof-audit and publication boundaries

- Operator A: analytic exact projection/variance computation; independent finite categorical and biased Boolean checks in `check_exact.py`.
- Operator B: analytic Hoeffding orthogonality plus an **imported** arbitrary-product quadratic theorem. The quadratic theorem's complete external review remains open.
- Test scripts check arithmetic and finite identities; they do not establish global originality or the unrestricted cubic conjecture.
- Remaining hard problem: prove a uniform generalized-selector bound for arbitrary leaf L2 spaces without leaf moment assumptions, equivalently universal cubic exponent two; the earlier direct random-evaluation approach fails on rare-atom leaf functions.
- Do not publish these as an independently certified breakthrough. Integrate in an explicit **working-draft/under-review** section if authorized.

## Operator D. Bounded shared controls, arbitrary high-rank leaf sections (exact strengthening)

**Imported from the parallel bounded-control research note, reproduced here with a shorter variance proof.** Suppose A=(X_1,...,X_t) are independent controls and Y_k are independent leaves, independent of A, with

    f(A,Y)=h(A)+sum_k g_k(A,Y_k),  E_{Y_k} g_k(A,Y_k)=0,

and |f|<=B. There is no degree bound on the control function h or on the dependence of g_k on A. Let V=Var(f) and M=sup_j I_j(f) over *all* control and leaf coordinates. Then

    V <= B sqrt(M) + t M <= (t+1) B sqrt(M),
    M >= V^2/[(t+1)^2 B^2].

For t=2 this covers degree-at-most-three functions with two shared controls and arbitrary leaf-section rank, skewness, continuous alphabets, and an arbitrary number of leaves, with coefficient 3 (squared-influence denominator 9), substantially improving the D+t constant for this narrower class.

**Proof.** By the law of total variance relative to the entire leaf family,

    V = E_Y Var_A(f(A,Y)) + Var_Y(E_A f(A,Y)).

For each fixed Y, the Efron–Stein inequality on the t independent controls gives

    E_Y Var_A(f) <= sum_{j=1}^t I_{X_j}(f) <= t M.

Set F(Y)=E_A f(A,Y)=E_A h(A)+sum_k \bar g_k(Y_k), where \bar g_k=E_A g_k(A,Y_k). Then F is bounded by B and additive in independent leaves, each \bar g_k centered. For every finite leaf set, the essential range width of its sum equals the sum of the individual essential widths (independence). Since F lies in [-B,B], those widths sum to at most 2B. Popoviciu gives

    sum_k ||\bar g_k||_{L2(Y_k)} <= B.

Furthermore Jensen and the leaf influence identity imply

    ||\bar g_k||_2^2 <= E_A ||g_k(A,.)||_2^2 = I_{Y_k}(f) <= M.

Therefore

    Var_Y(F)=sum_k ||\bar g_k||_2^2
      <= (sup_k ||\bar g_k||_2)(sum_k ||\bar g_k||_2) <= B sqrt(M).

Combine the two estimates. Approximation by finite leaf sets and conditional expectations handles countably many active inputs; strong measurability reduces arbitrary index families to countable support. The leading coefficient 1 is sharp for f=(Y_1+...+Y_n)/n with fair leaves and unused controls, since V=1/n and M=1/n^2.

**Distinction:** This theorem handles arbitrary high-dimensional leaf sections but requires a *fixed finite control family* outside which all leaf interactions are additive. Operator C permits arbitrarily many dense controls but requires rank-one leaf features. The unrestricted generalized selector case contains neither restriction and remains open.
