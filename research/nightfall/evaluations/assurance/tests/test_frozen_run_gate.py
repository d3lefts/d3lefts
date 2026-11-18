"""Adversarial tests for frozen_run_gate. All data is synthetic; NO model runs."""
from __future__ import annotations

import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from frozen_run_gate import InvalidEvidence, sha_file, verify


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, sort_keys=True, separators=(",", ":")),
                    encoding="utf-8")
    return sha_file(path)


class FrozenRunGateTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.plan = {
            "schema": "nightfall.eval.plan.v2",
            "task_id": "DispatchQ-B1",
            "task_commit": "a" * 40,
            "candidate_tree_sha256": "b" * 64,
            "prompt_sha256": "c" * 64,
            "grader_sha256": "d" * 64,
            "runner_image_digest": "sha256:" + "e" * 64,
            "model_id": "laboratory/model-v1@2026-11-18",
            "budget": {"wall_seconds": 300, "tokens": 20000, "tool_calls": 20},
            "grading": {"tests_total": 2, "max_points": 100},
            "attempt_ids": ["try-1", "try-2"],
            "holdout": {"hidden_tests_visible_to_agent": False,
                        "grader_outside_agent_workspace": True,
                        "network_disabled": True,
                        "credentials_present": False},
        }
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.make_attempt("try-1", completed=True)
        self.make_attempt("try-2", completed=False)

    def make_attempt(self, attempt_id, completed):
        folder = self.root / "attempts" / attempt_id
        folder.mkdir(parents=True, exist_ok=True)
        trace = {
            "schema": "nightfall.eval.trace.v1", "attempt_id": attempt_id,
            "events": (
                [{"seq": 0, "kind": "tool_call", "tool": "edit_file"},
                 {"seq": 1, "kind": "tool_result", "tool": "edit_file"}]
                if completed else [{"seq": 0, "kind": "assistant", "tool": ""}]
            ),
        }
        t_rel = f"attempts/{attempt_id}/trace.json"
        trace_sha = write_json(folder / "trace.json", trace)
        if completed:
            p_rel = f"attempts/{attempt_id}/patch.diff"
            (folder / "patch.diff").write_bytes(b"diff --git a/file b/file\n+safe\n")
            p_sha = sha_file(folder / "patch.diff")
            g_rel = f"attempts/{attempt_id}/grade.json"
            grade = {
                "schema": "nightfall.eval.grade.v1",
                "task_id": self.plan["task_id"],
                "attempt_id": attempt_id,
                "grader_sha256": self.plan["grader_sha256"],
                "tests_passed": 1, "tests_total": 2,
                "score_points": 50, "max_points": 100,
                "grader_exit_code": 0,
            }
            g_sha = write_json(folder / "grade.json", grade)
        else:
            p_rel = p_sha = g_rel = g_sha = None
        receipt = {
            "schema": "nightfall.eval.attempt.v1",
            "attempt_id": attempt_id,
            "plan_sha256": self.plan_hash,
            "task_commit": self.plan["task_commit"],
            "model_id": self.plan["model_id"],
            "outcome": "completed" if completed else "tool_failure",
            "elapsed_seconds": 42, "tokens_used": 51,
            "tool_calls": 1 if completed else 0,
            "trace_path": t_rel, "trace_sha256": trace_sha,
            "patch_path": p_rel, "patch_sha256": p_sha,
            "grade_path": g_rel, "grade_sha256": g_sha,
        }
        write_json(folder / "receipt.json", receipt)

    def receipt(self, attempt_id="try-1"):
        return json.loads((self.root / "attempts" / attempt_id / "receipt.json")
                          .read_text())

    def update_receipt(self, data, attempt_id="try-1"):
        write_json(self.root / "attempts" / attempt_id / "receipt.json", data)

    def assert_bad(self, name=None):
        with self.assertRaises(InvalidEvidence, msg=name or "must reject"):
            verify(self.root, self.plan_hash)

    def test_valid_mixed_denominator(self):
        r = verify(self.root, self.plan_hash)
        self.assertEqual((r["planned_attempts"], r["observed_attempts"],
                          r["completed_with_tool_and_grade"], r["not_completed"]),
                         (2, 2, 1, 1))
        self.assertIn("unattested", r["decision"])
        self.assertEqual(r["author_reported_grader_scores_not_verified"][0]["score_points"], 50)

    def test_valid_failure_only_denominator(self):
        self.plan["attempt_ids"] = ["try-2"]
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.update_receipt({"unused": True}, "try-1")
        # Unregistered extra attempt must still be rejected, not discarded.
        self.assert_bad()

    def test_plan_tamper_after_external_pin(self):
        self.plan["model_id"] = "laboratory/model-v2"
        write_json(self.root / "plan.json", self.plan)
        self.assert_bad()

    def test_bad_external_plan_hash(self):
        with self.assertRaises(InvalidEvidence):
            verify(self.root, "f" * 64)

    def test_missing_failed_attempt_not_dropped(self):
        (self.root / "attempts" / "try-2" / "receipt.json").unlink()
        self.assert_bad()

    def test_undeclared_extra_attempt_directory(self):
        (self.root / "attempts" / "unregistered").mkdir()
        self.assert_bad()

    def test_duplicate_attempt_ids_in_plan(self):
        self.plan["attempt_ids"] = ["try-1", "try-1"]
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.assert_bad()

    def test_duplicate_json_keys_rejected(self):
        path = self.root / "plan.json"
        data = path.read_text()
        path.write_text(data[:-1] + ',"task_id":"DispatchQ-B1"}')
        self.plan_hash = sha_file(path)
        self.assert_bad()

    def test_unknown_plan_field_fails_closed(self):
        self.plan["claimed_google_approved"] = True
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.assert_bad()

    def test_holdout_grader_exposed_rejected(self):
        self.plan["holdout"]["hidden_tests_visible_to_agent"] = True
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.assert_bad()

    def test_holdout_credentials_rejected(self):
        self.plan["holdout"]["credentials_present"] = True
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.assert_bad()

    def test_wrong_model_receipt_rejected(self):
        receipt = self.receipt()
        receipt["model_id"] = "other/model"
        self.update_receipt(receipt)
        self.assert_bad()

    def test_wrong_task_commit_rejected(self):
        receipt = self.receipt()
        receipt["task_commit"] = "f" * 40
        self.update_receipt(receipt)
        self.assert_bad()

    def test_tool_count_not_backed_by_trace(self):
        receipt = self.receipt()
        receipt["tool_calls"] = 2
        self.update_receipt(receipt)
        self.assert_bad()

    def test_no_tool_use_cannot_complete(self):
        a = self.root / "attempts" / "try-1"
        trace = {
            "schema": "nightfall.eval.trace.v1", "attempt_id": "try-1",
            "events": [{"seq": 0, "kind": "final", "tool": ""}],
        }
        rec = self.receipt()
        rec["trace_sha256"] = write_json(a / "trace.json", trace)
        rec["tool_calls"] = 0
        self.update_receipt(rec)
        self.assert_bad()

    def test_trace_tampering_detected(self):
        (self.root / "attempts" / "try-1" / "trace.json").write_text("{}")
        self.assert_bad()

    def test_patch_tampering_detected(self):
        (self.root / "attempts" / "try-1" / "patch.diff").write_bytes(b"tampered")
        self.assert_bad()

    def test_grade_tampering_detected(self):
        (self.root / "attempts" / "try-1" / "grade.json").write_text("{}")
        self.assert_bad()

    def mutate_grade(self, key, value):
        a = self.root / "attempts" / "try-1"
        grade = json.loads((a / "grade.json").read_text())
        grade[key] = value
        r = self.receipt()
        r["grade_sha256"] = write_json(a / "grade.json", grade)
        self.update_receipt(r)

    def test_out_of_range_score_rejected_even_when_hash_repaired(self):
        self.mutate_grade("score_points", 101)
        self.assert_bad()

    def test_false_grader_digest_rejected(self):
        self.mutate_grade("grader_sha256", "0" * 64)
        self.assert_bad()

    def test_grader_exit_nonzero_rejected(self):
        self.mutate_grade("grader_exit_code", 2)
        self.assert_bad()

    def test_invalid_score_type_bool_rejected(self):
        self.mutate_grade("score_points", True)
        self.assert_bad()

    def test_timeout_cannot_invent_success_score(self):
        r = self.receipt("try-2")
        r["grade_path"] = "attempts/try-1/grade.json"
        r["grade_sha256"] = sha_file(self.root / r["grade_path"])
        self.update_receipt(r, "try-2")
        self.assert_bad()

    def test_budget_overrun_rejected(self):
        r = self.receipt()
        r["tokens_used"] = 20001
        self.update_receipt(r)
        self.assert_bad()

    def test_path_traversal_rejected(self):
        r = self.receipt()
        r["trace_path"] = "../plan.json"
        r["trace_sha256"] = self.plan_hash
        self.update_receipt(r)
        self.assert_bad()

    def test_internal_symlink_rejected(self):
        a = self.root / "attempts" / "try-1"
        (a / "trace2.json").symlink_to(a / "trace.json")
        r = self.receipt()
        r["trace_path"] = "attempts/try-1/trace2.json"
        self.update_receipt(r)
        self.assert_bad()

    def test_trace_sequence_gap_rejected_with_fresh_hash(self):
        a = self.root / "attempts" / "try-1"
        trace = json.loads((a / "trace.json").read_text())
        trace["events"][1]["seq"] = 4
        r = self.receipt()
        r["trace_sha256"] = write_json(a / "trace.json", trace)
        self.update_receipt(r)
        self.assert_bad()

    def test_versionless_model_id_rejected(self):
        self.plan["model_id"] = "laboratory/model"
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.assert_bad()

    def test_completed_unanswered_tool_call_rejected(self):
        a = self.root / "attempts" / "try-1"
        trace = {
            "schema": "nightfall.eval.trace.v1", "attempt_id": "try-1",
            "events": [{"seq": 0, "kind": "tool_call", "tool": "edit_file"}],
        }
        r = self.receipt()
        r["trace_sha256"] = write_json(a / "trace.json", trace)
        self.update_receipt(r)
        self.assert_bad()

    def test_orphan_tool_result_rejected(self):
        a = self.root / "attempts" / "try-1"
        trace = json.loads((a / "trace.json").read_text())
        trace["events"][0] = {"seq": 0, "kind": "tool_result", "tool": "edit_file"}
        r = self.receipt()
        r["trace_sha256"] = write_json(a / "trace.json", trace)
        self.update_receipt(r)
        self.assert_bad()

    def test_malformed_event_kind_cannot_crash_checker(self):
        a = self.root / "attempts" / "try-1"
        trace = json.loads((a / "trace.json").read_text())
        trace["events"][0]["kind"] = {"malformed": True}
        r = self.receipt()
        r["trace_sha256"] = write_json(a / "trace.json", trace)
        self.update_receipt(r)
        self.assert_bad()

    def test_malformed_outcome_cannot_crash_checker(self):
        r = self.receipt()
        r["outcome"] = {"fake": "completed"}
        self.update_receipt(r)
        self.assert_bad()

    def test_undeclared_hidden_grader_in_attempt_rejected(self):
        (self.root / "attempts" / "try-1" / "hidden_grader.py").write_text(
            "secret = True", encoding="utf-8")
        self.assert_bad()

    def test_undeclared_top_level_evidence_file_rejected(self):
        (self.root / "untracked-private-reference.py").write_text(
            "source", encoding="utf-8")
        self.assert_bad()

    def test_cross_attempt_trace_reuse_rejected(self):
        r = self.receipt()
        r["trace_path"] = "attempts/try-2/trace.json"
        r["trace_sha256"] = sha_file(self.root / r["trace_path"])
        self.update_receipt(r)
        self.assert_bad()

    def test_cross_attempt_grade_reuse_rejected(self):
        r = self.receipt("try-2")
        r["outcome"] = "completed"
        r["tool_calls"] = 1
        r["patch_path"] = "attempts/try-1/patch.diff"
        r["patch_sha256"] = sha_file(self.root / r["patch_path"])
        r["grade_path"] = "attempts/try-1/grade.json"
        r["grade_sha256"] = sha_file(self.root / r["grade_path"])
        self.update_receipt(r, "try-2")
        self.assert_bad()

    def test_v2_rejects_conflicting_grader_denominators(self):
        """Regression for independently reproduced v1 accept-with-mismatched-scales bug."""
        self.make_attempt("try-2", completed=True)
        folder = self.root / "attempts" / "try-2"
        grade = json.loads((folder / "grade.json").read_text())
        grade["tests_total"] = 3
        grade["tests_passed"] = 3
        grade["max_points"] = 7
        grade["score_points"] = 7
        receipt = self.receipt("try-2")
        receipt["grade_sha256"] = write_json(folder / "grade.json", grade)
        self.update_receipt(receipt, "try-2")
        self.assert_bad("two attempts cannot disagree on scorer scale")

    def test_v2_rejects_arbitrary_single_grade_scale(self):
        """One attempt cannot redefine the frozen point maximum."""
        self.mutate_grade("score_points", 1)
        self.mutate_grade("max_points", 1)
        self.assert_bad("one attempt cannot change its own scorer maximum")

    def test_v2_allows_two_completed_at_same_scoring_scale(self):
        self.make_attempt("try-2", completed=True)
        result = verify(self.root, self.plan_hash)
        self.assertEqual(result["frozen_grading_denominator"],
                         {"tests_total": 2, "max_points": 100})
        self.assertEqual(result["completed_with_tool_and_grade"], 2)
        self.assertEqual(result["planned_attempts"], 2)

    def test_v1_plan_rejected_no_silent_legacy_promotion(self):
        self.plan["schema"] = "nightfall.eval.plan.v1"
        self.plan.pop("grading")
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.assert_bad("v1 plans never pinned the score denominator")

    def test_grade_tests_total_drift_rejected(self):
        self.mutate_grade("tests_total", 3)
        self.assert_bad("grader test count drift")

    def test_grade_max_points_drift_rejected(self):
        self.mutate_grade("max_points", 101)
        self.assert_bad("grader max points drift")

    def test_plan_missing_frozen_grading_rejected(self):
        self.plan.pop("grading")
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.assert_bad("no unpinned score scale")

    def test_plan_boolean_grading_denominator_rejected(self):
        self.plan["grading"]["tests_total"] = True
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.assert_bad("Python True must not masquerade as integer one")

    def test_plan_empty_grading_denominator_rejected(self):
        self.plan["grading"]["max_points"] = 0
        self.plan_hash = write_json(self.root / "plan.json", self.plan)
        self.assert_bad("no zero score ceiling")

    def test_trace_unknown_event_rejected_with_fresh_hash(self):
        a = self.root / "attempts" / "try-1"
        trace = json.loads((a / "trace.json").read_text())
        trace["events"][1]["kind"] = "model_did_well"
        r = self.receipt()
        r["trace_sha256"] = write_json(a / "trace.json", trace)
        self.update_receipt(r)
        self.assert_bad()


if __name__ == "__main__":
    unittest.main()
