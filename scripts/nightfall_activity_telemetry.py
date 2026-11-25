#!/usr/bin/env python3
"""SciNet activity overlay for existing NIGHTFALL agent-task receipts.

No task execution, proof promotion, independence attestation or AI-success prediction.
Input: JSONL, one object per observation. Required keys: run_id, activity,
operator, receipt. Optional: related_activities (list). One primary activity
owns the runtime; related activities are labels, never additional cost.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
from collections import defaultdict

from nightfall_agent_tasks import verify_receipt

# Adapted from Alamos & Althoff (2026), SciNet: The Anatomy of Science,
# CC BY 4.0. Pinned source (activity labels and IDs):
# https://github.com/lukasalthoff/scinet/blob/69973ad2cf21a34298b1f7f600f2c3820989113e/data/work_activities.csv
SOURCE = "69973ad2cf21a34298b1f7f600f2c3820989113e"
ACTIVITIES = {
    "U29.01": "Theorem construction",
    "U29.02": "Examples, counterexamples and classifications",
    "U29.03": "Formal frameworks",
    "U29.04": "Formal verification",
    "U29.05": "Conceptual frameworks",
    "U29.06": "Mathematical model formulation",
    "UNMAPPED": "Outside the imported theoretical-analysis taxonomy",
}
ID = re.compile(r"[A-Za-z0-9][A-Za-z0-9._:-]{0,127}")


def fingerprint(receipt):
    return hashlib.sha256(json.dumps(
        receipt, sort_keys=True, separators=(",", ":"), ensure_ascii=True,
        allow_nan=False,
    ).encode("utf-8")).hexdigest()


def aggregate(observations):
    runs, owners = {}, {}
    duplicate_observations = 0
    for event in observations:
        if not isinstance(event, dict) or not (
            {"run_id", "activity", "operator", "receipt"} <= set(event)
            <= {"run_id", "activity", "operator", "receipt", "related_activities"}
        ):
            raise ValueError("invalid activity observation")
        run_id, operator, activity = (event[k] for k in ("run_id", "operator", "activity"))
        if not all(isinstance(v, str) and ID.fullmatch(v) for v in (run_id, operator)):
            raise ValueError("invalid run/operator identifier")
        if not isinstance(activity, str) or activity not in ACTIVITIES:
            raise ValueError("unknown primary activity")
        related = event.get("related_activities", [])
        if not isinstance(related, list) or not all(
            isinstance(v, str) and v in ACTIVITIES and v != activity for v in related
        ):
            raise ValueError("invalid related activities")
        receipt = event["receipt"]
        verify_receipt(receipt)
        duration = receipt["execution"]["duration_ms"]
        if type(duration) is not int or duration < 0:
            raise ValueError("invalid measured runtime")
        key = fingerprint(receipt)
        identity = (key, activity, operator)
        if run_id in runs:
            if runs[run_id]["identity"] != identity:
                raise ValueError("conflicting observation for existing run ID")
            runs[run_id]["related"].update(related)
            duplicate_observations += 1
            continue
        if key in owners:
            raise ValueError("identical receipt assigned multiple run IDs; cannot distinguish executions")
        owners[key] = run_id
        runs[run_id] = {
            "identity": identity, "related": set(related), "duration": duration,
            "status": receipt["execution"]["status"],
            "problem": receipt["problem_id"], "dirty": receipt["source"]["worktree_dirty"],
        }
    groups = defaultdict(lambda: {"runs": 0, "pass_checks": 0, "fail_checks": 0,
                                  "runtime_ms": 0, "dirty_runs": 0})
    secondary = defaultdict(int)
    for r in runs.values():
        _, activity, operator = r["identity"]
        g = groups[(activity, operator)]
        g["runs"] += 1
        g["runtime_ms"] += r["duration"]
        g["pass_checks" if r["status"] == "PASS" else "fail_checks"] += 1
        g["dirty_runs"] += int(r["dirty"])
        for tag in r["related"]:
            secondary[tag] += 1
    return {
        "schema": "nightfall.activity-telemetry.v1",
        "taxonomy_commit": SOURCE,
        "unique_runs": len(runs),
        "duplicate_observations": duplicate_observations,
        "total_command_runtime_ms": sum(r["duration"] for r in runs.values()),
        "activity_operator": [
            {"activity": activity, "operator": operator, **metrics}
            for (activity, operator), metrics in sorted(groups.items())
        ],
        "secondary_tag_counts_nonadditive": dict(sorted(secondary.items())),
        "scope": "Structurally validated execution receipts; claimed provenance and classifications not attested. Runtime is summed command wall time, not human effort, makespan, tokens or spend.",
        "proof_certification": False,
        "independent_review_certified": False,
        "novelty_certified": False,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("jsonl", type=Path, help="observations with embedded existing task receipts")
    args = parser.parse_args()
    with args.jsonl.open(encoding="utf-8") as stream:
        result = aggregate(json.loads(line) for line in stream if line.strip())
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))


if __name__ == "__main__":
    main()
