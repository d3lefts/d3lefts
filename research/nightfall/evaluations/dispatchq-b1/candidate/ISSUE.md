# Issue: restore correctness of a durable SQLite work queue

The work queue powers a background document-processing service. Production reports describe duplicate jobs, overlapping claims by independent workers, stale acknowledgments, and retries that run after exhaustion. Repair `dispatchq/queue.py` **without changing its public API**. You may refactor the implementation and add tests. Use only the Python standard library, SQLite, and the existing schema names.

## Contract

- `WorkQueue(db_path, *, clock, lease_seconds=30.0, max_attempts=3)` opens an existing or new SQLite DB. Multiple queue objects/processes may use the same DB. The clock returns seconds; callers can inject a fake clock. Reject invalid `lease_seconds` (nonpositive, NaN, infinite) and invalid `max_attempts` (not a positive integer).
- `submit(job_id, payload, *, due_at=0.0) -> bool`: insert a ready job, returning True only on first creation. Repeating the same `job_id`, even with different payload or due date, returns False **without changing any existing fields**. The payload is an opaque string. Reject empty IDs, non-string payloads, and nonfinite due dates.
- `claim(worker, *, limit=1) -> list[Lease]`: atomically lease up to `limit` eligible jobs across all queue instances and processes. Eligible jobs are ready with `due_at <= now` or leased with `lease_until <= now`, except exhausted jobs. Return them ordered by `(due_at, created_at, job_id)`. `Lease` exposes `job_id`, `payload`, opaque unique `token`, 1-indexed `attempts`, and `lease_until = claim_time + lease_seconds`. Attempts increment **once per successful claim**, never on submission/ack/fail. Reject an empty worker or nonpositive/non-integer limit. Do not expose a job to two simultaneous claimers. On a claim call, an expired lease with `attempts >= max_attempts` becomes `dead` and cannot be claimed again.
- `finish(job_id, token) -> bool`: return True and set `done` only for the **current unexpired** lease matching that token. Clear token/lease fields on success. Stale, expired, unknown, and repeated finishes return False without changing job state.
- `fail(job_id, token, *, delay=0.0) -> bool`: accept only a current unexpired lease with the matching token. If attempts equal `max_attempts`, mark `dead`; otherwise release to `ready` with `due_at = now + delay`. Clear old token/lease data. Return False without mutation for stale/expired tokens. Reject negative or nonfinite delay. Repeated failures cannot reschedule a job.
- `status(job_id) -> dict | None`: return the persisted row fields `job_id`, `payload`, `due_at`, `state`, `attempts`, `token`, `lease_until`, or None if missing. Completion and dead-letter states are terminal.
- All operations must persist across separate Python objects. Concurrent claims should be correct under SQLite locking, not just under one in-process `threading.Lock`. Maintain SQLite-safe parameterized queries and bounded lock waits.

## Acceptance

Run `python -m unittest discover -s tests -v` from this directory. This public suite is only a smoke test; a separate evaluator checks the full written contract, including concurrent claims, lease expiry, retry exhaustion, and persistence. You will not receive the evaluator during a blind attempt. Avoid modifying any files outside this candidate repository. There are no external network calls or packages.
