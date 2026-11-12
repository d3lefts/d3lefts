# Canonical research catalogue

**Dated:** 11 November 2026. **Audience:** external mathematicians, reviewers, and reproducibility engineers.

This directory is the **canonical scholarly claim index** for selected principal results, supporting constructions and adverse experiments. The actual theorem texts, Lean sources, checkers, and historical evidence remain at their original paths: this migration is a *linking/metadata reorganization*, not a source rewrite. The historical [40-record selection](../nightfall/SITE_CURATED_40_20261030.json) and its 11 historical Proof Passports are preserved and not silently reclassified.


**November 11 publication-preflight revision:** [four-paper research and referee queue](../../papers/publication-preflight-20261111/README.md), [source-custody map](../../papers/publication-preflight-20261111/SOURCE_MAP.md), and [independent mathematical review gates](../../papers/publication-preflight-20261111/REFEREE_GATES.md). The selected machine registry now includes individually scoped SLD sharpness, Werner inverse-k continuation and exact 4/5-shuffle entries. These entries do not certify novelty or convert package-only N5 bytes into GitHub reproducibility; they remain active unrefereed research claims.

## Read the evidence

- [Machine-readable claim registry](CLAIMS.json): exact status, dependencies, source access, evidence files, and unresolved review/priority gates. This registry is intentionally selective, not a count of globally original theorems.
- [Paper shelf](../../papers/README.md): referee-first narratives, including [Paper A](../../papers/exact-recovery/MANUSCRIPT.md), [Paper B](../../papers/spectral-adaptive-prediction/MANUSCRIPT.md), and [Paper C](../../papers/specialized-complexity/MANUSCRIPT.md), each pointing to a source of truth.
- [Dependency and certification protocol](DEPENDENCIES.md): what may be inferred, and what cannot.
- [Independent referee desk](../referee/README.md): decisive mathematical review briefs and how to submit a reproducible objection.
- [Historical preservation guide](../archive/README.md): source custody, superseded claims and release access.

## Status meanings (independent dimensions)

| Axis | What it establishes | What it does *not* establish |
| --- | --- | --- |
| `validity` | A theorem source, exact checker, or explicit unresolved proof claim | Historical novelty, publication acceptance |
| `source_status` | Availability and completeness of named public input objects | Valid mathematical argument |
| `review` | Whether a non-author mathematical review has been recorded | Whether the checker found a counterexample |
| `priority` | Whether source-to-source historical originality has been determined | Whether a theorem is correct |
| `dependencies` | Which repository claims are imported as premises | Automatic promotion from a green CI run |

**Kernel-checked scoped:** only the exact named Lean declaration with its source commit, axioms and imported premises. **Finite-exact replayed:** exact finite evidence, not a universal theorem. **Conditional:** result depends on a separately unresolved premise. **Analytic manuscript:** a written argument awaits a non-author proof audit. **Conjecture:** not established. **Retrospective/adverse:** preservation of a failed or scope-limited evaluation.

A public folder, paper title, PR, or successful website CI is not an independent referee report. Never promote a downstream result without closing every load-bearing premise and recording independent scope-matched review.

## Paper-series custody

The selected `NF-OBS-SPECIALIZED-20261111` catalogue entry points to Paper C's canonical Markdown, generated PDF/LaTeX, exact F16 checker and JSON receipt, checksum manifest and archive. Its status records all four component scopes separately. This is **not** an addition to the frozen 40 historical site records or 11 historical Proof Passports. The scholarly checker also validates the published Paper C bundle byte-for-byte without treating its finite replay as an external referee decision.

## Maintenance

Use `python3 scripts/check_research_archive.py` before submitting a change. The checker validates file paths, IDs, dependency acyclicity, status schemas, formal-proof provenance fields, and external-review stop rules. It **does not prove mathematics** or inspect external literature. Add a new claim only when a stable primary source and its distinct evidence gates exist. Preserve superseded evidence and reasons. Avoid adding the same result as a new claim merely because an agent or manuscript version changed.

Rights and citation: [Reuse and rights notice](../REUSE_AND_RIGHTS.md) · [CONTRIBUTING.md](../../CONTRIBUTING.md) · [CITATION.cff](../../CITATION.cff).
