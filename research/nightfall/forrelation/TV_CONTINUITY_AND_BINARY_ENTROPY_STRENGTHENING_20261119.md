# Product-mixture obstruction: sharper exact exponent and robust conditional-entropy transfer

**NIGHTFALL / 2026-11-18 ET / author-side independent second check / v0.1**

**Ownership and provenance.** This is a quantitative strengthening of the reviewer-origin
exponential Forrelation obstruction recorded in #858, NOT an independent proof of
Aaronson–Ambainis's Forrelation result and NOT the quantum-query simulation theorem.
The finite checker is separate; no full Lean kernel or independent human referee review
is claimed. The two-block finite MGF operator is being formalized independently in #869;
do not duplicate or misattribute it.

## Objective and exact statement

Let H be any real N×N orthogonal matrix; Z have iid standard normal entries;
F=sign Z and G=sign(HZ). Let P be their *unconditioned* joint law on 2N fair
Rademacher coordinates. For t in [-1,1], put

    phi(t) = (1+t)/2 log(1+t) + (1-t)/2 log(1-t),     0 log 0 := 0.
    c = phi(2/pi) = 0.2192005468261678... nats per coordinate.

All logarithms are natural. An exact decomposition of P into M fully
coordinate-independent product laws must obey

    log M >= sum_i phi(r_i) >= N c,

where r_i = (2/pi) sum_j H[j,i] asin(H[j,i]) >= 2/pi. For flat Walsh–Hadamard,
r_i = a_N = (2 sqrt(N)/pi) asin(1/sqrt(N)), and the tighter bound is
log M >= N phi(a_N).

For any M-component full-coordinate product mixture Q with TV(P,Q) <= eta,
0 <= eta <= 1/2, the **sharpened robust bound** is

    log M >= N [ phi(2/pi) - 2 eta log(2) ] - 2 h_2(eta),

where h_2(t)=-t log t-(1-t) log(1-t). At eta = 0.01,

    log M >= 0.2053376032149689... N - 0.1120030687096947...

This improves the prior #858 reviewer bound
    log M >= N [phi(2/pi)-4 eta log(2)] - 3 h_2(eta).
The asymptotic exponential rate is positive for
    eta < phi(2/pi)/(2 log 2) = 0.1581197709331307...
under this certificate, versus ~0.07906 for the previous entropy-continuity
argument. This threshold is **sufficient**, not claimed sharp.

## Proof A: per-coordinate binary-entropy information certificate

Each F_i and G_j is a fair sign; within each block the coordinates are mutually
independent. Let T_i=(H^T G)_i. Since H is orthogonal and G is iid uniform
sign, E T_i^2 = 1. Gaussian sign-arcsine correlation gives

    r_i = E[F_i T_i] = (2/pi) sum_j H[j,i] asin(H[j,i]).

For all |u|<=1, u asin(u)>=u^2; because every column of H has squared norm 1,
r_i>=2/pi. Define m_i(g)=E[F_i|G=g]. Cauchy–Schwarz yields

    E[m_i(G)^2] >= (E[m_i(G) T_i])^2 = r_i^2.

For a fair sign F_i, its mutual information in nats with G is

    I(F_i;G) = E_G phi(m_i(G)).

The map u->phi(sqrt(u)) is nondecreasing convex for 0<=u<=1, as seen from

    phi(sqrt(u)) = sum_{k>=1} u^k / (2k(2k-1)).

Hence Jensen and the L² correlation witness imply
I(F_i;G)>=phi(|r_i|). Independence of all F_i gives, by conditional entropy
subadditivity, I(F;G)>=sum_i I(F_i;G)>=N phi(2/pi).
For any full-coordinate product mixture with latent index Theta,
F and G are conditionally independent given Theta, so
I(F;G)<=H(Theta)<=log M. This proves the exact result.

## Proof B: improved **classical conditional entropy continuity**

For arbitrary finite laws P,Q on X×Y at total variation eta, there is a
maximal common-part decomposition

    P = (1-eta) R + eta P_1,    Q = (1-eta) R + eta Q_1.

Introduce a Bernoulli mixing flag E of weight eta separately for P and Q.
The chain rule gives

    H_P(X|Y) = (1-eta) H_R(X|Y) + eta H_{P_1}(X|Y)
               + I_P(X;E|Y),

with 0<=I_P(X;E|Y)<=h_2(eta), and the same formula for Q.
Since each conditional entropy lies in [0,log|X|],

    |H_P(X|Y)-H_Q(X|Y)| <= eta log|X| + h_2(eta).

This holds with zero atoms and without any lower density assumption. Setting
Y to a singleton gives the same bound for unconditional entropy. Now
I(F;G)=H(F)-H(F|G), and |F|=2^N. Therefore

    I_Q(F;G) >= I_P(F;G) - 2 eta N log2 - 2 h_2(eta).

An M-component product mixture Q has I_Q(F;G)<=log M. Combining with Proof A
gives the robust theorem. This proof has a strictly stronger TV penalty than
bounding all three entropies H(F), H(G), H(F,G) separately.

## Exact N=2 structural audit: rank versus latent mixture size

For the 2×2 normalized Walsh–Hadamard matrix, angular sectors of the 2D
standard Gaussian yield exactly eight (F,G) atoms, each of mass 1/8.
Both 4-state block marginals are uniform, and I(F;G)=log 2.

The 4×4 joint probability table has **ordinary real matrix rank 3**, but
each nonempty support rectangle contains at most two of its eight support
cells. Any nonnegative product-mixture component has rectangular support,
so at least four components are required. Four suffice: condition on F,
and G|F is a product of one fixed and one fair sign coordinate.
Thus the exact minimum full-coordinate product-mixture size is **M=4**.
This finite example checks and distinguishes ordinary rank from latent
nonnegative/product rank. It is not a proof of the general-N exponent.

## Scope, audit, and prior art

* Finite external source: Aaronson and Ambainis, *Forrelation: A Problem that
  Optimally Separates Quantum from Classical Computing*, SIAM J. Comput. 2018,
  Theorem 9, https://www.scottaaronson.com/papers/for.pdf.
* Existing operator prior art: Wyner common information; Tim Austin,
  *Multi-variate correlation and mixtures of product measures*, Kybernetika
  56 (2020), DOI 10.14736/kyb-2020-3-0459.
* Exponential representational gaps in **other distributions** are established:
  Montúfar–Morton, *When Does a Mixture of Products Contain a Product of
  Mixtures?*, SIAM J. Discrete Math., DOI 10.1137/140957081.
* The exact mean-mgf and binary-entropy methods are standard known ingredients;
  their present explicit Forrelation specialization is a **provisional
  contribution candidate**, without claim-specific global priority clearance.
* The law P is unconditioned and uses real Gaussian-sign variables.
  There is NO assertion for the promise-conditioned Forrelation YES distribution,
  nor of a quantitative necessity for correlation in every quantum algorithm.
* Reproduction: run
  python3 research/nightfall/forrelation/check_tv_continuity_strengthening.py
  (pure standard library, deterministic finite arithmetic).
  The checker tests finite instances, not the infinite family nor the Gaussian
  arcsine identity; those remain analytic dependencies.
* Independent audit still requested: exact entropy-continuity common-part
  decomposition, arcsine normalization, finite-universe quantifier handling,
  priority and reviewer attribution. A full Lean certificate, especially
  for the Gaussian-sign specialization, is OPEN.
