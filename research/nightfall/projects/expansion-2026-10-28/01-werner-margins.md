# Dossier 01 — Werner finite-copy margins and restricted endpoint sectors

**Source dates:** 2026-10-28. **Research lead:** Devin J. Wright. **Evidence:** proof manuscripts, conditional certificate transfers, and reported exact-rational audit. **External mathematical/priority review:** open.

## Separate mathematical claims

### A. Dimension-uniform, self-contained finite-copy estimate

Let \(|\Omega_d\rangle=\sum_{a=1}^d|aa\rangle\), \(P_d=|\Omega_d\rangle\langle\Omega_d|\), \(S_d=I-P_d/d\), and for a Schmidt-rank-at-most-two vector \(\psi=\operatorname{vec}C\) write
\[
Q_k(t,C)=\langle\psi,(I-tP_d)^{\otimes k}\psi\rangle .
\]
The manuscript's operator argument establishes, for each \(d\ge3\) and finite \(k\ge1\),
\[
Q_k(1/d,C)\ge(1-2/d)^k\|C\|_F^2,
\]
and, using the tensor-product operator-norm telescoping bound, at
\[
t_{d,k}=\frac1d+\frac{(1-2/d)^k}{2dk},\qquad
Q_k(t_{d,k},C)\ge\frac12(1-2/d)^k\|C\|_F^2.
\]
This is a **copy-dependent** strict-NPT interval. It supplies no common fixed \(t>1/d\) valid for all unbounded \(k\).

**Mechanism:** \(S_d\) is a positive separable isotropic operator. One valid construction is the \(U\otimes\overline U\) twirl of \(|x\rangle\otimes|\overline y\rangle\) with \(\langle x,y\rangle=0\), normalized by its trace. Product-vector contraction preserves Schmidt rank at most two. The one-copy partial trace inequality supplies \(1-2/d\). This wording corrects the source PDF's erroneous \(U\otimes U\) twirl description.

### B. Source-dependent 25–100-copy qutrit improvements

A distinct 24-copy source-derived certificate at \(t=0.34000\) reports a rational restricted margin \(m_{24}\approx9.79504003001414918\times10^{-7}\). Separable padding and dynamic programming across positive-margin blocks give \(b_{25}=m_{24}/3\) and the explicit strict increment
\[
\delta_{25}=\frac{b_{25}(1-b_{25})}{50}
 \approx6.530024554613673\times10^{-9}.
\]
The source reports lower margin \(M_{25}\approx1.06603003851356\times10^{-13}\). Additional source-dependent examples: \(\delta_{26}\approx4.18591363160\times10^{-9}\), \(\delta_{30}\approx3.58300496367\times10^{-10}\), \(\delta_{100}\approx2.27284509511\times10^{-28}\). These are **not** claimed to replace the public 4–20 approved registry; the numeric seed inherits its upstream source-operator premises.

At the PPT boundary, for a rank-two form lower margin \(b_k\le10^{-2}\), the source derives
\[
Q_k(1/3+\delta,C)\ge
\left[b_k-2k\delta-\frac{(3k\delta)^3}{1-3k\delta}\right]\|C\|_F^2,
\]
for \(3k\delta<1\). Setting \(\delta=b_k(1-b_k)/(2k)\) leaves a strictly positive bound. The original exact rational 24-copy seed and complete 76-row table must accompany an independent replay before they are promoted as fully publicly reproducible data.

### C. Four-copy *restricted-witness* endpoint

Let \(H(a_1,a_2,a_3,a_4)=(a_3-a_1-a_2,\ a_4-a_1-2a_2)\) over \(\mathbb F_3\). Let \(P_s\) project onto the nine words with syndrome \(s\), and take
\(S=\{(0,0),(1,0),(2,0)\}\),
\(T=\{(0,0),(0,1),(0,2)\}\).
For rank-\(\le2\) coefficient matrices constrained by \(C=P_SCP_T\), the source claims
\[
Q_4(1/2,C)=\sum_{s\in S,t\in T}Q_4(1/2,P_sCP_t)\ge0.
\]
The first equality follows from the fact that the nine syndrome differences \(s-t\) are distinct and the quadratic-form kernel conserves syndrome difference. The final inequality imports the earlier nine-word affine-code theorem. Both support projections have rank 27. **This is a restricted-witness statement, not unrestricted four-copy undistillability.**

## Primary source artifacts to mirror

- \`NIGHTFALL_WERNER_MULTIPLICATIVE_MARGIN_20261028.pdf\`
- \`NIGHTFALL_WERNER_MULTIPLICATIVE_MARGIN_20261028.zip\`
- \`BOUNDS_25_TO_100.csv\`
- \`NIGHTFALL_Q4_SYNDROME_GLUING_20261028.pdf\`
- \`NIGHTFALL_Q4_COMPLEMENTARY_SYNDROME_20261028.zip\`
- \`NIGHTFALL_WERNER_ALL_BOUNDS_20261028.xlsx\`

These filenames identify Library checkpoints. Their binary contents and exact 24-copy seed are **not included in this text dossier**. See the [approved Werner atlas](../werner-atlas/README.md) for the separately reconciled 4–20 evidence tiers.

## Review gates

1. Reconstruct exact \(m_{24}\) from the original rational source certificate, then check every 25–100 row by a second exact code path.
2. Independently check the product-vector/separability argument, plus all twirl normalizations.
3. Replay the affine-code restricted-witness theorem before using the syndrome-gluing conclusion.
4. Compare literature at matching assumptions; no blanket novelty claim.
