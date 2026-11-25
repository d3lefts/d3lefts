# NIGHTFALL publication infrastructure

Community: [NIGHTFALL — Independent Mathematical Research](https://zenodo.org/communities/nightfall-research/records)

First published manuscript: Wright, D. J. (2026). *Dimension-Free Classical Simulation Under Correlated Inputs: Wyner Common-Information Bounds and Query-Local Representations*. Zenodo. [doi:10.5281/zenodo.24511398](https://doi.org/10.5281/zenodo.24511398). Manuscript v0.7, Zenodo v1, 24 pages. Publication confirmed by the owner-provided record screenshot on November 24, 2026. Community inclusion and live public API metadata remain to be independently checked; publication is not journal peer review.

The [publication registry](../publications.json) is the machine-readable starting point. Keep the paper DOI distinct from any software or data DOI. Preserve published file bytes, never overwrite a version, and record source hashes only after fetching the actual archived bytes.

## Mandatory manuscript format — owner directive, 24 November 2026

Every new manuscript intended for Zenodo must follow the established mathematical-preprint house style. Read this section **before drafting or reformatting**, including in fresh ChatGPT/Work sessions and all NIGHTFALL research roles. Internal drafts may use other layouts; publication PDFs may not unless the owner explicitly approves an exception.

**Visual references:** the published Wyner common-information paper ([DOI](https://doi.org/10.5281/zenodo.24511398)), the quadratic-influence paper, and the owner-approved corrected publication layout of *Exact Adaptive Phase Retrieval over Finite Fields: Rank–Phase Decomposition and Optimal Query Packing* (24 November 2026). The last is a layout reference, not an assertion of deposit or a new publication record. Use the actual reference PDF or its approved source when available; do not infer that a generic journal template is a match.

### Author and first page

- The author block is exactly the name **Devin J. Wright** and the affiliation **Independent researcher**, on separate centered lines (author rendered in uppercase by AMS typography; affiliation in normal mixed case). No NIGHTFALL affiliation, subtitle, research-program label, version number, draft badge, or release status in the byline. Version information belongs in archive metadata and source custody, not the title/author block.
- Center the uppercase title in balanced lines, followed by the author/affiliation and an inset abstract with a bold “Abstract.” label. Use a displayed principal equation when this improves readability without changing the claim.
- Use a continuous, balanced first page, not a separate cover sheet. Follow the Wyner and corrected finite-field layout: title, author, abstract, AI disclosure, date, 2020 Mathematics Subject Classification, and keywords. A genuinely long abstract may move the disclosure to page two, as in the quadratic-influence paper; do not force this break merely because it is convenient. Avoid large unexplained blank blocks, crowding, artificial filler, or shrinking the type to force content onto one page.
- AI disclosure must accurately describe assistance and the exact scope of formal verification; do not attribute unarchived or unperformed checks to a reviewer. Preserve acknowledgements and responsibility for correctness. Put contents and acknowledgements on subsequent pages where appropriate.

### Reusable LaTeX baseline

The corrected finite-field publication used the following baseline; retain it as the default unless the reference manuscript requires a documented adjustment for readability.

~~~latex
\documentclass[11pt]{amsart}
\usepackage[T1]{fontenc}
\usepackage{lmodern,amsmath,amssymb,amsthm,booktabs,microtype}
\usepackage[letterpaper,inner=0.94in,outer=1.41in,top=0.75in,
  bottom=1.1in,headheight=8pt,headsep=14pt,footskip=18pt]{geometry}
\usepackage[colorlinks=true,linkcolor=black,citecolor=blue,urlcolor=blue]{hyperref}
\usepackage{etoolbox}
\makeatletter
\patchcmd{\@setauthors}{\MakeUppercase{\authors}}%
  {\MakeUppercase{\authors}\par\normalfont\small Independent researcher}%
  {}{\PackageError{publication}{Author formatting patch failed}{}}
\makeatother
\setlength{\emergencystretch}{2em}
% Use a short running title and balance long title lines deliberately.
\title[Short running title]{Full paper title}
\author{Devin J. Wright}
\date{Month YYYY}
% Supply paper-specific \subjclass[2020]{...} and \keywords{...}.
~~~

Use AMS theorem/proof typography, numbered sections and equations, alternating author/short-title running heads, centered page numbers, restrained academic tables, and conventional references. No branded cover, decorative colors, promotional panels, or interface-style layout. The author patch deliberately fails closed if the expected AMS macro changes; inspect the compiled byline rather than silently falling back.

### Required layout preflight

1. Compile from the actual LaTeX source (repeat until references and contents settle). Render page one and compare visually with the established papers at the same scale. Check title balance, author block, text measure, abstract and disclosure placement, and whitespace; do not assume that matching the preamble guarantees matching layout.
2. Render and inspect **every** page, including mathematical displays, tables, running heads, contents and bibliography. Repair awkward pagination, overflow, clipping, blank pages and unresolved references. Where layout requires a change to a mathematical statement, stop and obtain a mathematical review rather than making a silent edit.
3. Confirm no version or research-program affiliation in the author block; confirm the source and PDF contain the intended scientific content and accurate disclosure. Rebuild the final supplement manifest and check that the standalone PDF and packaged PDF are byte-identical.
4. Record the final layout check and the source/PDF hashes in the release package. This is a formatting gate, not a mathematical certification, originality claim or permission to publish. Preserve the owner-approval and rights gates below.

## Release procedure

1. Complete the mandatory manuscript-format preflight above. Prepare a selected reproducibility package for one paper: exact approved manuscript/source, named Lean terminals and frozen dependencies, toolchain lock, replay instructions, verifier receipts, SHA-256 manifest, claim-level Proof Passport and upstream license notices. Mark unavailable files explicitly.
2. Audit the package for secrets, personal information, third-party rights, authorship, licenses, proof scope and exact source identity. Obtain explicit owner approval for the package and license; see [rights boundaries](../../research/REUSE_AND_RIGHTS.md).
3. If using GitHub automatic archiving, do not tag the full research repository before its entire release snapshot has been approved. Prefer a separately scoped release repository for rights-cleared code or a manually uploaded, selected ZIP. Zenodo archives the repository release snapshot, not just the selected assets.
4. The [metadata template](release-metadata.template.json) preserves the archive author/title and community identifier. Its placeholder license is deliberately invalid; only after rights approval replace it with the approved Zenodo license identifier and install the resulting file as `.zenodo.json` in the actual release repository. Zenodo prioritizes that file over CITATION.cff. Do not apply the preprint license to unrelated archive contents.
5. After approval, create the release or deposit, verify the new DOI and exact file manifest, and request/accept community inclusion as needed. Link the version-specific DOI in the website, registry, GitHub release and associated paper. No publication action is triggered by this documentation.
6. Corrections to archived files require a new version. Keep historical versions, evidence status and reviewer attribution visible.

Official documentation: [Zenodo GitHub metadata](https://help.zenodo.org/docs/github/describe-software/zenodo-json/), [record lifecycle](https://help.zenodo.org/docs/deposit/about-records/), [community roles](https://help.zenodo.org/docs/communities/about-communities/), [deposit API](https://developers.zenodo.org/).

The research site is the discovery catalogue, Zenodo is the archival DOI layer, and GitHub preserves the living proof sources and replay infrastructure. Journal and conference review is separate.
