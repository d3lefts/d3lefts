# Exact onset of detector orientation defects in causal phaseless sensing

**NIGHTFALL theorem candidate, 2026-11-22.** One proof-level structural advancement toward the same continuous physical-detector flagship, not a new research track or a phase-retrieval query-count theorem. All ordinary topology used here (connected images, covering-space lifts, real line-bundle holonomy) is classical. Novelty of the *causal history-space application* is not established. Independent non-author mathematical audit and Lean certification remain open.

**Source scope and dependencies:** PR #695 proves sharp unrestricted/fixed query counts, PRs #995/#1000 prove and audit the sharp \(2n-1\) count for *continuous oriented row selectors* at paper level using CCFH Remark 2.7. Existing draft PR #1047 supplies an explicit **attained-history** non-liftable normalized fourth detector and a zero-allowing non-liftable third detector. The present note proves these first possible stages are the **earliest possible**, without assuming any chronological independence of the first two rows.

## Theorem A. Every two-reading history space is contractible

Let \(n\ge1\), \(Q_1\in\mathrm{Sym}_+^n\) be an arbitrary constant positive semidefinite matrix, and let \(f_2:[0,\infty)\times\mathbb R^n\to\mathbb R\) be continuous and **even in its second variable**, \(f_2(t,-x)=f_2(t,x)\). (This includes \(f_2(t,x)=x^\top Q_2(t)x\) for every continuous PSD feedback \(Q_2\), of any rank or strength.)

For each input \(x\in\mathbb R^n\), its two-reading transcript is
\[
T_2(x)=\bigl(t=x^\top Q_1x,\ f_2(t,x)\bigr).
\]
Then the attained history set \(H_2=T_2(\mathbb R^n)\subseteq[0,\infty)\times\mathbb R\), in the subspace topology, is **contractible**. More explicitly, when \(Q_1\ne0\), choose any \(z\) with \(z^\top Q_1z=1\), and put
\[
q(t)=f_2(t,\sqrt t\,z)\quad(t\ge0).
\]
Then
\[
R_\lambda(t,y)=\bigl(t,(1-\lambda)y+\lambda q(t)\bigr),\qquad
0\le\lambda\le1,
\]
is a *strong deformation retraction* of \(H_2\) onto the graph of \(q\), which is homeomorphic to \([0,\infty)\). If \(Q_1=0\), \(H_2=\{0\}\times f_2(0,\mathbb R^n)\) is an interval and hence contractible.

**Proof.** Suppose \(Q_1\ne0\). For any \(t>0\), the quadratic level set
\[
L_t=\{x\in\mathbb R^n:x^\top Q_1x=t\}
\]
is homeomorphic (by diagonalizing the positive eigenvalues) to \(S^{r-1}\times\mathbb R^{n-r}\), where \(r=\operatorname{rank}Q_1\). If \(r\ge2\) it is connected. If \(r=1\), its two components are exchanged by \(x\mapsto-x\), and the evenness of \(f_2(t,\cdot)\) makes their images identical. In either case the image \(I_t=f_2(t,L_t)\subseteq\mathbb R\) is a connected subset and therefore an interval. For \(t=0\), \(L_0=\ker Q_1\) is connected and likewise gives an interval \(I_0\). The selected continuous section \(q(t)\) belongs to \(I_t\) because \(\sqrt t\,z\in L_t\); at zero the same holds because \(0\in L_0\). Hence each \(I_t\) contains the entire interval between its members and \(q(t)\), proving \(R_\lambda\) lands in \(H_2\) and is a continuous strong deformation retract onto the graph. Contractibility follows. If \(Q_1=0\), only t=0 occurs and \(\mathbb R^n\) is connected; its continuous scalar image is an interval. QED.

**Scope test:** The theorem requires the stage-two response to be even in the **actual signal**, not merely that an arbitrary transcript has two entries. It holds for PSD rank-one through full-rank \(Q_1,Q_2\) and arbitrary nonnegative causal gains. It also holds when the second reading is a continuous, nonlinear, even detector response. No compactness of the global history image and no external Borsuk–Ulam theorem are used.


### Adversarial edge case: contractible history can fail to be closed

Take n=2, Q1=e1e1ᵀ and the unit second row
\[
a_2(t)=\frac{(1,t-1)}{\sqrt{1+(t-1)^2}}.
\]
For each t≠1 the two chronological rows are independent, so the attainable y2 fiber at first output t is **all** [0,∞). At t=1 the second row becomes e1 and y2 is forced to 1. Consequently
\[
H_2=\bigl(([0,\infty)\setminus\{1\})\times[0,\infty)\bigr)\ \cup\ \{(1,1)\},
\]
which is **not closed** in the ambient plane: points \((1+1/k,0)\in H_2\) converge to (1,0) outside H2. A witness for each k is \(x_1=\sqrt{1+1/k}\), \(x_2=-k\sqrt{1+1/k}\), giving the second reading zero exactly.

Nevertheless \(q(t)=t/[1+(t-1)^2]\) is a continuous attained section, and the same vertical straight-line deformation \(R_\lambda\) contracts the entire nonclosed H2 onto its graph. This explicitly falsifies any attempt to replace Theorem A's contractibility proof by a blanket assertion that *all attainable history spaces are closed*. It also reinforces why the original #995 paper used **compact restricted histories** in the Tietze route, and why the independent genuine-prefix proof needs no such extension.

## Theorem B. Sharp earliest rank-one orientation defect

Assume \(n\ge2\). At every stage j, a *normalized physical rank-one detector selector* is a continuous map
\[
Q_j:H_{j-1}\longrightarrow\operatorname{Proj}_1(\mathbb R^n)
=\{ww^\top:\|w\|=1\},
\qquad y_j=x^\top Q_j(h)x.
\]

**(i) Impossibility before stage four.** The first **three** selectors \(Q_1,Q_2,Q_3\) must admit continuous signed-row lifts on their **own actual attainable histories**. This holds with no assumption that the first two sensing rows are independent at each history. Indeed \(H_0\) is a point, \(H_1=[0,\infty)\), and \(H_2\) is contractible by Theorem A; any continuous projector-valued map from these contractible spaces admits a continuous unit-vector lift under \(S^{n-1}\to\mathbb RP^{n-1}\), by the homotopy-lifting property of covering maps. **Do not infer or assume that every attainable \(H_2\) is locally path-connected:** the proved strong deformation retraction is enough. In detail, lift the line map along the graph of its continuous section \(q(t)\), which is a ray, and then lift the explicit vertical deformation homotopy \(R_\lambda\).

**(ii) Attainment at stage four.** There is a four-stage protocol in \(\mathbb R^2\) with the first three rows chosen continuously, all normalized, whose attained \(H_3\) supports a continuous normalized rank-one fourth selector with **no** continuous signed-row lift. Use the exact two-graph construction and winding loop in PR #1047 §3, choosing first \(x_1^2,x_2^2\), third \([(x_1+g(d_1,d_2)x_2)/\sqrt{1+g^2}]^2\), \(g=(d_1-2)^2+(d_2-2)^2-1\), and fourth projector P(0) on the + sheet and P(min(1,d_1,d_2)) on the − sheet. Both definitions agree on the sheet overlap but force inconsistent lift signs around the t∈[0,1] two-sheet loop. Padding the sensing vectors by zeros embeds the same example in every \(n\ge2\).

Thus **stage four is the exact earliest stage of a non-liftable normalized rank-one physical detector**, in any dimension \(n\ge2\). This concerns **existence of a nonorientable feedback selector**, not recovery or a new measurement optimum.

## Theorem C. If zero-gain rank-one detectors are permitted, the threshold drops to stage three

Let \(Q_j:H_{j-1}\to\mathrm{Sym}_+^n\) be continuous of rank ≤1 (allowing zero, and bounded trace), with stage-one Q1 a fixed nonzero rank-one detector. Then selectors at stages **one and two always have continuous signed-row factorizations**, while one can first fail at **stage three**.

**Proof of the lower stage.** \(H_0\) is a point and \(H_1=[0,\infty)\). For any continuous rank≤1 PSD \(Q_2\) on \(H_1\), set \(U=\{t:\operatorname{tr}Q_2(t)>0\}\). It is an open subset of the half-line and hence a disjoint union of intervals. The normalized eigenline of Q2 has a continuous unit lift on each component; combine the lifts with magnitude \(\sqrt{\operatorname{tr}Q_2(t)}\) and define a=0 at zero-gain histories. The norm tends to zero at each zero-gain history, so a is continuous even when infinitely many U-components accumulate. Thus Q2 always factors as aaᵀ.

**Sharp stage-three example.** First query the two coordinate squares in \(\mathbb R^2\), giving \(H_2=[0,\infty)^2\). Let \(z=(h_1-2,h_2-2)\), \(r=\|z\|_2\), and choose
\[
Q_3(h)=\frac1{2(1+r)}
\begin{pmatrix}r+z_1&z_2\\z_2&r-z_1\end{pmatrix}
\]
(and zeros off this 2×2 block if n>2). It is continuous PSD, rank≤1, and \(\operatorname{tr}Q_3=r/(1+r)<1\). At the centre (2,2) it vanishes. On a circle around the centre its normalized eigenline performs one half-turn and has no continuous signed lift. Consequently Q3 has no continuous global signed-row factorization. This is the construction in the PR #1047 discovery-space note, rewritten here to establish the exact stage threshold.

**Result:** permitting zero gain advances the earliest possible physical-vs-oriented regularity distinction from the fourth to the third query. It does **not** establish that a lower query count is achievable.

## Corollary D. Information-theoretic relevance and limits

The source-established continuous oriented-row phase retrieval bound implies the following necessary conditions in any exact, universal, causal, rank-one physical-detector recovery protocol with \(m<2n-1\):

- If normalized nonzero detector projectors are required, some **non-liftable** selector occurs at a stage \(j\ge4\). In particular any normalized physical-detector strategy with at most three queries is equivalent to an oriented-row strategy even though the selector regularity is specified only on attained histories.
- If rank≤1 PSD detectors may vanish, some **non-liftable** selector occurs at \(j\ge3\).
- These statements are **necessary only**. The four-query normalized and three-query zero-gain holonomy examples deliberately do **not** recover all input signs; no counterexample to the continuous oriented-row bound, nor a new optimal physical-detector query number, has been constructed.
- For the six-reading n=4 flagship, projective holonomy may first appear at stage 4 in a degenerate prefix, but if the first four rows are chronologically independent along all histories then the existing orthant-prefix lemma in PR #1047 pushes its first possible appearance to the **sixth** detector.

This gives a reusable, exact information/operator hierarchy: **attainable transcript topology precedes detector holonomy, and holonomy is a necessary (not sufficient) resource for beating the oriented-row bound.**

## Certification and originality boundary

**Proved here on paper:** Theorem A strong deformation retract, Theorem B earliest stage via exact existing construction, Theorem C earliest rank-drop stage, Corollary D conditional only on the already externally sourced continuous-row theorem. Elementary point-set topology, spectral theorem and double-cover lifting are classical. The first-three histories theorem should be independently checked for the rank-one first-level two-component case, the t=0 level, and arbitrary strength gains; the rank-loss row continuity proof should be attacked at accumulations of zero-gain components.

**Not claimed:** A Lean kernel theorem for Theorems A–C, human mathematical refereeing, worldwide priority, a universal all-dimensional query-count improvement in the physical-detector model, or an explicit six-reading R4 recovering policy.

**External prior-art spot check:** standard phase-retrieval surveys and CCFH 2019/2020 establish background but did not reveal this exact stage-onset statement in the limited search. Before calling any theorem original, search adaptive intensity sensing and topology of quotient measurement/history spaces with an independent specialist.

**Cheapest next decisive test:** attack the universal **six-reading n=4 normalized projector** case with stage-four/sixth-stage holonomy made explicit; do not run arbitrary parameter optimization or enlarge finite counting tables. In an oriented-row class, route formal proof dependency to existing PR #1032/#1037/#1041 instead of duplicating Lean work.

**Transfer:** the contractibility theorem A holds for any two causal scalar even responses after one PSD quadratic measurement, not only phase-retrieval rows. Thus it can constrain early feedback topology in adaptive sensing, active experiment design and nonlinear quadratic tomography. This is a *provable transfer of a topological fact*, not a claim those applications yield new reconstruction theorems.
