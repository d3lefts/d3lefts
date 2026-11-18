# NIGHTFALL SWE evaluation portfolio — quality gate v0.1

**Status (2026-11-18): two author-calibrated tasks; zero validated frontier-agent benchmarks.** This is a portfolio of evaluation-engineering *constructions*, not a model leaderboard or an official benchmark submission. Do not promote one metric across task families: different rubrics measure different failure mechanisms.

| Task | Distinct mechanism | Public artifact | Evidence | Open gate |
| --- | --- | --- | --- | --- |
| **DispatchQ-B1** | Cross-process lease/fencing, durable queue retries, concurrent claim handling | [Public starter](https://github.com/d3lefts/d3lefts/pull/818) | Author-side 20-test/100-point calibration; independent public 13-case canary in [draft #820](https://github.com/d3lefts/d3lefts/pull/820) | Complete canary CI, blind agent runs, alternate correct repair |
| **ArtifactGraph-B2** | Incremental DAG, source digest identity, artifact integrity, source path confinement, atomic index replacement | [Public starter](https://github.com/d3lefts/d3lefts/pull/824) | Author-side 25 tests (100-point reference; 60-point starter); 10/10 one-fault mutations caught; three score-stable local repeats; Python 3.10/3.13 public CI | Independent alternative implementation, hidden-grader audit, blind agent runs |

The site engineering dossier in [PR #821](https://github.com/d3lefts/d3lefts/pull/821) is already merged; do not edit it to imply that the still-draft benchmark branches have been merged.

## Benchmark promotion protocol (shared across tasks)

1. **Reproducibility / provenance:** pin candidate source commit, complete task prompt, dependencies, Python runtime, evaluator source hash, sandbox image, evaluator settings and SHA-256 of each replay artifact. Successful CI for *public smoke* is not validation of the hidden grader.
2. **Construct validity:** preregister targeted SWE skills and non-goals; write a falsifiable contract with realistic developer affordances and multi-file integration. Require at least one independent knowledgeable reviewer to attack specification ambiguity, artificiality and underconstrained grading.
3. **Calibration:** reference solution scores fully and defective seed scores materially lower. Seed faults may not be encoded as whitelist/substring shortcuts in the grader. Capture failed calibrations. Add one independently authored correct repair as an anti-overfit gate.
4. **Mutation / adversarial audit:** track every test family, mutant source SHA, fault mechanism, expected detection and actual outcome. Author-built mutants establish sensitivity, **not completeness or independent certification**. The next audit must introduce independently designed faults after scorer freeze.
5. **Blind model comparison:** no solution, grader or private mutant exposure to candidates. Fix wall-time/token/tool/compute budgets, task source, initialization, network and filesystem permissions, and scorer *before* running models. Preserve all attempts including tool failures and timeouts.
6. **Correct scoring:** use source-exact clean checkout and independent test execution. Treat crashes as failures; report rubric subscores, attempts, variance, runtime and failure taxonomies. Do not claim difficulty or model rankings from one unpaired run.
7. **Publication:** show evidence tier on each card: _design_, _author-calibrated_, _independently audited_, _blind-model measured_, or _externally reviewed_. Promote only with matching evidence. Hide private reference and holdout material until a deliberate, explicitly approved release.

## Portfolio decision rule

Prefer **two validated, orthogonal tasks** over many unvalidated tasks. A third task should be started only when it adds a clearly new failure mechanism (for example API evolution or multi-service migrations) and does not displace the independent evaluation of the first two.

## Attribution and boundaries

NIGHTFALL's human lead coordinates task scope and source publication. ChatGPT and Claude may construct and audit work in separate processes; agent-to-agent agreement is not independent human review. Credit external projects and collaborators; use source-linked empirical claims. No Google/DeepMind/Polaris affiliation, endorsement, external benchmark score, or production-security certification is implied.
