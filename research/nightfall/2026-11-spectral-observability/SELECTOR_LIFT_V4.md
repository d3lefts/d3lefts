# v4: General selector lifting, a sharper cubic logarithm, and exact pair obstruction

**Date:** 10 November 2026 US/Eastern.  
**Status:** self-contained analytic derivation from a stated scalar premise. The degree-three specialization uses the degree-two scalar theorem in the supplied v3 manuscript. Internal review, not external mathematical refereeing or a priority certificate.

## Operator theorem: selector lift for any scalar influence exponent

Assume a class of bounded scalar functions on independent coordinates satisfies the following implication uniformly for all degree-at-most-s functions h, on every allowed product law:

    Var(h) <= C B^(2-2/alpha) (sup_j I_j(h))^(1/alpha),

whenever |h| <= B, with fixed alpha >= 1 and C > 0. Influences are total-effect Efron–Stein influences I_j(h) = E[(h-E_j h)^2].

Let X have arbitrary independent coordinates. Let Y_1,...,Y_K be independent fair signs, independent of X, and let g_1,...,g_K be real measurable functions of X with Hoeffding degree <= s. Define

    f(X,Y) = sum_k Y_k g_k(X),       |f| <= B a.s.

Put W = Var(f), M = sup_i I_i(f), where i ranges over both X and Y coordinates. For M>0:

    W <= B sqrt(M)
         + C B^(2-2/alpha) [4(1+sqrt(2)) M log(e+s B^2/M)]^(1/alpha).

There is no dependence on alphabet size, number of coordinates, number K of selector leaves, or atom masses. The scalar premise must hold for the specific signed selector functions below; the theorem does not assume or establish a general all-degree product-space influence bound.

### Proof

(1) Every sign pattern of finite Y has positive probability. Since |f(X,Y)|<=B, Fubini gives sum_k |g_k(X)|<=B almost surely. Consequently W=sum_k E g_k^2<=B^2; the Y_k influence equals E g_k^2, so each E g_k^2<=M and |E g_k|<=sqrt(M). Hence

    sum_k (E g_k)^2
      <= (max_k |E g_k|) sum_k |E g_k|
      <= B sqrt(M).

(2) For each X-coordinate j define the positive-semidefinite K-by-K matrix

    A_j[k,l] = E[(g_k-E_j g_k)(g_l-E_j g_l)].

Its trace s_j = sum_k I_j(g_k) = I_j(f) <= M. The degree-s Hoeffding decomposition and nonnegative orthogonal squares give the sharper influence budget

    P := sum_j s_j
       = sum_k sum_j I_j(g_k)
       <= s sum_k Var(g_k)
       <= s W <= s B^2.

In the degree-three signed-selector specialization s=2; the v3 manuscript used the weaker P<=3W from the degree of f. This correction improves a quantitative constant without changing the mathematical assumptions.

The coefficient s in P<=sW is optimal even among one-leaf examples: take g(X)=product_{j=1}^s (X_j-E X_j) with independent nondegenerate bounded inputs and f=Yg rescaled to |f|<=B. Its pure degree-s ANOVA component has I_j(g)=Var(g) on each of the s coordinates; hence P=sW exactly. This establishes sharpness of the *influence-budget factor*, not of the final logarithmic prediction constant.

(3) For independent auxiliary fair signs eps_k, set h_eps(X)=sum_k eps_k g_k(X). Then |h_eps|<=B and deg(h_eps)<=s, so by the scalar premise

    Var(h_eps)
      <= C B^(2-2/alpha) [max_j eps^T A_j eps]^(1/alpha).

Averaging the left side over eps gives sum_k Var(g_k) >= W-B sqrt(M).

(4) Put Z=max_j eps^T A_j eps. For any A positive semidefinite of nonzero trace t, Gaussian linearization and cosh(u)<=exp(u^2/2) imply

    E_eps exp(eps^T A eps/(4t))
      <= det(I-A/(2t))^(-1/2) <= sqrt(2).

The determinant bound follows because the eigenvalue fractions sum to 1/2 and their product (1-lambda_i/(2t)) is at least 1/2. Thus Pr(eps^T A_j eps > u)<=sqrt(2)exp(-u/(4s_j)). For u>=4M, exp(-u/(4t))/t is increasing over 0<t<=M, so summing the individual tails gives

    Pr(Z>u) <= sqrt(2) (P/M) exp(-u/(4M)).

Let L=log(e+P/M)>=1, u_0=4ML. Integrating the bound yields

    E Z <= 4ML + 4sqrt(2) P exp(-L)
        <= 4(1+sqrt(2)) M L
        <= 4(1+sqrt(2)) M log(e+s B^2/M).

Finally, concavity of z^(1/alpha) gives E Z^(1/alpha) <= (E Z)^(1/alpha). Combine (3) and (4). If M=0, every E g_k^2=0 and W=0. This proves the claim.

## Improved unconditional cubic selector theorem

Apply the operator with s=2, alpha=2, and the v3 scalar quadratic constant D=16(1+sqrt(3)). Since log(e+2B^2/M)>=1, one obtains

    Var(f) <= [1+2 sqrt(1+sqrt(2)) D] B
                     sqrt(M log(e+2B^2/M)),

with numerical constant less than 137.

This is strictly stronger than the submitted v3 formula with log(e+3B^2/M), for every B>0 and M>0. It is **not** a solution of the general arbitrary-alphabet degree-three theorem. The proof is conditional on the quadratic theorem's correctness, which the supplied source has not yet established through non-author referee or end-to-end Lean compilation.

The general lift is a transferable *operator*: any subsequently verified scalar exponent alpha for selector functions of degree s can be substituted without a fresh random-sign proof.

## Exact all-p proof of the four-bit obstruction

Take independent Bernoulli(p) bits, 0<p<1, and define the bounded function f=+1 when (x1=x2=1), (x3=x4=1), or x=(0,0,0,0), and f=-1 otherwise. The fourth-order multilinear Möbius coefficient vanishes by direct enumeration, so the Hoeffding degree is <=3 for all positive product atom masses.

Let h(a,b)=E[f | x1=a,x2=b]. Direct conditioning gives

    h(1,1) = 1,
    h(1,0) = h(0,1) = 2p^2-1,
    h(0,0) = 1-4p+4p^2.

The mixed difference h(1,1)-h(1,0)-h(0,1)+h(0,0) equals 4(1-p). For binary Bernoulli(p) coordinates, the pair Hoeffding component is exactly

    f_{12}(x1,x2) = 4(1-p)(x1-p)(x2-p).

Its sup norm is 4(1-p)max(p,1-p)^2 (because |x_i-p| is either p or 1-p); symmetry gives the identical f_{34} result. Thus two disjoint pair components have total sup norm 8(1-p)max(p,1-p)^2. The original v3 identity 8(1-p)^3 holds only for p <= 1/2, and is FALSE for p > 1/2. The corrected formula still tends to 8 as p approaches 0. Any universal degree-three disjoint-pair bound of the form sum ||f_pair||_inf <= K B therefore requires K>=8. The bounded quadratic matching argument permits K=4 only at degree <=2.

The independent script selector_pair_symbolic.py checks all four pair-ANOVA values as integer polynomial identities in p and uses exact rational counterchecks on both sides of 1/2; the piecewise supremum follows analytically by maximizing the elementary factors |x_i-p|. No floating tolerance or third-party dependency.

## Next decisive experiment

Prove or refute the existence of universal constants K,kappa for the v3 degree-three fourth-moment assignment certificate, under general heterogeneous atom masses. Pre-register the stronger prediction that pair/link assignments, **not** triples alone, control the fourth moment. A smallest sharp adversarial test is the skew four-bit obstruction above extended to k disjoint pairs and cubic coupling links. If a counterexample forces K to grow with k, the proposed certificate operator fails even if the universal influence theorem might still hold.

Maintain separate statuses: exact pair obstruction certified by analytic identity and script; selector lift analytically derived with explicit premise; general cubic theorem OPEN; originality and independence of audit unconfirmed.
