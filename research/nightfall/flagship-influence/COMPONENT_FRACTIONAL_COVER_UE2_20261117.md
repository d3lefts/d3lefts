# Componentwise Fractional-Cover Influence Inequality — a proved scoped frontier

**Research checkpoint:** 2026-11-17 Eastern. **Analytic theorem with an elementary finite-product proof (author-side), not Lean certified or independently reviewed; its novelty is not established.** It does NOT prove the unrestricted N-UE2(2,1), N-UE2(2), N-UE2(6), or unrestricted cubic theorem. Contribution is a reusable *component/tensorization reduction* and exact support certificate, based on standard ANOVA Parseval, Efron–Stein, Popoviciu, and LP duality.

## Theorem: arbitrary finite independent products, any real bounded function, any degree

Let \(\mu=\bigotimes_{i\in I}\mu_i\) be an independent product on a **finite** coordinate set \(I\), with arbitrary coordinate alphabets, biases and possible null atoms (everything interpreted under the actual law). Let \(f\in L^\infty(\mu;\mathbb R)\) and
\[
f=\mathbb Ef+\sum_{\varnothing\ne S\subseteq I}f_S,\qquad
W_S=\|f_S\|_{L^2(\mu)}^2 .
\]
Its **active Hoeffding hypergraph** has hyperedges \(\mathcal H=\{S:W_S>0\}\). Partition the active vertices into the disjoint connected components \(C_a\) of this hypergraph, and let \(\mathcal H_a\) denote the edges in \(C_a\).

For each component define its fractional vertex-cover number
\[
\tau_a^*=\min_{w_i\ge0}
\left\{\sum_{i\in C_a}w_i:
     \sum_{i\in S} w_i\ge1 \quad\forall S\in\mathcal H_a\right\},
\quad
\Theta(f)=\max_a\tau_a^*
\]
(with \(\Theta(f)=0\) for constants). Let \(B(f)=\inf_c\|f-c\|_\infty\), \(V(f)=\operatorname{Var}_\mu(f)\), and \(M(f)=\max_i\mathbb E_\mu[\operatorname{Var}(f\mid X_{-i})]\). Then:
\[
\boxed{\quad V(f)^2\le \Theta(f)\,B(f)^2\,M(f).\quad}\tag{CFCI}
\]
This is **not merely a degree-\(d\) theorem**: it applies to any finite-product bounded real \(f\), with its own support-dependent coefficient.

### Proof and exact operator mechanism

Write \(g_a=\sum_{S\in\mathcal H_a}f_S\). Each \(g_a\) is mean-zero and measurable on the disjoint coordinate block \(C_a\), so the \(g_a\)'s are independent, \(V=\sum_a V_a\), and their centered essential radii are **additive**:
\[
B(f)=\sum_a B(g_a),\qquad B(g_a)=(\operatorname{ess\,sup}g_a-\operatorname{ess\,inf}g_a)/2.
\]
This range identity is an exact consequence of independence (a finite product of near-extremal positive-probability events has positive probability), not an estimate from triangle inequalities.

For any feasible cover \(w^{(a)}\), genuine original-law Hoeffding orthogonality gives
\[
V_a=\sum_{S\in\mathcal H_a}W_S
\le\sum_{i\in C_a}w_i\sum_{S\ni i}W_S
=\sum_{i\in C_a}w_i\,I_i(f)
\le\Big(\sum_{i\in C_a}w_i\Big)M.
\]
Popoviciu's range/variance bound independently gives \(V_a\le B(g_a)^2\).
Therefore \(V_a^2\le\tau_a^*M B(g_a)^2\), i.e.
\(V_a\le B(g_a)\sqrt{\tau_a^*M}\). Sum across independent blocks and use the exact range identity:
\[
V=\sum_aV_a
\le \sqrt{\Theta(f)M}\sum_aB(g_a)
=B(f)\sqrt{\Theta(f)M}.
\]
Squaring proves (CFCI). Constants and empty supports are immediate. No flip/resampling normalization changes occur.

### LP dual certificate

Ordinary finite LP strong duality gives the equivalent fractional matching expression
\[
\tau_a^*=\max_{z_S\ge0}
\left\{\sum_{S\in\mathcal H_a}z_S:
\sum_{S\ni i}z_S\le1\quad\forall i\in C_a\right\}.
\]
A feasible cover alone is a *valid sufficient upper certificate* on the coefficient. Matching cover+packing objectives certify the exact optimal **cover cost**, not the mathematical priority or sharpness of the main UE2 conjecture. For example, the triangle edges \(\{01,12,02\}\) have cover \(w_i=1/2\) and packing \(z_S=1/2\), proving \(\tau^*=3/2\).

### Sharpness of the support-dependent factor 2

Take fair signs \(a,b,c,d\) and \(h=ac+ad+bc-bd\). Its only ANOVA edges are the complete bipartite graph \(K_{2,2}\). Its minimum fractional cover number equals **2** (a left-vertex cover of cost 2, matched by two disjoint-edge packing weights). Direct enumeration:
\[
B(h)=2,\quad V(h)=4,\quad M(h)=2,\quad
\frac{V(h)^2}{B(h)^2M(h)}=2=\tau^*.
\]
For any number of independent copies, \(f=\sum_t h_t\) still satisfies \(\Theta(f)=2\), and the same ratio 2 **exactly**, regardless of the number of coordinates. Thus the cover parameter in (CFCI) is sometimes quantitatively sharp and correctly tensorizes disconnected high-dimensional sums.

## New conditional closure and counterexample localization

**Sharp UE2 subtheorem, arbitrary degree:** If \(f\) has Efron–Stein degree \(\le d\) and EVERY connected ANOVA support component has \(\tau_a^*\le d^2\), then
\[
\boxed{\quad V(f)^2\le d^2 B(f)^2 M(f).\quad}
\]
This is the exact coefficient-one N-UE2(2,1) conclusion for this nontrivial structural family, including any number of disjoint components, heterogeneous products and overlapping interactions within components. In particular, *a single anchor coordinate intersecting every nonzero ANOVA support* yields \(\Theta=1\), no matter how many other coordinates/edges participate.

**Any finite-product counterexample to N-UE2(2,1) can be localized.** Since the sharp inequality tensorizes over disjoint independent blocks, failure for \(f\) implies a failing connected component \(g_a\). By (CFCI), such a component must also satisfy \(\tau_a^*>d^2\). Hence searches for valid counterexamples can restrict to **connected support hypergraphs with fractional vertex-cover cost greater than \(d^2\)**, rather than disconnected sums or small-cover geometries. This is a necessary condition for any counterexample, not a sufficient condition for one.

**Contrast with the hard Chebyshev class.** The bias-tuned Chebyshev near-extremizers have huge, highly connected support hypergraphs containing many nonzero singleton and pair components, so \(\tau^*\) grows with dimension. CFCI does not settle their finite-dimensional sharp inequality; it identifies the missing high-cover, range-cancellation mechanism without conflating it with a low-cover certificate.

### Arbitrary-index transfer for explicitly block-summable constructions

The same proof extends to a countable family of mutually independent disjoint-coordinate component functions \(g_a\) satisfying \(\sum_a B(g_a)<\infty\), with uniformly bounded cover costs and centered summands. Then \(\sum_a g_a\) converges essentially uniformly (since \(|g_a|\le2B(g_a)\)), the centered radius and variances are componentwise additive, and (CFCI) follows by finite partial sums. This is an **explicit block-summable subclass**, not a general infinite-product ANOVA decomposition or the unresolved all-degree source theorem.

## Exact computational audit and independent challenge

Run:
\`\`\`sh
python3 research/nightfall/flagship-influence/check_component_cover_ue2.py
\`\`\`
The checker separately computes all finite ANOVA components from conditional expectations, genuine original-law influences directly from conditional variances, exact support connectivity and range additivity, and tests supplied rational cover weights. Required exact fixtures: sharp degree-one additive blocks (\(\Theta=1\)), two Hadamard \(K_{2,2}\) blocks (ratio=\(\Theta=2\)), triangle fractional cover (\(\Theta=3/2\)), dense anchored cubic triples (\(\Theta=1\)), and heterogeneous nonbinary product blocks (\(\Theta=1\)). The script is a **regression check**, not an independent proof of the general theorem. An adversary should attack the range-additivity step, zero-probability supports, cross-component influences, and LP-cover direction.

## Relation to the open frontier / credit

- This theorem **does not imply any unconditional all-degree degree-only inequality**: \(\Theta(f)\) can exceed \(d^2\), even for degree one if calculated *globally* without components; the component maximum is essential.
- It does not solve the **source-consistent mean-coupled Q3** gate of merged provisional PR #799 / draft PR #803.
- Classical inputs: Efron–Stein/Hoeffding ANOVA orthogonality, Popoviciu, fractional cover/packing LP duality. No originality is claimed for those or for the elementary inequality absent dated expert review.
- New-to-repository reusable operator: **componentwise range tensorization + spectral fractional-cover certificate**, giving a fail-fast restriction on counterexample geometry and a quantitatively sharp certificate for selected large classes.
- Independent human proof review, Lean kernel formalization, full priority search and paper/submission authorization are **not performed** here. Do not promote this to an unrestricted UE2 theorem or to a novel competitive record.


## Further transfer to the parallel fair-cube cubic theorem (#807): weighted hybrid gate

**Conditional on the separate, author-side fair-cube Q3 bound in PR #807** (not an independent proof of that input): split a finite independent product into fair-sign coordinates \(F\) and arbitrary-law coordinates \(A\). Let \(f\) have degree \(\le3\), centered radius \(B\), original variance \(V\), and max original resampling influence \(M\). Let \(\mathcal H_A\) consist of the active ANOVA supports that meet \(A\). For **any feasible nonnegative fractional cover** of this subhypergraph, with weights \(w_i\) on arbitrary coordinates \(i\in A\) satisfying
\[
\sum_{i\in S\cap A}w_i\ge1\quad \forall S\in\mathcal H_A,
\qquad t_A=\sum_{i\in A}w_i,
\]
one has the source-preserving hybrid bound
\[
\boxed{
V\le \sqrt{152+48\sqrt2}\, B\sqrt M+t_A M
\quad\text{and}\quad
V^2\le\big(\sqrt{152+48\sqrt2}+t_A\big)^2B^2M .
}
\]
The same bound holds for fractional covers using *all* coordinates in \(S\) (not just \(S\cap A\)), though then \(t_A\) denotes the total weight. Every A-touching ANOVA component is assigned to the residual once, independent of its overlaps with fair coordinates.

**Proof:** \(g=E[f\mid X_F]\) is a fair-cube degree-\(\le3\) function with the same centered range bound and \(\max I_i(g)\le M\). Apply #807's sector theorem: \(\operatorname{Var}(g)\le \sqrt{152+48\sqrt2} B\sqrt M\). The orthogonal residual \(r=f-g\) has **exactly** the ANOVA supports meeting \(A\), so by the same fractional-cover/Parseval calculation \(\operatorname{Var}(r)=\sum_{S\in\mathcal H_A}W_S\le\sum_iw_i I_i(f)\le t_A M\). Orthogonality gives \(V=V(g)+V(r)\). Finally \(M\le V\le B^2\), so \(t_AM\le t_A B\sqrt M\).

**Quantitative transfer:** PR #807's existing v1.2 theorem has \(t_A=|A|\), obtained by putting weight 1 on every nonfair coordinate. Here the **fractional cover can be substantially smaller than \(|A|\)**. If all nonfair-touching active supports contain one distinguished arbitrary coordinate \(a_0\), then \(t_A=1\) independently of \(|A|\); the cubic bound is \(V^2<251 B^2M\) even with arbitrarily many nonfair coordinate laws. The original full-product sharp C=1 bound remains **OPEN**, and this mixed-law theorem still depends on the scoped fair-cube input.

**Independent audit obligation:** check that the fair projection's centered essential range and influences contract under the actual product law, especially for null atoms; then independently verify the fair-cube sector bound from #807. The fractional-cover step itself is unconditional elementary ANOVA algebra.
