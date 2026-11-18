# NIGHTFALL: Bernstein-sharp universal product influence conjecture

Version: 1.0 — 2026-11-17 (US Eastern). Classification: **new stronger conjecture, not a theorem**; accompanied by an **author-side proved sharpness proposition** and exact rational finite checks. No Lean kernel certificate or independent human review of the sharpness proposition, and no claim of priority over classical Chebyshev/Bernstein extremality. Research direction: Devin J. Wright / NIGHTFALL, AI-assisted derivation. Independent refutation is invited.

## Most ambitious plausible universal statement: N-UE2(2,1)

For every index set \(\iota\) (any universe), every independent product probability law \(\mu=\bigotimes_{i\in\iota}\mu_i\), and every essentially bounded **real-valued** \(f\in L^2(\mu)\) of Hoeffding/Efron–Stein degree at most an integer \(d\ge1\), let
\[
B_\mu(f)=\inf_{a\in\mathbb R}\|f-a\|_{L^\infty(\mu)}
=\tfrac12(\operatorname{ess\,sup}_\mu f-\operatorname{ess\,inf}_\mu f),
\quad V=\operatorname{Var}_\mu(f),
\quad M=\sup_{i\in\iota}\|f-\mathbb E_\mu[f\mid X_{\iota\setminus\{i\}}]\|_2^2.
\]
If the index set is empty set \(M=0\), and the function is constant. Define infinite-product degree using the \(L^2\)-closed span of canonical Hoeffding components on at most \(d\) coordinates. **Conjecture:**
\[
\boxed{\quad V^2\le d^2\,B_\mu(f)^2\,M.\quad}\tag{N-UE2(2,1)}
\]
No unproved assumption is treated as an axiom. The bound is meaningful without any mass floor, finite dimension, or alphabet restriction; null atoms are interpreted modulo the law. It implies N-UE2(2) and N-UE2(6) with \(C=1\), hence the original AA polynomial-conjecture bound \(I_{\rm flip}^{AA}(p)\ge16\operatorname{Var}(p)^2/d^2\) on uniform \([0,1]\)-valued functions (provided the conjecture is proved). The bound is much stronger than the *known* \(V^{5/2}/d^6\) theorem, and its unconditional truth is open even at unrestricted cubic degree.

## Sharpness proposition — the coefficient 1 and degree power 2 are simultaneously optimal for EVERY degree

**Author-side analytic proof, not independent review.** For each fixed \(d\ge1\) there are full-support finite i.i.d. Bernoulli products and degree-exactly-\(d\) real polynomials \(f_n\in[-1,1]\) with
\[
\lim_{n\to\infty}
\frac{\operatorname{Var}_{\mu_n}(f_n)^2}
{d^2\,B_{\mu_n}(f_n)^2\,\max_i I_i^{\mu_n}(f_n)}=1.
\]
In particular any universal inequality of the proposed form **must** have \(C\ge1\), separately at each fixed degree \(d\); any degree exponent \(k<2\) is impossible even with an arbitrary fixed coefficient.

**Construction.** Put \(\theta=\pi/(2d)\), \(z=\cos\theta\), \(p_d=(1+z)/2\in(0,1)\), \(X_i\overset{\rm iid}{\sim}\mathrm{Bernoulli}(p_d)\), \(K_n=\sum_{i=1}^n X_i\), and for all \(n\ge d\),
\[
f_n(X)=g_d(K_n/n),\qquad g_d(t)=T_d(2t-1)
\]
where \(T_d(\cos\alpha)=\cos(d\alpha)\) is the classical Chebyshev polynomial. Since \(g_d([0,1])\subset[-1,1]\), the finite-cube radius \(B_n\le1\); the mesh \(\{k/n\}\) becomes dense, \(T_d\) attains both \(\pm1\) on \([-1,1]\), hence \(B_n\to1\). Expanding the nonzero leading monomial of \(T_d\) shows that the multilinear coefficient on any set of \(d\) distinct Bernoulli variables is \(2^{d-1}(2/n)^dd!\ne0\). Thus its ANOVA degree under full support is **exactly** \(d\).

**Original-source resampling influence formula.** If \(L\sim\mathrm{Bin}(n-1,p_d)\), the conditional variance across coordinate \(i\) is
\[
M_n=p_d(1-p_d)\,\mathbb E\left[
\left(g_d((L+1)/n)-g_d(L/n)\right)^2
\right].
\]
Since \(K_n/n\to p_d\) in \(L^4\), a Taylor expansion (bounded second derivative for fixed \(d\)) gives
\[
n\,\operatorname{Var}(g_d(K_n/n))\longrightarrow
p_d(1-p_d)\,g_d'(p_d)^2.
\]
The bounded finite difference \(n(g_d((L+1)/n)-g_d(L/n))\to g_d'(p_d)\) in \(L^2\) gives
\[
n^2M_n\longrightarrow p_d(1-p_d)\,g_d'(p_d)^2.
\]
The Chebyshev derivative identity (the classical Bernstein extremizer) gives, **exactly**,
\[
p_d(1-p_d)g_d'(p_d)^2
=(1-z^2)T'_d(z)^2=d^2\sin^2(d\theta)=d^2.
\]
Therefore \(nV_n\to d^2\), \(n^2M_n\to d^2\), and since \(B_n\to1\), \(V_n^2/(B_n^2M_n)\to d^2\). This proves the asserted sharpness lower bound. The limiting argument is analytic, not an empirical extrapolation. The source uses a **classical** extremizing polynomial; literature priority for this exact influence interpretation has not been established.

**Uniform cube strengthening for odd d.** If \(d\) is odd, one may instead take \(p=1/2\), i.e. the *uniform* Boolean cube, and \(f_n=T_d((2K_n-n)/n)\). Then \(T_d'(0)=\pm d\) and the same limit equals \(d^2\). Thus even the uniform-cube fixed-odd-degree problem forces the degree-\(d\) sharp coefficient 1. Bias tuning is needed by this particular family for even degrees.

**Elementary exact rational sample.** For \(d=2\), choose \(p=17/20\) instead of the irrational extremizer. The analytic limit is
\[
\frac{p(1-p)\,g'_2(p)^2}{d^2}
=\frac{2499}{2500}=0.9996.
\]
This is exact rational arithmetic. Arbitrarily close rational choices yield the sharp supremum 1 without irrational probability data.

## A genuine obstruction to spectral-degree substitutes

Let \(W_k(f_n)\) be the true-law Hoeffding energy in level \(k\). Orthogonality implies \(\sum_k kW_k=\sum_i I_i=nM_n\), and \(\sum_kW_k=V_n\). The above calculation gives
\[
D_{\rm spectral}(f_n):=\frac{\sum_k kW_k}{\sum_k W_k}
=\frac{nM_n}{V_n}\longrightarrow 1,
\quad \text{while}\quad
\frac{V_n^2}{B_n^2 M_n}\longrightarrow d^2.
\]
Thus one CANNOT strengthen the universal conjecture by replacing algebraic degree \(d\) with average \(L^2\) Hoeffding degree \(D_{\rm spectral}\), even though the function becomes asymptotically linear in *energy*. The high-degree global range geometry remains essential. This is an exact structural warning for operator reduction and cubic proofs.

## Adversarial scopes and checks

- Do NOT generalize to dependent coordinate laws using the same conditional-variance influences: for \(X_1=X_2\) fair signs and \(f=X_1\), both conditional variances vanish but \(V=1\).
- Do NOT generalize to arbitrary Hilbert-valued functions: \(f(x_1,\dots,x_n)=n^{-1/2}(x_1,\dots,x_n)\) has degree 1, centered radius 1, variance 1 and each vector influence \(1/n\), contradicting coefficient 1 as \(n\to\infty\).
- Finite numerical *attacks* (not independent certification) on fair/biased binary products through 9 coordinates and categorical 3-/4-letter products through 6 coordinates found no violation of \(V^2\le d^2B^2M\); optimized coefficient values approached the sharp bound from below. Search continuation should include high-alphabet selectors, correlated routing restricted to independent original inputs, and large-degree compositions. No finite search proves the conjecture.
- Existing cubic source-consistent mean-coupled Q2 gate (#799/#803) remains open. Existing exact a.e. Q2 constant about 105.416 (#776) does **not** prove coefficient 1 for \(d=2\). Do NOT merge this conjecture as a proved theorem.
- Classical Bernstein/Chebyshev extremality is established background mathematics; the exact product-influence sharpness statement is an author-side derived proposition with no novelty clearance. Priority comparison should include Turturean 2026 §9.4–9.5, Filmus–Hatami–Keller–Lifshitz, completely bounded influence results, and product ANOVA/decoupling.

## Proof passport and decisive next experiment

Statement: **N-UE2(2,1), OPEN CONJECTURE**.
Proved-bound candidate: none beyond existing Q2 / restricted cubic and the author-side sharpness lower bound.
Certificate: exact finite Fraction checker at \`research/nightfall/flagship-influence/check_ue2_bernstein_saturation.py\` (finite Bernoulli binomial and independent direct-cube conditionals). It does **not** prove the \(n\to\infty\) limit or the universal inequality.
Independent audit: rederive Taylor/ANOVA degree without reusing this proof, test full source-coupled Q3, and find a counterexample to \(V^2/(d^2B^2 M)\le1\) or produce a rigorous inequality.
Stop rule: keep N-UE2(6) as conservative backup. If any valid ratio \(>1\) appears, **demote** N-UE2(2,1) and retain N-UE2(2) with unspecified universal \(C\); do not rationalize away adverse examples. Avoid coefficient polishing before attempting the missing universal mechanism.
