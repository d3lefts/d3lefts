# NIGHTFALL / PHASESHIFT

**An open research archive for mathematics, exact computational evidence, and trustworthy AI systems.**

Research directed by **Devin J. Wright** · Human-led, AI-assisted · 2026

[Principal mathematical results](https://d3lefts.github.io/d3lefts/mathematical-results.html) · [Research website](https://d3lefts.github.io/d3lefts/) · [Browse research](https://d3lefts.github.io/d3lefts/research.html) · [Independent review](https://d3lefts.github.io/d3lefts/review.html) · [Source and evidence](https://d3lefts.github.io/d3lefts/evidence.html)

[![Verify research website](https://github.com/d3lefts/d3lefts/actions/workflows/verify-site.yml/badge.svg)](https://github.com/d3lefts/d3lefts/actions/workflows/verify-site.yml)

NIGHTFALL studies mathematical structures and builds reproducible mechanisms for discovering, checking, and explaining results. Every claim should travel with its **statement, assumptions, source, verification method, and limitations**. A computation, a formal proof, an originality assessment, and a competition result are different kinds of evidence.

## Start here

| Area | What is available | Where to inspect it |
| --- | --- | --- |
| **Product-space influence and fractional certificates** | Certificate Engine v2 candidate and a separate **Lean 4.33.0 kernel-compiled finite-product scalar influence theorem** (PR #317; exponent 5/2, explicit weaker coefficient), alongside earlier **Lean 4.35.0** supporting bridge lemmas with narrower scopes. General measurable/infinite-product and adaptive Hilbert extensions are analytic proof candidates rather than end-to-end Lean results. The unrestricted exponent-two “(2,4)” influence problem remains open. | [Manuscript and checks](research/nightfall/2026-11-certificate-engine/README.md) · [Lean source](research/nightfall/formalization/product_space/) · [Proof-status dossier](https://d3lefts.github.io/d3lefts/product-space-influence.html) |
| **Cubic leaf-alphabet-free influence (active, restricted)** | Analytic exponent-two bound for cubic interactions with a bounded **top-degree-only** vertex cover; also any number of independent covered blocks, with no leaf count/alphabet/minimum-mass factor. Includes an exact selector sharpness example, a nonadaptive lower bound, and a rank-sensitive Hilbert corollary with a logarithmic overhead. **Not the unrestricted cubic theorem; no external peer review or full Lean receipt.** | [Proof and limits](research/nightfall/2026-11-cubic-leaf-alphabet-free/PROOF_NOTE.md) · [Exact direct-resampling checks](research/nightfall/2026-11-cubic-leaf-alphabet-free/check_leaf_free_exact.py) · [Review PR #335](https://github.com/d3lefts/d3lefts/pull/335) |
| **Erdős minimum overlap** | Exact finite rational witness and independently replayable arithmetic; mathematical witness identity is distinct from any accepted competition entry. | [Evidence and prior-art status](research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md) |
| **Sidon and finite-field constructions** | Explicit finite objects, exact checkers, source-dependent theorem candidates, and open proof/novelty audits. | [Curated research index](research/nightfall/README.md) |
| **Werner-state bounds** | Conditional finite-copy certificate registry and documented source-inequality dependencies. | [Werner atlas](research/nightfall/projects/werner-atlas/README.md) |
| **AI safety and verification** | SourceBound/authorization research and a publicly available review release; theoretical claims and measured experiments are distinguished. | [Review dossier](research/nightfall/projects/ai-safety-peer-review-2026-10-28/README.md) |

**Editorial scope (10 November 2026, with 11 November UTC research updates).** The website includes 40 curated research records, 11 evidence-specific Proof Passports, and five internally approved finite or bounded findings (three in the core index and two in a separately scoped publication note). These are *catalogue and evidence classifications*, **not** a claim that five globally original theorems have received independent peer review. New candidate manuscripts remain outside that approved finding set.

## Read and verify the evidence

- [Current public research library](https://d3lefts.github.io/d3lefts/research.html), [claim-specific limitations](research/nightfall/AUDIT.md), and [publication-scope boundaries](research/nightfall/PUBLICATION_SCOPE.md).
- [Review protocol](research/nightfall/REVIEW_PROTOCOL.md) explains reproducibility, formalization, attribution, and counterexample reporting.
- [Public curated evidence release](https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28) includes the archived checksums and supporting materials. The private historical master archives are **not** public release assets.

### Repository guide

| Path | Purpose |
| --- | --- |
| [`docs/`](docs/README.md) | Static research website, accessible interactions, and its development guide |
| [`research/nightfall/`](research/nightfall/README.md) | Manuscripts, candidate proofs, certificate packages, research histories, and independent audits |
| [`research/nightfall/formalization/`](research/nightfall/formalization/) | Lean proof sources with explicitly scoped theorem statements |
| [`scripts/`](scripts/) and [`tests/`](tests/) | Exact checkers, CI support, website tests, and adversarial controls |
| [`.github/workflows/`](.github/workflows/) | Automated checks and reproducibility receipts |

### Reproduce a first check

From the repository root with Python 3 and Node.js:

```bash
python3 scripts/check_site.py
python3 scripts/test_repository_docs.py
node scripts/test_proof_passport_batch.cjs
```

These are documentation/site and **scoped finite-record consistency checks**, not mathematical refereeing. Some browser tests require Chromium and Playwright; specialist research checkers document their own inputs, toolchains, and hashes. For the pinned Lean bridge, see [the formalization directory](research/nightfall/formalization/product_space/) and [contribution guide](CONTRIBUTING.md).

## Contribute or report a problem

Independent replications, attempted counterexamples, missing-source reports, and priority corrections are welcome. Open a [verification report](https://github.com/d3lefts/d3lefts/issues/new/choose), or use [CONTRIBUTING.md](CONTRIBUTING.md) and the repository pull-request template for source-backed changes. Negative results and superseded claims remain part of the record.

This project is **human-directed and substantially AI-assisted**. Specific manuscripts credit earlier authors, imported theorems, AI drafting contributions, and independent reviewers separately. A green CI run or an AI cross-check is not an external peer-review endorsement.

### Reuse and licensing

There is **no repository-wide `LICENSE` file** at this checkpoint. Public visibility alone does not grant a blanket right to reuse source code, figures, manuscripts, or third-party materials. Check individual files and upstream sources, and obtain permission where required. [Citation metadata](CITATION.cff) describes how to credit the archive; it is not a software license.
