# DispatchQ-B1: stateful public contract audit (v0.1)

**Status:** internally developed model-based checker, independent of the private benchmark grader and reference source. **Not** an independently human-reviewed benchmark or a blind model result.

## Objective and experimental contract

Test whether a candidate `dispatchq.WorkQueue` obeys the *public* `ISSUE.md` across chained operations, not merely isolated API calls. The checker contains a Python data-structure state machine, separately written from the SQL implementation; it uses **two distinct queue objects sharing one SQLite database** and a controllable clock.

- **Frozen test schedule:** 32 `random.Random(seed)` streams, seeds 0–31, 120 planned actions each (3,840 actions for fully passing candidates; defective trajectories stop at first divergence). Per action, check persisted row status of eight potential job IDs. Actions include submit/duplicate, multi-item claim, finish/fail using fresh or stale tokens, and clock advance. Inspect returned lease order, attempts, expiration, and token uniqueness.
- **Argument rejection:** 13 invalid input probes across constructor, claim limit and retry delay. Errors from `TypeError`, `ValueError` or `sqlite3.Error` all count as rejection: the issue does not demand a specific exception class. An invalid input that silently succeeds is a violation.
- **Seed calibration:** the pinned deliberately defective source `05edf787fbd1cb3841ed4aa813361ee1024b354f6fcd7505a56eddf98cbfd406` must produce exactly 32 first-divergence trajectories, 12 silently accepted invalid inputs, **zero unexpected execution errors**. Drift is a failing result, not a green regression.
- **Strict candidate mode:** all 32 trajectories and all rejection probes must succeed. Passing this is neither a complete proof of the contract nor a guarantee under concurrent process scheduling.

The exact `ISSUE.md` in the benchmark branch is the normative contract. A separately written 13-case public contract canary exists in draft [#820](https://github.com/d3lefts/d3lefts/pull/820); unlike that suite, this audit explores *multi-operation trajectories* and checks every persisted row after each transition. The shared frozen-run evidence mechanism in [#829](https://github.com/d3lefts/d3lefts/pull/829) handles future **real model-run receipts**, not this deterministic source audit.

## Reproduction (trusted source only)

From repository root, run:

```bash
python research/nightfall/evaluations/dispatchq-b1/audit/stateful/model_check.py \
  --candidate research/nightfall/evaluations/dispatchq-b1/candidate \
  --mode seed-calibration
```

For a **trusted** repaired candidate, replace the path and use `--mode strict`. Use `--output /path/to/receipt.json` to preserve the machine-readable result. Python standard library only. CI exercises the pinned defective seed on Python 3.10 and 3.13 and uploads the finite JSON calibration receipt. It does **not** expose private solutions, execute untrusted model patches, or certify process isolation.

## Current local observations (2026-11-18)

| Test / control | Defective seed | Separately implemented private repair |
|---|---:|---:|
| Deterministic trajectories matching public model (32 × 120) | 0/32 | 32/32 |
| Silently accepted invalid-input probes | 12/13 | 0/13 |
| Unexpected execution exceptions | 0 | 0 |
| Author's 20-case weighted private grader | not rerun in this audit | 100/100, ten consecutive runs |
| Separate 6-process claim stress (18 jobs/round) | not rerun in this audit | 5/5 rounds, 18 unique claims per round |
| Mutated private repair variants detected by checker | not applicable | 8/8 deliberately non-equivalent fault families |

The 8 fault families: duplicate payload overwrite, wrong claim ordering, lease expiry boundary, exhausted lease not marked dead, wrong retry delay, failure after final attempt incorrectly rescheduled, boolean-as-integer argument, and omission of the expired/exhausted sweep. They are **author-side perturbations**, not model-generated submissions, and their source remains private with the alternate repair.

The private alternate was written from the public issue **before** running the author-supplied hidden grader; the original author's reference code was not read. Its SHA-256 is `05430a9b7553e3fa8a1b9fa3c912c789de1ef4e790e30e639f7a95a6f83d16c2`. Because the patch and grader are withheld, these latter numerical claims are **provisional internal receipts**, not independently downloadable third-party verification.

## Checker, limitations and promotion gate

- **Model mechanism:** exact state transitions, deterministic fake-clock stepping, persistent snapshots and token-history checks.
- **Strength:** catches long-lived state drift and the eight tested fault families with a separate representation from the SQL queue.
- **Not checked:** every possible schedule, process races, lock timing, adversarial filesystem behavior, sandbox escape, semantic correctness of the withheld private grader, or model task difficulty. The public checker itself imports and executes trusted candidate source in the host process; never use it directly on hostile code.
- **Independent audit:** reviewer must inspect the oracle against the actual issue specification, test for overconstraint and missing reachable states, and replay an alternate repair in a credential-free environment.
- **Novelty:** no academic novelty, Polaris endorsement or SWE-bench comparison claimed. The contribution is an executable, reproducible **evaluation process** example.
- **Stop rule:** do not promote either benchmark to `validated` until an isolated blind model attempt with pinned budgets/denominators, source-exact private grading, non-gamed holdout, and independent reviewer sign-off.

The raw checker in this public branch is transparent; private correct repair and hidden tests must remain outside Git history until the holdout policy changes.
