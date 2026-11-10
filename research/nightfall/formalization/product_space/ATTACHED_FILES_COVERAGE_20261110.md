# NIGHTFALL — attached-manuscript Lean certification scope

**Checkpoint:** 10 November 2026. **Branch:** nightfall-lean-attached-theorems-20261110.  
**Compiler:** official Lean 4.35.0, Mathlib v4.35.0, through the existing repository bridge.  
**Scientific status:** **17 new kernel-compiled declarations in three files, not a formal proof of all attached manuscripts.** Passing finite checks or Lean lemmas does not establish novelty, significance or publication eligibility.

## New certificates from this PR

| File | Named declarations | Exact claim kernel-checked | Premises / unresolved steps |
| --- | ---: | --- | --- |
| [ANOVAActivation.lean](ANOVAActivation.lean) | 4 | Finite interaction-energy activation: monotonicity of explained energy, raw increment identity, exact coordinate-gain formula, and supermodularity for nonnegative interaction energies | Represents ANOVA components as an energy table; does **not** derive the Hoeffding decomposition, conditional expectation identity, measurable coordinate selection or arbitrary-product theorem |
| [RestrictedInfluence.lean](RestrictedInfluence.lean) | 3 | Square-root influence budget and sharp additive algebra: if coordinate variances obey Popoviciu and the total oscillation budget is at most 2B, then V² ≤ B²M; in particular V² ≤ M for B=1 | Product-space facts V=ΣI, total oscillation ≤2B, and I_i≤radius_i²/4 are **explicit hypotheses**. The full probability-space degree-one theorem is **not** certified by this file |
| [QuarticRademacher.lean](QuarticRademacher.lean) | 10 | Real-linear finite fair-sign expectation and exact fourth moment E(Σa_i ε_i)^4=3(Σa_i²)²−2Σa_i⁴≤3(Σa_i²)² | Does **not** prove the affine certificate-row inequality Q(3), the weighted Cauchy comparison or general quartic conjecture Q(C) |

The named declarations compile under the pinned Mathlib toolchain with only the standard Lean foundations **propext**, **Classical.choice**, and **Quot.sound**; no `sorry`, `admit`, custom axioms, `native_decide` or untrusted reductions were accepted. Reproduce by running [the dedicated GitHub Actions workflow](../../../.github/workflows/nightfall-attached-manuscript-lean.yml); the official run preserves exact source SHA-256, named-axiom receipts, toolchain, and Mathlib commit. The procedural output is evidence of these precise formal statements, not of mathematical novelty.

**Successful proof receipt:** https://github.com/d3lefts/d3lefts/actions/runs/42883199924

## Source inventory of 10 user-supplied attachments (SHA-256)

These user-uploaded files were consulted to select the formalization targets. The original bytes are not silently uploaded, replaced, or presented as approved public releases.

| Attachment | SHA-256 |
| --- | --- |
| NIGHTFALL_TwoDraw_Transfer_Research_Note_20261110(1).pdf | `ef290d3bac3e5e273a0ec9db17ff808687f4cc6865d8671c5c6b99e95246d953` |
| Wright_Certificate_Engine_v3_Referee_Package_20261110(1).zip | `620139f49c85723d2fc123fc5dad53e68fdbd324c2dc2884eea506e45bea6c5a` |
| NIGHTFALL_Exact_Adaptive_Recovery_Referee_Package_20261110(1).zip | `6672eee3ae722c94ba3c49558e987aa8403b4756062a0dcc6bed55e75b4c731b` |
| Wright_Influence_Product_Spaces.pdf | `416bfe6a64112602364fb7d7ae301ca8c7680e31e481773777967abac24d304c` |
| Wright_Restricted_Exponent_Two_Audit(1).zip | `76f47d51b2b36c6301d6687767d3c8b9ffab4b4570f4e340a8ef938b067c0beb` |
| Wright_Two_Papers_2026-11-10.zip | `dabf4df3d581c3884ea7ba9b8e003d1dfad90340e5b3ae5f83fb959bbac661e3` |
| NIGHTFALL_TwoDraw_Transfer_Manuscript_and_Evidence_20261110(1).zip | `7252a681541f6103830aadf9413d0126255f287687775f683f35cbf23fee69a9` |
| Wright_Restricted_Exponent_Two_Proof_Note(1).pdf | `dd8076990ac9249a34ac8d9b7d078d12c9ef827ad11ba040de33330eaaf70744` |
| Wright_Quartic_Antipodal_Inequality.pdf | `3bb41bc4ab3adb7cfba6f66557e67c861e255a4beb29766e5ad1893a3c5cf87e` |
| Wright_Exact_Adaptive_Recovery_Referee_20261110(1).pdf | `84e3505d0fbe1770716cb222d6e52b8410ec765a255b8ea113a8268f3b50d5f1` |

## Existing merged prerequisites and active independent branch

- [PR #289](https://github.com/d3lefts/d3lefts/pull/289): seven finite orientation and positive-support localization declarations kernel-checked. These do **not** certify product-space A–A.
- [PR #293](https://github.com/d3lefts/d3lefts/pull/293): seven **conditional** weight-removal declarations, with positive reciprocal-premise inputs, kernel-checked.
- [Draft PR #295](https://github.com/d3lefts/d3lefts/pull/295): weighted two-draw transfer and mass absorption. The mass-weighted removal module has passed separately; the end-to-end reciprocal transfer is **not** kernel-certified. A concrete Lean 4.33.0 error and minimal proposed fix are recorded in the PR discussion. The two external toolchain tracks (Lean 4.33.0 vs 4.35.0) must be composed carefully, with Turturean's source and commit pinned.

## Exact finite checkers also replayed locally

The attached two-draw archive's two standard-library scripts returned **40** and **30** valid finite cases (70 total). The v3 extension script completed its own exact finite activation and restricted checks. The adaptive-recovery script reproduced exhaustive tables on four Boolean inputs (65,536) and three ternary-output inputs (6,561), alongside 1,950 independent exact explained-variance identities. The restricted-exponent counterexample checker also ran. These are **falsification screens and arithmetic evidence**, never proofs of universal claims.

## Remaining decisive formal gates (not certified)

1. **Finite-product reciprocal inequality:** Compose the externally imported Turturean antipodal theorem, restricted rows, positivity, two-draw orientation, and the directed boundary factor. PR #295 owns this; no duplication in this PR.
2. **Complete localized product influence theorem:** Derive the localized two-sided inequality from the reciprocal theorem and conditional weight-removal (including zero-probability atoms); formalize competing-symbol Chebyshev certificate rows, median estimates and the arbitrary-product measurable extension. The `(5/2,6)` influence theorem remains a manuscript claim in this chain.
3. **Exact finite-palette adaptive recovery:** Formalize the sensitivity/degree bound, maximal interaction support, finite query-tree construction, and countable-support/Fubini/measurable-selection passage for unrestricted product coordinates. ANOVA activation alone is insufficient.
4. **Restricted exponent-two theorems:** Prove the quadratic biased-bit Khintchine/sensitivity estimates, sparse interaction-cover projection inequality, and block-additive theorem inside Lean, not merely their algebraic consequences.
5. **Quartic conjecture:** The general Q(C) remains a conjecture. For affine Q(3) the newly checked fourth moment must still be joined to certificate-row lower bounds and weighted reciprocal Cauchy–Schwarz. One-level mean-crossing bounds with exponents (2,4) do not establish a full squared-influence bound.
6. **Independent expert validation / originality:** No external nonauthor referee, original-contribution determination, or public publication/competition submission is implied.

### Independent audit plan and stop rule

For each remaining theorem, demand a single named Lean declaration with explicit quantified assumptions, replayed source hashes, absence of untrusted axioms and independent proof-review of model-to-formal-statement equivalence. If only a consequence of an unproved premise compiles, retain **conditional formalization** status. Stop expanding low-value examples when the all-pairs and measurable-selection bridges remain unresolved.

**Credit:** Research led by Devin J. Wright. The uploaded manuscript packages credit work from ChatGPT/GPT-6 and Claude. David Turturean's antipodal theorem, FHKL sensitivity results, classical ANOVA and decision-tree theory remain separately attributed; no source authorship or independent human review is reassigned.
