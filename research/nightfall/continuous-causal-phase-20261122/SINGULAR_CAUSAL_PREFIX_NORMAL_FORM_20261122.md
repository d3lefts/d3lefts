# Exact singular-prefix normal form for continuous causal intensity sensing

**NIGHTFALL research, 2026-11-22. Status:** independently derived paper-level representation theorem, exact algebra and topology audit required before promotion; no Lean kernel theorem, external human referee, worldwide novelty claim or solved six-query recovery construction.

**Purpose:** Continue the already proved full-rank-prefix no-go in \`FULL_RANK_CAUSAL_PREFIX_BU_OBSTRUCTION_20261122.md\`. A six-reading \(\mathbb R^4\) continuous rank-one *physical detector* recovery, if possible at all, must suffer rank degeneration among its first four sensor lines *and* contain a non-liftable detector on an attained history space. The statement here localizes the **first possible rank degeneration at the nth reading**, when the first n−1 rows remain full rank. The mechanism is a singularity of the causal signed coordinate map and a "vertical-fiber pinch" in the attainable next-history set.

## Theorem S1: a global partial causal-coordinate homeomorphism

Let n≥2 and let \(a_j:H_{j-1}\to\mathbb R^n\) for j=1,...,n−1 be continuous causal row selectors, each with square reading \(y_j=(a_j(y_{<j})\cdot x)^2\). Assume the first j chronological rows are independent **at every actually attained (j−1)-history**, for each j≤n−1.

The earlier full-rank-prefix lemma gives \(H_j=[0,\infty)^j\) for all j≤n−1. Thus every choice of a signed previous-reading vector \(z\in\mathbb R^{n-1}\) defines a continuous full-row-rank matrix
\[
R(z)=R(d)=\begin{pmatrix}
a_1()\\a_2(d_1)\\\vdots\\a_{n-1}(d_1,\ldots,d_{n-2})
\end{pmatrix},\qquad d_i=z_i^2.
\]
Define the canonical minimum-norm particular solution
\[
x_0(z)=R(d)^\top\bigl(R(d)R(d)^\top\bigr)^{-1}z.
\]
Let \(w(d)\) be the **continuous unit kernel vector** obtained by normalizing the signed maximal-cofactor vector of \(R(d)\). Since R has rank n−1 everywhere, this vector never vanishes; its orientation is fixed by one ordered cofactor formula. It obeys \(R(d)w(d)=0\), \(\|w(d)\|=1\), and \(x_0(z)\cdot w(d)=0\).

Then
\[
\Xi:\mathbb R^{n-1}\times\mathbb R\to\mathbb R^n,\quad
\Xi(z,t)=x_0(z)+tw(d)
\]
is an **odd homeomorphism** (with the combined antipode \((z,t)\mapsto(-z,-t)\)). Its inverse sends an actual input x to (i) its chronological **signed** first n−1 row readings z and (ii) \(t=x\cdot w(z^2)\).

**Proof:** Both x0 and w are continuous because matrix inversion is continuous on full-rank matrices, and the normalized cofactor denominator is strictly positive. R depends only on squares d and is even in z; x0 is odd, w is even. For any prescribed (z,t), \(R(d)\Xi(z,t)=z\), and causal induction verifies the true first n−1 signed readings of \(\Xi(z,t)\) equal z. Conversely any input x has signed prefix z, so \(R(d)x=z\); subtracting x0(z) leaves a vector in the 1D kernel spanned by w(d), with coefficient \(t=x\cdot w(d)\). Hence the stated maps are mutually inverse and continuous. The oddness follows from x0(−z)=−x0(z) and w((−z)²)=w(z²). QED.

**Geometric transfer:** A continuously full-rank n−1-query prefix is an **odd, globally trivialized affine line fibration** over signed feedback coordinates, not merely a generic submersion. There are no orientation twists in the 1D kernel over the contractible signed coordinate domain. This is an exact normal form of *all* input signals, including zero histories.

## Theorem S2: exact attainable n-th measurement fibers and singularity locus

Choose a continuous nth signed row \(a_n(d)\) on the attained \(H_{n-1}=[0,\infty)^{n-1}\) (physical normalized projector choices also lift on this contractible domain). Under the homeomorphism of Theorem S1, the nth squared scalar reading is
\[
y_n=(\beta(z)+c(d)t)^2,
\quad
\beta(z)=a_n(d)\cdot x_0(z),
\quad
c(d)=a_n(d)\cdot w(d).
\]
Here \(c\) is continuous and \(\beta\) is continuous and **odd** in z, while \(c\) is even. The chronological n×n sensing matrix is invertible precisely where \(c(d)\ne0\), since the first n−1 rows span \(w(d)^\perp\).

Let \(H_n(d)\subseteq[0,\infty)\) denote the set of attainable nth squared readings for a **fixed prior magnitude transcript** \(d=(d_1,\ldots,d_{n-1})\). Then
\[
\boxed{
H_n(d)=
\begin{cases}
[0,\infty), & c(d)\ne0,\\[2pt]
\{\beta(s_1\sqrt{d_1},\ldots,s_{n-1}\sqrt{d_{n-1}})^2:
s_i\in\{\pm1\}\}, & c(d)=0.
\end{cases}}
\]
At the degenerate set \(D=\{d:c(d)=0\}\), the whole free line direction t becomes unobservable; the formerly full vertical [0,∞) fiber pinches to a finite set of **at most \(2^{n-2}\)** values (because the simultaneous sign flip z→−z negates β without changing β²; for n=2 the bound gives one). The singular set D is *exactly* the rank-drop set for the nth row relative to the first n−1.

**Proof:** For fixed d, any sign pattern z=s√d is realizable by S1, with the last input parameter t completely free. If c(d)≠0, \((\beta(z)+c(d)t)^2\) ranges over all nonnegative reals as t runs over \(\mathbb R\). If c(d)=0, the nth value no longer depends on t and is exactly the finite sign-pattern set displayed. Its size is at most 2^{n−2}, since the involution s→−s gives the same square, including repeated values when some d_i vanish. Finally, the nth row lies in the span of the first n−1 rows iff it is perpendicular to the unique complementary unit kernel w, i.e. iff c(d)=0. QED.

**No hidden closedness:** Even when every row selector is continuous, \(H_n\) need not be closed in the ambient nonnegative orthant. E.g. for n=2, take \(a_1=e_1\), \(a_2(d_1)=(1,d_1−1)/\sqrt{1+(d_1−1)^2}\). The singular set is D={1}; for d1≠1 the second-output fiber is [0,∞), but at d1=1 it is {1}. Therefore points \((1+1/k,0)\in H_2\) converge to (1,0) outside H2. This is the exact counterexample already documented in the holonomy-onset proof, and it shows why neither contractibility nor causal continuity implies global history-closedness.

## Consequence for the \(\mathbb R^4\) six-reading flagship

If a normalized physical-detector six-reading scheme starts with **three everywhere-independent** causal rows, then their attained prefix has a global S1 homeomorphism with \(z\in\mathbb R^3,t\in\mathbb R\). Its fourth detector **must be oriented liftable**, since H3 is the full orthant. The fourth reading has the exact S2 normal form with scalar \(c(d)\). If c(d) is nowhere zero, the full four-prefix is everywhere independent and the earlier Borsuk–Ulam no-go forbids six-query recovery, **even if the fifth and sixth detectors are non-orientable**. Consequently any successful six-reading scheme within this first-three-independent family must have a nonempty singular locus
\[
D=\{d\in[0,\infty)^3:c(d)=0\},
\]
where the attainable fourth-history fiber pinches from an interval to **at most four** values. A later projector may have nontrivial orientation holonomy only through the actual pinched history topology; whether such a projector can recover the remaining signs in just two scalar readings is still **OPEN**.

**Precisely what is ruled out:** all fixed-basis and all globally independent causal four-prefix architectures, irrespective of continuous nonlinear downstream outputs. **Not ruled out:** schemes with a rank-loss locus in the fourth row, or already in one of the first three, and downstream nonliftability. The current result is a structural representation and a decisively narrowed construction search, not a proof of universal impossibility.

## Adversarial audit checklist and provenance

- Validate the cofactor kernel identity and continuous normalization, including d_i=0 and n=2. Any singularity in the *first n−1* row matrix violates the theorem's assumptions; do not pretend this normal form applies there.
- Audit the causal inverse: the input Xi(z,t) must reproduce the **signed** prescribed row readings z, not just their squared values; the induction explicitly supplies this bridge.
- Check the scalar c(d) is exactly the determinant/rank-loss criterion, not merely sufficient. An n×n matrix with first n−1 independent rows has determinant 0 iff the nth row annihilates its unit kernel.
- Validate the finite-fiber cardinality bound \(2^{n-2}\): global antipodes pair sign patterns; zero coordinate duplications can only lower the count.
- Check trace-one physical projector selectors: on H_{n−1} orthant every such continuous selector has a signed unit-row lift; after the singular stage that assumption may fail.
- Only ordinary finite-dimensional linear algebra, covering lifts, and causal continuity used. All are classical mechanisms; novelty of their exact feedback-history synthesis requires specialist search.
- No new numerical parameter tuning, Lean package or duplicate parent PR. The cheapest decisive next experiment is to build or rule out a continuous projective fifth/sixth detector on one explicit pinched four-reading history domain with **universal** sign separation, including all zero/support boundary strata.

**Mechanism record:** Full rank → odd coordinate trivialization → quadratic rank collapse \(c(d)=0\) → vertical-fiber pinch / sign-sheet birth → possible projective detector holonomy → need actual all-signal recovery certificate or adversarial collision. All stages preserve their mathematical status and classical dependencies.
