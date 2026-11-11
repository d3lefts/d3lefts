# The finite-to-infinite influence and adaptive spectral observation bridge

**NIGHTFALL technical proof supplement, v1.0 — 11 November 2026.**

**Scope:** A self-contained *analytic proof reconstruction*, conditional only on the **specified finite-product scalar theorem**. It is **not** a new Lean formalization, independent non-author refereeing, global novelty certification, or a replacement for the original research manuscript. Exact finite and numerical falsifiers accompany this supplement; they do not prove the infinite theorem.

**Research provenance:** Devin J. Wright / NIGHTFALL; mathematical source [PRINCIPAL_THEOREM.md](../../research/nightfall/2026-11-principal-observability/PRINCIPAL_THEOREM.md). The finite scalar input is the Lean declaration `Nightfall.ProductSpace.Influence.product_influence` at source commit `e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb`, Lean 4.33.0; successful [named-theorem CI receipt](https://github.com/d3lefts/d3lefts/actions/runs/42929857470). The inherited antipodal/level-set/certificate approach and original Boolean-cube result are credited to **David Turturean**, arXiv:2611.09773 (2026-11-06). The classical Hoeffding–Efron–Stein decomposition, Gaussian quadratic moment formula, and martingale conditional expectation results are not claimed as original here.

## 0. Theorem and exact assumptions

Let \((\Omega_i,\mathcal A_i,\mu_i)_{i\in I}\) be an arbitrary family of probability spaces and let \((\Omega,\mathcal A,\mu)=\bigotimes_i(\Omega_i,\mathcal A_i,\mu_i)\) carry the product sigma field (or its completion). Let \(H\) be a real Hilbert space and \(F:\Omega\to H\) strongly measurable, with \(\|F\|\le B\) almost surely, \(0<B<\infty\). Suppose \(F\) has **Hoeffding degree at most \(d\ge1\)**: modulo null sets it depends on countably many inputs, and in its countable product ANOVA decomposition all components indexed by sets of size greater than \(d\) vanish.

Let \(C_F\) be its covariance operator, \(\lambda_1\ge\lambda_2\ge\cdots\ge0\) its eigenvalues counting multiplicities, and \(\tau_r=\operatorname{tr}(C_F)-\sum_{j=1}^r\lambda_j\) for any integer \(r\ge1\) (zeros permitted).

Define
\[
c_*=\frac{\sqrt{3/12500}}{\pi^6},\quad
U=\frac{d^7 B^3 r^{3/2}}{c_*\eta^{3/2}},
\quad N=\left\lceil \frac{40}{3}U\log(1+4U)\right\rceil,\qquad \eta>0.
\]

**Analytic theorem (finite-foundation conditional):** there is a measurable deterministic policy querying at most \(N\) distinct *whole input coordinates* such that, for its observation sigma field \(\mathcal T\), the conditional-mean predictor \(\widehat F=\mathbb E[F\mid\mathcal T]\) satisfies
\[
\mathbb E\|F-\widehat F\|^2\le\tau_r+\eta.
\]
The policy and the prior law/function are assumed known; there is no running-time bound. There is no dependence on the number or sizes of input alphabets or on any positive lower atom mass.

For scalar \(F=f\in[-B,B]\), the logarithm and spectral projection are unnecessary:
\[
N_{\rm scalar}\le\left\lceil \frac{5d^7B^3}{3c_*\eta^{3/2}}\right\rceil.
\]
Both conclusions depend on the exact finite scalar Lean theorem with its **weaker** \(5/2\) exponent and coefficient \(c_*\). Neither uses the unresolved quadratic exponent-two hypothesis.

## 1. Finite scalar theorem and its transfer

**Only imported mathematical influence premise.** If \(h\) is real and of indicator-monomial product degree \(\le d\) on finitely many coordinates with a *common finite alphabet type*, independent normalized nonnegative coordinate masses, and \(|h|\le A\) pointwise, then, writing \(v=\operatorname{Var}(h)>0\) and
\(I_i(h)=\mathbb E[(h-\mathbb E_i h)^2]\),
\[
\sup_i I_i(h)\ge c_*d^{-6}A^{-3}v^{5/2}. \tag{1.1}
\]
This follows by rescaling the exact Lean theorem from unit range. The proof below **does not** claim that Lean checked anything beyond that finite declaration.

**Lemma 1 (finite alphabets can differ).** For finitely many finite alphabets \(A_i\), take a common finite alphabet \(A\) containing disjoint labeled copies of all \(A_i\). Embed each marginal into its corresponding copy, assigning probability zero outside it. Choose a coordinatewise retraction \(\rho_i:A\to A_i\) fixing the legal symbols; send every illegal symbol to one chosen legal symbol. If \(h\) has degree \(\le d\), then \(g(y)=h((\rho_i(y_i))_i)\) has indicator-product degree \(\le d\), the same sup bound, variance and resampling influences under the embedded product law. Apply (1.1) to \(g\). No minimum-mass factor appears.

**Lemma 2 (arbitrary measured-product scalar lift).** For any real \(|h|\le A\) almost surely, with countable-support Hoeffding degree \(\le d\) under an arbitrary independent product law,
\[
\sup_i I_i(h)\ge c_*d^{-6}A^{-3}\operatorname{Var}(h)^{5/2}. \tag{1.2}
\]

**Proof.** Every measurable subset of a product sigma field depends on at most countably many coordinates: the family of countably supported events is a sigma field containing the finite-cylinder generators. A strongly measurable real \(h\) is therefore represented, modulo null sets (also after completion), on a countable coordinate set \(J\). The relevant coordinate sigma fields can each be reduced to countably many generating events: apply the preceding observation to a countable collection of inverse images of rational open intervals under \(h\), and list the finitely many coordinate events appearing in their cylinder constructions. This does not assume the original \(\mathcal A_i\) are countably generated.

Choose increasing finite product partition sigma fields \(\mathcal G_n\), each involving finitely many coordinates and finitely many atoms, with \(h\) measurable under \(\bigvee_n\mathcal G_n\). Put \(h_n=\mathbb E[h\mid\mathcal G_n]\). Standard \(L^2\) martingale approximation gives \(h_n\to h\) in \(L^2\), so \(\operatorname{Var}(h_n)\to\operatorname{Var}(h)\). Every positive-probability partition atom has conditional mean in \([-A,A]\). **Discard zero-probability coordinate atoms** when forming the finite categorical law, so that arbitrary values on null cells cannot introduce spurious pointwise high-degree terms.

The orthogonal projection \(\Pi_n:h\mapsto h_n\) commutes with every coordinate averaging operator \(\mathbb E_i\): both are tensor products of coordinatewise conditional expectations under independence (for coordinates omitted by \(\mathcal G_n\), the corresponding tensor factor is full averaging). Consequently \((1-\mathbb E_i)\Pi_n=\Pi_n(1-\mathbb E_i)\), and
\(I_i(h_n)=\|\Pi_n(1-\mathbb E_i)h\|_2^2\le I_i(h)\).
For every finite set \(S\) of more than \(d\) indices, the product of centered coordinate operators \(\prod_{i\in S}(1-\mathbb E_i)\) annihilates \(h\), and hence \(h_n\). Therefore \(h_n\) has Hoeffding degree \(\le d\), which on finite positive categorical atoms expands into pointwise indicator monomials of degree \(\le d\).

Apply Lemma 1 to each \(h_n\), take the supremum of the original influences and let \(n\to\infty\). If \(v=\operatorname{Var}(h)=0\) the inequality is trivial; otherwise \(v_n>0\) eventually. This proves (1.2). \(\square\)

**Audit-critical point:** this proof uses a finite-alphabet theorem *without* silently applying a pointwise degree hypothesis on arbitrary null partition cells. The positive-atom restriction resolves that issue.

## 2. Product ANOVA energy and actual posterior drift

Write the vector-valued orthogonal Hoeffding expansion \(G=\sum_{S:|S|\le d}G_S\) for any bounded \(H\)-valued output (all relevant \(S\) are contained in countable \(J\)). For nonempty \(S\), \(\mathbb E G_S=0\). Set
\[
v(G)=\operatorname{Var}(G),\quad
I_i(G)=\mathbb E\|G-\mathbb E_iG\|^2,\quad
T(G)=\sum_i I_i(G).
\]
Orthogonality and monotone convergence give the exact identities
\[
v(G)=\sum_{S\ne\varnothing}\|G_S\|_2^2,\quad
I_i(G)=\sum_{S\ni i}\|G_S\|_2^2,\quad
v(G)\le T(G)=\sum_{S\ne\varnothing}|S|\|G_S\|_2^2\le d\,v(G). \tag{2.1}
\]

**Lemma 3 (exact actual-coordinate drift).** If \(j\) is queried under a product law, and \(G_{x_j}\) denotes its measurable section after observing \(X_j=x_j\), then
\[
\int T(G_{x_j})\,\mu_j(dx_j)=T(G)-I_j(G). \tag{2.2}
\]

**Proof.** For any \(i\ne j\), integrating the conditional section's \(i\)-resampling influence over \(x_j\) gives \(I_i(G)\) exactly by Fubini, since coordinate averages in distinct variables commute. The queried coordinate has zero influence after it is fixed. Sum nonnegative terms by Tonelli. This does **not** require an abstract stochastic-drift premise, a fourth-moment estimate, or the bound (1.2). \(\square\)

Moreover, for almost all \(x_j\), \(G_{x_j}\) remains bounded by \(B\) and of degree \(\le d\) on the residual product: centered mixed coordinate differences of order \(>d\) remain zero on the sections by Fubini. Because \(J\) is countable, this assertion holds simultaneously outside a null set for every finite sequence of coordinates that a finite adaptive policy might select.

**Lemma 4 (measurable adaptive policy).** Under any finite transcript whose queried indices were chosen from preceding observed values, unqueried coordinates remain independent with their original marginal laws. For the countable active set \(J\), posterior \(i\)-influences are measurable functions of the transcript, finite in sum, and are positive in total whenever posterior variance is positive. A nonnegative summable countable family with positive supremum attains that supremum: otherwise infinitely many distinct terms exceed half the supremum and the sum diverges. Thus the first (fixed enumeration) maximizer is a measurable choice. Query it; after finitely many steps the construction stays valid by induction. No regular conditional probability on an arbitrary uncountable alphabet is needed: posterior objects are defined by integrals of measurable sections on each countable index-branch. \(\square\)

## 3. The finite-rank Gaussian / Rademacher bridge

Fix a finite-dimensional range of \(G\), of dimension at most \(r\). At each posterior separately, diagonalize its covariance in an orthonormal eigenbasis, padding with zero directions if needed. For all sign vectors \(\varepsilon\in\{-1,1\}^r\), the scalar \(h_\varepsilon=\langle\varepsilon,G\rangle\) has **exactly** the same variance \(v=\operatorname{Var}(G)\), and obeys \(|h_\varepsilon|\le\sqrt r B\). Let
\[
A_i=\mathbb E[(G-\mathbb E_iG)(G-\mathbb E_iG)^\top]\succeq0,\;
p=\sum_i\operatorname{tr}(A_i),\;
m=\sup_i\operatorname{tr}(A_i).
\]
By Lemma 2, for **every sign vector**,
\[
\sup_i\varepsilon^\top A_i\varepsilon\ge L:=kv^{5/2},
\qquad k=\frac{c_*}{B^3d^6r^{3/2}}. \tag{3.1}
\]
This does not assume \(\sup_i\varepsilon^\top A_i\varepsilon\) and expectation over signs commute. We control the maximum *after* scalarizing.

**Lemma 5 (uniform PSD sign moment).** For every real \(r\times r\) PSD matrix \(A\) with \(s=\operatorname{tr} A>0\),
\[
\mathbb E_\varepsilon\exp\left(\frac{\varepsilon^\top A\varepsilon}{4s}\right)\le\sqrt2. \tag{3.2}
\]
**Proof.** Let \(Z\) be centered Gaussian with covariance \(A\). Gaussian linearization and independence of the signs give
\[
\mathbb E_\varepsilon e^{\varepsilon^\top A\varepsilon/(4s)}
=\mathbb E_Z\prod_{j=1}^r \cosh(Z_j/\sqrt{2s})
\le\mathbb E_Z e^{\|Z\|^2/(4s)}
=\det(I-A/(2s))^{-1/2}.
\]
For the nonnegative eigenvalues \(\lambda_j\) summing to \(s\), \(\prod_j(1-\lambda_j/(2s))\ge1-\sum_j\lambda_j/(2s)=1/2\). This proves the claimed constant even for singular \(A\). \(\square\)

**Lemma 6 (logarithmic trace influence).** The preceding assumptions imply
\[
kv^{5/2}\le4m\log\left(1+(\sqrt2-1)\frac p m\right). \tag{3.3}
\]
**Proof.** If \(v>0\), (3.1) forces \(m>0\). For each nonzero \(A_i\), put \(s_i=\operatorname{tr}A_i\le m\). Convexity of \(t\mapsto e^{tz}\) on \([0,1]\) and (3.2) give
\[
\mathbb E_\varepsilon e^{\varepsilon^\top A_i\varepsilon/(4m)}
\le1+(\sqrt2-1)\frac{s_i}{m}.
\]
The quadratic forms are nonnegative; hence for each sign vector
\[
e^{\sup_i\varepsilon^\top A_i\varepsilon/(4m)}-1
\le\sum_i(e^{\varepsilon^\top A_i\varepsilon/(4m)}-1).
\]
For countably many coordinates use monotone convergence, with \(\sum_i s_i=p<\infty\). Taking expectations and applying Jensen to the left, using (3.1), yields
\(
e^{L/(4m)}-1\le(\sqrt2-1)p/m.
\)
This is (3.3). \(\square\)

**Lemma 7 (explicit inversion without hidden assumptions).** With \(L=kv^{5/2}>0\), \(m,p>0\),
\[
m\ge\frac{L}{8\log(1+4p/L)}. \tag{3.4}
\]
Indeed let \(t=L/(4m)\), \(y=4p/L\), \(a=\sqrt2-1<1/2\). From (3.3), \(e^t-1\le ayt\). The function \((e^t-1)/t\) is strictly increasing for \(t>0\). At \(t_0=2\log(1+y)\), \(e^{t_0}-1=y(2+y)>2ay\log(1+y)=ayt_0\), since \(\log(1+y)\le y\) and \(2a<1\). Hence \(t<t_0\), proving (3.4). \(\square\)

**Quantifier check:** the per-posterior diagonal basis need not be a measurable function of the transcript; it is used only to prove the *basis-independent* trace influence inequality (3.3). The actual adaptive policy chooses a coordinate based on \(\operatorname{tr}A_i\), which is measurable by Lemma 4. Thus no unproved measurable spectral-basis selector is needed.

## 4. From local influence to expected posterior progress

Let \(\mathcal T_t\) be the observed history after \(t\) distinct coordinate queries, and let \(G_t\) denote the posterior *section* of \(G\), viewed as a residual product function. Define deterministic quantities
\[
V_t=\mathbb E\operatorname{Var}(G_t),\qquad
P_t=\mathbb E T(G_t),\qquad
M_t=\mathbb E\max_{i\ {\rm unqueried}} I_i(G_t).
\]
Conditional-variance monotonicity gives \(V_{t+1}\le V_t\). By (2.1), \(V_t\le P_t\le dV_t\). For the maximum-influence policy in Lemma 4, (2.2) gives
\[
P_{t+1}=P_t-M_t. \tag{4.1}
\]
At each posterior with variance \(v\), (3.3) applies with the same \(B,d,r,k\). The map \((m,p)\mapsto m\log(1+(\sqrt2-1)p/m)\) is jointly concave: it is the perspective of the concave function \(\log(1+(\sqrt2-1)x)\), continuously extended by zero at \(m=0\). Jensen and convexity of \(v\mapsto v^{5/2}\) therefore give
\[
kV_t^{5/2}\le4M_t\log\left(1+(\sqrt2-1)\frac{P_t}{M_t}\right). \tag{4.2}
\]
This is where expectation and the local *maximum* are placed in the correct order. Applying Lemma 7 to (4.2) yields
\[
M_t\ge
\frac{kV_t^{5/2}}
{8\log(1+4P_t/(kV_t^{5/2}))}. \tag{4.3}
\]
If \(V_t>\eta\), then \(P_t\le dV_t\) implies
\[
\frac{4P_t}{kV_t^{5/2}}\le\frac{4d}{k\eta^{3/2}}=4U,\quad
M_t\ge\frac{kV_t^{5/2}}{8H},\quad
H=\log(1+4U). \tag{4.4}
\]

## 5. A capped concave potential closes the query budget

Define, for \(z\ge0\),
\[
\Phi(z)=\frac{8H}{k}\int_0^z\left[\max\left(\eta,\frac{s}{d}\right)\right]^{-5/2}ds.
\]
It is increasing, concave, finite, and continuously differentiable. If \(V_t>\eta\), then \(V_t\ge P_t/d\) together with (4.1), (4.4) gives
\[
\Phi(P_t)-\Phi(P_{t+1})
\ge \Phi'(P_t)(P_t-P_{t+1})
=\frac{8H}{k}\frac{M_t}{\max(\eta,P_t/d)^{5/2}}\ge1. \tag{5.1}
\]
The total possible potential is independent of the number of input coordinates:
\[
\Phi(\infty)
=\frac{8H}{k}\left(
\int_0^{d\eta}\eta^{-5/2}ds+
\int_{d\eta}^\infty(s/d)^{-5/2}ds\right)
=\frac{40}{3}\frac{dH}{k\eta^{3/2}}
=\frac{40}{3}U\log(1+4U). \tag{5.2}
\]
If \(V_N>\eta\) at \(N=\lceil\Phi(\infty)\rceil\), then variance monotonicity makes (5.1) applicable at all previous \(t<N\), yielding \(N\le\Phi(P_0)-\Phi(P_N)<\Phi(\infty)\le N\), a contradiction (the strict inequality uses \(P_N\ge V_N>0\) and \(\Phi(P_0)<\Phi(\infty)\)). Hence \(V_N\le\eta\). If posterior variance becomes zero earlier, stop; additional observations are unnecessary.

**Scalar improvement.** From Lemma 2 at every scalar posterior, \(M_t\ge k_0 V_t^{5/2}\) with \(k_0=c_*d^{-6}B^{-3}\), without the PSD sign lemma. Replace \(\Phi\) above by \(\Phi_0(z)=k_0^{-1}\int_0^z\max(\eta,s/d)^{-5/2}ds\). Its total range is \((5/3)d/(k_0\eta^{3/2})\), proving the stated log-free scalar budget.

## 6. Fixed output projection and risk

Let \(P_r\) be the fixed orthogonal projection onto \(r\) leading eigenvectors of the **unconditional** covariance \(C_F\) (take the available rank if it is smaller). Put \(G=P_rF\), \(R=(I-P_r)F\). Since \(\|G\|\le B\) and its range has dimension at most \(r\), Lemmas 1–5 apply to \(G\). The policy uses \(G\)'s posterior trace influences and ensures
\(\mathbb E\|G-\mathbb E[G\mid\mathcal T_N]\|^2\le\eta\).

Orthogonal ranges imply *exactly*
\[
\begin{aligned}
\mathbb E\|F-\mathbb E[F\mid\mathcal T_N]\|^2
&=\mathbb E\|G-\mathbb E[G\mid\mathcal T_N]\|^2\\
&\quad+\mathbb E\|R-\mathbb E[R\mid\mathcal T_N]\|^2\\
&\le\eta+\operatorname{Var}(R)=\eta+\tau_r.
\end{aligned}
\]
This completes the **analytic proof reconstruction** from the scoped finite scalar theorem. \(\square\)

## 7. Reusable exponent-transfer principle

The argument is not tied to the specific exponent \(5/2\). Suppose an externally established **finite categorical law-free scalar theorem**, with degree cap \(d\), provides for some \(q>1\) and \(a_d>0\)
\[
\sup_i I_i(h)\ge a_d A^{2-2q}\operatorname{Var}(h)^q
\]
whenever \(|h|\le A\), with the same indicator-product hypotheses as Lemma 1. Lemmas 1 and 2 lift it to arbitrary independent product laws, without changes to the coefficient. With \(k_0=a_d B^{2-2q}\), the scalar greedy posterior policy achieves risk \(\le\eta\) within
\[
N_{\rm scalar}\le\left\lceil \frac{q}{q-1}\frac{d}{k_0\eta^{q-1}}\right\rceil.
\]
For Hilbert output projected to \(r\) dimensions, take \(k=a_d B^{2-2q}r^{1-q}\) by the same sign-variance argument. Lemmas 5–7 remain valid for every \(q>1\), and the expected influence calculation uses convexity of \(v^q\). Therefore the Hilbert spectral-tail target follows in at most
\[
N_{\rm Hilbert}\le \left\lceil
\frac{8q}{q-1}\frac{d}{k\eta^{q-1}}
\log\left(1+\frac{4d}{k\eta^{q-1}}\right)
\right\rceil .
\]
This is an **operator that transfers any such independently proved finite scalar influence power law** to arbitrary-product adaptive observability. Taking \(q=5/2\) and \(a_d=c_*d^{-6}\) recovers the displayed NIGHTFALL constants exactly.

**Scope:** this is a logical transfer theorem, not an improvement of Turturean's base exponent or a certificate that such a finite scalar premise exists for \(q=2\). Novelty of the abstract operator itself is unreviewed.

## 8. Independent proof attack and evidence limits

**A priori attack targets:** (A) null-atom partition cells spuriously introducing degree; (B) false interchange of expectation and coordinate maximum; (C) conditional covariance eigenbasis measurability; (D) assuming a stochastic drift inequality instead of deriving it; (E) missing finite-horizon stopping strictness. The proof addresses (A) by positive-atom restriction, (B) by a sign exponential-moment bound, (C) by basing the actual policy on trace rather than eigenvectors, (D) via exact Fubini identity (2.2), and (E) via the bounded concave potential (5.2). These are internal proof repairs, **not independent non-author referee approval**.

**Reproducible checkers:** [exact rational posterior/Hilbert falsifier](checks/check_posterior_hilbert_exact.py) and [integer-Gram PSD/log numerical stress](checks/check_psd_log_stress.py). The former rederives finite drift and signed influence independently of NIGHTFALL's existing checker code; the latter uses floating point for analytic stress and cannot certify an exponential inequality. Both use Python's standard library. Run each directly from a checkout. Finite success cannot prove the infinite-product lemma or novelty.

**Open gates:** independent mathematical reconstruction of Lemma 2 on general measure spaces and the convergence/null-set handling; an independent specialist review of Lemmas 5–7 and the potential; pinned end-to-end Lean if desired; dated source-to-source originality comparison against post-November-2026 and classical product influence / adaptive query literature; author-controlled publication decision.

**Certification status:** one pre-existing kernel-checked finite product theorem + this self-contained internally audited *analytic composition*. The stronger variance-squared quadratic theorem, categorical fixed-query rate and unrestricted cubic theorem are **not** derived, proved, or promoted here.
