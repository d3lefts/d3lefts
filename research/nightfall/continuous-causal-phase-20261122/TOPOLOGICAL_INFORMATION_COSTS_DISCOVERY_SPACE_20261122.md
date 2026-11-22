# Research perimeter: topological information costs in causal phase retrieval
**NIGHTFALL scoped programme, 2026-11-22. Status:** an evidence-based research niche and several elementary paper-level deductions, **not a certified new field, new priority, or solved physical-detector complexity theorem**. Source custody: phase retrieval PRs #695/#699/#995/#1000; the present PR #1047 source/holonomy note; external CCFH theorem (2019/2020). Keep structural-information/Q2/prime-wheel as parked, not concurrent flagships.

## Scientific question

For real exact scalar intensity measurements, which **regularity constraints on causal sensor selection** force fixed-frame-sized measurement complexity, and which weaker physically natural regularity conditions leave room for adaptive information savings?

Model the stage-j observation by

\[
y_j=x^\top Q_j(y_1,\ldots,y_{j-1})x,\qquad
Q_j(h)\succeq0,\quad \operatorname{rank}Q_j(h)\le1,\quad
\operatorname{tr}Q_j(h)\le1.
\]

The history domain is either the actual attainable set \(H_{j-1}\), or the entire nonnegative orthant \(\mathbb R_{\ge0}^{j-1}\); these are NOT interchangeable. A signed row \(a_j(h)\) has \(Q_j(h)=a_j(h)a_j(h)^\top\). Physical Q is unaffected by the sign \(a\mapsto-a\).

Count one scalar intensity per query; never equate a rank-k response to one rank-one scalar. Recovery means injectivity of the full true causal transcript on **every** signal modulo global \(\pm1\), including zero and changing support.

### Four tiers, no hidden novelty promotion

| Class | Exact minimal m / bounds | Gate |
|---|---|---|
| Arbitrary history-dependent signed row | \(n+1\) | #695 Lean-certified |
| Continuous signed row on attainable history | \(2n-1\) | #995 complete paper proof; #1000 independent AI audit; external CCFH Remark 2.7; conditional causal Lean; external human referee/priority pending |
| Continuous positive rank-one **normalized** projector on full orthant | \(2n-1\) | §4b of PR #1047, paper corollary via covering lift; not independently formalized |
| Continuous normalized projector on **attained** history, or continuous PSD rank≤1 allowing zeros even on full orthant | \(n+1\le m\le2n-1\) | Open exact query counts for \(n\ge3\), no six-reading R4 solution claimed |

Lower \(n+1\) for the last class follows because each individual rank≤1 PSD matrix has *some* signed-row square root, even if no **continuous** row choice exists. Upper \(2n-1\) is a fixed full-spark frame.

## Theorem I: exact detector-lift criterion (elementary bundle reduction)

Let \(H\) be any topological subspace of Euclidean history space and \(Q:H\to\mathrm{Sym}_+^n\) continuous of rank at most one. Set

\[
U=\{h:\operatorname{tr}Q(h)>0\},
\quad \lambda(h)=\operatorname{tr}Q(h),
\quad P(h)=Q(h)/\lambda(h)\quad(h\in U).
\]

Then **the following statements are equivalent**:

1. There is a continuous row \(a:H\to\mathbb R^n\) with \(Q(h)=a(h)a(h)^\top\).
2. The normalized line map \(P:U\to\mathbb RP^{n-1}\) has a continuous unit-vector lift \(w:U\to S^{n-1}\) with \(P(h)=w(h)w(h)^\top\).
3. The pulled-back real line bundle \(L_P\) over \(U\) is trivial; equivalently its first Stiefel–Whitney class \(w_1(L_P)\) vanishes (in the appropriate Čech cohomology for a possibly non-manifold Euclidean subspace).

**Proof:** (1)⇒(2), \(w=a/\|a\|\) on U. (2)⇒(1), let \(a(h)=\sqrt{\lambda(h)}\,w(h)\) on U and \(a(h)=0\) on \(H\setminus U\). For a rank-one PSD Q its sole positive eigenvalue equals its trace, giving \(aa^\top=Q\). Continuity at h∈H\U follows from \(\|a(h')\|=\sqrt{\lambda(h')}\to0\), regardless of how wildly w winds. (2)⇔(3) is the standard equivalence between a unit section and triviality of a real line bundle; its cohomological form uses classical prior art. QED.

**Interpretation:** There are exactly two *sources* for a failure of oriented-row regularity within this model: nontrivial topology of the **attained nonzero-history domain U**, or **detector zeros** that make U topologically nontrivial even when the full history domain H is contractible. Neither source, by itself, proves an information advantage.

## Theorem II: necessary topological cost of beating the continuous-row threshold

For any exact universally recovering real causal rank≤1 PSD protocol with \(m\le2n-2\) stages, at least one stage j must have a **nontrivial line bundle \(L_{P_j}\) on \(U_j=\{h\in H_{j-1}:\operatorname{tr}Q_j(h)>0\}\)**, equivalently a non-liftable normalized direction map. If all stages had trivial bundles, Theorem I would produce continuous signed rows with identical readings at every reachable history, contradicting the CCFH-based all-policy lower bound from #995/#1000. This is a *necessary*, NOT sufficient, criterion. Do not infer existence of a successful sub-\(2n-1\) protocol from the non-lift examples.

**Special cases:**
- If every \(H_{j-1}\) is **contractible** (or locally path-connected and simply connected) and each Q_j is nonzero normalized, all row lifts exist and **2n−1** is necessary. Bare triviality of the fundamental group without covering-space hypotheses is not used.
- If the normalized Q_j are given continuously on the full history orthants, all lift and **2n−1** is necessary.
- If the first n actual row choices are chronologically independent along every history, their n-length attainable domain is exactly the orthant. Non-liftability for normalized projectors cannot first arise until the **(n+2)-nd** detector. The construction in PR #1047 §4d attains this onset (but intentionally fails recovery).

## Theorem III: sharp C0 stability of the orientation obstruction

Let \(H\) be any topological space and \(P,P':H\to\mathrm{Proj}_1(\mathbb R^n)\) continuous normalized rank-one orthogonal-projector maps. If

\[
\|P(h)-P'(h)\|_{\mathrm{op}}<1
\quad\text{for every }h\in H,
\]

then P and P' are homotopic and have the **same liftability class**. In particular a non-liftable detector remains non-liftable under any such perturbation; a uniform \(\rho<1\) gives a uniform spectral gap.

**Proof:** Put \(A_t(h)=(1-t)P(h)+tP'(h)\). If the angle between their unoriented lines is \(\theta\), \(\|P-P'\|_{\rm op}=|\sin\theta|<1\), and the top two eigenvalues of A_t have gap
\[
\sqrt{1-4t(1-t)\sin^2\theta}>0.
\]
The unique top eigenspace therefore varies continuously with (h,t), producing a homotopy of line projectors from P to P'. The pulled-back double covers are isomorphic under homotopy; a continuous lift exists for one iff it exists for the other. QED.

**Sharp universal threshold:** the constant 1 cannot be raised. For the once-winding loop \(P(\varphi)=v(\varphi/2)v(\varphi/2)^\top\) on \(S^1\), with \(v(\phi)=(\cos\phi,\sin\phi)\), P is non-liftable. The constant projector \(P_0=e_1e_1^\top\) is liftable, but their maximum operator-norm distance is exactly 1 (at the orthogonal line).

**Certificate design:** With a known interpolation bound that guarantees each segment stays at operator distance <1 from its start, choose rational projectors at angles \(0,\pi/4,\pi/2,3\pi/4,\pi\), represented by integer vectors
\[
w_0=(1,0),\ w_1=(1,1),\ w_2=(0,1),\ w_3=(-1,1),\ w_4=(1,0).
\]
All consecutive dot products are nonzero and their signs are \(+,+,+,-\). Their product is \(-1\), an exact finite witness to nontrivial holonomy of the explicitly specified half-turn loop. **Discrete samples without the interpolation control are not a universal topological certificate.**

## Theorem IV: rank loss makes a simply connected history domain insufficient

Even on the full contractible history orthant \(H=[0,\infty)^2\), a continuous norm-bounded rank≤1 PSD detector that may vanish need not have a continuous square-root row.

Take \(z=(h_1-2,h_2-2)\), \(r=\sqrt{z_1^2+z_2^2}\), and
\[
Q(h)=\frac1{2(1+r)}
\begin{pmatrix}
r+z_1 & z_2\\
z_2 & r-z_1
\end{pmatrix}
\]
with Q(2,2)=0. Its determinant vanishes because \(r^2=z_1^2+z_2^2\), its trace is \(r/(1+r)\in[0,1)\), and it is PSD and rank exactly one for \(r>0\). Around the radius-one circle centered at (2,2), the normalized direction Q/tr Q is the once-winding half-angle projector of Theorem III. Any continuous row factorization would restrict to a unit-row lift on that circle, impossible. The same construction embeds as a 2×2 principal block in any n≥2.

This can be used as the **third stage after two fixed coordinate-square readings**, because those actual prior histories fill the whole orthant. Thus the normalized/nonvanishing hypothesis in the full-history projector corollary cannot be discarded. The winding mechanism is classical real-eigenvector/Berry-sign holonomy, not an original topological invariant; its realization as a *causal detector-selection regularity failure* is the scoped research synthesis.

## The decisive single-flagship open problem

Define \(m_{\rm att,proj}(n)\) as the exact query optimum for normalized, continuous nonzero rank-one projector selections defined only on attained histories. The source-proved bounds are

\[
n+1\le m_{\rm att,proj}(n)\le2n-1.
\]

**Primary falsifier:**
\[
\boxed{m_{\rm att,proj}(4)\stackrel{?}{=}7.}
\]

Either construct six **actual** causal normalized projectors with universal sign recovery, including all zero/support boundaries, or prove no such six-query policy can exist via an invariant stronger than mere mixed-character transcript parity. PR #1047 §4d shows that a non-liftable sixth projector can exist on actual H5 after four independent measurements, but that example does NOT recover signals. PR #1047 §4c shows quaternion multiplication gives a nowhere-zero mixed-character map, so antipodal parity of raw transcript differences alone cannot settle this question.

**Mandatory distinction:** For rank≤1 PSD sensors that may vanish, define a separate tier \(m_{\rm att,PSD0}(n)\). Theorem IV shows its row-lifting obstruction may appear already at detector 3 on a contractible history. The early n=3 four-query instance is a useful **counterexample stress**, not another flagship or a solved result. An all-n theorem requires a transfer mechanism, not extrapolation from these finite dimensions.

## Boundary to established literature, checked 2026-11-22

- Balan–Casazza–Edidin: fixed real complement property and the \(2n-1\) frame threshold.
- Charikar–Wu–Ye, *Adaptive Discrete Phase Retrieval* (SOSA 2020, DOI 10.1137/1.9781611976014.9): adaptive measurement constructions on discrete/bounded-bit signal classes; not the identical arbitrary-real feedback regularity model.
- Chan–Chen–Frick–Hull, *Borsuk–Ulam Theorems for Products of Spheres and Stiefel Manifolds Revisited* (arXiv:1902.00935, printed Remark 2.7): exact topological zero premise in the oriented-row proof; credit classical topology to its antecedents.
- Mario Ullrich, *A Borsuk–Ulam Theorem for Adaptive Continuous Measurements* (arXiv:2610.33781, Oct 2026): arbitrary history selection of functionals continuous in x, antipodal separation/ball error; different regularity and identification problem.
- Favazza–Frank–Freeman–Ghoreishi–King–Randrianarivony, *Frames and Phase Retrieval for Vector Bundles* (SampTA 2025, DOI 10.1109/SampTA64769.2025.11133513): already treats moving frames and phase retrieval of vector-bundle sections. **Do not claim invention of vector-bundle/topological phase retrieval**. Their fixed fiberwise moving-frame/sampling model is not this sequential attained-feedback information model; the primary PDF text was available but its visual access became browser-challenged during this session, so do not treat the comparison as exhaustive.
- Real Berry sign / conical intersection theory: half-angle eigenline holonomy is classical, including published work on geometric phase and holonomy of 2×2 symmetric operators. Theorem IV is an application, not a discovery of Berry phase.
- Phasebook (2025 survey), condition-number bounds (2026): fixed/general statistical phase-retrieval and robustness are mature fields; only claims with **exactly the same causal+regularity+detector** model bear directly on this programme.

**Current novelty result:** limited dated search did not locate the precise exact four-tier threshold law or its attainable-history lift/no-lift examples. This is only *candidate originality*. External specialist search and non-author human review are required before a novel-priority gate. Theorems I–IV are primarily elementary known topology combined with the NIGHTFALL phase-retrieval theorem; do not pitch them as discovering covering theory, Berry holonomy, or phase retrieval on bundles.

## Focused validation and stop rule

1. **Independent proof audit** of the ranked results: zero set, continuity at Q=0, covering lift ⇔ row factor, interpolation gap and sign-cycle, prefix orthant. Finite rational checks verify algebra/holonomy nodes, not the homotopy theorem.
2. **One genuine information experiment:** n=4 six normalized/projective detectors on actual H5. A universally separating exact policy is a decisive counterexample. A universal obstruction exploiting measurement realizability is a decisive new theorem.
3. **Proof-engineering gate:** complete the independently sourced product-sphere zero in Lean, or explicitly keep the all-n oriented-row statement as a paper theorem relying on published CCFH. Do not write duplicated Lean sources or turn conditional Lean into an unconditional badge.
4. **Publishing gate:** identify exact-model prior art by date and complete independent human review; no public original-discovery assertion before that.
5. **Stop:** No new constant tuning, exploratory alternative flagship, or extra CI campaign until a candidate policy/proof crosses the n=4 six-versus-seven gate. Theorem I is a transferable classifier; the newly conjectured exact PSD/projector complexity law is the true future breakthrough target.

**Research graph:** Causal sensing → attained history → normalized detector/zero locus → pullback line bundle → liftability/holonomy → obstruction to continuous oriented feedback → query threshold → topological vs genuine-causal gap → novelty/certification.
