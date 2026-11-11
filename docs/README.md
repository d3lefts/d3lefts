# NIGHTFALL public website

A static research website built from checked-in HTML, CSS, JavaScript, and source-linked research records. The public site is served from [`main/docs`](./) at [d3lefts.github.io/d3lefts](https://d3lefts.github.io/d3lefts/).

**Current editorial snapshot: 10 November 2026.** The archive presents 40 curated research records and 11 scoped Proof Passports. Its separately designated five finite/bounded findings are **not** claims of worldwide mathematical novelty. The November observability publication drafts add a proposed quadratic influence theorem, adaptive/nonadaptive query separation and a cubic proof-obstruction note, outside the frozen catalogue. The earlier Certificate Engine v2 page preserves its seven-declaration Lean checkpoint; later finite-product receipts have distinct proof scope. External mathematical and originality reviews remain open.

## Identity: evidence-bearing discoveries that compound

The public identity is **“Discovery should compound. Evidence should travel.”** The [Discovery System](discovery-system.html) is the scientific architecture: represent the problem, invent a mechanism, attach a claim-specific Proof Passport, submit the evidence to independent criticism, preserve corrections, and investigate typed transfers.

- **Proof Passports** record validity, reproducibility, originality and significance separately. The dated historical registry has 11 claims; the separate manually maintained active ledger has 4. These are not fifteen proved theorems.
- **Constellation / Mechanism Atlas** uses the historical registry's five mechanism categories and twenty typed claim–method edges. Finite checks, shared methods, open premises and analogies are not equivalent; active passports are not yet integrated into those frozen graph counts.
- **Independent Review** supplies bounded falsification and audit routes. **NEW MOON** preserves past witnesses and corrected/negative evidence; **NULL FIELD** tracks the still-open frontier.
- No homepage, graph visualization, green CI run, typed relationship or internal model review promotes a mathematical claim into a certified theorem, novel contribution or externally refereed result.

## Two distinct site experiences

| Experience | Entry point | Purpose |
| --- | --- | --- |
| **NULL FIELD** | [`index.html`](index.html) | **Active research**: Wright product-space influence, quadratic observability, candidate proofs, formalization gaps, adversarial tests, and open next steps |
| **NEW MOON** | [`new-moon.html`](new-moon.html) | **Archived breakthrough research**: Erdős finite overlap witnesses, Sidon constructions, earlier campaign records, exact checkers and provenance |

Both experiences share source records and review standards, but divide by research lifecycle, not proof strength. An archived candidate is not automatically a certified theorem, and an active theorem can have checked sublemmas. The historical CSS token `data-nf-experience="archive"` denotes the NULL FIELD light palette for compatibility; it is **not** a scientific archive classification. Do not rename this implementation token until linked CSS and browser tests migrate together. Each landing page has a distinct layout. Keep the theme switch functional, keyboard-accessible, and honest about destination.

## Research and verification pages

| Entry | Meaning |
| --- | --- |
| [`research.html`](research.html) | Curated library, source distinctions, scope-qualified records and filters |
| [`discovery-system.html`](discovery-system.html) | Six-stage scientific identity, typed mechanism graph coverage, linked Proof Passports and explicit publication stop rules |
| [`product-space-influence.html`](product-space-influence.html) | Candidate influence/fractional-certificate manuscript, formalization evidence and outstanding proof obligations |
| [`observability.html`](observability.html) | Current quadratic observability principal manuscript, query separation, companion certificate bridge, explicit cubic obstruction and publication gates |
| [`active-proof-passport.html`](active-proof-passport.html) · [`JSON`](active-proof-passport.json) | Manually versioned active claim registry (four scoped records, proof dependencies, limits and next audit), distinct from the frozen 11 historical Passports |
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
