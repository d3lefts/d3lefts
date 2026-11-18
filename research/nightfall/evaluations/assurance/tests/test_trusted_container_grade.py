"""Synthetic proof attacks for trusted_container_grade; NO models or hidden tests."""
from __future__ import annotations
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from trusted_container_grade import (InvalidEvidence, capture, tree_sha256,
                                     patch_paths, validate_result)
from frozen_run_gate import sha_file, validate_grade


def put(path, body):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(body, encoding="utf-8")


class ContractUnitTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.seed = self.root / "seed"
        put(self.seed / "value.py", "ANSWER=0\n")
        self.patch = self.root / "candidate.patch"
        put(self.patch, "diff --git a/value.py b/value.py\n"
                        "--- a/value.py\n+++ b/value.py\n"
                        "@@ -1 +1 @@\n-ANSWER=0\n+ANSWER=1\n")
        self.grader = self.root / "grader.py"
        put(self.grader, 'print("temporary")\n')

    def test_canonical_tree_identity_sensitive_to_mode_and_bytes(self):
        original = tree_sha256(self.seed)
        put(self.seed / "value.py", "ANSWER=1\n")
        self.assertNotEqual(tree_sha256(self.seed), original)
        (self.seed / "value.py").chmod(0o755)
        self.assertNotEqual(tree_sha256(self.seed), original)

    def test_safe_patch_diff_parses_original(self):
        self.assertEqual(patch_paths(self.patch), ["value.py"])

    def test_path_traversal_is_rejected_before_apply(self):
        put(self.patch, "diff --git a/../grader.py b/../grader.py\n")
        with self.assertRaises(InvalidEvidence):
            patch_paths(self.patch)

    def test_ambiguous_cross_file_diff_is_rejected(self):
        put(self.patch, "diff --git a/value.py b/other.py\n")
        with self.assertRaises(InvalidEvidence):
            patch_paths(self.patch)

    def test_new_symlink_in_seed_is_rejected(self):
        (self.seed / "secret.py").symlink_to(self.grader)
        with self.assertRaises(InvalidEvidence):
            tree_sha256(self.seed)

    def test_duplicate_json_and_boolean_grade_are_rejected(self):
        plan = {"task_id": "DispatchQ-B1",
                "grader_sha256": "a"*64,
                "grading": {"tests_total": 1, "max_points": 100}}
        grade = b'{"tests_passed":1,"tests_passed":0,"tests_total":1,"score_points":100,"max_points":100}'
        with self.assertRaises(InvalidEvidence):
            validate_result(grade, plan, "try-1")
        grade = b'{"tests_passed":true,"tests_total":1,"score_points":100,"max_points":100}'
        with self.assertRaises(InvalidEvidence):
            validate_result(grade, plan, "try-1")

    def test_nonfrozen_scoring_scale_is_rejected(self):
        plan = {"task_id": "DispatchQ-B1",
                "grader_sha256": "a"*64,
                "grading": {"tests_total": 1, "max_points": 100}}
        bad = b'{"tests_passed":1,"tests_total":1,"score_points":7,"max_points":7}'
        with self.assertRaises(InvalidEvidence):
            validate_result(bad, plan, "try-1")


@unittest.skipUnless(os.environ.get("NIGHTFALL_TEST_DOCKER_ID"),
                     "requires an explicitly locally pinned Docker image ID")
class RealContainerSyntheticTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.seed = self.root / "seed"
        put(self.seed / "value.py", "ANSWER=0\n")
        self.patch = self.root / "candidate.patch"
        put(self.patch, "diff --git a/value.py b/value.py\n"
                        "--- a/value.py\n+++ b/value.py\n"
                        "@@ -1 +1 @@\n-ANSWER=0\n+ANSWER=1\n")
        self.grader = self.root / "hidden_grader.py"
        self.grade_src = (
            "import json,runpy,sys\n"
            "v=runpy.run_path(sys.argv[1]+'/value.py')['ANSWER']\n"
            "score=100 if v==1 else 0\n"
            "print(json.dumps({'tests_passed':int(score>0),'tests_total':1,"
            "'score_points':score,'max_points':100}))\n")
        put(self.grader, self.grade_src)
        self.plan = self.root / "plan.json"
        self.plan_data = {
            "schema": "nightfall.eval.plan.v2",
            "task_id": "Synthetic-Capture",
            "task_commit": "a"*40,
            "candidate_tree_sha256": tree_sha256(self.seed),
            "prompt_sha256": "c"*64,
            "grader_sha256": sha_file(self.grader),
            "runner_image_digest": os.environ["NIGHTFALL_TEST_DOCKER_ID"],
            "model_id": "laboratory/synthetic-nonmodel@2026-11-18",
            "budget": {"wall_seconds": 300, "tokens": 20000, "tool_calls": 20},
            "grading": {"tests_total": 1, "max_points": 100},
            "attempt_ids": ["try-1", "try-2"],
            "holdout": {"hidden_tests_visible_to_agent": False,
                        "grader_outside_agent_workspace": True,
                        "network_disabled": True, "credentials_present": False},
        }
        self.repin()

    def repin(self):
        self.plan.write_text(json.dumps(self.plan_data, sort_keys=True),
                             encoding="utf-8")
        self.plan_sha = sha_file(self.plan)

    def run_capture(self, attempt="try-1", name="capture"):
        return capture(self.plan, self.plan_sha, attempt, self.seed,
                       self.patch, self.grader, self.root/name, 60)

    def test_real_executed_score_from_patched_source(self):
        res = self.run_capture()
        grade = json.loads((self.root/"capture"/"grade.json").read_text())
        self.assertEqual((grade["tests_passed"], grade["score_points"]), (1,100))
        self.assertEqual(validate_grade(grade, self.plan_data, "try-1"), (100, 100))
        self.assertEqual(res["submitted_patch_sha256"], sha_file(self.patch))
        self.assertNotEqual(res["original_candidate_tree_sha256"],
                            res["patched_candidate_tree_sha256"])
        self.assertEqual(res["grade_json_sha256"],
                         sha_file(self.root/"capture"/"grade.json"))
        self.assertTrue(res["agent_model_not_run_by_this_script"])
        self.assertFalse((self.root/"seed"/"hidden_grader.py").exists())

    def test_frozen_grader_bytes_cannot_change(self):
        put(self.grader, self.grade_src + "# changed\n")
        with self.assertRaises(InvalidEvidence):
            self.run_capture()
        self.assertFalse((self.root/"capture").exists())

    def test_frozen_source_tree_cannot_change(self):
        put(self.seed/"value.py", "ANSWER=42\n")
        with self.assertRaises(InvalidEvidence):
            self.run_capture()
        self.assertFalse((self.root/"capture").exists())

    def test_output_scale_not_self_selected(self):
        put(self.grader, self.grade_src.replace("'max_points':100", "'max_points':7"))
        self.plan_data["grader_sha256"] = sha_file(self.grader)
        self.repin()
        with self.assertRaises(InvalidEvidence):
            self.run_capture()
        self.assertFalse((self.root/"capture").exists())

    def test_failed_grader_creates_no_score(self):
        put(self.grader, "raise RuntimeError('synthetic grader failure')\n")
        self.plan_data["grader_sha256"] = sha_file(self.grader)
        self.repin()
        with self.assertRaises(InvalidEvidence):
            self.run_capture()
        self.assertFalse((self.root/"capture").exists())

    def test_network_is_disabled_in_real_container(self):
        src = (
            "import json,socket\n"
            "sock=socket.socket();sock.settimeout(1.0)\n"
            "try:\n"
            "  sock.connect(('1.1.1.1',443));blocked=False\n"
            "except OSError:\n"
            "  blocked=True\n"
            "finally:\n"
            "  sock.close()\n"
            "print(json.dumps({'tests_passed':int(blocked),'tests_total':1,"
            "'score_points':100 if blocked else 0,'max_points':100}))\n")
        put(self.grader, src)
        self.plan_data["grader_sha256"] = sha_file(self.grader)
        self.repin()
        self.run_capture()
        grade = json.loads((self.root/"capture"/"grade.json").read_text())
        self.assertEqual(grade["score_points"],100)


if __name__ == "__main__":
    unittest.main()
