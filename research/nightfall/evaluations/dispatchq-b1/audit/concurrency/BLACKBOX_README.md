# DispatchQ-B1: black-box cross-process safety probe (v0.1)

**Scope:** finite, API-only, truly concurrent OS-process stress on the public work queue contract. Not a trusted execution sandbox, a complete concurrency proof, a hidden grader, a blind coding-agent run, or a benchmark model score.

## Why this exists

The existing [source-pinned forced-interleaving witness (#836)](https://github.com/d3lefts/d3lefts/pull/836) establishes an actual two-process TOCTOU counterexample in the intentionally defective seed, but deliberately intercepts its internal SQLite `SELECT`. The [separate 32×120 step state-model oracle (#833)](https://github.com/d3lefts/d3lefts/pull/833) covers many chained transitions, but is sequential.

**New operator:** exercise the unmodified **public API** from genuinely independent Python processes that simultaneously enter `claim`. The checker does not modify `WorkQueue`, install a SQLite adapter or inspect private implementation details. Each round initializes a new SQLite database with exactly one eligible job. Worker processes synchronize at a barrier immediately *before* calling the public API. A separate parent process aggregates their returned leases and persisted final database state.

## Experimental contract (recorded before CI)

- **Test input:** six fresh Python processes and one due job, eight independent trial rounds, a single fake time of 100.0 and a fixed 30-second default lease. Every worker may claim at most one job; all workers share only an on-disk SQLite path and the test-start barrier.
- **Negative-control candidate:** the exact deliberately defective seed `dispatchq/queue.py` SHA-256 `05edf787fbd1cb3841ed4aa813361ee1024b354f6fcd7505a56eddf98cbfd406`. Its defect is independently proven by the source-targeted #836 witness. **Prediction:** naturally scheduled subprocess claims may reproduce a duplicate; some schedules may not. We specifically do NOT assert a minimum observed race count.
- **Per-round semantic oracle:** on one job, there must be exactly one returned lease among all six processes, with valid job ID, attempt 1, an unexpired 130.0 deadline, distinct nonempty token, and a persisted `leased` row retaining the same token and attempts 1. Duplicate leases, worker timeouts, error reports, missing workers, incorrect persisted state or absent claims are classified separately.
- **Independent checker controls:** six synthetic assertion paths (correct single claim; duplicate claim; persisted attempt drift; wrong persisted token; missing worker; worker error) must all behave as expected *before* running candidate code.
- **Evidence modes:** `seed-survey` requires the exact defective source hash and records **all** observed violations without demanding a race; `strict` returns failure on any detected contract violation (for a trusted corrected candidate only). Both fail on operational setup errors. Neither establishes the absence of all races.
- **Trust boundary:** the runner imports candidate code with process privileges. It is **not suitable for untrusted AI-generated patches** unless surrounded by a separately verified no-credential Docker/OS sandbox. Source-hashing is provenance, not containment.
- **Stop rule:** no repaired candidate is declared correct based solely on this finite stress. Require a separate alternative correct solution, held-out grader verification, independent linearizability reasoning, and replay across multiple process scheduling environments before confidence increases.

## Replay

From repository root:

```sh
python research/nightfall/evaluations/dispatchq-b1/audit/concurrency/blackbox_process_probe.py --self-test
python research/nightfall/evaluations/dispatchq-b1/audit/concurrency/blackbox_process_probe.py \
  --candidate research/nightfall/evaluations/dispatchq-b1/candidate \
  --mode seed-survey --rounds 8 --workers 6 --output /tmp/dispatchq-process-survey.json

# Only on a separately trusted candidate; this is NOT a security sandbox.
python research/nightfall/evaluations/dispatchq-b1/audit/concurrency/blackbox_process_probe.py \
  --candidate /path/to/trusted-repaired/candidate \
  --mode strict --rounds 8 --workers 6
```

Path-scoped GitHub Actions runs on Python 3.10 and 3.13, retains the source SHA-256 and each individual round result in an uploaded JSON receipt. Because scheduling may vary, the published measurements must be reported as observed *counts and trial denominators*, never a general probability or an agent score.

**Authorship:** NIGHTFALL AI-assisted engineering, internally derived separately from task author; no human-independent code audit or tool-agent experiment is claimed. Private grader and reference are neither accessed nor published.

## Exact-source CI result — 18 November 2026

[GitHub Actions run 44384068910](https://github.com/d3lefts/d3lefts/actions/runs/44384068910) completed the public black-box probe on Python **3.10 and 3.13**, using the same pinned defective source SHA-256 `05edf787fbd1cb3841ed4aa813361ee1024b354f6fcd7505a56eddf98cbfd406`. Both platforms passed the six synthetic semantic controls and reported:

| Observation | Python 3.10 | Python 3.13 |
|---|---:|---:|
| API-only OS-process rounds completed | 8/8 | 8/8 |
| Rounds with duplicate claims | **8/8** | **8/8** |
| Operational errors/timeouts | 0 | 0 |
| Workers per round | 6 | 6 |

The process probe uses only `WorkQueue.submit`, `WorkQueue.claim`, `WorkQueue.status`, and an ordinary *pre-call* barrier. It does not patch `sqlite3.Connection` or intercept an internal SELECT. Each CI matrix job uploaded all eight trial records. On this specific environment and concurrency configuration, duplicate leases were reproducibly observed; **8/8 is a finite observed count, not a general race probability**.

This strengthens the seed counterexample without certifying any correct repair or grading a real tool-agent attempt. For independent review, replay the same command on a differently provisioned worker and audit a separately implemented fixed queue in strict mode inside a no-credential environment. Even a strict all-pass finite replay cannot prove all possible concurrent schedules.
