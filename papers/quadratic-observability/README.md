# Quadratic Product-Space Influence and Adaptive Queries

**Status:** Manuscript claims, external referee open; **public principal LaTeX source is incomplete** in the checked-in publication directory. This is an evidence map, not a PDF substitute.

**Canonical scope:** [principal manuscript synopsis](../../research/nightfall/observability-publication/PRINCIPAL_PAPER.md). [Exact missing-file inventory](../../research/nightfall/observability-publication/SOURCE_ACCESS.md).

**Update (12 November 2026).** The scalar constant below, \(256(1+\sqrt3)^2\), is from the 10 November synopsis and is superseded. A full written proof of the scalar theorem, the rank-\(r\) Hilbert bound and the adaptive \(\lceil12C_2rB^2/\eta\rceil\) policy is deposited as [`NIGHTFALL_Beyond_Boolean_Cube_v9_2.pdf`](../finite-product-influence/NIGHTFALL_Beyond_Boolean_Cube_v9_2.pdf), with \(C_2=(10+2\sqrt2)^2(1+\sqrt3)^2\approx1228.36\) (same constant as v8; SHA-256 in `SOURCE_SHA256SUMS_v9_2`). Its LaTeX source is **not** yet in the tree. An internal (non-external) proof check is recorded in [V9_2_INTERNAL_REVIEW_20261112.md](../finite-product-influence/V9_2_INTERNAL_REVIEW_20261112.md). The categorical nonadaptive package listed under *Required publication package* is still missing. External review status is unchanged.

## Two claims that must not be conflated

**Scalar degree two:** For independent heterogeneous product coordinates, bounded real `|F|<=B`, and Hoeffding degree at most two, the manuscript proposes

```text
max_i I_i(F) >= Var(F)^2 / (256(1 + sqrt(3))^2 B^2).
```

This strengthens the variance dependence compared with the formally certified general-degree `5/2` exponent. The **matching extraction / off-matching boundedness / fourth-moment bridge** is the critical unrefereed proof dependency. Neither the finite `5/2` Lean proof nor supporting matching lemmas automatically establishes this statement.

**Query complexity:** For a specified worst-case whole-coordinate model with rank-`r` Hilbert outputs and finite coordinate alphabets size at most `m`, the manuscript proposes degree-two adaptive `Theta(r/eta)` and nonadaptive `Theta(rm/eta)`. The fixed-degree nonadaptive generalization is a distinct candidate. Quantifiers, accuracy restrictions and lower constructions matter; no statement gives runtime efficiency.

The adaptive quadratic theorem **uses** the proposed scalar quadratic premise; the categorical nonadaptive proof has separate signed-mass moment matching obligations. See [observability formalization coverage](../../research/nightfall/formalization/observability/README.md).

## Required publication package

Named but not present in the public publication folder: `main.tex`, `matching-core.tex`, `queries.tex`, `categorical.tex`, `nightfall-rank-appendix.md`, the original finite checkers, exact replay and `SHA256SUMS`. These cannot be replaced by reconstructed prose while claiming original-byte reproducibility. Deposit the unchanged source and checksum inventory, build the PDF from them, and independently replay the checkers before calling this referee-ready.

**Prior work and priority:** Turturean's uniform Boolean-cube theorem, classical ANOVA, and adjacent categorical query / decoupling bounds must be compared under identical normalization. This audit is not completed.

**Referee entry:** [quadratic proof attack and report format](../../research/referee/README.md).
