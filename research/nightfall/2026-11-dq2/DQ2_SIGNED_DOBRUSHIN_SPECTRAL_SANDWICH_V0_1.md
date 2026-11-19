# DQ2 v3 — Spectral-sandwich transfer on signed frustrated Ising graphs

Status (2026-11-17): author-derived analytic result, exact finite-state audits; NO Lean kernel, external human referee, originality certificate, or claim promotion. Original finite independent-spin Q2 theorem with constant K0=(2(1+sqrt(2))*sqrt(3)+11901/6250)^2 is an explicit existing premise. Previous loopy ferromagnetic research was merged in PR #788; weighted signed trees remain in draft #786.

## Research contract
Objective: preserve variance-squared/max-original-site-influence for physical quadratic functions on general zero-field binary graphical systems with negative edges, frustration and unbounded cycle rank, with a coefficient independent of number of vertices. Weakest useful inputs: full-function heat-bath Poincare inequality, lower spectral bound for the linear spin covariance matrix, and uniformly positive conditional spin variance. Strongest external spectral input checked this session: Liming Wu, Poincare and transportation inequalities for Gibbs measures under the Dobrushin uniqueness condition (2006), https://arxiv.org/abs/math/0611635; Eldan–Koehler–Zeitouni, A spectral condition for spectral gap (2022), https://arxiv.org/abs/2007.08200; Koehler–Lifshitz–Minzer–Mossel, Influences in Mixing Measures (STOC 2024), https://arxiv.org/abs/2307.07625. This is NOT a novelty review with a positive priority outcome.

## A. Abstract spectral-sandwich Q2 theorem (author analytic, any mean-zero binary law)

Let nu be any full-support probability law on {-1,+1}^n with E_nu Xi=0. Let mu be independent fair signs, C=Cov_nu(X), and I_i^nu(h)=E_nu Var_nu(h | all coordinates except i). Assume:
- (P) For every real h, Var_nu(h) <= A sum_i I_i^nu(h), with A>=1.
- (C) C >= gamma*Identity as quadratic forms, gamma>0.
- (U) Each Var_nu(Xi | X_-i)>=v>0 pointwise.

Then for every physical quadratic f(x)=c+sum_i a_i xi+sum_{i<j} b_ij xi*xj with |f|<=B,

  Var_nu(f)^2 <= 4*K0*A^4/(v*gamma) * B^2 * max_i I_i^nu(f).

Proof: For h=sum_i u_i Xi, I_i^nu(h)<=u_i^2, so (P) implies C<=A*Identity. Set g_i=a_i+sum_{j ne i}b_ij Xj. Then I_i^nu(f)=E(w_i g_i^2), with w_i=Var(Xi|X_-i). Since E Xj=0,
I_i^nu(f)<=E g_i^2=a_i^2+b_i^T C b_i<=a_i^2+A sum_j b_ij^2.
Summing and invoking P gives
Var_nu(f)<=A (sum_i a_i^2+2A sum_{i<j} b_ij^2)
<= 2 A^2 Var_mu(f), since A>=1.
The other direction is
I_i^nu(f)>=v E g_i^2>=v(a_i^2+gamma sum_j b_ij^2)>=v gamma I_i^mu(f),
since gamma<=C_ii=1. Square the variance comparison, apply the existing independent Q2 theorem, then substitute the influence lower comparison. No claims about dependent-Hoeffding degree or commutation are needed. All premises must be checked for the actual dependent law.

## B. Signed Ising transfer in Dobrushin regime

Let nu(x) proportional to exp(sum_{ij in E} J_ij xi*xj) for any finite simple graph, arbitrary signed finite J_ij, zero external field. Put t_ij=tanh(abs(J_ij)), alpha=max_i sum_j t_ij<1.

Classical Dobrushin–Poincare: flipping neighbor j perturbs the single-site conditional of i in total variation by at most t_ij. The symmetric Dobrushin influence matrix has operator norm at most alpha. The continuous-time single-site heat-bath generator sum_i(Q_i-Id) has spectral gap >=1-alpha (Wu 2006 / classical coupling), giving (P) with A=(1-alpha)^(-1), for the genuine I_i normalization. Random-scan discrete-time heat bath has an extra 1/n factor; do not confuse them.

Use the merged-#788 signed dual-score lemma: m_i=E[Xi|X_-i]=tanh(sum_j J_ij Xj), w_i=1-m_i^2, U_i=(Xi-m_i)/w_i. Then Cov(Xj,U_i)=delta_ij, and Q=Cov(U) is sparse on graph edges. Define H_i=sum_j abs(J_ij), H=max H_i, and
D=max_i [cosh(H_i)^2+ 0.5 sum_j sinh(2 abs(J_ij)) exp(2(H_i-abs(J_ij)))].
Its row-sum bound gives ||Q||op<=D. Cauchy-duality yields C>=D^(-1)*Identity. Also w_i>=v=sech(H)^2.

The abstract theorem therefore gives

  Var_nu(f)^2 <= 4*K0*D*cosh(H)^2/(1-alpha)^4 * B^2 * max_i I_i^nu(f).

This is independent of vertex count or number of cycles whenever alpha has a uniform gap below one.

## C. Entirely alpha-based closed form

Because sum_j tanh(abs J_ij)<=alpha<1, superadditivity of atanh on nonnegative numbers with sum<1 gives H_i<=atanh(alpha). Hence v>=1-alpha^2. Using 0.5 sinh(2u) exp(2(H-u)) = exp(2H)*tanh(u)/(1+tanh(u))^2, the score bound is
 D <= 1/(1-alpha^2)+alpha*(1+alpha)/(1-alpha)
   = [1+alpha*(1+alpha)^2]/(1-alpha^2).
Thus

  Var_nu(f)^2 <= K0*F(alpha)*B^2*max_i I_i^nu(f),

  F(alpha)=4*[1+alpha*(1+alpha)^2] / [(1-alpha)^4*(1-alpha^2)^2].

F(0)=4, which is transfer slack (the independent theorem itself has coefficient K0). We make no sharpness claim. For any n-by-n signed square grid with maximum degree four and |tanh J|<=r<1/4, alpha<=4r and this yields a uniform coefficient even with O(n^2) frustrated plaquettes. On signed odd cycles, r<1/2 suffices.

## D. Infinite correlated systems (author-analytic corollary, separate gate)

On a countable locally finite graph with signed finite J and sup_i sum_j tanh|J_ij|<=alpha<1, classical Dobrushin uniqueness yields a unique zero-field Gibbs state, the weak limit of finite free-boundary states. The same finite bound is uniform along the exhaustion. For a bounded algebraic quadratic cylinder f, its variance converges by weak convergence; after the volume includes all neighbors of the cylinder support, the local Gibbs/DLR conditional-spin formula coincides in finite and infinite law, so native site influences converge as expectations of finite-coordinate functions. Influences vanish outside the support. Pass the inequality to the limit. For L2 limits of uniformly B-bounded quadratic cylinder f_k, use the 1-Lipschitz property of sup_i sqrt(I_i) (each conditional residual is an orthogonal projection). This covers correlated infinite-volume signed Gibbs models in the stated uniqueness regime, but not arbitrary phases, graphs of unbounded local degree or dependent ANOVA-degree classes. Needs independent measure-theory review and Lean formalization.

## E. Exact audit and reproduction

Author-side checker source locally pinned at SHA256 5d7b2589cb730ffebb792481d6054abd146c8035d5b09211a44668d9edd8f385 before repository upload. It uses Fraction full-state enumeration and exact LDL matrices:
- complete 2^n state Dirichlet minus (1-alpha)*variance form (all-function Poincare; not random samples);
- all conditional scores from native two-atom conditional laws, exact Cov(X,U)=Id and off-graph zeros;
- score covariance row norms and lower spin covariance C>=D^(-1)*Id;
- full algebraic quadratic covariance matrix bound, all quadratic site gradient PSD comparisons;
- ten secondary deterministic low-degree polynomial checks.

Passed instances: frustrated triangle n=3 (alpha=11/30), frustrated square n=4 (alpha=13/40), signed square with chord n=4 (alpha=257/770), frustrated pentagon with chord n=5 (alpha=157/520), and mixed-sign K4 (alpha=43/195). All arithmetic rational. A new GitHub exact-head CI gate will be required; author-side arithmetic does not prove the universal theorem or supersede its classical Poincare input.

## F. Review, significance and next operator

Independent mathematical audit must attack normalization (continuous-time vs random scan), universal alpha-to-H conversion, score off-edge conditional measurability, all-quadratic Poincare composition, n=0 and n=1 edges, and infinite DLR convergence. Run an independent implementation of at least one full Poincare rational matrix. Formalize the abstract spectral sandwich in Lean as a theorem *with explicit hypotheses*; the signed score and Dobrushin gap are separate dependencies. Prior art is unresolved: Wu, Eldan–Koehler–Zeitouni and Koehler–Lifshitz–Minzer–Mossel may already imply this transfer. Do not claim novelty, a sharper coefficient or an unconditional Lean theorem, and do not merge as a verified landmark.

Cheapest decisive next experiment (completed): exact full-function PSD checks on five frustrated finite graphs. Next stop gate: an independent reviewer must validate the analytic spectral-sandwich and compare it with existing Ising low-degree influence theorems. Discovery graph: dependent Q2 -> physical algebraic degree -> full-law Poincare and covariance sandwich -> actual-site influence -> signed frustrated all-graph Q2 -> rational checker -> infinite correlated extension -> limitations (Dobrushin alpha<1, zero field, binary spin, algebraic degree two) -> transfer to correlated sensing.


## G. Cubic barrier — exact connected-chain counterexample to degree-independent covariance transfer

This is an important **negative control**, not a counterexample to the quadratic theorem. Fix any 0<r<1/2 and any integer k>=2. Take the connected zero-field (k+2)-spin Ising chain X0,Y1,...,Y_{k+1} with *every* edge tanh J=r. Its Dobrushin parameter is alpha=2r<1 (for the interior). Let

  f_k(X0,Y) = (X0/k) sum_{j=1}^k Y_j Y_{j+1}.

This is a bounded |f_k|<=1 algebraic degree-three polynomial. Global spin-flip symmetry gives E_nu f_k=0. On a zero-field Ising tree the bond variables Z_j=Y_jY_{j+1} are independent with E Z_j=r, so

  Var_nu(f_k) = E[(sum_j Z_j / k)^2]
              = r^2+(1-r^2)/k.

Under the fair independent-spin reference law mu, these k bond variables are independent mean-zero signs, so Var_mu(f_k)=1/k. Consequently

  Var_nu(f_k)/Var_mu(f_k) = 1+(k-1)r^2 -> infinity.

There is therefore **no dimension-uniform constant depending only on the Dobrushin alpha** satisfying Var_nu(f)<=K(alpha) Var_mu(f) for *all bounded algebraic degree-three polynomials*, even on weakly correlated connected Ising chains with a fixed 1D degree bound. This invalidates the tempting attempt to extend the quadratic spectral-sandwich variance comparison to cubic functions without additional cancellations. It does not refute a genuine cubic variance-squared/maximum-actual-influence inequality: I_{nu,X0}(f_k)=(1-r^2)Var_nu(f_k), because the true one-site conditional variance of X0 given Y1 is 1-r^2; thus an influential coordinate is still present.

Mechanism: the quadratic gradient with respect to X0 has coherent nonzero mean E_nu[(sum_j Y_jY_{j+1})/k]=r. This creates a nonvanishing linear effective component when physical-spin cubic monomials are measured under nu. Degree-three repair should center bond contractions / use a law-adapted Wick or chaos decomposition before assuming covariance-sector comparability. Exact rational bond-product checks for r=1/3, k=2,3,4,6,10 match the displayed identity.

**No new landmark claim from this obstruction alone:** tree bond independence and the computation are elementary classical facts; it is a diagnostic theorem/counterexample establishing why quadratic transfer does not naively extend. It should be preserved with the DQ2 certificate so future cubic work does not repeat the failed operator family.
