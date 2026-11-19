# NIGHTFALL / UE2 — exact small-interaction-component theorem

**Checkpoint 2026-11-17.** Author-side elementary proof, not independently peer-reviewed or kernel checked. This proves N-UE2(2,1) on one broad structured class; it is **not** unrestricted exponent two. Classical ingredients: Popoviciu and Efron–Stein tensorization.

## Theorem: a universal block-size coefficient independent of block count

Let \(\mu\) be any finite independent product probability law with arbitrary coordinate alphabets and zero-probability symbols permitted. Let \(S_1,\dots,S_t\) be disjoint coordinate sets, each with size at most \(r\ge1\), and suppose
\[
f(X)=c+\sum_{\alpha=1}^{t} g_\alpha(X_{S_\alpha})
\]
almost everywhere, where \(f\) is essentially bounded. Put
\[
B(f)=\frac{\operatorname{ess\,sup} f-\operatorname{ess\,inf} f}{2},
\quad V=\operatorname{Var}_\mu(f),\quad M=\max_i I_i(f),
\quad I_i(f)=\mathbb E[\operatorname{Var}(f\mid X_{-i})].
\]
Then **without any hypothesis on the degrees of the individual block functions**
\[
\boxed{\quad V^2\le r\,B(f)^2 M.\quad}
\]

### Proof

For block \(\alpha\), define \(B_\alpha=(\operatorname{ess\,sup} g_\alpha-\operatorname{ess\,inf}g_\alpha)/2\) and \(V_\alpha=\operatorname{Var}(g_\alpha)\). Independence of disjoint blocks gives
\[
V=\sum_\alpha V_\alpha,\qquad B(f)=\sum_\alpha B_\alpha.
\]
(The second identity holds for essential extrema in finite independent products, even with zero-mass symbols; all values are taken modulo the law.) Classical Popoviciu and Efron–Stein give
\[
V_\alpha\le B_\alpha^2,\quad
V_\alpha\le \sum_{i\in S_\alpha}I_i(g_\alpha)\le r M.
\]
Therefore \(V_\alpha\le B_\alpha\sqrt{rM}\), and
\[
V=\sum_\alpha V_\alpha\le \sqrt{rM}\sum_\alpha B_\alpha
=B(f)\sqrt{rM}.
\]
Squaring proves the theorem. No disjoint-block count, marginal atom floor, alphabet or dimension constant appears.

## Immediate consequence for the conjectures

For degree \(d\ge1\), **if every connected component of the hypergraph of nonzero canonical ANOVA supports has at most \(d^2\) coordinates**, then \(f\) decomposes over those components. Apply the theorem with \(r=d^2\) to obtain
\[
\boxed{\operatorname{Var}(f)^2\le d^2 B(f)^2 \max_i I_i(f).}
\]
This is exactly the extremal N-UE2(2,1) bound on that class. In particular, the unrestricted-looking cubic case is settled for any number of independent components of size at most **nine** coordinates, with no assumptions on how cubic edges overlap *inside* those components.

**Falsification filter:** If a finite-product \(d\)-degree counterexample to N-UE2(2,1) exists, then at least one connected ANOVA support component has size **strictly greater than \(d^2\)**. Merely tensoring or adding disjoint small networks cannot create a violation.

This is not new prior art in Efron–Stein tensorization; it is a scoped transfer of the classical inequalities and oscillation additivity into the active conjecture's sharp coefficient and hypergraph language. It is independent of the fixed-block empirical-mean Bernstein result: the latter excludes asymptotic violations for fixed-dimensional *connected* mean-field polynomials, whereas this result proves a finite exact inequality for arbitrary additively separated small components.

### Limits and next task

- The proof does **not** handle a connected component of size greater than \(d^2\), even if its function has degree \(d\).
- It does **not** imply a universal \(V^2\le d^2B^2M\) for all degree-\(d\) functions.
- Lean certification could use merged finite original-law Efron–Stein (#506) and source-variance tensorization; independent classical-prior-art comparison and non-author proof audit remain pending.
- Target connected cubic interaction hypergraphs with at least ten active coordinates and high overlap; test source-consistent selector charge there before making global claims.
