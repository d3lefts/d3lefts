#!/usr/bin/env python3
"""DispatchQ-B1 public, independent deterministic state-machine contract checker.

This is not the benchmark's private grader and not an execution sandbox. Never run
untrusted agent-authored candidate code with production credentials or network.
"""
from __future__ import annotations

import argparse
from collections import Counter
from dataclasses import dataclass
from hashlib import sha256
import importlib
import json
from pathlib import Path
import random
import sqlite3
import sys
import tempfile
from typing import Any

SEED_SHA256 = "05edf787fbd1cb3841ed4aa813361ee1024b354f6fcd7505a56eddf98cbfd406"


@dataclass
class Row:
    job_id: str
    payload: str
    due_at: float
    created_at: float
    state: str = "ready"
    attempts: int = 0
    token: str | None = None
    lease_until: float | None = None

    def public(self) -> dict[str, Any]:
        return {name: getattr(self, name) for name in
                ("job_id", "payload", "due_at", "state", "attempts", "token", "lease_until")}


class Oracle:
    """Minimal, non-SQL state machine transcribed from public issue semantics."""

    def __init__(self, *, lease_seconds: float = 5.0, max_attempts: int = 3):
        self.rows: dict[str, Row] = {}
        self.lease_seconds = lease_seconds
        self.max_attempts = max_attempts

    def submit(self, job_id: str, payload: str, due_at: float, now: float) -> bool:
        if job_id in self.rows:
            return False
        self.rows[job_id] = Row(job_id, payload, due_at, now)
        return True

    def claim(self, limit: int, now: float) -> list[Row]:
        for row in self.rows.values():
            if row.state == "leased" and row.lease_until <= now and row.attempts >= self.max_attempts:
                row.state, row.token, row.lease_until = "dead", None, None
        eligible = [r for r in self.rows.values() if r.attempts < self.max_attempts
                    and ((r.state == "ready" and r.due_at <= now)
                         or (r.state == "leased" and r.lease_until <= now))]
        eligible.sort(key=lambda r: (r.due_at, r.created_at, r.job_id))
        chosen = eligible[:limit]
        for row in chosen:
            row.state = "leased"
            row.attempts += 1
            row.token = None  # Filled with candidate's fresh opaque token after comparing.
            row.lease_until = now + self.lease_seconds
        return chosen

    def finish(self, job_id: str, token: str, now: float) -> bool:
        row = self.rows.get(job_id)
        if row is None or row.state != "leased" or row.token != token or row.lease_until <= now:
            return False
        row.state, row.token, row.lease_until = "done", None, None
        return True

    def fail(self, job_id: str, token: str, delay: float, now: float) -> bool:
        row = self.rows.get(job_id)
        if row is None or row.state != "leased" or row.token != token or row.lease_until <= now:
            return False
        if row.attempts >= self.max_attempts:
            row.state = "dead"
        else:
            row.state, row.due_at = "ready", now + delay
        row.token, row.lease_until = None, None
        return True


class Divergence(Exception):
    pass


def expect(actual: Any, expected: Any, label: str) -> None:
    if actual != expected:
        raise Divergence(f"{label}: expected={expected!r}, observed={actual!r}")


def run_trajectory(queue_cls: type, seed: int, steps: int) -> tuple[int, dict[str, int]]:
    rng = random.Random(seed)
    nops: Counter = Counter()
    with tempfile.TemporaryDirectory(prefix="dispatchq-model-") as tmp:
        clock = [100.0]
        db = Path(tmp) / "job.sqlite"
        clients = [queue_cls(db, clock=lambda: clock[0], lease_seconds=5.0, max_attempts=3)
                   for _ in range(2)]
        model = Oracle()
        tokens: list[tuple[str, str]] = []
        known_tokens: set[str] = set()
        job_ids = [f"job{j}" for j in range(8)]
        def snapshot(step: int) -> None:
            for job in job_ids:
                actual = clients[step % 2].status(job)
                expected = model.rows[job].public() if job in model.rows else None
                expect(actual, expected, f"step={step} status({job})")

        for step in range(steps):
            x = rng.random()
            client = clients[rng.randrange(2)]
            now = clock[0]
            if x < 0.32:
                nops["submit"] += 1
                job_id = rng.choice(job_ids)
                payload = f"v{step}:{rng.randrange(7)}"
                due_at = now + rng.choice([-4.0, -1.0, 0.0, 1.0, 7.0])
                expected = model.submit(job_id, payload, due_at, now)
                actual = client.submit(job_id, payload, due_at=due_at)
                expect(actual, expected, f"step={step} submit")
            elif x < 0.65:
                nops["claim"] += 1
                limit = rng.randrange(1, 5)
                expected = model.claim(limit, now)
                actual = client.claim("w0" if step % 2 else "w1", limit=limit)
                expect(len(actual), len(expected), f"step={step} claimed count")
                for k, (leased, oracle_row) in enumerate(zip(actual, expected)):
                    expect((leased.job_id, leased.payload, leased.attempts, leased.lease_until),
                           (oracle_row.job_id, oracle_row.payload, oracle_row.attempts, oracle_row.lease_until),
                           f"step={step} claim[{k}]")
                    if not isinstance(leased.token, str) or not leased.token or leased.token in known_tokens:
                        raise Divergence(f"step={step} absent/reused opaque lease token")
                    oracle_row.token = leased.token
                    tokens.append((leased.job_id, leased.token))
                    known_tokens.add(leased.token)
            elif x < 0.81:
                nops["finish"] += 1
                job_id, tok = rng.choice(tokens) if tokens and rng.random() < 0.8 else (rng.choice(job_ids), "bogus")
                expected = model.finish(job_id, tok, now)
                actual = client.finish(job_id, tok)
                expect(actual, expected, f"step={step} finish")
            elif x < 0.96:
                nops["fail"] += 1
                job_id, tok = rng.choice(tokens) if tokens and rng.random() < 0.8 else (rng.choice(job_ids), "bogus")
                delay = rng.choice([0.0, 2.0, 4.0])
                expected = model.fail(job_id, tok, delay, now)
                actual = client.fail(job_id, tok, delay=delay)
                expect(actual, expected, f"step={step} fail")
            else:
                nops["advance"] += 1
                clock[0] += rng.choice([0.0, 1.0, 3.0, 5.0, 10.0])
            snapshot(step)
        return steps, dict(nops)


def invalid_argument_probes(queue_cls: type) -> list[str]:
    """Cross-check validation that Python booleans do not pass for positive ints."""
    misses = []
    with tempfile.TemporaryDirectory(prefix="dispatchq-validation-") as tmp:
        db = Path(tmp) / "queue.sqlite"
        for kwargs in ({"lease_seconds": 0.0}, {"lease_seconds": float('nan')},
                       {"lease_seconds": float('inf')}, {"max_attempts": 0},
                       {"max_attempts": True}):
            try:
                queue_cls(db, clock=lambda: 100.0, **kwargs)
            except (TypeError, ValueError, sqlite3.Error):
                pass
            else:
                misses.append(f"invalid constructor accepted: {kwargs!r}")
        q = queue_cls(db, clock=lambda: 100.0)
        for val in (0, -1, True, 1.5, "1"):
            try:
                q.claim("worker", limit=val)
            except (TypeError, ValueError, sqlite3.Error):
                pass
            else:
                misses.append(f"invalid limit accepted: {val!r}")
        for val in (float('inf'), float('nan'), -1.0):
            try:
                q.fail("not-present", "none", delay=val)
            except (TypeError, ValueError, sqlite3.Error):
                pass
            else:
                misses.append(f"invalid delay accepted: {val!r}")
    return misses


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--candidate", type=Path, required=True)
    ap.add_argument("--seeds", type=int, default=32)
    ap.add_argument("--steps", type=int, default=120)
    ap.add_argument("--mode", choices=("survey", "strict", "seed-calibration"), default="survey")
    ap.add_argument("--output", type=Path)
    args = ap.parse_args()
    if args.seeds < 1 or args.steps < 1:
        ap.error("seeds/steps must be positive")
    path = args.candidate.resolve() / "dispatchq" / "queue.py"
    if not path.is_file():
        ap.error("candidate must contain dispatchq/queue.py")
    source_hash = sha256(path.read_bytes()).hexdigest()
    if args.mode == 'seed-calibration' and source_hash != SEED_SHA256:
        ap.error("seed-calibration requires the pinned original defective source hash")
    sys.path.insert(0, str(args.candidate.resolve()))
    sys.modules.pop("dispatchq", None)
    sys.modules.pop("dispatchq.queue", None)
    cls = importlib.import_module("dispatchq.queue").WorkQueue
    successes = []
    failures = []
    errors = []
    for seed in range(args.seeds):
        try:
            ops, distribution = run_trajectory(cls, seed, args.steps)
            successes.append({"seed": seed, "ops": ops, "actions": distribution})
        except Divergence as exc:
            failures.append({"seed": seed, "type": type(exc).__name__, "reason": str(exc)[:250]})
        except Exception as exc:
            errors.append({"seed": seed, "type": type(exc).__name__, "reason": str(exc)[:250]})
    validity = invalid_argument_probes(cls)
    report = {
        "benchmark": "NIGHTFALL-DISPATCHQ-B1", "checker": "public-stateful-oracle-v1",
        "mode": args.mode, "candidate_sha256": source_hash,
        "seeds": args.seeds, "steps_per_seed": args.steps,
        "passed_trajectories": len(successes), "failed_trajectories": len(failures),
        "validation_misses": validity,
        "execution_errors": errors,
        "failed_examples": failures[:8],
        "python": sys.version.split()[0],
        "trust_limit": "Trusted local candidates only; no sandbox; no hidden grader or independent human review",
    }
    payload = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(payload)
    print(payload)
    if args.mode == "strict":
        return 0 if not failures and not errors and not validity else 1
    if args.mode == "seed-calibration":
        return 0 if not errors and args.seeds == 32 and args.steps == 120 and len(failures) == 32 and len(validity) == 12 else 1
    return 0 if not errors else 1

if __name__ == '__main__':
    raise SystemExit(main())
