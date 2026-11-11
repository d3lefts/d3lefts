# NIGHTFALL Mathematical Research Archive

**Archive map · 11 November 2026**  
**Custodian:** Devin J. Wright / NIGHTFALL PHASESHIFT. **Status:** open research repository, not a journal-accepted collection.

A first-time mathematician should begin with the **claims and their evidence**, not a list of every research session or website feature.

| Read in this order | Purpose |
| --- | --- |
| [Paper shelf](../papers/README.md) | One entrypoint per principal mathematical contribution with an authoritative primary source |
| [Canonical claim catalogue](catalogue/README.md) · [machine-readable claims](catalogue/CLAIMS.json) | Exact scope, status, source completeness, dependencies, and unresolved gates |
| [Proof dependency map](catalogue/DEPENDENCIES.md) | What the finite Lean theorem proves and what the analytic lifts still require |
| [Independent referee desk](referee/README.md) | Smallest load-bearing proof attacks, checkers, and report format |
| [Historical evidence and releases](archive/README.md) | Exact finite objects, adverse experiments, superseded work, and frozen source custody |
| [Original research tree](nightfall/README.md) | **Unmoved** primary manuscripts, scripts, proof passports, formal sources and research history |
| [NEW MOON legacy research tree](new-moon/spectral-observability/README.md) | Historical source location; folder name does not determine current claim status |
| [Reuse and rights](REUSE_AND_RIGHTS.md) | What is and is not licensed or authorized |

The [website's 40 curated records](nightfall/SITE_CURATED_40_20261030.json), 11 historical Proof Passports, and five internally designated finite/bounded findings remain separately maintained. They are **not** a claim of 40 peer-reviewed theorems. New living passports and selected canonical claims do not silently alter historical counts.

## Source-of-truth policy

- **One primary mathematics source:** a theorem manuscript or exact Lean declaration retains its original path, revision and math claims. The catalogue provides citations/metadata only. Use immutable commits when citing formal receipts or numerical witnesses.
- **Separate certification axes:** validity, public reproducibility, novelty, external mathematical review, significance and release authorization are recorded separately, never deduced from a green workflow.
- **Dependent claims:** a proposed lemma or analytic transfer cannot inherit kernel certification from its finite input theorem.
- **Corrections:** retain errata and original source identifiers. A source defect demotes affected conclusions and demands a clear reason and repair.
- **Publication:** original theorem and checker objects must be available and independently replayed before presenting a release as source-complete. Do not invent or re-upload master archives.
- **Attribution:** credit original published mathematicians, the research leader, implementers and reviewers according to actual participation.

## Reproducibility smoke test

From a fresh checkout, run `python3 scripts/check_research_archive.py`. This checks the **archive metadata and local references**, not mathematical truth. Follow each claim's primary source for its own Lean toolchain or exact checker; a separate reviewer should reproduce every advertised mathematical step.

[Main repository README](../README.md) · [Contributing and review](../CONTRIBUTING.md) · [Citation metadata](../CITATION.cff).
