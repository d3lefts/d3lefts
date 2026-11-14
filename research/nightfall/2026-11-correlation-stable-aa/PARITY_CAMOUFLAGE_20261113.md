# Parity camouflage: exact low-degree moment agreement with vanishing conditional influence

**NIGHTFALL counterexample theorem | 13 November 2026 | Author-directed AI-assisted derivation**

**Status:** Exact elementary analytic proof plus Fraction-only finite enumeration; classical parity conditioning is a known primitive. The exact quantitative comparison below is derived here *within the research programme*. No worldwide novelty or externally independent referee status is asserted.

## Theorem: covariance-blind conditional influence attenuation

Fix n>=3 and the uniform product reference \(\mu\) on \(\{-1,+1\}^n\). Write
\(\chi(x)=\prod_{j=1}^n x_j\). For \(0\le\tau\le1\) let

\[
\nu_\tau(x)=2^{-n}[1+(1-\tau)\chi(x)].
\tag{1}
\]

Equivalently \(\nu_\tau\) is the mixture of an even-parity law, weight \(1-\tau\), and the ordinary uniform law, weight \(\tau\).

**(i) Exact moment camouflage.** The measure \(\nu_\tau\) is \((n-1)\)-wise independent: every proper subset of coordinates has precisely the corresponding fair-product distribution. Hence expectations of every monomial of Fourier degree \(<n\) match \(\mu\). In particular, if f and g both have reference Fourier degree at most d and \(2d<n\), then

\[
\mathbb E_{\nu_\tau}f=\mathbb E_\mu f,\quad
\mathbb E_{\nu_\tau}(fg)=\mathbb E_\mu(fg),\quad
\operatorname{Cov}_{\nu_\tau}(f,g)=\operatorname{Cov}_\mu(f,g).
\tag{2}
\]

**(ii) Exact conditional-influence operator scaling.** For **every** real function f on the cube (no degree restriction) and **every coordinate i**,

\[
\boxed{ I_i^{\nu_\tau}(f)=(2\tau-\tau^2)I_i^\mu(f).}
\tag{3}
\]

Here \(I_i^\nu(f)=\mathbb E_\nu\operatorname{Var}_\nu(f\mid X_{-i})\). This is *not* the unconditional marginal-coordinate resampling form used for independent sources.

**(iii) Failure of arbitrary-correlation Aaronson–Ambainis.** At \(\tau=0\), take the degree-one function \(f(x)=x_1\). Then \(|f|=1\), \(\operatorname{Var}_{\nu_0}f=1\), but \(I_i^{\nu_0}(f)=0\) for **every** i. Thus no positive influence lower bound based solely on a low-degree reference representation and variance can hold for all correlated measures.

**(iv) Quantitative restriction on dependence penalties.** For \(\tau>0\), the likelihood ratio \(d\nu_\tau/d\mu\) lies in \([\tau,2-\tau]\), so \(R=(2-\tau)/\tau\). The exact all-function conditional-influence attenuation is

\[
\boxed{2\tau-\tau^2=\frac{4R}{(R+1)^2}\sim \frac4R.}
\tag{4}
\]

In this example any uniform lower influence theorem cannot permit a dependence penalty asymptotically better than order \(R^{-1}\) without additional conditions. The proven general \(R^{-5/2}\) transfer leaves a quantitative \(R\)-exponent gap, an actual research target.

## Proof

Fourier orthogonality gives
\(\mathbb E_{\nu_\tau}h=\mathbb E_\mu h+(1-\tau)\mathbb E_\mu(h\chi)\).
Any monomial supported on a proper subset of coordinates is orthogonal to the full parity character. Products of reference-degree-d functions have degree at most \(2d\), proving (i).

Fix i and any assignment of the other n-1 signs. The marginal distribution of those other signs is uniform for \(\nu_\tau\). Conditional on them, \(X_i\) equals the unique sign completing even parity with probability \(1-\tau/2\), and equals the opposite sign with probability \(\tau/2\). For the two possible values \(f_+,f_-\), conditional variance is \(p(1-p)(f_+-f_-)^2\). Under \(\nu_\tau\), \(p(1-p)=(\tau/2)(1-\tau/2)\), while under fair product it is \(1/4\). Since the distribution of \(X_{-i}\) is *identical* to the product marginal, integrating gives (3) exactly for every f. The example f=x1 at tau=0 gives (iii). The ratio algebra yields (iv). QED.

## Distinguish the proved obstruction from overclaims

This does NOT show that an influence theorem fails for bounded-positive-density distributions with a fixed R: tau=0 has R=infinity. It does not show that k-wise independence is new or that every local-correlation condition is insufficient. Nor does it contradict the original independent-product theorem or its correlation-transfer corollary.

It shows that even *perfect covariance agreement on the entire low-degree function space* does not control conditional resampling influence. A successful generalization beyond the global R bound must preserve a quantitative comparison of conditional-coordinate Dirichlet forms, not merely low-order moments or unconditional covariance geometry.

## Reproduce

Run Python 3.11+ standard library only:
  
    python3 check_parity_camouflage.py

The saved integer/rational checker exhausts n=3,...,8; tau=0,1/13,1/3,1/2,3/4,1; randomized rational values of unrestricted f; and degree<=2/3 polynomials. Its recorded local result is 1,584 exact influence identities, 108 covariance/moment tests and 1,836 monomial comparisons. The CI replay source and active commit must be checked separately before claiming a hosted receipt.

**Next decisive experiment:** derive a hereditary coordinate-Dirichlet comparison that can be authenticated locally even if the full-system likelihood ratio R grows exponentially with n; test it against parity-tilt and constrained-spin systems, while retaining low-degree reference structure.