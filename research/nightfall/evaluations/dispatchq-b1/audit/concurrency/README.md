# DispatchQ-B1 — deterministic two-process claim-race witness

**Status:** source-targeted adversarial test on a known defective starter. It is not an agent benchmark score, general concurrency proof, private grader, or external review.

## Pre-registered experimental contract

**Objective:** Show that the deliberately defective starter's `claim` violates the public task's cross-process atomic claim guarantee under a *feasible, deliberately selected* two-process interleaving that cannot be exercised by the sequential state-machine audit in [#833](https://github.com/d3lefts/d3lefts/pull/833).

**Preconditions:** Only run against candidate `dispatchq/queue.py` with SHA-256 `05edf787fbd1cb3841ed4aa813361ee1024b354f6fcd7505a56eddf98cbfd406`. Create one due job. Each of two fresh Python processes initializes its own `WorkQueue` backed by the same SQLite DB. Fake clock fixed at 100.0.

**Instrumented schedule:** Only in the pinned defective starter, a subclass of `sqlite3.Connection` intercepts the known eligible-row SELECT, buffers its one row, and synchronizes the two subprocesses via a shared barrier **after both SELECTs complete but before either UPDATE begins**. That schedule is consistent with the seed's explicit read-then-write program structure. It is a white-box adversarial schedule, not an unmodified black-box evaluation.

**Prediction before CI:** Both workers return a lease for the same `race` job, each says attempt 1 and has a distinct token; the persisted row contains the token of just one worker. The task contract says an eligible job must not be exposed to two simultaneous claimers. Fail closed on changed source, worker exception, timeout, missing second result or absent duplicate. Source and result are stored as a JSON receipt; no credential or network use is needed.

**Distinguishing alternatives:**
- Both leases refer to the same job: confirm atomicity violation in *the seed*.
- Exactly one lease, or a worker error: cannot use this execution as a positive concurrency counterexample; investigate scheduling and source instrumentation.
- Stalled barrier: source query changed / the tested interleaving was not constructed; fail rather than claim successful defense.
- A genuinely corrected implementation could pass without duplicates, but this harness is intentionally source-pinned and **must not be applied to arbitrary agent patches or used to grade them**.

**Reproduction:**

```sh
python research/nightfall/evaluations/dispatchq-b1/audit/concurrency/forced_interleaving.py \
  --output /tmp/dispatchq-interleaving.json
```

Path-scoped CI uses Python 3.10 and 3.13 and uploads independent receipts. Source SHA guard prevents the test being quietly repurposed to a changed candidate.

## Why separate from the 3,840-step state machine?

The model-based checker #833 performs thousands of **sequential** operations across two queue objects; it never makes their `claim` methods overlap. Thus passing 3,840 operations cannot establish the cross-process atomicity specified by ISSUE.md. This witness actively constructs the omitted schedule. One execution under a feasible interleaving is a valid *counterexample to seed atomicity*, not evidence that other implementations are sound under all interleavings.

**Future acceptance gate:** A repaired candidate should be challenged by an independently implemented, *black-box* multi-process stress experiment in an OS-isolated, credential-free environment, using controlled starts, repeated seeds and a recorded denominator. Those runs complement, but cannot replace, deterministic state-model checking or a formal linearizability proof.

**Attribution:** Human-directed AI-generated adversarial schedule and code; internally reproduced if CI passes. No independent human referee. The reference implementation and withheld grader were neither accessed nor published.

## Source-exact result (2026-11-18)

[GitHub Actions run 44380919138](https://github.com/d3lefts/d3lefts/actions/runs/44380919138) **PASS** on both Python **3.10 and 3.13**. Each spawned two distinct OS processes against the pinned defective starter. Each process returned exactly one lease for job `race`, each claimed attempt 1, with distinct opaque tokens. The persisted DB row had attempts 1 and contained precisely one worker's token. No unexpected unfinished processes. Each CI job preserved a JSON receipt artifact, including exact candidate SHA-256.

**Formal violation witness:** There exists a feasible overlapping two-process execution on the known starter in which two workers simultaneously obtain lease objects for the same job, contradicting ISSUE.md's atomic-claim requirement. This refutes the starter's concurrent safety. It **does not** refute the state-machine oracle's sequential observations, which are for a different experimental regime.

**Certification:** Reproduced internal deterministic counterexample, not formal schedule enumeration, repaired-candidate conformance, human review or a blind agent model result. This is the most limited supported claim. We do not claim process race frequency or likelihood under naturally scheduled starts.
