"""Synthetic proof attacks for trusted_container_grade; NO models or hidden tests."""
from __future__ import annotations
import hashlib
import json
import os
import shutil
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from trusted_container_grade import (InvalidEvidence, capture, tree_sha256,
                                     patch_paths, validate_result)
from frozen_run_gate import sha_file, validate_grade, verify
from join_grader_capture import joined_report


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

    def test_real_task_is_blocked_despite_synthetic_model_label(self):
        """A real task ID must not use this same-process scorer adapter."""
        self.plan_data["task_id"] = "DispatchQ-B1"
        self.repin()
        with self.assertRaisesRegex(InvalidEvidence, "UNTRUSTED_SCORE_ORIGIN"):
            self.run_capture()
        self.assertFalse((self.root/"capture").exists())

    def test_real_model_is_blocked_despite_synthetic_task_label(self):
        """A real agent identity cannot get a trusted score from this adapter."""
        self.plan_data["model_id"] = "independent-real-agent/run-a@2026-11-18"
        self.repin()
        with self.assertRaisesRegex(InvalidEvidence, "UNTRUSTED_SCORE_ORIGIN"):
            self.run_capture()
        self.assertFalse((self.root/"capture").exists())

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

    def test_oversized_grader_output_is_denied_without_score(self):
        put(self.grader, "print('X'*20000)\n")
        self.plan_data["grader_sha256"] = sha_file(self.grader)
        self.repin()
        with self.assertRaises(InvalidEvidence):
            self.run_capture()
        self.assertFalse((self.root/"capture").exists())

    def test_hanging_grader_is_denied_without_score(self):
        put(self.grader, "import time\ntime.sleep(10)\n")
        self.plan_data["grader_sha256"] = sha_file(self.grader)
        self.repin()
        with self.assertRaises(InvalidEvidence):
            capture(self.plan, self.plan_sha, "try-1", self.seed,
                    self.patch, self.grader, self.root/"capture", 2)
        self.assertFalse((self.root/"capture").exists())

    def test_input_patch_symlink_is_denied(self):
        patch_link = self.root/"alternate.patch"
        patch_link.symlink_to(self.patch)
        with self.assertRaises(InvalidEvidence):
            capture(self.plan, self.plan_sha, "try-1", self.seed,
                    patch_link, self.grader, self.root/"capture", 30)
        self.assertFalse((self.root/"capture").exists())

    def assemble_synthetic_packet(self):
        """Explicitly FAKE model trace, but REAL captured grader stdout."""
        self.run_capture()
        packet = self.root/"run"
        packet.mkdir()
        shutil.copyfile(self.plan, packet/"plan.json")
        for aid,complete in (("try-1",True),("try-2",False)):
            folder=packet/"attempts"/aid
            folder.mkdir(parents=True)
            trace={"schema":"nightfall.eval.trace.v1","attempt_id":aid,
                   "events":([
                       {"seq":0,"kind":"tool_call","tool":"edit_file"},
                       {"seq":1,"kind":"tool_result","tool":"edit_file"}
                   ] if complete else [
                       {"seq":0,"kind":"assistant","tool":""}
                   ])}
            trace_path=folder/"trace.json"
            trace_path.write_text(json.dumps(trace,sort_keys=True))
            patch_file=folder/"patch.diff"
            grade_file=folder/"grade.json"
            if complete:
                shutil.copyfile(self.patch,patch_file)
                shutil.copyfile(self.root/"capture"/"grade.json",grade_file)
            receipt={
                "schema":"nightfall.eval.attempt.v1",
                "attempt_id":aid,
                "plan_sha256":self.plan_sha,
                "task_commit":self.plan_data["task_commit"],
                "model_id":self.plan_data["model_id"],
                "outcome":"completed" if complete else "tool_failure",
                "elapsed_seconds":4,
                "tokens_used":20,
                "tool_calls":1 if complete else 0,
                "trace_path":f"attempts/{aid}/trace.json",
                "trace_sha256":sha_file(trace_path),
                "patch_path":f"attempts/{aid}/patch.diff" if complete else None,
                "patch_sha256":sha_file(patch_file) if complete else None,
                "grade_path":f"attempts/{aid}/grade.json" if complete else None,
                "grade_sha256":sha_file(grade_file) if complete else None,
            }
            (folder/"receipt.json").write_text(json.dumps(receipt,sort_keys=True))
        self.assertEqual(verify(packet,self.plan_sha)["planned_attempts"],2)
        capsules=self.root/"capsules"
        cap_dir=capsules/"attempts"/"try-1"
        cap_dir.mkdir(parents=True)
        shutil.copyfile(self.root/"capture"/"capture.json",cap_dir/"capture.json")
        shutil.copyfile(self.root/"capture"/"grade.json",cap_dir/"grade.json")
        manifest={
            "schema":"nightfall.eval.capture-manifest.v1",
            "plan_sha256":self.plan_sha,
            "captures":[{"attempt_id":"try-1",
                         "capture_sha256":sha_file(cap_dir/"capture.json"),
                         "grade_sha256":sha_file(cap_dir/"grade.json")}]
        }
        (capsules/"capture-manifest.json").write_text(
            json.dumps(manifest,sort_keys=True))
        return packet,capsules,sha_file(capsules/"capture-manifest.json")

    def test_score_join_after_real_synthetic_grader(self):
        packet,capsules,pin=self.assemble_synthetic_packet()
        report=joined_report(packet,self.plan_sha,capsules,pin)
        self.assertEqual((report["planned_attempts"],
                          report["graded_completed_attempts"],
                          report["failed_or_incomplete_attempts"]),(2,1,1))
        self.assertIn("unattested",report["decision"])

    def test_posthoc_inflated_score_passes_format_but_fails_execution_join(self):
        packet,capsules,pin=self.assemble_synthetic_packet()
        a=packet/"attempts"/"try-1"
        grade=json.loads((a/"grade.json").read_text())
        grade["score_points"]=99
        (a/"grade.json").write_text(json.dumps(grade,sort_keys=True))
        receipt=json.loads((a/"receipt.json").read_text())
        receipt["grade_sha256"]=sha_file(a/"grade.json")
        (a/"receipt.json").write_text(json.dumps(receipt,sort_keys=True))
        # Deliberately prove receipt-only v2 admits this self-reported change.
        self.assertEqual(verify(packet,self.plan_sha)["completed_with_tool_and_grade"],1)
        with self.assertRaises(InvalidEvidence):
            joined_report(packet,self.plan_sha,capsules,pin)

    def test_posthoc_patch_substitution_is_rejected(self):
        packet,capsules,pin=self.assemble_synthetic_packet()
        a=packet/"attempts"/"try-1"
        (a/"patch.diff").write_text((a/"patch.diff").read_text().replace(
            "+ANSWER=1","+ANSWER=2"))
        receipt=json.loads((a/"receipt.json").read_text())
        receipt["patch_sha256"]=sha_file(a/"patch.diff")
        (a/"receipt.json").write_text(json.dumps(receipt,sort_keys=True))
        self.assertEqual(verify(packet,self.plan_sha)["completed_with_tool_and_grade"],1)
        with self.assertRaises(InvalidEvidence):
            joined_report(packet,self.plan_sha,capsules,pin)

    def test_capture_manifest_freeze_and_complete_denominator(self):
        packet,capsules,pin=self.assemble_synthetic_packet()
        manifest_path=capsules/"capture-manifest.json"
        manifest=json.loads(manifest_path.read_text())
        manifest["captures"]=[]
        manifest_path.write_text(json.dumps(manifest,sort_keys=True))
        with self.assertRaises(InvalidEvidence):
            joined_report(packet,self.plan_sha,capsules,pin)
        # Even deliberately repinning a now-empty posthoc manifest must fail
        # because the actual planned completed attempt still needs a capsule.
        with self.assertRaises(InvalidEvidence):
            joined_report(packet,self.plan_sha,capsules,sha_file(manifest_path))

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
