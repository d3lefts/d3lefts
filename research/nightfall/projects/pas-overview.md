# Proof After Scarcity — current status and Version 2

**NIGHTFALL / PHASESHIFT · public research dossier updated 29 October 2026**

**Primary manuscript:** [Proof After Scarcity, Version 2 — Source-bound dependency models, exact finite sensitivity, and an unvalidated verification-priority hypothesis](pas/PAS_V2_20261029.md)

**Scope:** self-directed, AI-assisted research conducted with ChatGPT and Claude under the direction of Devin J. Wright. No independent human referee, world-first theorem, deployed search advantage, or validated predictive prioritization is claimed.

## What PAS now studies

PAS asks whether a verification system can represent claims with their exact source versions, independent evidence, typed proof dependencies, and uncertainty—and whether that structure *eventually* helps allocate limited verification effort better than simple heuristics.

The core distinction is between:

1. **Bibliographic citation / reuse graphs**, which may contain cycles and establish only textual references;
2. **A finite proof's actual logical dependency DAG**, which has a topological order if its steps are well founded;
3. **Source and verification history**, which records corrections, abstentions, and qualified checks without upgrading an uncertain edge into a certified dependency.

### Established mathematical part

For a strictly upper-triangular edge-weight matrix (B\) of an (n\)-node finite DAG, (B^n=0) and

[
(I-B)^{-1} = \sum_{k=0}^{n-1} B^k.
]

Version 2 proves the path-sum formula, the exact change in modeled exposure from increasing one forward-edge weight, and conditional entrywise interval bounds for nonnegative dependency weights. These are **elementary finite algebraic identities**, not a new mathematical discovery or a measured real-world error-rate estimate.

**Replay:** [integer-exact PAS v2 checker](../../../scripts/test_pas_v2.cjs), covering deterministic DAGs by independent direct-path enumeration and matrix path sums, forward-edge changes, and interval inequalities. The checker is a small implementation sanity check—not independent peer review.

### Empirical status

**Verification-priority advantage is not established.** The historical 13 October retrospective, outcome-aware exercise did not demonstrate superiority to simpler strategies. That experiment is **not part of the new manuscript's supporting evaluation**; its [original figures, controls, caveats and earlier dossier](pas/RETROSPECTIVE_20261013.md) remain preserved as historical audit evidence. Removing it from the main argument does not reverse the unfavorable outcome.

A credible empirical evaluation still requires publicly frozen primary inputs, prospectively collected outcomes, independent source-to-dependency annotation, blinded evaluation, and matched-budget baselines.

## Existing assets and historical limitations

- **October 6 source corpus:** 722 manuscripts, 597 **bibliographic** citation edges and 73 mutual-citation groups. Those numbers are not verified proof-dependency edges.
- **Reported October 27 synthetic checks:** the earlier dossier reported 216 DAG exposure and 802 edge-derivative comparisons. Its original checker/source files are not publicly available in this repository. These have not been independently rerun here; the new v2 checker is a distinct limited implementation.
- **Public 372-family metadata ranking:** [CSV, generator, SHA-256 and limitations](pas/README.md), derived from the OpenAI `math` release at commit `adc7f1241b42e322a6451854ab7e4b4c146bf78a`. SHA-256 of the public CSV: `3e303b69ef8e530b5c618e61f9cb5c4527ea717b0588c59f2fb75b4afd5924e7`. Original local October 6 freeze lacks an independently controlled contemporary timestamp.
- **Separate historical manuscript-graph H1:** scheduled decisive score 2027-04-06, but its primary freeze graph, preregistration and original manifest are not publicly available, and its historical timestamp is not externally validated. There is no claim of publicly checkable October 7 preregistration.

## Read, test, or review

- [PAS Version 2 manuscript](pas/PAS_V2_20261029.md) — definitions, finite propositions and proofs, source-admission rules, evaluation protocol, explicit limitations.
- [Version 2 exact checker](../../../scripts/test_pas_v2.cjs) — executable `node scripts/test_pas_v2.cjs`.
- [Public metadata freeze](pas/README.md) — CSV and regeneration code.
- [Historical retrospective audit](pas/RETROSPECTIVE_20261013.md) — the prior unfavorable evaluation, unchanged in meaning.
- [Original October 28 dossier at its pinned commit](https://github.com/d3lefts/d3lefts/blob/f8b73066db17a0ae0fd590fb2ec61accb5e38566/research/nightfall/projects/pas-overview.md) — full pre-revision text.

**Research status:** exact finite model and documented open problems, with the first major empirical advantage hypothesis unvalidated. This dossier supersedes the *editorial framing* of October 28; it does not alter past experimental measurements or the dated source record.
