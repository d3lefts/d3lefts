# Fair-sign quadratic influence by mixed Littlewood; rank-t leaf observability

**Checkpoint:** 2026-11-11 UTC. Research direction: Devin J. Wright / NIGHTFALL.  
**Status:** self-contained finite-product analytic derivation using the classical sharp real Khintchine inequality, with independent exact finite falsification. No end-to-end Lean formalization, independent human refereeing, or worldwide novelty certification. The arbitrary-law degree-two and unrestricted cubic (2,4) inequalities remain **OPEN**.

## Cross-session deduplication (performed before this construction)

Recovered prior NIGHTFALL sessions and inspected current live repository branches:

- #317/#325: finite-product scalar (5/2,6) theorem, Lean checked; not the present squared-variance endpoint.
- #327/#329/#335/#336: cubic fourth-moment obstruction, selector logarithm, top-degree covers, and scoped Lean algebra.
- #338: five-priority audit and weighted transversal LP barrier.
- #347: proposed law-free \(\ell_1\)-valued quadratic inequality with coefficient \(D\sqrt 2\), where \(D=16(1+\sqrt3)\), **conditional on an unreviewed matching/fourth-moment argument**; also bounded shared controls and two-draw occupancy no-go.
- #348: degree-dependent squared-variance influence on the uniform cube via pointwise sensitivity, including degree 2 and degree 3; this note must **not** claim a first exponent-two theorem for Boolean cubes.
- #349: homogeneous/tripartite cubic reduction, link-energy conjecture, Hadamard stress tests, coefficient-one falsifier.
- #350: posterior-stable leaf-spectral rank theorem conditional on the unverified general-product \(\ell_1\) quadratic premise.

**Nonduplicate change:** the present result independently **discharges** that premise for any number of *fair Rademacher control inputs*, with explicit coefficient 4, and consequently gives an **unconditional** fixed-leaf-rank, alphabet-independent finite-product observation theorem in that narrower control model. It does NOT lift the theorem to biased or arbitrary-alphabet controls.

## Definitions and imported standard inequality

For independent fair signs \(X=(X_1,\ldots,X_n)\) and a vector \(G=(g_a)_{a=1}^K:\{-1,1\}^n\to\mathbb R^K\), put

\[
W(G)=\mathbb E\|G-\mathbb E G\|_2^2,\qquad
J_i(G)=\mathbb E\|G-\mathbb E_iG\|_2^2,\qquad
M(G)=\max_i J_i(G).
\]

Each \(g_a\) has Fourier-Walsh degree at most two. Assume the **pointwise** output norm \(\|G(x)\|_1=\sum_a|g_a(x)|\le A\).

Only one external inequality is imported, the sharp real \(p=1\) Khintchine inequality and its Hilbert-valued extension (Latała–Oleszkiewicz):

\[
\mathbb E_\epsilon\left\|\sum_j\epsilon_j v_j\right\|_H
\ge\frac1{\sqrt2}\left(\sum_j\|v_j\|_H^2\right)^{1/2}
\]
for any finite family of vectors in a real Hilbert space. For an independent symmetric sum \(Z\), the same lower bound for \(v_0+Z\) is obtained by inserting an independent fair sign on \(v_0\); because \(Z\stackrel d=-Z\), this insertion does not change the expected norm.

The mixed \((\ell_1,\ell_2)\) Littlewood inequalities and their \((\sqrt2)^{m-1}\) constants were studied long before NIGHTFALL, notably Pellegrino (2015/2016), https://arxiv.org/abs/1501.00965. **Do not assert novelty of the Khintchine or mixed Littlewood operator.**

## Lemma 1 — one-leaf signed section

Let \(L\subseteq[n]\), \(C=[n]\setminus L\). Define

\[
Q_LG(x)=\tfrac12(G(x_L,x_C)-G(-x_L,x_C)).
\]

Since \(\deg G\le2\), this is precisely the sum of Fourier components with **exactly one** index in \(L\). It has the representation

\[
Q_LG(y,x)=\sum_{i\in L}y_i a_i(x),\qquad
a_i(x)=v_i+\sum_{j\in C}x_j T_{ij}\in\mathbb R^K.
\]

The pointwise bound passes **without a norm-loss**:
\(\|Q_LG(y,x)\|_1\le A\).
Orthogonal Fourier projection gives \(J_i(Q_LG)\le J_i(G)\) for every \(i\).

Fix \(x\in\{\pm1\}^{C}\). For every output sign vector \(\sigma\in\{\pm1\}^K\),

\[
\sum_{i\in L}|\langle\sigma,a_i(x)\rangle|
=\sup_{y\in\{\pm1\}^{L}}\langle\sigma,Q_LG(y,x)\rangle
\le A.
\]

Average over \(\sigma\) and use scalar Khintchine to obtain
\(\sum_{i\in L}\|a_i(x)\|_2\le\sqrt2 A\).
Average over the fair control signs \(x\in C\) and use Hilbert Khintchine with the extra independent sign on \(v_i\):
\[
\mathbb E_x\|a_i(x)\|_2
\ge\frac1{\sqrt2}\left(\|v_i\|_2^2+\sum_{j\in C}\|T_{ij}\|_2^2\right)^{1/2}
=\frac1{\sqrt2}\sqrt{J_i(Q_LG)}.
\]
Thus the mixed-slice estimate is
\[
\boxed{\sum_{i\in L}\sqrt{J_i(Q_LG)}\le2A.}\tag{1}
\]

Every retained component has exactly one leaf coordinate. Therefore
\(W(Q_LG)=\sum_{i\in L}J_i(Q_LG)\), and by (1),
\[
\boxed{W(Q_LG)\le2A\sqrt{M(G)}.}\tag{2}
\]

This proof does **not** assume that \(Q_LG\) has independently distributed vector coefficients or any uniform \(L^4/L^2\) ratio for biased variables.

## Theorem 2 — unconditional fair-sign vector quadratic influence

**Theorem.** Under the degree-two and \(\ell_1\)-bounded hypotheses above,
\[
\boxed{W(G)\le4A\sqrt{M(G)},\qquad
M(G)\ge\frac{W(G)^2}{16A^2}}\tag{3}
\]
for \(A>0\), with the zero-variance case trivial. The result is independent of \(n\) and output dimension \(K\).

**Proof.** Independently label every input coordinate as leaf with probability \(1/2\). For each Fourier support \(S\) of size one or two, the probability that \(|S\cap L|=1\) is exactly \(1/2\). Parseval therefore gives
\(\mathbb E_L W(Q_LG)=W(G)/2\).
Equation (2) bounds each \(W(Q_LG)\le2A\sqrt{M(G)}\).
Take expectations and multiply by two. QED.

**Boundary:** the norm-one projection \(Q_L=(I-R_L)/2\), where \(R_L\) flips the leaf signs, and the second Khintchine step both exploit genuinely fair signs. Replacing the inputs with arbitrary biased/categorical variables is **not justified** by two-draw averaging: #347 gives an exact occupancy obstruction to the expected-maximum transfer. This restriction is essential to the claim.

## Theorem 3 — unconditional alphabet-free cubic rank-one leaves

Let \(X\) consist of any number of independent **fair signs**, let \(Y_1,\ldots,Y_K\) be independent arbitrary finite-alphabet leaves, independent of \(X\), and let
\[
f(X,Y)=\sum_{k=1}^K u_k(X)\phi_k(Y_k),\qquad
\mathbb E\phi_k(Y_k)=0,\quad \deg_Xu_k\le2,\quad |f|\le B.
\]
Define \(V=\operatorname{Var}(f)\), \(M=\max_i I_i(f)\) over **all** controls and leaves, and \(B>0\).

Conditioning on \(X=x\), the independent leaf ranges add. Popoviciu's inequality and centering yield
\[
\sum_k |u_k(x)|\,\|\phi_k\|_{L^2(Y_k)}\le B.
\]
Write \(g_k=u_k\|\phi_k\|_2\). Theorem 2 gives
\(\sum_k\operatorname{Var}_X(g_k)\le4B\sqrt M\), since control influences of the vector \(g\) are bounded by the scalar \(f\)'s control influences.
Furthermore \(I_{Y_k}(f)=\mathbb E g_k^2\le M\), and
\(\sum_k|\mathbb E g_k|\le B\); hence
\(\sum_k(\mathbb E g_k)^2\le B\sqrt M\).
Orthogonality proves
\[
\boxed{V\le5B\sqrt M,\qquad M\ge\frac{V^2}{25B^2}.}\tag{4}
\]
The leaf alphabets may be arbitrarily large, irregular, and have arbitrarily small positive atom probabilities. **The control inputs, not the leaves, must be fair signs.** This is stronger in scope than a scalar trilinear Boolean-only statement but narrower than the open arbitrary-product cubic theorem.

## Theorem 4 — leaf-spectral tail and posterior-stable adaptive recovery

More generally let
\[
f(X,Y)=h(X)+\sum_{k=1}^K G_k(X)(Y_k),\qquad |f|\le B,
\]
where \(h\) and every scalar section of \(G_k\) have control degree at most two, each \(G_k(X)\in L^2_0(Y_k)\), and the \(X\)-coordinates are independent fair signs. Fix for each leaf a **control-independent** orthogonal projection \(P_k\) of rank \(\le t\ge1\) onto centered leaf features. Put
\[
\tau_t=\sum_k\mathbb E_X\|(I-P_k)G_k(X)\|_{L^2(Y_k)}^2.
\]
Then
\[
\boxed{V(f)\le\tau_t+(5+4\sqrt t)B\sqrt{M(f)}.}\tag{5}
\]

**Proof.** The scalar \(h=\mathbb E[f|X]\) is bounded by \(B\), and (3) for \(K=1\) gives \(\operatorname{Var}_X(h)\le4B\sqrt M\).
Pointwise independent-leaf range control gives \(\sum_k\|G_k(x)\|_2\le B\). In fixed orthonormal bases of the projected subspaces, the collection of all scalar control coefficients has \(\ell_1\) norm at most \(\sqrt t B\). Theorem 2 bounds their **centered** control energy by \(4\sqrt t B\sqrt M\). Their mean-square energy is at most \(B\sqrt M\), as in Theorem 3. Residual leaf energy is orthogonal to the projected and control-only terms, and equals \(\tau_t\). Thus (5).

**Exact-rank subclass.** If \(G_k(X)\) always lies in a fixed at-most-\(t\)-dimensional centered leaf subspace, then \(\tau_t=0\). The structure is preserved after **every** positive-probability adaptive coordinate transcript:
- observing a fair control sign restricts the remaining degree-two coefficient sections and leaves the remaining controls independent and fair;
- observing a leaf \(Y_k=y\) replaces its term by the degree-two control function \(G_k(X)(y)\), added to \(h\); all unqueried leaves retain the same fixed subspaces;
- the posterior output remains bounded by the original \(B\).

Consequently every posterior obeys \(V_{\rm post}\le C_tB\sqrt{M_{\rm post}}\), with \(C_t=5+4\sqrt t\). The degree is at most three. For the ANOVA potential \(T=\sum_i I_i\), \(V\le T\le3V\), and querying a maximal-influence coordinate gives
\(\mathbb E[T_{\rm after}\mid\text{transcript}]=T-M\).
Therefore \(M\ge T^2/(9C_t^2B^2)\) and Jensen gives
\(p_{n+1}\le p_n-p_n^2/(9C_t^2B^2)\) for \(p_n=\mathbb ET_n\). Hence \(p_n\le9C_t^2B^2/n\). The conditional-mean observer has MSE at most \(\eta>0\) after at most
\[
\boxed{N=\left\lceil\frac{9(5+4\sqrt t)^2B^2}{\eta}\right\rceil}\tag{6}
\]
whole-coordinate queries, or earlier if the finite inputs are exhausted. This is a **finite-product query count**, not computational runtime. There is no leaf-count, leaf-alphabet or minimum-atom factor, and there is no logarithmic overhead.

**Important:** An *initial* small spectral tail \(\tau_t\) need not remain small after posterior restrictions. Equation (6) is asserted only for the **fixed exact-rank subclass** (or a separately proven uniformly posterior-stable tail condition), not for general initial-only approximate rank.

## Exact replay and independent audit

A second implementation with exact fractions (no floating tolerance) independently enumerated 6,560 nonzero 2-by-2-by-2 trilinear integer coefficient tensors; each obeyed the *stronger* pure trilinear implication \(V^2\le4B^2M\), with maximum observed normalized squared ratio 2. It also ran 500 additional finite degree-two \(\ell_1\)-vector stress examples over up to five fair-sign controls, all satisfying (3). The committed checker uses deterministic input and exact integer/rational arithmetic. These checks falsify specific finite statements; they **do not replace** the Khintchine proofs or establish worldwide novelty.

Audit independently: (i) verify the signed-flip projector is exactly one-leaf at degree <=2; (ii) verify the two separate uses of Khintchine and the constant-offset symmetrization; (iii) verify \(\mathbb E_L W(Q_L)=W/2\); (iv) verify the leaf range/Popoviciu and coefficient \(\ell_1\) bounds; (v) prove posterior closure for all finite transcripts, with zero-probability events excluded; (vi) test against rare-leaf feature distributions and the Hadamard and occupancy examples from #347/#349. The independent proof review and prior-art certification gates are **not** fulfilled merely by CI.

## External priority and significance

- Daniel Pellegrino, *The optimal constants of the mixed (\(\ell_1,\ell_2\))-Littlewood inequality*, arXiv:1501.00965 / J. Number Theory 160 (2016), established the mixed multilinear principle and \((\sqrt2)^{m-1}\) constants: https://arxiv.org/abs/1501.00965.
- Classical Khinchine and Latała–Oleszkiewicz vector-valued extension (see https://doi.org/10.1007/s00208-023-02669-9).
- O'Donnell and Zhao (CCC 2016), one-block polynomial decoupling: https://arxiv.org/abs/1512.01603.
- Turturean (6 November 2026), uniform-cube (5/2,6): https://arxiv.org/abs/2611.09773.
- NIGHTFALL #348 already proves a *different* degree-dependent exponent-two bound for uniform cubes, so (3) is a **new within-program unconditional \(\ell_1\)-vector bridge with a small constant**, not a claimed first Boolean-cube exponent-two discovery.
- This paper has no global-priority clearance. Its main contribution to this program is removing the previously conditional quadratic matching dependency from the fair-sign-control branch of #350. Heterogeneous/biased **controls**, unrestricted leaf Hilbert rank, arbitrary measurable products, full cubic (2,4), and end-to-end Lean proofs remain open.

**Next cheapest decisive experiment:** port the two-step mixed Littlewood certificate to *biased two-point controls* with a carefully tracked distortion parameter; compare against the #347 distributed-address occupancy no-go. Reject any assertion of a law-free bound until the distortion has been eliminated by a genuine proof rather than an invalid expectation/max swap.


## Theorem 5 — heterogeneous controls on one side, fair signs on the other (unconditional)

A second representation change removes **all atom-mass dependence in one entire control block** while preserving a dimension-free squared-variance bound.

**Law-free additive vector lemma.** Let \(U=(U_a)_{a=1}^K\) be additive in independent arbitrary finite-alphabet coordinates \(X_i\), with \(\sup_x\|U(x)\|_1\le A\), and \(J_i(U)=\mathbb E\|U-\mathbb E_iU\|_2^2\). Then
\[
\boxed{\sum_i\sqrt{J_i(U)}\le\sqrt2\,A,\qquad
\operatorname{Var}_{\ell_2}(U)\le\sqrt2 A\sqrt{\max_iJ_i(U)}.}\tag{7}
\]
**Proof independent of biases.** For every output sign vector \(\sigma\in\{\pm1\}^K\), the scalar \(\langle\sigma,U(x)\rangle\) is additive, bounded in \([-A,A]\), and has independent coordinate-section ranges \(R_i(\sigma)\) satisfying \(\sum_iR_i(\sigma)\le2A\). Popoviciu implies \(\sqrt{\operatorname{Var}\langle\sigma,U_i\rangle}\le R_i(\sigma)/2\), hence the sum of these scalar standard deviations is at most \(A\). Writing the covariance matrix of centered \(U_i\) as \(\Sigma_i\succeq0\), Hilbert Khintchine gives
\[
\mathbb E_\sigma\sqrt{\sigma^\top\Sigma_i\sigma}
\ge\frac1{\sqrt2}\sqrt{\operatorname{tr}\Sigma_i}
=\frac1{\sqrt2}\sqrt{J_i(U)}.
\]
Average over \(\sigma\), sum over \(i\), and use independence/ANOVA. No fair-control or minimum-mass assumption appears in (7); only **additivity** is essential.

Now let \(X=(X_i)\) be arbitrary independent finite-alphabet controls with any normalized positive laws, \(Z=(Z_j)\) be independent fair-sign controls, independent of \(X\), and let
\[
G(X,Z)=g_0+\sum_i u_i(X_i)+\sum_j v_j Z_j+
             \sum_{i,j} w_{ij}(X_i) Z_j\in\mathbb R^K,
\]
where \(u_i,w_{ij}\) are centered in \(X_i\), \(\|G(X,Z)\|_1\le A\) pointwise, and all sums are finite. Thus **every component has Hoeffding degree at most one in each of the two blocks**, with no quadratic interaction contained wholly inside \(X\) or \(Z\). Put \(W=\mathbb E\|G-\mathbb EG\|_2^2\) and \(M=\max_iI_i(G)\) over \(X\) and \(Z\). Then
\[
\boxed{W\le(2+2\sqrt2)A\sqrt M.}\tag{8}
\]

**Proof.** Flip all \(Z\)-signs to form the norm-one odd and even projections:
\[
G_{\mathrm{odd}}=(G(X,Z)-G(X,-Z))/2,\quad
G_{\mathrm{even}}=(G(X,Z)+G(X,-Z))/2.
\]
Both have \(\ell_1\)-norm at most \(A\). The even part is additive in the arbitrary \(X_i\), so by (7) its centered energy is at most \(\sqrt2 A\sqrt M\). The \(X\)-mean of the odd part is additive in the fair \(Z_j\), bounded by \(A\), so its variance is likewise at most \(\sqrt2 A\sqrt M\).

For each fixed sign pattern \(Z=z\), the odd function of \(X\) is additive and \(\ell_1\)-bounded by \(A\). Therefore (7) gives
\(\sum_i\sqrt{I_{X_i}(G_{\mathrm{odd}}(\cdot,z))}\le\sqrt2 A\).
For each \(i\), the centered \(X_i\)-section of the odd part is a Hilbert-valued Rademacher sum \(\sum_j z_j w_{ij}(X_i)\) in \(H_i=L_0^2(X_i;\mathbb R^K)\). The sharp Hilbert Khintchine inequality yields
\[
\mathbb E_Z\sqrt{I_{X_i}(G_{\mathrm{odd}}(\cdot,Z))}
\ge\frac1{\sqrt2}\sqrt{I_{X_i}(G_{\mathrm{odd}})}.
\]
Average the previous additive bound over \(Z\). It follows that
\(\sum_i\sqrt{I_{X_i}(G_{\mathrm{odd}})}\le2A\).
By exact bi-degree-(1,1) ANOVA, the **cross** variance equals
\(\sum_i I_{X_i}(G_{\mathrm{odd}})\), so it is at most \(2A\sqrt M\).
The three centered parts (even \(X\)-only, odd \(Z\)-only, and \(X\)-\(Z\) cross) are pairwise orthogonal; their total variance is bounded by
\((\sqrt2+\sqrt2+2)A\sqrt M\). QED.

This result is **unconditional even when the \(X_i\) alphabets are arbitrarily large or their atom probabilities arbitrarily small**. It requires at least the second block \(Z\) to consist of fair signs and excludes same-side higher interactions among the arbitrary controls. It does not prove the full law-free \(Q2\) conjecture in #347.

### Posterior-stable mixed-control leaf-rank corollary

Let \(Y_k\) be independent arbitrary finite-alphabet leaves, and
\[
f(X,Z,Y)=h(X,Z)+\sum_k G_k(X,Z)(Y_k),\quad |f|\le B,
\]
where \(h\) and every scalar section of \(G_k\) have the **bi-degree-(1,1)** representation of (8), and each \(G_k(X,Z)\) belongs to a fixed centered leaf-feature subspace of dimension at most \(t\ge1\).

Write \(C_{\mathrm{mix}}=2+2\sqrt2\). The same range/Popoviciu, fixed-basis \(\ell_1\), mean-square leaf energy, and ANOVA arguments as Theorem 4 give
\[
\boxed{\operatorname{Var}(f)\le[1+C_{\mathrm{mix}}(1+\sqrt t)]B\sqrt M.}\tag{9}
\]
Every positive-probability posterior obtained by querying any control or leaf preserves the bi-degree-(1,1) structure, the centered leaf subspaces and the bound \(B\): observing \(X_i\) or \(Z_j\) drops interaction order within its own block; observing a leaf transfers its now-known feature section into \(h\). Consequently the greedy influence observer satisfies
\[
\boxed{
N\le\left\lceil
\frac{9[1+(2+2\sqrt2)(1+\sqrt t)]^2B^2}{\eta}
\right\rceil
}\tag{10}
\]
for mean squared risk at most \(\eta\) on finite products. This extends Theorem 4 from all-fair controls to an **entire arbitrary-product block** and an independent fair-sign block, at the price of forbidding within-block degree-two interactions.

**Transfer frontier identified:** the still-open case is quadratic interaction between **two arbitrary-law control coordinates**, or leaf sections with unrestricted feature rank. The law-free additive lemma (7) is not sufficient by itself to tensorize two arbitrary-law blocks: the required \(L^1\to L^2\) promotion fails on rare symbols, and #347's two-draw occupancy example refutes a naive expected-maximum interchange. A valid next theorem needs a new joint-energy certificate that accounts for this failure.

**Additional prior art:** the additive \(\ell_1\)-vector estimate (7) and mixed-slice argument are consequences of classical range/Popoviciu and Khintchine principles. Their specific composition and constants require originality comparison; no worldwide novelty or independent non-author referee status is asserted.
