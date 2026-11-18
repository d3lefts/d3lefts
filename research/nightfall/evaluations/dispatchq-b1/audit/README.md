# NIGHTFALL / DispatchQ-B1 independent public canary (v0.1)

**Status: internal cross-check; NOT a completed independent benchmark certification.**

This source is a separately implemented, deliberately *public* contract probe for the [DispatchQ-B1 candidate](../candidate/ISSUE.md), under evaluation in NIGHTFALL draft PR #818. It does **not** contain the withheld scorer, reference solution, holdout seeds, or an AI model result. The candidate task and its author-side benchmark remain provisional.

## Design contract

**Question:** Can a separate implementation of the written public API contract detect deliberate defects in the supplied seed without grading the solution against its own expected implementation?

**Representation:** One fake-clock SQLite file per case; API-observable state only; stable JSON receipt sorted by case name in source order. Assertions are semantic, not source-pattern matching.

**Predictions (before source-exact CI):** Ten failures on the known defective starter: idempotent submission, due-order, expired finish, exhausted lease, final retry, lease configuration validation, worker validation, payload validation, nonfinite due-time validation, and expired fail. Three positive controls: persistent cross-instance operations, normal claim/finish, and stale token rejected after successful release/reclaim. A corrected candidate should pass all thirteen, but thirteen tests cannot establish total correctness.

**Checker:** `python audit/public_contract_probe.py --mode seed` runs the exact known-defect profile and fails closed on a deviation; `--mode candidate` requires all cases to pass; `--mode observe` reports without a verdict. The report contains the SHA-256 of candidate `queue.py` and case outcomes. CI checks Python 3.10 and 3.13.

**Independent source limits:** The code was authored by a separate AI-assisted research instance after reading the task contract and candidate source, not by an independent human referee or under a blinded grading protocol. These tests do not prove security under arbitrary input, absence of race conditions, worker/process isolation, or a valid model-performance ranking.

**Security:** All scripts import candidate Python in-process. This is safe only for our trusted starter fixture. An untrusted AI-generated patch must execute in a disposable, no-credential OS/container sandbox with time, CPU, memory, process and network restrictions. Do not use this CLI to test adversarial patch code on a trusted host.

## Intended evidence chain

1. Pin the exact candidate source commit.
2. Record ten known negative-control failures and three positive-control passes as a deterministic finite witness.
3. Replay on two pinned Python versions and retain CI receipt artifacts.
4. Hand the candidate and test contract to an independent engineer for alternative-correct-solution review; do not disclose hidden tests.
5. Only after isolation, genuine agent tool-call validation, preregistered blind attempts and held-out scorer audit report task difficulty or benchmark model scores.

This canary supports **grader discrimination on public observed cases**, not blind benchmark validity. The fact that ten defective operations are caught is not a 10/13 model failure rate and not an accuracy score.

## Commands

From the project root (`research/nightfall/evaluations/dispatchq-b1/`):

```sh
python audit/public_contract_probe.py --mode seed --output /tmp/dispatchq-public-canary.json
# After an independently produced, trusted repair, NOT on arbitrary agent code:
python audit/public_contract_probe.py --mode candidate
```

**Attribution:** NIGHTFALL human-directed, AI-assisted contract review. The task's original implementation and its hidden grader are separately attributed in PR #818. Public canary source and CI should be inspected independently; no external review is represented.

## Source-exact CI result — 18 November 2026

**Internal reproduction PASS:** GitHub Actions [run 44348467883](https://github.com/d3lefts/d3lefts/actions/runs/44348467883), source-exact on **Python 3.10 and 3.13**. Both jobs independently reported `failed=10`, `passed=3`, `mismatches=[]` against the deliberately defective seed, with `candidate_sha256=05edf787fbd1cb3841ed4aa813361ee1024b354f6fcd7505a56eddf98cbfd406`. The output is a negative-control discrimination witness, **not** an evaluated agent patch, model score, full rubric validation, or external human check. The CI workflow retains JSON receipt artifacts for each Python version.

Open gates: independent alternate correct repair; source-exact author withheld grader inspection, attack-patch isolation, blind tool-using model runs, reviewer acceptance. No gate has been silently promoted.
