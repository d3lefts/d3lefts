# NIGHTFALL Q3 — two-replica Walsh/Bernstein transfer

**Research status (2026-11-17):** Author-side exact mathematical reduction and two finite exact-rational checkers. No Lean certificate, no independent non-author proof review, no prior-art novelty certification, and **no unrestricted cubic exponent-two proof**. Do not publish or promote the latter claim.

## Objective and strongest checked external context

Target for arbitrary independent probability factors: every bounded `L²` Efron–Stein degree-≤3 `f` obeys `Var(f)^2 ≤ C_3 B² max_i Inf_i(f)`, with universal `C_3`. Turturean (arXiv:2611.09773) proves variance exponent 5/2 on the fair Boolean cube. Huffstutler–Miloschewsky–Podder (arXiv:2611.12795), Blanc–Docter–Strassle–Tan (arXiv:2611.11626), and Girish–Mittal–Nehoran–Raz (arXiv:2609.35327) are relevant; the latter's stated equivalences are qualitative and **are not** a proof of this quantitative bound. Existing NIGHTFALL merged PR #776 certifies the a.e. infinite-product Q2 C105.416 statement as written; draft #787 is restricted cubic top-cover. User-directed threshold: any promotion requires the unrestricted inequality plus full source exactness and external priority review.

## Exact finite-product two-replica spectral theorem (author proof)

Let \(\mu=\bigotimes_{i=1}^n\mu_i\) with completely arbitrary probability spaces, and let \(f\in L^\infty(\mu)\), \(|f|\le B\), with orthogonal Hoeffding decomposition \(f=\sum_{S\subseteq[n]} f_S\) and \(E_s=\sum_{|S|=s}\|f_S\|_2^2\). Take two i.i.d. samples \(X,X'\sim\mu\). With fair independent signs \(\varepsilon_i\in\{-1,1\}\), define \(Y_i=X_i\) when \(\varepsilon_i=1\) and \(X'_i\) otherwise, and \(F_{X,X'}(\varepsilon)=f(Y)\). Let \(\widehat F(T)\) be the ordinary uniform Boolean Walsh coefficient in the \(\varepsilon\) variables. All identities below integrate over \((X,X')\).

For every \(k\ge1\),

\[
\boxed{\mathbb E_{X,X'}\sum_{|T|=k}\widehat F(T)^2
=\sum_{s\ge k}\binom{s}{k}2^{-s}E_s.}
\]

The level-zero identity is \(\mathbb E\widehat F(\varnothing)^2=(\mathbb E_\mu f)^2+\sum_{s\ge1}2^{-s}E_s\). In particular \(F\) has fair-cube degree at most the original ANOVA degree, for almost all pairs; the expected conditional fair variance is

\[
\mathbb E\operatorname{Var}_{\varepsilon}(F)=\sum_{s\ge1}(1-2^{-s})E_s,
\]

and its site influence is exactly

\[
\boxed{\mathbb E_{X,X'} I_i^{\varepsilon}(F)=\tfrac12 I_i^{\mu}(f).}
\]

**Proof:** In the original ANOVA tensor space, each centered one-coordinate factor \(u(X_i)\) becomes \(m_i+\varepsilon_i d_i\), where \(m_i=(u(X_i)+u(X'_i))/2\), \(d_i=(u(X_i)-u(X'_i))/2\). Both are centered, orthogonal, and have squared \(L²\) norm \(\|u\|_2^2/2\). Tensorize. Different original ANOVA subsets remain orthogonal, and each \(s\)-sector sends exactly \(2^{-s}\) of its energy to each of its \(2^s\) pair-replica Walsh subsets. Finite-rank tensor density extends from pure tensors to arbitrary \(L²\) sectors. The influence identity follows alternatively by resampling a selected source coordinate and using \(\mathbb E(f(X_i)-f(X'_i))^2=2I_i(f)\). No atom floor or bias bound is needed.

## Cubic-to-quadratic contraction

If \(f\) has degree ≤3, define \(Q_{X,X'}=\sum_{|T|\le2}\widehat F(T)\chi_T\) for each pair. Then

\[
\boxed{
\begin{aligned}
\mathbb E\operatorname{Var}_\varepsilon(Q)&=\frac12E_1+\frac34(E_2+E_3)\ge\frac12\operatorname{Var}_\mu(f),\\
\mathbb E I_i^\varepsilon(Q)&=\frac12 I_i^\mu(f)-\frac18\sum_{|S|=3,\ i\in S}\|f_S\|_2^2\le\frac12 I_i^\mu(f),\\
\|Q_{X,X'}\|_{L^\infty(\varepsilon)}&\le5B\quad\text{for a.e. pair}.
\end{aligned}}
\]

To verify amplitude: for fixed pair and sign setting, \(q(t)=(T_tF)(\varepsilon)\), with \(T_t\) ordinary fair-cube noise, is bounded by \(B\) on \([-1,1]\). It is a polynomial of degree≤3, and its \(t^3\) coefficient is \(\Pi_3F(\varepsilon)\). Exact interpolation gives

\[
[t^3]q=\tfrac23(q(1)-q(-1))-\tfrac43(q(1/2)-q(-1/2)),
\]

hence \(|\Pi_3F|\le4B\), and \(|Q|=|F-\Pi_3F|\le5B\).

If \(f\) is **pure cubic** (\(E_1=E_2=0\)) the equalities specialize to

\[
\boxed{\mathbb E\operatorname{Var}_\varepsilon(Q)=\tfrac34\operatorname{Var}_\mu(f),\qquad
\mathbb E I_i^\varepsilon(Q)=\tfrac38 I_i^\mu(f).}
\]

Moreover, pure-cubic original energy is distributed across fair-cube Walsh levels \(k=0,1,2,3\) in the exact proportions \(1:3:3:1\). This is a **binomial spectral transport**. It does not require that each fixed fair section be homogeneous cubic (usually it is not).

## Exact sufficient gate, and why ordinary Q2 cannot be averaged

The *restricted two-replica family* is the image of this lift/projection operator on original degree≤3 product functions. If one proves for this family, with a universal \(K\), the mean-coupled inequality

\[
\left(\mathbb E_{X,X'}\operatorname{Var}_\varepsilon(Q)\right)^2\le
K\,\big(\operatorname{ess\,sup}_{X,X'}\|Q_{X,X'}\|_\infty\big)^2
\max_i\mathbb E_{X,X'} I_i^\varepsilon(Q),
\]

then the full cubic target follows with \(C_3=50K\), and with \(C_{3,\mathrm{pure}}=50K/3\) for pure cubic. This is a **conditional reduction**, not a proved inequality. It must not be extended to arbitrary random quadratic families: if \(U\) is uniform on \([n]\) and \(Q_U(\varepsilon)=\varepsilon_U\), then every fiber has variance 1 but every coordinate's mean influence is \(1/n\), so any such universal inequality fails by factor \(n\). A proof must use the paired-source consistency/selector influences.

A second no-go applies even to the genuine two-replica lift: take independent Bernoulli\((p)\) original coordinates and degree-one \(f=\frac1n\sum_i(X_i-p)\). Let \(J_i=I_i^\varepsilon(F_{X,X'})\). Then

\[
\frac{\mathbb E\max_i J_i}{\max_i\mathbb E J_i}
=\frac{1-(1-2p(1-p))^n}{2p(1-p)}.
\]

Set \(n=m^2,p=1/m\); the ratio is asymptotic to \(m/2\to\infty\). Thus *interchanging expectation and coordinate maximum* is invalid even at original degree one. The linear example does not refute the cubic target itself; its source normalized influence ratio is far below the hard scale.

## Reproducibility and independent checks

- `check_cubic_replicalift_exact.py` uses exact rational enumeration of all \(2^4\) biased source words, their \(2^8\) ordered paired words, and \(2^4\) fair selections; constructs source ANOVA via genuine conditional means and fair Walsh coefficients separately, checks the full binomial transform, projected amplitude and influence identities, and the exact all-\(m\) max-exchange formula against sample values.
- `check_cubic_replicalift_categorical.py` is independent code using four heterogeneous binary/ternary alphabets, a pure cubic supported on two overlapping triples, and exact 24×24×16 enumeration; checks the proportions 1:3:3:1, the \(3/4\) and \(3/8\) identities, and the \(5B\) bound.
- Both were run in the current execution environment with `PASS`. This is numerical/exact finite **testing**, not independent review of the general proof.
- The proof uses only elementary Hilbert tensor orthogonality and explicit noise interpolation; a Lean representation/compilation is **not** yet available.

## Mechanism and limitation

Problem → arbitrary-product cubic Q3; representation → 2-sample fair-bit Walsh lift; mechanism → binomial energy transform; operator → delete fair level 3 with \(5B\) bound; construction → random fair quadratic family; certificate → two exact checker programs + displayed derivation; limitation → expectation of maximal influence cannot be exchanged with a maximum of expectations; transfer → higher-degree (\(d\)) exact binomial energy transform, with conditional fair degree reduction.

**Outcome:** substantial exact structural reduction and two explicit no-go results, but **NO unrestricted exponent-two cubic theorem, no merged Lean proof, and no novelty certification**. The next truly decisive test is to prove or falsify the mean-coupled quadratic inequality specifically on source-consistent two-replica projected families. Any counterexample to that specific inequality would, up to normalization, speak directly to the original cubic objective.
