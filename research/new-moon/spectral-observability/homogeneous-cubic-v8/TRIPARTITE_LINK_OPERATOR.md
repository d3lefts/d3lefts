# Exact 3-partite link representation and the missing quadratic energy inequality

**2026-11-11 · Proposed operator, not a theorem closure.** This note continues the [tripartite projection](TRIPARTITE_REDUCTION.md). All identities are algebraic/measure-theoretic on finite products; the conjecture below is **unproved**.

## Link representation

Let \(f(X_A,X_B,X_C)\) be a real, bounded, homogeneous cubic with every ANOVA support containing exactly one coordinate from each of the three disjoint blocks. Write
\[
f=\sum_{a\in A}q_a(X_a;X_B,X_C),\qquad
q_a=\sum_{b\in B,c\in C} f_{\{a,b,c\}}.
\]
Each \(q_a\), viewed as a function of \(X_a\), is centered. Regard
\(Q_a(X_B,X_C)=q_a(\cdot;X_B,X_C)\) as an element of the Hilbert space
\(H_a=L^2_0(\mu_a)\). As a function of \(X_B,X_C\), it has **pure interaction degree two**, one input from each of B and C.

**Pointwise block-\(\ell_1\) budget.** For almost every \((x_B,x_C)\), define the essential range width
\[
R_a(x_B,x_C)=\operatorname*{ess\,sup}_{x_a}q_a(x_a;x_B,x_C)
-\operatorname*{ess\,inf}_{x_a}q_a(x_a;x_B,x_C).
\]
Because the \(X_a\) are independent and \(|f|\le B_0\), the essential range width of their sum is \(\sum_aR_a\le2B_0\). Popoviciu's bound yields \(\|Q_a(x_B,x_C)\|_{H_a}\le R_a/2\). Hence
\[
\boxed{\sum_{a\in A}\|Q_a(x_B,x_C)\|_{H_a}\le B_0}
\quad\text{for almost every }(x_B,x_C).
\tag{L1}
\]

**Exact influence identities.** Orthogonality of the separate centered A-coordinate fibers gives
\[
\boxed{V(f)=\sum_a\mathbb E_{BC}\|Q_a\|^2,\qquad
I_a(f)=\mathbb E_{BC}\|Q_a\|^2,}
\]
and for every \(j\in B\cup C\),
\[
\boxed{I_j(f)=\sum_a \mathbb E_{BC}\|(I-E_j)Q_a\|_{H_a}^2.}
\]
Thus no hidden rank or leaf-alphabet parameter is introduced by this representation.

## Single missing sufficient inequality — conjecture, not established

Let \(\{Q_a\}\) be an arbitrary finite family of \(H_a\)-valued **pure B×C bilinear** product-space observables satisfying the stronger pointwise condition (L1), with arbitrary Hilbert spaces \(H_a\) and arbitrary independent input laws. Set
\[
\mathcal V=\sum_a\mathbb E\|Q_a\|^2,\quad
\mathcal M=\max\left\{
\max_a\mathbb E\|Q_a\|^2,\
\max_{j\in B\cup C}\sum_a\mathbb E\|(I-E_j)Q_a\|^2
\right\}.
\]

**Link-energy conjecture LE(C):** there is an absolute constant \(C\) such that
\[
\boxed{\mathcal V\le C\,B_0\sqrt{\mathcal M}.}
\]
If proved, this would imply the unrestricted 3-partite squared-variance influence theorem and, by [tripartite reduction](TRIPARTITE_REDUCTION.md), the pure-cubic theorem with a factor \(36C\); by the v8 homogeneous extraction plus imported Q2, it would extend to all degree-three bounded scalar functions.

**Logical warning:** (L1) is a *necessary* condition for a bounded scalar cubic and may describe more general Hilbert-valued link families that are not themselves realizable by a bounded scalar \(f\). Therefore LE(C) is a *sufficient, potentially strictly stronger conjecture*, not an established equivalent characterization.

## Why the old methods stop here

- The elementary \(L^2\)-Hilbert quadratic influence theorem pays output-rank; treating \(\bigoplus_aH_a\) as one unstructured Hilbert output loses the rank-independent objective.
- The new pointwise \(\ell_1\) constraint is stronger than an \(L^2\) output-ball constraint. It comes from a **single globally bounded scalar** and could remove the rank loss.
- Matching addresses independent B–C link increments; top-degree covers handle a few dominating A hubs; selector lifting handles distributed adaptive addressing. None currently proves LE(C) in the dense interlocking regime.
- No dimension-free conclusion may be inferred merely from weighted support energies: the [complete-hypergraph no-go](PROOF_ATTACK.md) shows exactly why.

## Cheapest decisive experiment and checker

First test LE(C) for small, fully independent product laws with one B-coordinate, one C-coordinate, and many A-linked output fibers, using direct exact rational evaluation. Minimize the ratio \(\mathcal M/(\mathcal V/B_0)^2\) over coefficient arrays; compare sparse matching, single-hub, and distributed selector cases. Then add a genuine proof attack at arbitrary skew masses.

The [exact link sanity checker](checks/tripartite_link_exact.py) verifies the displayed necessary \(\ell_1\) and influence accounting identities for a six-bit 3-partite example with two fair A coordinates and biased B/C coordinates. It does **not** test the conjecture universally.

**Status:** representation and identities analytically proved; LE(C) OPEN; no independent human proof review; no publication/novelty claim.
