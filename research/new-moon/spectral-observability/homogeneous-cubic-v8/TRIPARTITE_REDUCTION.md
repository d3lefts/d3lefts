# Three-block projection: a law-free reduction of homogeneous cubic influence

**11 November 2026.** Status: elementary analytic reduction with exact rational finite replay. **Not** a proof of exponent-two influence or a claim of global originality. See O'Donnell–Zhao (2016) on polynomial decoupling, and Bansal–Sinha–de Wolf (2022) on completely bounded block-multilinear forms; our hypothesis here concerns ordinary bounded product-law observables, **not** complete boundedness.

## Theorem (tripartite reduction; finite product)

Let \(f\) be a bounded *homogeneous Hoeffding degree-three* scalar or real-Hilbert-valued observable on a finite independent product space. Set \(B=\|f\|_\infty\), \(V=\operatorname{Var}(f)\), and \(M=\max_i I_i(f)\).

There is a partition of the input coordinate index set into three disjoint classes \(A_1,A_2,A_3\) and an ANOVA subprojection \(g\) satisfying:

1. Every nonzero interaction support of \(g\) contains exactly one coordinate from each \(A_j\); in particular \(g\) is 3-partite trilinear.
2. \(\operatorname{Var}(g)\ge(2/9)V\).
3. \(\|g\|_\infty\le8B\).
4. \(I_i(g)\le I_i(f)\) for each coordinate.

Therefore, if **all** bounded degree-three tripartite observables obey
\[
\operatorname{Var}(g)\le C\|g\|_\infty\sqrt{\max_i I_i(g)},
\tag{Tri3(C)}
\]
then **all** bounded homogeneous cubics obey
\[
\boxed{\operatorname{Var}(f)\le 36\,C B\sqrt M.}
\]
The converse is tautological, since trilinear tripartite functions are homogeneous cubics. Thus (Tri3) and the unrestricted pure-cubic exponent-two conjecture are equivalent **up to constants**.

## Proof

For a block \(A\), write \(E_A\) for integrating all its input coordinates against their product marginal, keeping the other coordinates fixed. Each \(E_A\) is a commuting \(L^\infty\) contraction and orthogonal projection in \(L^2\). Let
\[
P_{\mathcal A}=(I-E_{A_1})(I-E_{A_2})(I-E_{A_3}),\qquad g=P_{\mathcal A}f.
\]

On an ANOVA component \(f_S\), the factor \(I-E_{A_j}\) retains it iff \(S\cap A_j\ne\varnothing\). Because every nonzero support of \(f\) has size three, a retained support must meet each class **exactly once**. Hence
\[
g=\sum_{\substack{|S|=3\\|S\cap A_j|=1\ (j=1,2,3)}} f_S.
\]
Orthogonality gives
\(\operatorname{Var}(g)=\sum_{S\text{ rainbow}}\|f_S\|_2^2\)
and \(I_i(g)\le I_i(f)\). The \(L^\infty\) operator norm of \(I-E_{A_j}\) is at most two, so \(\|g\|_\infty\le 2^3B=8B\), including Hilbert-valued outputs by Jensen's inequality.

Color each coordinate independently uniformly in \(\{1,2,3\}\). A fixed triple is rainbow with probability \(3!/3^3=2/9\). Taking expectation of the ANOVA energy identity over colorings yields
\[
\mathbb E_{\mathcal A}\operatorname{Var}(P_{\mathcal A}f)
=\frac29\operatorname{Var}(f).
\]
One coloring achieves at least this average, and the four claims hold for that coloring. Apply (Tri3(C)) to obtain \(2V/9\le8CB\sqrt M\), or \(V\le36CB\sqrt M\). QED.

For an essentially countably supported measurable product, first restrict to countably many essential inputs, assign independent colors, and apply Tonelli to the nonnegative summable ANOVA energies. The norm and energy statements hold as \(L^\infty\) and \(L^2\) operator bounds. Additional posterior measurable-selection requirements for adaptive prediction are **not** proved here.

## Fixed-degree transfer

The identical argument works for any fixed homogeneous degree \(k\): use \(k\) independently colored blocks, and
\[
P=\prod_{j=1}^k (I-E_{A_j}).
\]
It retains a fraction \(k!/k^k\) of homogeneous energy on average, is an \(L^\infty\) contraction up to factor \(2^k\), and never increases influence. A universal constant \(C_k\) for \(k\)-partite homogeneous degree \(k\) functions transfers to arbitrary homogeneous degree \(k\) with coefficient
\[
\boxed{2^k\,\frac{k^k}{k!}\,C_k.}
\]
This is a proof-reduction operator, not an independent improvement of the exponent.

## Why it changes the next experiment

The v8 pure-cubic theorem removes lower-degree cancellation; this theorem also removes non-partite support geometry at a fixed constant cost. The unresolved kernel can be studied on a function
\[
g(x_A,x_B,x_C)=\sum_{a\in A,\,b\in B,\,c\in C} g_{abc}(x_a,x_b,x_c)
\]
with **one input from each class per interaction**. Repeated AB pairs and dense links remain, but links are naturally indexed by ordered block pairs, enabling conditional covariance and operator-factorization tests.

A tempting application of Bansal–Sinha–de Wolf's completely bounded trilinear theorem is **not** justified without controlling the completely bounded norm from ordinary \(\|g\|_\infty\); we make no such assumption.

## Independent rational check

Run \`python3 checks/tripartite_projection_exact.py\`. It tests all \(3^5=243\) coordinate colorings of a five-coordinate *heterogeneously biased* Boolean product, evaluating the retained energies and sup norms directly, without importing the general proof. It confirms exact mean retention \(2/9\), \(8B\) norm control, influence monotonicity, and existence of an above-average coloring.

## Prior work / attribution (consulted 2026-11-11)

- Ryan O'Donnell and Yu Zhao, *Polynomial Bounds for Decoupling, with Applications*, CCC 2016, https://doi.org/10.4230/LIPIcs.CCC.2016.24.
- Nikhil Bansal, Makrand Sinha, Ronald de Wolf, *Influence in Completely Bounded Block-Multilinear Forms and Classical Simulation of Quantum Algorithms*, CCC 2022, https://doi.org/10.4230/LIPIcs.CCC.2022.28.
- David Turturean, *A proof of the Aaronson–Ambainis conjecture*, arXiv:2611.09773 (2026): general Boolean-cube \((5/2,6)\) theorem.

**Certification:** analytic proof above, exact finite falsification checks, no independent mathematical referee, no Lean certificate, and no novelty claim.
