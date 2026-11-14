# Exact unrestricted nonadaptive physical observation on a zero-field Ising path

**NIGHTFALL Theorem E | November 13–14, 2026 | AI-assisted mathematical derivation directed by Devin J. Wright**

**Status:** Author-side complete finite proof with two independent original-state implementations (90-model full bundle, 40-model branch CI). No external historical originality verdict, external specialist referee, or Lean end-to-end formalization. This theorem supersedes the *reconstruction-only* cost frontier **on this special path model**, not on arbitrary trees or adaptive policies.

## The physical source and the Bayes-optimal information interface

Let \(X_0\) be uniform on \(\{-1,1\}\). For \(e=1,\ldots,n-1\), let edge innovation signs \(U_e\) be mutually independent of one another and of \(X_0\), with means \(t_e\in[-1,1]\), and define \(X_e=X_{e-1}U_e\). The original physical states are correlated. Fix an additive original-site quadratic target

\[
f(X)=c+\sum_{e=1}^{n-1}a_e X_{e-1}X_e
=c+\sum_{e=1}^{n-1}a_e U_e.
\]

State observations return complete noiseless original vertex signs \(X_i\), without directly revealing U. For any fixed set S of observed vertices, predict by \(\widehat f=\mathbb E[f\mid X_S]\). Its residual mean-square Bayes risk is \(\mathcal R(S)=\mathbb E(f-\widehat f)^2\). The objective is minimizing this risk over all *fixed/nonadaptive* sets |S|<=r.

## Theorem — exact physical Bayes risk and optimal read set in polynomial time

Write \(V=\sum_e a_e^2(1-t_e^2)\). For i<j initialize \(T_{ii}=1,C_{ii}=0\), then extend each interval by

\[
T_{ij}=T_{i,j-1}t_j,\qquad
C_{ij}=C_{i,j-1}t_j+a_j(1-t_j^2)T_{i,j-1},
\]
\[
W_{ij}=\begin{cases}C_{ij}^2/(1-T_{ij}^2)&|T_{ij}|<1,\\
0& |T_{ij}|=1.\end{cases}
\]

Then, for *every* selected set S={i1<...<ir},

\[
\boxed{\mathcal R(S)=V-\sum_{\ell=1}^{r-1}W_{i_\ell,i_{\ell+1}}.}
\]

For S empty or a singleton this sum is zero. All weights W are exact rationals for rational source parameters, including deterministic edges t_e=±1. They can be calculated in O(n²) arithmetic. The optimal risk over all physical vertex sets of size at most r is computable in O(r n²) arithmetic with O(n²+rn) DP storage and traceback; the complexity measures arithmetic operations rather than rational bit complexity.

### Proof

For an edge interval (i,j], define its additive contribution \(A_{ij}=\sum_{e=i+1}^j a_eU_e\) and path product \(Y_{ij}=\prod_{e=i+1}^jU_e\). The latter is a sign with mean T_ij. By independent edge laws, \(\mathrm{Cov}(A_{ij},Y_{ij})\) satisfies the recurrence C_ij above. The space of functions of binary Y is exactly two-dimensional, so the conditional mean E[A|Y] is affine in Y, and the variance it explains equals C²/(1−T²) when |T|<1. For deterministic Y, C=0 and the explained variance is zero.

Now take observed vertices \(S=\{i_1<\cdots<i_r\}\). Because X0 is a uniform independent root sign, the first observed anchor Xi1 is uniform and **independent of the entire innovation vector**. All other observed vertex values are equivalent to consecutive products \(Y_{i_1i_2},\ldots,Y_{i_{r-1}i_r}\) plus that independent anchor. These products depend on disjoint innovation intervals and are independent. The remaining innovation contributions, outside those intervals, are independent of all observed values. Conditional-mean variance therefore decomposes into the sum of interval gains W; subtracting from the total variance V proves the exact Bayes risk.

For a fixed number k of observed sites, let D_k(j) be the largest explained variance among increasing k-site sets whose final site is j. Then

\[
D_1(j)=0,\qquad D_k(j)=\max_{i<j}\{D_{k-1}(i)+W_{ij}\}.
\]

Each site set has a unique ordered decomposition, so induction proves the recurrence is exact. Optimizing over all k<=r and endpoints j gives the global unrestricted **nonadaptive** physical read optimum. No assumption that only fully reconstructed innovations are useful is made. QED.

## Strict improvement over the prior tree DP model

Take three vertices and edge means t1=t2=1/2, coefficients a1=a2=1/2. Then V=3/8 and W_02=3/20. Reading physical vertices {0,2} reconstructs *zero individual innovations*; the earlier reconstruction-only DP therefore predicts risk 3/8, while the unrestricted physical Bayes risk is

\[
\boxed{3/8-3/20=9/40}.
\]

This is exactly where source-local independence and physical observation interface diverge. The theorem resolves that discrepancy, rather than suppressing it.

## Source and replay

- Source algorithm: path_full_bayes.py (exact rational recurrence and site-set DP).
- Separate, direct physical-root-and-increment enumeration checker: check_path_full.py (40 randomized rational source models for branch CI, plus deterministic transitions, and the 9/40 counterexample).
- Original larger 90-model source/5,900 observed-site tests and 517 budget optimum comparisons are preserved in the frozen downloadable research bundle under audit_path_full.py and its SHA-256 manifest.
- Earlier independent finite-source theorem and sharp lower bound are in THEOREM_AND_AUDIT.md; original ANOVA checkers also run under the branch CI.
- Passing finite checks are not a proof of mathematical priority, external referee acceptance, or Lean formalization.

## Existing literature and novelty boundary

The independent-edge factorization of a zero-field Ising tree is classical (Evans–Kenyon–Peres–Schulman, 2000), and binary regression, interval information and weighted path DPs are established mechanisms. This exact same physical-query loss/cost statement was not identified by a targeted preliminary survey; that is **insufficient** to establish that it is new worldwide. Compare exact nonadaptive HMM sensor-placement and Markov-bridge literature with full same-oracle definitions before submission.

This theorem is for known independent edge signs and a fair, unobserved root. General trees with arbitrary queried site sets, magnetic fields, noisy reads and adaptive policies need separate theorems. Do not elevate our earlier restricted tree-knapsack frontier or the uncompiled Q2 result into this claim.
