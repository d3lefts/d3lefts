# NIGHTFALL Beyond the Boolean Cube — v9.2: degree-two-first revision

Date: 12 November 2026.

## Editorial changes

1. Reordered the **opening theorem sequence** to lead with the law-uniform degree-two influence bound (`thm:q`, constant `C_2`), its sharp variance exponent (`prop:sharp`), the rank-linear Hilbert bound (`thm:r`), and the rank-optimal adaptive observation theorem (`thm:obs`).
2. Rewrote the title and abstract to lead with these degree-two results. Their complete mathematical statements and proof constants were preserved.
3. Moved the complete quadratic, rank, and adaptive proofs immediately after the opening theorem section. Moved the discussion of Boolean reduction obstacles later, so it no longer precedes the main constructive proof.
4. Retained **both** all-degree results and their distinct certification levels from v9.1 in a later, separately labeled section: the stronger unrefereed analytic v8 coefficient and the weaker finite Lean-supported coefficient with separately written analytic extension.
5. Preserved the quantum query discussion, fixed-set guarantee, source provenance, historical attribution, open obligations, and bibliography. The 53 original LaTeX labels remain unique; cross-reference compilation succeeds.

## Certification boundary

This is an editorial reorganization, **not** a new mathematical theorem, a new Lean compilation, or independent mathematical review. The degree-two scalar, Hilbert, adaptive, and stronger all-degree claims remain author-side analytic proofs. The finite `product_influence` Lean receipt is source scoped and does not certify arbitrary-measurable products. No GitHub merge, external submission, or originality promotion was undertaken by this revision.

## Build

PDF compiled with pdfTeX via `latexmk -pdf` and checked for unresolved references and overfull boxes (none in final run). 14 pages. Original v9 and v9.1 source artifacts remain unchanged.
