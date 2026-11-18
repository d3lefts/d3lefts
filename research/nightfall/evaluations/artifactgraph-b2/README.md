# ArtifactGraph-B2 — incremental build integrity benchmark

**NIGHTFALL SWE evaluation candidate, v0.1 (2026-11-18).**

A realistic Python stdlib repair task spanning manifest parsing, dependency
planning, content-addressed persistence and source boundary validation.
Broken starter source is in `candidate/`; the full agent-facing contract is in
[`candidate/ISSUE.md`](candidate/ISSUE.md). This tests a substantially different
engineering skill set than [DispatchQ-B1](../dispatchq-b1/README.md), which
emphasizes queue leases and cross-process concurrency.

## Quick start

```bash
cd research/nightfall/evaluations/artifactgraph-b2/candidate
python -m unittest discover -s tests -v
```

Three public smoke tests should pass on the starter, despite important hidden
failures. The task is to repair the implementation without changing the
public API, public tests, or system assumptions in the issue.

## What is actually measured

| Evidence | Scope | Status |
| --- | --- | --- |
| Public smoke | 3 smoke checks on defective starter | Passed locally |
| Author-side reference | 25 exact contract checks, 4 points each | 25/25, 100/100 |
| Defective starter | Same 25 contract checks | 15/25, 60/100 |
| Mutation calibration | 10 distinct one-fault mutations, each independently replayed | 10/10 detected |
| Independent alternate repair | Different implementation and reviewer | Not done |
| Blind coding agent | Fixed-budget, no-solution tasks across independent agents | Not done |
| External model ranking | Same scorer, budget and machine; intervals | Not established |

The scores refer only to **local author-side Python unit-test outcomes**.
They are not evidence that a specific AI model succeeded or failed; graders
and reference were developed together and are **not independently certified**.
The private author-side reference, mutation harness, scoring code and withheld
contract cases are intentionally not part of the public repository.

## Reproducibility and integrity

The [public evidence manifest](PUBLIC_EVIDENCE.json) records the calibration
hashes, basic measurement design, and explicit limitations. SHA-256 digests
identify the exact private reference and local checker. Repository CI runs
only public tests, so a green workflow means the candidate starter remains
usable—not that the entire benchmark or a coding agent has been certified.

The reference and hidden tests must **not** be made available to agents in blind
runs. Use an isolated no-credential filesystem with internet disabled and a
fixed execution budget. For fair comparison, freeze source commits, prompt,
Python version, grader, time/tool budgets and scoring policy before seeing
agent results; keep failed attempts in the denominator.

## Next gates

1. Independently implement a second correct solution against the published contract.
2. Conduct a blind scorer audit and improve mutation coverage beyond authored bugs.
3. Run two or more coding agents in isolated fresh checkouts with identical budgets.
4. Repeat for flakiness, report uncertainty and observed difficulty (not assumed difficulty).
5. Publish portfolio-grade results only after independent review and evidence verification.

**Not affiliated with, endorsed by, or submitted to Google, DeepMind, Polaris,
SWE-bench, or any external benchmark operator.**
