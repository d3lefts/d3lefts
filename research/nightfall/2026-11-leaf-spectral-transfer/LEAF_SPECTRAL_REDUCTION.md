# Leaf-spectral reduction of the cubic product influence frontier

**NIGHTFALL research checkpoint — 11 November 2026 UTC**  
Research direction: Devin J. Wright. **Status: conditional analytic theorem, with exact independently reimplemented finite controls; NOT an unconditional cubic exponent-two theorem, an end-to-end Lean theorem, an outside referee report, or an originality determination.**

## Objective and imported premise

Connect the optimized one-leaf projection of draft PR #347, the logarithm-free scalar-coordinate `ell_1` quadratic matching operator in the same PR, and the spectral observability program. Crucially, do **not** extrapolate the latter to arbitrary single Hilbert-valued leaf blocks: that extrapolation is false (counterexample below).

**Exact imported premise Q2(\(C_Q\)).** For any finite independent product of *control* inputs and any finite scalar-output vector \(g=(g_{ka})_{k,a}\), each coordinate of Hoeffding degree at most two, if
\[
\sum_{k,a}|g_{ka}(x)|\le A\quad\text{for all control states }x,
\]
then
\[
\sum_{k,a}\operatorname{Var}(g_{ka}) \le C_Q A\sqrt{\sup_i\sum_{k,a} I_i(g_{ka})}.
\]
PR #347 proposes \(C_Q=16(1+\sqrt3)\sqrt2\), relying on its **not yet independently refereed** quadratic matching proof. Everything below is a valid implication if Q2 holds; do not cite this note as an independent proof of Q2. The finite full-support setup is sufficient for the exact algebra. Arbitrary completed products require separate measurable approximation.

## Theorem A — leaf-spectral selector inequality (conditional on Q2)

Let \(X\) be independent controls, \(Y_1,\dots,Y_K\) independent leaves, and
\[
f(X,Y)=\sum_{k=1}^K G_k(X)(Y_k),\quad E_{Y_k}G_k(x)(Y_k)=0,
\quad |f|\le B.
\]
Assume \(G_k:X\to H_k=L^2_0(Y_k)\) has control Hoeffding degree at most two. For each \(k\), choose an arbitrary fixed orthogonal projection \(P_k:H_k\to H_k\) of rank at most \(t\ge1\), independent of \(X\). Define
\[
V=\operatorname{Var}(f),\quad
M=\sup_j I_j(f),\quad
\tau_t=\sum_k E_X\|(I-P_k)G_k(X)\|_{H_k}^2 .
\]
Then
\[
\boxed{V\le \tau_t+[1+C_Q\sqrt t]\, B\sqrt M .}\tag{A}
\]
In particular, with PR #347's proposed \(C_Q=D\sqrt2\), \(D=16(1+\sqrt3)\), the coefficient is \(1+D\sqrt{2t}\). The coefficient depends on **leaf-section feature rank**, not leaf alphabet cardinality or minimum atom mass; no number-of-leaves factor occurs.

**Proof.** Condition on \(X=x\). Independence of the leaves gives an essential-range width of \(f(x,\cdot)\) equal to the sum of its leaf widths \(R_k(x)\), at most \(2B\). Popoviciu's variance inequality and leaf centering imply
\[
\sum_k\|G_k(x)\|_{H_k}\le \tfrac12\sum_k R_k(x)\le B.
\]
Fix an orthonormal basis \(e_{ka}\), \(1\le a\le t\), for each projected space, padding with zeros if needed. Put \(g_{ka}(x)=\langle G_k(x),e_{ka}\rangle\). Cauchy--Schwarz *within each leaf* yields \(\sum_{k,a}|g_{ka}(x)|\le\sqrt t\sum_k\|G_k(x)\|\le\sqrt t B\). Each scalar coefficient has control degree at most two. Write \(W_t=\sum_{k,a}\operatorname{Var}_X g_{ka}\). By Q2 and orthogonal projection contraction,
\[
W_t\le C_Q\sqrt t B\sqrt{\sup_i\sum_{k,a}I_i(g_{ka})}\le C_Q\sqrt t B\sqrt M .
\]
The projected mean contribution satisfies
\[
\sum_k\|E_X P_kG_k\|^2
\le \big(\max_k\|E_XP_kG_k\|\big)\sum_k\|E_XP_kG_k\|
\le \sqrt M\,B,
\]
because \(I_{Y_k}(f)=E_X\|G_k(X)\|^2\le M\) and \(\sum_k\|E_XP_kG_k\|\le E_X\sum_k\|G_k\|\le B\).
Finally, leaf orthogonality and Parseval give \(V=\tau_t+W_t+\sum_k\|E_XP_kG_k\|^2\). QED.

**Canonical spectral choice.** \(P_k\) may be the first \(t\) eigenvectors of the uncentered positive trace-class covariance operator \(\mathcal C_k=E_X[G_k\otimes G_k]\); then \(\tau_t=\sum_k\sum_{j>t}\lambda_j(\mathcal C_k)\). No selected leaf bases are required by the eventual observation policy: they are analytical witnesses.

## Theorem B — cubic one-leaf spectral defect (conditional on Q2)

Let \(|F|\le B\) have scalar Hoeffding degree at most three on a finite arbitrary product, \(V=\operatorname{Var}(F)\), and \(M=\max_i I_i(F)\). Color every coordinate independently as a leaf with probability
\[
p_*=1-1/\sqrt3=:\alpha.
\]
For a coloring \(L\), let \(Q_L F=\sum_{|S\cap L|=1} F_S\). In each such selector, take best rank-\(t\) control-independent projections on each leaf space and denote the resulting aggregate leaf spectral tail by \(\tau_t(L)\). Set \(\bar\tau_t=E_L\tau_t(L)\). Then
\[
\boxed{\alpha V\le \bar\tau_t+
18[1+C_Q\sqrt t]B\sqrt M.}\tag{B}
\]
Indeed, the one-leaf retention identity gives \(E_L\operatorname{Var}(Q_LF)\ge\alpha V\); Markov's degree-three endpoint derivative yields \(\|Q_LF\|_\infty\le18B\), and ANOVA orthogonality gives \(I_i(Q_LF)\le I_i(F)\). Apply (A) at each coloring and average. In the zero-tail subclass,
\[
M\ge\left(\frac{\alpha}{18(1+C_Q\sqrt t)}\right)^2 \frac{V^2}{B^2}.
\]
More generally, if \(\bar\tau_t\le\theta\alpha V\) for \(0\le\theta<1\), then the same bound holds multiplied by \((1-\theta)^2\).

**Exact remaining frontier:** prove an alphabet-independent leaf-aware quadratic inequality without any finite-rank assumption, or control the spectral defect \(\bar\tau_t\) by input influence. Merely proving the rank-one case does not suffice.

## Necessary falsification — the naive Hilbert upgrade is FALSE

Let \(X_1,\ldots,X_n\) be independent fair signs and \(Y\) uniform on \([n]\). Regard the centered section
\[
G(X)(y)=X_y-\overline X,\qquad \overline X=n^{-1}\sum_i X_i
\]
as one degree-one control function with values in the Hilbert space \(H=L^2_0(Y)\). Exactly,
\[
\|G(X)\|_H\le1,\quad
E\|G-E_XG\|_H^2=1-1/n,\quad
I_{X_i}(G)=(n-1)/n^2.
\]
Therefore the ratio \(W/(B\sqrt{\max_i I_{X_i}(G)})=\sqrt{n-1}\to\infty\). There is **no** dimension-free Hilbert-valued quadratic inequality that uses only control influences and \(\|G(X)\|_H\le B\), even at control degree one. This does not refute (A), because the associated scalar selector \(f(X,Y)=X_Y-\overline X\) has leaf influence \(I_Y(f)=1-1/n\). The leaf-influence term is indispensable.

The exact rational checker `check_leaf_spectral.py` independently enumerates this obstruction and directly verifies the selector variance/influence decompositions on small categorical examples. It does not certify the imported Q2 statement.

## Prior art, audit and next decisive test

- O'Donnell--Zhao (CCC 2016), *Polynomial Bounds for Decoupling, with Applications*, https://arxiv.org/abs/1512.01603 — one-block decoupling and Boolean-cube equivalences precede this program.
- Turturean (6 Nov 2026), https://arxiv.org/abs/2611.09773 — general-degree \(5/2\) influence exponent on the uniform cube.
- NIGHTFALL [PR #347](https://github.com/d3lefts/d3lefts/pull/347) — optimized coloring and conditional \(\ell_1\)-quadratic source; [PR #335](https://github.com/d3lefts/d3lefts/pull/335) — independent top-cover transfer; [PR #332](https://github.com/d3lefts/d3lefts/pull/332) — general-degree adaptive spectral observer candidate.

**Independent proof-attack plan:** (1) Referee or formalize the exact Q2 matching-to-fourth-moment step, including the \(\ell_1\) coefficient budget; (2) attack (A) on rare-symbol heterogeneous leaves with dimension \(t=1,2,3\), directly computing all resampling influences; (3) test the sharpness of \(\sqrt t\), e.g. random orthogonal and one-hot leaf bases; (4) check if projected covariance-tail estimates survive arbitrary posterior conditioning; (5) only then infer an adaptive query budget. No global novelty, publication, or full cubic closure is asserted.


## Corollary C — posterior-stable leaf spectrum implies adaptive O(1/eta) observation (conditional)

Under Theorem B, put C_t=18(1+C_Q sqrt(t))/(alpha(1-theta)). Assume that **every positive-probability finite-product posterior after any possible coordinate transcript** satisfies the same aggregated one-leaf spectral-defect hypothesis \`bar_tau_t <= theta*alpha*Var(f_posterior)\`, with fixed t and theta<1. This posterior-stability assumption is essential: a spectral condition verified only at the initial law is **not enough** for adaptive prediction.

For each posterior, Theorem B supplies \`Var(f_posterior)<=C_t B sqrt(M_posterior)\`, with a bound B inherited under conditioning. Let \`T=sum_i I_i(f_posterior)\`; ANOVA gives \`Var<=T<=3 Var\`, and for the coordinate of maximum posterior influence the exact one-step identity is \`E[T_after | transcript]=T-M\`. Hence \`M>=T^2/(9 C_t^2 B^2)\` at every nonconstant posterior. The expected potential \`p_n=E T_n\` therefore obeys
\[
p_{n+1}\le p_n-\frac{p_n^2}{9C_t^2 B^2},\qquad
p_n\le\frac{9 C_t^2 B^2}{n}\quad(n\ge1).
\]
Thus the conditional-mean predictor has mean squared risk at most \`eta\` after \`ceil(9 C_t^2 B^2 / eta)\` whole-coordinate queries, independent of input dimension and leaf alphabet sizes. This is a **conditional finite-product query-count corollary only**: it does not control computational cost, prove posterior spectral stability for general cubic inputs, or fill the measurable infinite-product bridge.

**Decisive follow-up test:** seek a natural structural condition under which leaf-spectrum defect bounds are inherited by every posterior, or construct a finite rational counterexample showing posterior instability. This is an actual information-structure gate, not a request to optimize numerical constants.


## Theorem D — posterior-stable finite-feature selectors (conditional, log-free adaptive law)

The spectral-defect hypothesis of Corollary C is **automatically posterior-stable** for the following concrete subclass; no global one-leaf-color spectral assumption is required.

Let controls \`X\` and leaves \`Y_1,...,Y_K\` be independent *finite full-support* random variables, and let
\[
f(X,Y)=h(X)+\sum_{k=1}^K G_k(X)(Y_k),\qquad |f|\le B.
\]
Assume (i) \`h\` has control Hoeffding degree at most two; (ii) each \`G_k(X)(Y_k)\` is centered in \`Y_k\` for each \`X\`, and has control Hoeffding degree at most two; (iii) there is a **fixed, control-independent** linear subspace \`E_k\subset L^2_0(Y_k)\` of dimension at most \`t\`, with \`G_k(X)\in E_k\` for every control state. There may be arbitrarily many leaves and control coordinates; their alphabet sizes and atom masses are unrestricted.

Under the explicit imported Q2(\`C_Q\`) premise and the scalar quadratic product-space bound
\[
\operatorname{Var}(h)\le D\|h\|_\infty
 \sqrt{\sup_i I_i(h)},\qquad D=16(1+\sqrt3),
\]
we obtain
\[
\boxed{\operatorname{Var}(f)\le C_t B\sqrt{M},\qquad C_t=D+1+C_Q\sqrt t.}\tag{D1}
\]
Here \`M\` is the maximum resampling influence across **both controls and leaves**.

**Proof.** \`h=E[f|X]\`, so \`|h|\le B\`, \`I_i(h)\le I_i(f)\`, and the scalar quadratic premise bounds \`Var(h)\le DB\sqrt M\`. For the leaf part, the bounded range in each fiber \`X=x\` gives \`sum_k ||G_k(x)||_{L2(Y_k)}<=B\`. Expand each \`G_k\` in an orthonormal basis of its fixed at-most-\`t\)-dimensional subspace. The total scalar coefficient l1 norm is at most \`sqrt(t) B\`; Q2 bounds the **centered** control coefficient energy by \`C_Q sqrt(t) B sqrt(M)\`. The squared coefficient means sum to at most \`B sqrt(M)\` by leaf influences and the same pointwise norm budget, as in Theorem A. Orthogonality between \`h-Eh\` and the centered leaf terms gives (D1).

**Posterior closure.** A revealed control coordinate merely restricts each coefficient to a control section and preserves control degree <=2 and its fixed leaf subspace. A revealed leaf \`Y_k=y\` converts \`G_k(X)(y)\` into an additional control-only degree-<=2 summand of \`h\`, and deletes that leaf from the sum. Every positive-probability transcript therefore remains in this class with the **same** \`t\`, \`D\`, \`C_Q\`, and uniform bound \`B\`. The representation need not use a single canonical \`h\` across transcripts. Crucially, this closure does not assume control-only Hilbert influence.

At every posterior, \`Var<=C_t B sqrt(M)\`. The exact degree-three ANOVA potential identity then yields, by greedy largest-influence observation,
\[
\boxed{E\operatorname{Var}(f\mid\text{transcript after }N\text{ queries})
 \le\eta\quad\text{if}\quad
 N\ge \left\lceil \frac{9 C_t^2 B^2}{\eta}\right\rceil.}\tag{D2}
\]
This is a **log-free**, leaf-alphabet-free, dimension-free *finite-product* adaptive query guarantee for a concrete posterior-stable class, **conditional** on Q2 and the scalar quadratic influence theorem. If PR #347's suggested \`C_Q=D sqrt(2)\` is validated, \`C_t=D+1+D sqrt(2t)\` and the cost scales \`O(t B^2/eta)\` for fixed numerical quadratic constants. No efficient coordinate-selection algorithm is asserted.

**What differs from PR #347:** that note explicitly treats *rank-one* leaf features for its alphabet-free logarithm-free bound; (D1)-(D2) extend the mechanism to fixed but arbitrary per-leaf section rank \`t\`, including a control-only degree-two summand that is essential for closure after adaptive leaf observations. No unrestricted rank claim follows, and no end-to-end formal or independent outside referee certificate exists.

**Next audit:** independently test the exact posterior structural closure on all finite transcripts for small control/leaf systems; directly prove the Q2 matching step in a standalone proof that does not cite an analogous result as its conclusion. Prior-art comparison must distinguish this bounded per-leaf-section-rank subclass from one-block decoupling and classical Hilbert-valued U-statistic inequalities.
