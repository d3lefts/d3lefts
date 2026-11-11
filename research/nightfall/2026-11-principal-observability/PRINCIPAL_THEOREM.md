# Universal Product-Space Observability
## Dimension-free adaptive prediction of bounded low-interaction systems

**Research lead:** Devin J. Wright, NIGHTFALL Constellation.  
**Date:** 11 November 2026 (UTC).  
**Status:** Public technical research claim, with analytic proof and an exactly pinned Lean-checked **finite scalar** foundation. The full measurable-product Hilbert adaptive composition is not yet independently refereed or machine checked end-to-end. No global novelty or priority certification is asserted.

**Additional analytic proof source (11 November 2026):** [full-chain proof supplement v1](../../../papers/universal-observability/PROOF_SUPPLEMENT_v1.md) supplies detailed finite-to-measurable, PSD sign, actual posterior drift, measurable coordinate selection and capped-potential arguments; the [chain audit](../../../papers/universal-observability/CHAIN_AUDIT_v1.md) records independent exact finite falsifiers and open specialist review gates. **This does not constitute external referee acceptance or end-to-end Lean certification.**

### Main theorem (analytic)

Let \(F\) be a strongly measurable, real Hilbert-valued observable on an arbitrary independent product probability space, with \(\|F\|\le B\) almost surely and Hoeffding interaction degree at most \(d\ge1\). Let \(\tau_r\) denote the covariance variance beyond the first \(r\) output directions. Put

\[
c_*=\frac{\sqrt{3/12500}}{\pi^6},\qquad
U=\frac{d^7B^3 r^{3/2}}{c_*\eta^{3/2}}.
\]

For every \(\eta>0\), there is a deterministic measurable adaptive whole-coordinate observation rule, using at most

\[
\boxed{N=\left\lceil\frac{40}{3}U\log(1+4U)\right\rceil}
\]

queries, such that its conditional-mean predictor satisfies

\[
\boxed{\mathbb E\|F-\widehat F\|^2\le\tau_r+\eta.}
\]

The bound has **no dependence on input dimension, alphabet cardinality or minimum atom mass**. Laws and observable are assumed known; query selection and conditional-mean computation are not claimed efficient. The index set may be arbitrarily large; strong measurability gives an essentially countable active subset.

**Scalar corollary.** For real \(f\) with \(|f|\le B\), a log-free query bound follows:
\[
N_{\rm scalar}\le\left\lceil\frac{5d^7B^3}{3c_*\eta^{3/2}}\right\rceil.
\]

### Stronger sharp quadratic theorem (analytic)

For degree at most two, define \(V=\operatorname{Var}(f)\), \(M=\sup_i I_i(f)\), \(I_i(f)=\mathbb E|f-\mathbb E_i f|^2\). The quadratic matching proof gives
\[
V\le D B\sqrt M,\qquad D=16(1+\sqrt3),
\]
for arbitrary input alphabets and product laws. For Hilbert-valued outputs, with
\(a_r=\Gamma(r/2)/(\sqrt\pi\Gamma((r+1)/2))\), a separate direct vector proof gives
\[
N_{\rm quad}\le\left\lceil\frac{4D^2 B^2}{a_r^2\eta}\right\rceil
\]
for projected risk at most \(\eta\), plus the spectral tail \(\tau_r\).
For unit-ball rank-\(r\) quadratic observables and \(0<\eta\le1/4\), the worst-case order is \(\Theta(r/\eta)\): the lower bound is already attained by rank-\(r\) additive fair-sign sums. This is an optimal query-scaling classification, not an efficient runtime statement.

### Proof I: finite bias-free scalar theorem and transfer

The merged NIGHTFALL Lean declaration from PR #317 proves for bounded finite-product real functions of indicator-monomial degree at most \(d\), with heterogeneous nonnegative normalized marginal tables and a common finite alphabet type, that some coordinate satisfies
\[
3\operatorname{Var}(f)^5\le12500(\pi^2d^2)^6 I_i(f)^2.
\]
This is **kernel-checked at exactly \(c_*=\sqrt{3/12500}/\pi^6\)**, not the larger coefficient proposed in earlier manuscripts. Pinned source commit: e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb. [Proof passport](../formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md) and [successful Lean receipt](https://github.com/d3lefts/d3lefts/actions/runs/42929857470).

Finite Hoeffding degree implies indicator-monomial degree, because every component on support \(S\) expands into indicator products on \(S\). Heterogeneous finite alphabet types can be embedded into a common disjoint alphabet; a coordinatewise retraction sends invalid symbols to fixed legal ones without increasing degree or supnorm. Scaling yields
\[
\tag{1}
\sup_i I_i(h)\ge c_* A^{-3}d^{-6}\operatorname{Var}(h)^{5/2}
\]
for a real \(|h|\le A\) of degree at most \(d\).

For arbitrary product spaces, strong measurability implies dependence, modulo null sets, on countably many coordinates with countably generated relevant sigma-fields. Approximate by finite rectangular product conditional expectations. The approximants are uniformly bounded, preserve degree (the product projection commutes with coordinate averaging), and cannot increase any influence, while variance converges. Apply the finite statement and pass to the \(L^2\) limit. This measure-theoretic extension is **analytic, not included in the cited Lean theorem**.

### Proof II: random signs compress vector rank

Project \(G=P_rF\) onto the leading covariance rank-\(r\) subspace. Let \(v=\operatorname{Var}(G)\), \(A_i\) be the PSD coordinate influence matrices, \(p=\sum_i\operatorname{tr}A_i\), and \(m=\sup_i\operatorname{tr}A_i\). ANOVA gives \(v\le p\le dv\).

In a covariance eigenbasis, for every \(\varepsilon\in\{\pm1\}^r\), the scalar \(h_\varepsilon=\langle\varepsilon,G\rangle\) has variance \(v\), supnorm at most \(\sqrt r B\), and influence \(\varepsilon^\top A_i\varepsilon\). By (1),
\[
\max_i\varepsilon^\top A_i\varepsilon\ge L:=kv^{5/2},
\quad k=\frac{c_*}{B^3d^6r^{3/2}}.
\]
For PSD \(A\) with \(s=\operatorname{tr}A>0\), Gaussian linearization and the inequality \(\cosh x\le e^{x^2/2}\) give
\[
\mathbb E_\varepsilon e^{\varepsilon^\top A\varepsilon/(4s)}
\le\det(I-A/(2s))^{-1/2}\le\sqrt2 .
\]
A convex-chord inequality, \(\exp(\max_i z_i)-1\le\sum_i(\exp z_i-1)\), and Jensen give
\(L\le4m\log(1+(\sqrt2-1)p/m)\).
Logarithmic inversion yields
\[
\tag{2}
m\ge\frac{kv^{5/2}}{8\log(1+4p/(kv^{5/2}))}.
\]

### Proof III: exact posterior influence descent

After a nonanticipating finite transcript the unqueried inputs retain a product posterior law, and the conditional function has degree at most \(d\) almost everywhere. Greedily reveal a coordinate of largest posterior trace influence. Let \(v_t,p_t,m_t\) be expected posterior variance, total influence and maximal trace influence. Convexity of \(v^{5/2}\) and concavity of \(m\log(1+a p/m)\) transport (2) through expectation.

The exact ANOVA identity for querying coordinate \(i\) is
\[
\mathbb E_{X_i}T(G\mid X_i)=T(G)-I_i(G),\quad T=\sum_j I_j.
\]
Thus \(p_{t+1}=p_t-m_t\). While \(v_t>\eta\), put
\(H=\log(1+4U)\), \(U=d/(k\eta^{3/2})\). Since \(p_t\le d v_t\),
\[
m_t\ge\frac{k v_t^{5/2}}{8H}.
\]
The capped potential
\[
\Phi(z)=\frac{8H}{k}\int_0^z\max(\eta,s/d)^{-5/2}\,ds
\]
decreases by at least one on every such query and has total range at most \((40/3)U H\). Therefore \(N\) queries suffice for expected posterior variance at most \(\eta\).

For scalar outputs, use (1) directly and the identical total-influence potential without the logarithmic rank step: its total range is \(5d/(3k\eta^{3/2})\), with \(k=c_*B^{-3}d^{-6}\). Fixed-order tie-breaking on the countable active coordinate set gives a measurable policy. Orthogonal output projection and conditional expectation contraction add at most \(\tau_r\) to the risk.

### Explicit lower bound for the quadratic regime

With \(r\) independent groups of \(k\) independent fair signs, let
\(F=(k\sqrt r)^{-1}(\sum_{j=1}^kX_{1j},\ldots,\sum_{j=1}^kX_{rj})\).
Then \(\|F\|\le1\), \(\operatorname{Var}(F)=1/k\), and each coordinate's influence is \(1/(rk^2)\). Reaching risk \(1/(2k)\) requires at least \(rk/2\) distinct observations even adaptively; hence the rank/accuracy order \(r/\eta\) cannot be improved.

### Verification and novelty boundary

**Verified formally:** finite scalar theorem at precisely the stated coefficient, PR #317 (19 named kernel-compiled declarations, only standard Lean axioms).

**Written analytic proof, not end-to-end certified:** arbitrary measurable product transfer, random-sign Hilbert compression, posterior measurable selection, total-influence descent, covariance-tail lifting, and direct quadratic classification. Selected supporting Lean modules and finite exact tests exist, but **their composition is not kernel-certified**. No independent non-author mathematical referee or comprehensive worldwide priority search has approved the complete theorem.

**Not claimed:** the unrestricted cubic exponent-two influence inequality, general correlated inputs, algorithmic runtime bounds, or a new proof of the original Boolean-cube Aaronson–Ambainis conjecture. The cubic question remains open; see the separate [research branch](https://github.com/d3lefts/d3lefts/pull/347).

**Prior work credited:** David Turturean, [A proof of the Aaronson–Ambainis conjecture](https://arxiv.org/abs/2611.09773), 6 November 2026; Aaronson–Ambainis, *The Need for Structure in Quantum Speedups* (2014); classical Hoeffding–Efron–Stein theory; standard random-sign and Gaussian quadratic-form tools; [Blanc–Docter–Strassle–Tan](https://arxiv.org/abs/2611.11626), 8 November 2026; [Huffstutler–Miloschewsky–Podder](https://arxiv.org/abs/2611.12795), 9 November 2026.

**The claim:** quantitative adaptive observability of bounded low-interaction observables over arbitrary independent product laws, with a dimension-free spectral-rank budget. It is meaningful independently of whether the stronger cubic conjecture is ultimately solved.
