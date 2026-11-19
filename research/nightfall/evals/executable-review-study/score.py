#!/usr/bin/env python3
"""Score a preregistered reviewer submission without inventing agent trials."""
from __future__ import annotations

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path

from oracle import evaluate_all

ALLOWED = frozenset({"valid", "invalid", "uncertain"})
MODES = frozenset({"prose_only", "executable"})


def score_submission(submission: dict, gold: dict) -> dict:
    if submission.get("schema") != "nightfall.exec-review.submission.v1":
        raise ValueError("wrong reviewer submission schema")
    reviewer = submission.get("reviewer_id")
    condition = submission.get("condition")
    if not isinstance(reviewer, str) or not reviewer.strip() or condition not in MODES:
        raise ValueError("reviewer ID and valid review condition required")
    if submission.get("case_sha256") != gold["case_sha256"]:
        raise ValueError("reviewer did not use the exact frozen case bank")
    answers = submission.get("answers")
    cases = gold["cases"]
    if not isinstance(answers, list) or len(answers) != len(cases):
        raise ValueError("all preregistered claims must be answered, uncertain is allowed")
    expected = {c["id"]: c for c in cases}
    seen = set()
    outcomes = []
    for row in answers:
        cid = row.get("id")
        verdict = row.get("verdict")
        if cid in seen or cid not in expected or verdict not in ALLOWED:
            raise ValueError("unrecognized, duplicated or malformed verdict")
        seen.add(cid)
        if not isinstance(row.get("reasoning"), str):
            raise ValueError("reviewer must supply reasoning for each verdict")
        truth = expected[cid]["ground_truth"]
        outcomes.append({"id": cid, "family": expected[cid]["family"],
                         "truth": truth, "verdict": verdict,
                         "correct": verdict == truth})
    outcomes.sort(key=lambda x: x["id"])
    true_valid = sum(x["truth"] == "valid" for x in outcomes)
    true_invalid = len(outcomes) - true_valid
    correct = sum(x["correct"] for x in outcomes)
    false_accept = sum(x["truth"] == "invalid" and x["verdict"] == "valid" for x in outcomes)
    false_reject = sum(x["truth"] == "valid" and x["verdict"] == "invalid" for x in outcomes)
    abstain = sum(x["verdict"] == "uncertain" for x in outcomes)
    return {
        "schema": "nightfall.exec-review.score.v1",
        "reviewer_id": reviewer, "condition": condition,
        "condition_enforced_by_oracle": False,
        "blind_holdout": False,
        "case_sha256": gold["case_sha256"],
        "submission_sha256": hashlib.sha256(json.dumps(submission, sort_keys=True).encode()).hexdigest(),
        "total": len(outcomes), "true_valid": true_valid, "true_invalid": true_invalid,
        "correct": correct,
        "accuracy_fraction": f"{correct}/{len(outcomes)}",
        "false_accept": false_accept, "false_reject": false_reject,
        "abstain": abstain,
        "family_accuracy": {family: f"{sum(o['correct'] for o in outcomes if o['family'] == family)}/{sum(o['family'] == family for o in outcomes)}"
                            for family in sorted(set(o["family"] for o in outcomes))},
        "outcomes": outcomes,
        "limits": "PUBLIC benchmark. Arm designation is self-declared, not enforced here. No independent agent trials implied.",
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--submission", required=True, type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    gold = evaluate_all()
    submission = json.loads(args.submission.read_text())
    report = score_submission(submission, gold)
    output = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.write_text(output, encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
