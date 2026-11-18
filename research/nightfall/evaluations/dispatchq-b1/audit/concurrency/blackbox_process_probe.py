#!/usr/bin/env python3
"""Black-box, real-process concurrent claim probe for trusted DispatchQ candidates.

This probes only the public WorkQueue API, without monkeypatching the source
or synchronizing an internal SELECT. Natural OS scheduling is not exhaustive.
Survey mode must NEVER equate no observed race with a safe implementation.
Imports candidate Python code in worker processes: NOT an isolation sandbox.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import multiprocessing as mp
from pathlib import Path
import queue
import sys
import tempfile
from typing import Any

SEED_SHA256 = "05edf787fbd1cb3841ed4aa813361ee1024b354f6fcd7505a56eddf98cbfd406"
SCHEMA = "nightfall.dispatchq.blackbox-multiprocess.v1"


def _token_fingerprint(value: str | None) -> str | None:
    return hashlib.sha256(value.encode("utf-8")).hexdigest() if isinstance(value, str) else None


def worker_claim(candidate: str, database: str, worker_id: int, gate: Any, reports: Any) -> None:
    """Entire candidate import, queue creation, and claim live in an independent process."""
    try:
        sys.path.insert(0, candidate)
        from dispatchq.queue import WorkQueue

        q = WorkQueue(database, clock=lambda: 100.0)
        gate.wait(timeout=15.0)
        leases = q.claim(f"worker-{worker_id}", limit=1)
        reports.put({
            "worker": worker_id,
            "leases": [
                {
                    "job_id": x.job_id,
                    "attempts": x.attempts,
                    "token_hash": _token_fingerprint(x.token),
                    "lease_until": x.lease_until,
                }
                for x in leases
            ],
        })
    except BaseException as exc:
        reports.put({
            "worker": worker_id,
            "error": type(exc).__name__,
            "message": str(exc)[:160],
        })


def assess(results: list[dict], row: dict | None, workers: int) -> list[str]:
    """Semantic invariants for one single-job race; unit-testable without a queue."""
    failures: list[str] = []
    if len(results) != workers:
        failures.append("missing_worker_report")
    ids = [r.get("worker") for r in results]
    if len(set(ids)) != len(ids):
        failures.append("duplicate_worker_report")
    if any("error" in r for r in results):
        failures.append("worker_error")
    leases = [x for r in results for x in r.get("leases", [])]
    if any(len(r.get("leases", [])) > 1 for r in results):
        failures.append("worker_exceeded_limit")
    if len(leases) == 0:
        failures.append("eligible_job_unclaimed")
    if len(leases) > 1:
        failures.append("duplicate_lease_across_processes")
    if any(x.get("job_id") != "single" for x in leases):
        failures.append("wrong_job")
    if any(x.get("attempts") != 1 for x in leases):
        failures.append("invalid_attempt_count")
    fingerprints = [x.get("token_hash") for x in leases]
    if any(x is None for x in fingerprints) or len(set(fingerprints)) != len(fingerprints):
        failures.append("missing_or_reused_token")
    if any(x.get("lease_until") != 130.0 for x in leases):
        failures.append("invalid_lease_deadline")
    if row is None or row.get("state") != "leased":
        failures.append("not_persistently_leased")
    else:
        if row.get("attempts") != 1:
            failures.append("persisted_attempt_count")
        if row.get("payload") != "payload":
            failures.append("payload_modified")
        if _token_fingerprint(row.get("token")) not in fingerprints:
            failures.append("persisted_token_not_returned")
    return failures


def run_one(candidate: Path, workers: int) -> dict:
    from dispatchq.queue import WorkQueue

    with tempfile.TemporaryDirectory(prefix="nf-dq-blackbox-") as tmp:
        database = str(Path(tmp) / "queue.sqlite")
        q = WorkQueue(database, clock=lambda: 100.0)
        if q.submit("single", "payload", due_at=0.0) is not True:
            raise RuntimeError("setup failed: initial queue insert rejected")
        ctx = mp.get_context("spawn")
        gate = ctx.Barrier(workers)
        reports = ctx.Queue()
        processes = [
            ctx.Process(target=worker_claim, args=(str(candidate), database, worker_id, gate, reports))
            for worker_id in range(workers)
        ]
        try:
            for proc in processes:
                proc.start()
            for proc in processes:
                proc.join(timeout=25.0)
            stuck = [i for i, proc in enumerate(processes) if proc.is_alive()]
            if stuck:
                try:
                    gate.abort()
                except Exception:
                    pass
                for i in stuck:
                    processes[i].terminate()
                for proc in processes:
                    proc.join(timeout=3.0)
            results = []
            for _ in range(workers):
                try:
                    results.append(reports.get(timeout=1.0))
                except queue.Empty:
                    break
            results.sort(key=lambda r: r["worker"])
            row = q.status("single")
        finally:
            for proc in processes:
                if proc.is_alive():
                    proc.terminate()
                    proc.join(timeout=3.0)
            reports.close()
            reports.join_thread()
        issues = assess(results, row, workers)
        if stuck:
            issues.append("worker_timeout")
        return {
            "returned_claims": sum(len(r.get("leases", [])) for r in results),
            "returned_worker_reports": len(results),
            "violations": sorted(set(issues)),
            "persisted_attempts": row.get("attempts") if row else None,
            "worker_processes": workers,
        }


def self_test() -> None:
    token = _token_fingerprint("one")
    row = {"state": "leased", "attempts": 1, "payload": "payload", "token": "one"}
    good = [
        {"worker": 0, "leases": [{"job_id": "single", "attempts": 1,
                                  "token_hash": token, "lease_until": 130.0}]},
        {"worker": 1, "leases": []},
    ]
    assert assess(good, row, 2) == [], "valid single claim was rejected"
    doubled = [
        good[0],
        {"worker": 1, "leases": [{"job_id": "single", "attempts": 1,
                                  "token_hash": _token_fingerprint("two"), "lease_until": 130.0}]},
    ]
    assert "duplicate_lease_across_processes" in assess(doubled, row, 2)
    assert "persisted_attempt_count" in assess(good, {**row, "attempts": 2}, 2)
    assert "persisted_token_not_returned" in assess(good, {**row, "token": "lost"}, 2)
    assert "missing_worker_report" in assess(good[:1], row, 2)
    assert "worker_error" in assess([good[0], {"worker": 1, "error": "Oops"}], row, 2)
    print("PASS: six black-box receipt/oracle synthetic controls")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--candidate", type=Path)
    parser.add_argument("--mode", choices=("seed-survey", "strict"), default="seed-survey")
    parser.add_argument("--rounds", type=int, default=8)
    parser.add_argument("--workers", type=int, default=6)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return 0
    if args.candidate is None:
        parser.error("--candidate is required unless --self-test")
    if not 1 <= args.rounds <= 64 or not 2 <= args.workers <= 12:
        parser.error("allowed: 1..64 rounds and 2..12 workers")
    candidate = args.candidate.resolve()
    path = candidate / "dispatchq" / "queue.py"
    if not path.is_file():
        parser.error("candidate must have dispatchq/queue.py")
    candidate_sha = hashlib.sha256(path.read_bytes()).hexdigest()
    if args.mode == "seed-survey" and candidate_sha != SEED_SHA256:
        parser.error("seed-survey requires exact pinned intentionally defective source")

    # Import only trusted candidate code; no sandbox exists here.
    sys.path.insert(0, str(candidate))
    from dispatchq.queue import WorkQueue  # noqa: F401

    observed = [run_one(candidate, args.workers) for _ in range(args.rounds)]
    observed_bad = sum(bool(r["violations"]) for r in observed)
    duplicate_rounds = sum("duplicate_lease_across_processes" in r["violations"] for r in observed)
    operational_errors = sum(any(t in r["violations"] for t in
                                 ("worker_timeout", "missing_worker_report", "worker_error"))
                             for r in observed)
    report = {
        "schema": SCHEMA,
        "mode": args.mode,
        "candidate_sha256": candidate_sha,
        "rounds_planned": args.rounds,
        "rounds_completed": len(observed),
        "workers_per_round": args.workers,
        "rounds_with_contract_violations": observed_bad,
        "rounds_with_duplicate_claims": duplicate_rounds,
        "rounds_with_operational_errors": operational_errors,
        "trials": observed,
        "limits": [
            "No monkeypatching or SELECT interception; genuine OS subprocesses use public API",
            "Observing no race is not a proof of concurrency correctness",
            "Uses untrusted-code-unsafe in-process import; not an OS isolation boundary",
            "Finite scheduling sample, no model agent run, no hidden grader",
        ],
    }
    payload = json.dumps(report, sort_keys=True, indent=2) + "\n"
    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(payload, encoding="utf-8")
    print(payload, end="")
    if operational_errors:
        return 2
    if args.mode == "strict" and observed_bad:
        return 1
    # A seed with zero observed violations is NOT "safe": this is survey-only.
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
