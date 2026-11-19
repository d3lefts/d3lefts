# DispatchQ-B1 — durable work-queue repair benchmark

**NIGHTFALL SWE evaluation prototype · v0.1 · 2026-11-18**

A deliberately defective, realistic Python/SQLite service and a written issue for testing coding agents' ability to preserve concurrency and lifecycle invariants while repairing a durable work queue. Part of NIGHTFALL's effort to build high-signal, reproducible long-horizon software-engineering evaluations.

> **Calibration only.** Not affiliated with or endorsed by Google, Google DeepMind, Polaris, or SWE-bench. No blind frontier-agent run, external reviewer, or validated model-ranking claim exists yet. Do not represent these author-side checks as an independent assessment of model capability.

## Give an agent the challenge

The *only* agent-facing directory is [`candidate/`](candidate/). It contains the specification, defective implementation, and three intentionally limited public smoke tests. Its implementation is expected to be repaired, not to pass a hidden benchmark as-is.

```sh
cd research/nightfall/evaluations/dispatchq-b1/candidate
python -m unittest discover -s tests -v
```

The task covers duplicate/idempotent submission, deterministic due-time ordering, cross-process atomic claims, unique lease tokens, expiration and stale-worker fencing, bounded retries, dead-letter termination, durable persistence, validation, and lock contention. See [`candidate/ISSUE.md`](candidate/ISSUE.md) for the complete agent-visible contract. Standard-library Python 3.10+; no network or third-party packages.

## Calibrated author-side evidence

The **withheld** evaluator contains 20 weighted contract tests totaling 100 points. The author-built reference passed 20/20 (100/100) in 10 consecutive local runs. The intentionally defective starter scored **52–60/100** across 10 runs because a race-sensitive concurrency test fluctuated. Eight distinct fault-injected reference variants were detected in the original mutation audit. An additional non-scored six-process claim probe passed 5/5 trials for the reference and 4/5 for the starter. These are *author-side* observations, not independent certification. See [`PUBLIC_EVIDENCE.json`](PUBLIC_EVIDENCE.json) for provenance and precise qualifications.

The reference, hidden tests, score runner, and exact per-test mutation receipts are deliberately **not** committed. Public disclosure would contaminate the intended blind evaluations. Local scorer executes imported candidate code and is *not* a security sandbox; real agent patches must be replayed in an isolated disposable environment without credentials and with resource limits.

## Promotion / next experiment

1. Freeze this candidate commit and a separate, immutable evaluator version/hash.
2. Have independent coding agents solve **fresh copies** of the candidate under fixed, preregistered tool, compute, and time budgets; do not provide them evaluator or reference source.
3. Score completed patches in isolated evaluation environments, retain raw transcripts, file diffs, and per-test receipts, and repeat at least three independent attempts per model.
4. Have an engineer who did not write the reference inspect the issue and grader, then test an independently produced correct alternate implementation and adversarial grader-targeting patches.
5. Publish meaningful comparisons only after reproducible blind runs and reviewer acceptance. A disagreement or unstable oracle blocks promotion; a 100/100 reference alone is insufficient.

**Website summary:** “NIGHTFALL builds executable evaluations of coding-agent reliability. DispatchQ-B1 probes durable state, concurrency and retry correctness; its reference passes 20 weighted contract tests and eight seeded defects are detected. Independent agent calibration is pending.”

**Authorship:** NIGHTFALL author-side ChatGPT implementation and local checks; no Claude, Google, or external-review contribution is represented here.
