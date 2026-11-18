# All-degree finite-label transfer toward NF-PS-FINITE

Date: 2026-11-18 (America/New_York) · Version 0.1 · Status: **new proof source, CI not yet adjudicated**. No theorem, novelty, or publication-level claim is promoted without current-head compilation and independent review.

## Objective, source and significance threshold

Target: extend the independently compiled **finite-product** degree-`d` influence inequality `Nightfall.ProductSpace.Influence.product_influence` to genuinely arbitrary independent products (arbitrary index sets, heterogeneous measurable coordinate spaces, nonuniform laws), preserving the exponents **5/2 in variance** and **6 in degree**, with no smallest-atom factor. The hard threshold is a complete Lean theorem whose input is the standard a.e. Hoeffding degree at most `d`, not a user-supplied finite-table degree predicate. A quantum query corollary must be stated with input encoding and a full distributional query-and-fix proof, not inferred automatically.

Strongest directly checked external references this session:
- David Turturean, *A proof of the Aaronson–Ambainis conjecture*, arXiv:2611.09773 (2026-11-06): uniform Boolean cube.
- Girish, Mittal, Nehoran and Raz, *Distributional Variants of the Aaronson–Ambainis Conjecture*, arXiv:2609.35327: common-bias Bernoulli product / slice variants.
- Our own `research/nightfall/formalization/product_space/ProductInfluence.lean` cites and adapts Turturean's pinned Lean work (PSI), with its historical Lean 4.33 certification; no current-pin recompilation is claimed yet.
- The purported November 8 Bhattacharjee/Zenodo general-product lead remains unverified; no priority conclusion is made from it.

## Provenance and exact representation

- Baseline (already merged): `InfinitePiQ2CellAverage.lean` uses a three-residual argument and returns only `NativeSupportedDegreeTwo`; `InfinitePiQ2OriginalLabelResidualTransfer.lean` proves the three-residual Hilbert isometry/adjoint transport.
- New: `InfinitePiAllDegreeLabelTransfer.lean` defines `iterResidual E sites f` for an **arbitrary finite ordered word**, not just three coordinates. For the literal finite-label map φ and original source law μ, the exact operator assertion is
  `D^q_sites (U† f) = U† (D^μ_sites f)`,
  where `q_i = (φ_i)_* μ_i`, `U` is the genuine L²-isometric pullback and `U†` is its adjoint (the conditional finite-label average). In addition,
  `D^μ_sites (U U† f) = U U† (D^μ_sites f)`.
- Mechanism: degree-free induction on the residual word from already proved **per-coordinate self-adjoint intertwining**, no combinatorial `2^(d+1)` expansion and no degradation in constants. It makes the transfer independent of `d`. Repeated sites are permitted; the degree hypothesis applies to *pairwise distinct* sites of length `d+1`.
- Current **verification status**: author-side Lean source on a separate branch, awaiting exact-source pinned Lean compile, named standard-axiom audit, source SHA and CI receipt. Until those pass, classify as **provisional construction**.

## Remaining composition gates against NF-PS-FINITE

1. **Finite label degree → indicator monomial degree**. `ProductInfluence.product_influence` requires `RowBound.HasProdDegreeLE f d`, an exact finite *pointwise* indicator expansion. Establish the implication from zero `d+1` iterated genuine label residuals to supported canonical Efron–Stein degree, then to an indicator expansion after zero-atom repair; do **not** assume it. This is the principal new finite theorem. The existing `ActualSourceANOVA.es_decomp` and `esComp_dependsOn` are the strongest reuse candidates.
2. **Null atoms and tagged dependent alphabets**. The finite AA theorem has a common finite alphabet and an all-words bound, while the table comes from heterogeneous alphabets with possibly null cells. Implement a supported-word repair by coordinatewise projection to positive-mass letters and show the degree predicate is preserved for *every* `d`; then apply existing tagged-alphabet transport. Preserve true original masses.
3. **Current Lean pin for ProductInfluence**. Recompile exact finite theorem on the pinned Lean 4.36.0-rc2 / Mathlib lock, with no unstated assumptions, and compare the declaration's actual `HasProdDegreeLE` shape.
4. **End-to-end finite-cell limit**. Reuse the already certified Q2 finite-label variance/influence contraction and density, while proving that the `d`-degree hypothesis survives each approximation. Handle variance zero, `d=0`, empty coordinate sets and arbitrary essential (rather than global) bounds separately.
5. **Independent audit and prior art**. An adversarial checker must try zero-mass categorical counterexamples, nonrectangular encodings, uncountable index cases, scaling conventions, the source-vs-tagged-law influence and a misleading classical-simulation claim. Settle the purported Zenodo source before any novelty statement.

## Cheap decisive experiment and stop rule

First run the strict Lean file using the existing original-label residual dependency compilation order. A missing theorem or nonstandard axiom is failure, not success. Only after that, implement a single general finite ANOVA-to-indicator bridge for all `d`, rather than building `d=3,4,5,...` special cases. A three-site Q2 specialization is a fast regression against the existing certified `source_label_projection_triple_zero`. Stop numerical constant optimization until the global degree bridge is proved.

## Certification and audit log

| Component | Status | Certificate / pending check |
|---|---|---|
| Finite AA bound `product_influence` | Historical Lean certificate only | Current 4.36 recompile required |
| Original-law all-L² source/label intertwining | Previously pinned Lean-checked in merged Q2 integration | Exact imported source |
| Arbitrary-word residual/adjoint transfer | Provisional new Lean construction | Strict PR CI in progress |
| Native categorical `d` indicator bridge | Open | No source-exact proof yet |
| Infinite-product AA terminal | Open | Do not claim full theorem |
| Quantum query corollary | Open | Needs encoding / acceptance / distributional proof |
| Priority and independent review | Open | Accessible dated source comparison required |

Scope boundary: an operator-preservation result is not an influence bound. Treat no exploratory Lean file, passing self-check or numerical experiment as external certification.
