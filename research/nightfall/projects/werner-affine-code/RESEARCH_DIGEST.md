# Four-copy Werner endpoint on a nine-word ternary affine code

**Research lead:** Devin J. Wright · NIGHTFALL / PHASESHIFT · 28 October 2026  
**Original Library source:** `RESEARCH_NOTE(20261028-080810).md`; original working ZIP `NIGHTFALL_WERNER_Q4_MDS_ENDPOINT_20261028.zip`.  
**Status:** Restricted-witness proof manuscript with exact finite coefficient checks reported; independent outside referee review and literature priority open. This digest is a public, curated statement of the archived manuscript, not a replacement for the original frozen source bytes.

## Precise result

For any complex (d^4\times d^4) coefficient matrix (C) of rank at most two, (d\ge 3), set
[
Q_4(C)=\sum_{J\subseteq\{1,2,3,4\}}(-1/2)^{|J|}\|\operatorname{Tr}_J C\|_F^2.
]
Use the ternary code (A=\{(x,y,x+y,x+2y):x,y\in\mathbb F_3\}), with its nine basis vectors embedded into Alice's (d^4)-dimensional space. The source derives (Q_4(C)\ge0) whenever the **range** of (C) lies in the code span, without restricting the co-range. Exchanging row and column roles also preserves the claim.

## Certificate mechanism

The proof groups matrix coefficients into a central trace group and 24 transversal groups for (d=3). Each group yields an expression
[
A_g(X)=\|X_g\|_F^2-\tfrac12|\operatorname{Tr} X_g|^2\ge0,
]
because (X_g) is a submatrix of a rank-at-most-two matrix. Its exact integer identity is
[
16Q_4(C)=\sum_g w_g A_g(X)+\sum_{a\in A,b\in[d]^4}\delta(a,b)|X_{a,b}|^2,
]
with (w_g\ge0), (delta(a,b)\ge0). For (d=3), the 729 residual entries have histogram (delta=0:81, 4:216, 6:72, 8:216, 12:144).

The archive reports a separate coefficient checker covering all **531,441** ordered coefficient pairs for (d=3), with independent direct partial-trace sanity tests. That is an exact finite identity audit; the mathematical proof and novelty still require independent specialist review.

## Scope and next obstruction

This proves positivity only on the specified restricted rank-two witness family. It **does not** establish the unrestricted four-copy Werner threshold (t=1/2). The code has full local qutrit support at every site while constraining Alice's global range to dimension nine. Extending across different code cosets introduces interference terms and requires an argument that retains rank two throughout.

**References:** Related archived [complementary-syndrome construction](../werner-syndrome-gluing/RESEARCH_DIGEST.md); [Werner evidence atlas](../werner-atlas/README.md); Tomar (2026), `https://www.mefyi.com/papers/werner-states-copies/`. External priority comparison pending.
