#!/usr/bin/env python3
"""NIGHTFALL blind coding-agent run RECEIPT gate.

This is a structural/provenance consistency checker, not an agent executor, a
sandbox, a cryptographic signature scheme, or a validator of grader semantics.
All verdicts stay INTERNAL; do not relabel them model benchmarks.
Python 3.10+; standard library only.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path, PurePosixPath

SHA = re.compile(r"[a-f0-9]{64}\Z")
COMMIT = re.compile(r"[a-f0-9]{40}\Z")
ATTEMPT = re.compile(r"[A-Za-z0-9_-]{1,48}\Z")
TASK = re.compile(r"[A-Za-z][A-Za-z0-9_-]{1,63}\Z")
TERMINAL = {"completed", "timeout", "tool_failure", "crash", "refused"}
KINDS = {"tool_call", "tool_result", "assistant", "final", "error"}


class InvalidEvidence(ValueError):
    pass


def need(ok, why):
    if not ok:
        raise InvalidEvidence(why)


def exact_keys(obj, keys, context):
    need(type(obj) is dict and set(obj) == set(keys),
         context + ": missing/unknown keys")


def is_hex(s, pattern=SHA):
    return type(s) is str and pattern.fullmatch(s) is not None


def nonnegative_int(v):
    return type(v) is int and v >= 0


def positive_int(v):
    return type(v) is int and v > 0


def no_duplicates(pairs):
    seen = {}
    for key, value in pairs:
        need(key not in seen, "duplicate JSON key: " + key)
        seen[key] = value
    return seen


def json_file(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"),
                          object_pairs_hook=no_duplicates,
                          parse_constant=lambda x: (_ for _ in ()).throw(
                              InvalidEvidence("nonfinite JSON token " + x)))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise InvalidEvidence("cannot parse " + path.name + ": " +
                              type(exc).__name__) from exc


def sha_file(path):
    h = hashlib.sha256()
    try:
        with path.open("rb") as f:
            while True:
                data = f.read(65536)
                if not data:
                    break
                h.update(data)
    except OSError as exc:
        raise InvalidEvidence("cannot hash " + path.name) from exc
    return h.hexdigest()


def safe_member(root, rel):
    need(type(rel) is str and rel != "", "missing relative artifact path")
    p = PurePosixPath(rel)
    need(not p.is_absolute() and p.as_posix() == rel and
         all(part not in (".", "..") for part in rel.split("/")),
         "unsafe relative artifact path")
    need(not any(c in rel for c in ("\\", "\0", ":")), "unsafe filename")
    base = root.resolve(strict=True)
    path = root / rel
    need(path.resolve(strict=False).is_relative_to(base),
         "artifact path escapes evidence root")
    # Forbid symlinks even if pointing inside the run; prevent TOCTOU aliases.
    cur = root
    for part in rel.split("/"):
        cur = cur / part
        need(not cur.is_symlink(), "symlink in evidence path")
    need(path.is_file(), "missing evidence artifact " + rel)
    return path


def file_and_hash(root, rel, expected, context):
    need(is_hex(expected), context + ": missing SHA-256")
    path = safe_member(root, rel)
    need(sha_file(path) == expected, context + ": SHA-256 mismatch")
    return path


def validate_plan(plan):
    exact_keys(plan, ("schema", "task_id", "task_commit",
                      "candidate_tree_sha256", "prompt_sha256",
                      "grader_sha256", "runner_image_digest", "model_id",
                      "budget", "attempt_ids", "holdout"), "plan")
    need(plan["schema"] == "nightfall.eval.plan.v1", "unsupported plan schema")
    need(type(plan["task_id"]) is str and TASK.fullmatch(plan["task_id"]),
         "invalid task ID")
    need(is_hex(plan["task_commit"], COMMIT), "missing task source commit")
    for key in ("candidate_tree_sha256", "prompt_sha256", "grader_sha256"):
        need(is_hex(plan[key]), "invalid plan digest " + key)
    need(type(plan["runner_image_digest"]) is str and
         plan["runner_image_digest"].startswith("sha256:") and
         is_hex(plan["runner_image_digest"][7:]),
         "runner image must be pinned by sha256 digest")
    need(type(plan["model_id"]) is str and
         4 <= len(plan["model_id"]) <= 180 and
         "/" in plan["model_id"] and "@" in plan["model_id"].split("/", 1)[1],
         "model identity lacks provider/version pin")
    budget = plan["budget"]
    exact_keys(budget, ("wall_seconds", "tokens", "tool_calls"), "budget")
    need(all(positive_int(x) for x in budget.values()), "budget must be positive")
    ids = plan["attempt_ids"]
    need(type(ids) is list and 1 <= len(ids) <= 100 and
         all(type(x) is str and ATTEMPT.fullmatch(x) for x in ids) and
         len(set(ids)) == len(ids), "invalid/duplicate attempt IDs")
    h = plan["holdout"]
    exact_keys(h, ("hidden_tests_visible_to_agent",
                   "grader_outside_agent_workspace",
                   "network_disabled", "credentials_present"), "holdout")
    need(h == {"hidden_tests_visible_to_agent": False,
               "grader_outside_agent_workspace": True,
               "network_disabled": True,
               "credentials_present": False},
         "unsafe or undeclared holdout assumptions")


def validate_trace(trace, attempt_id, reported_calls, completed):
    exact_keys(trace, ("schema", "attempt_id", "events"), "trace")
    need(trace["schema"] == "nightfall.eval.trace.v1", "wrong trace schema")
    need(trace["attempt_id"] == attempt_id, "trace attempt identity mismatch")
    events = trace["events"]
    need(type(events) is list and len(events) > 0 and len(events) <= 100000,
         "trace absent or enormous")
    calls = 0
    pending = {}
    for i, event in enumerate(events):
        exact_keys(event, ("seq", "kind", "tool"), "trace event")
        need(type(event["seq"]) is int and event["seq"] == i,
             "trace sequence reordered or omitted")
        need(type(event["kind"]) is str and event["kind"] in KINDS,
             "unknown trace event kind")
        need(type(event["tool"]) is str and len(event["tool"]) <= 128,
             "invalid trace tool name")
        if event["kind"] in ("tool_call", "tool_result"):
            need(len(event["tool"]) > 0, "missing tool name")
        else:
            need(event["tool"] == "", "non-tool event has a tool name")
        if event["kind"] == "tool_call":
            calls += 1
            pending[event["tool"]] = pending.get(event["tool"], 0) + 1
        if event["kind"] == "tool_result":
            need(pending.get(event["tool"], 0) > 0,
                 "tool result without preceding matching call")
            pending[event["tool"]] -= 1
    need(calls == reported_calls, "tool count contradicts raw trace")
    if completed:
        need(not any(pending.values()),
             "completed episode has unanswered tool calls")
    return calls


def validate_grade(grade, plan, attempt_id):
    exact_keys(grade, ("schema", "task_id", "attempt_id",
                       "grader_sha256", "tests_passed", "tests_total",
                       "score_points", "max_points", "grader_exit_code"), "grade")
    need(grade["schema"] == "nightfall.eval.grade.v1", "grade schema mismatch")
    need(grade["task_id"] == plan["task_id"] and
         grade["attempt_id"] == attempt_id, "grade task/attempt mismatch")
    need(grade["grader_sha256"] == plan["grader_sha256"], "grader identity drift")
    for key in ("tests_passed", "tests_total", "score_points", "max_points",
                "grader_exit_code"):
        need(nonnegative_int(grade[key]), "invalid grade integer " + key)
    need(grade["max_points"] > 0 and grade["tests_total"] > 0,
         "empty grading denominator")
    need(grade["tests_passed"] <= grade["tests_total"] and
         grade["score_points"] <= grade["max_points"], "score over maximum")
    need(grade["grader_exit_code"] == 0, "grader command failed")
    return grade["score_points"], grade["max_points"]


def verify(root, expected_plan_sha256):
    root = Path(root)
    need(is_hex(expected_plan_sha256), "pin the expected plan hash externally")
    plan_file = safe_member(root, "plan.json")
    need(set(x.name for x in root.iterdir()) == {"plan.json", "attempts"},
         "undeclared top-level evidence material")
    need(sha_file(plan_file) == expected_plan_sha256,
         "plan changed since preregistration")
    plan = json_file(plan_file)
    validate_plan(plan)
    scores = []
    attempts = []
    budget = plan["budget"]
    for attempt_id in plan["attempt_ids"]:
        receipt_path = safe_member(root, "attempts/" + attempt_id + "/receipt.json")
        receipt = json_file(receipt_path)
        exact_keys(receipt, ("schema", "attempt_id", "plan_sha256",
                             "task_commit", "model_id", "outcome",
                             "elapsed_seconds", "tokens_used", "tool_calls",
                             "trace_path", "trace_sha256",
                             "patch_path", "patch_sha256",
                             "grade_path", "grade_sha256"), "attempt")
        need(receipt["schema"] == "nightfall.eval.attempt.v1",
             "wrong attempt schema")
        need(receipt["attempt_id"] == attempt_id and
             receipt["plan_sha256"] == expected_plan_sha256 and
             receipt["task_commit"] == plan["task_commit"] and
             receipt["model_id"] == plan["model_id"],
             "attempt crossed frozen model/plan/source identity")
        need(type(receipt["outcome"]) is str and
             receipt["outcome"] in TERMINAL, "unknown terminal outcome")
        for key, maximum in (
            ("elapsed_seconds", budget["wall_seconds"]),
            ("tokens_used", budget["tokens"]),
            ("tool_calls", budget["tool_calls"])
        ):
            need(nonnegative_int(receipt[key]) and receipt[key] <= maximum,
                 "budget or type violation: " + key)
        need(receipt["trace_path"] ==
             "attempts/" + attempt_id + "/trace.json",
             "trace not owned by matching attempt")
        trace_path = file_and_hash(
            root, receipt["trace_path"], receipt["trace_sha256"], "trace")
        trace = json_file(trace_path)
        completed = receipt["outcome"] == "completed"
        calls = validate_trace(trace, attempt_id, receipt["tool_calls"], completed)
        if completed:
            need(receipt["patch_path"] ==
                 "attempts/" + attempt_id + "/patch.diff" and
                 receipt["grade_path"] ==
                 "attempts/" + attempt_id + "/grade.json",
                 "graded artifact crosses attempt boundary")
            need(calls > 0, "completed attempt has no tool-use evidence")
            patch = file_and_hash(root, receipt["patch_path"],
                                  receipt["patch_sha256"], "patch")
            need(patch.stat().st_size > 0, "empty patch")
            grade_file = file_and_hash(root, receipt["grade_path"],
                                       receipt["grade_sha256"], "grader receipt")
            score = validate_grade(json_file(grade_file), plan, attempt_id)
            scores.append({"attempt_id": attempt_id, "score_points": score[0],
                           "max_points": score[1]})
        else:
            # Failures remain in the fixed denominator, with no invented grade.
            need(receipt["patch_path"] is None and
                 receipt["patch_sha256"] is None and
                 receipt["grade_path"] is None and
                 receipt["grade_sha256"] is None,
                 "incomplete episode invented a graded patch")
        expected_files = {"receipt.json", "trace.json"}
        if completed:
            expected_files |= {"patch.diff", "grade.json"}
        attempt_dir = root / "attempts" / attempt_id
        need(set(x.name for x in attempt_dir.iterdir()) == expected_files,
             "undeclared artifact or hidden grader in attempt packet")
        attempts.append({"attempt_id": attempt_id,
                         "outcome": receipt["outcome"], "tool_calls": calls})
    # Check no undeclared attempt receipts are hidden from the denominator.
    folder = root / "attempts"
    need(folder.is_dir() and
         sorted(x.name for x in folder.iterdir()) == sorted(plan["attempt_ids"]),
         "unexpected or omitted attempt directory")
    return {
        "schema": "nightfall.eval.internal-receipt-check.v1",
        "decision": "structurally_consistent_unattested_internal_records",
        "plan_sha256": expected_plan_sha256,
        "task_id": plan["task_id"],
        "planned_attempts": len(plan["attempt_ids"]),
        "observed_attempts": len(attempts),
        "completed_with_tool_and_grade": len(scores),
        "not_completed": len(attempts) - len(scores),
        "attempts": attempts,
        "author_reported_grader_scores_not_verified": scores,
        "ceiling": "internal_unreviewed_run_not_a_validated_benchmark",
    }


def main():
    p = argparse.ArgumentParser()
    p.add_argument("run_directory", type=Path)
    p.add_argument("--expected-plan-sha256", required=True)
    args = p.parse_args()
    try:
        report = verify(args.run_directory, args.expected_plan_sha256)
    except (InvalidEvidence, OSError) as exc:
        print(json.dumps({"status": "REJECT", "reason": str(exc)},
                         sort_keys=True))
        return 2
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
