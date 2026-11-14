# Two-scale observability: a block-product influence theorem for singular dependent coordinates

**NIGHTFALL representation transition | 13 November 2026 | Author-directed, AI-assisted analysis**

**Certification:** Author-side analytic **corollary** of the pinned Lean finite heterogeneous-product theorem, plus independent exact-rational finite stress tests. The block regrouping argument is elementary and not claimed historically novel. Its value is a precise strengthening of permitted *coordinate dependence* and a robust substitute when fine-coordinate heat-bath influences disappear.

## Problem and scope

Let n elementary coordinates be partitioned into m disjoint nonempty blocks \(B_1,\ldots,B_m\), each of size <=s, and let the **actual** joint law be

\[
\nu=\bigotimes_{b=1}^m \nu_b,\qquad
\nu_b\text{ arbitrary on }\Omega_{B_b}.
\tag{1}
\]

There is **no requirement of coordinate independence inside a block**: each \(\nu_b\) may be singular, concentrated on a parity constraint, or contain zero-probability symbols. The block laws may differ.

Assume \(|f|\le B\) pointwise on the full Cartesian domain and that f admits a **pointwise algebraic coordinate-interaction representation**

\[
f(x)=\sum_{S\subseteq[n],\ |S|\le d}h_S(x_S).
\tag{2}
\]

Here d>=1; h_S need not be canonical Hoeffding components, and sums may include vanishing terms. A weaker almost-sure statement is sufficient if one proves the same representation on every positive-probability block input. A source-law degree statement that holds only on a separate unrelated support does *not* automatically imply (2).

For every block define its full-state conditional resampling influence

\[
J_b^\nu(f)=\mathbb E_\nu\operatorname{Var}_\nu(f\mid X_{-[B_b]}).
\]

This is the influence of the **entire block as one meta-coordinate**.

## Theorem 3 — block-product Aaronson–Ambainis and adaptive observation

With the pinned constant \(c_*=\sqrt{3/12500}/\pi^6\), the potentially highly correlated measure (1) satisfies

\[
\boxed{\max_{b\in[m]} J_b^\nu(f)\ge
c_*\frac{\operatorname{Var}_\nu(f)^{5/2}}{B^3d^6}.}
\tag{3}
\]

For any \(0<\eta\le B^2\) there exists a deterministic **adaptive whole-block** observation policy making at most

\[
\boxed{Q\le\min\left\{m,\
\left\lceil\frac{4d^7B^3}{c_*\eta^{3/2}}\right\rceil\right\}}
\tag{4}
\]

block observations, yielding MSE <=η under the conditional-mean predictor. If individual coordinates must be read to reveal a block, the resulting worst-case cost is bounded by \(sQ\) scalar-coordinate reads (and also by n).

**Proof.** Every term \(h_S(x_S)\) in (2) depends on no more than \(|S|\le d\) blocks. Regroup these functions by their block support, giving a pointwise interaction-degree<=d representation on the **independent meta-coordinate product** (1). The existing Lean-checked finite heterogeneous-product theorem therefore applies at unchanged constant \(c_*\) to the block variables, proving (3). Zero-mass block configurations are allowed by the existing theorem's finite-source hypothesis.

After whole blocks are observed, the remaining blocks retain their original independent product law. Every section of (2) has block degree<=d and pointwise bound B, so the same statement is hereditary. Let V_t be expected posterior variance and T_t expected sum of block influences. Independent-block ANOVA gives \(T_t\le dV_t\). The exact total-influence descent identity gives \(T_t-T_{t+1}\ge c_*V_t^{5/2}/(B^3d^6)\) for the block-influence greedy policy. The dyadic-level argument in the companion [correlated theorem](HEREDITARY_CORRELATION_THEOREM.md) with R=1 bounds the number of steps by \(4d^7B^3/(c_*\eta^{3/2})\). The conditional-mean predictor has risk V_t. Every block costs at most s single-coordinate reads, completing the proof. QED.

## Why the block theorem is quantitatively stronger than a global density bound

Let each block consist of L >= 3 fair-sign coordinates, and let \(\nu_{b,\tau}\) be the full-support parity tilt (tau>0) or even-parity law (tau=0) described in [parity camouflage](PARITY_CAMOUFLAGE_20261113.md). With m blocks, the global density ratio relative to the fair coordinate-product law, when tau>0, is

\[
R_{\rm global}=\left(\frac{2-\tau}{\tau}\right)^m.
\]

The bounded-density influence transfer accordingly becomes exponentially weak in m. The block-product theorem (3) has **no dependence on m or tau**, and still applies at **tau=0** when the global density is singular and every fine-coordinate heat-bath influence of some nonconstant functions vanishes.

The theorem must not be misrepresented as a positive lower bound on individual-coordinate influences under singular within-block correlations. It is a bound on **block** influences and a policy reading complete blocks. A formal information-access model must pay for all s elementary reads and any computational work required to identify the blocks and evaluate posterior influences.

## Exact finite audit

The checker [check_block_coarsening.py](check_block_coarsening.py) constructs 110 randomly parameterized finite independent-block laws, with arbitrary within-block dependencies and 84 cases containing zero-mass configurations. Pointwise degree<=3 functions are built on source fine coordinates; the checker reconstructs macroblock Hoeffding components *from the actual block law*, checks 514 component-degree and energy identities, and checks 221 expected posterior block-influence drift identities using Fraction. It directly asserts \(\operatorname{Var}\le\sum_bJ_b\le d\operatorname{Var}\).

This test does not prove the original product-space influence theorem or verify its numerical c* constant on all functions. The proof invokes the separately pinned Lean declaration with full source scope.

## Novelty and next structural question

Viewing correlated clusters as independent meta-variables is classical regrouping. The proposed contribution **within this programme** is to make the dependence/resource contract explicit, join it to the newly established hereditary source theorem, and isolate exactly where the fine-coordinate interpretation fails.

The materially harder, potentially historically original theorem would replace sQ with an **intrinsic block revelation cost** determined by the fine-coordinate decision structure, not raw block cardinality, and then derive matching information-access lower bounds. That requires a new mechanism rather than simply applying a known product theorem to coarsened variables.