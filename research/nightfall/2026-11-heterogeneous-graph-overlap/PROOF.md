# Quadratic product influence without fair signs or atom-mass floors
## Edge-coloring, weighted deletion, and posterior-stable overlap certificates

**NIGHTFALL research checkpoint:** 11 November 2026.  
Research direction: Devin J. Wright. **Status:** finite-product analytic theorem with a self-contained proof using classical ANOVA/Popoviciu and matching/edge-coloring, independently tested exact finite identities. **NOT:** a proof of the unrestricted degree-two bound with a universal constant; external priority clearance; independent non-author referee review; or a Lean-verified integrated theorem.

### 0. Research objective and no-duplication reconciliation

Objective: control *simultaneous* quadratic interactions between arbitrary-law variables, with no fair control block and no minimum atom mass. A meaningful theorem must allow an unbounded number of inputs, large heterogeneous alphabets, and connected interaction networks. Success condition: a variance-squared maximal-influence bound with a constant depending on a transparent *structural interaction certificate* but neither total input dimension nor coordinate laws.

Checked repository branches #317, #327, #335, #347, #348, #349, #350, #354. Relevant upstream mechanisms: #327 hypergraph matching-amplitude lemma and finite Markov switching; #347 weighted deletion and bounded shared-control cores; #349 dense tripartite/Hadamard obstructions; #354 fair-sign and partially mixed-law Khintchine bounds. Unlike #354, **the theorem here requires no fair sign on either interacting side**. It permits arbitrary interactions of a bounded-edge-colorable graph (including long connected paths and cycles), or a finite collection of hubs plus such a residual. It does **not** solve the open fully dense graph case or certify the broader manuscript's unrefereed general matching/fourth-moment argument.

### 1. Exact setting

Let \(X_1,\ldots,X_n\) be independent variables on **arbitrary finite full-support probability spaces**, without a lower bound on any marginal mass. Zero-probability symbols may be deleted. Let \(f\) be scalar real, \(|f|\le B\), \(B>0\), and have Hoeffding/ANOVA degree at most two:
\[
f=c+\sum_i f_i(X_i)+\sum_{\{i,j\}\in E} f_{ij}(X_i,X_j).
\]
Every canonical component has zero conditional mean in each of its input coordinates, and distinct components are \(L^2\)-orthogonal.

Define
\[
V=\operatorname{Var}(f),\quad I_i=\mathbb E(f-\mathbb E_i f)^2,\quad M=\max_i I_i,\quad
G=(\{1,\ldots,n\},E).
\]
For an edge set \(E'\), \(\chi'(E')\) is the minimum number of matchings into which \(E'\) can be partitioned. It is zero for an empty graph. For a vertex set \(H\), write \(G-H\) for the graph induced on its complement.

### 2. Matching amplitude (complete independent proof)

**Lemma.** For every matching \(\mathcal M\subseteq E\),
\[
\boxed{\sum_{e\in\mathcal M}\|f_e\|_\infty\le4B.}\tag{M}
\]

For each \(e=\{i,j\}\), choose a pair of symbols \(x_e=(x_i,x_j)\) attaining \(|f_e(x_e)|=\|f_e\|_\infty\), and reverse signs in the following construction if needed. Since \(f_e\) is centered in each coordinate, for an independent \(y_e=(y_i,y_j)\) sampled from the respective marginals,
\[
\mathbb E_{y_e}\bigl[f_e(x_i,x_j)-f_e(x_i,y_j)
 -f_e(y_i,x_j)+f_e(y_i,y_j)\bigr]=f_e(x_e).
\]
Consequently some \(y_e\) gives an oriented mixed difference \(\Delta_e\) with \(|\Delta_e|\ge\|f_e\|_\infty\). Construct two probability distributions supported on the four corners \((x_i,x_j),(x_i,y_j),(y_i,x_j),(y_i,y_j)\): the even- and odd-parity distributions, each uniform on its two corners. Their single-coordinate marginals coincide, but the expectation of \(f_e\) differs by \(|\Delta_e|/2\), with orientation chosen in the favorable direction. Across disjoint matching edges, take independent products of the chosen even/odd experiments, and fix identical independent marginals outside the matching. Any other degree-\(\le2\) ANOVA term sees either at most one coordinate from each matched edge, or a pair not among the selected edges, so its expectation is the same in both experiments. Thus
\[
2B\ge\left|\mathbb E_{\rm even}f-\mathbb E_{\rm odd}f\right|
=\frac12\sum_{e\in\mathcal M}|\Delta_e|
\ge\frac12\sum_{e\in\mathcal M}\|f_e\|_\infty.
\]
No fair bits, anti-concentration, bounded fourth moment or minimum atom floor are used.

### 3. Additive projection bound

Let \(g=c+\sum_i f_i\). For each \(x\), introduce the degree-two Bernstein/ANOVA switching polynomial
\[
q_x(t)=\bigl[\prod_i(\mathbb E_i+t(\mathrm{Id}-\mathbb E_i))f\bigr](x)
=c+t\sum_i f_i(x_i)+t^2\sum_{e\in E}f_e(x_e).
\]
For \(0\le t\le1\) this is the expectation of \(f\) under independent partial coordinate resampling, hence \(|q_x(t)|\le B\). The exact degree-two interpolation identity
\[
g(x)=q_x(0)+q_x'(0)=-2q_x(0)+4q_x(1/2)-q_x(1)
\]
implies \(\|g\|_\infty\le7B\). For an additive scalar function bounded by \(A\), independence makes the sum of its coordinate-section range widths at most \(2A\). Popoviciu gives \(\sum_i\sqrt{\operatorname{Var}f_i}\le A\). Since \(\operatorname{Var}f_i\le I_i(f)\le M\),
\[
\boxed{\sum_i\|f_i\|_2^2\le7B\sqrt M.}\tag{A}
\]

### 4. New bounded-overlap theorem (all heterogeneous laws)

**Theorem 1 (edge-color certificate).** With \(\chi'=\chi'(G)\),
\[
\boxed{V\le(7+4\chi') B\sqrt M,\qquad
M\ge\frac{V^2}{(7+4\chi')^2B^2}.}\tag{1}
\]

**Proof.** Partition \(E\) into \(\chi'\) matchings. By (M),
\(\sum_{e\in E}\|f_e\|_\infty\le4\chi'B\).
Every edge satisfies \(\|f_e\|_2^2\le M\), because each of its two vertices has influence containing this nonnegative ANOVA energy. Hence
\[
\sum_{e\in E}\|f_e\|_2^2
\le\sqrt M\sum_e\|f_e\|_2
\le4\chi'B\sqrt M.
\]
Add the orthogonal additive energy bound (A). QED.

For a **bipartite graph**, König's line coloring theorem gives \(\chi'=\Delta\), the maximum graph degree. In particular, any connected path or even cycle, of arbitrarily many coordinates and entirely heterogeneous laws, satisfies \(\boxed{V\le15B\sqrt M}\) because \(\Delta=2\). A matching has \(\chi'=1\). For an arbitrary simple graph, Vizing gives \(\chi'\le\Delta+1\), providing a general bounded-degree result.

**Pure homogeneous quadratic refinement.** If \(c=0\) and \(f_i=0\) for all \(i\), no additive correction is needed:
\[
\boxed{V\le4\chi' B\sqrt M.}\tag{2}
\]
Thus a pure bipartite path/cycle has coefficient 8.

### 5. Weighted deletion and core-overlap parameter

For any vertex set \(H\subseteq[n]\), let \(g_H=\mathbb E[f\mid X_{[n]\setminus H}]\). It is bounded by \(B\) and its quadratic graph is \(G-H\), while
\[
V-\operatorname{Var}(g_H)
 =\sum_{S:S\cap H\ne\varnothing}\|f_S\|_2^2
 \le\sum_{i\in H}I_i(f).
\]
Consequently, without assuming \(|H|\) small,
\[
\boxed{V\le(7+4\chi'(G-H))B\sqrt M+\sum_{i\in H}I_i(f).}\tag{3}
\]
The weighted cost is a valid **instance-level** certificate, but may not be posterior-stable.

For a fixed structural \(H\) of cardinality \(t\), since \(I_i(f)\le M\le B\sqrt M\),
\[
\boxed{V\le(7+4\chi'(G-H)+t)B\sqrt M.}\tag{4}
\]
Define the **core-overlap certificate**
\[
\kappa(G)=\min_{H\subseteq[n]}\bigl(|H|+4\chi'(G-H)\bigr).
\]
Then
\[
\boxed{V\le[7+\kappa(G)]B\sqrt M.}\tag{5}
\]
This unifies arbitrary numbers of disjoint edges, arbitrarily long connected paths, bounded-degree graphs, and a fixed number of high-degree star hubs joined to such a residual. A star with thousands of leaves has \(\kappa\le1\); a long bipartite path has \(\kappa\le8\). The parameter is **not** universally bounded on all graphs; dense Hadamard/complete interaction cases remain outside the current proof.

### 6. Posterior-stable whole-coordinate prediction

**Theorem 2 (finite-product adaptive observation).** Let \(C_G=7+\kappa(G)\). There is a deterministic adaptive whole-coordinate observation rule, using conditional Efron–Stein influences, whose conditional-mean predictor has expected squared risk at most \(\eta>0\) after at most
\[
\boxed{N=\left\lceil\frac{4C_G^2B^2}{\eta}\right\rceil}\tag{6}
\]
queries (or after observing all coordinates, whichever comes first).

**Proof.** A positive-probability observation transcript fixes some coordinates and leaves the others independent with unchanged marginal laws. Degree cannot increase; the remaining quadratic support is an induced subgraph of \(G\). A fixed \(H\) that witnesses \(\kappa(G)\), restricted to remaining coordinates, continues to certify a cost \(\le\kappa(G)\). Every posterior retains \(|f|\le B\). Thus (5) applies at every reached posterior.

Let \(T=\sum_iI_i(f_{\rm post})\). Exact ANOVA gives \(V_{\rm post}\le T\le2V_{\rm post}\), hence \(M_{\rm post}\ge T^2/(4C_G^2B^2)\). The exact posterior identity for observing coordinate \(i\) is
\[
\mathbb E[T_{\rm next}\mid\text{transcript}]=T-I_i(f_{\rm post}).
\]
Query an index attaining \(M_{\rm post}\), with deterministic tie-breaking. Set \(p_s=\mathbb ET_s\), \(a=4C_G^2B^2\). Jensen gives \(p_{s+1}\le p_s-p_s^2/a\). Since \(0\le p_0\le2B^2<a\), reciprocals telescope to \(p_s\le a/s\) for \(s\ge1\). Expected posterior Bayes risk is at most \(p_s\), so \(s=N\) suffices. No runtime bound is asserted for computing the optimal coordinate.

For the connected bipartite path subclass (\(\Delta=2,\kappa\le8\)), **no number-of-coordinates or alphabet factor enters**:
\[
N\le\left\lceil\frac{900B^2}{\eta}\right\rceil.
\]

### 7. Sharp exponent, limits, and decisive next experiment

For any \(n\ge1\), let \(X_i,Y_i\) be independent fair signs and \(f_n=n^{-1}\sum_iX_iY_i\), a matching interaction graph. Here \(B=1\), \(V=1/n\), \(M=1/n^2=V^2\), showing the squared-variance exponent is **sharp in the theorem's class**. The proof itself never assumes fair signs; this is merely a sharpness witness.

**Cannot claim:** a universal numerical constant for all quadratic graphs; a verified improvement over a fully refereed arbitrary-law quadratic theorem; new priority for König, Vizing, Popoviciu, or the prior NIGHTFALL matching lemma; full arbitrary measurable-product and algorithmic runtime complexity. The unrestricted dense-graph case and two-arbitrary-law *unbounded overlapping* interaction networks are still unresolved by this mechanism.

**Audit:** an independent exact rational checker constructs heterogeneous biased categorical degree-two functions with multi-feature pair interactions on connected paths, cycles and hub networks; rederives every ANOVA component by direct conditional expectations; tests (M), \(\|g\|_\infty\le7B\), (1), (5), and all conditional ANOVA drift identities across 576 posterior transcripts/816 one-step decisions. Source-exact CI, independent reviewer proof criticism and dated prior-art review remain separate certification gates.

**Cheapest decisive next experiment:** Optimize the *weighted* edge-deletion certificate \(\sum_{i\in H}I_i\) and residual \(\chi'\) on the large Hadamard/interlocking instances from #349. If \(\kappa(G)\) diverges, which structural energy invariants replace **unweighted** edge chromatic number? Test an edge-energy weighted fractional-color/cover bound with a primal/dual LP, and independently attack it on random biased complete bipartite graphs. The goal is an unconditional bound uniform over dense overlaps; the present theorem does not supply one.

### Sources and attribution
- Classical König (1916), edge coloring of bipartite graphs: https://mathworld.wolfram.com/KoenigsLineColoringTheorem.html .
- Vizing (1964), edge coloring for simple graphs: https://ti.inf.ethz.ch/ew/lehre/GT05/lectures/PDF/lecturecf.pdf .
- Original finite-product matching amplitude and switching mechanism, NIGHTFALL: https://github.com/d3lefts/d3lefts/tree/main/research/nightfall/observability-publication .
- Related independent FAIR-control and mixed-law partial theorem: https://github.com/d3lefts/d3lefts/pull/354 .
- Dense cubic control/law-free proof attack: https://github.com/d3lefts/d3lefts/pull/349 .
- O'Donnell and Zhao (2016), decoupling of bounded low-degree polynomials: https://arxiv.org/abs/1512.01603 .
- Turturean (2026), general influence on uniform Boolean cube: https://arxiv.org/abs/2611.09773 .
