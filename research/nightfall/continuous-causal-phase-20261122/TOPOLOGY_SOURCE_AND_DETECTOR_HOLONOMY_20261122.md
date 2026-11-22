# NIGHTFALL independent source reconciliation and oriented-row detector holonomy

**2026-11-22 | Independent source audit and scoped new construction.**
**Primary sources:** merged PRs [#995](https://github.com/d3lefts/d3lefts/pull/995) (original all-policy paper argument), [#1000](https://github.com/d3lefts/d3lefts/pull/1000) (independent non-author AI audit), [#997](https://github.com/d3lefts/d3lefts/pull/997) (genuine-prefix formulation), [#1008](https://github.com/d3lefts/d3lefts/pull/1008), [#1010](https://github.com/d3lefts/d3lefts/pull/1010), [#1015](https://github.com/d3lefts/d3lefts/pull/1015) (conditional Lean terminal integrated into main despite the source PR closed-unmerged), [#1024](https://github.com/d3lefts/d3lefts/pull/1024) (maximal zero padding), [#1030](https://github.com/d3lefts/d3lefts/pull/1030) (status reconciliation), [#1032](https://github.com/d3lefts/d3lefts/pull/1032), [#1034](https://github.com/d3lefts/d3lefts/pull/1034), [#1037](https://github.com/d3lefts/d3lefts/pull/1037), [#1041](https://github.com/d3lefts/d3lefts/pull/1041). The parallel investigations are credited and preserved rather than duplicated.

**Status separation:** The **universal continuous oriented-row** \(2n-1\) threshold now has a complete **paper-level proof using an externally published product-sphere theorem**, independently checked at the AI-instance level, and a separately kernel-checked **conditional** causal model. The product-sphere zero existence theorem is **not** proved in the current Lean dependency graph; the numerical probes do not prove it. Full specialist referee and same-model global novelty search are still open. This document supplies (i) the exact published-to-formal topology identification, (ii) a concise genuine-history proof audit, (iii) a concrete new **actual-history holonomy example** showing the physical quadratic-detector continuity model is strictly broader than oriented-row continuity, and (iv) a small geometry lemma localizing that distinction. Do not promote the new example to a new phase-retrieval query-count theorem.

## 1. Exact published source: CCFH Remark 2.7, not a guessed topology assumption

**Yu Hin Chan, Shujian Chen, Florian Frick, J. Tristan Hull**, *Borsuk–Ulam Theorems for Products of Spheres and Stiefel Manifolds Revisited*, arXiv:1902.00935v2, **2019-11-06**, journal *Topological Methods in Nonlinear Analysis* 55(2) (2020), 553–564, DOI 10.12775/TMNA.2019.103.
Primary PDF: https://arxiv.org/pdf/1902.00935, printed page 5, **Remark 2.7**, immediately following Theorem 2.5. This is also credited there to earlier Ramos/Fadell–Husseini/Dzedzej–Idzik–Izydorek theory.

The cited source **explicitly states**: every \(G=(\mathbb Z/2)^k\)-equivariant continuous map

\[
S^{n_1}\times\cdots\times S^{n_k}
\longrightarrow V_{\varepsilon_1}^{\oplus n_1}
\oplus\cdots\oplus V_{\varepsilon_k}^{\oplus n_k}
\]

has a zero, where \(V_{\varepsilon_j}\) is the real sign character in the \(j\)-th independent antipodal action. For the exact merged Lean predicate
\`Nightfall.ProductSphereObstruction.ProductSphereZero n (n-1) (n-1)\`, substitute \(k=2,n_1=n_2=n-1\), and the two target sign characters \(\varepsilon_1,\varepsilon_2\).
The theorem's domain and codomain, separate antipodal equivariance, continuity **on the sphere product only**, and simultaneous-zero conclusion match the frozen Lean interface. For \(r,s<n\), zero-pad the blocks to n-1 using the already kernel-checked #1024 reduction.

**This closes the *external paper-level topology dependency by exact source identification*.** It does not establish a **Lean proof** of the cited external theorem or that the phase-retrieval application is historically original. Distinguish the source mathematical argument (complete given CCFH) from current formalization status (conditional).

## 2. Direct actual-prefix reduction, independent source-level verification

For any continuous oriented-row policy \(a_j:H_{j-1}\to\mathbb R^n\), with \(H_{j-1}\) the **actually attainable** preceding transcripts, let \(T_j(x)\) be the actual causal squared-intensity transcript and let \(x_\pm=u\pm v\) for \(u,v\in S^{n-1}\). No norm bound on \(a_j\) is needed for the lower bound. (The fixed-frame upper can still use normalized rows.)

**Inductive source facts:** \(T_j:\mathbb R^n\to\mathbb R^j\) is continuous even though the selector is defined only on the attainable subset: composition is continuous in the subspace topology. Also \(T_j(-x)=T_j(x)\) because every reading is a square and both antipodes share their preceding history. Define

\[
h^\pm_{j-1}(u,v)=T_{j-1}(u\pm v),\qquad
b_j(u,v)=a_j(h^+_{j-1})+a_j(h^-_{j-1}).
\]

Under either independent sign flip \(u\mapsto-u\) or \(v\mapsto-v\), the two actual prefix transcripts \(h^+,h^-\) **exchange** (possibly with an overall minus sign on one input, harmless by transcript evenness). Hence \(b_j\) is continuous and invariant under each sign flip. Colour the \(m\le2n-2\) readings U/V so each colour has at most \(n-1\) stages; define \(f_j(u,v)=b_j(u,v)\cdot u\) for U, or \(f_j(u,v)=b_j(u,v)\cdot v\) for V. The U block is odd in u/even in v and the V block even in u/odd in v. The **exact CCFH zero theorem** supplies unit vectors u,v with all \(f_j=0\).

At that zero, prove actual transcript equality inductively. If \(T_{j-1}(x_+)=T_{j-1}(x_-)=h\), then \(b_j=2a_j(h)\). A U-zero says \(a_j(h)\cdot u=0\), so \((a_j(h)\cdot(u+v))^2=(a_j(h)\cdot(u-v))^2\); the V case is symmetric. Thus true stage-j readings agree, completing the induction. Since \(x_+-x_-=2v\ne0\) and \(x_++x_-=2u\ne0\), the two inputs are not equivalent modulo global sign. A fixed full-spark frame yields the matching \(2n-1\) upper bound.

**Result:** a complete paper-level proof of the exact \(\,m_{\rm cont}(n)=2n-1\) statement, n≥2, for the **continuous oriented-row** source model. This short intrinsic reduction is already present in parallel PRs #997 and #1015; **no new authorship or independent first-proof credit is claimed here**. It avoids Tietze and never evaluates a selector at an unreachable history.

## 3. New model-scope counterexample: physically continuous rank-one detector with no continuous row lift, on ACTUALLY attainable histories

A rank-one intensity sensor may be specified by a positive semidefinite, rank-one, trace-one matrix \(Q(h)\) whose measured output is \(x^\top Q(h)x\). Replacing a row \(a\) by \(-a\) has **no physical effect**. Thus the intrinsic regularity condition is continuity of \(Q:H\to\{aa^\top:\|a\|=1\}\cong\mathbb RP^{n-1}\), which need not admit a continuous **oriented** lift \(a:H\to S^{n-1}\). The following example realizes this issue on a genuine causal history space, not an abstract circle.

**Exact three-stage protocol in \(\mathbb R^2\).** Query first \(x_1^2=d_1\), then \(x_2^2=d_2\). Define

\[
g(d_1,d_2)=(d_1-2)^2+(d_2-2)^2-1,
\qquad
a_3(d)=\frac{(1,g(d))}{\sqrt{1+g(d)^2}},
\]

and query the squared output of \(a_3(d)\cdot x\). All three signed rows are globally continuous on their attained histories and have unit norm.

The **actual** attainable three-reading history set is the union of two graph sheets over the full quadrant \(B=[0,\infty)^2\):

\[
H_3=G_+\cup G_-,\qquad
G_\pm=\{(d_1,d_2,F_\pm(d)):d\in B\},
\quad
F_\pm(d)=
\frac{(\sqrt{d_1}\pm g(d)\sqrt{d_2})^2}{1+g(d)^2}.
\]

These are exactly the sign classes \(x_1x_2\gtrless0\). Their intersection is precisely where \(d_1=0\), or \(d_2=0\), or \(g(d)=0\). The circle \(g=0\) lies entirely inside the positive quadrant, with \(d_1,d_2\ge1\). Each graph is closed and connected.

Let
\[
\tau(d)=\min(1,d_1,d_2),\quad
v(t)=(\cos(\pi t),\sin(\pi t)),\quad
P(t)=v(t)v(t)^\top.
\]

Define the *fourth* rank-one quadratic detector on **all** actually attained histories by
\[
Q(h)=\begin{cases}
P(0), & h\in G_+,\\
P(\tau(d)),& h=(d_1,d_2,F_-(d))\in G_-.
\end{cases}
\]

**Well-defined and continuous:** At the graph intersection on either coordinate axis, \(\tau=0\), so both definitions equal \(P(0)\). At the circle \(g=0\), \(\tau=1\), and \(P(1)=P(0)\), since \(v(1)=-v(0)\). Thus the definitions agree everywhere on the overlap. Both sheets are closed in the full history space, so the finite closed-pasting lemma makes \(Q\) continuous on \(H_3\). Every value is a positive semidefinite rank-one projection with trace one.

**No global continuous signed row \(a(h)\) represents \(Q(h)\):** On the connected sheet \(G_+\), a continuous unit lift must be constantly \(+e_1\) or \(-e_1\); choose \(+e_1\) by global sign. On the connected sheet \(G_-\), every continuous lift must have the form \(\epsilon\,v(\tau(d))\) for one constant sign \(\epsilon\in\{\pm1\}\), since the projector has exactly those two unit representatives. At an axis intersection \(\tau=0\), compatibility forces \(\epsilon=+1\). At the interior-circle intersection \(\tau=1\), compatibility forces \(\epsilon=-1\). Contradiction.

An explicit **closed loop of attained histories** makes the obstruction manifest. Let \(d(t)=(t,2)\) for \(0\le t\le1\). Here \(g(d(t))=(1-t)(3-t)>0\) for \(0\le t<1\), and

\[
F_+(d(t))-F_-(d(t))
=\frac{4\sqrt{2t}(1-t)(3-t)}{1+(1-t)^2(3-t)^2}>0
\quad(0<t<1).
\]

The two graph paths meet exactly at their endpoints t=0 (the coordinate-axis overlap) and t=1 (the interior circle), forming a simple loop inside \(H_3\). On its \(G_+\) arc, \(Q=P(0)\) is constant; on the reverse \(G_-\) arc, \(Q=P(t)\) traverses the projective line once, with odd winding. Any row lift must reverse sign around this loop.

**What is and is not proved:** This is an explicit, rigorous *regularity-class separation* on an actually realized causal intensity-history domain. It does **not** produce fewer than \(2n-1\) readings: in \(\mathbb R^2\), the first three measurements already meet that threshold, and the fourth serves only to expose the physical-detector continuity class. It does **not** refute or invalidate the oriented-row theorem, nor demonstrate a nonorientable selector on the exact n=4 six-reading prefix. The Möbius covering obstruction is classical; originality of this particular causal-history construction has not been checked.

## 4. Full-rank prefix lemma — where any orientation loophole can first appear

**Proposition (elementary, paper-level).** Fix \(j\le n\). Let \(a_i:H_{i-1}\to\mathbb R^n\) be causally selected rows for \(i=1,\ldots,j\), and suppose that for each \(1\le i\le j\) and every *attained* length-(i−1) prefix h, the chronological row vectors
\[
a_1(),\,a_2(h_1),\,\dots,\,a_i(h_1,\ldots,h_{i-1})
\]
are linearly independent. Then **every** nonnegative target transcript of length j is attained:
\[
\boxed{H_j=[0,\infty)^j.}
\]

**Proof by induction:** \(j=1\): any target \(y_1\ge0\) is attained by solving the single nonzero linear equation \(a_1\cdot x=\sqrt{y_1}\). Suppose \(H_{j-1}=[0,\infty)^{j-1}\). For any target y of length j, its prefixes are attained, so all chronological rows are defined and by assumption independent. The linear system \(a_i(y_{<i})\cdot x=\sqrt{y_i}\) for i≤j has a real solution because j≤n and the coefficient matrix has full row rank. The actual causal transcript of that x follows the target y by induction. Nonnegative is automatic because readings are squares. QED.

The orthant is contractible, so any continuous nonzero rank-one projection selector \(Q_{j+1}:H_j\to\mathbb RP^{n-1}\) has a continuous unit-vector lift; this is the standard covering-space lifting theorem (not newly formalized here). Thus a nonorientable physical detector over the attained history set **cannot appear before a first full-rank n-query prefix is completed**, as long as all chronological prefixes satisfy the stated independence. Rank collapse or later branched history spaces can change that.

**Concrete consequence for the \(\mathbb R^4\), six-reading problem:** If the first four rows are chronologically independent at every reachable history, \(H_4=[0,\infty)^4\). The fifth **projectively continuous** detector necessarily has a continuous row lift on \(H_4\). Any genuine projective-vs-oriented obstruction in such a six-reading architecture must therefore involve the attainable five-reading history \(H_5\) and the *sixth* detector, rather than the first five row choices. This is a necessary geometric localization, not an existence claim for a six-reading exact protocol.


## 4b. Exact additional theorem: global normalized detector continuity *does* suffice

**Corollary (paper-level, matching sharp threshold).** Suppose each stage-j measurement is \(x^\top Q_j(h)x\), where the controller selects a **nonzero rank-one orthogonal projection**
\[
Q_j:[0,\infty)^{j-1}\longrightarrow
\{ww^\top:\ w\in S^{n-1}\}
\]
continuously on the **entire** ambient space of potential nonnegative earlier readings, not merely on the attained history set. Then for all \(n\ge2\) the exact universally phase-retrieving number of such causal readings is \(2n-1\).

**Proof:** The projection-valued target is homeomorphic to \(\mathbb RP^{n-1}\), and the double cover \(S^{n-1}\to\mathbb RP^{n-1}\), \(w\mapsto ww^\top\), has the continuous lifting property on the contractible, locally path-connected orthant \([0,\infty)^{j-1}\). Fixing one row sign at the zero transcript determines a continuous lift \(a_j(h)\in S^{n-1}\) of each \(Q_j(h)\) over the entire orthant. Its induced intensity equals \((a_j(h)\cdot x)^2\) at every actual history. Apply the already paper-proved continuous oriented-row lower bound of Section 2. Conversely a fixed normalized full-spark frame needs \(2n-1\) readings and uses constant projector-valued selectors. QED, **conditional only on the externally published CCFH theorem as detailed in §1, not on a new topology conjecture**.

**Necessary qualifications:** The entire-*history* domain condition is stronger than the actually-attained-history condition in §3. The nonzero constant-rank (normalized rank-one projector) condition is essential for this covering-lift proof; if \(Q_j\) can vanish or vary rank, lifting to a row can fail even on a contractible ambient domain. The §3 counterexample is a continuous map on \(H_3\) **that cannot extend to a continuous normalized rank-one projector on the whole nonnegative orthant**; otherwise its non-liftability would contradict this corollary. This is not a contradiction between the two statements but an explicit boundary of the regularity assumptions.

**Research implication:** The physically intrinsic feedback model is already settled when every normalized detector choice is defined continuously on all nonnegative histories. The only projective-orientation loophole left by the current argument concerns selectors continuous solely on the attained (possibly multiply glued) history subsets, or detectors allowed to pass through zero/rank changes. Treat this as an exact model-scope theorem with standard covering-space prior art, NOT a new worldwide novelty claim or a Lean kernel result.


## 4c. Exact obstruction to a tempting replacement proof: mixed antipodal parity is too weak

Suppose a physically specified stage is \(y_j=x^\top Q_j(T_{j-1}(x))x\), with \(Q_j\) continuous on attained histories and normalized rank-one as in §3. For **any** such even causal transcript, define the true-history difference
\[
\Delta_j(u,v)=T_j(u+v)_{\!j}-T_j(u-v)_{\!j},
\qquad (u,v)\in S^{n-1}\times S^{n-1}.
\]
Under either independent flip \(u\mapsto-u\) or \(v\mapsto-v\), the two input signals \(u+v,u-v\) exchange up to overall sign. The transcript is even, so **each** \(\Delta_j\) is odd under **both** antipodes. Thus the vector \(\Delta=(\Delta_1,\ldots,\Delta_m)\) has the *single mixed character* \(\varepsilon_1+\varepsilon_2\) repeated m times, not the two separately pure character blocks that drive CCFH Remark 2.7.

At \(n=4\) there is an elementary, explicit nowhere-zero mixed-character map of rank **four**, hence also into six coordinates: identify \(\mathbb R^4\) with Hamilton's quaternions and define
\[
\Psi:S^3\times S^3\to\mathbb R^4,\qquad \Psi(u,v)=uv.
\]
Quaternion multiplication is bilinear, so \(\Psi(-u,v)=\Psi(u,-v)=-\Psi(u,v)\). Norm multiplicativity gives \(\|\Psi(u,v)\|=\|u\|\|v\|=1\), so it has **no zero anywhere**. Appending two zero coordinates yields a nowhere-zero mixed-character map to \(\mathbb R^6\). The associated mixed-character characteristic-class polynomial is \((\alpha+\beta)^6\), whose only potentially surviving term modulo \((\alpha^4,\beta^4)\) is \(\binom63\alpha^3\beta^3=20\alpha^3\beta^3=0\) in mod-two cohomology; quaternion multiplication provides a direct stronger witness that the equivariant map is possible. This is standard normed-division-algebra topology, **not novel**.

**Crucial limitation:** \(\Psi\) is an abstract equivariant map, **not** a realizable list of squared-linear readings. The observation does NOT establish a six-reading detector policy and does NOT refute the oriented-row theorem. It definitively rules out the proof strategy of deducing the all-policy six-reading collision from the **mixed parity of actual intensity differences alone**. The previously successful proof uses the additional **continuously oriented rank-one row** to split its zero conditions into two pure characters. For projective-only detector choices on attained history subsets, the necessary extra structure remains to be identified. Preserve this as an explicit operator-family failure and stop repeating a mixed-character-only topological argument.

The quaternion norm identity was separately expanded as a polynomial identity in eight independent real variables and reduces to zero exactly; the universal argument is algebraic and requires no numerical optimization.


## 4d. Sharpness of the first possible orientation-defect stage, in every dimension

The prefix lemma in §4 says that if the first n rows are chronologically independent, the selectors for readings 1 through n+1 can be continuously lifted whenever specified by nonzero normalized projectors on their attained histories. **This stage barrier is sharp, even under the full-rank-prefix assumption.**

**Proposition (constructive).** For every \(n\ge2\), there is an \((n+1)\)-reading normalized continuous *oriented-row* protocol whose first n rows are the independent coordinate rows, and a continuous, normalized, rank-one physical detector selector for **reading n+2** on its exact attained \((n+1)\)-history space, with **no continuous oriented-row lift**.

**Proof.** Take the first n measurements \(d_i=x_i^2\). For reading n+1 choose the globally continuous normalized row
\[
a_{n+1}(d)=\frac{(1,g(d_1,d_2),0,\ldots,0)}{\sqrt{1+g(d_1,d_2)^2}}
\]
with \(g\) exactly as in §3. The attainable histories consist of all vectors
\[
(d_1,\ldots,d_n,z), \qquad
d_i\ge0,\quad z=F_\pm(d_1,d_2),
\]
with each \(F_\pm\) precisely the two-sheet function in §3. Up to permutation of coordinates this is the **topological product** \(H_3^{(2D)}\times[0,\infty)^{n-2}\), with both factor projections continuous.

Define the proposed reading-(n+2) detector by pulling back the no-lift projector \(Q\) of §3 along the projection onto \((d_1,d_2,z)\), and embed its 2×2 matrix as the upper-left block of an n×n matrix with all other entries zero. It remains a continuous trace-one rank-one PSD projection on the **actual attained histories**. If a continuous unit-vector row lift existed on this larger history domain, restrict it to the closed slice \(d_3=\cdots=d_n=0\). Its last n−2 coordinates must vanish because the projector has no support there, and its first two coordinates would give a continuous row lift of the §3 nonorientable projector on \(H_3^{(2D)}\), contradiction.

For n=4 the pattern is **four fixed independent coordinate readings, one continuous fifth row, and one physically continuous non-liftable sixth rank-one detector**. This explicitly realizes the geometric regularity phenomenon at the exact numerical frontier of the broader six-versus-seven project. QED.

**Limits:** This constructed protocol does **not** phase-retrieve all signals; the fifth and sixth readings deliberately ignore coordinates 3 through n and cannot resolve their relative signs. Therefore it is **not** a six-reading counterexample to the proved oriented-row count and does not settle the physical-detector count. It establishes only that the new model's nonorientability is genuinely realizable at the earliest permitted stage after a full-rank prefix. A construction of universal recovery, or a new obstruction exploiting the residual rank-one algebra, is still required.

## 5. Formalization / priority / independent audit plan

- The published CCFH Remark 2.7 is the correct **external mathematical theorem**, not a Lean axiom masquerading as proof. #1010/#1024 supply only algebra, a Prop-valued topology interface and zero-padding; #1015/#1017 supply conditional causal Lean proofs. #1032/#1034/#1037/#1041 address distinct fragments of a proposed independent Lean proof of the classical zero theorem (character averaging, reference orbit, smooth approximation, sphere-only extension); full relative transversality and compact one-manifold boundary parity remain missing. **Do not duplicate source modules, falsely merge stacked branches or announce an unconditional kernel certificate.**
- Ullrich arXiv:2610.33781v1 (2026-10-24) explicitly allows **arbitrary history dependence** while each selected functional is continuous in x. His antipodal-separation theorem is not a lower bound for real phase retrieval modulo sign: the squared-linear measurements here are **even**, so every transcript automatically identifies x and −x. His model and performance criterion are distinct, not a direct earlier proof of the present \(2n-1\) result.
- The main scientific novelty gate remains dated, same-model literature comparison and independent human referee. Classical Ramos/CCFH topology, double covers, full-rank linear surjectivity and ordinary fixed-frame 2n-1 are credited as prior art. This document's new **causal attainable-history no-lift construction** has a complete explicit paper proof, but neither Lean checking nor specialist priority review.
- **Cheapest independent mathematical check for this new construction:** verify the two sheet formulas; that the sheets meet only on axes and g=0; equality of the two Q definitions at all overlaps; and the constant-sign lift contradiction on the explicit two-arc loop. The graph and projection formulas are elementary and admit exact symbolic identity checks. No large search or proof-engineering campaign is warranted until a second proof attacks this exact construction.
- **Next high-value question in the *same phase-retrieval flagship*:** Does the \(2n-1\) threshold persist when the chosen **rank-one quadratic detector \(Q_j(h)\)** is continuous on reachable histories, without a global signed row lift? This is a strictly broader model by the construction above. A universal continuous six-reading \(\mathbb R^4\) protocol **in that weaker regularity class** would not contradict the existing oriented-row theorem. Conversely, a new obstruction for this model would strengthen its physical relevance. Treat this as an explicitly **new conjectural extension**, not as the already proved result and not as a second flagship.
