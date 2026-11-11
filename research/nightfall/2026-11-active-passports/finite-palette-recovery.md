# Proof Passport: NF-FINITE-PALETTE-RECOVERY-20261111

**NIGHTFALL Constellation · Devin J. Wright · version 1.0 (2026-11-11).**
**Status:** WRITTEN ANALYTIC CANDIDATE; finite Lean core checked; infinitary bridge OPEN. This is a claim-specific proof-passport note, not an independently refereed theorem or novelty certificate.

## Exact claim and quantifiers

For a bounded independent-product function of interaction degree ≤d with a finite palette of q real values, range R and minimum gap Δ>0, the v1.1 analytic audit proposes almost-sure exact recovery after at most d·floor(d²·min{(q−1)²,2R/Δ}) whole-coordinate observations, independent of input dimension.

**Display shorthand:** `Dμ(f) ≤ d⌊d² min{(q−1)², 2R/Δ}⌋  (candidate)`

## Premises

1. Independent coordinates, potentially infinitely many, with completed-product measurability and finite-output palette.
2. Hoeffding interaction degree ≤d, q finite, minimum palette gap Δ>0 and range R.
3. Correct statements are almost sure; no uniform pointwise recovery or efficient selection is claimed.

## Mechanism (dependency graph)

1. Every measurable function is represented almost surely on a countable effective coordinate set; sections and nonzero top-order interactions are selected measurably.
2. Nonconstant maximal-order block sections yield positive-measure resampling witnesses. Disjoint replacement blocks preserve finite interaction degree on an almost-sure common-good set.
3. Markov derivative / finite-palette Boolean interpolation bounds the number of disjoint sensitive blocks; at most d new coordinates are revealed per round.

## Provenance and certification

1. FiniteSwitchingCore and other finite-section/energy helpers have 13 scoped Lean declarations recorded in the recovery receipt; they do not certify the whole theorem.
2. Finite ANOVA and switching checks include 952 exact instances. The adversarial audit records explicit null-set and overlapping-switch failures for invalid proof shortcuts.
3. The v1.1 bound contains 2R/Δ, whereas earlier v0.2/v0.3 sources claim R/Δ. The constants and hypotheses are not reconciled; no silent strengthening is made.

**Primary source:** `research/nightfall/2026-11-five-closures/FIVE_CLOSURES_V11.md`. The present page is a source-bound summary and does not supersede the primary original proof.

**Research source links:**
- [Exact-recovery proof attack](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/product_space/EXACT_RECOVERY_ADVERSARIAL_AUDIT_20261110.md)
- [Finite Lean and checker receipt](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/product_space/RECOVERY_CERTIFICATE_RECEIPT_20261110.md)
- [Infinitary analytic v1.1](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/2026-11-five-closures/FIVE_CLOSURES_V11.md)
- [Finite-palette alternative candidate](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/2026-11-observability/FINITE_PALETTE_CERTIFICATE_OBSERVATION_V03.md)

## Failure conditions, limits, and priority

1. The joint countable-selection, conditional Fubini and simultaneous hybrid-degree arguments have not been independently refereed or compiled in Lean.
2. The finite-palette condition cannot simply be replaced with countable values, even if entropy is low.
3. No efficient algorithmic runtime, globally novel theorem, or all-product pointwise theorem is established.

**Upstream attribution and comparison:** Classical Hoeffding/ANOVA, finite block sensitivity (Tal and adjacent work), Markov derivatives, and NIGHTFALL's scoped Lean switching proof. All general-measure claims are unrefereed.

## Independent adversarial audit

Independently rederive the countable-support representation for completed products, pin sections and nonzero component choices, create a single Fubini-good set for every finite queried-block sequence, and resolve the factor-two R/Δ discrepancy before any theorem promotion.

**Gate:** Preserve this certificate and every failed or superseded result, but do not promote to published novel theorem without independent proof review and dated prior-art comparison. No frozen historical Proof Passport or five approved Original Findings are being changed.
