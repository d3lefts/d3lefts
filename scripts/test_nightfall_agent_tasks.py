#!/usr/bin/env python3
"""Independent fail-closed regression controls for the agent task dispatcher.

Checks contract semantics, not the mathematical correctness of the underlying
verifiers or independence of the agents using it.
"""
import copy
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

import nightfall_agent_tasks as tasks


class AgentTasksTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # Run an existing authoritative repository validator, not a fake pass.
        cls.receipt = tasks.run_task(
            "passport", "NIGHTFALL-PROGRAM", "independent-reproducer", 120
        )
        tasks.verify_receipt(cls.receipt)

    def test_catalogue_allowlist(self):
        catalog = tasks.task_list()
        self.assertEqual(catalog["schema"], "nightfall.agent-task-catalogue.v1")
        names = [x["name"] for x in catalog["tasks"]]
        self.assertEqual(names, sorted(tasks.TASKS))
        self.assertFalse(catalog["proof_certification"])
        with self.assertRaises(ValueError):
            tasks.run_task("bash -c 'echo unsafe'", "NIGHTFALL-PROGRAM", "auditor", 30)

    def test_positive_metadata_receipt_not_proof(self):
        r = self.receipt
        self.assertEqual(r["execution"]["status"], "PASS")
        self.assertEqual(r["execution"]["exit_code"], 0)
        self.assertFalse(r["certification"]["mathematical_theorem"])
        self.assertFalse(r["certification"]["independent_semantic_audit"])
        self.assertFalse(r["certification"]["global_priority"])
        self.assertTrue(tasks.GIT.fullmatch(r["source"]["git_head"]))

    def test_failure_cannot_be_promoted_to_pass(self):
        # Simulates an existing verifier returning a nonzero process status.
        real_run = subprocess.run

        def fail_checker(args, *params, **kwargs):
            if args and args[0] == sys.executable:
                return subprocess.CompletedProcess(args, 7, b"", b"intended failure")
            return real_run(args, *params, **kwargs)

        with mock.patch.object(tasks.subprocess, "run", side_effect=fail_checker):
            r = tasks.run_task("compiler-lock", "NIGHTFALL-PROGRAM", "auditor", 30)
        self.assertEqual(r["execution"]["status"], "FAIL")
        self.assertEqual(r["execution"]["exit_code"], 7)
        tasks.verify_receipt(r)
        bad = copy.deepcopy(r)
        bad["execution"]["status"] = "PASS"
        with self.assertRaisesRegex(ValueError, "forged"):
            tasks.verify_receipt(bad)

    def test_forged_certification_rejected(self):
        mutated = copy.deepcopy(self.receipt)
        mutated["certification"]["mathematical_theorem"] = True
        with self.assertRaisesRegex(ValueError, "cannot certify"):
            tasks.verify_receipt(mutated)

    def test_wrong_command_and_scope_rejected(self):
        for change in ("command", "scope"):
            mutated = copy.deepcopy(self.receipt)
            mutated[change] = "wrong" if change == "scope" else ["bash", "-c", "true"]
            with self.assertRaisesRegex(ValueError, "mismatch"):
                tasks.verify_receipt(mutated)

    def test_bad_source_anchors_rejected(self):
        for change in ("git_head", "anchor_sha256"):
            mutated = copy.deepcopy(self.receipt)
            mutated["source"][change] = "unknown"
            with self.assertRaises(ValueError):
                tasks.verify_receipt(mutated)

    def test_timeout_cannot_look_successful(self):
        mutated = copy.deepcopy(self.receipt)
        mutated["execution"]["timed_out"] = True
        with self.assertRaisesRegex(ValueError, "forged"):
            tasks.verify_receipt(mutated)

    def test_receipt_is_immutable_by_default(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / "receipt.json"
            tasks.write_receipt(self.receipt, p)
            self.assertTrue(p.exists())
            with self.assertRaisesRegex(ValueError, "already exists"):
                tasks.write_receipt(self.receipt, p)

    def test_role_and_problem_are_validated(self):
        with self.assertRaisesRegex(ValueError, "invalid problem"):
            tasks.run_task("passport", "../BAD", "constructor", 30)
        with self.assertRaisesRegex(ValueError, "unknown agent role"):
            tasks.run_task("passport", "GOOD", "made-up-reviewer", 30)

    def test_missing_anchors_are_not_accepted_as_proof(self):
        mutated = copy.deepcopy(self.receipt)
        mutated["source"]["anchor_sha256"].pop("docs/lean-compiler-lock.json")
        with self.assertRaisesRegex(ValueError, "source anchors"):
            tasks.verify_receipt(mutated)


if __name__ == "__main__":
    unittest.main(verbosity=2)
