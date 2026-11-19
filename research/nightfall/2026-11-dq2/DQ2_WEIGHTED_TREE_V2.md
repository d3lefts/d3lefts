# DQ2 v2 — dimension-free quadratic observability on weighted Ising trees

**Active research checkpoint, 2026-11-17.** Status: complete author-side analytic argument + independently implemented exact finite-instance tests; **NOT** an independently refereed theorem, Lean certificate, novelty certificate, or submission. Supersedes the homogeneous assumptions in [DQ2 v1](DQ2_DEPENDENT_TREE_V1.md), while preserving that version's proofs, chains, and limitations.

## Objective and comparison

Extend the existing bounded degree-two **uniform-product** variance/influence theorem to dependent spins on connected trees without an exponential global-density comparison. Focus on a reusable, operator-level dependence budget rather than polishing the numerical coefficient.

Input theorem (external proof dependency): for every bounded real polynomial on independent uniform signs of algebraic degree <=2,
\[
\operatorname{Var}_{\mu}(f)^2 \le K_0 B^2 \max_i\operatorname{Inf}_{\mu,i}(f).
\]
NIGHTFALL's finite Q2 source gives \(K_0=(2(1+\sqrt2)\sqrt3+11901/6250)^2\approx105.41624\), but use only the **finite** original theorem with its exact source and CI receipt; the integrated infinite-product Lake build is a separate task.

## Weighted-tree transfer theorem (analytic)

Let \(T=(V,E)\) be any finite tree. For each edge \(e=\{u,v\}\) choose a finite real interaction \(J_e\); set \(t_e=\tanh J_e\), \(r_e=|t_e|<1\). The zero-field Ising measure is
\[
\nu(x)=2^{-|V|}\prod_{e=\{u,v\}\in E}(1+t_e x_u x_v),\qquad x\in\{-1,1\}^{V}.
\]
All configurations have positive probability. Define the weighted path correlation
\[
w(u,v)=\prod_{e\in P(u,v)} r_e,\qquad w(u,u)=1,
\]
and the three explicit finite budgets
\[
S=\max_{u\in V}\sum_{v\in V}w(u,v),\quad
D=\max_{u\in V}\left(1+\sum_{e\ni u}\frac{r_e}{1-r_e}\right),\quad
H=\max_{u\in V}\sum_{e\ni u}\operatorname{arctanh}r_e.
\]
Let \(v_*=\operatorname{sech}^{2}H\). For every bounded algebraic degree-two polynomial
\[
f(x)=c+\sum_u a_u x_u+\sum_{u<v}b_{uv}x_ux_v,\qquad |f(x)|\le B,
\]
and native conditional-resampling influence
\[
\operatorname{Inf}_{\nu,i}(f)=\mathbb E_{\nu}\operatorname{Var}_{\nu}(f(X)\mid X_{V\setminus\{i\}}),
\]
one has, **conditional only on the existing uniform-product Q2 theorem**,
\[
\boxed{\operatorname{Var}_{\nu}(f)^2
\le K_0\,S^4D\,\cosh^2(H)\,B^2
\max_{i\in V}\operatorname{Inf}_{\nu,i}(f).}
\]

In a growing family of trees with uniformly bounded \(S,D,H\), this is dimension-free. No identical-coupling or degree bound is needed. It is a transfer for *algebraic quadratic functions of physical spins*, not an unspecified dependent-ANOVA notion of degree.

### Proof mechanism and checks (all-finite-tree argument)

**Step 1 — Independent edge innovations.** Choose a root \(X_o\) uniform on \(\{\pm1\}\). Along each edge \(e=\{u,v\}\), let \(Y_e=X_uX_v\) be an independent sign with mean \(t_e\). This gives exactly \(\nu(x)\), by tree reconstruction. Therefore \(\mathbb E X_i=0\),
\(C_{ij}:=\operatorname{Cov}(X_i,X_j)=\prod_{e\in P(i,j)}t_e\), and
\(X_iX_j=\prod_{e\in P(i,j)}Y_e\).

**Step 2 — Pair-path covariance.** For any two edge paths \(P,Q\),
\[
\operatorname{Cov}\bigl(\prod_{e\in P}Y_e,\prod_{e\in Q}Y_e\bigr)
=\Bigl(\prod_{e\in P\triangle Q}t_e\Bigr)
 \Bigl(1-\prod_{e\in P\cap Q}t_e^2\Bigr).
\]
If \(P\cap Q=\emptyset\), the covariance vanishes. Otherwise the intersection is an edge path. Give \(P\) direction \(i\to j\); the common edge path supplies a **unique compatible orientation** \(k\to l\) of the endpoints of \(Q\). The two disjoint end pieces give
\[
\prod_{e\in P\triangle Q}r_e
=w(i,k)w(j,l).
\]
Every nonzero \(Q\) maps to one ordered pair \((k,l)\). Thus each absolute covariance row of centered pair monomials has sum at most
\[
\sum_{k,l}w(i,k)w(j,l)
=\Bigl(\sum_k w(i,k)\Bigr)\Bigl(\sum_l w(j,l)\Bigr)\le S^2.
\]
The unique orientation is essential; one does not double-count each path.

**Step 3 — Restricted quadratic covariance operator.** The linear monomial covariance matrix has absolute row sum <=S, while the centered quadratic-monomial covariance matrix has absolute row sum <=S². Global spin-flip symmetry makes their cross covariance exactly zero. Symmetry + Schur's test gives
\[
\operatorname{Var}_{\nu}(f)\le
S^2\left(\sum_i a_i^2+\sum_{i<j}b_{ij}^2\right)
=S^2\operatorname{Var}_{\mu}(f),
\]
where \(\mu\) is the uniform independent-sign law. The constant term is irrelevant.

**Step 4 — Exact inverse covariance (positive definiteness).** The spin covariance matrix \(C\) is invertible and
\[
(C^{-1})_{ii}=1+\sum_{e\ni i}\frac{t_e^2}{1-t_e^2},\quad
(C^{-1})_{ij}=-\frac{t_{\{i,j\}}}{1-t_{\{i,j\}}^2}\ \text{if } \{i,j\}\in E,
\]
and all other off-diagonal entries vanish. Multiply this formula by \(C_{ij}=\prod_{e\in P(i,j)}t_e\); the unique first neighbor on the path cancels every off-diagonal entry (valid even if a \(t_e=0\)). The absolute row sum is at most
\[
1+\sum_{e\ni i}\frac{r_e^2+r_e}{1-r_e^2}
=1+\sum_{e\ni i}\frac{r_e}{1-r_e}\le D.
\]
Therefore the minimum eigenvalue of \(C\) is at least \(D^{-1}\); the same lower bound holds on every principal submatrix.

**Step 5 — Physical-coordinate influence transfer.** Given all other spins,
\[
\operatorname{Var}_{\nu}(X_i\mid X_{-i})
=\operatorname{sech}^2\left(\sum_{e=\{i,j\}\ni i}J_e X_j\right)
\ge \operatorname{sech}^2 H=v_*.
\]
Writing \(g_i(X_{-i})=a_i+\sum_{j\ne i}b_{ij}X_j\), algebraic quadraticity gives
\(\operatorname{Inf}_{\nu,i}(f)=\mathbb E[\operatorname{Var}(X_i\mid X_{-i})g_i^2]\).
By zero spin means and Step 4,
\[
\mathbb E_\nu g_i^2\ge D^{-1}(a_i^2+\sum_{j\ne i}b_{ij}^2)
=D^{-1}\operatorname{Inf}_{\mu,i}(f).
\]
Hence \(\operatorname{Inf}_{\nu,i}(f)\ge v_*D^{-1}\operatorname{Inf}_{\mu,i}(f)\).

**Step 6 — Composition.** Apply Step 3, square, use the pre-existing product Q2, then Step 5:
\[
\operatorname{Var}_{\nu}(f)^2
\le K_0 S^4(D/v_*)B^2\max_i\operatorname{Inf}_{\nu,i}(f).
\]
This is the displayed theorem. No finiteness-dependent factor appears except through the explicit dependence budgets.

## Recovering and improving the homogeneous case

For homogeneous \(|\tanh J|=r\) and maximum degree at most \(d\ge2\), the sufficient condition \((d-1)r<1\) gives
\[
S\le1+\frac{dr}{1-(d-1)r},\qquad
D\le1+\frac{dr}{1-r},\qquad H\le d\operatorname{arctanh}(r).
\]
For a chain \(d=2\), this simplifies to
\(S=(1+r)/(1-r)\),
\(D=(1+r)/(1-r)\),
and \(\cosh^2 H=(1+r^2)^2/(1-r^2)^2\),
hence the exact v1 multiplier
\(F_{\rm chain}(r)=(1+r)^3(1+r^2)^2/(1-r)^7\).
At \(r=0\), every bound collapses to the independent-product coefficient \(K_0\). Varying signs and zero couplings are fully permitted in this weighted statement.

## Exact tests, provenance, and negative controls

- Weighted-tree independently implemented rational checker: 4 differently shaped finite trees (sizes 5,7,7,8), with mixed positive, negative and zero edge correlations, 32 random quadratic coefficient assignments, direct conditional-coordinate influences, and exact pair-product covariance identities. **PASS**. Source SHA-256 \`0ccd1ab4ebfa02d03bad69f76420b24ac178b981df68fa0e17cf8d43926bec3e\`; result SHA-256 \`cd4fcbc30881b2ffcdc1b98a7aebb338ed0c3e9762de8c3d3691751c4b3c21e0\`.
- V1 tests: chain rational replay (675 local influence inequalities), separate SymPy direct covariance audit (742 pairs), tree geodesic audit (4 structures × 2 parameters), independent same-session exact symbolic inverse precision audit. See V1 for exact source/results hashes.
- Failed initial tree-test parameter choice: a star of degree six tested at \(r=1/5\), violating strict \((d-1)r<1\); the test was corrected to \(r=1/6\). This was a test precondition error, not a counterexample to a theorem.
- The **symbolic proof is the all-size argument**. Computational test coverage cannot establish all-size validity. The proof has not been independently reviewed by an outside mathematician.
- A named dependent-tree Lean theorem, an all-modules pinned Lake integration build, and new exact theorem-specific kernel receipts are NOT yet present. Do not promote this artifact to Lean-certified status.
- Do not confuse \(S\), the susceptibility/path-correlation budget, with the local-covariance conditioning budget \(D\) or local uncertainty \(v_*\). The inequality degrades if any becomes unbounded.

## Independent criticism and next cheapest decisive test

1. Author-independent adversarial proof review: seek a tree/path counterexample to the **unique overlap orientation** assertion; seek a mismatch in the native leave-one-out conditional variance (no product-law substitution); confirm exact normalization of Q2's influence.
2. Lean certification interfaces in order: weighted tree sign/bond factorization; unique-path symdiff covariance; finite symmetric-matrix row norm lemma; exact weighted inverse covariance; conditional spin variance lower bound; existing finite Q2 theorem; final DQ2-TREE terminal.
3. Heterogeneous trees are handled; target loopy graphs next. Cycles break both independent edge innovations and unique-path indexing. Replacing those mechanisms—not coefficient polishing—is the key remaining research problem.
4. Compare carefully with Koehler–Lifshitz–Minzer–Mossel, *Influences in Mixing Measures* (STOC 2024), https://arxiv.org/abs/2307.07625 ; Chen–Chen–Zhang, *Discrete Isoperimetric Inequalities via Curvature* (2026), https://arxiv.org/abs/2609.24687 ; dependent Hoeffding decompositions (Il Idrissi et al., 2025). This search does not establish novelty or priority. General influence inequalities may already imply related claims.
5. Do not publish a novelty assertion or a purported Lean certificate without exact-source and independent review gates.

## Reusable transfer operator

The proof isolates a general condition: if a dependent law \(\nu\) and a reference product law \(\mu\) satisfy
\(\operatorname{Var}_\nu(f)\le\kappa\operatorname{Var}_\mu(f)\) on the quadratic sector and
\(\operatorname{Inf}_{\nu,i}(f)\ge\eta\operatorname{Inf}_{\mu,i}(f)\) for every quadratic \(f\),
then \(\operatorname{Var}_\nu(f)^2\le K_0 \kappa^2/\eta\, B^2\max_i\operatorname{Inf}_{\nu,i}(f)\).
For weighted trees \(\kappa=S^2\), \(\eta=v_*/D\). Preserving this operator/interface is more valuable than preserving a large numerical coefficient in isolation.
