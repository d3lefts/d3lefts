# Route 1, v2: finite star coupling removes FUR and Hellinger

**Date:** 2026-11-19. **Status:** complete author-side paper derivation; the finite star-coupling and large/small identities have independent exact-rational regression, but the end-to-end theorem is **NOT Lean kernel-certified or non-author reviewed**. Novelty/priority not cleared. This note strengthens the merged Route 1 paper proof (former PR #928) without claiming that proof as a new independent discovery.

## Theorem (paper-level)

Let I be finite, each A_i finite nonempty, and let nu=sum_{theta=1}^M pi_theta P_theta be an arbitrary known finite mixture of product laws P_theta=otimes_i p_theta,i. The mixture weights and coordinate masses may vanish. Let f:prod_i A_i -> [0,1] have indicator interaction degree at most d, d>=1. For any 0<epsilon,delta<1, a deterministic adaptive decision tree approximates f with nu-probability of error >epsilon at most delta, using at most

    ceil[(2/delta) (d^2/gamma + ln(M)*(c_d/gamma)^3)]

queries, where

    D=d+1,
    gamma = sqrt(3*tau^5/12500)/(pi^2 D^2)^3,
    tau=epsilon^2*delta/2,
    c_d=(pi^2/2+2)*d^2.

Consequently the depth is poly(d,1/epsilon,1/delta)*(1+ln M), independent of n, all alphabet sizes and minimum atom masses. For a T-query quantum acceptance probability, use d<=2T (under the standard finite-symbol polynomial-method oracle model). Computational running time is **not bounded**. The construction is nonuniform in the known mixture and f.

### Input dependencies, checked against source this session

1. Existing kernel-checked product row theorem: Nightfall.ProductSpace.RowBound.product_row_bound in research/nightfall/formalization/product_space/ProductRowBound.lean, cost K=pi^2 d^2 for globally [-1,1]-bounded degree-d f.
2. Existing kernel-checked product influence theorem: Nightfall.InfinitePiAAProductTerminal.infinitePi_aa_product, bound 3 Var(G)^5 <= 12500 (pi^2 D^2)^6 B^6 (max_i Inf_i(G))^2. For B=1 this gives the gamma above.
3. Standard real Markov polynomial derivative inequality |p'|<=d^2 for |p|<=1 on [-1,1], and finite Pinsker KL(p||q)>=2 TV(p,q)^2 in natural logarithms. The former is re-derived below for the required interpolation; the latter remains an external analytic input.
4. Existing exact posterior Phi-splitting identity in research/nightfall/formalization/product_space/MixtureSimulation.lean (Phi_sum), used with posterior component weights, not an M-factor loss.

## Lemma 1. Universal fiber oscillation budget

For every anchor x, define

    osc_i(x_-i)=max_{a,b in A_i} |f(x[i:=a])-f(x[i:=b])|.

Then

    sum_i osc_i(x_-i) <= 2 d^2.

Proof. Let U_i=max_a (f(x[i:=a])-f(x)) and V_i=max_b (f(x)-f(x[i:=b])); both nonnegative and osc_i=U_i+V_i. Select maximizing and minimizing replacement symbols b_i^+,b_i^-. Independently switch each x_i to b_i^+ with probability s. The expected value q_+(s) is a polynomial of degree at most d, because every indicator monomial of f is supported on at most d coordinates. It is in [0,1] for all s in [0,1], and q_+'(0)=sum_i U_i. The polynomial P(t)=2q_+((t+1)/2)-1 is bounded by 1 on [-1,1] and P'(-1)=q_+'(0). Markov gives sum_i U_i<=d^2. The same construction for b_i^- gives sum_i V_i<=d^2. Add. The bound holds for all alphabets and all x, without a source law. QED.

## Lemma 2. Switching-time fooling for arbitrary product PAIR laws

Let (X_i,Y_i) be independent across i, but X_i and Y_i may be arbitrarily coupled within a coordinate. Let q_i=Pr[X_i!=Y_i]. Then

    E|f(X)-f(Y)| <= 2 d^2 * max_i q_i.

Proof. Draw independent T_i uniform on [0,1], independently of the pairs, and form Z_i(t)=X_i before T_i, Y_i after T_i. The telescoping jump at T_i has magnitude at most 1[X_i!=Y_i]*osc_i(Z_-i(T_i)). Conditional on T_i=t, the latter oscillation depends only on other coordinate pairs and clocks, and hence is independent of the mismatch event at i. Thus

    E|f(X)-f(Y)|
       <= sum_i q_i int_0^1 E osc_i(Z_-i(t)) dt
       <= (max_i q_i) * 2d^2.

The final inequality uses Lemma 1 pointwise. QED.

## Lemma 3. Finite star maximal coupling, including zero atoms

For any finite alphabet A and probability vectors p,q, put m(a)=min(p(a),q(a)), r(a)=p(a)-m(a), s(a)=q(a)-m(a), t=sum_a r(a)=TV(p,q). If t>0, set

    C_pq(a,b) = 1[a=b]*m(a) + r(a)*s(b)/t;

if t=0 set C_pq(a,b)=1[a=b]*p(a). Its row marginals are p, column marginals q, and Pr[a!=b]=t, since r(a)s(a)=0. Define the conditional kernel

    K_q(b|a) = C_pq(a,b)/p(a)  if p(a)>0,
             = q(b)            if p(a)=0.

Every K_q(.|a) sums to 1 and sum_a p(a)K_q(b|a)=q(b).

Now let p=bar p_i=sum_theta pi_theta p_theta,i. For each coordinate i, define a SINGLE FINITE seed U_i=(a,(b_theta)_{theta=1}^M), of probability

    lambda_i(a,b_1,...,b_M)
        = bar p_i(a) * product_theta K_{p_theta,i}(b_theta|a).

Let bar h_i(U_i)=a and h_i(theta,U_i)=b_theta. Then simultaneously for every theta:

    bar h_i(U_i) ~ bar p_i,
    h_i(theta,U_i) ~ p_theta,i,
    Pr[bar h_i(U_i)!=h_i(theta,U_i)] = TV(bar p_i,p_theta,i).

The U_i are independent across i. There is NO need for a pairwise all-components correlated-sampling theorem, a Hellinger angle, positive atoms, or an infinite seed space. Zero-weight theta may be retained; its kernel is still a valid conditional law.

This star coupling is sufficient because the latent theta-theta' increment will be bounded by the triangle inequality through the SINGLE common bar h(U), not by a direct theta-theta' mismatch estimate.

## Lemma 4. The M-free latent fooling inequality

Write bar p_i=sum_theta pi_theta p_theta,i, I_i=sum_theta pi_theta KL(p_theta,i||bar p_i), and I*=max_i I_i. For the finite star coupling, define bar X(U)=(bar h_i(U_i)) and X^theta(U)=(h_i(theta,U_i)). Then

    E_{theta,U}|f(X^theta(U))-f(bar X(U))|
       <= c_d * (I*)^(1/3),   c_d=(pi^2/2+2)d^2.

Proof. Let 0<eta<=1 and t_theta,i=TV(p_theta,i,bar p_i). The set L_theta={i:t_theta,i>eta} is deterministic given theta, NOT random in U. Form Z^theta(U) by taking X^theta_i on L_theta and bar X_i outside.

For the LARGE part, apply the pinned ordinary row at the single anchor bar X(U), with weights a_i(bar X) >=0 and sum_i a_i(bar X)<=K=pi^2 d^2:

    |f(bar X)-f(Z^theta)| <= sum_{i in L_theta} a_i(bar X).

Since bar X and its row are independent of theta, average first over theta with U fixed:

    E_{theta,U}|f(bar X)-f(Z^theta)|
       <= K * max_i Pr_theta[t_theta,i>eta]
       <= K * max_i E_theta[t_theta,i^2]/eta^2
       <= K * I*/(2 eta^2).

The final step is finite Pinsker; the mixture support ensures KL is finite for every positive-weight component, even if some coordinate atoms vanish.

For the SMALL part, conditional on theta the coordinate pairs (Z_i^theta,X_i^theta) are independent across i and their mismatch probabilities are <=eta: zero on L_theta and exactly t_theta,i off L_theta. Lemma 2 gives

    E_{theta,U}|f(Z^theta)-f(X^theta)| <= 2d^2 eta.

Thus the sum is at most K I*/(2eta^2)+2d^2 eta. If 0<I*<=1 choose eta=(I*)^(1/3), obtaining c_d (I*)^(1/3). If I*=0, Pinsker implies all positive-weight components equal the bar marginal coordinatewise, hence the difference is zero. If I*>1, the left side is <=1<=c_d (I*)^(1/3). QED.

## Lemma 5. Latent lift and the decisive observable-coordinate dichotomy

Define G(theta,U)=f(X^theta(U)) on the PRODUCT probability space pi otimes_i lambda_i. The pushforward of G equals the law of f under nu. Every indicator monomial f_S of support S, |S|<=d, pulls back as

    sum_theta0 1[theta=theta0] * f_S(h_i(theta0,U_i) : i in S),

which depends on at most d+1 product coordinates (theta and U_S). Hence G has indicator and Efron–Stein degree <=d+1, with zeros allowed. The product AA theorem implies, whenever Var_nu(f)>=tau, a coordinate c among {theta} union I has Inf_c(G)>=gamma.

For seed coordinate U_j, resampling U_j at fixed theta exactly resamples the original input coordinate under p_theta,j, so

    E_theta L_j^{p_theta}(f) = E|G(theta,U)-G(theta,U^{(j)})|
                            >= 2 Inf_{U_j}(G).

For the latent coordinate theta, resampling theta' with U fixed and using Lemma 4 twice:

    2 Inf_theta(G)
       <= E_{theta,theta',U}|G(theta,U)-G(theta',U)|
       <= 2 c_d (I*)^(1/3).

Therefore at every posterior node with Var_nu(f)>=tau, there is either
(a) an observable j with E_theta L_j^{p_theta}(f)>=2gamma, or
(b) an observable j with I(theta;X_j)>=(gamma/c_d)^3.

**This closes the M-free crux on paper without FUR.** Note that (a) is a mean ABSOLUTE resampling increment; influence is half the SQUARED increment, so the inequality direction above uses |a|^2<=|a| for f in [0,1].

## The deterministic simulator and exact drift accounting

At a posterior node rho, the surviving components remain products after conditioning on already observed symbols; zero posterior components may be dropped. The restricted function f_rho retains indicator degree <=d. If Var_nu_rho(f_rho)<=tau, output its exact conditional mean. Otherwise select a coordinate satisfying (a) or (b), query it, and recurse. The decision tree is deterministic: its construction may use exact knowledge of f and the mixture and unbounded computation.

Define Phi(rho)=E_{theta|rho} sum_{i unqueried} L_i^{p_theta,rho}(f_rho). Lemma 1 implies 0<=Phi<=2d^2. For a query at j, conditional Fubini and independence within each component give the EXACT identity

    Phi(rho)-E[Phi(child)|rho] = E_{theta|rho} L_j^{p_theta,rho}(f_rho).

Let H(rho) be the posterior Shannon entropy of theta in NATS, with 0<=H<=ln M. Its exact conditional drop on querying j is I(theta;X_j|rho). Therefore the combined potential

    Psi(rho)=Phi(rho)/(2gamma) + H(rho)*(c_d/gamma)^3

has expected drop >=1 at every nonterminal node. Since no coordinate is queried twice, the process ends after at most n queries, and

    E_nu N <= Psi(root) <= d^2/gamma + ln M*(c_d/gamma)^3.

Cap the depth at ceil(2 Psi(root)/delta). By Markov, the probability of encountering this cap before a low-variance leaf is <=delta/2. At ordinary leaves, conditional Chebyshev bounds the chance |f-mean|>epsilon by tau/epsilon^2=delta/2. Total error <=delta. QED, subject to the cited product AA/row inputs and standard analytic inequalities.

## Independent checks and limitations

Companion stdlib-only script check_route1_star_coupling_exact.py independently constructs finite star kernels, verifies their simultaneous pair marginals and mismatch TV with zero atoms, and checks all three parts of the large/small decomposition, source-product pair independence and the sharp 2d^2 oscillation budget on 36 random finite mixtures. **32,340 exact rational assertions passed** on 2026-11-19; script SHA256 dab9e3a4995bfdde7b20e88c2ac74f9d1b7c0d97c0899add68c7acf4fc6a71bb. It checks the rational proxy J*=max_i E_theta TV_i^2; the final Pinsker-to-information step is analytic, not numerically proved.

The checker's finite-row bound uses a_i=1, cost n, only to exercise the large/small mechanism. It does NOT numerically certify the universal K=pi^2 d^2 row theorem; that is the preexisting Lean result. The checker also does NOT certify the product-AA lift or the complete stopping-time proof. No independent human referee or new Lean terminal has reviewed this full composition.

**Independent adversarial review targets:** (i) verify finite-star kernel with arbitrary real/zero atoms and theta zero weights; (ii) check that the fixed bar X row is independent of theta even after choosing L_theta; (iii) check the polynomial degree of G when theta is a SINGLE coordinate; (iv) check the 2d^2 oscillation constant's [0,1] Markov normalization; (v) check exact posterior Phi drift and entropy chain rule including zero-weight components; (vi) check standard quantum acceptance polynomial degree for arbitrary finite-symbol oracles; (vii) dated prior-art search, including BDST, GMNR, HMP, and product-mixture results. If any fails, demote this proof rather than claim a theorem.

**Next Lean gates:** (1) finite-star joint/kernel marginal and zero-atom transport, (2) the M-free large/small key lemma with source RowBound and Markov switching, (3) exact finite-degree latent lift, (4) posterior potential and entropy chain rule, (5) one named end-to-end Route1 theorem and axiom receipt under pinned Lean 4.36.0-rc2. Do not mark (5) complete because the older product AA and mixture theorems are kernel checked.

**Mechanism:** finite shared reference -> deterministic large-TV coordinate sets -> anchored ordinary rows + independent small-TV switching -> M-free latent information dichotomy -> combined mean-increment/entropy potential -> logarithmic mixture dependence. This supersedes FUR as a required hypothesis for Route 1, but does NOT prove the standalone FUR conjecture.