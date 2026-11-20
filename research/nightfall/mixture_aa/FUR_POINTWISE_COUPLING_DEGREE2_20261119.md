# FUR pointwise coupling — degree-two Markov amplification
2026-11-19 | Status: author-side proof; NOT Lean, independently refereed, or novel-certified; NOT full FUR.

## Aim
The open reduction in MIXTURE_AA_POLYLOG_M_BRIEF_20261119.md asks whether a large hidden-label influence can be charged to an observable coordinate with information polynomial in the variance/degree. This proves the pointwise product-coupling inequality proposed in section 4 of that brief and identifies an obstruction to finishing the averaging step.

## Theorem PF(d)
Let Omega_i be arbitrary finite sets and f: product_i Omega_i -> [0,1] admit a **global** local-support expansion of degree <=d:
f(x)=sum_{|S|<=d} f_S(x_S).
For independent pairs (X_i,Y_i) with arbitrary joint laws C_i, let p_i=Pr[X_i != Y_i], eta=max_i p_i. For d>=1,
E[(f(X)-f(Y))^2] <= min(1, 8*d^2*eta),
E[|f(X)-f(Y)|] <= min(1, sqrt(8)*d*sqrt(eta)).
At d=2 the squared bound is 32*eta, irrespective of n, alphabet sizes, or zero atoms.

The theorem assumes global interaction degree, not only a source-relative almost-sure degree under degenerate marginals. A quantum acceptance polynomial's natural global local-support expansion meets this structural requirement.

## Proof (complete on paper, modulo classical Markov brothers' inequality)
If eta=0, X=Y almost surely. Otherwise write each coupling C_i=(1-p_i)*D_i+p_i*B_i, where D_i is supported on the diagonal and B_i is supported on mismatched pairs (choose unused conditional pieces arbitrarily for p_i in {0,1}). Define
C_i(t)=(1-t*p_i)*D_i+t*p_i*B_i for 0 <= t <= 1/eta.
These are genuine probability laws throughout that interval.

Let P(t)=E_{product_i C_i(t)} [(f(X)-f(Y))^2]. The square of the difference of two functions of global local-support degree <=d involves no more than 2d pair-coordinate blocks. Integrating each term against the independent, t-affine laws C_i(t) makes P a polynomial in t of degree <=2d, independent of n. Also P(0)=0 because all coordinates match, and 0<=P(t)<=1 for t in [0,1/eta] because f takes values in [0,1].

Markov brothers' inequality for a degree-D polynomial bounded in absolute value by 1 on an interval of length L gives sup|P'| <= 2 D^2/L. With D=2d and L=1/eta, get P(1)<=8d^2 eta. The trivial bound P(1)<=1 and Cauchy-Schwarz give the two asserted bounds. QED.

Under coordinatewise maximal coupling of product laws P_i,Q_i, p_i=TV(P_i,Q_i). Under consistent sampling with p_i<=2TV, the squared estimate becomes <=16d^2 max_i TV(P_i,Q_i).

## Exact application to latent product lift
For any fixed component labels theta,theta', shared independent seeds U_i create independent coordinate pairs [h_i(theta,U_i), h_i(theta',U_i)]. Hence
E_U[(G(theta,U)-G(theta',U))^2] <=16d^2 max_i TV(mu_(theta,i),mu_(theta',i))
when using the consistent-sampling coupling advertised in the research brief.

This **is** the missing pointwise pairwise fooling estimate, as a paper-level result. It is **not** the full hidden-coordinate-information alternative in FUR.

## Precise remaining obstacle (invalid max/expectation interchange)
Averaging the preceding bound gives a right side of
16d^2 E_(theta,theta') [max_i TV(mu_(theta,i),mu_(theta',i))].
But information only bounds max_i E_(theta,theta') TV^2. Pinsker and the triangle inequality give
E_(theta,theta') TV(mu_(theta,i),mu_(theta',i))^2 <= 2 I(theta; X_i)
with information measured in nats. In general E max_i cannot be replaced by max_i E.

EXACT COUNTEREXAMPLE TO THAT INTERCHANGE, NOT TO FUR:
take theta uniform on {1,...,n}, mu_theta=point mass on the one-hot vector e_theta. Then
max_i I(theta;X_i)=h(1/n) -> 0
yet E_(theta,theta') max_i TV(mu_(theta,i),mu_(theta',i))=1-1/n -> 1.
Bounded degree-two f with constant variance on this support has **not** been exhibited. Consequently this obstruction does not refute FUR; it refutes only the unweighted averaging step.

## Next decisive degree-two question
For a bounded quadratic multilinear functional of all component marginal probability vectors, can hidden-label variation be controlled by a fixed-weight sum of **per-coordinate** variances/information, rather than an average of pairwise coordinate maxima? Potential operator families: Grothendieck/Hilbert factorization for bilinear forms, weighted sensitivity/junta bounds, or explicit low-degree counterexample. The label's alphabet size M must not enter.

The structural candidate inequality must include, or work alongside, the posterior-averaged **seed increments** because the latent influence of the lifted function is not merely the variance of component means.

## Prior art and certifications
Checked arXiv:2609.35327 (Girish, Mittal, Nehoran, Raz: fixed biased product and slice variants), 2026 papers on mixtures and product-TV computation, and the canonical NIGHTFALL Mixture-AA brief. The method uses the **classical** univariate Markov brothers inequality: no novelty is claimed. This exact theorem formulation was not found in the narrow session search, which is not priority clearance.

CERTIFICATION: reproducible author-side mathematical derivation, requiring a Lean or independent formal proof and outside referee before theorem promotion. The final poly(d) FUR and polylog(M) quantum simulation remain OPEN.
