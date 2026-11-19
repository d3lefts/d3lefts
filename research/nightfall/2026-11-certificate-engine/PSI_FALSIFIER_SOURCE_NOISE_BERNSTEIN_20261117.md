# Exact degree-two falsification of sharp pointwise sensitivity; arbitrary-product source-noise Bernstein bounds

**NIGHTFALL research checkpoint, 2026-11-17 Eastern.** Research direction Devin J. Wright, AI-assisted construction, author-side proof and exact independent arithmetic. **Status:** finite exact counterexample + author-side universal *operator* lemma; no unrestricted degree-three exponent-two theorem, no Lean for the operator, no independent referee, no novelty/priority signoff. Existing conjecture #348 must be **demoted** in its real-valued scope, not retroactively relabelled as a theorem.

## A. Four fair signs falsify the proposed real-valued PSI coefficient 1

Let a,b,c,d be four independent uniform signs and put
\[
 f(a,b,c,d)=\frac{-a+b-c-d}{2}+\frac{(a+b)(c-d)}4.
\]
Every Fourier monomial has degree one or two (there are exactly four singleton and four pair characters). Define source-resampling influence
\[
 I_i(f)=\tfrac14\mathbb E_{X}(f(X)-f(X^{\oplus i}))^2,
\quad M=\max_i I_i(f),\quad
 R=\max_x\sum_i|f(x)-f(x^{\oplus i})|.
\]
Orthogonality gives \(V=\operatorname{Var}(f)=4(1/2)^2+4(1/4)^2=5/4\).
For each coordinate there is one coefficient of magnitude \(1/2\) and two pair coefficients of magnitude \(1/4\); therefore **every** \(I_i=1/4+2/16=3/8\). Direct exhaustive evaluation of the 16 values shows \(\min f=-2,\max f=2\), and **R=4**. Thus
\[
 \boxed{\frac{V^2}{(R^2/4)M}=\frac{25}{24}>1.}
\]
This is a strict exact-rational **counterexample** to the real-valued general pointwise-sensitivity conjecture \(\mathrm{PSI}(1)\) recorded in merged PR #348 and in \`POINTWISE_SENSITIVITY_AUDIT_20261111.md\`. It does **not** contradict the narrower *Boolean-valued* exhaustive four-bit screen, which found no violations, nor its degree-one/product-additive theorem; it also does not contradict N-UE2(2,1). It proves that any corrected universal real-valued PSI coefficient \(c\) in \(V^2\le c (R^2/4) M\) must satisfy **c ≥ 25/24**. The previous real-valued degree-two Khintchine bound in #348 supplies c≤2 for d≤2, leaving the interval [25/24,2] (not asserted optimal).

**Independent checks:** one engine computes the direct 16-state source variance, all four *actual* sign-flip-resampling influences and the maximum sensitivity; a separate Walsh-coefficient engine computes eight coefficients and four influences without using the direct conditional formula. The dictator is an equality negative control. \`check_source_noise_psi_exact.py\` reproduces both.

## B. An all-degree arbitrary-product source operator (not the open influence theorem)

Let \(\mu=\bigotimes_{i=1}^n\mu_i\) be any finite product of probability spaces, including heterogeneous categorical alphabets and zero-probability atoms; let \(f\) be a *scalar real* essentially bounded function of canonical Efron–Stein degree at most \(d\ge1\). Set the **centered** essential range radius \(B=\inf_{c\in\mathbb R}\|f-c\|_{L^\infty(\mu)}\), and genuine source residual \(D_i f=f-\mathbb E_{\mu_i}f\). For \(0\le\rho\le1\) let \(T_\rho=\prod_i(\rho\,\mathrm{Id}+(1-\rho)\mathbb E_i)\), the original-law heat-bath refresh noise. Then for \(\mu\)-almost every \(x\):
\[
\boxed{\sum_{i=1}^n |D_iT_\rho f(x)|
    \ \le\ dB\sqrt{\frac{\rho}{1-\rho}}\quad(0<\rho<1),}
\tag{B1}
\]
and the unsmoothed endpoint obeys
\[
\boxed{\sum_{i=1}^n |D_i f(x)|\le4d^2 B.}\tag{B2}
\]
No \(n\), alphabet, minimum atom probability, or marginal-bias term enters. These are **pointwise coordinate-residual budgets**, not variance/influence lower bounds. Neither proves N-UE2(6), N-UE2(2), N-UE2(2,1), nor unrestricted cubic exponent two.

### Proof (original law, exact polynomial representation)

Fix a full-measure good \(x\). For \(t=(t_i)\in[0,1]^n\) define a positive conditional product interpolation
\[
P_x(t)=\left(\prod_i[t_i\,\mathrm{Id}+(1-t_i)\mathbb E_i]f\right)(x).
\]
For finite alphabet this is an ordinary convex combination of source values, hence its *whole-cube* range lies in \([c-B,c+B]\). In general standard finite product laws, Fubini provides one common full-measure set for finitely many mixed integrations; the formula is representative-independent a.e. Using canonical ANOVA decomposition,
\[
P_x(t)=\sum_{|S|\le d}\left(\prod_{i\in S}t_i\right)f_S(x);
\]
it is multiaffine of **total degree≤d**, irrespective of source alphabets.

**Smoothed inequality B1.** At \(t=(\rho,\dots,\rho)\), choose signs \(\sigma_i\in\{\pm1\}\) to align \(-\sigma_i \partial_iP_x(t)\ge0\). Put
\[
t_i(s)=\tfrac12[1+\cos(\theta+\sigma_i s)],\quad
\theta=\arccos(2\rho-1).
\]
For all \(s\), \(t_i(s)\in[0,1]\). Thus \(H(s)=P_x(t_1(s),\dots,t_n(s))\) is a trigonometric polynomial of *frequency degree at most d*, globally bounded in centered radius B. The **classical trigonometric Bernstein inequality** gives \(|H'(0)|\le dB\). By the chain rule:
\[
\sqrt{\rho(1-\rho)}\sum_i|\partial_iP_x(\rho)|
=|H'(0)|\le dB.
\]
Since \(D_iT_\rho f(x)=\rho\,\partial_iP_x(\rho)\), (B1) follows exactly. In particular \(\sum_i|D_iT_{1/2} f(x)|\le dB\).

**Endpoint inequality B2.** At \(t_i=1\) one has \(\partial_iP_x(\mathbf1)=D_i f(x)\). Partition indices into those with positive and negative residual at this fixed \(x\). For either subset \(L\), the univariate restriction \(q_L(s)=P_x((s)_{i\in L},(1)_{i\notin L})\), \(s\in[0,1]\), remains bounded in centered radius B and has degree≤d. The **classical Markov endpoint derivative inequality** on [0,1] yields \(|q_L'(1)|\le2d^2B\). Applying it separately to the positive and negative sets gives (B2).

### Role and limitation

(B1) and (B2) are source-exact operator transplants of classical Markov/Bernstein geometry. They extend beyond uniform signs and are useful in observability/certificate calculations, but the operator family itself may have established antecedents (Markov semigroups, polynomial heat-bath interpolation, Turturean/FHKL); **priority unresolved**.

**Critical failed shortcut:** Even a pointwise \(\ell_1\) budget \(K=\sup_x\sum_i|D_i f(x)|\) does *not* imply \(V^2\le K^2\max_i I_i\) with coefficient one. The four-sign witness above has \(K=R/2=2\) and ratio 25/24. More generally \(D_iT_\rho f\) can activate on rare, rotating source configurations, so \(\mathbb E\max_i\) cannot be silently replaced by \(\max_i\mathbb E\); #799 separately falsified that exchange.

**Unresolved mathematical gate:** a **source-consistent, variance-weighted** coupling estimate for true two-replica quadratic projections, sufficient to control the competition between rare active links and selector-coordinate influences. The right next mechanism must charge selector cost and exploit original-law correlation, not assume the now false sharp PSI or generic annealed Q2 inequalities.

## C. Reproducibility and certification

\`python3 -I research/nightfall/2026-11-certificate-engine/checks/check_source_noise_psi_exact.py\` checks:
- full 16-state rational PSI falsifier with Fourier/conditional independent mechanisms;
- dictator exact equality in the old PSI convention;
- twelve deterministic original-source independent heterogeneous categorical products, including null letters and biased marginals, genuine degree≤3 by a separately computed fourfold residual;
- for every supported state, the unsmoothed bound and three rational refresh levels \(\rho=1/4,1/2,3/4\), checking squared inequalities exactly.

**Status:** the finite counterexample is a certified exact algebraic disproof of *one* repository conjecture. The two all-source pointwise inequalities have complete author-side arguments importing classical trigonometric Bernstein and algebraic Markov; the finite checks are regressions, **not proofs** of those universal statements. Formal Lean, human review and novelty checks remain separate gates. Avoid changes to the flagship UE2 theorem registry until audited.
