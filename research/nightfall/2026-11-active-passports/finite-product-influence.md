# Proof Passport: NF-FINITE-PRODUCT-INFLUENCE-20261111

**NIGHTFALL Constellation · Devin J. Wright · version 1.0 (2026-11-11).**
**Status:** LEAN CHECKED • finite theorem; priority and external referee open. This is a claim-specific proof-passport note, not an independently refereed theorem or novelty certificate.

## Exact claim and quantifiers

For bounded real f with product indicator degree at most d on a finite product, there is a coordinate j with 3·Var(f)^5 ≤ 12500·(π²d²)^6·I_j(f)^2. The marginal probabilities may depend on j and may contain zero-mass atoms; the alphabets share one finite Lean type.

**Display shorthand:** `3 V⁵ ≤ 12500 (π²d²)⁶ Iⱼ(f)²`

## Premises

1. Finite coordinate type and common finite alphabet type; arbitrary coordinate-dependent probability tables, including zero masses.
2. Pointwise |f|≤1, positive product variance V, indicator-monomial product-degree bound ≤d.
3. Independent-resampling influence I_j = E[(f−E_j f)²], and the exact pinned statement rather than a stronger manuscript constant.

## Mechanism (dependency graph)

1. Product competing-symbol rows have certified total cost ≤π²d².
2. Two independent draws and orientation convert heterogeneous marginals into fair conditional signs; localized two-sided inequalities charge squared influence.
3. Imported Turturean level-set/median machinery composes with the product rows. The source declares the same standard axioms; there are no sorry/custom axioms in the specified CI receipt.

## Provenance and certification

1. Merged PR #317 at checked head e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb, successful GitHub Actions run 42929857470.
2. 19 named declarations; checked axiom set Classical.choice, Quot.sound, propext, no sorryAx.
3. Pinned theorem constant c*=sqrt(3/12500)/π⁶ ≈ 0.00001611411225. This does NOT certify the larger candidate constant in a separate manuscript.

**Primary source:** `research/nightfall/formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md`. The present page is a source-bound summary and does not supersede the primary original proof.

**Research source links:**
- [Lean proof passport](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md)
- [Pinned Lean source](https://github.com/d3lefts/d3lefts/blob/e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb/research/nightfall/formalization/product_space/ProductInfluence.lean)
- [Kernel compilation and axiom receipt](https://github.com/d3lefts/d3lefts/actions/runs/42929857470)

## Failure conditions, limits, and priority

1. No kernel-checked measurable/infinite-product extension; no bridge to arbitrary Hoeffding degree in all spaces.
2. No full quadratic (2,4) theorem, adaptive Hilbert observer, runtime bound or quantum consequence follows automatically.
3. Independent human proof review and dated priority audit still open. The core cube method is due to David Turturean.

**Upstream attribution and comparison:** David Turturean, 2026 (arXiv:2611.09773); product transfer NIGHTFALL PR #317. Classical Hoeffding–Efron–Stein influence normalization. Do not attribute Turturean's cube theorem to NIGHTFALL.

## Independent adversarial audit

Rebuild the pinned PR #317 with the exact upstream Turturean commit; inspect product-degree and zero-atom hypotheses and the precise theorem type; separately formalize the finite-law ANOVA support-degree equivalence and measurable-product bridge.

**Gate:** Preserve this certificate and every failed or superseded result, but do not promote to published novel theorem without independent proof review and dated prior-art comparison. No frozen historical Proof Passport or five approved Original Findings are being changed.
