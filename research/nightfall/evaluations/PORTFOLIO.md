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

## Matched interaction checks on public starters

Run `python3 research/nightfall/evaluations/paired_contract_calibration.py` from the repository root. The script runs trusted public fixtures and prints one JSON record per task, arm and repetition. A false check records a contract mismatch. An ordinary Python exception produces a failed record with an error message. Remaining histories run, and the process exits nonzero after the last record if any raised an exception. This diagnostic imports candidate code in process and is suitable only for trusted calibration.

The [Google Quantum AI experiment](https://research.google/blog/a-game-you-cannot-win-unless-you-have-a-quantum-computer/) motivates the comparison: structured tasks can expose systematic errors under a specified resource budget. Here both arms use the same number of public API calls per task and four checks on each history. The software experiment measures detection on selected histories. Its baseline has no theoretical success ceiling.

| Public starter | Baseline | Targeted change | Passing histories, baseline / targeted |
| --- | --- | --- | --- |
| DispatchQ-B1 | After expiry and reclaim, finish the current lease first. | Submit the old token first and verify that the new lease is unchanged and can still finish. | 3/3 / 3/3 |
| ArtifactGraph-B2 | Modify bytes and timestamp together, and separately rebuild unchanged inputs from a clean cache. | Change equal-length bytes at fixed timestamp, and separately change only the timestamp from a clean cache. | 3/3 / 0/3 |

Local three-repeat calibration against source revision `46b6712b0afdbea4e7c66d82533715a73794f177`. Every repeat starts with fresh state. B2 reused stale output after a byte edit. In a separate workspace it rebuilt unchanged bytes after a timestamp change while preserving the correct output digest. Both arms perform four build calls. All four queue checks passed in both orders. Each task contributes one implementation, so repeats measure reproducibility rather than independent repair samples. The script reports wall time for inspection. Fixed arm order and first-import cost preclude speed comparisons.

For a prospective test, freeze both suites before collecting additional patches. Have a separate reviewer classify valid alternatives and faulty repairs from the written contract without seeing arm outcomes. Compare paired detection counts and false rejections by implementation. Preserve every attempt, including crashes. Keep private cases outside the public tree. The [Docker calibration](assurance/trust-boundary/DOCKER_RESULTS.md) covers a synthetic protocol. Real model grading still requires external score computation and integration with the private task graders.
