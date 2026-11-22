# Two quantitative upgrades for Route 1 squared-loss tail transfer

**Checkpoint:** 2026-11-22. **Parent:** draft PR #988, `LOW_DEGREE_QUERY_RISK_CONSERVATION_20261121.md` v1.3. **Transfer target:** draft PR #987. **Scope:** paper-level universal proofs, finite exact checks; NOT Lean-certified, externally refereed, or novel-priority cleared. These bounds use classical Hoeffding/Jackson tools.

## Original assumptions and exact reusable interface

Let \(\nu,Q\) be arbitrary PMFs on the same finite Cartesian alphabet. Let \(f:X\to[0,1]\) be interaction-degree at most \(d\), and let \(t:X\to[0,1]\) be a deterministic original-coordinate decision tree of depth at most \(q\). No product, full support, or independence assumption is imposed. Set \(Z=(f-t)^2\in[0,1]\). Fix a positive integer \(m\). Assume the two laws agree on all coordinate marginals of order

\[
k\ge K_m=\min\{n,\max(2md,(2m-1)d+q)\}.
\]

As proved by the parent PR, \(\mathbb E_\nu Z^j=\mathbb E_Q Z^j\) for \(j=0,\ldots,m\). Thus **every real polynomial \(p\) of degree at most \(m\) has identical expectation when evaluated at \(Z\)**. Everything below uses this exact interface without additional assumptions.

## Theorem A: binomial-threshold exponential envelope

For \(0\le a<a+\gamma\le1\), \(m\ge1\), put \(\beta=\exp(-m\gamma^2/2)\). Since \(0<\beta<1\),

\[
\boxed{\Pr_\nu(Z\ge a+\gamma)
\le \frac{\Pr_Q(Z>a)+\beta}{1-\beta}
\le \Pr_Q(Z>a)+\frac{2\beta}{1-\beta}.}
\]

Consequently for any \(0<\eta\le1\), it suffices to take

\[
\boxed{m\ge \left\lceil\frac{2}{\gamma^2}\log\frac4\eta\right\rceil}
\quad\Longrightarrow\quad
\Pr_\nu(Z\ge a+\gamma)\le\Pr_Q(Z>a)+\eta.
\]

**Proof (explicit polynomial certificate).** Let \(c=a+\gamma/2\) and \(r=\lceil mc\rceil\), which lies in \(\{1,\ldots,m\}\). Define

\[
B_{m,r}(z)=\sum_{j=r}^{m}\binom mj z^j(1-z)^{m-j}
  =\Pr\{\operatorname{Bin}(m,z)\ge r\}.
\]

It is a degree-\(m\) polynomial with values in \([0,1]\) on \([0,1]\). When \(z\le a\), its binomial upper tail is at most \(e^{-2m(c-z)^2}\le\beta\). When \(z\ge a+\gamma\), its lower tail \(\Pr\{\operatorname{Bin}(m,z)<r\}\) is at most \(e^{-2m(z-c)^2}\le\beta\): the integer inequality \(Y<\lceil mc\rceil\) implies \(Y<mc\), avoiding a discretization loss. These are standard one-sided Hoeffding bounds for Bernoulli trials. Therefore

\[
(1-\beta)\mathbf1_{\{z\ge a+\gamma\}}\le B_{m,r}(z)
\le \mathbf1_{\{z>a\}}+\beta
\]

pointwise on \([0,1]\). Integrate the left under \(\nu\), replace \(\mathbb E_\nu B=\mathbb E_Q B\) by moment equality, and integrate the right under \(Q\). Finally \(2\beta/(1-\beta)\le\eta\) when \(\beta\le\eta/4\) and \(0<\eta\le1\). QED.

This is a **rate improvement** relative to the parent theorem's additive \(1/(\gamma\sqrt m)\), not a discovery of Hoeffding concentration or Bernstein polynomials.

## Theorem B: complementary explicit Jackson-kernel envelope

Under the same hypotheses, for every integer \(L\ge1\) with \(2(L-1)\le m\),

\[
\boxed{\Pr_\nu(Z\ge a+\gamma)
\le\Pr_Q(Z>a)+\frac{3\pi}{2\gamma L}.}
\]

Choosing \(L=\lfloor m/2\rfloor+1\) gives additive at most \(3\pi/(\gamma m)\) for \(m\ge1\), and suffices to take \(m\ge\lceil3\pi/(\gamma\eta)\rceil\) for error \(\eta\).

**Self-contained constant.** Let \(h(z)=0\) if \(z\le a\), \(h(z)=1\) if \(z\ge a+\gamma\), and interpolate linearly between. Define the even periodic function \(g(\theta)=h((1+\cos\theta)/2)\), which is \(1/(2\gamma)\)-Lipschitz on the circle. Write

\[
J_L(\theta)=\left|\sum_{j=0}^{L-1}e^{ij\theta}\right|^4
=\left(\frac{\sin(L\theta/2)}{\sin(\theta/2)}\right)^4,
\qquad A_L=\int_{-\pi}^{\pi}J_L(\theta)\,d\theta
=\frac{2\pi}{3}(2L^3+L).
\]

Its Fourier degree is \(2(L-1)\), and \(J_L\ge0\). With \(|J_L(\theta)|\le\min(L^4,\pi^4/|\theta|^4)\) and the split at \(|\theta|=\pi/L\),

\[
\int_{-\pi}^{\pi}|\theta|J_L(\theta)d\theta\le2\pi^2L^2,
\qquad
A_L\ge\frac{4\pi}{3}L^3.
\]

Convolution \(G_L=(J_L/A_L)*g\) is an even trigonometric polynomial of degree at most \(2(L-1)\), hence \(G_L(\theta)=p_L((1+\cos\theta)/2)\) for some ordinary polynomial \(p_L\) of the same degree. Its nonnegative normalized kernel guarantees \(0\le p_L\le1\), and the first-moment estimate gives

\[
\sup_{0\le z\le1}|p_L(z)-h(z)|
\le\frac{1}{2\gamma}\frac{3\pi}{2L}=\frac{3\pi}{4\gamma L}.
\]

Moment equality transfers \(\mathbb E p_L(Z)\), hence \(|\mathbb E_\nu h(Z)-\mathbb E_Q h(Z)|\le3\pi/(2\gamma L)\). Sandwich \(\mathbf1_{\{z\ge a+\gamma\}}\le h(z)\le\mathbf1_{\{z>a\}}\). QED.

The standard Jackson kernel and its rate are classical approximation theory; the displayed normalization and constants are included so the certificate is independent of a black-box approximation theorem.

## Exact source-calibrated Route 1 consequence

Suppose the merged Route 1 / Wyner theorem produces a bounded depth-\(q\) tree \(t\) under \(Q\) with \(\Pr_Q(|f-t|>\varepsilon_0)\le\delta_0\). Clip leaves to \([0,1]\). For any \(\varepsilon_1>\varepsilon_0\), set \(\gamma=\varepsilon_1^2-\varepsilon_0^2\) and choose \(m\) by **either** theorem (or the better of their two sufficient requirements). If \(\nu,Q\) match through the actual \(K_m\), then

\[
\Pr_\nu(|f-t|\ge\varepsilon_1)\le\delta_0+\eta.
\]

Unlike the earlier Markov bridge, the source tolerances do not need an \(\varepsilon^2\delta\) rescaling. Unlike the parent Bernstein ramp, the marginal-order requirement is bounded by

\[
K_m=O\!\left(q+d\cdot\min\left\{
\frac{\log(1/\eta)}{\gamma^2},\frac1{\gamma\eta}
\right\}\right)
\]

at these explicit constants. **This is a certificate-strength improvement, not a reduction of the actual Route 1 query count \(q\).** The moment-matching order \(K_m\) depends on the simulator's actual \(q\); checking it after choosing \(q\) is mandatory.

For \(\varepsilon_0=\varepsilon/2\), \(\varepsilon_1=\varepsilon\), \(\gamma=3\varepsilon^2/4\). At \(\varepsilon=1/2,\eta=0.05\), the sufficient counts are original \(m=11{,}378\), Hoeffding \(m=250\), Jackson \(m=1006\) (using the stated conservative Jackson simplification). The first is \(45.5\times\) larger than the best new bound; no end-to-end simulator speedup is claimed.

## Independent audit, limitations, transfer and priority

- A separately implemented exact rational parity-family checker validates the degree-m polynomial expectation identity, first-m raw moment equality under different laws, the binomial envelope inequalities on rational grids, and the Jackson Fourier-normalization identity. **Finite tests are not the universal proof.**
- Proof-attack gates: check endpoint inequalities \(z=a,a+\gamma\), \(r=1,m\), empty/full alphabets, deterministic zero-mass transcripts, and the exact sign of \(\ge\) versus \(>\). Separately audit use of the original-oracle query interface and the dependence of \(K_m\) on \(q\).
- The result does **not** solve the approximate-marginal Simon regime. In fact PR #988's four-point collision example shows large relative Gram distortion even when absolute discrepancies are small. A possible next operator is transcript-conditional coupling/hazard, with an honest query cost; it remains open for general bounded degree-d targets.
- **Credit:** Route 1 / Wyner base theorem belongs to the existing credited contributors of merged PR #970; the moment-conservation source is PR #988. Hoeffding's inequality and Jackson polynomial approximation are classical. This note sharpens a quantitative bound in the NIGHTFALL application only. No independent priority, Lean kernel, or peer-review claim.
- **Stop rule:** do not expend tokens further polishing the constants until the source-matched moment threshold can actually be obtained for a nontrivial online reference, or until a counterexample rejects the proposed transfer.

References: Hoeffding (1963); Jackson approximation theorem; parent draft PRs #988 and #987; exact verifier `scripts/check_route1_tail_envelopes_exact.py`.
