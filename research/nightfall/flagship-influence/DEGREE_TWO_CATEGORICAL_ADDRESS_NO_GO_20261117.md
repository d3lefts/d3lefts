# NIGHTFALL UE2: degree-two categorical addressing defeats inverse-degree root-sum Bernstein

**Checkpoint:** 2026-11-17 US Eastern. **Status:** exact analytic counterexample to one *auxiliary proof shortcut*, not to the extremal N-UE2(2,1) conjecture or to unrestricted cubic exponent two. Source is finite independent product, full support, one categorical coordinate and fair leaf signs. Author-side proof, independent exact full-state Fraction checker, no Lean or human referee certification. Address functions and Fourier/ANOVA decomposition are classical; no worldwide novelty claim.

## The shortcut under attack

Let \(R_i=I-\mathbb E[\cdot\mid X_{-i}]\) be original-product residuals, \(N=\sum_iR_i\) the Efron–Stein degree operator, and \(N^{-1}\) its inverse on centered ANOVA sectors. The stronger proposed inequality
\[
\tag{FALSE}\sum_i\|R_iN^{-1}(f-\mathbb Ef)\|_2\le d B(f)
\]
for all bounded real degree-\(d\) product functions would imply N-UE2(2,1) by \(\operatorname{Var}(f)=\sum_i\langle R_i f,R_iN^{-1}(f-\mathbb Ef)\rangle\) and Cauchy. It is **false already at degree two for a 7-symbol categorical coordinate**, and the violation factor is unbounded as the alphabet grows.

## Construction and exact ANOVA calculation

Let \(m\ge2\), let \(A\) be uniform on \(\{1,\ldots,m\}\), and let \(Y_1,\ldots,Y_m\) be mutually independent fair signs, independent of A. Set \(f(A,Y)=Y_A\). Then
\[
B(f)=1,\quad V=\operatorname{Var}(f)=1,\quad I_A(f)=1-1/m,\quad I_{Y_j}(f)=1/m,
\quad M=1-1/m.
\]
The canonical ANOVA decomposition is exactly
\[
 f=\frac1m\sum_jY_j+\sum_j(\mathbf 1_{\{A=j\}}-1/m)Y_j,
\]
with first-chaos and second-chaos terms only. The second-chaos is nonzero, so degree is **exactly 2**. Applying \(N^{-1}\) multiplies the pair component by 1/2:
\[
 h=N^{-1}f=\sum_j\left(\frac1{2m}+\frac12\mathbf1_{\{A=j\}}\right)Y_j.
\]
The exact inverse-degree residual norms are
\[
\|R_{Y_j}h\|_2^2=\frac{m+3}{4m^2},\quad
\|R_Ah\|_2^2=\frac{1-1/m}{4}.
\]
Thus the full \(\ell^1(L^2)\) gradient budget is
\[
\boxed{\sum_i\|R_ih\|_2=\frac{\sqrt{m+3}+\sqrt{1-1/m}}2.}
\]
At \(m=6\), the sum is \((3+\sqrt{5/6})/2<2=dB\). At \(m=7\), it is \((\sqrt{10}+\sqrt{6/7})/2>2\), as follows from the exact rational inequality \(60/7>(18/7)^2\). The leaf-only sum \(\sqrt{m+3}/2\) already exceeds 2 at \(m=14\), and the ratio of the full left side to \(dB=2\) diverges like \(\sqrt m/4\).

**Crucial safeguard:** the original extremal bound is not threatened. Its ratio for this family is
\[
\frac{V^2}{d^2B^2M}=\frac{m}{4(m-1)}\le\frac12.
\]
The address site itself has large genuine original-law influence; any sharp general proof must charge high leaf-gradient mass to the same selector. This is the categorical analogue of the fair-binary addressing obstruction in `INVERSE_DEGREE_GRADIENT_NO_GO_20261117.md`, but it is strictly stronger because the failure is already in degree two, with arbitrary-alphabet relevance.

## Audit and transfer

- `python3 -I research/nightfall/flagship-influence/check_categorical_address_resolvent_exact.py` performs independent full-state rational enumeration for m=2 through m=7. Its raw conditional-variance computations reproduce all original source influences, both residual norm formulas, and the failing m=7 threshold. m=14 leaf failure is symbolic, not brute-force enumeration.
- All variables are genuinely independent. The construction does not use correlated coordinates or the misleading Boolean flip convention.
- The unrestricted C=1 conjecture, the unknown-coefficient exponent-two conjectures, and the cubic source-consistent mean-coupled Q2 gate remain open.
- **Discovery operator:** category/address compression collapses k fair-bit selector coordinates into one high-alphabet coordinate, reducing Fourier degree from k+1 to 2 while preserving the geometry of many rare selected leaves. Proof strategies should be robust to this categorical compression and joint-selector charging.
