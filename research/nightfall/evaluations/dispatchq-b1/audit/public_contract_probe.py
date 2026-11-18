#!/usr/bin/env python3
"""Independent public contract canary for DispatchQ-B1, NOT its withheld grader.

Tests are API-level and deterministic. Run only in a trusted local checkout;
importing agent-authored Python is not a sandbox. Do not run unknown patches
outside a disposable no-credentials isolation boundary.

Modes: --mode seed requires the original defective fixture's known fault vector;
--mode candidate requires all public cases to pass; --mode observe reports only.
This does not supply scores for the private 20-case benchmark.
"""
from __future__ import annotations

import argparse
import contextlib
import hashlib
import io
import json
import sys
import tempfile
from pathlib import Path

PROJECT = Path(__file__).resolve().parents[1]
CANDIDATE = PROJECT / "candidate"
sys.path.insert(0, str(CANDIDATE))
from dispatchq import WorkQueue  # noqa: E402


class Fixture:
    def __init__(self, directory: Path):
        self.now = 100.0
        self.db = directory / "work.sqlite"

    def clock(self):
        return self.now

    def queue(self, **kwargs):
        return WorkQueue(self.db, clock=self.clock, **kwargs)


def require(ok, message):
    if not ok:
        raise AssertionError(message)


def idempotent_submit(f):
    q = f.queue()
    require(q.submit("one", "v1", due_at=90) is True, "initial insertion")
    before = q.status("one")
    require(q.submit("one", "changed", due_at=1000) is False, "duplicate boolean")
    require(q.status("one") == before, "duplicate modified row")


def due_order(f):
    q = f.queue()
    q.submit("z", "early", due_at=10)
    q.submit("a", "late", due_at=20)
    require([x.job_id for x in q.claim("w", limit=2)] == ["z", "a"], "due order")


def expired_finish(f):
    q = f.queue(lease_seconds=3)
    q.submit("x", "data")
    token = q.claim("w")[0].token
    f.now = 104.0
    before = q.status("x")
    require(q.finish("x", token) is False, "expired finish accepted")
    require(q.status("x") == before, "expired finish mutated row")


def exhausted_expiry(f):
    q = f.queue(lease_seconds=3, max_attempts=1)
    q.submit("x", "data")
    q.claim("w")
    f.now = 104.0
    require(q.claim("other") == [], "exhausted expired job reclaimed")
    require(q.status("x")["state"] == "dead", "not dead-lettered")


def exhausted_fail(f):
    q = f.queue(max_attempts=1)
    q.submit("x", "data")
    token = q.claim("w")[0].token
    require(q.fail("x", token) is True, "current fail rejected")
    require(q.status("x")["state"] == "dead", "final attempt not dead-lettered")


def invalid_constructor(f):
    for value in (0, float("nan"), float("inf")):
        try:
            f.queue(lease_seconds=value)
        except (ValueError, TypeError):
            continue
        raise AssertionError("invalid lease_seconds accepted")


def invalid_worker(f):
    q = f.queue()
    q.submit("x", "data")
    try:
        q.claim("")
    except (ValueError, TypeError):
        return
    raise AssertionError("empty worker accepted")


def invalid_payload(f):
    q = f.queue()
    try:
        accepted = q.submit("x", {"not": "a string"})
    except Exception:
        accepted = False
    require(accepted is False, "non-string payload returned success")
    require(q.status("x") is None, "non-string payload persisted")


def nonfinite_due(f):
    q = f.queue()
    try:
        accepted = q.submit("x", "data", due_at=float("nan"))
    except Exception:
        accepted = False
    require(accepted is False, "nonfinite due_at returned success")
    require(q.status("x") is None, "nonfinite due_at persisted")


def expired_fail(f):
    q = f.queue(lease_seconds=3)
    q.submit("x", "data")
    token = q.claim("w")[0].token
    f.now = 104.0
    before = q.status("x")
    require(q.fail("x", token) is False, "expired fail accepted")
    require(q.status("x") == before, "expired fail mutated row")


def persistence(f):
    q = f.queue()
    q.submit("x", "payload")
    other = f.queue()
    require(other.status("x")["payload"] == "payload", "missing durable row")
    token = other.claim("remote")[0].token
    require(q.finish("x", token) is True, "cross-instance finish failed")
    require(other.status("x")["state"] == "done", "not durable")


def happy_path(f):
    q = f.queue()
    q.submit("x", "data", due_at=90)
    lease = q.claim("w")[0]
    require(lease.attempts == 1, "first claim attempts")
    require(q.finish("x", lease.token) is True, "valid finish rejected")
    require(q.status("x")["state"] == "done", "not done")


def stale_token(f):
    q = f.queue()
    q.submit("x", "data")
    a = q.claim("w")[0]
    require(q.fail("x", a.token) is True, "release failed")
    b = q.claim("w")[0]
    require(a.token != b.token, "token reuse")
    before = q.status("x")
    require(q.finish("x", a.token) is False, "stale token accepted")
    require(q.status("x") == before, "stale token mutated row")


# Seed expectations are specified before execution of this independently
# implemented probe on the repository's source-exact candidate.
CASES = [
    ("idempotent_submit", idempotent_submit, "FAIL"),
    ("due_order", due_order, "FAIL"),
    ("expired_finish", expired_finish, "FAIL"),
    ("exhausted_expiry", exhausted_expiry, "FAIL"),
    ("exhausted_fail", exhausted_fail, "FAIL"),
    ("invalid_constructor", invalid_constructor, "FAIL"),
    ("invalid_worker", invalid_worker, "FAIL"),
    ("invalid_payload", invalid_payload, "PASS"),
    ("nonfinite_due", nonfinite_due, "PASS"),
    ("expired_fail", expired_fail, "FAIL"),
    ("persistence", persistence, "PASS"),
    ("happy_path", happy_path, "PASS"),
    ("stale_token", stale_token, "PASS"),
]


def run_cases():
    results = []
    for name, test, expected in CASES:
        with tempfile.TemporaryDirectory() as directory:
            try:
                with contextlib.redirect_stdout(io.StringIO()):
                    test(Fixture(Path(directory)))
            except Exception as exc:
                result, failure = "FAIL", type(exc).__name__
            else:
                result, failure = "PASS", None
            results.append({
                "name": name,
                "result": result,
                "seed_expectation": expected,
                "failure_type": failure,
            })
    return results


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=("seed", "candidate", "observe"),
                        default="observe")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()

    results = run_cases()
    mismatches = [
        x["name"] for x in results
        if (args.mode == "seed" and x["result"] != x["seed_expectation"])
        or (args.mode == "candidate" and x["result"] != "PASS")
    ]
    report = {
        "schema": "nightfall.dispatchq.public-canary.v1",
        "mode": args.mode,
        "candidate_sha256": hashlib.sha256(
            (CANDIDATE / "dispatchq" / "queue.py").read_bytes()).hexdigest(),
        "total_public_checks": len(results),
        "passed": sum(x["result"] == "PASS" for x in results),
        "failed": sum(x["result"] == "FAIL" for x in results),
        "mismatches": mismatches,
        "cases": results,
        "scope": "public independent API canary; not withheld grader; not sandbox",
    }
    record = json.dumps(report, sort_keys=True, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(record, encoding="utf-8")
    print(record, end="")
    return int(bool(mismatches))


if __name__ == "__main__":
    raise SystemExit(main())
