#!/usr/bin/env python3
"""Join source-executed grader capsules to v2 run evidence, without score trust inflation.

The join is byte/hash based and still relies on trusted host custody.
It does not authenticate a model, its raw tool calls, or the grader's semantics.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path

from frozen_run_gate import (InvalidEvidence, need, exact_keys, is_hex,
                             json_file, sha_file, safe_member, verify)


CAPTURE_FIELDS = (
    "schema", "status", "plan_sha256", "task_id", "attempt_id", "image_id",
    "original_candidate_tree_sha256", "patched_candidate_tree_sha256",
    "submitted_patch_sha256", "grader_sha256", "grade_json_sha256",
    "grader_exit_code_observed", "grader_duration_seconds", "network_disabled",
    "agent_model_not_run_by_this_script", "grader_file_never_in_agent_workspace",
    "not_authenticated_against_malicious_host",
)


def joined_report(run_root: Path, plan_sha: str,
                  capsule_root: Path, pinned_manifest_sha: str):
    """Reject every mismatch; require the manifest SHA from an external source."""
    run_root = Path(run_root)
    capsule_root = Path(capsule_root)
    need(is_hex(pinned_manifest_sha), "external capture-manifest SHA required")
    run_report = verify(run_root, plan_sha)
    plan = json_file(safe_member(run_root, "plan.json"))
    manifest_path = safe_member(capsule_root, "capture-manifest.json")
    need(sha_file(manifest_path) == pinned_manifest_sha,
         "capture manifest changed since independent freeze")
    manifest = json_file(manifest_path)
    exact_keys(manifest, ("schema", "plan_sha256", "captures"), "manifest")
    need(manifest["schema"] == "nightfall.eval.capture-manifest.v1" and
         manifest["plan_sha256"] == plan_sha, "manifest identity mismatch")
    captures = manifest["captures"]
    need(type(captures) is list and len(captures) <= 100,
         "missing or enormous capture list")

    complete = []
    for aid in plan["attempt_ids"]:
        receipt = json_file(safe_member(run_root, f"attempts/{aid}/receipt.json"))
        if receipt["outcome"] == "completed":
            complete.append(aid)
    need(len(captures) == len(complete),
         "missing or extra grader capture in denominator")

    by_attempt = {}
    for item in captures:
        exact_keys(item, ("attempt_id", "capture_sha256", "grade_sha256"),
                   "manifest capture")
        aid = item["attempt_id"]
        need(type(aid) is str and aid in complete and aid not in by_attempt,
             "unknown/duplicate captured attempt")
        need(is_hex(item["capture_sha256"]) and is_hex(item["grade_sha256"]),
             "missing capture/grade SHA")
        by_attempt[aid] = item
    need(set(by_attempt) == set(complete),
         "capture manifest omitted a completed attempt")
    need(set(x.name for x in capsule_root.iterdir()) ==
         {"capture-manifest.json", "attempts"},
         "extra untrusted material in capture bundle")
    attempts_root = capsule_root / "attempts"
    need(attempts_root.is_dir() and
         sorted(x.name for x in attempts_root.iterdir()) == sorted(complete),
         "capture directories not equal to completed attempt set")

    matched = []
    for aid in complete:
        item = by_attempt[aid]
        location = capsule_root / "attempts" / aid
        need(location.is_dir() and
             set(x.name for x in location.iterdir()) == {"capture.json", "grade.json"},
             "extra or missing captured artifact")
        p_capture = safe_member(capsule_root, f"attempts/{aid}/capture.json")
        p_grade = safe_member(capsule_root, f"attempts/{aid}/grade.json")
        need(sha_file(p_capture) == item["capture_sha256"] and
             sha_file(p_grade) == item["grade_sha256"],
             "captured grader output/hash mismatches frozen manifest")
        evidence = json_file(p_capture)
        exact_keys(evidence, CAPTURE_FIELDS, "trusted grader capture")
        need(evidence["schema"] == "nightfall.eval.local-grader-capture.v1" and
             evidence["status"] ==
             "trusted_host_local_execution_not_independent_attestation",
             "unknown or inflated grader capture status")
        for key, expected in (
            ("plan_sha256", plan_sha),
            ("task_id", plan["task_id"]),
            ("attempt_id", aid),
            ("image_id", plan["runner_image_digest"]),
            ("original_candidate_tree_sha256", plan["candidate_tree_sha256"]),
            ("grader_sha256", plan["grader_sha256"]),
            ("grade_json_sha256", item["grade_sha256"]),
            ("grader_exit_code_observed", 0),
            ("network_disabled", True),
            ("agent_model_not_run_by_this_script", True),
            ("grader_file_never_in_agent_workspace", True),
            ("not_authenticated_against_malicious_host", True),
        ):
            need(type(evidence[key]) is type(expected) and evidence[key] == expected,
                 "grader capture contradiction: " + key)
        need(is_hex(evidence["patched_candidate_tree_sha256"]) and
             is_hex(evidence["submitted_patch_sha256"]),
             "missing patched-source or patch hash")
        duration = evidence["grader_duration_seconds"]
        need(type(duration) in (int, float) and math.isfinite(duration) and
             duration >= 0, "grader time malformed")
        receipt = json_file(safe_member(run_root, f"attempts/{aid}/receipt.json"))
        patch = safe_member(run_root, f"attempts/{aid}/patch.diff")
        grade = safe_member(run_root, f"attempts/{aid}/grade.json")
        need(sha_file(patch) == evidence["submitted_patch_sha256"],
             "grade was run on a different submitted patch")
        need(sha_file(grade) == item["grade_sha256"] and
             sha_file(grade) == receipt["grade_sha256"],
             "published grade differs from actual captured grader stdout")
        need(grade.read_bytes() == p_grade.read_bytes(),
             "reported grade bytes differ from captured score")
        matched.append({"attempt_id": aid,
                        "patch_sha256": evidence["submitted_patch_sha256"],
                        "grade_sha256": item["grade_sha256"]})

    return {
        "schema": "nightfall.eval.execution-join.v1",
        "decision": "local_scoring_captured_and_joined_but_model_unattested",
        "plan_sha256": plan_sha,
        "capture_manifest_sha256": pinned_manifest_sha,
        "planned_attempts": run_report["planned_attempts"],
        "graded_completed_attempts": len(complete),
        "failed_or_incomplete_attempts": run_report["not_completed"],
        "matched": matched,
        "ceiling": "not_a_blind_model_benchmark_or_independent_runner_attestation",
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("run_directory", type=Path)
    ap.add_argument("captures_directory", type=Path)
    ap.add_argument("--expected-plan-sha256", required=True)
    ap.add_argument("--externally-pinned-capture-manifest-sha256", required=True)
    args = ap.parse_args()
    try:
        report = joined_report(
            args.run_directory, args.expected_plan_sha256,
            args.captures_directory,
            args.externally_pinned_capture_manifest_sha256)
    except (InvalidEvidence, OSError, ValueError) as exc:
        print(json.dumps({"status": "REJECT", "reason": str(exc)}))
        raise SystemExit(1)
    print(json.dumps(report, sort_keys=True))


if __name__ == "__main__":
    main()
