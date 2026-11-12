# Sharp SLD tensorization and physically attained ternary extremizers

**NIGHTFALL / Devin J. Wright — 11 November 2026 — analytic result, version 1.0.**

**Certification:** Author-side finite-dimensional proof and two independent finite exact rational replay scripts (homogeneous and heterogeneous examples). This document is **not** an end-to-end Lean kernel theorem, external referee report, worldwide novelty certificate, or approval for public submission. It is independent of the unrefereed v8 all-product quadratic influence proof.

## Theorem A: exact condition-number-dependent tensor envelope

Let \(b_i\succ0\) be density operators on nonzero finite-dimensional complex Hilbert spaces. Write \(J_b(Y)=(bY+Yb)/2\), and let
\[
\kappa_i=\lambda_{\max}(b_i)/\lambda_{\min}(b_i)\ge1,\qquad
C_d(\boldsymbol\kappa)=\frac{2^{1-d}\prod_{i=1}^d(1+\kappa_i)}{1+\prod_{i=1}^d\kappa_i}
=\frac{\prod_i\cosh(\tfrac12\log\kappa_i)}{\cosh(\tfrac12\sum_i\log\kappa_i)}.
\]
On complex Hilbert–Schmidt operator space, including its Hermitian real subspace,
\[
\boxed{J_{\bigotimes_i b_i}^{-1}\succeq C_d(\boldsymbol\kappa)
      \bigotimes_iJ_{b_i}^{-1}.}
\]
For **every fixed tuple** of local density operators this coefficient is optimal as an operator inequality. It is attained on off-diagonal matrix units joining the tensor-product maximal-eigenvalue and minimal-eigenvalue eigenvectors (and by their Hermitian sum). Thus the coefficient requires no dimension or minimum-eigenvalue lower bound beyond faithfulness. It equals one if all \(\kappa_i=1\), and approaches \(2^{1-d}\) as all \(\kappa_i\to\infty\).

**Proof.** Diagonalize each \(b_i\). For a tensor matrix unit whose local row/column eigenvalues are \(\alpha_i,\beta_i>0\), the ratio of the diagonal quadratic-form coefficients of the left and unscaled right sides is
\[
R=\frac{2^{1-d}\prod_i(\alpha_i+\beta_i)}
          {\prod_i\alpha_i+\prod_i\beta_i}
 =\frac{\prod_i\cosh t_i}{\cosh(\sum_i t_i)},
\quad t_i=\tfrac12\log(\alpha_i/\beta_i),\
|t_i|\le h_i:=\tfrac12\log\kappa_i.
\]
The numerator is unchanged by individual sign changes, and
\(\cosh(\sum_i t_i)\le\cosh(\sum_i|t_i|)\).
For \(0\le t_i\le h_i\),
\[
\partial_{t_i}\log R=
 \tanh t_i-\tanh(\sum_jt_j)\le0.
\]
The minimum therefore occurs at every \(t_i=h_i\), giving \(C_d\). Taking the maximal and minimal eigenvectors for every \(i\) realizes that ratio. All superoperators are diagonal in the tensor matrix-unit basis, proving the claimed Loewner inequality. \(\square\)

### Boundary checks

- At \(d=1\), \(C_1=1\) and the operator inequality is equality.
- A locally maximally mixed factor (\(\kappa_i=1\)) contributes no penalty: it cancels from the expression for \(C_d\).
- The statement compares **inverse SLD/Jordan operators**. It is not the additive quantum Fisher information law for independently parametrized states and is not a general quantum channel tensorization theorem.

## Theorem B: actual independent ternary sources attain Theorem A

Fix arbitrary \(\kappa_i\ge1\); choose
\(p_i=\kappa_i/(1+\kappa_i)\), \(q_i=1/(1+\kappa_i)\), and real \(r_i\) with \(0<r_i^2<p_iq_i\).
Let \(X_i\) be independent uniform symbols in \(\{0,1,2\}\); put
\(\omega=e^{2\pi i/3}\) and define local faithful qubit states
\[
\rho_{i,x}=
\begin{pmatrix}p_i&r_i\omega^{-x}\\r_i\omega^{x}&q_i\end{pmatrix}.
\]
The average register state is \(b_i=\mathrm{diag}(p_i,q_i)\).
Let the bounded scalar target be
\[
f(X)=\cos\left(\tfrac{2\pi}{3}\sum_iX_i\right).
\]
Then \(\mathbb E f=0\), \(\operatorname{Var}(f)=1/2\), \(|f|\le1\), and \(f\) has **pure Hoeffding interaction order \(d\)**.

For a subset \(Q\), denote the optimal reduction in scalar Bayes mean-square error from a collective measurement of the registers in \(Q\) by \(G^*(Q)\). Define \(T_i(g)=\tfrac13\sum_xg(x)\rho_{i,x}\) on the real centered ternary contrast space and \(K_i=T_i^*J_{b_i}^{-1}T_i\). Then:
\[
\begin{aligned}
K_i&=(2r_i^2)I,\quad a_i=\lambda_{\min}(K_i)=2r_i^2>0,\\
G^*(Q)&=0\qquad(Q\subsetneq[d]),\\
G^*([d])&=\frac{\prod_i r_i^2}{\prod_ip_i+\prod_iq_i},\\
\frac{G^*([d])}{\operatorname{Var}(f)\prod_i a_i}
&=\frac{2^{1-d}}{\prod_ip_i+\prod_iq_i}
=C_d(\boldsymbol\kappa).
\end{aligned}
\]
Thus Theorem A is **also sharp within real scalar Bayesian estimation by physical, product-prepared qubit ensembles**. No globally entangled input states or singular averages are needed.

**Proof.** The ternary characters have exact mean zero and orthogonality. Any proper marginal of the full target's score vanishes, because at least one nontrivial character is averaged out. The full centered score is exactly
\[
A=\mathbb E[f(X)\bigotimes_i\rho_{i,X_i}]
=\frac{\prod_i r_i}{2}(|0^d\rangle\langle1^d|+
                       |1^d\rangle\langle0^d|).
\]
Since \(J_B\) multiplies this off-diagonal operator by
\((\prod p_i+\prod q_i)/2\), the Personick optimum
\(\operatorname{Tr}(A J_B^{-1}(A))\) gives the stated gain.
The real centered ternary contrasts
\(\sqrt2\cos(2\pi x/3)\) and \(\sqrt2\sin(2\pi x/3)\) are orthonormal and are sent by \(T_i\) to orthogonal qubit off-diagonal matrices of squared Hilbert–Schmidt norm \(r_i^2\). As \(J_{b_i}^{-1}\) acts on them by multiplication by two, \(K_i=2r_i^2 I\). Substitution completes the equality and proves all local Gram gaps are positive. \(\square\)

The construction also shows no proper register subset reveals the target in this *mean-square Bayes-gain* sense, although its terminal leave-one-out gain is positive. Do **not** rephrase it as a lower bound on an initial single-register acquisition, quantum adaptive-query complexity theorem, or general correlated-input result.

## Corollary: no polynomial-in-degree replacement of the SLD transfer loss

Choose the same \(p_i=9/10\), \(q_i=1/10\), \(r_i=3/20\) for every coordinate. Every local average has condition number \(9\) and positive visibility gap \(a_i=9/200\), uniformly in \(d\), but
\[
\frac{G^*([d])}{a^d\operatorname{Var}(f)}
=\frac{2\cdot5^d}{9^d+1}
\le2(5/9)^d.
\]
Hence **no universal positive inverse-polynomial function of \(d\)** can replace the degree-dependent SLD tensor comparison coefficient while retaining only fixed local-condition-number and local-contrast-gap hypotheses. This is a restricted impossibility statement about the specific normalized interaction-transfer model; it does not rule out better bounds under additional encoding symmetry, commutativity, interaction structure, or a different observation resource.

## Machine replay and independent attack

From repository root:

~~~sh
python3 -I papers/quantum-sld-tensorization/checks/check_trine_score_exact.py
python3 -I papers/quantum-sld-tensorization/checks/check_spectral_constant_exact.py
~~~

- **Score checker:** exact arithmetic in \(\mathbb Q(\omega)\); enumerates every \(3^d\) source string and every \(2^d\times2^d\) score entry for \(d=1,2,3,4\), checks local positive definiteness, the explicit full-score formula, full Bayes gain, and ratio. Reference \((p,r)=(9/10,3/20)\); ratios: \(1,25/41,25/73,625/3281\).
- **Independent spectral checker:** rational-only enumeration of all tensor matrix-unit ratios for local condition-number lists \( (1), (9), (1,9), (2,5), (1,3,9), (9,9,9,9)\). It independently checks exact equality at the maximally/minimally oriented matrix unit and the **nonuniform** physical extremizer's gain ratio.
- Both checks are finite falsification tests; the proof of all dimensions and spectra is the analytic argument above, not an exhaustive program or Lean certificate.

### Review / prior-art status

1. Independently audit the spectral ratio and its sign/endpoint minimization; try noncommuting local bases, singleton local dimensions, and equal eigenvalues. Re-derive Theorem B from the *original operational definition* of optimal Bayes risk, verifying scalar centering and contrast Gram normalization.
2. Establish whether the exact \(\cosh\)-ratio formula, physical ternary saturation, or related spectral comparison already appears in quantum information geometry. The known SLD/Bures–Helstrom metric and Personick optimal-estimation frameworks predate NIGHTFALL; a targeted search of this area has **not** verified worldwide priority.
3. The general operator inequality and ternary physical extremizer are **not** in the current Lean registry. Don't promote them by adding a historical CI link from an unrelated Lean module.
4. The earlier \(2^{1-d}\) bound, quantum ANOVA, and operational interaction expansion are treated as prior NIGHTFALL analytic inputs, not newly invented here. No implication for Bouvel's conjecture or exponent-two arbitrary-law influence is claimed.

**Contribution graph:** Product quantum average states → SLD matrix-unit representation → exact spectral constant → ternary phase-source extremizer → fixed-gap exponential no-go → two independent exact replay checks → outstanding specialist referee / novelty gate.

**Antecedents for review:** Personick (1971), *Application of quantum estimation theory to analog communication over quantum channels*, IEEE Trans. Inf. Theory 17, 240–246, DOI 10.1109/TIT.1971.1054643; M. Tsang (2023), *Operational meanings of a generalized conditional expectation in quantum metrology*, Quantum 7, 1162, https://arxiv.org/abs/2212.13162; classical Jordan/SLD metric comparison, e.g. https://pmc.ncbi.nlm.nih.gov/articles/PMC7517174/.
