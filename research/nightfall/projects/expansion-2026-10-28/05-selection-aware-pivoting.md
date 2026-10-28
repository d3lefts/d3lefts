# Dossier 05 — Selection-aware Gaussian partial-pivoting stability

**Source manuscript:** \`selection_aware_GEPP_revised.pdf\`, revised 2026-10-06. **Status:** mathematical derivation manuscript, with explicit dependence on prior pivot-polytope arguments and Anderson's inequality; external expert review and novelty determination pending.

## Problem and theorem

Let \(B=\Delta+G\in\mathbb R^{n\times n}\), where \(\Delta\) is deterministic and \(G\) has independent standard Gaussian entries. Run Gaussian elimination with partial pivoting in exact arithmetic. After \(m\) selected rows, take the next \(s\) selected rows, with \(t=m+s<n\). Project their leading-\(t\)-column block onto the nullspace of the preceding \(m\) selected rows, obtaining \(C\in\mathbb R^{s\times s}\).

For integers \(a,b\ge0\), \(a+b=j<s\), the revised manuscript derives
\[
\Pr\{\sigma_{s-j}(C)\le\varepsilon\}
\le \min\!\left\{1,\binom nt
\left(\frac{A_{s,a+1}\varepsilon}{\ell_{s,b}}\right)^{(a+1)(n-t)}\right\},
\]
where \(A_{s,q}=\sqrt s/(\sqrt2\,\Gamma(q/2+1)^{1/q})\) and \(\ell_{s,b}>0\) is an explicit singular-value lower bound for a unit lower-triangular matrix with entries bounded in magnitude by one. Singular values are indexed in decreasing order.

## Mechanism

The selected pivot rows determine the Gaussian pivot polytope \(K_t=[-1,1]^tU_t\) through the upper factor. If \(Q\) is an orthonormal basis for the nullspace of the previous rows, the projected polytope has the form \([-1,1]^sV\). The future selected-row block factors *exactly* as \(C=L_{22}V\), where \(L_{22}\) is the bottom-right unit lower-triangular factor.

Gaussian projection plus an ellipsoid-volume bound relates small singular values of \(V\) to small Gaussian mass; rejected unselected rows contribute the power \(n-t\), and the possible row sets contribute \(\binom nt\). The explicit loss \(\ell_{s,b}\) from \(L_{22}\) is essential: ignoring that factor invalidates the spectral lift. A triangular counterexample in the manuscript demonstrates this failure mode.

This is a **selected-block estimate**, rather than a new upper bound on the final Gaussian-elimination growth factor. The manuscript explicitly states that its local comparison is not uniformly superior across all parameter regimes.

## Main evidence and upstream credit

- Manuscript: \`selection_aware_GEPP_revised.pdf\`, original LaTeX \`selection_aware_GEPP_revised.tex\`.
- Source argument: Huang–Tikhomirov pivot-polytope and rejected-row approach; deterministic Gaussian shifts are handled with Anderson's inequality.
- Source dependencies and bounds are given in the manuscript itself. No public standalone runnable checker has yet been mirrored with this dossier.

## Independent review tasks

1. Derive the pivot-polytope identity from actual GEPP row selection, including deterministic shifts and conditional events.
2. Verify all singular-value indices in \(C=L_{22}V\), especially endpoint \(j=s-1\).
3. Prove the explicit \(\ell_{s,b}\) constant at all small \(s\) and check Gaussian-volume normalizations.
4. Compare at matched \(n,m,s,j,\varepsilon\) against published selected-block bounds; measure any improvement only in supported parameter regimes.
