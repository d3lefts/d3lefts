# Dossier 37 — Uniform cubic graph-cover construction

**Editorial snapshot:** 2026-10-30 · **Evidence:** unmerged uniform theorem candidate · **Originality:** unreviewed.

## Source and theorem target
[Lemnis PR #204](https://github.com/d3lefts/d3lefts/pull/204) proposes an explicit family of connected cubic bipartite regular covers of K3,3 indexed by field extension degree d≥8. The intended cycles have girth exactly 14 and an exhibited simple 32-cycle. The proof reduces neutral short-cycle words to six specified nonzero Laurent polynomials; a finite-field primitive-element choice is intended to avoid all their roots for every eligible degree.

## Evidence and required attacks
The PR reports 144 quotient-neutral short words, six polynomial types, and independent internal checks over GF256 and GF512. The [review queue](../../REVIEW_TRIAGE_20261029.md) asks for non-author enumeration of *all* quotient-neutral words, proof of the primitive-element existence inequality including small-degree edge cases, and a separate proof of connectivity and simplicity of claimed cycles. Verify characteristic-two voltage multiplication and cyclic nonbacktracking constraints before accepting the theorem.

## Limits
These are controlled-cover, model-specific claims. Neither a proof of the Erdős–Gyárfás conjecture nor a new global extremal graph record follows automatically. The universal proof, independently reviewed source and worldwide novelty remain open.
