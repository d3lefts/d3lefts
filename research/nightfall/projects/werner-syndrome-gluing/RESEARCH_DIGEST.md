# Complementary-syndrome gluing for the restricted four-copy Werner endpoint

**Research lead:** Devin J. Wright · NIGHTFALL / PHASESHIFT · 28 October 2026  
**Original Library source:** `NIGHTFALL_Q4_SYNDROME_GLUING_20261028.pdf` and companion source ZIP `NIGHTFALL_Q4_COMPLEMENTARY_SYNDROME_20261028.zip`.  
**Status:** Conditional analytic transfer from the nine-word restricted-witness theorem; exact selection-rule computations reported. This digest preserves the original PDF's theorem scope; original frozen binaries need a separately verified public mirror.

## Statement and support geometry

For (d\ge3), define (H(a)=(a_3-a_1-a_2,\,a_4-a_1-2a_2)) over $\mathbb F_3$. Let (P_s) project onto the nine computational words with syndrome (s). Set (S=\{(0,0),(1,0),(2,0)\}), (T=\{(0,0),(0,1),(0,2)\}), and (P_S=\sum_{s\in S}P_s), (P_T=\sum_{t\in T}P_t). Each projection has rank 27.

For every rank-at-most-two complex matrix (C=P_SCP_T), the archived analytic argument gives
$
Q_4(1/2,C)\ge0.
$
The statement includes coherent combinations across all nine syndrome-pair blocks within this **27-by-27** rectangular support.

## Why the decomposition works

A nonzero matrix coefficient of the polarized quadratic form respects the syndrome **difference** (H(a)-H(b)). The difference map ((s,t)\mapsto s-t) is injective on (S\times T). Consequently
$
Q_4(1/2,C)=\sum_{s\in S,t\in T}Q_4(1/2,P_sCP_t).
$
Each two-sided compression retains rank at most two and its row space is a translate of the nine-word code. Applying the archived affine-code certificate to every block proves nonnegativity.

The original source reports 236,196 exact coefficient-pair vanishing checks for mismatched differences, direct partial-trace controls, and an independent replay of the nine-word source identity.

## Sharp scope limitation

The gluing identity **fails to separate** blocks when syndrome differences collide. In the source's two-coset aligned example, (16Q_4) equals (1) on each of two individual diagonal words and (0) on their sum; the cross interaction is exactly (-2). A rank-one global witness can have a negative *individual difference sector* when projected sectorwise, because those projections need not preserve rank one. Thus a global rank-two inference requires a rank-preserving split or a direct inequality on the original factors.

This is a restricted-witness result, **not** unrestricted four-copy undistillability. The [Lemnis follow-up](../../agent-reports/lemnis_werner_coupling_20261028/RESEARCH_NOTE.md) reports a sharp cross-sector norm and a stronger conditional witness criterion, subject to separate review.
