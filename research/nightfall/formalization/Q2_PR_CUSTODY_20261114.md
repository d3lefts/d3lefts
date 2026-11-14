# NIGHTFALL Q2 pull-request custody and consolidation ledger — 2026-11-14

**Policy:** Do not erase an independent construction to make the PR queue green. A closed PR stays historically recoverable; closing is **not** merging, theorem certification, or source deletion. Author-directed research remains in draft unless the exact certificate and priority gates pass.

## Active source of truth

- [PR #479](https://github.com/d3lefts/d3lefts/pull/479): the **current source-only terminal Q2 integration candidate**. Finite product laws with a common finite alphabet, heterogeneous marginal weights and zero-mass atoms. Terminal theorem **NOT STRICT LEAN-CERTIFIED** as of this checkpoint.
- [Pinned CI](../../../.github/workflows/nightfall-q2-consolidated-lean.yml): one runner, import-DAG compilation, strict per-stage standard-axiom receipts. First three stages PASS on historical [run #43608651044](https://github.com/d3lefts/d3lefts/actions/runs/43608651044); stage four `ActualSourceOwnedFourthClosure.lean` failed on a specific Lean owner-rewrite type mismatch. The corrected source was committed to PR #479 as `16ab8c9268350769592a514a9f820339da543982`. **The correction must pass a newer current-head run before it counts.**
- [PR #483](https://github.com/d3lefts/d3lefts/pull/483): repo-CI governance, runner-budget, pin/documentation cleanup. It changes no mathematical sources.
- [PR #482](https://github.com/d3lefts/d3lefts/pull/482): merged CI infrastructure, not a theorem result.

## Historical proof paths — preserve until exact custody reconciliation

| PR | Main role | Custody state / decision |
| --- | --- | --- |
| [#477](https://github.com/d3lefts/d3lefts/pull/477) | Current-pin original-source Hilbert moment, Jensen, fourth & terminal candidates | **Administratively closed as superseded by #479.** All 18 changed Lean files compared by Git blob SHA: 17 identical to #479; the eighteenth is replaced by the explicitly repaired fourth-moment proof. Historical branch retained. |
| [#476](https://github.com/d3lefts/d3lefts/pull/476) | Earlier source/Hilbert moment integration | Historical stack predecessor. Keep until every unique source and receipt is compared against main and #479. |
| [#478](https://github.com/d3lefts/d3lefts/pull/478) | Original-source variance ownership | Distinct `ActualSourceQ2VarianceOwnership.lean` not in #479's changed-file set; **do not close indiscriminately**. |
| [#480](https://github.com/d3lefts/d3lefts/pull/480) | Actual-source proof-gate repairs, integrated energy | Distinct `ActualSourceIntegratedEnergy.lean` and hard-owner reduction note; review for incorporation. |
| [#481](https://github.com/d3lefts/d3lefts/pull/481) | Alternate genuine-source endpoint and energy integration | Distinct `ActualSourceQ2GenuineInterface.lean`; review against #479 before promotion. |
| [#474](https://github.com/d3lefts/d3lefts/pull/474) | Original-law influence/ANOVA bridge | Preserve its separate source, historical receipts and exact-current-pin versions. |
| [#424](https://github.com/d3lefts/d3lefts/pull/424), [#425](https://github.com/d3lefts/d3lefts/pull/425), [#426](https://github.com/d3lefts/d3lefts/pull/426), [#428](https://github.com/d3lefts/d3lefts/pull/428) | Historical source-specific moment, conditional-section and matching constructions | Legacy `ActualES*` source variants and exact checkers remain distinct from the current `ActualSource*` family. Archive by immutable commit rather than deleting. |
| [#430](https://github.com/d3lefts/d3lefts/pull/430), [#433](https://github.com/d3lefts/d3lefts/pull/433), [#434](https://github.com/d3lefts/d3lefts/pull/434), [#443](https://github.com/d3lefts/d3lefts/pull/443) | Greedy-source matching, Parseval, sampled-law bridge and owner-observation attempts | Some proof files, older pin/conditional interfaces and checker scripts remain unique; preserve their failure modes and mechanism transfers. |
| [#475](https://github.com/d3lefts/d3lefts/pull/475) | Tennessee Eastman mission-conditioned recertification testbed | Independent systems research; **exclude from Q2 consolidation**. |

## Mandatory gate before any further retirement

1. List every changed source file from the historical PR and compare its **blob SHA** with the canonical PR or merged `main`.
2. If a file is not byte-identical, document the proof mechanism and whether the canonical version supersedes it. Keep unique exact checkers, manuscripts, negative controls and certificates in recoverable history.
3. Label obsolete candidates as superseded with a pointer to the new PR and source hashes. Only then close the old PR; do not delete the branch during custody review.
4. Do not merge stale CI workflows into `main`; transfer needed source code separately.
5. A terminal Q2 theorem requires *one* current-head strict named-declaration Lean receipt (standard axioms only), plus separate originality and external-review gates. PR closure, finite numerical testing or a passing sublemma is not that receipt.

## Other repo debt kept explicit

- The repository currently has ~122 workflow files. Source-specific non-Q2 checks should retain their separate evidence contract; the dozens of old Q2 proof autostarts are now manual-only, and the canonical Q2 pipeline alone builds the overlapping import graph.
- CI token permissions for stale-run cancellation should be periodically reviewed for least privilege. Preserve all approval controls for publishing, releases and publication.
- There is no repository-wide `LICENSE`; public visibility does not license reuse. The copyright holder must choose the rights grant, if any. Do not invent one.
- Protection of `main`, required status checks and workflow permissions requires a verified GitHub ruleset. Documentation and CI lints do not replace branch protection.

This is a **dated custody snapshot**, not a claim that every historical branch has been byte-reconciled.
