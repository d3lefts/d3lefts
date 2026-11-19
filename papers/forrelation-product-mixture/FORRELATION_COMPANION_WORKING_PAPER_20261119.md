# Product-Mixture Complexity of Gaussian-Sign Forrelation
## Exact and Total-Variation-Robust Information Certificates

**NIGHTFALL companion working paper, v1.0 — 19 November 2026.**  
**Public manuscript, not a peer-reviewed publication or arXiv submission.** Contributor identification and author order require human verification. The Gaussian-sign construction is Aaronson–Ambainis's; the sign identity is classical. The original exponential-mixture idea was noted in the NIGHTFALL review discussion of [PR #858](https://github.com/d3lefts/d3lefts/pull/858), with the quantitative binary-entropy, robust and maximum-atom variants developed in [PR #868](https://github.com/d3lefts/d3lefts/pull/868) and subsequent adversarial checks. The analytic Gaussian specialization is **not** Lean-certified; only separate finite information/conditional terminals in [PR #869](https://github.com/d3lefts/d3lefts/pull/869) and [PR #871](https://github.com/d3lefts/d3lefts/pull/871) have strict pinned Lean receipts. Independent mathematical and priority review remains open.

### Abstract

Let \(U\) be a real \(N\times N\) orthogonal matrix, \(Z\sim N(0,I_N)\), \(F=\operatorname{sgn}(Z)\), and \(G=\operatorname{sgn}(UZ)\). Denote the **unconditioned** joint law of \((F,G)\) by \(P_U\). Write
\[
\phi(t)=\tfrac12[(1+t)\ln(1+t)+(1-t)\ln(1-t)],\qquad 0\ln0=0.
\]
Any **exact mixture of \(M\) two-block product distributions** representing \(P_U\) satisfies
\[
\ln M\ \ge\ N\phi(2/\pi)=0.219200546826\ldots N.
\]
If every component is independent across **all \(2N\) individual sign coordinates**, a stronger *exact* bound holds:
\[
\ln M\ge N\alpha_U\ln2\ge (2\ln2/\pi)N
       =0.441271200305\ldots N,
\quad
\alpha_U=\mathbb E_{P_U}[F^\top U^\top G/N].
\]
For any \(M\)-block-product mixture \(Q\) with \(\operatorname{TV}(Q,P_U)\le\eta\le1/2\),
\[
\ln M\ge N[\phi(2/\pi)-2\eta\ln2]-2h_2(\eta).
\]
At \(\eta=.01\) this is \(0.205337603215N-0.112003068710\). We reconcile the earlier valid but weaker quadratic coefficient \(2/\pi^2=0.202642367285\), derive the Gaussian sign identity geometrically, and distinguish universal analytical proofs from Lean formalization.

### 1. Model

Throughout \(N\ge1\), \(U^\top U=I_N\), and \(Z\) has independent standard-normal coordinates. The law \(P_U\) of \((F,G)=(\operatorname{sgn}Z,\operatorname{sgn}(UZ))\) has **independent uniform Rademacher coordinates within each block**: both \(Z\) and \(UZ\) have covariance \(I\) and are jointly Gaussian. Their *joint* distribution across blocks is correlated. Set
\[
S_U(f,g)=f^\top U^\top g/N,\qquad |S_U(f,g)|\le1.
\]
A *block-product mixture* is \(Q(f,g)=\sum_{\theta=1}^M w_\theta A_\theta(f)B_\theta(g)\), where \(w_\theta\ge0,\ \sum_\theta w_\theta=1\). The \(A_\theta,B_\theta\) may have internal dependencies. A *coordinate-product mixture* additionally requires that each \(A_\theta\) and \(B_\theta\) factor over their respective \(N\) individual symbols. The stronger exact theorem is for this narrower class; the binary entropy and approximate theorems apply to the broader class.

### 2. Gaussian sign identity (standard result, proved here on paper)

**Lemma 1 (Grothendieck sign identity).** If centered, unit-variance jointly Gaussian \(X,Y\) have correlation \(\rho\), then
\[
\mathbb E[\operatorname{sgn}X\,\operatorname{sgn}Y]
 = (2/\pi)\arcsin\rho.
\]
*Proof.* Represent \(X=u\cdot V,\ Y=v\cdot V\), where \(u,v\) are planar unit vectors separated by angle \(\vartheta=\arccos\rho\) and \(V\) is a rotationally invariant two-dimensional standard Gaussian. The direction of \(V\) is uniform. The signs disagree on wedges of total angle \(2\vartheta\), hence with probability \(\vartheta/\pi\). Their product has mean \(1-2\vartheta/\pi=(2/\pi)\arcsin\rho\). The degenerate endpoints follow by continuity. This is classical; see [Briët, Lemma 2.1](https://www.thenetworkcenter.nl/uploaded_files/inlineitem/JB_grothendieck_proof.pdf). The mathematical step is established analytically but **has not yet been formalized in Mathlib for this project**.

Let \(T_i=(U^\top G)_i\), \(r_i=\mathbb E[F_iT_i]\). Since \(G\) has independent fair signs and \(U\) is orthogonal, \(\mathbb E T_i^2=1\). The identity gives
\[
r_i=\frac2\pi\sum_j U_{ji}\arcsin(U_{ji})\ge\frac2\pi\sum_jU_{ji}^2=\frac2\pi,
\quad
\alpha_U=\frac1N\sum_i r_i\ge\frac2\pi.
\]
The inequality uses \(t\arcsin t\ge t^2\) for \(|t|\le1\). For a normalized Walsh–Hadamard matrix, all \(r_i\) equal
\[
a_N=\frac{2\sqrt N}{\pi}\arcsin(1/\sqrt N),
\]
so \(\alpha_U=a_N\). In particular the results apply to Forrelation's Walsh–Hadamard instance with \(N=2^k\), and to *any* real orthogonal \(U\).

### 3. Sharper exact block-product information bound

**Theorem 2.** Every exact \(M\)-block-product representation of \(P_U\) obeys
\[
\boxed{\ln M\ge\sum_{i=1}^N\phi(r_i)\ge N\phi(2/\pi).}
\]
For flat Walsh–Hadamard \(U\), the first lower bound is \(N\phi(a_N)\).

*Proof.* Let \(m_i(g)=\mathbb E[F_i\mid G=g]\). Since \(F_i\) is a fair sign,
\[
I(F_i;G)=\mathbb E_G[\phi(m_i(G))].
\]
Cauchy–Schwarz, \(\mathbb E T_i^2=1\), and \(\mathbb E[m_i(G)T_i]=r_i\) imply \(\mathbb E m_i(G)^2\ge r_i^2\). The function \(\psi(s)=\phi(\sqrt s)\) is increasing and convex on \([0,1]\), because
\[
\psi(s)=\sum_{k\ge1}\frac{s^k}{2k(2k-1)}
\]
with nonnegative coefficients, and the endpoint is obtained by continuity. Thus Jensen implies
\(I(F_i;G)\ge\psi(\mathbb E m_i^2)\ge\phi(r_i)\).
The \(F_i\) are independent; conditional-entropy subadditivity yields
\(I(F;G)\ge\sum_i I(F_i;G)\ge\sum_i\phi(r_i)\).
In an \(M\)-block-product mixture the blocks are conditionally independent given the component index \(\Theta\). Therefore \(I(F;G)\le H(\Theta)\le\ln M\). QED.

### 4. Stronger exact *coordinate*-product bound

**Theorem 3 (maximum-atom certificate).** Every exact \(M\)-component **fully coordinate-product** representation of \(P_U\) obeys
\[
\boxed{\ln M\ge N\alpha_U\ln2\ge (2\ln2/\pi)N.}
\]
The general \(\alpha_U\)-dependent inequality is sharp at \(U=I_N\).

*Proof.* Discard zero-weight components. Let the \(\theta\)th product component have weight \(w_\theta>0\) and sign-coordinate means \(a_{\theta,i}=\mathbb E[F_i\mid\Theta=\theta]\) and \(b_{\theta,j}=\mathbb E[G_j\mid\Theta=\theta]\). Let \(f^*_\theta\) choose the more likely sign in each coordinate of \(F\). Conditional independence across F-coordinates gives
\[
P_\theta(F=f^*_\theta)=2^{-N}\prod_i(1+|a_{\theta,i}|).
\]
Since the *true* marginal \(P_U(F=\cdot)\) is uniform, and all mixture terms are nonnegative,
\[
2^{-N}\ge w_\theta P_\theta(F=f^*_\theta)
\quad\Longrightarrow\quad
\sum_i\ln(1+|a_{\theta,i}|)\le-\ln w_\theta.
\]
By the concavity of \(\ln(1+t)\) on \([0,1]\), \(\ln(1+t)\ge t\ln2\ge t^2\ln2\); therefore
\[
\|a_\theta\|_2^2\le\frac{-\ln w_\theta}{\ln2}.
\]
Apply the same argument to the uniform G-marginal to obtain the identical bound for \(\|b_\theta\|_2^2\). Orthogonality then yields
\[
\mathbb E[S_U(F,G)\mid\Theta=\theta]
=\frac{a_\theta^\top U^\top b_\theta}{N}
\le\frac{\|a_\theta\|_2\|b_\theta\|_2}{N}
\le\frac{-\ln w_\theta}{N\ln2}.
\]
Average over \(\theta\):
\(N\alpha_U\ln2\le H(w)\le\ln M\).
When \(U=I_N\), \(G=F\) and \(\alpha_U=1\). The uniform diagonal law is represented exactly by \(2^N\) point-mass product components, matching the lower bound. QED.

This theorem does **not** follow for an \(\eta\)-approximate mixture without a new argument: the pointwise uniform-marginal domination would become \(Q_F(f^*)\le2^{-N}+\eta\), losing an order-\(N\) exponent at constant \(\eta\).

### 5. TV-robust bound (even for block-product mixtures)

**Lemma 4 (finite conditional entropy continuity).** If \(P,Q\) are laws on finite \(\mathcal X\times\mathcal Y\) with \(\operatorname{TV}(P,Q)\le\eta\le1/2\), then
\[
|H_P(X\mid Y)-H_Q(X\mid Y)|
\le\eta\ln|\mathcal X|+h_2(\eta).
\]

*Proof.* Let \(\rho=\operatorname{TV}(P,Q)\), and take a maximal common-part decomposition \(P=(1-\rho)R+\rho P_1\), \(Q=(1-\rho)R+\rho Q_1\). Introduce a binary mixing flag \(B\) of bias \(\rho\). The chain rule gives
\[
H_P(X\mid Y)=(1-\rho)H_R(X\mid Y)+\rho H_{P_1}(X\mid Y)+I_P(X;B\mid Y).
\]
The final term is in \([0,h_2(\rho)]\). The analogous formula holds for \(Q\). Both conditional entropies of the residuals are in \([0,\ln|\mathcal X|]\); subtraction bounds the difference by \(\rho\ln|\mathcal X|+h_2(\rho)\). The right-hand function is increasing for \(\rho\in[0,1/2]\), so replace \(\rho\) by \(\eta\). Take \(Y\) constant for unconditional entropy. QED.

**Theorem 5 (robust block-product obstruction).** If \(Q\) is an \(M\)-block-product mixture, \(\operatorname{TV}(Q,P_U)\le\eta\le1/2\), then
\[
\boxed{\ln M\ge\sum_i\phi(r_i)-2\eta N\ln2-2h_2(\eta)
       \ge N[\phi(2/\pi)-2\eta\ln2]-2h_2(\eta).}
\]
At \(\eta=0.01\):
\[
\ln M\ge 0.2053376032149689\,N-0.1120030687096947.
\]
The asymptotic exponent is positive for every fixed
\(\eta<\phi(2/\pi)/(2\ln2)=0.158119770933\ldots\).

*Proof.* Use \(I(F;G)=H(F)-H(F\mid G)\) and apply Lemma 4 to each entropy, with \(|\mathcal X|=2^N\). Thus \(I_Q(F;G)\ge I_{P_U}(F;G)-2\eta N\ln2-2h_2(\eta)\). Theorem 2 lower-bounds \(I_{P_U}\); conditional independence under \(Q\) upper-bounds \(I_Q(F;G)\le H(\Theta)\le\ln M\). QED.

### 6. Exactly why the old exponent was \(0.2026\)

Let \(U_0\) denote the law of independent fair sign blocks. Conditional on \(F=f\), the \(G_j\) are independent Rademachers, so
\[
\mathbb E_{U_0}e^{\lambda S_U}
=\mathbb E_F\prod_j\cosh\!\left(\frac{\lambda(Uf)_j}{N}\right)
\le e^{\lambda^2/(2N)}
\]
by \(\ln\cosh(t)\le t^2/2\) and \(\|Uf\|_2^2=N\). Since \(P_U\) has fair block marginals,
\(D(P_U\|U_0)=I_{P_U}(F;G)\).
Gibbs' KL variational principle with \(\lambda=N\alpha_U\) yields
\[
\ln M\ge I(F;G)\ge N\alpha_U^2/2\ge 2N/\pi^2
           =0.2026423672846755\ldots\,N.
\]
This is correct, but loses the positive terms beyond \(t^2/2\) in \(\phi(t)=t^2/2+t^4/12+\cdots\). The binary-entropy certificate is strictly stronger for exact block-product mixtures and supports a better robust form. The maximum-atom theorem is stronger still, but has additional factorization assumptions and is not yet TV-robust. **Do not present \(0.2026\) and \(0.2192\) as a contradiction.**

### 7. Independent finite audit and limitations

For the \(N=2\) Walsh–Hadamard matrix, the Gaussian plane has eight angular sectors of mass \(1/8\); the joint law has eight atoms and uniform four-state marginals. Direct computation gives \(I(F;G)=\ln2\), \(\mathbb E S_U=1/\sqrt2\), and exact coordinate-product mixture complexity \(4\): no positive support rectangle contains more than two of the eight atoms, while conditioning on F gives a four-component product representation. The joint matrix's ordinary real rank is only three. This illustrates why ordinary rank, block-product rank and full-coordinate product complexity must be distinguished.

The deterministic checker in this directory audits constants, the N=2 sector model, the identity-matrix sharpness case, and finite conditional-entropy continuity. These checks **do not prove** the universal theorems. This manuscript's Gaussian sign–correlation argument is an analytic proof; Mathlib/Lean has not yet verified the complete specialization. The generic finite-information bound and conditional terminal were separately formalized (PRs #869 and #871) and are not being misrepresented as the full Gaussian theorem.

This result is about the *unconditioned* sign-Gaussian law, not arbitrary Forrelation YES-promise inputs, not a classical query lower bound, and not an equivalence between mixture complexity and quantum advantage. No publication-priority claim is made. Independent expert mathematical review, prior-art audit and contributor consent remain required for any journal or arXiv submission.

### Related literature and attribution

- Aaronson–Ambainis, *Forrelation: A Problem That Optimally Separates Quantum from Classical Computing*, SIAM J. Comput. 2018, https://arxiv.org/abs/1411.5729
- J. Briët, *Lecture Notes on Applications of Grothendieck's Inequality*, Lemma 2.1, https://www.thenetworkcenter.nl/uploaded_files/inlineitem/JB_grothendieck_proof.pdf
- *Forrelation Is Extremally Hard*, ITCS 2026, https://doi.org/10.4230/LIPIcs.ITCS.2026.72
- Braun–Jain–Lee–Pokutta, *Information-theoretic approximations of the nonnegative rank*, ECCC TR13-158, https://eccc.weizmann.ac.il/report/2013/158/
- Montúfar–Morton, *When Does a Mixture of Products Contain a Product of Mixtures?*, SIAM J. Discrete Math. 2015, https://doi.org/10.1137/140957081
- Tim Austin, *Multi-variate correlation and mixtures of product measures*, Kybernetika 2020, https://doi.org/10.14736/kyb-2020-3-0459

### Status

**Public mathematical working paper:** the analytic proof is written in full and its finite checker passes. **Not claimed:** end-to-end Lean Gaussian-sign theorem, independent human referee certification, novelty clearance, or arXiv/journal publication. The material was prepared following the explicit request to publish a companion paper; contributor identification is reserved for the human research team.