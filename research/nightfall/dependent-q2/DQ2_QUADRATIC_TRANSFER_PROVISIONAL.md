# DQ2 algebraic quadratic transfer — provisional author-side theorem

**Checkpoint:** 2026-11-17. **Status:** paper proof and finite computational audits, **not Lean certified, not independently refereed, not priority certified**. Do not promote to the canonical theorem catalogue as certified; do not confuse algebraic degree 2 with spectral degree 2.

## Definitions

Let \(\nu\) be a strictly positive law on \(\{-1,1\}^n\).
Set \(R_i f=f-\mathbb E_\nu[f\mid X_{-i}]\) and
\(I_i(f)=\mathbb E_\nu[\operatorname{Var}(f\mid X_{-i})]\).
Let \(A=\sum_iR_i\) have Poincaré gap \(\lambda>0\).
Write \(w_i(x_{-i})=\operatorname{Var}(X_i\mid x_{-i})\),
\(v_i=\mathbb E_\nu w_i\), \(D=\operatorname{diag}(v_i)\),
and \(\Sigma=\operatorname{Cov}_\nu(X)\).
For the site-conditional TV Dobrushin matrix \(c_{ij}\), let
\(\kappa=\max_i\sum_{j\ne i}c_{ij}<1\).

## Theorem A: quadratic transfer principle

Assume \(\alpha D\preceq\Sigma\preceq\beta D\),
\(\lambda\operatorname{Var}(g)\le\sum_i I_i(g)\) for all \(g\),
and for some \(R\ge 1\) all conditional variances obey
\(R^{-1}v_i\le w_i(x_{-i})\le Rv_i\).

Every multilinear quadratic
\[f(x)=c+\sum_i a_ix_i+\sum_{i<j}b_{ij}x_ix_j,\qquad |f|\le B\]
satisfies
\[
\boxed{\operatorname{Var}_\nu(f)^2\le
 \frac{R^3}{\lambda^2}
 \left(5+\frac{4\sqrt2\,\beta}{\sqrt\alpha}\right)^2
 B^2\max_i I_i(f).}
\]
All constants are independent of \(n\), graph degree and interaction overlap.

## Corollary B: Dobrushin and high-temperature Ising

Under Dobrushin, \(\alpha=(1+\kappa)^{-1}\),
\(\beta=(1-\kappa)^{-1}\), \(\lambda\ge1-\kappa\).
For an Ising law
\(\nu(x)\propto\exp(\sum_i h_ix_i+\sum_{i<j}J_{ij}x_ix_j)\)
with \(H=\max_i\sum_{j\ne i}|J_{ij}|<1\), all fields \(h_i\)
may be arbitrary. Since \(\kappa\le H\) and
\(w_i(x)=\operatorname{sech}^2(h_i+\sum_jJ_{ij}x_j)\),
the log conditional variance is 2-Lipschitz in the local field
and \(R\le e^{4H}\). Thus
\[
\boxed{\operatorname{Var}_\nu(f)^2\le
\frac{e^{12H}}{(1-H)^2}
\left(5+\frac{4\sqrt{2(1+H)}}{1-H}\right)^2
B^2\max_i I_i(f).}
\]
This is **bias independent** and permits dense overlapping interactions,
including Curie–Weiss at fixed inverse temperature below 1.

## Corollary C: arbitrary positive binary Dobrushin laws

If \(v_* = \min_{i,x_{-i}}w_i(x_{-i})>0\), no assumption on
relative variance distortion is needed:
\[
\operatorname{Var}_\nu(f)^2\le
\frac{1}{v_*(1-\kappa)^2}
\left(5+\frac{4\sqrt{2(1+\kappa)}}{1-\kappa}\right)^2
B^2\max_iI_i(f).
\]

## Proof mechanism — make independently checkable

**1. Residual Gram comparison.** Let
\(\zeta_i=X_i-\mathbb E[X_i\mid X_{-i}]\), with
\(\mathbb E\zeta_i^2=v_i\). For \(i\ne j\),
\(\mathbb E\zeta_iX_j=0\), and the binary conditional covariance
identity yields
\(|\mathbb E\zeta_i\zeta_j|\le
\min(c_{ji}v_i,c_{ij}v_j)\).
Therefore
\[
(1-\kappa)\sum_i a_i^2v_i\le
\left\|\sum_i a_i\zeta_i\right\|_2^2\le
(1+\kappa)\sum_i a_i^2v_i,
\]
using
\(2\sqrt{c_{ij}c_{ji}}|a_ia_j|\le c_{ij}a_i^2+c_{ji}a_j^2\)
and the Dobrushin row-sum bound.
For \(g=\sum_i a_iX_i\),
\(\mathbb E[g\sum_i a_i\zeta_i]=\sum_i a_i^2v_i\);
Cauchy–Schwarz gives
\(\operatorname{Var}(g)\ge (1+\kappa)^{-1}\sum_i a_i^2v_i\).
The heat-bath Poincaré inequality gives the matching upper
\((1-\kappa)^{-1}\sum_i a_i^2v_i\).

**2. Deterministic quadratic decoupling.** Symmetrize \(b_{ij}\)
with zero diagonal and put
\(q(x)=\sum_{i<j}b_{ij}x_ix_j\). Boundedness implies
\(\sum_i|a_i|\le B\) and \(\operatorname{osc}(q)\le2B\).
For sign vectors \(x,y\), put \(u=(x+y)/2\), \(v=(x-y)/2\).
The identity \(x^\top by=2(q(u)-q(v))\), and multilinear
interpolation to the sign cube, give \(|x^\top by|\le4B\).
The sharp \(L^1\) Khintchine inequality then gives
\[
\sum_i\left(\sum_jb_{ij}^2\right)^{1/2}\le4\sqrt2 B.
\]
Set \(d_i=a_i+\sum_jb_{ij}\mathbb EX_j\).
Then \(\sum_i|d_i|\le5B\).

**3. Influence summation.** Write
\(h_i=a_i+\sum_jb_{ij}X_j\),
\(\sigma_i^2=\sum_jv_jb_{ij}^2\), and \(M=\max_iI_i(f)\).
Since \(R_if=\zeta_ih_i\),
\[
\frac{v_i}{R}(d_i^2+\alpha\sigma_i^2)
\le I_i(f)\le
Rv_i(d_i^2+\beta\sigma_i^2).
\]
Consequently
\(\sqrt{v_i}|d_i|\le\sqrt{RM}\) and
\(\sqrt{v_i}\sigma_i\le\sqrt{RM/\alpha}\).
The deterministic bounds above imply
\[
\sum_iI_i(f)\le R^{3/2}B\sqrt M
\left(5+\frac{4\sqrt2\beta}{\sqrt\alpha}\right).
\]
Apply Poincaré and square. QED.

For Corollary C, use \(I_i\ge v_*\mathbb Eh_i^2\),
\(I_i\le\mathbb Eh_i^2\), the same coefficient decoupling,
and the Dobrushin linear covariance sandwich.

## Audit and limitations

- Exact enumeration of 13 rational three-spin laws, including
  zero-field Ising chain with nearest correlation 1/2:
  \(\kappa=4/5\), \(v_* =9/25\), \(v=(3/4,3/5,3/4)\),
  \(G_{12}=G_{23}=-3/10\), \(G_{13}=0\).
- Independent enumerative stress tests: 12 Ising models for
  covariance sandwich and nondegenerate bound; 128 high-temperature
  Ising instances, sizes (n=3,4,6,8), fields up to magnitude 12
  for relative variance and bias-free bound.
- Tests are not proofs or independent refereeing. No Lean code has
  been compiled; no infinity-dimensional or general-alphabet claim.
- The mathematical degree here is algebraic multilinear degree ≤2.
  Spectral degree for noncommuting Glauber residuals is not resolved.
- The constants are not sharp; no originality claim yet.

### Priority comparisons before theorem promotion

Koehler–Lifshitz–Minzer–Mossel, *Influences in Mixing Measures*
(STOC 2024), https://arxiv.org/abs/2307.07625 ;
Götze–Sambale–Sinulis, *Higher order concentration*
https://arxiv.org/abs/1801.06348 ;
Adamczak–Kotowski–Polaczyk–Strzelecki, *A note on concentration
for polynomials in the Ising model* https://arxiv.org/abs/1809.03187 ;
Wu, *Poincaré and transportation inequalities ... Dobrushin*
https://arxiv.org/abs/math/0611635 ;
Mukherjee et al., *Logistic Regression under Network Dependence*
(JMLR 2024, Lemma 23), https://jmlr.org/papers/volume25/22-1040/22-1040.pdf.

**Next gate:** independent proof attack of (i) \(c_{ij}\) orientation,
(ii) conditional-variance ratio, (iii) decoupling identity and constants,
and (iv) relationship to the cited high-temperature Ising results.
