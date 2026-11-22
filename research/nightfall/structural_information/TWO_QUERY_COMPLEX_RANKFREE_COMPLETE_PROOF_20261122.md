# Rank-free two-query binary-character simulation: complete Hilbert-energy proof

**NIGHTFALL, proof revision v3 — 2026-11-22.** Source theorem extends the existing tensor-subcube Hilbert argument in #1016/#1059 and its abstract binary-label formulation in #1068; mathematical mechanism, identities and attribution are preserved. **Status: complete author-side analytic paper proof** for *all finite-dimensional complex Hilbert spaces*, *arbitrary effects \(0\le P\le I\)* and *all finite binary label sets*. It has passed a new, separately implemented finite multi-rank numerical attack, but **independent mathematical review, Lean kernel formalization, dated same-scope global novelty clearance and authorized publication remain OPEN**. Do not interpret “complete paper proof” as “Lean-certified” or “world-first theorem.”

## Research contract and fixed model

**Objective.** Derive a nonadaptive *legal original-label* classical estimator of an arbitrary two-query quantum *scalar acceptance probability*, with cost controlled by two explicitly defined binary XOR fibers, uniformly in Hilbert-space dimension and effect rank.

**Frozen feasible set.** \(V\) is a finite-dimensional vector space over \(\mathbb F_2\), \(R\subseteq V\setminus\{0\}\) a finite set of **distinct** allowed classical query labels, \(D=R\cup\{0\}\), and \(s\) uniform on the complete dual \(V^*\). The response to a legal classical query \(a\in R\) is \(\chi_a(s)=(-1)^{s(a)}\). A two-query quantum circuit has the exact phase-oracle semantics
\[
 O_s=\sum_{a\in D}\chi_a(s)\Pi_a,\quad
 \Psi_s=O_s U O_s\psi,\quad f(s)=\langle\Psi_s,P\Psi_s\rangle .
\]
The finite complex Hilbert space \(\mathcal H\) is arbitrary; the \(\Pi_a\) are orthogonal **projections** with \(\Pi_a\Pi_b=0\) for \(a\ne b\) and \(\sum_a\Pi_a=I\); \(\|\psi\|=1\), \(U\) unitary and \(P=P^*\) an arbitrary effect \(0\preceq P\preceq I\), *not* assumed to be a projection or rank bounded. Initial/final fixed unitaries are absorbed into \(\psi,P\). The \(a=0\) positive oracle sector can be nonzero. The circuit \(f\), but not the secret \(s\), is known for nonuniform classical preprocessing. Only the **number of raw classical oracle queries**, not classical runtime, is bounded.

Set the **ordered**, **nonzero-frequency** pair fiber
\[
M=\max\Bigl(1,\max_{z\in V\setminus\{0\}}
 \#\{(a,b)\in D^2:a+b=z\}\Bigr),
\]
and primitive four-fiber
\[
K=\max\Bigl(1,\max_{z\in V\setminus\{0\}}
 \#\{(a_1,\ldots,a_4)\in D^4:
 \sum_j a_j=z,\; \{a_j:a_j\ne0\}\text{ has size equal to its multiplicity and is linearly independent}\}\Bigr).
\]
**Clarification:** zero slots may repeat in the *counting upper bound* \(K\), but all repeated-label four-tuples, including repeated zero slots, will belong to Group B in the **disjoint Fourier coefficient partition**. This prevents double counting. When \(R=\varnothing\), the theorem is immediate with zero queries.

**Strongest relevant earlier source examined:** original NIGHTFALL #1016 two-query tensor argument and independently written author-controlled #1059 Hilbert audit; the published Lovitz–Petrov (2023) circuit statement concerns the *tensor specialization* and is not an input to the abstract operator proof. A 2026 exact-two-query variable theorem (Li / related scope) is about exact Boolean algorithms, not automatically the same distributional correlated-label acceptance model. Prior-art novelty remains unresolved.

## Theorem (complete paper-level proof; all finite complex Hilbert spaces)

For every \(0<\varepsilon,\delta<1\) there exists a set of original labels \(H\subseteq R\), fixed **before** receiving any oracle answers, and a deterministic estimator \(g:\{\pm1\}^{H}\to[0,1]\) such that
\[
\Pr_{s\sim{\rm Unif}(V^*)}
\left[\left|f(s)-g((\chi_h(s))_{h\in H})\right|>\varepsilon\right]\le\delta,
\]
and
\[
\boxed{|H|\le\min\left\{|R|,
\left\lceil\frac{2(2\sqrt K+145\sqrt M)^2}{\varepsilon^2\delta}\right\rceil
\right\}.}\tag{T2}
\]
There is **no dimension, rank, trace, nonzero-mass floor, oracle-label independence or runtime hypothesis**. The distribution is *uniform on \(V^*\)*; no analogous nonuniform-source assertion follows without further work.

### Lemma 1 — frame lightness and unrestricted complex energy

Let
\[
\psi_a=\Pi_a\psi,\quad t_{ba}=\Pi_bU\psi_a,\quad
p_a=\|\psi_a\|^2,\quad q_b=\sum_a\|t_{ba}\|^2.
\]
Then \(\sum_a p_a=\sum_b q_b=\sum_{a,b}\|t_{ba}\|^2=1\). Put \(G=\sum_{a,b}|t_{ba}\rangle\langle t_{ba}|\), so \(G\succeq0\), \({\rm Tr}G=1\).

For \(0<\eta<1\) define first-light labels by \(p_a<\eta\), second-light labels by \(q_b<\eta\). The two restricted positive frames satisfy **separately**
\[
 G^{(1)}_{\ell}
 =\sum_{a:p_a<\eta}\sum_b |t_{ba}\rangle\langle t_{ba}|
 =\sum_b\Pi_bU\left(\sum_{a:p_a<\eta}
 |\psi_a\rangle\langle\psi_a|\right)U^*\Pi_b
 \preceq\eta I,\tag{1}
\]
since the mutually orthogonal \(\psi_a\) each have \(\|\psi_a\|^2<\eta\), and pinching preserves Loewner order. Likewise,
\[
 G^{(2)}_{\ell}
 =\sum_{b:q_b<\eta}\sum_a |t_{ba}\rangle\langle t_{ba}|
 \preceq \sum_{b:q_b<\eta}q_b\Pi_b
 \preceq \eta I,\tag{2}
\]
since each \(b\)-block is positive, supported on \({\rm ran}\Pi_b\), and has trace \(q_b\).

Define \(c_{a,b,a',b'}=\langle t_{b'a'},P t_{ba}\rangle\) (complex convention: linear in the second slot). For **any** one of the four possible restrictions that its corresponding first/second label is light,
\[
 \sum_{\text{restricted path},\,\text{unrestricted opposite path}}
 |c_{a,b,a',b'}|^2
 ={\rm Tr}(G_\ell PGP)
 \le\eta {\rm Tr}(PGP)
 =\eta {\rm Tr}(GP^2)\le\eta.\tag{3}
\]
For a primed restriction swap the conjugate pair; the absolute square is unchanged. We use only \(P=P^*,\,0\preceq P\preceq I\Rightarrow P^2\preceq I\); **the paths themselves need not be orthogonal**.

Choose heavy set \(H=\{a\in R:p_a\ge\eta\text{ or }q_a\ge\eta\}\), of size \(|H|\le2/\eta\), and its binary span \(W={\rm span}_{\mathbb F_2}H\). Every nonzero Fourier frequency \(z\notin W\) contains in its four-slot expansion **at least one label outside \(W\)**, and that label is nonzero and light in the corresponding stage. Summing the four restrictions in (3), the total *ungrouped* energy over all four-tuples contributing a frequency outside \(W\) is at most \(4\eta\). In particular, if an indexed subfamily has at most \(B\) ordered original four-tuples at each \(z\notin W\), then
\[
 \sum_{z\notin W}\left|\sum_{\substack{\text{tuples in the subfamily}\\
 \text{with XOR }z}}c_\text{tuple}\right|^2\le 4B\eta.\tag{4}
\]

### Lemma 2 — grouped two-frame principle

We will repeatedly use this elementary complex-Hilbert fact. For families \(u_x,v_y\) with positive frames \(F_u=\sum_x|u_x\rangle\langle u_x|\), \(F_v=\sum_y|v_y\rangle\langle v_y|\), if the *full* frames satisfy \({\rm Tr}F_u,{\rm Tr}F_v\le1\) and the restriction \(F_{u,\ell}\preceq\eta I\), then
\[
 \sum_{x\;\ell,y}|\langle v_y,u_x\rangle|^2
 = {\rm Tr}(F_{u,\ell}F_v)\le\eta\,{\rm Tr}F_v\le\eta.\tag{5}
\]
The same holds with the roles reversed if \(F_{v,\ell}\preceq\eta I\). If a positive contraction \(Q\) is inserted between \(u_x,v_y\), replace one frame by \(QFQ\); its trace does not increase. A fixed vector \(v\) with \(\|v\|\le1\) may be used in place of one family, in which case the same inequality reads \(\langle v,F_{u,\ell}v\rangle\le\eta\). No orthogonality beyond the **explicit** frame bounds is assumed.

### Lemma 3 — exact disjoint four-slot trichotomy

Expanding \(O_s U O_s\psi=\sum_{a,b\in D}\chi_{a+b}(s)t_{ba}\) and the Born expectation gives
\[
 f(s)=\sum_{a,b,a',b'\in D}\chi_{a+b+a'+b'}(s)c_{a,b,a',b'}.\tag{6}
\]
For \(z=a+b+a'+b'\ne0\), divide all original ordered four-tuples into three **disjoint** classes:

- **A:** no repeated slot label, and all nonzero entries have no nonempty XOR-zero subset;
- **B:** at least two of the *four slot labels*, including possible zeros, coincide;
- **C:** all four are distinct and nonzero, with a three-element XOR-zero subset.

The trichotomy is exhaustive: if all four labels are distinct and one is zero, a zero-XOR subset of the other three would force total XOR zero. If all four labels are distinct nonzero and the total XOR is nonzero, the *only* possible nonempty dependent subset is a triple; two different dependent triples would force the two distinct omitted labels equal. Hence there is exactly **one** zero triple in Class C.

For A, the number of four-tuples for each \(z\ne0\) is at most \(K\), and (4) yields
\[
 \|\text{outside-}W\text{ Fourier contribution of A}\|_2
 \le 2\sqrt{K\eta}.\tag{7}
\]

### Lemma 4 — all six repeated-label cancellations, unrestricted effect

For B let the six basic equality events equate any two of the slot positions \(a,b,a',b'\). Apply inclusion–exclusion **to complex Fourier coefficients**, not to their absolute values. Each single event is summed *over the canceled index first*, leaving two ordered survivor labels \(x,y\) and frequency \(z=x+y\). Thus there are at most \(M\) ordered survivor pairs per nonzero frequency.

The six first-order grouped coefficients and their light-frame justifications are:

| Equality | Surviving labels | Grouped coefficient | Why the survivor-index square energy is \(\le2\eta\) outside \(W\) |
|---|---|---|---|
| \(a=a'\) | \(b,b'\) | \(\langle T_{b'},(\oplus_aP)T_b\rangle,\ T_b=\oplus_at_{ba}\) | \(T_b\) orthogonal, squared norms \(q_b\), total trace 1, \(q\)-light frame \(\preceq\eta I\) |
| \(b=b'\) | \(a,a'\) | \(\langle U\psi_{a'},P_{\rm diag}U\psi_a\rangle,\ P_{\rm diag}=\sum_b\Pi_bP\Pi_b\) | \(U\psi_a\) orthogonal, squared norms \(p_a\), \(P_{\rm diag}\) a contraction |
| \(a=b\) | \(a',b'\) | \(\langle t_{b'a'},PV\rangle,\ V=\sum_at_{aa}\) | \(\|V\|^2=\sum_a\|t_{aa}\|^2\le1\); Lemma 1 for each survivor |
| \(a'=b'\) | \(a,b\) | \(\langle V,Pt_{ba}\rangle\) | conjugate of previous case |
| \(a=b'\) | \(b,a'\) | \(\langle U\psi_{a'},F_b\rangle,\ F_b=\sum_a\Pi_aP t_{ba}\) | nontrivial synthesis bound (8) below |
| \(b=a'\) | \(a,b'\) | \(\langle F_{b'},U\psi_a\rangle\) | complex conjugate of previous case |

The crucial crossed-slot synthesis bound is, **for all complex scalars \(\beta_b\)**,
\[
\begin{aligned}
\left\|\sum_b\beta_bF_b\right\|^2
 &=\sum_a\left\|\Pi_aP\sum_b\beta_bt_{ba}\right\|^2\\
 &\le\sum_a\left\|\sum_b\beta_bt_{ba}\right\|^2\\
 &=\sum_b|\beta_b|^2\sum_a\|t_{ba}\|^2
 =\sum_bq_b|\beta_b|^2. \tag{8}
\end{aligned}
\]
The **last** equality uses only that, *for fixed \(a\)*, the vectors \(t_{ba}=\Pi_bU\psi_a\) lie in mutually orthogonal output blocks as \(b\) varies. It emphatically does **not** assume that different full two-query paths or equal-frequency path vectors are orthogonal. Inequality (8) implies \(\sum_b|F_b\rangle\langle F_b|\preceq I\) with trace at most 1 and that its \(q_b<\eta\) subframe is \(\preceq\eta I\). Combined with the orthogonal \(U\psi_{a'}\) frame and its \(p_{a'}<\eta\) restriction, (5) yields energy \(\le\eta\) for each light survivor, hence \(\le2\eta\).

For any single equality event, \(x+y=z\notin W\) implies at least one **surviving** label is outside \(W\), therefore light in its corresponding stage. Lemma 2 bounds the sum of squares of its grouped \(x,y\) coefficients by \(2\eta\); Cauchy–Schwarz over at most \(M\) pairs per frequency gives
\[
 \|\text{outside-}W\text{ Fourier contribution of one equality}\|_2
 \le\sqrt{2M\eta}.\tag{9}
\]

Now consider an intersection of **at least two distinct** equality events. Its equality graph on four positions either has a component of size at least 3, or two disjoint pairs. If all four coincide, or two distinct paired components occur, total XOR is zero. Otherwise the only nonzero-frequency case is **one triple-equal label \(x\)** and singleton label \(y\), with \(z=x+y\). There are at most \(M\) such ordered \((x,y)\) lifts for fixed \(z\), and the original-slot ungrouped bound (4) gives norm at most \(2\sqrt{M\eta}\). Of \(2^6-1\) nonempty intersections, six are single events and at most **57** are higher intersections; applying triangle inequality to the inclusion–exclusion formula gives
\[
 \|\text{outside-}W\text{ contribution of B}\|_2
 \le(6\sqrt2+114)\sqrt{M\eta}.\tag{10}
\]

### Lemma 5 — exactly one zero triple; four survivor positions

For each \(e\in R\), set
\[
\widehat T_e=\sum_{\substack{a,b\in R\\a+b=e}}t_{ba}.
\]
Each nonzero \(e\)-fiber has at most \(M\) **ordered** paths. Cauchy–Schwarz and the fact that every ordered pair contributes to at most one such fiber give
\[
 \sum_{e\in R}\|\widehat T_e\|^2
 \le M\sum_{a,b\in R}\|t_{ba}\|^2\le M.\tag{11}
\]

In Class C the **unique** triple has XOR zero and the survivor label equals the nonzero frequency \(d=z\). Analyze a fixed survivor position, at first **including** tuples where \(d\) repeats one of the nonzero triple labels, and then subtract the overlaps.

**Survivor \(a'=d\), triple \(a+b+b'=0\).** Sum first over \(a,b\) and put
\[
 Z=\sum_{e\in R}\Pi_e P\widehat T_e,\qquad
 K_d=\langle U\psi_d,Z\rangle .
\]
By orthogonality of the distinct \(\Pi_e\), \(\|Z\|^2\le\sum_e\|\widehat T_e\|^2\le M\). Since \(d=z\notin W\) is \(p_d\)-light, the \(U\psi_d\) form an orthogonal light frame bounded by \(\eta I\). Hence
\[
 \sum_{d\notin W}|K_d|^2\le\eta M.\tag{12}
\]

**Survivor \(b'=d\), triple \(a+b+a'=0\).** The grouped coefficient is
\[
 K_d=\sum_{e\in R}\langle\Pi_d U\psi_e,P\widehat T_e\rangle .
\]
Cauchy–Schwarz **on the actual \(d\)-block paths**, then \(\Pi_d\)-orthogonality, gives
\[
 |K_d|^2
 \le \left(\sum_{e\in R}\|\Pi_dU\psi_e\|^2\right)
    \left(\sum_{e\in R}\|\Pi_dP\widehat T_e\|^2\right)
 \le q_d\sum_{e\in R}\|\Pi_dP\widehat T_e\|^2.
\]
For \(d\notin W\), \(q_d<\eta\); summing over such \(d\) and using the resolution \(\sum_d\Pi_d=I\) gives
\[
 \sum_{d\notin W}|K_d|^2
 \le\eta\sum_e\|P\widehat T_e\|^2
 \le\eta M. \tag{13}
\]
Survivors at \(a\) and \(b\) are complex conjugates of the two cases above, by swapping primed and unprimed paths and using \(P=P^*\).

For each survivor location, eliminate the temporary overlap where \(d\) coincides with one of its three triple entries. The triple's three nonzero entries are **automatically pairwise distinct** because their XOR is zero. For fixed \(d\) and one repeated position, the other two labels must XOR to \(d\), giving at most \(M\) original ordered lifts. Thus each of the four survivor positions has at most \(3M\) overlap lifts per \(z=d\notin W\). Every such lift has a light survivor \(d\), so (4) bounds the correction norm by \(2\sqrt{3M\eta}\). The genuine distinct Class C contribution is therefore
\[
\|\text{outside-}W\text{ contribution of C}\|_2
 \le4(1+2\sqrt3)\sqrt{M\eta}.\tag{14}
\]

### The conclusion — literal original queries and parameter choice

Since \(s\) is **uniform on \(V^*\)**, Walsh characters \(\chi_z\) for \(z\in V\) are orthonormal. The sigma-field of the **actually queried** characters \((\chi_h)_{h\in H}\) is generated by their binary span \(W\). The conditional expectation \(g=\mathbb E[f\mid(\chi_h)_{h\in H}]\) is exactly the \(W\)-Fourier projection: it retains **all** frequencies in \(W\), including zero, and drops those outside. Hence \(0\le g\le1\), even though individual Fourier coefficients may be complex.

Using the *exact* trichotomy of Lemma 3 and triangle inequality, (7), (10), (14) give
\[
\begin{aligned}
 \|f-g\|_{L^2(V^*)}
 &\le \left[2\sqrt K+
 \left(6\sqrt2+114+4(1+2\sqrt3)\right)\sqrt M\right]\sqrt\eta\\
 &\le(2\sqrt K+145\sqrt M)\sqrt\eta,
 \qquad
 6\sqrt2+114+4(1+2\sqrt3)=140.341687834\ldots<145.
\end{aligned}\tag{15}
\]
Choose
\[
 \eta=\frac{\varepsilon^2\delta}{(2\sqrt K+145\sqrt M)^2}.
\]
It lies in \((0,1)\) for the stated parameters and \(K,M\ge1\). Parseval gives \(\mathbb E|f-g|^2\le\varepsilon^2\delta\), and Markov gives the stated failure bound. The heavy set has \(|H|\le2/\eta\). Alternatively, querying all of \(R\) determines **all** characters used by the known oracle circuit and hence \(f\) exactly. Choose the cheaper of these two deterministic nonadaptive strategies. This proves (T2). **QED, at paper level.**

## Proof-attack ledger, certificate and remaining gates

1. **Repeated-zero partition:** all repeated *slot labels* are assigned to B before primitive counting; K overcounts zero-padded supports only as an upper bound. Failure mode: charging a repeated-zero tuple simultaneously to A and B.
2. **Four-slot Hilbert frame:** (3) uses incoherent path masses \(p_a\) and \(q_b\), not the secret-dependent post-query probability of observing \(b\). Failure mode: incorrectly substituting \(p_b\) for \(q_b\) at the second stage. A two-sector swapped-state counterexample makes \(p_b=0\), \(q_b=1\).
3. **Crossed equality:** (8) uses *same-\(a\)* final-sector orthogonality, not coherent path orthogonality. Failure mode: swapping the order \(P\Pi_a\) and \(\Pi_aP\), or falsely asserting all \(t_{ba}\) are orthogonal.
4. **Zero triples:** (11) counts **nonzero pair fibers only**. The source triple labels are nonzero, and exactly three possible survivor/triple coincidences must be removed. Failure mode: forgetting corrections or misplacing the \(\Pi_d\) projector relative to the noncommuting effect \(P\).
5. **Distribution and oracle:** uniform hidden dual source is indispensable for the orthogonal Walsh projection; only original \(a\in R\) are queried; \(0\)-label is free and cannot be charged as an independent input symbol.
6. **Independent local falsifier:** \`scripts/audit_t2_rankfree_frames_independent.py\` checks 12 independent seeded **14-dimensional** complex models, variable-rank query sectors, positive nonprojective noncommuting effects, four-slot frequency expansion, all six grouped-equality energies, four extended zero-triple energies and exact overlap corrections, and an explicit wrong-stage-weight negative control. Existing \`check_t2_complex_grouping_exact.py\` uses a **different**, Gaussian-rational single-projector implementation. Numerical success does NOT prove the theorem; the analytic lemmas above do.
7. **Next kernel target:** name and prove (1)-(3), (8), (11)-(14), disjoint trichotomy and uniform-Walsh projection in pinned Lean without treating any of them as an assumed theorem or inserting \`sorry\`/\`axiom\` to manufacture a terminal. Require **fail-closed** independent \`leanchecker\`, named axiom audit and exact source receipt. Internal non-author-style review through Lemnis must independently attempt to falsify (8) and (12)-(14); external specialist review remains separate.
8. **Prior art and priority:** standard quantum query model, Fourier character orthogonality, PSD trace pinching are antecedents; Lovitz–Petrov 2023 gives tensor circuit controls, not the abstract operator lemma. GMNR, BDST 2026 and Li 2026 must be compared by exact oracle/access/error scope. No dated same-scope novelty clearance yet. Human owner controls submission/publication.

**Status classification:** **complete mathematical paper proof**, **reproducible finite adversarial checks**, **NOT Lean-kernel-certified**, **NOT independently mathematically refereed**, **NOT cleared as globally novel**. The theorem's validity and proof-checking status must not be conflated.
