# Dossier 03 — Exact ETH transfer refinements: taper and rank barrier

**Sources:** \`NIGHTFALL_ETH_TAPER_PROOF.md\` (2026-10-26), \`ETH_WEIGHT_REFINEMENT_OBSTRUCTION_20261027.md\` (2026-10-27). **Status:** exact mathematical argument manuscripts; reported separate code-path tests; literature-priority and source-integration audit open. **No improved universal SAT exponent is claimed.**

**Primary source text:** [October 26 exact 2-adic taper manuscript](sources/NIGHTFALL_ETH_TAPER_PROOF.md). The separate October 27 weight-refinement obstruction is summarized below; its original source remains outside this public tree.

## A. 2-adic Hermite interpolation taper

Let \(L=2^a\), \(a\ge u\ge1\), \(M\ge1\), \(D=M(2L-1)\). Assign interpolation nodes at 2-adic valuation \(i\) an integer multiplicity \(q_i\) for \(0\le i<u\). Define
\[
(Aq)_i=\sum_{j=1}^{a-i}\frac j{2^j}(q_i-q_{i+j}),\quad q_j=0\ (j\ge u),\quad N_i=L/2^i.
\]
The source gives
\[
g(k)=k/6+5/18+(2/9)4^{-k},\quad
S_u=u/3+(2/9)(1-4^{-u}),\quad R=D/(LS_u),
\]
and \(q_i=\lceil Rg(u-i)\rceil+1\). Its proof yields:
\[
\sum_{i<u}N_iq_i>D,\quad (Aq)_i<R+4,\quad 1\le q_i\le4M.
\]
The generating-function recurrence for \(g\) is used to control valuation loss. The report compares a leading precision allowance asymptotic to \(6M/u\) with a source allowance asymptotic to \(24M/u\) in the matched parameter regime: a **constant-factor precision improvement**, with the published subexponential exponent unchanged.

A finite-grid minimax argument uses the upper-triangular \(M\)-matrix \(A\) and \(v=A^{-1}\mathbf1\ge0\), giving exact continuous relaxation optimum \(D/(w^Tv)\), with \(w_i=L/2^i\). Audit the original full assumptions and the integer rounding allowance before reusing this result in the upstream algorithm.

## B. Disjoint middle-layer coefficient partition rank obstruction

For \(n=2m\), with \(I(x,y,u,v)=[x=u][y=v]\), \(P(x,y,u,v)=[x=v][y=u]\), define
\[
T_S=\bigotimes_{j\in S}(P-I)\bigotimes_{j\notin S} I,\qquad |S|=m.
\]
For any partition of all \(m\)-subsets of \([n]\) into \(q\ge1\) nonempty families \(G_a\), put \(F_a=\sum_{S\in G_a}T_S\). The manuscript proves
\[
\max_a \operatorname{rank}_{(x,y)|(u,v)}(F_a)
       \operatorname{rank}_{(x,u)|(y,v)}(F_a)
\ge\frac{12^n}{(n+1)^2q^2}.
\]
**Proof sketch:** in one flattening, \(P-I\) has rank-one antisymmetric mode, with a three-dimensional complementary symmetric space; in the other flattening, the corresponding modes are indexed by lower shadows. For any subset family \(G\) occupying fraction \(\alpha\) of the middle layer, double counting upper and lower incidences bounds both ranks below by
\(\alpha D_0\), where \(D_0=\sum_{j=0}^m\binom nj3^j\ge12^{n/2}/(n+1)\). A largest partition cell has \(\alpha\ge1/q\).

This is a no-go **only for splitting the unchanged middle-layer tensor into disjoint groups with subexponentially many pieces**. It leaves open signed cross-degree cancellation, alternative tensor representations, and improved SAT algorithms.

## Audit dependencies

- Original taper note: separate rational arithmetic, Hermite reconstruction, and LP tests reported.
- Rank barrier: independent direct flattening matrices and modular-rank checks reported on exhaustive small families and sampled \(n\le8\).
- Upstream comparison: OpenAI's October 25, 2026 ETH manuscript, and Anthropic's \`eth\` proof repository at source commit \`16a5ce41304fcdaea4e0be7c132e1c361dc26da5\`.
- Corresponding source bundles and full checker bytes remain outside this GitHub text dossier.

**Reviewer tasks:** reconstruct both flattenings directly, verify each normalization, rerun taper against original Hermite assumptions, and complete dated literature-priority comparison.
