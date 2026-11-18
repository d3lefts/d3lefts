# NIGHTFALL — Robust response-hull duality: the product-influence → evidence-cost bridge

**Checkpoint:** November 17, 2026 (research candidate).  
**Objective:** identify exactly when coordinate resampling influence yields useful *observable* information after an independently changing source marginal, and make the guarantee checkable without trusting an optimizer.  
**Claim status:** exact analytic derivation with original-source rational witness; check each result against the dedicated CI below. Generic Lean proof is a supporting-hyperplane/matching-optimum implication, **not** a Lean evaluation of the JSON instance. No human referee or worldwide novelty clearance; this does **not** certify safety of any real consequential effect.

## Contract

A finite original source product `μ=μ_k⊗∏_{i≠k}μ_i`, a **fixed, everywhere-defined** function `f`, exact deterministic whole-symbol readings and squared prediction-error loss. The entire replacement law `q∈Δ(X_k)` is allowed, possibly assigning positive mass to previously null source symbols. All original function values on such new atoms must be supplied and source-authenticated. No adversarial physical source updates during a read, no dependent-law drift, and no claim of zero-error authorization.

For an already observed coordinate set `S` and a candidate `j∉S∪{k}`, define the observable expected squared-error reduction:

\[
G_j(S;q)=\operatorname{Var}_q(\mathbb E_q[f\mid X_{S∪\{j\}}])
          -\operatorname{Var}_q(\mathbb E_q[f\mid X_S]).
\]

This is **not** the resampling influence `I_j=E_q[(f-E_q[f|X_{-j}])²]`.

## Theorem 1 — observation-order curvature and exact response hull

For each possible changed-coordinate value `a`, form an ORIGINAL-MODEL response vector indexed by `z=(x_S,x_j)`:

\[
d_a(z)=\mathbb E_{\mu_{-(S∪\{j,k\})}}[f\mid X_k=a,X_{S∪\{j\}}=z]
        -\mathbb E_{\mu_{-(S∪\{k\})}}[f\mid X_k=a,X_S=z_S].
\]

Here the corresponding two expectations hold the displayed coordinates fixed and integrate only the remaining independent coordinates. These are ordinary finite sums over the original unmodified source tables, including symbols formerly of zero probability.

Let `H=L²(μ_{S∪j})`, and `K_{ab}=⟨d_a,d_b⟩_H`. This Gram matrix is positive semidefinite, with rational entries for rational input.

**If `k∉S`:**

\[
G_j(S;q)=\left\|\sum_aq_a d_a\right\|_H^2=q^T Kq.
\]

Consequently, the **exact robust guarantee** over all source marginals is

\[
\inf_{q∈Δ(X_k)}G_j(S;q)=
\operatorname{dist}\big(0,\operatorname{conv}\{d_a\}\big)^2.
\]

This minimum vanishes **if and only if** the origin lies in the response convex hull. It may occur at an INTERIOR marginal. Testing only extreme product laws is not a valid robust-information lower-bound certificate.

**If `k` has ALREADY been observed:** the gain from then observing `j` is instead

\[
G_j(S∪\{k\};q)=\sum_a q_a\|d_a\|_H^2,
\quad\inf_{q∈Δ}G_j(S∪\{k\};q)=\min_a\|d_a\|_H^2.
\]

The difference is a nonnegative conditional-response variance,

\[
G_j(S∪\{k\};q)-G_j(S;q)
=\sum_aq_a\|d_a-\overline d_q\|_H^2,
\qquad\overline d_q=\sum_aq_ad_a.
\]

**Proof:** before measuring k, the projection increment for observing j averages over k and therefore equals \(\sum q_ad_a\). Squaring its \(H\)-norm gives the Gram form. After k is measured, k's value is known on each branch, so the expected squared response norm is the affine average of squared branch responses. Subtraction gives the Hilbert variance identity; the convex-hull formula follows because all q are feasible mixture weights. Nothing in this algebra requires degree two; the *source-local structural simplification* below does.

## Theorem 2 — exact rational proof object (checker-first)

For a proposed rational distribution \(q^*\), let \(h=\sum_aq_a^*d_a\) and \(\lambda=\|h\|_H^2\). Check:

1. `q*≥0`, `sum(q*)=1`.
2. \(h=\sum q_a^*d_a\) **from the original source vectors**.
3. For **every** source symbol a, \(\langle h,d_a\rangle_H\ge\lambda\).

Then **every** admissible q has \(G_j(S;q)\ge\lambda\), and q* attains equality, so \(\lambda\) is the global minimum. Indeed, with \(v=\sum q_ad_a\),

\[
\|v\|^2-\lambda
=\|v-h\|^2+2(\langle v,h\rangle-\lambda)\ge0.
\]

These are exact rational arithmetic operations; the numerical optimizer is wholly outside the verifier. `RobustObservationHull.lean` formalizes this general supporting/matching implication with the exact type contract, under pinned Lean/Mathlib. No theorem in this scope asserts that the JSON parser or complete source model is correct.

When \(\lambda>0\), h provides a strict separating hyperplane between the origin and the response hull; when \(\lambda=0\), q* explicitly certifies cancellation. This is classical finite-dimensional convex projection/Farkas-style witness reasoning.

## Theorem 3 — the quadratic interaction-unlocking identity

Assume additionally **Efron–Stein degree ≤2 under an independent source law**, with pointwise pair-factor representation valid on every admitted source symbol. In the orthogonal Hoeffding decomposition \(f=f_∅+\sum_i f_i+\sum_{i<j}f_{ij}\), write \(w_{ij}=\|f_{ij}\|²\).

For every \(S\) not containing distinct j,k:

\[
\boxed{G_j(S∪\{k\};q)-G_j(S;q)=w_{jk}(q).}
\]

The interaction energy is exactly the additional **expected actionable information unlocked by first observing k**; this equality does not depend on the other coordinates already observed. It is a consequence of the orthogonal conditional-projection identity.

If the law at k changes, every candidate j outside the canonical pair-neighbor set \(N(k)\) retains `G_j(S)` **for every existing S disjoint from j,k**. Under the same product-law/pointwise-factor hypotheses, this follows from SCIF source-local recentering: the old singleton/pair weights involving j are unchanged. It is a source-local expected-information update, **not** stability of the globally optimal Bellman policy or of zero-error permission.

**Locality of the entire source-derived Gram proof object.** Fix the old original-product ANOVA components as pointwise tables on the common admissible source alphabet, and let `j,k∉S` be distinct. Write
\[
D=f_j(X_j)+\sum_{\ell∈S}f_{j\ell}(X_j,X_\ell),
\qquad A_a=f_{jk}(a,X_j).
\]
Then `d_a=D+A_a`. By product centering, distinct incident pair terms are orthogonal; hence the full robust Gram is
\[
\boxed{K_{ab} =
 w_j+\sum_{\ell∈S}w_{j\ell}
 +\langle f_j,A_a\rangle_{L²(\mu_j)}
 +\langle f_j,A_b\rangle_{L²(\mu_j)}
 +\langle A_a,A_b\rangle_{L²(\mu_j)}.}
\]
Once the source-derived singleton/pair tables and energies have been authenticated, **constructing the Gram for candidate j and changed k does not require enumerating the complete product space**. It costs `O(|X_k|² |X_j| + |S∩N(j)|)` exact arithmetic to assemble the table and scalar observed-edge energy, ignoring source authentication and table parsing. A zero canonical pair `f_{jk}=0` makes every `A_a=0`: the entire Gram and gain are invariant to replacement at k. This is a computational localization of expected one-step *information value*, **not** an algorithm for globally optimal dynamic recertification.

The exact original-world checker `check_quadratic_gain_locality.py` recomputes conditional sums directly on a 4-coordinate quadratic model, including previously zero-mass atoms, and tests the source-local edge identity. A pure cubic supplies a sharp counterexample: the j gain changes from 0 to 1 after editing k even though the old j–k pair projection vanishes. Thus the degree hypothesis cannot be discarded.

## Corollary — exact robust two-source acquisition-cost phase diagram

This gives a **priced information-acquisition** theorem, rather than only a qualitative influence-versus-information obstruction. Assume the *only* selectable exact sensors are the changed source k and the candidate j, with positive read prices c_k,c_j; the source law q_k can be any simplex marginal; the other marginal and original mission table are fixed. The performance requirement is a *uniform lower bound on explained variance*, at least τ, over every q_k. Define

\[
L=\operatorname{dist}\!\left(0,\operatorname{conv}\{d_a\}\right)^2,\qquad
U=\min_a\|d_a\|^2.
\]

Then the exact minimum **fixed-sensor-bundle** price is

\[
\boxed{
C^*(\tau)=
\begin{cases}
0,&\tau\le0,\\
c_j,&0<\tau\le L,\\
c_j+c_k,&L<\tau\le U,\\
+\infty,&\tau>U.
\end{cases}}
\]

**Lower bound and matching construction:** no observations capture zero variance; observing k alone has worst-law explained variance zero because the adversary may choose q_k to be a point mass. Observing j alone has robust gain exactly L by the response-hull theorem. Observing both has robust gain exactly U: by the total-variance decomposition,
\(\operatorname{Var}_q(f)=\mathbb E_q[\operatorname{Var}(f\mid X_k)]+\operatorname{Var}_q(\mathbb E[f\mid X_k])\ge U\),
with equality at the point-mass source law on a minimizing k-symbol. Thus the four cases are exhaustive and attained. This is a genuine sharp phase diagram for **robust fixed-coordinate squared-loss observation**, but it is NOT the full adaptive Bellman/recertification problem and it does not certify zero-error action safety.

For the original numerical witness below, \(L=1/6\), \(U=2/3\). With unit observation prices and threshold \(\tau=1/2\), the robust acquisition optimum is exactly two reads; under the old deterministic source law it was one. This cleanly locates a *cost jump* caused by information cancellation while the original resampling influence stays constant.

## Original-source quantitative witness: influence stays high while evidence fails

`source_bound_hull_witness.json` records the two-coordinate original mission table

| X | Y=0 | Y=1 | Y=2 |
|---|---:|---:|---:|
| 0 | 1 | −1 | 0 |
| 1 | 0 | 1 | −1 |

`Y` has uniform law on 3 outcomes. The authenticated old source law has `P(X=0)=1`; an authorized update allows **any** new `P(X=0)=p∈[0,1]`. The mission function is everywhere bounded by 1 and has product degree ≤2 (the two-site case is degenerate as a degree bound).

The original-world responses are \(d_0=(1,-1,0)\), \(d_1=(0,1,-1)\), giving

\[
K=\begin{pmatrix}2/3&-1/3\\-1/3&2/3\end{pmatrix},\quad
G_Y(∅;p)=\frac16+2(p-\tfrac12)^2.
\]

Both endpoint laws have gain **2/3**, but the admissible interior law `p=1/2` has only **1/6**. The coordinate's original-product resampling influence stays exactly **2/3** for *every* p; influence alone does not certify what a read reveals.

The dual witness is \(q^*=(1/2,1/2)\), \(h=(1/2,0,-1/2)\), \(\lambda=1/6\), with \(\langle h,d_0\rangle=\langle h,d_1\rangle=1/6\). Reading X before Y yields \(G_Y(\{X\};p)=2/3\) for all p. Under an **information-gain requirement at least 1/2**, no *fixed one-coordinate* sensor set is uniformly sufficient across all p, but the two-coordinate set is: the minimum fixed sensor count rises exactly from **one** under the old law to **two** under the replacement-law family. This is a squared-loss information target, **not** a binary-safe zero-error actuation contract.

## Verification, independent attack and provenance

- `check_hull_exact.py` reconstructs the response Gram from the original source, checks the global support-hyperplane/matching certificate, verifies the numerical gain and influence and rejects altered source or witness fields (18 mutations).
- `check_hull_independent.cjs` uses a separate exact BigInt rational algebra to reconstruct and globally minimize the direct conditional-variance **quadratic in p**, checking both endpoints and its interior vertex (10 mutations). It does not call the Python KKT logic.
- `check_quadratic_gain_locality.py` independently enumerates full original-world conditional expectations for a 4-coordinate example and checks the exact w_{jk} unlocking identity; the cubic counterexample is a separate strict-negative test.
- `.github/workflows/nightfall-robust-observation-hull-lean.yml` compiles the general matching-hull Lean theorem under the repository's pinned compiler, checks its independent exact-type contract and allowed axioms, and records precise source hashes. If this workflow has not passed, keep the Lean claim **provisional**.

## Relation to prior work and novelty threshold

This integrates **existing** NIGHTFALL product Q2 and SCIF graph locality (not new claims), preexisting nested-address adaptive-query separations, and the existing proof-object/Lean certification pattern. Classical ANOVA/Hoeffding-Sobol variance partition, convex-hull projection, KKT optimality, dynamic programming and active feature acquisition are upstream mechanisms. See the 2026 IJCAI *Survey on Active Feature Acquisition Strategies*, 2021 *Global Sensitivity Analysis with Mixtures*, and the 2010 OSSS decision-tree/influence literature.

**Novelty status: unresolved.** This author-side mathematical synthesis is a useful intermediate **reusable certificate operator**, but neither the projection theorem nor the additive Q2 variance identities are claimed as previously unknown. Novel contribution would require (i) a rigorously stated *change-local policy-value* bound or a new algorithmic complexity separation using the hull witnesses, (ii) independent nonauthor checking, and (iii) full-text source-level prior-art comparison.

## Next decisive experiment

Attach these exact response-hull proof objects as *information-quality preconditions* to the existing `SemanticBellmanPotential.lean` policy passports. Enforce an explicit **type boundary**:

`ExpectedInformationCertificate(μ, f, S, q, threshold)`
\(\not\Rightarrow\)
`ZeroErrorPermissionCertificate(effects, histories, source_versions, atomic_guard)`.

Test one in-window source-law change that (a) keeps Q2 resampling influence high, (b) crosses the 1/2 information threshold, and (c) forces recertification of the chosen sensor policy. A dynamic full-world checker must independently confirm every action, source epoch and protected effect. A failure of such a checker demotes any policy transfer; do not promote a squared-loss Gram certificate to physical permission.
