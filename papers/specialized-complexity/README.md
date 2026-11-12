# Paper C — Specialized Complexity of Adaptive Observation

**[Read the complete manuscript](MANUSCRIPT.md)** · Devin J. Wright / NIGHTFALL · 11 November 2026.

**Subtitle:** Certificate Geometry, Rank Structure, and Finite-Field Phase Codes.

**Status:** Public author-side analytic and finite-computational manuscript for independent mathematical review. Not a worldwide-originality certificate, external referee acceptance, or end-to-end Lean proof.

## What this paper adds to the series

Paper A treats exact finite-palette whole-coordinate recovery. Paper B treats general bounded Hilbert-valued approximation and spectral tails. Paper C distinguishes specialized structural regimes that admit stronger or differently normalized complexity bounds.

- **Certificate overlap:** finite Boolean product observables with bounded fractional certificate rows admit a geometric expected-posterior contraction and logarithmic risk dependence under the exact normalized directed-resampling influence inequality.
- **Disjoint output groups:** an independently proved scalar allocation consequence of Paper B gives rank-linear, not general rank-free, dependence.
- **F16 cubic-power oracle:** explicit fixed 81-state and adaptive 27-state phase codes; k=4,5,7 exact query optima in the source's strictly defined powered-query model. The 27-state Lean certificate lives in **closed, unmerged** PR #252; original adaptive construction from closed PR #255. Do not represent either as a merged main-branch Lean declaration.
- **Quadratic exponent-two:** an *unrefereed conditional strengthening*, not a prerequisite for the first three mechanisms.

**Dated note (12 November 2026).** `MANUSCRIPT.md` is hash-pinned and is not edited. Its equation (16) quotes the earlier coefficient \(16(1+\sqrt3)\), and the following paragraph quotes v7's \(15(1+\sqrt3)\). The current written proof is [v9.2](../finite-product-influence/NIGHTFALL_Beyond_Boolean_Cube_v9_2.pdf) (same constant as v8): \(\mathrm{Var}(f)\le D_2B\sqrt{\sup_iI_i(f)}\) with \(D_2=(10+2\sqrt2)(1+\sqrt3)\approx35.05\), including the rank-\(r\) lift. Proposition 4 then holds with \(C_2\) replaced by \(D_2\), **still conditional** because the premise has not been externally refereed. See [the internal review](../finite-product-influence/V9_2_INTERNAL_REVIEW_20261112.md). The finite-field claims were independently replayed by [check_f16_independent_20261112.py](../../research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/check_f16_independent_20261112.py).

## Repository integration and exact claim identity

- [Selected claim record](../../research/catalogue/CLAIMS.json): `NF-OBS-SPECIALIZED-20261111`, with finite-computational, analytic, inherited and conditional components distinguished explicitly.
- [Series dependency graph](../../research/catalogue/DEPENDENCIES.md): Paper C imports Paper B's scalar bound for disjoint-group allocation, while the F16 oracle and certificate-guided Boolean sampler are distinct mechanisms.
- [Principal mathematics entry point](../../docs/mathematical-results.html): Papers A/B/C are linked together without changing the frozen historical 40 records.
- [Independent referee assignment](../../research/referee/README.md): tests the exact query model, conditional posterity and historical source scope.

## Artifacts

- [Markdown manuscript](MANUSCRIPT.md) is the canonical reviewed text.
- `Specialized_Complexity_Manuscript.tex` and `Specialized_Complexity_Manuscript.pdf` are generated from the Markdown by the reproducible GitHub Actions workflow.
- [Exact finite-field replay](replay_f16_specialized.py) and its JSON receipt are a mathematical finite audit, not a new originality claim.
- `Specialized_Complexity_Source_and_Audit.zip` packages sources, PDF, checker, and a SHA-256 manifest. **The original local archive was repaired because its ZIP omitted the PDF named in the manifest**; CI rebuilds a self-contained package.

## Checkers and source lineage

- [Main-branch fixed block](../../research/nightfall/formalization/phase_block/PhaseBlock.lean); [corresponding proof passport](../../docs/phase-block-proof-passport.html).
- [Recovered archived adaptive finite certificate](../../docs/phase-adaptive-branch-proof-passport.html), including source SHAs, exact branch table, and archived passing CI.
- [Certificate sampler and expected-posterior bridge](../../research/nightfall/formalization/product_space/VariancePosteriorOneStep.lean).
- [Paper B's disjoint-output rank-linear proof](../spectral-adaptive-prediction/MANUSCRIPT.md).
- [Quadratic source-status disclosure](../../research/nightfall/formalization/observability/QUADRATIC_DISCOVERY_PROOF_PASSPORT.md).

**Reproduce:** `python3 replay_f16_specialized.py`; if generated files are present, run `sha256sum -c SOURCE_SHA256SUMS`; the archive contains its own matching source hashes. The 2026-11-11 original prepared ZIP and PDF may not have identical bytes to a CI rebuild because TeX/Pandoc versions, timestamps, and PDF metadata vary. Exact mathematical content and checked witness counts are preserved; do not claim byte-identical reproduction of a regenerated PDF.

**Publication boundary:** Independent source-level review and dated same-model prior-art search remain open. Repository publication is not journal submission.
