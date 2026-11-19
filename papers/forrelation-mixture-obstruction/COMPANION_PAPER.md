# Exponential Product-Mixture Complexity of Gaussian-Sign Forrelation

**NIGHTFALL collaboration · companion working preprint · v0.1 · 19 November 2026**

**Status:** publicly released working manuscript; analytic paper derivation, *not* a complete Lean-certified Gaussian theorem, independently human refereed paper, or claim of established novelty. Attribution and contributor identity remain subject to final review.

## Abstract

For an orthogonal matrix \(H\), sample \(Z\sim\mathcal N(0,I_N)\) and set \(F=\operatorname{sgn}Z\), \(G=\operatorname{sgn}(HZ)\). We quantify the minimum number \(M\) of latent components necessary to express the unconditioned sign law as a mixture of laws that are independent between the \(F\) and \(G\) blocks. Using standard Gaussian sign-correlation and a per-coordinate binary-entropy information witness, we obtain

\[
\log M\ge N\phi(2/\pi)=0.21920054682616779\ldots N,
\]

where \(\phi(t)=\frac{1+t}{2}\log(1+t)+\frac{1-t}{2}\log(1-t)\). An approximation within total variation \(\eta\le 1/2\) still requires

\[
\log M\ge N[\phi(2/\pi)-2\eta\log2]-2h_2(\eta).
\]

For 1% total variation the rate is \(0.20533760321496889\ldots N\) minus \(0.11200306870969468\ldots\). The earlier lower-bound exponent \(2/\pi^2=0.20264236728467554\ldots\) is mathematically valid, but strictly weaker: it follows from a single aggregate-moment bound instead of the exact per-coordinate fair-sign information function. Both proofs and their trust boundaries are preserved below.

**Scope:** unconditioned Gaussian-sign Forrelation, not arbitrary promise-conditioning or a complete characterization of quantum advantage. The bound also holds for mixtures of *block*-independent distributions (a stronger restriction on representation complexity than full-coordinate independence).

---

## Definitions and principal results

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

## Gaussian sign-correlation lemma (elementary analytic proof)

For a centered bivariate Gaussian \((X,Y)\) with unit variances and correlation \(\rho\in[-1,1]\),

\[
\mathbb E[\operatorname{sgn}(X)\operatorname{sgn}(Y)]
=\frac2\pi\arcsin\rho.
\]

**Proof.** For \(|\rho|<1\), represent \((X,Y)=(U,\rho U+\sqrt{1-\rho^2}V)\), where \(U,V\) are independent standard normals. The joint density of \((U,V)\) is rotationally invariant, so its polar angle is uniform on \([0,2\pi)\). The normals of the two sign half-spaces make angle \(\theta=\arccos\rho\). The signs disagree on arcs of total angular measure \(2\theta\), hence with probability \(\theta/\pi\). Their product therefore has expectation \(1-2\theta/\pi=(2/\pi)\arcsin\rho\). The \(|\rho|=1\) cases are immediate. **QED.**

This closes the Gaussian sign identity in the **paper proof** without requiring the reader to take it on faith; a Lean formalization remains open in [Mathlib #42600](https://github.com/leanprover-community/mathlib4/issues/42600).

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

## Reconciliation of the two constants

The original reviewer proof observes the aggregate Forrelation statistic \(S(F,G)=F^{\mathsf T}H^{\mathsf T}G/N\). For flat Hadamard matrices, Gaussian sign-correlation gives its mean

\[
\alpha_N=\frac{2\sqrt N}{\pi}\arcsin(1/\sqrt N)\ge2/\pi.
\]

The uniform independent-block reference measure \(U\) satisfies the exact sub-Gaussian estimate \(\log\mathbb E_U e^{\lambda S}\le\lambda^2/(2N)\). The KL variational inequality implies

\[
I_P(F;G)=D(P\Vert U)\ge \frac N2\alpha_N^2
\ge \frac{2N}{\pi^2}=0.20264236728467554\ldots N.
\]

This is the valid older moment inequality, supported in abstract form by the certified latent-mixture MGF operator in NIGHTFALL PR #869. The sharpened proof above instead retains each \(F_i\)-to-\(G\) correlation witness and applies the exact binary information function, whose positive-coefficient series is

\[
\phi(t)=\frac{t^2}{2}+\frac{t^4}{12}+\frac{t^6}{30}+\cdots.
\]

Thus \(\phi(2/\pi)=0.21920054682616779\ldots>2/\pi^2\), an improvement of \(0.01655817954149225\ldots\) nats per coordinate (approximately 8.17% relative to the weaker rate). For normalized Walsh–Hadamard order \(N\), the strictly better finite-\(N\) coefficient is \(\phi(\alpha_N)\).

**Version rule:** quote 0.2192005468 as the universal sharpest currently derived exponent. Quote 0.2026423673 only as the previous, weaker MGF lower bound; do not present them as conflicting results.

## Formalization, prior art and publication status

The proof relies on the published Sheppard Gaussian sign identity, which is not currently available as a theorem in NIGHTFALL's pinned Mathlib. See [Mathlib issue #42600](https://github.com/leanprover-community/mathlib4/issues/42600). [NIGHTFALL PR #869](https://github.com/d3lefts/d3lefts/pull/869) has a successful pinned Lean certificate for the **abstract, weaker exponential-moment operator**, not the Gaussian-sign source nor the stronger entropy exponent. [PR #871](https://github.com/d3lefts/d3lefts/pull/871) contains scoped conditional entropy terminals but does not close their analytic premises. Neither the exact sharp exponent nor the TV-robust specialization is currently a fully kernel-certified Gaussian theorem.

- [Aaronson and Ambainis, *Forrelation: A Problem That Optimally Separates Quantum from Classical Computing*](https://arxiv.org/abs/1411.5729), SIAM J. Comput. (2018): the Gaussian sign-rounding source and original quantum/classical problem.
- [Girish and Servedio, *Forrelation Is Extremally Hard*](https://doi.org/10.4230/LIPIcs.ITCS.2026.72), ITCS 2026: explicit Gaussian sign construction and expectation 2/pi.
- [Tim Austin, *Multi-variate correlation and mixtures of product measures*](https://doi.org/10.14736/kyb-2020-3-0459), Kybernetika 56 (2020): existing structural theory of product mixtures.
- A. D. Wyner (1975), *The Common Information of Two Dependent Random Variables*: standard latent-variable mutual information bounds.
- [NIGHTFALL PR #858 review discussion](https://github.com/d3lefts/d3lefts/pull/858): AI-reviewer-origin exponential obstruction. [NIGHTFALL PR #868](https://github.com/d3lefts/d3lefts/pull/868): dated independent audit and entropy/TV strengthening.

**Attribution:** This companion uses Aaronson–Ambainis's pre-existing Gaussian Forrelation distribution and standard common-information tools. The exponential-mixture obstruction was suggested in NIGHTFALL's AI-assisted review thread, and the sharper binary-entropy proof appeared in its later audit. These do not constitute independent human peer review or complete priority clearance. Author and contributor attribution must be finalized before archival external submission.

## Reproducibility

The adjacent Python checker is standard-library-only and tests the exact two-dimensional Gaussian angular sectors, finite rectangular-support ranks, 3,486 rational conditional-entropy comparisons, and the sharp numeric coefficients. Finite tests are not a certificate of the infinite family or Gaussian arcsine identity. The [proof passport](PROOF_PASSPORT.md) names each certificate and unresolved dependency. The PDF companion version is typeset from an independently checked LaTeX presentation of the same theorems; the public Markdown is the textual source of record.
