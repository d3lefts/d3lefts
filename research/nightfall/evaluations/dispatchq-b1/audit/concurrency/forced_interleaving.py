#!/usr/bin/env python3
"""Source-exact, two-PROCESS TOCTOU witness for DispatchQ-B1's known seed.

This is a structural seed exploit, NOT a portable benchmark grader, general
concurrency proof, sandbox, or blind AI-agent result. Run trusted seed ONLY.
A synchronous barrier forces both SQLite SELECTs to finish before updates.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import multiprocessing as mp
from pathlib import Path
import sqlite3
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
CANDIDATE = ROOT / "candidate"
PINNED_SEED_SHA256 = "05edf787fbd1cb3841ed4aa813361ee1024b354f6fcd7505a56eddf98cbfd406"


class BufferedCursor:
    """API-minimal cursor preserving the row snapshot taken before the barrier."""

    def __init__(self, rows):
        self.rows = rows

    def fetchall(self):
        return self.rows


def claim_worker(db: str, barrier, outbox, worker_id: int) -> None:
    """Fresh Python process with a local read-barrier adapter for the known seed."""
    try:
        sys.path.insert(0, str(CANDIDATE))
        from dispatchq.queue import WorkQueue

        class ForcedReadInterleaving(sqlite3.Connection):
            def execute(self, sql, parameters=()):
                cursor = super().execute(sql, parameters)
                if "SELECT * FROM jobs WHERE" in sql and "lease_until" in sql:
                    rows = cursor.fetchall()
                    if len(rows) != 1 or rows[0]["job_id"] != "race":
                        raise RuntimeError("source query shape or seed rows changed")
                    # Crucial: both independent processes read BEFORE either
                    # worker enters the separate UPDATE transaction.
                    barrier.wait(timeout=12)
                    return BufferedCursor(rows)
                return cursor

        q = WorkQueue(db, clock=lambda: 100.0)

        def intercepted_connection():
            conn = sqlite3.connect(db, timeout=10.0, factory=ForcedReadInterleaving)
            conn.row_factory = sqlite3.Row
            return conn

        q._connect = intercepted_connection
        leases = q.claim("worker-" + str(worker_id), limit=1)
        outbox.put({
            "worker": worker_id,
            "claims": [{
                "job_id": lease.job_id,
                "attempts": lease.attempts,
                "token": lease.token,
            } for lease in leases],
        })
    except BaseException as exc:
        outbox.put({
            "worker": worker_id,
            "error": type(exc).__name__,
            "message": str(exc)[:160],
        })


def demonstrate() -> dict:
    source = CANDIDATE / "dispatchq" / "queue.py"
    observed_sha = hashlib.sha256(source.read_bytes()).hexdigest()
    if observed_sha != PINNED_SEED_SHA256:
        return {
            "status": "wrong_source",
            "expected_candidate_sha256": PINNED_SEED_SHA256,
            "actual_candidate_sha256": observed_sha,
        }

    sys.path.insert(0, str(CANDIDATE))
    from dispatchq.queue import WorkQueue

    with tempfile.TemporaryDirectory(prefix="nf-dispatchq-race-") as tmp:
        db = str(Path(tmp) / "queue.sqlite")
        q = WorkQueue(db, clock=lambda: 100.0)
        if q.submit("race", "payload", due_at=0.0) is not True:
            return {"status": "seed_submission_failed", "actual_candidate_sha256": observed_sha}

        ctx = mp.get_context("spawn")
        barrier = ctx.Barrier(2)
        outbox = ctx.Queue()
        children = [
            ctx.Process(target=claim_worker, args=(db, barrier, outbox, worker))
            for worker in (1, 2)
        ]
        try:
            for child in children:
                child.start()
            for child in children:
                child.join(timeout=20)
            unfinished = [child.pid for child in children if child.is_alive()]
            for child in children:
                if child.is_alive():
                    child.terminate()
                    child.join(timeout=2)
            records = []
            for _ in range(2):
                try:
                    records.append(outbox.get(timeout=2))
                except Exception:
                    break
            records.sort(key=lambda x: x["worker"])
            stored = q.status("race")
        finally:
            for child in children:
                if child.is_alive():
                    child.terminate()
                    child.join(timeout=2)
            outbox.close()
            outbox.join_thread()
        leases = [claim for record in records for claim in record.get("claims", [])]
        duplicate = (
            not unfinished
            and len(records) == 2
            and all("error" not in record for record in records)
            and len(leases) == 2
            and all(lease["job_id"] == "race" and lease["attempts"] == 1 for lease in leases)
            and leases[0]["token"] != leases[1]["token"]
            and stored["state"] == "leased"
            and stored["token"] in {lease["token"] for lease in leases}
        )
        # Redact opaque tokens: their distinctness and the final token
        # relationship are the only properties relevant to this witness.
        public_records = [
            {
                "worker": rec["worker"],
                "claim_count": len(rec.get("claims", [])),
                "claimed_job_ids": [x["job_id"] for x in rec.get("claims", [])],
                "attempts": [x["attempts"] for x in rec.get("claims", [])],
                **({"error": rec["error"], "message": rec["message"]} if "error" in rec else {}),
            }
            for rec in records
        ]
        return {
            "schema": "nightfall.dispatchq.forced-interleaving.v1",
            "scope": "known trusted seed only; instrumented SELECT barrier; not a general concurrency grader",
            "candidate_sha256": observed_sha,
            "observed_two_process_double_claim": duplicate,
            "workers": public_records,
            "distinct_worker_tokens": len(leases) == 2 and leases[0]["token"] != leases[1]["token"],
            "stored_token_matches_one_worker": len(leases) == 2 and stored["token"] in {x["token"] for x in leases},
            "persisted_attempts": stored["attempts"],
            "unexpected_unfinished_processes": len(unfinished),
        }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", type=Path)
    args = ap.parse_args()
    result = demonstrate()
    document = json.dumps(result, sort_keys=True, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(document, encoding="utf-8")
    print(document, end="")
    return 0 if result.get("observed_two_process_double_claim") is True else 1


if __name__ == "__main__":
    raise SystemExit(main())
