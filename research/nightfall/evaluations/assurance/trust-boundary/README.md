# NIGHTFALL evaluator trust-boundary proof attack

**Status:** Public synthetic exploit regression · not an agent benchmark result.

A controlled false-credit witness exposed an integrity defect in the private DispatchQ-B1 v0.3 scorer. The intentionally defective queue's `queue.py` bytes were unchanged, but a modified package initializer contaminated Python's in-process `unittest.TextTestRunner`. The old scorer returned **100/100** despite the defective queue's normal score of 58–66. Because the old receipt hashes only `queue.py`, both source trees were assigned the same candidate digest. All effects were on owned, synthetic/local fixtures; no agent submissions or third-party systems were affected.

The private v0.4 scorer changes the **trust boundary**, not merely its assertions: the trusted test runner does not import the candidate; operations are delegated to a separate candidate-side RPC process. The same initializer mutation no longer changes the grader process. Its result was **58/100**, versus the correct reference's **100/100**, in source-exact local replay. The receipt now includes the **entire candidate source tree** and all scorer/transport code. These results establish resistance to the specific in-process monkeypatch, not to arbitrary malicious candidate code or benchmark contamination.

This directory contains a *toy* reproducer with no hidden tests, private reference, or model traces:

```sh
python research/nightfall/evaluations/assurance/trust-boundary/verify_boundary.py
```

The four checks exercise a deliberately defective toy implementation with an initializer mutation, ordinary failing code, full-tree hashing, and symlink rejection. The direct-import toy grader falsely awards 100; the out-of-process variant scores 0. Both run without external dependencies. CI replays on Python 3.10 and 3.13.

## Trust boundaries and remaining blockers

1. A process boundary prevents directly mutating Python objects in the grader process, **but it does not isolate the candidate's filesystem or network**. The worker in the internal v0.4 prototype can still read local paths; it must not be used with arbitrary agent-authored code until a disposable, no-network, no-credential sandbox prohibits access to holdouts and private keys.
2. Worker-reported results are still untrusted data. The grader must check outcomes in its own process and reject invalid JSON, protocol mismatches, timeouts, source-tree drift, skipped tests and inconsistent scores.
3. Stable grading must be demonstrated on alternate correct repairs and adversarial fixtures, across pinned runtimes. Local proof-of-concept results are **not external human certification**.
4. Actual agent execution needs the separately pinned run-plan/scoring denominators from #829/#830 and raw tool traces. **No blind agent scores are claimed here.**

## Coordination

- Source task #818; private grader audits #838/#842; independent model-based DispatchQ contract audit #833; separate ArtifactGraph-B2 #824.
- Future evaluator code should follow this separation before any blind-agent benchmark promotion.
- This is an original NIGHTFALL harness audit, **not** an official Polaris, Google DeepMind or SWE-bench evaluation.