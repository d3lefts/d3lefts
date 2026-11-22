# Sharp obstruction for full-rank continuous causal prefixes

**2026-11-22 · NIGHTFALL independent paper theorem and architecture falsifier.**
**Research status:** complete self-contained paper proof conditional only on the **classical ordinary Borsuk–Ulam theorem**, plus known existence of full-spark real frames. No new Lean kernel terminal, human referee, or historical priority clearance. This is a new *scope-strengthening result*, not a proof of the universal continuous physical-detector threshold.

**Why this belongs to the flagship:** The earlier projective-detector holonomy example in PR #1047, §4d, was realized after a first n **everywhere independent** sensing prefix and exposed a nonorientable detector at stage n+2. The result below proves that **no amount of such downstream holonomy can make this prefix architecture recover all signals with fewer than 2n−1 continuous readings**. This is a decisive negative result and forces a meaningful change of construction operator: **prefix rank degeneration is required, in addition to a detector lift defect, for any putative projectively continuous physical-detector saving.**

## Theorem 1: coordinate-square prefix obstruction, even for arbitrary continuous subsequent readings

Fix n≥2 and k≤n−2. Suppose the first n readings of an unknown z∈R^n are exactly
\[
d(z)=(z_1^2,\ldots,z_n^2),
\]
and the remaining k readings collectively define a **continuous** map \(G:\mathbb R^n\to\mathbb R^k\). G may depend causally on previous readings, may be nonlinear or sign-sensitive in z, and need not be a quadratic form, rank-one detector, or even response. Then
\[
z\longmapsto (z_1^2,\ldots,z_n^2,G(z))
\]
cannot distinguish all real signals modulo global ± sign. The bound is sharp: n−1 additional fixed squared-linear readings can be chosen so that all 2n−1 rows form a full-spark frame and universal recovery holds.

**Proof.** Fix u=e_n and embed the unit sphere \(S^{n-2}\subset\mathbb R^{n-1}\) in the first n−1 coordinates. For v∈S^{n−2}, let \(z_\pm=u\pm v\). Their first n coordinate squares coincide, and \(z_+\ne\pm z_-\) because u,v are nonzero and have disjoint supports. Define
\[
D:S^{n-2}\longrightarrow\mathbb R^k,\qquad
D(v)=G(u+v)-G(u-v).
\]
D is continuous, and \(D(-v)=-D(v)\). By ordinary Borsuk–Ulam, every continuous odd map \(S^{n-2}\to\mathbb R^k\) with k≤n−2 has a zero. At that v, G(z_+)=G(z_−), so the **entire** transcript collides. This does not depend on the causal structure or physical nature of the later k readings. For sharpness, generic n−1 additional rows together with the n coordinate rows form a real full-spark frame, which phase-retrieves by the classical complement property. QED.

**Key distinction:** The lower bound uses the *coordinate-square prefix*, NOT nonembeddability of the full cone in \(\mathbb R^{2n-2}\). General continuous even maps need not obey this architecture restriction; the latter matters at n=4 because the cone over RP³ embeds R⁶.

## Theorem 2: every continuously chosen, everywhere-independent n-reading causal prefix is exactly equivalent to coordinate squares by a sign-equivariant homeomorphism

Let \(a_j:H_{j-1}\to\mathbb R^n\) for 1≤j≤n be continuous causal signed-row choices, with
\[
y_j(x)=(a_j(y_1,\ldots,y_{j-1})\cdot x)^2.
\]
For **every actually attained** prefix history \((y_1,\ldots,y_{j-1})\), assume the first j chronologically selected rows are linearly independent. This is an everywhere-full-rank hypothesis, not merely generic independence.

Then (A) \(H_j=[0,\infty)^j\) for each j≤n, (B) the **signed causal reading map**
\[
\Phi:\mathbb R^n\to\mathbb R^n,\qquad
\Phi(x)_j=a_j(y_1(x),\ldots,y_{j-1}(x))\cdot x
\]
is an **odd homeomorphism**, and (C) the actual first n squared-output transcript is the ordinary coordinate-square map applied to \(\Phi(x)\).

**Proof of (A) by induction.** For j=1 the first nonzero row realizes any target y1≥0. Suppose every target nonnegative history of length j−1 is attained. Given arbitrary \(y_1,\dots,y_j\ge0\), each selected row in the prescribed chronology is therefore defined and the j×n matrix of those rows has full row rank. Solve the j equations
\[
a_i(y_1,\ldots,y_{i-1})\cdot x=+\sqrt{y_i},\quad i=1,\dots,j.
\]
Causal induction checks that the actual readings of this x equal the prescribed y_i. Thus H_j is the full orthant.

**Proof of (B) and (C).** For z∈R^n define the n×n matrix
\[
A(z)=\begin{pmatrix} a_1()\\ a_2(z_1^2)\\\vdots\\
a_n(z_1^2,\ldots,z_{n-1}^2)\end{pmatrix}.
\]
By (A) and everywhere independence, A(z) is invertible for **all** z. It is continuous and even in z. Set \(\Psi(z)=A(z)^{-1}z\); the inverse-matrix map is continuous on GL_n, so Ψ is continuous and odd. For x=Ψ(z), induction shows the actual signed readings equal z_1,...,z_n: the previous measured squares are z_i² and the currently selected row is the corresponding row of A(z), which satisfies its linear equation. Therefore Φ(Ψ(z))=z. Conversely for any input x, putting z=Φ(x), its chronological rows form A(z) and satisfy A(z)x=z; invertibility yields Ψ(Φ(x))=x. Hence Φ and Ψ are mutually inverse continuous odd maps. By definition y_j(x)=Φ(x)_j². QED.

**Application to any downstream measurements.** Let the remaining k scalar readings be **arbitrary continuous** functions of the actual input (as happens for any causal protocol with continuous physical detector selection on attainable histories). Conjugating the whole transcript by Ψ produces coordinate squares followed by some continuous \(G(z)\). Theorem 1 then forbids universal recovery when \(k\le n-2\).

This generalizes the elementary invertible **fixed**-basis change noted in merged PR #699: the coordinate transformation can now be **causal, nonlinear, and history-dependent**, while remaining an odd homeomorphism.

## Corollary 3: physical projectors require both topology and prefix rank loss to beat 2n−1

Consider a real causal intensity protocol with continuously selected **normalized nonzero rank-one PSD projectors** \(Q_j(h)\), defined only on their attainable histories. Suppose it recovers all input signals modulo ± in \(m\le2n-2\) readings.

**Necessary condition I — orientation defect.** Some projector choice has **no continuous signed unit-row lift** on its attainable history domain; otherwise PR #995/#1000's paper-level all-policy continuous-row theorem would contradict the measurement count. This is the previously recorded no-lift necessity in PR #1047; it is not restated as an independently new invention.

**Necessary condition II — early prefix rank degeneration.** The chronological first n chosen measurement lines **cannot** be linearly independent at every attainable prefix history. If they were, their histories would be full orthants by (A), so each physical projector choice at prefix steps 1,...,n lifts continuously on that orthant under the double cover \(S^{n-1}\to\mathbb RP^{n-1}\). The resulting signed row prefix satisfies Theorem 2. All later physical outputs are continuous even if their projectors are non-liftable. Theorem 1 forbids the supposed m≤2n−2 recovery. Hence there must exist a prefix 1≤j≤n and an actually attainable history for which the first j chosen measurement lines are linearly dependent.

**Dimension-four consequence.** No six-reading continuous physical-projector protocol in R⁴ with an everywhere-independent first four directions can recover all signals, even when its sixth projector has nontrivial holonomy on its attainable H5. The construction in PR #1047 §4d shows the sixth-stage holonomy is geometrically realizable after that full-rank prefix, but **this theorem proves the entire architecture cannot succeed with six readings**. Any successful six-reading protocol must allow first-four prefix degeneracy *and* contain a non-liftable projector selection. These two conditions are independent requirements and still not sufficient for recovery.

**Extension:** Theorem 1 and the latter part of Theorem 2 place **no rank or evenness assumptions on later scalar readings** other than continuity of their composite input map. Consequently the prefix-rank-degeneration necessity is stronger than a quadratic rank-one-specific argument. The orientation-defect condition remains tied to quadratic rank-one physical detector selection and the already established oriented-row lower bound.

## Independent proof attack and edge cases

1. **n=2:** S^(n−2)=S⁰ and k≤0; the theorem says two coordinate squares cannot identify (1,1) and (1,−1), while a third fixed row suffices. All definitions work.
2. **n=4, m=6:** select u=e4 and v∈S². The last two continuous output differences give an odd map S²→R²; BU forces a collision. The first four can be nonlinear adaptive signed rows if they form an invertible chronological matrix on *all* histories; the homeomorphism handles this without approximation.
3. **Zero entries / attainable histories:** (A) prescribes \(\sqrt{0}=0\); full row rank still permits solving. The inverse Ψ is continuous even across zero-support strata because each a_i is continuous on the entire attained orthant and A(z) remains invertible.
4. **No hidden global history extension:** (A) shows the prefix domains actually equal full orthants; later outputs are continuous compositions restricted to their actual domains, no Tietze application needed.
5. **Crucial limit:** rank independence at only a dense/generic set is NOT enough for the global coordinate homeomorphism. A single rank collapse may create nontrivial attained history topology. The theorem does not decide whether such a collapse can lead to successful sub-(2n−1) sensing.

**Certification gate:** paper-level proofs here, relying on ordinary Borsuk–Ulam (classical) and complement-property real frames (classical). Independently check continuous inverse and exact causal consistency; find counterexample to the claimed full-orthant premise if possible. No Lean-certified theorem, human proof review, exact same-model priority finding or breakthrough submission is claimed. Do not promote to a stronger result for arbitrary first n rank-one physical projectors **without** the everywhere-independent hypothesis.

**Next operator for the sole flagship:** in n=4 six readings, combine *forced early rank degeneration* with *nontrivial attained-history orientation holonomy*. This is a dramatically narrower structural search than merely asking whether a sixth non-orientable projector exists. Attempt to construct a universally recovering protocol with both phenomena; or prove rank degeneration itself forces a collision that no subsequent two scalar readings can remove. The present theorem eliminates the full-rank-prefix family but not the unrestricted model.
