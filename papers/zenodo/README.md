# NIGHTFALL publication infrastructure

Community: [NIGHTFALL — Independent Mathematical Research](https://zenodo.org/communities/nightfall-research/records)

First published manuscript: Wright, D. J. (2026). *Dimension-Free Classical Simulation Under Correlated Inputs: Wyner Common-Information Bounds and Query-Local Representations*. Zenodo. [doi:10.5281/zenodo.24511398](https://doi.org/10.5281/zenodo.24511398). Manuscript v0.7, Zenodo v1, 24 pages. Publication confirmed by the owner-provided record screenshot on November 24, 2026. Community inclusion and live public API metadata remain to be independently checked; publication is not journal peer review.

The [publication registry](../publications.json) is the machine-readable starting point. Keep the paper DOI distinct from any software or data DOI. Preserve published file bytes, never overwrite a version, and record source hashes only after fetching the actual archived bytes.

## Release procedure

1. Prepare a selected reproducibility package for one paper: exact approved manuscript/source, named Lean terminals and frozen dependencies, toolchain lock, replay instructions, verifier receipts, SHA-256 manifest, claim-level Proof Passport and upstream license notices. Mark unavailable files explicitly.
2. Audit the package for secrets, personal information, third-party rights, authorship, licenses, proof scope and exact source identity. Obtain explicit owner approval for the package and license; see [rights boundaries](../../research/REUSE_AND_RIGHTS.md).
3. If using GitHub automatic archiving, do not tag the full research repository before its entire release snapshot has been approved. Prefer a separately scoped release repository for rights-cleared code or a manually uploaded, selected ZIP. Zenodo archives the repository release snapshot, not just the selected assets.
4. The [metadata template](release-metadata.template.json) preserves the archive author/title and community identifier. Its placeholder license is deliberately invalid; only after rights approval replace it with the approved Zenodo license identifier and install the resulting file as `.zenodo.json` in the actual release repository. Zenodo prioritizes that file over CITATION.cff. Do not apply the preprint license to unrelated archive contents.
5. After approval, create the release or deposit, verify the new DOI and exact file manifest, and request/accept community inclusion as needed. Link the version-specific DOI in the website, registry, GitHub release and associated paper. No publication action is triggered by this documentation.
6. Corrections to archived files require a new version. Keep historical versions, evidence status and reviewer attribution visible.

Official documentation: [Zenodo GitHub metadata](https://help.zenodo.org/docs/github/describe-software/zenodo-json/), [record lifecycle](https://help.zenodo.org/docs/deposit/about-records/), [community roles](https://help.zenodo.org/docs/communities/about-communities/), [deposit API](https://developers.zenodo.org/).

The research site is the discovery catalogue, Zenodo is the archival DOI layer, and GitHub preserves the living proof sources and replay infrastructure. Journal and conference review is separate.
