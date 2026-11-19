# Degree-two binary FUR: close the averaging obstruction with real Grothendieck
**2026-11-19. AUTHOR-SIDE MATHEMATICAL PROOF. NOT Lean-certified, externally refereed, or novelty-cleared.**

## Theorem QG: arbitrary-coupling quadratic stability
Let f:{-1,1}^n -> [0,1] have global algebraic degree at most two. Let (X,Y) have **any joint law** on pairs of strings (no coordinate independence at all), and p=max_i Pr[X_i != Y_i]. Then

    E |f(X)-f(Y)| <= p + 8 K_G sqrt(p)

where K_G is any valid real Grothendieck constant (e.g. the universal constant from the standard real Grothendieck inequality). The same right hand side bounds E[(f(X)-f(Y))^2], because |f(X)-f(Y)|<=1. The constants are dimension-free.

### Proof with all constants and hypotheses exposed
Expand uniquely on the Boolean cube:

    f(x) = c + sum_i a_i x_i + Q(x)
    Q(x) = sum_{i<j} b_ij x_i x_j
    B(u,v) = 1/2 sum_{i<j} b_ij (u_i v_j + u_j v_i).

Thus B is symmetric bilinear, Q(x)=B(x,x), and its diagonal entries are zero.
Since 0<=f<=1, the identity f(x)-f(-x)=2 sum_i a_i x_i gives
    sum_i |a_i| <= 1/2.
Also c=E_uniform f is in [0,1], while c+Q(x)=(f(x)+f(-x))/2 lies in [0,1], so |Q(x)|<=1 at all Boolean vertices. Q is multilinear, so |Q(z)|<=1 for all z in [-1,1]^n. Polarization and homogeneity give
    B(u,v) = (Q(u+v)-Q(u-v))/4,
and |Q(u+v)|,|Q(u-v)|<=4 for u,v in [-1,1]^n, hence
    sup_{u,v in [-1,1]^n} |B(u,v)| <= 2.

Set Delta=X-Y and Mid=(X+Y)/2. Then Delta_i is 0 or +/-2 and Mid_i is 0 or +/-1. The polynomial identity is
    f(X)-f(Y) = sum_i a_i Delta_i + 2 B(Delta,Mid).

By the triangle inequality,
    E |sum_i a_i Delta_i|
        <= sum_i |a_i| E|Delta_i|
        <= (1/2)*(2p) = p.

For p=0 everything vanishes. For p>0, work in the real Hilbert space H=L2(Omega,Pr) of the joint sample space. Define
    u_i = Delta_i/(2 sqrt(p)) in H,
    v_j = sign(B(Delta,Mid)) * Mid_j in H.
Since E Delta_i^2=4 Pr[X_i != Y_i] <= 4p, ||u_i||_H<=1. Since |Mid_j|<=1, ||v_j||_H<=1. The real Grothendieck inequality for the scalar matrix of B gives
    E |B(Delta,Mid)|
       = 2 sqrt(p) sum_{ij} B_ij <u_i,v_j>
       <= 2 sqrt(p) K_G sup_{s_i,t_j in [-1,1]} |B(s,t)|
       <= 4 K_G sqrt(p).
The factor 2 before B in f(X)-f(Y) yields 8 K_G sqrt(p). QED.

This handles **arbitrarily correlated** pairs, which the earlier product-pair Markov argument did not. It uses Grothendieck, which is a nontrivial *external theorem*; a Lean implementation must make that dependency explicit, not hide it in an axiom.

## Corollary: binary latent-label information alternative (paper proof)
Let theta have arbitrary finite prior/posterior pi, and given theta let X have a product law over binary symbols with coordinate means/biases p_(theta,i). Construct independent uniform seeds U_i and **shared monotone threshold maps**
    h_i(theta,U_i)=+1 iff U_i <= p_(theta,i).
Set G(theta,U)=f(h(theta,U)). For independent theta,theta' sampled from pi while sharing the SAME seed vector U, the mismatch probability at coordinate i is exactly
    q_i = E_(theta,theta') |p_(theta,i)-p_(theta',i)|
        = E_(theta,theta') TV(mu_(theta,i),mu_(theta',i)).

Let bar_p_i=E_theta p_(theta,i), I_i=I(theta;X_i) in natural-log units, and Imax=max_i I_i. There is a sharper **exact rational variance identity** for binary laws:
    q_i^2 <= E_(theta,theta') (p_(theta,i)-p_(theta',i))^2
          = 2 Var_theta(p_(theta,i)) <= I_i.
The first bound is Cauchy-Schwarz, the equality is an exact two-replica variance identity, and the last uses the standard Bernoulli Pinsker bound KL(Ber(p)||Ber(q))>=2(p-q)^2 (nats). Thus q=max_i q_i<=min(1,sqrt(Imax)); no triangle-inequality loss is needed. QG applies to the **unconditional**, correlated coupling (X,Y) induced by theta,theta',U. Therefore its *mean absolute resampling increment*
    L_theta(G) := E_(theta,theta',U) |G(theta,U)-G(theta',U)|
satisfies
    L_theta(G) <= q+8 K_G sqrt(q)
               <= (1+8 K_G) sqrt(q).
Rearrangement proves the quantitative information alternative
    Imax >= (L_theta(G)/(1+8 K_G))^4.
This is independent of M, n, the prior weights, component biases, and zero-probability atoms.

**Definition audit:** the repository's ProductInfluence.lean defines pincr as E |g(X)-g(X^(i))|, with an independent resampling of coordinate i. The latent-coordinate resampling L_theta above is exactly that definition for the product law pi x product_i Law(U_i).

## Connection to the full Mixture-AA degree-two crux
For f of global degree <=2, the lift G(theta,U) has global local-support degree <=3: each original degree-two term pulls back to a function of theta and at most two seed coordinates. G remains in [0,1] and Var(G)=Var_nu(f).
Apply the existing product-space mean_increment theorem at degree 3 to G. If its coordinate j with a large mean increment is a seed U_i, that is precisely a posterior-averaged component resampling increment. If j=theta, the preceding corollary supplies an OBSERVABLE coordinate i with I(theta;X_i) >= a fourth power of the available increment threshold. This is the desired M-independent crux **for binary degree-two globally bounded f**, at the paper level.

The mixture simulation brief states that this crux plus the potential Phi+H yields depth poly(d,log M,1/epsilon,1/delta). That simulation step is already an author-side reduction; the present note does NOT recertify its chain rule, stopping-time proof, or circuit bridge. In particular, it does not establish the full quantum theorem for T>1 or arbitrary alphabets.

## Conditional query-simulation consequence (not certified here)
Assuming the existing product-space mean_increment theorem and the two-potential stopping argument from the Mixture-AA brief compose without further model/conditioning gaps, let f be any globally bounded binary degree-two acceptance polynomial under an M-component binary product mixture. The lift has degree at most three, so a coordinate has mean-absolute increment at least a constant multiple of tau^(3/2) (d=2 fixed). The binary information alternative gives a corresponding observable entropy drop at least a constant multiple of tau^6. Potential descent, Chebyshev leaf error, and Markov truncation with tau proportional to epsilon^2 delta give an idealized deterministic classical query bound of form

    O((1+ln M) * epsilon^(-12) * delta^(-7))

for epsilon,delta in (0,1). Constants depend on the existing product-space row bound and real Grothendieck constant, but not on M, n or component biases. This would cover the acceptance probability of a one-query (T=1) quantum algorithm on **binary** product mixtures. It is a CONDITIONAL PAPER COROLLARY pending the exact entropy-chain-rule, tree, circuit, and independent review; it is NOT a finished Lean theorem or all-T breakthrough.

## Important exactness and formalization obligations
1. Verify the real Grothendieck inequality in the exact form for finite signed matrices and real Hilbert vectors with norms <=1. Cite the source, verify numerical upper bound if replacing K_G symbolically by a constant, and preferably prove/verify the statement in a dedicated Lean dependency.
2. Establish the global quadratic multilinear representation and sup-norm bounds on a Boolean cube in Lean, including the polarization identity and ||B||_{infty x infty}<=2.
3. Formalize the L2 joint-probability construction for arbitrary correlated pairs; the sign of B(Delta,Mid) is a valid bounded measurable test function.
4. Formalize Bernoulli Pinsker, the exact two-replica variance identity, Cauchy-Schwarz, and monotone shared-seed coupling. An exact rational proxy checker is supplied in fur_binary_information_proxy_exact.py. Exact finite probability seed construction is possible by partitioning [0,1] at the finitely many component bias thresholds; no atom lower bound is needed.
5. Confirm lift degree<=3 under the repository's HasProdDegreeLE definition and discharge the product mean_increment parameters.
6. Compose entropy-potential reduction and binary mixture simulator with an independent end-to-end proof audit. No automatic status promotion until CI and expert review pass.
7. Search prior art on Grothendieck, multilinear low-degree noise sensitivity, correlated-pair stability and quantum query simulation. This proof mechanism may be known; no novelty is certified.

## Independent adversarial predictions
- The one-hot component mixture from FUR_POINTWISE_COUPLING_DEGREE2_20261119.md no longer creates an averaging obstacle: q_i=2(n-1)/n^2 ->0, even though E_pair max_i TV ->1.
- A valid degree-two quadratic should satisfy the QG bound even when all coordinate mismatches are maximally correlated across the pair-vector; coordinate independence is not needed.
- In degree >=3, a naive bilinear Grothendieck replacement is not justified; higher-order multilinear constants can grow with dimension.

Status transitions: CONJECTURAL UNREVIEWED DERIVATION -> PAPER PROOF (this note) -> numerical audit artifact -> conditional Lean terminal -> end-to-end Lean certificate -> outside referee -> dated priority audit. The present status is only PAPER PROOF.
