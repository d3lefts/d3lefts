# NIGHTFALL public website

A static research website built from checked-in HTML, CSS, JavaScript, and source-linked research records. The public site is served from [`main/docs`](./) at [d3lefts.github.io/d3lefts](https://d3lefts.github.io/d3lefts/).

**Current editorial snapshot: 10 November 2026.** The archive presents 40 curated research records and 11 scoped Proof Passports. Its separately designated five finite/bounded findings are **not** claims of worldwide mathematical novelty. New product-space influence and Certificate Engine v2 manuscripts remain candidate research with seven separately scoped Lean-compiled declarations.

## Two distinct site experiences

| Experience | Entry point | Purpose |
| --- | --- | --- |
| **NULL FIELD** | [`index.html`](index.html) | Evidence-first research homepage, selected finite findings, current discoveries, and direct independent-review routes |
| **NEW MOON** | [`new-moon.html`](new-moon.html) | Open research ledger, unresolved mathematical work, and inspectable instruments |

Both experiences share common tokens and navigation logic but have distinct page layouts. Keep the theme switch functional, keyboard-accessible, and honest about destination.

## Research and verification pages

| Entry | Meaning |
| --- | --- |
| [`research.html`](research.html) | Curated library, source distinctions, scope-qualified records and filters |
| [`product-space-influence.html`](product-space-influence.html) | Candidate influence/fractional-certificate manuscript, formalization evidence and outstanding proof obligations |
| [`review.html`](review.html) | Independent reviewer paths and bounded validation tasks |
| [`passport.html`](passport.html) | Claim-scoped proof passports and their dependencies |
| [`evidence.html`](evidence.html) | Public evidence release and reproducibility access |
| [`exact-research.html`](exact-research.html) | Local exact finite tools and guided replay |

Site components and finite tools do not certify mathematical conjectures. The authoritative state of each theorem, finite witness or experiment is given by its linked primary source and checker.

## Editing guidelines

1. **Keep the distinction between claims and evidence.** A candidate proof, an exact finite witness, a kernel-checked *sublemma*, a complete theorem, and a historically novel contribution must not share an undifferentiated success label.
2. **Link to canonical research artifacts.** Cite source versions and reusable checker receipts rather than inventing summary numbers or copying immutable witness data into HTML.
3. **Preserve provenance.** Credit the original mathematical authors and explicitly document substantial AI-generated drafting or code. Named AI agents are not human staff or independent peer reviewers.
4. **Maintain both experiences.** Check dark/light contrast, narrow-phone layout, keyboard focus, accessible disclosure labels, and reduced-motion handling.
5. **Avoid documentation by accumulation.** Update this guide when site architecture changes; preserve dated historical notes separately in [the October development history](SITE_DEVELOPMENT_HISTORY_2026-10.md).

### Quick local checks

Run from the repository root:

```bash
python3 scripts/check_site.py
python3 scripts/test_repository_docs.py
node scripts/test_proof_passport_batch.cjs
node --check docs/site.js
```

Browser acceptance tests require Chromium and `playwright-core` (pinned in the workflow). See [Verify research website](../.github/workflows/verify-site.yml), which checks static URLs, on-page anchors, source scope, theme behavior, and responsive browser paths. The dedicated product-space dossier test is [`scripts/test_product_space_presentation.mjs`](../scripts/test_product_space_presentation.mjs).

Do not update canonical source counts or scientific status merely to make a test pass. Resolve the underlying discrepancy and retain corrections.

## Deployment

GitHub Pages is configured for the **`main` branch, `/docs` directory**. The [site validation workflow](../.github/workflows/verify-site.yml) runs on pull requests and relevant pushes. Verify published Pages separately after merging; a green source check does not by itself establish a successful public deployment.

This folder contains a website and local instruments, not a stand-alone software package. For research attribution, contribution rules, historical releases, or licensing limits, consult the repository [README](../README.md) and [CONTRIBUTING](../CONTRIBUTING.md) documents.
