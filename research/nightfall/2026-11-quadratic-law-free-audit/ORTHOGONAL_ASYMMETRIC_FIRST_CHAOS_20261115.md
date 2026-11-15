# First-chaos budget: all-length asymmetric orthogonal-support theorem

**2026-11-15.** Analytically proved elementary subclass; not Lean-certified or independent human reviewed. This supplements the symmetric-law theorem in PR #574. It does **not** prove the unrestricted interacting asymmetric-law C96 bound.

## Statement

Let (H) be a real Hilbert space. Let independent (or merely product-distributed) random vectors (Y_i\in H_i\subset H), where the closed linear subspaces (H_i) are pairwise orthogonal, and let deterministic (h\perp H_i\) for every i. Assume \(\|Y_i\|\le c\) almost surely. No centering, symmetry, or identical distribution is needed. Set
\[
F=\left\|h+\sum_iY_i\right\|,\quad
u=\mathbb EF,\quad
W_1=\sum_i\operatorname{Var}(\mathbb E[F\mid Y_i]).
\]
Then \(W_1\le c\,u\), hence \(W_1\le\|h\|^2+c u\).

## Proof

Orthogonality gives \(F=\sqrt{\|h\|^2+\sum_i\|Y_i\|^2}\). Define \(F_{-i}=\sqrt{\|h\|^2+\sum_{j\ne i}\|Y_j\|^2}\) and \(\Delta_i=F-F_{-i}\). Then \(0\le\Delta_i\le\|Y_i\|\le c\). If \(F>0\),
\[
\Delta_i = \frac{\|Y_i\|^2}{F+F_{-i}}\le\frac{\|Y_i\|^2}{F},\qquad
\sum_i\Delta_i\le\frac{F^2-\|h\|^2}{F}\le F.
\]
At \(F=0\), every \(\Delta_i\) vanishes, so the same bound holds. By the first-degree product/Hoeffding projection bound and Efron–Stein,
\[
W_1\le\operatorname{Var}(F)
\le\sum_i\mathbb E\big(F-\mathbb E[F\mid Y_{-i}]\big)^2
\le\sum_i\mathbb E(F-F_{-i})^2
\le c\,\mathbb E\sum_i\Delta_i
\le c u.
\]
The second inequality involving \(F_{-i}\) uses the conditional least-squares property of conditional expectation; (F_{-i}) depends only on (Y_{-i}).

## Why it matters and does not close the general problem

This is an unrestricted-number-of-increments *asymmetric* source-law theorem with a geometric orthogonality restriction. The symmetry result in this PR permits arbitrary interacting directions but requires symmetric marginal laws. The original universal target allows **both** asymmetric laws and nonorthogonal interactions; no theorem combining the two restrictions has been proved here.

The mechanism is scalar monotone energy: \(F=\sqrt{a^2+\sum_i r_i^2}\), and deletion gains are nonnegative, bounded, and self-bounding. Once nonorthogonal cross terms are present, pointwise deletion monotonicity can fail; once marginal symmetry is absent, the fair-sign amplitude decomposition cannot be applied directly.

External provenance: Efron–Stein variance tensorization and elementary self-bounding functions. Claim original priority only after explicit related-work audit (not done).
