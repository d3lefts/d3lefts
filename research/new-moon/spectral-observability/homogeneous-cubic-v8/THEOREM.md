# NIGHTFALL v8 — Homogeneous-cubic reduction and energy-covered observability

**Date:** 2026-11-10 (America/New_York). **Status:** New analytic deduction, internally audited; *not* independently refereed or Lean-certified. All structural consequences importing v5's quadratic/linear-support influence theorem remain conditional on that source's correctness. **No unrestricted cubic exponent-two theorem is claimed.**

## Scope and notation

Let \(X=(X_i)_{i\in J}\) have an independent product law, and \(F\) be a strongly measurable real-Hilbert-valued random observable with \(\|F\|\le B\) almost surely. Write its Hoeffding–Efron–Stein decomposition as \(F=\sum_{k=0}^d F^{[k]}\), where \(F^{[k]}=\sum_{|S|=k}F_S\). Put \(V(F)=\mathbb E\|F-\mathbb EF\|^2\), \(I_i(F)=\mathbb E\|F-E_iF\|^2\), and \(M(F)=\sup_i I_i(F)\). All assertions below first apply to finite products; the measurable-product extension requires the finite-rectangle and posterior-selection arguments already identified as unrefereed in v5.

We import only the following quantitative analytical claims from the supplied v5 dossier, **not as newly proved facts here**:

- Q2: a bounded degree-2 observable with output covariance rank at most \(r\) obeys \(V\le (D B/a_r)\sqrt M\), where \(D=16(1+\sqrt3)\), \(a_r=\mathbb E_{u\in S^{r-1}}|u_1|\); its adaptive error \(\eta\) requires at most \(\lceil4D^2B^2/(a_r^2\eta)\rceil\) queries.
- Lk: a bounded degree-\(k\) observable whose **entire non-singleton support hypergraph is linear** (distinct supports meet in at most one coordinate) obeys \(V\le(C_kB/a_r)\sqrt M\) and admits \(\lceil2kC_k^2B^2/(a_r^2\eta)\rceil\) adaptive queries. The sharper supplied cubic constant is \(C_3=42+16(1+\sqrt2)+36\sqrt3\). We set \(C_1=C_2=D\) in the composite bounds.

## Lemma A — Uniform homogeneous coefficient extraction

For each \(0\le k\le d\), the homogeneous component satisfies
\[
\|F^{[k]}\|_{L^\infty(\mathcal H)}\le A_{d,k}B,\qquad A_{d,k}=\frac{2^k}{k!}\left(\frac{d!}{(d-k)!}\right)^2.
\]
For \(d=k=3\) the sharper Chebyshev-derived upper bound is
\[
\boxed{\|F^{[3]}\|_\infty\le32B.}
\]
**Proof.** Let \(N_t=\prod_i(E_i+t(I-E_i))\), \(0\le t\le1\), be the product resampling/noise semigroup. It is an \(L^\infty(\mathcal H)\) contraction and
\(N_tF=\sum_{j=0}^d t^jF^{[j]}\). For a unit output direction \(u\), the polynomial \(p_{x,u}(t)=\langle u,N_tF(x)\rangle\) is bounded by \(B\) on \([0,1]\). Repeated interval Markov inequalities give \(\|p^{(k)}\|_\infty\le2^k\prod_{j=0}^{k-1}(d-j)^2 B\); its \(t^k\) coefficient equals \(p^{(k)}(0)/k!\). Take the supremum over unit \(u\). For a cubic, the extremal leading-coefficient inequality on \([0,1]\), obtained by affine transformation of \(T_3\), is \(|[t^3]p|\le32B\). Countable essential support, common versions, and rational \(t\) extend the polynomial identity to completed measurable products at the level of \(L^2\) classes. \(\square\)

## Theorem B — The unrestricted cubic question reduces to pure cubic functions

Assume the following hypothesis for *all* arbitrary-law products and bounded pure degree-three observables \(H=H^{[3]}\), with the same scalar/Hilbert setting:
\[
\tag{PC3} V(H)\le C\|H\|_\infty\sqrt{M(H)}.
\]
Then every bounded scalar observable of degree at most three satisfies
\[
\boxed{V(f)\le\bigl(33D+32C\bigr)B\sqrt{M(f)}.}
\]
Conversely any universal degree-\(\le3\) inequality of this type contains (PC3) as a special case. Thus the existence of an alphabet-independent exponent-two bound for arbitrary bounded cubics is **equivalent up to universal constant loss** to its existence for bounded *homogeneous cubic* observables.

**Proof.** Put \(H=f^{[3]}\) and \(G=f-H\). Lemma A gives \(\|H\|_\infty\le32B\), \(\|G\|_\infty\le33B\), and \(\deg G\le2\). Orthogonality of the Hoeffding layers yields
\[
V(f)=V(G)+V(H),\quad I_i(f)=I_i(G)+I_i(H),\quad M(G),M(H)\le M(f).
\]
Apply Q2 to \(G\) and PC3 to \(H\) and sum. \(\square\)

This reduction is **not** a proof of PC3. It shows that mixtures and cancellation among lower degrees are not an independent obstacle: any counterexample sequence can be reduced to a bounded pure cubic sequence with altered absolute constants.

## Corollary B1 — All cubic *top supports* linear, lower supports arbitrary

Suppose the **cubic supports alone** form a linear 3-uniform hypergraph; the degree-one and degree-two supports are arbitrary and may overlap cubic supports in two coordinates. Let
\[
K_{\mathrm{top}}=33D+32C_3=33\cdot16(1+\sqrt3)+32[42+16(1+\sqrt2)+36\sqrt3]<6018.
\]
By Q2 and L3 applied to \(g\) and \(h\) from Theorem B, a Hilbert-valued rank-\(r\) observable obeys
\[
\boxed{V(F)\le K_{\mathrm{top}} B\,a_r^{-1}\sqrt{M(F)}.}
\]
The class is preserved under observations: fixing coordinates cannot introduce a new cubic support, and the remaining cubic supports are the original triples disjoint from the queried set. The ANOVA total-influence potential therefore yields **a single greedy full-output predictor** with
\[
\boxed{N\le\left\lceil6K_{\mathrm{top}}^2B^2/(a_r^2\eta)\right\rceil,
\quad \mathbb E\|F-\widehat F\|^2\le\tau_r+\eta.}
\]
This extends v5's globally linear-support class: it allows, for example, a nonzero quadratic support \(\{1,2\}\) to overlap a cubic support \(\{1,2,3\}\) in two coordinates. The bound is deliberately conservative in constants but has the optimal-order \(r/\eta\) dependence for fixed \(B\).

**Corollary B2 — A small *linearization deletion set* suffices.** When finite, let \(\ell_3\) be the smallest size of a vertex set \(T\) for which the surviving cubic supports \(\{S:|S|=3,\ S\cap T=\varnothing,\ F_S\ne0\}\) are linear. Query these \(\ell_3\) inputs first. All posterior sections have linear cubic top supports, with lower supports unrestricted, so the same certificate gives
\[
\boxed{N\le\ell_3+\left\lceil6K_{\mathrm{top}}^2B^2/(a_r^2\eta)\right\rceil,
\quad \mathrm{MSE}\le\tau_r+\eta.}
\]
When \(T\) hits *every* cubic support, use the much sharper quadratic constant instead, giving \(\ell_3+\lceil4D^2B^2/(a_r^2\eta)\rceil\). The parameter \(\ell_3\) can be small when a small dense overlapping core coexists with arbitrarily many disjoint linear cubic supports, even though the vertex cover number of *all* cubic supports is large.

**Exact status:** These are new analytic deductions **conditional on** the existing v5 Q2 and L3 analytical proofs. No independent expert has audited the composition, and the matching theorem it imports is not Lean certified. Neither corollary covers unbounded dense repeated-pair overlap without a small deletion set.

## Theorem C — Layerwise-linearity extension (larger than v5's global linear-support class)

Suppose \(F\) has degree \(\le d\) and covariance rank at most \(r\). For every \(k\ge3\), require *only* that distinct nonzero supports of \(F^{[k]}\) intersect in at most one coordinate. Impose **no linearity requirement across different levels**, nor between degree-two and higher interactions. Then, conditional on v5's Lk theorem,
\[
\boxed{V(F)\le\frac{B\sqrt{M(F)}}{a_r}\sum_{k=1}^{d} A_{d,k}C_k.}
\]
Moreover, for any \(\eta>0\), a deterministic adaptive algorithm can achieve \(\mathbb E\|F-\widehat F\|^2\le\eta\) using at most
\[
\boxed{N\le\sum_{k=1}^{d}\left\lceil\frac{2kd^2A_{d,k}^2C_k^2B^2}{a_r^2\eta}\right\rceil.}
\]
If output covariance has tail \(\tau_r\), project onto the first \(r\) output eigendirections and add \(\tau_r\) to the risk bound. Thus for fixed \(d\), \(\|F\|\le1\), rank at most \(r\), and \(0<\eta\le1/4\), the worst-case adaptive query order in this class is \(\Theta_d(r/\eta)\), using the additive degree-one lower bound from v5.

**Proof.** Lemma A bounds the range of each \(F^{[k]}\) by \(A_{d,k}B\). Each homogeneous layer has a linear nonsingleton support hypergraph: for \(k=2\) this is automatic, and for \(k\ge3\) it is the hypothesis. Apply Lk separately to each layer. ANOVA orthogonality gives \(V(F)=\sum_{k\ge1} V(F^{[k]})\) and \(I_i(F)=\sum_{k\ge1} I_i(F^{[k]})\), so \(M(F^{[k]})\le M(F)\), proving the influence bound. For prediction, **run the adaptive policy for each homogeneous layer separately**, giving each layer MSE target \(\eta/d^2\); repeated queries can be reused. The triangle inequality in \(L^2(\mathcal H)\) bounds the total root error by \(\sum_k\sqrt{\eta/d^2}=\sqrt\eta\). The displayed sum of query caps follows. This separate-layer protocol is essential: arbitrary conditioning can destroy layerwise linearity of the combined observable. \(\square\)

**Strictness / negative control.** On four or five fair signs, \(f=(X_1X_2X_3+X_1X_2X_4X_5)/2\) has one cubic and one quartic support, so each homogeneous layer is linear. The two supports intersect in \(\{1,2\}\), violating v5's global linearity. After observing \(X_5=1\), the posterior has cubic supports \(\{1,2,3\}\) and \(\{1,2,4\}\), which overlap in two coordinates. Consequently one cannot merely invoke the layerwise theorem at each posterior and run a *single* greedy potential; the theorem uses independent per-layer policies.

## Proposition C1 — Soft-cover influence certificate

For a bounded scalar degree-three observable, every fixed coordinate set \(T\) satisfies the **quantitative variational inequality**
\[
\boxed{V(f)\le33D B\sqrt{M(f)}+|T|M(f)+W(T),\qquad
W(T)=\sum_{\substack{|S|=3\\S\cap T=\varnothing}}\|f_S\|_2^2.}
\]
Here \(D=16(1+\sqrt3)\) comes from Q2. **Proof.** Set \(f'=\mathbb E[f\mid X_{J\setminus T}]\); it is bounded by \(B\), and its cubic part is the sum \(H_T\) indexed by triples disjoint from \(T\). Lemma A gives \(\|H_T\|_\infty\le32B\), so \(g=f'-H_T\) is quadratic and bounded by \(33B\). The orthogonal ANOVA decomposition yields \(V(f')=V(g)+W(T)\), and each \(I_i(g)\le I_i(f')\le I_i(f)\). Q2 bounds \(V(g)\le33DB\sqrt M\). Finally
\[
V(f)-V(f')=\sum_{S:S\cap T\ne\varnothing}\|f_S\|_2^2\le\sum_{i\in T} I_i(f)\le |T|M.
\]
Combining gives the result. The same statement with the first term divided by \(a_r\) holds for a rank-\(r\) Hilbert output, conditional on Q2's Hilbert lift. \(\square\)

This is a genuine quantitative extension of an **exact** cubic vertex cover: it gives a certificate for a *partial* energy cover, not just for eliminating every cubic edge. It is not by itself a universal exponent-two proof: large residual \(W(T)\) or large \(|T|M\) can remain. A sufficient structural lemma for the unrestricted conjecture would uniformly find \(T\) with \(|T|\lesssim B/\sqrt M\) and \(W(T)\lesssim B\sqrt M\); existence of such a lemma is still unproved.

## Theorem D — Soft cubic energy covers give quantitative adaptive prediction

Suppose \(\deg F\le3\), \(\|F\|\le B\), and choose an output projection \(P_r\) onto the first \(r\) centered covariance eigendirections. Let \(\tau_r\) be the excluded covariance trace and, for a fixed set \(T\) of \(h\) input coordinates, define the uncovered top-degree energy
\[
W_r(T)=\sum_{\substack{|S|=3\\S\cap T=\varnothing}}\|(P_rF)_S\|_{L^2}^2.
\]
Then, conditional on Q2, there is a deterministic adaptive whole-coordinate predictor which uses at most
\[
\boxed{h+\left\lceil\frac{4D^2(33B)^2}{a_r^2\eta}\right\rceil}
\]
queries and achieves
\[
\boxed{\mathbb E\|F-\widehat F\|^2\le\tau_r+\bigl(\sqrt{W_r(T)}+\sqrt\eta\bigr)^2.}
\]
If \(W_r(T)=0\), the improved budget is \(h+\lceil4D^2B^2/(a_r^2\eta)\rceil\) and risk is \(\tau_r+\eta\).

**Proof.** First reveal all \(X_T\). For every nonexceptional transcript \(x_T\), the posterior section \(P_rF(x_T,\cdot)\) is bounded by \(B\), degree \(\le3\), and its *entire* order-three Hoeffding component relative to the unqueried coordinates equals the same function
\(H_T=\sum_{|S|=3,S\cap T=\varnothing}(P_rF)_S\), independent of \(x_T\). By Lemma A, \(\|H_T\|_\infty\le32B\). The remaining \(G_{x_T}=P_rF(x_T,\cdot)-H_T\) has degree \(\le2\) and \(\|G_{x_T}\|_\infty\le33B\). Use Q2 to predict \(G_{x_T}\) with conditional mean-squared error at most \(\eta\), uniformly in the transcript, within the displayed query cap. The projected difference from \(F\) is \(H_T+(G_{x_T}-\widehat G_{x_T})\); the \(L^2\) triangle inequality yields the square-root risk bound, since \(\|H_T\|_{L^2}^2=W_r(T)\). Predict the excluded output by its known mean; output orthogonality adds at most \(\tau_r\). If \(H_T=0\), predict the unmodified bounded quadratic section directly. \(\square\)

**Warning:** the stronger naive additive error \(\tau_r+W_r(T)+\eta\) is not justified for arbitrary adaptive algorithms. Their transcript-dependent predictors need not remain orthogonal to the cubic tail. The attached rational negative control exhibits this failure. The squared sum of root errors above is the correct general estimate.

**Corollary: optimal-energy cover profile.** Let \(W_r^*(t)=\min_{|T|\le t}W_r(T)\), \(W_0=W_r(\varnothing)\). Greedily add the coordinate with largest currently uncovered cubic energy. After \(h\) steps the resulting set \(T_h\) satisfies, for every integer \(t\ge1\),
\[
\boxed{W_r(T_h)\le W_r^*(t)+(1-1/t)^h\bigl(W_0-W_r^*(t)\bigr).}
\]
This follows because each uncovered cubic support contributes its energy once to each incident coordinate. The weighted hypergraph coverage function is monotone submodular; among the \(t\) vertices of an optimal set, at least one captures \((W_r(T)-W_r^*(t))/t\) of the current uncovered energy. The recurrence proves the claim. Choosing \(h\gtrsim t\log(W_0/\varepsilon)\) gives \(W_r(T_h)\le W_r^*(t)+\varepsilon\), which inserts directly into Theorem D.

## Mechanism graph and exact gap

1. **Matching** handles each *linear homogeneous interaction layer*; coefficient extraction allows pair interactions and cross-degree overlaps to be arbitrarily complicated.
2. **Top-degree covers** handle concentrated cubic overlaps exactly, while weighted covers handle them approximately in energy. Neither requires bounds on leaf alphabet sizes.
3. **Selector lifting / disjoint modules** handle unbounded families of address structures where paying one coordinate per module would be wasteful; this separate input is recorded in repository PR #335 and is not reproduced as a general unrestricted theorem here.
4. The remaining homogeneous cubic case consists of **high-energy, densely overlapping repeated pairs without a small energy cover or a known selector-module decomposition**. No proof of universal \(V\lesssim B\sqrt M\) in this regime is supplied by these arguments.

## Verification obligations / status

- Newly checked algebra: noise-multiplier identity, Chebyshev cubic coefficient, exact ANOVA energy split, greedy energy-coverage recurrence, and the adaptive nonadditivity negative control (rational standalone checker).
- Imported and not independently externally certified: Q2; Lk and its Hilbert/rank transfer; arbitrary-measurable-product posterior selection; novelty.
- Next decisive test: find a bounded pure cubic with high normalized variance relative to \(B\sqrt M\) whose support has large energy-cover and linearization parameters, **or** prove a quantitative energy-structure lemma extracting matching/cover/selector pieces with valid uniform operator-norm control. Avoid uncontrolled projection onto arbitrary subsets of ANOVA supports; such projections need not preserve \(L^\infty\) bounds.

## Attribution

The foundational Boolean-cube influence result belongs to David Turturean, *A proof of the Aaronson–Ambainis conjecture* (arXiv:2611.09773, 2026). The quadratic and globally linear-support product-space bounds are imported from the NIGHTFALL v5 manuscripts and have not been independently expert-refereed. The top-cover selector result is reported in repository PR #335. Noise operators, Hoeffding projection, Markov/Chebyshev bounds, and weighted submodular coverage are standard mathematical tools; their combination and the exact deductions in this note require independent originality review.