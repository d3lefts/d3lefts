# NIGHTFALL / UE2 — source-weighted selector revealment theorem with arbitrary leaf overlap

**Checkpoint v2:** 2026-11-17 Eastern. **Status:** author-side complete elementary mathematical proof using classical Efron–Stein and conditional expectation; 200 independent Fraction full-state checks. **NOT** unrestricted Q3 or N-UE2(2,1), not Lean certified, independently refereed, or novelty cleared. This STRICTLY STRENGTHENS the earlier disjoint-leaf selector theorem `SELECTOR_CHARGING_ALL_DEGREES_20261117.md` by removing the disjointness requirement.

## Theorem — true original-law weighted revealment inequality

Partition coordinates of a **finite independent product probability space** into k address variables \(A_1,\dots,A_k\), each with an arbitrary finite categorical law, and arbitrary independent leaf variables \((Y_i)_{i\in L}\) with arbitrary alphabets and laws. For each address tuple \(a\), let \(S_a\subseteq L\) be a set of leaf coordinates of size at most t; the \(S_a\)'s may overlap in ANY pattern. Let \(f(A,Y)=g_A(Y_{S_A})\) be real and essentially bounded. For leaf i define its original-law revealment probability \(q_i=\Pr_A(i\in S_A)\). Let \(I_j(f)=\mathbb E\operatorname{Var}(f\mid X_{-j})=\|R_jf\|_2^2\) and \(M=\max_jI_j(f)\).

Then the following **weighted, source-quantified inequality** holds:
\[
\boxed{\quad \operatorname{Var}(f)\le\sum_{j=1}^k I_{A_j}(f)+\sum_{i\in L}q_iI_{Y_i}(f).\quad}\tag{WR}
\]
Since \(\sum_iq_i=\mathbb E_A|S_A|\le t\), Popoviciu gives
\[
\boxed{\quad \operatorname{Var}(f)^2\le(k+t) B(f)^2 M.\quad}\tag{Q}
\]
Moreover f has canonical Efron–Stein degree \(\le k+t\), because it is a sum of address-cylinder indicators multiplied by functions depending on at most t selected leaf coordinates. Therefore **N-UE2(2,1) holds with the stronger coefficient k+t for the entire overlapping selector class**. In particular, for k=2,t=1, arbitrary-alphabet cubic source selectors obey \(\operatorname{Var}(f)^2\le3 B(f)^2 M\) despite dense/repeated leaf sharing.

## Proof — exact coordinate-residual contraction

Write \(\bar f(Y)=\mathbb E_A f(A,Y)=\sum_a p_a g_a(Y_{S_a})\), where \(p_a=\Pr(A=a)\). Total variance gives
\[
\operatorname{Var}(f)=\mathbb E_Y\operatorname{Var}_A(f\mid Y)+\operatorname{Var}_Y(\bar f).
\]
Because the k address coordinates are independent conditional on Y, applying Efron–Stein there yields
\[
\mathbb E_Y\operatorname{Var}_A(f\mid Y)\le\sum_{j=1}^k I_{A_j}(f).
\]
Now fix a leaf i. Its genuine source coordinate residual commutes with independent averaging over A:
\[
R_i\bar f=\sum_{a:i\in S_a}p_a R_i g_a.
\]
The positive weights have total mass \(q_i\), so weighted Cauchy–Schwarz in original-leaf L² gives
\[
\|R_i\bar f\|_2^2\le q_i\sum_{a:i\in S_a}p_a\|R_i g_a\|_2^2
= q_i I_{Y_i}(f).
\]
The **last identity is the actual original-source resampling influence**, since for each address value only its selected leaf function contributes. Ordinary Efron–Stein on all leaf coordinates gives
\[
\operatorname{Var}_Y(\bar f)\le\sum_i\|R_i\bar f\|_2^2\le\sum_i q_i I_{Y_i}(f).
\]
Combining with the address term proves (WR), and \(\sum_iq_i\le t\) proves (Q). No disjointness or statistical independence between the *functions* \(g_a(Y_{S_a})\) is needed; only the original leaf coordinates themselves must form a product measure. This removes a genuine prior limitation, not a numerical constant tweak.

## Independent exact stress tests

`python3 -I research/nightfall/flagship-influence/check_selector_overlap_revealment_exact.py` checks 200 seeded finite independent product instances with k∈{1,2,3}, |L|∈{3,4,5}, t∈{1,2}, random positive rational biases, arbitrary overlapping selected subsets and random full leaf truth tables. The checker independently reconstructs every original conditional-variance influence using buckets indexed by all other coordinates, computes the true centered essential radius, verifies (WR)/(Q), and separately checks every \(I_i(\bar f)\le q_i I_i(f)\) from the explicit leaf-only average. These finite tests do **not** certify the universal analytic proof.

## Limits, prior art, transfer

- **Unrestricted cubic Q3 and all-degree UE2 are still open**: not every degree-d product polynomial admits a bounded-cost address/selected-support representation.
- Classical proof ingredients resemble revealment/OSSS-style influences; check existing literature before claiming novelty or a new theorem name. The novel-in-program part is this precise weighted resampling L² formulation and its transferable coupling to the source-consistent cubic selector obstruction.
- The proof assumes finite categorical address tuples and a product law over original leaf coordinates. Infinite products require finite-information approximation. It does not apply to non-product leaf dependence.
- **Next decisive gate:** test whether a useful overlapping cubic subfamily admits a decomposition into a small number of genuine source-coordinate selector forms with a **proved** control of range and coordinate influences. A generic randomized encoding is not enough: auxiliary selector variables change the original law and may destroy the maximum-influence comparison. No such unrestricted representation or transfer theorem is claimed.

**Discovery graph:** biased degree-two address counterexample → true influence tower → source-weighted leaf residual contraction → arbitrary overlap allowed → cubic selector C=3 → unknown low-cost representation of unrestricted cubic networks.
