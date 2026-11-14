# The source-level quadratic variance–influence inequality: complete analytic derivation

**NIGHTFALL v1.0 — research date 2026-11-13; repository integration 2026-11-14 UTC.**
**Research lead:** Devin J. Wright. AI-assisted derivation and checking.
**Certification tier:** complete **author-analytic mathematical proof**. This note is **not** a terminal Lean 4.36 proof, an independent human referee report, or an adjudication of novelty or priority. Neither a green local component nor the conditional scalar endpoint permits promotion of the original-source Q2 theorem. Scope is finite independent product probability laws.

## Formal objective and contract

Let \(I\) be a finite coordinate set, \(A_i\) finite nonempty alphabets and
\(\mu=\bigotimes_{i\in I}\mu_i\) with each \(\mu_i\) an arbitrary probability
law. Some symbols may have mass zero. All extrema below are taken over
\(A_i^+=\{a:\mu_i(a)>0\}\), so a function need only be bounded on the
positive-support Cartesian product. Assume \(B\ge0\), \(|f(x)|\le B\)
there, and the **genuine** Hoeffding/Efron–Stein degree of \(f\) is at
most 2 (pointwise on positive support, equivalently as an \(L^2(\mu)\)
source decomposition). Set
\[
V=\mathbb E_\mu(f-\mathbb E_\mu f)^2,\qquad
I_i=\mathbb E_\mu\operatorname{Var}_\mu(f\mid X_{I\setminus\{i\}}),
\qquad M=\max_{i\in I}I_i,
\]
with \(M=0\) for empty \(I\).

**Author-analytic theorem.**
\[
\boxed{V^2\le K_2 B^2 M,\quad
K_2=(10+2\sqrt2)^2(1+\sqrt3)^2
=1228.356323837227\ldots.}
\tag{Q2}
\]
The bound contains no dimension, alphabet-size, bias or minimum
positive-atom term. Equality cases and optimality of \(K_2\) are **not**
established. The exponent of \(V\) is 2; claiming a sharp *constant* is
unsupported.

The argument is **self-contained mathematically** with a short
independent-Hilbert fourth-moment expansion and elementary finite
product/conditional expectation operations. Statements about pinned Lean
scope appear **after** the proof and do not determine its validity.

## 1. Source representation and energy

Write the actual \(\mu\)-Hoeffding decomposition as
\[
f=m+\sum_i h_i(X_i)+\sum_{\{i,j\}}h_{ij}(X_i,X_j),
\quad
\mathbb E_{\mu_i}h_i=0,\quad
\mathbb E_{\mu_i}h_{ij}(\cdot,b)
=\mathbb E_{\mu_j}h_{ij}(a,\cdot)=0.
\tag{1.1}
\]
Canonical components can be derived by original-law conditional
expectations and finite Möbius inversion; no arbitrary pair kernels are
supplied. Put \(a_i=\sqrt{\mathbb E h_i^2}\),
\(e_{ij}=\mathbb E h_{ij}^2\). Exact product orthogonality gives
\[
V=\sum_i a_i^2+\sum_{\{i,j\}}e_{ij},
\qquad I_i=a_i^2+\sum_{j\ne i}e_{ij}.
\tag{1.2}
\]
Thus \(a_i^2\le M\), \(e_{ij}\le M\), and \(M=0\)
implies \(V=0\). The remainder assumes \(M>0\).

## 2. The actual-source matching amplitude lemma

Define
\[
w_{ij}=\max_{a\in A_i^+,b\in A_j^+}|h_{ij}(a,b)|.
\]
For any matching \(R\) of disjoint pairs, prove
\[
\sum_{\{i,j\}\in R}w_{ij}\le4B.\tag{2.1}
\]

Choose a supported maximizer \((a_0,b_0)\) of each \(|h_{ij}|\).
Separate centering yields the **exact rectangle identity**
\[
h_{ij}(a_0,b_0)
=\mathbb E_{A',B'}
[h_{ij}(a_0,b_0)-h_{ij}(A',b_0)
-h_{ij}(a_0,B')+h_{ij}(A',B')].
\]
Consequently there is a supported rectangle of absolute size at least
\(w_{ij}\); reversing one endpoint's orientation makes its signed
rectangle \(\Delta_{ij}\ge w_{ij}\).

Independently choose \(U_e\in\{0,1\}\) uniformly for each \(e\in R\).
In an **even** state choose endpoint values \((a_{U_e},b_{U_e})\);
in an **odd** state choose \((a_{U_e},b_{1-U_e})\).
All unmatched coordinates are fixed to arbitrary supported values.
The one-site marginals of all coordinates are equal in both states,
and distinct edge bits are independent. Hence every singleton and
nonmatching pair interaction contributes identical expectations. Only
the chosen matched pairs contribute, each \(\Delta_e/2\).
Both experiments are distributions on the *actual source support*,
not on \(\mu\) itself, and boundedness of \(f\) applies to both.
Thus
\[
2B\ge|\mathbb Ef_{\rm even}-\mathbb Ef_{\rm odd}|
=\frac12\sum_{e\in R}\Delta_e
\ge\frac12\sum_{e\in R}w_e,
\]
which proves (2.1) without a prior global energy oracle.

Greedily select nonzero edges in decreasing order of \(w_{ij}\),
accepting an edge only if both endpoints are still free. Assign its
weight to **both** selected endpoints and assign zero to any
never-selected endpoint. The resulting \(c_i\ge0\) obey
\[
\sum_i c_i\le8B,\qquad
w_{ij}\le\max(c_i,c_j)\le\sqrt{c_i^2+c_j^2}.
\tag{2.2}
\]
Indeed, an unselected edge conflicts with an earlier accepted edge of
at least its weight, and (2.1) bounds the selected matching.

## 3. Fractional ownership on original coordinates

For \(i\ne j\), put
\[
\lambda_{ij}=
\begin{cases}
c_i/\sqrt{c_i^2+c_j^2},&c_i^2+c_j^2>0,\\
0,&c_i=c_j=0.
\end{cases}
\]
If \(w_{ij}=0\) then \(e_{ij}=0\). For every edge with
\(e_{ij}>0\), (2.2) implies \(c_i^2+c_j^2>0\) and therefore
\[
0\le\lambda_{ij}\le1,\qquad
\lambda_{ij}^2+\lambda_{ji}^2=1,\qquad
\lambda_{ij}w_{ij}\le c_i.
\tag{3.1}
\]

For each original coordinate \(i\), use the finite-dimensional
**actual-source** Hilbert space
\(\mathcal H_i=L^2(A_i,\mu_i)\) and set
\[
U_i(a;X_{-i})=
f(X_{-i},a)-\mathbb E_{\mu_i}f(X_{-i},X_i)
=h_i(a)+\sum_{j\ne i}h_{ij}(a,X_j),
\]
\[
H_i(\cdot;X_{-i})=
\sum_{j\ne i}\lambda_{ij}h_{ij}(\cdot,X_j),\quad
s_i=\mathbb E\|H_i\|_{\mathcal H_i}^2,\quad
z_i=\mathbb E\|H_i\|_{\mathcal H_i},\quad
u_i=\mathbb E\|U_i\|_{\mathcal H_i}.
\tag{3.2}
\]
For **fixed \(i\)**, the vectors
\(Y_{ij}=\lambda_{ij}h_{ij}(\cdot,X_j)\) depend on distinct original
coordinates \(X_j\), are independent and mean zero as
\(\mathcal H_i\)-vectors, and have
\(\|Y_{ij}\|\le\lambda_{ij}w_{ij}\le c_i\) almost surely.
Pairwise orthogonality under \(\mu\) yields
\[
s_i=\sum_{j\ne i}\lambda_{ij}^2e_{ij}\le I_i\le M,\qquad
\boxed{\sum_i s_i=\sum_{\{i,j\}}e_{ij}}.
\tag{3.3}
\]
The sum identity holds because each nonzero pair energy is
allocated with squared endpoint coefficients summing to one.
We assert no independence **across different owners \(i\)**.

## 4. Genuine soft refresh is a contraction

For each \(i\), define a coordinate retention vector
\(r^{(i)}_i=1\), \(r^{(i)}_j=\lambda_{ij}\) for \(j\ne i\).
Let \(Q_r\) independently retain input coordinate \(j\) with
probability \(r_j\) or refresh it from **its actual source law**
\(\mu_j\). This is a finite convex mixture of original-product
conditional expectations. It is stationary and an
\(L^1(\mu;\mathcal H_i)\) contraction.

A separately centered singleton term has eigenvalue \(r_j\); a
separately centered pair term \(h_{jk}\) has eigenvalue \(r_jr_k\).
Their genuine-source eigenactions and finite linearity give
\[
\boxed{Q_{r^{(i)}}U_i=h_i+H_i.}\tag{4.1}
\]
No synthetic neighbor stream or owner-specific copy construction
appears. Since \(Q_r\) contracts the actual source expected norm,
\[
\mathbb E\|h_i+H_i\|_{\mathcal H_i}\le u_i.
\]
By the triangle inequality and
\(\|h_i\|_{\mathcal H_i}=a_i\),
\[
\boxed{z_i\le u_i+a_i.}\tag{4.2}
\]

## 5. Two direct original-source budgets

**(a) Switching budget.** Fix \(x\) in the positive-support product.
For each \(i\) choose a supported maximizer of
\(f(x_{-i},a)\). Independently switch each coordinate from \(x_i\)
to its chosen maximizer with probability \(t\in[0,1]\). Since
\(f\) has interaction degree at most two, the resulting expectation
\(q_+(t)\) is a polynomial of degree at most two. It obeys
\(|q_+(t)|\le B\) throughout \([0,1]\) and
\[
q_+'(0)=\sum_i
(\max_a f(x_{-i},a)-f(x)),\qquad
q'(0)=-3q(0)+4q(1/2)-q(1).
\]
Thus \(0\le q_+'(0)\le8B\). Repeating with supported minima gives
a total downward variation at most \(8B\). Therefore at **every**
supported \(x\),
\[
\sum_i\operatorname{osc}_{a\in A_i^+}f(x_{-i},a)\le16B.
\]
Finite weighted Popoviciu implies
\(\|U_i(\cdot;x_{-i})\|_{\mathcal H_i}
\le\frac12\operatorname{osc}_a f(x_{-i},a)\).
Integrating over the actual source gives
\[
\boxed{\sum_i u_i\le8B.}\tag{5.1}
\]

**(b) Additive budget.** With homogeneous original-law refresh
\(T_t=Q_{(t,\dots,t)}\) the exact eigenaction gives
\[
T_tf=m+tA+t^2P,\qquad A(x)=\sum_i h_i(x_i).
\]
For supported \(x,y\), put
\(r(t)=T_tf(x)-T_tf(y)=ut+vt^2\).
Since \(T_t\) is a Markov operator,
\(|r(t)|\le2B\) for \(0\le t\le1\).
For \(t_0=\sqrt2-1\),
\[
u=\frac{r(t_0)-t_0^2r(1)}{t_0(1-t_0)},\qquad
|u|\le\frac{2B(1+t_0^2)}{t_0(1-t_0)}
=4(1+\sqrt2)B.
\]
In the full Cartesian product support,
\(\operatorname{osc}A
=\sum_i\operatorname{osc}h_i\).
Weighted Popoviciu and \(a_i\le
\operatorname{osc}h_i/2\) imply
\[
\boxed{\sum_i a_i\le \alpha B,\quad
\alpha=2(1+\sqrt2).}\tag{5.2}
\]
By (4.2), \(\sum_i z_i\le(8+\alpha)B\).

## 6. Source-Hilbert fourth moment and interpolation

Fix \(i\). The independent, centered
\(\mathcal H_i\)-valued vectors \(Y_{ij}\) in §3 obey
\(\|Y_{ij}\|\le c_i\).
Let \(v_j=\mathbb E\|Y_{ij}\|^2\), so \(\sum_jv_j=s_i\).
Expanding the fourth power, all cross monomials in which an
independent centered vector appears linearly vanish:
\[
\mathbb E\|\sum_jY_{ij}\|^4
=\sum_j\mathbb E\|Y_{ij}\|^4+
2\sum_{j<k}v_jv_k+
4\sum_{j<k}\mathbb E\langle Y_{ij},Y_{ik}\rangle^2.
\]
Using \(\mathbb E\|Y_{ij}\|^4\le c_i^2v_j\) and
\(\mathbb E\langle Y_{ij},Y_{ik}\rangle^2\le v_jv_k\)
(Cauchy and source independence) gives
\[
\mathbb E\|H_i\|^4\le c_i^2s_i+3s_i^2.
\tag{6.1}
\]
The elementary \(L^1/L^2/L^4\) Hölder interpolation is
\(s_i^{3/2}\le z_i(\mathbb E\|H_i\|^4)^{1/2}\).
For \(s_i>0\), divide by \(\sqrt{s_i}\), then use
\(\sqrt{c_i^2+3s_i}\le c_i+\sqrt{3M}\).
For \(s_i=0\), the inequality is immediate. Thus
\[
\boxed{s_i\le z_i(c_i+\sqrt{3M}).}\tag{6.2}
\]

## 7. Exact terminal scalar closure

By (1.2), (3.3), (6.2),
\(a_i\le\sqrt M\), \(z_i\le\sqrt{s_i}\le\sqrt M\),
the endpoint budget (2.2), and the two source budgets,
\[
\begin{aligned}
V
&=\sum_i a_i^2+\sum_i s_i\\
&\le\sqrt M\sum_i a_i+\sum_i c_i z_i
 +\sqrt{3M}\sum_i z_i\\
&\le \alpha B\sqrt M+8B\sqrt M+
 \sqrt3(8+\alpha)B\sqrt M\\
&=(8+\alpha)(1+\sqrt3)B\sqrt M\\
&=(10+2\sqrt2)(1+\sqrt3)B\sqrt M.
\end{aligned}
\]
Squaring completes (Q2). The \(M=0\), \(B=0\), and empty-coordinate
cases are handled as above. **No global pair-star independence,
lower atom-size or auxiliary Q2 assumption was used in the analytic
chain.**

## Current pinned Lean certificate map, and the exact remaining gap

Lean 4.36.0-rc2 / pinned Mathlib (hashes in CI receipts), standard
axioms only \`Classical.choice\`, \`Quot.sound\`, \`propext\`.

- **Compiled:** 11 original-source soft noise/stationarity/singleton
  declarations in [draft #460](https://github.com/d3lefts/d3lefts/pull/460).
- **Compiled:** exact two-site original law, centered pair projection,
  pair eigenaction, finite true-source soft-star D1, distinct-neighbor
  orthogonality and pair-star squared-energy in
  [stacked draft #462](https://github.com/d3lefts/d3lefts/pull/462).
  See [the pinned passport](Q2_PINNED_PAIR_STAR_ENERGY_CERTIFICATE_20261113.md)
  for named run IDs and declaration scope.
- **Being checked / not yet promoted:** derived
  \`sourceDoubleCenteredPair\` from the actual input function \(f\),
  its two-sided centering and direct eigenaction; and a
  **conditional** scalar closure theorem with explicit budget
  hypotheses. A compiler pass for a conditional closure does not
  discharge those hypotheses.
- **Still requiring actual-source current-pin assembly:** identify
  the \`sourceDoubleCenteredPair\` table with the canonical
  Efron–Stein \(h_{ij}\) of arbitrary degree-two \(f\) (including
  supported zero-atom semantics); combine the global matching
  amplitude/greedy cover with source maxima; recompile the **original
  source** \(8B\) and \(\alpha B\) budgets; derive source-Hilbert
  fourth moments for weighted original coordinate stars; glue them
  into one theorem whose only substantive inputs are \(p,f,B\)
  and the genuine Efron–Stein degree bound.
- **Do not claim:** all-size terminal Lean Q2, arbitrary abstract
  measurable spaces, historical priority, independent specialist
  proof review, or optimality of the numerical constant.

**Cheap decisive formal experiment:** port only the named source
Möbius pair component and source-derived double-centered table
equivalence onto the new pin. If that cannot compose with the star
eigenaction and the actual-source source-energy identity, expose
the precise incompatible theorem type and stop rather than assuming
a representation/energy bridge.

## Independent audit and novelty

Independent criticism should reconstruct the matching parity
cancellation, verify source-supported extrema and the denominator-zero
case of \(\lambda\), attack the \(8B\) switching and
\(\alpha B\) additive budget against skewed finite laws and zero
atoms, and derive the Hilbert fourth moment without global owner
independence. Existing exact enumerators in this repository are
*falsification* evidence, not proof. Compare genuine theorem types
against classical bounded differences/variance, Hoeffding ANOVA,
fractional graph covers, product-noise operators, independent
Hilbert fourth-moment inequalities and the 2026 Turturean
Aaronson–Ambainis proof before asserting novelty.

**Stop rule:** No automatic promotion to kernel-certified, referee
validated or historically novel status without corresponding
source-hashed proof and independent human review.
