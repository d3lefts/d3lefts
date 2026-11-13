#!/usr/bin/env python3
"""Independent mutation tests for the unified source-ledger audit.

These tests deliberately do not mock Lean proof validity. They verify that a
forged or stale source/receipt pointer cannot pass the editorial gate.
"""
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import lean_certificate_registry as registry


class RegistryTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.path = "research/nightfall/formalization/product_space/Test.lean"
        file = self.root / self.path
        file.parent.mkdir(parents=True)
        file.write_text("theorem test_proposition : True := by trivial\n")
        (self.root / "docs").mkdir()
        self.row = {
            "path": self.path,
            "classification": "quarantine",
            "source_blob_sha": registry.git_blob_hash(file.read_bytes()),
            "global_priority": "unverified",
            "ci_source_match_status": registry.CI_MATCH,
            "ci_run": 12345678,
            "ci_run_head_sha": "a" * 40,
            "ci_receipt_scope": "Matched successful head, not full theorem certification.",
        }
        self.manifest = {
            "schema": "nightfall-lean-provenance-v1",
            "revision": 1,
            "source_commit": "b" * 40,
            "modules": [self.row],
            "counts": {"quarantine": 1, "derived_transfer": 0, "finite_construction": 0},
            "ci_source_match_counts": {
                "matched_successful_ci_head": 1, "no_direct_receipt_identified": 0
            },
            "off_main_certificates": []
        }
        self.save()

    def save(self):
        (self.root / registry.MANIFEST).write_text(json.dumps(self.manifest))

    def assert_rejected(self, term):
        with self.assertRaisesRegex(ValueError, term):
            registry.inspect(self.root)

    def test_valid_fixture_is_source_only(self):
        result = registry.inspect(self.root)
        self.assertEqual(result["historical_source_match_count"], 1)
        self.assertTrue(result["current_checkout_source_integrity"])
        self.assertFalse(result["fresh_compiler_replay"])
        self.assertFalse(result["universal_theorem_certified"])

    def test_source_mutation_fails(self):
        (self.root / self.path).write_text("theorem changed : True := by trivial\n")
        self.assert_rejected("Source blob changed")

    def test_new_unregistered_module_is_pending_not_certified(self):
        new_path = "research/nightfall/formalization/New.lean"
        (self.root / new_path).write_text(
            "theorem new : True := by trivial\n")
        result = registry.inspect(self.root)
        self.assertEqual(result["inventory_count"], 1)
        self.assertEqual(result["current_checkout_lean_source_count"], 2)
        self.assertEqual(result["unreviewed_source_count"], 1)
        self.assertFalse(result["all_checkout_sources_source_matched"])
        self.assertFalse(result["current_checkout_source_integrity"])
        self.assertTrue(result["registered_source_integrity"])
        self.assertEqual(len(result["entries"]), 1)
        pending = result["unreviewed_sources"][0]
        self.assertEqual(pending["path"], new_path)
        self.assertEqual(pending["classification"], "unreviewed-source")
        self.assertEqual(pending["ci_source_match_status"], "no-verified-receipt")
        self.assertEqual(pending["historical_run"], None)
        self.assertEqual(pending["historical_head"], None)
        self.assertEqual(pending["global_priority"], "unverified")

    def test_removing_registered_module_fails_closed(self):
        (self.root / self.path).unlink()
        self.assert_rejected("Missing registered Lean source")

    def test_unreviewed_file_cannot_be_promoted_without_a_receipt(self):
        new_path = "research/nightfall/formalization/New.lean"
        data = b"theorem new : True := by trivial\\n"
        (self.root / new_path).write_bytes(data)
        rec = dict(self.row, path=new_path, source_blob_sha=registry.git_blob_hash(data))
        rec["ci_run"] = None
        self.manifest["modules"].append(rec)
        self.save()
        self.assert_rejected("Missing historical CI run")

    def test_missing_ci_head_fails(self):
        self.row["ci_run_head_sha"] = ""
        self.save()
        self.assert_rejected("Missing exact historical CI head")

    def test_forged_success_match_fails(self):
        self.row["ci_source_match_status"] = "not-compilable"
        self.save()
        self.assert_rejected("No successful source-matched CI head")

    def test_missing_receipt_scope_fails(self):
        self.row["ci_receipt_scope"] = ""
        self.save()
        self.assert_rejected("Missing receipt scope limitation")

    def test_novelty_promotion_fails(self):
        self.row["global_priority"] = "confirmed"
        self.save()
        self.assert_rejected("Unexpected global novelty promotion")

    def test_misclassified_counts_fail(self):
        self.manifest["counts"]["quarantine"] = 2
        self.save()
        self.assert_rejected("Classification count drift")

    def test_off_main_cannot_masquerade_as_main(self):
        self.manifest["off_main_certificates"] = [{
            "path": self.path, "merged_to_main": False
        }]
        self.save()
        self.assert_rejected("Unmerged branch evidence counted as main")

    def test_git_blob_algorithm_matches_reference(self):
        data = b"abc\n"
        expect = hashlib.sha1(b"blob 4\0abc\n").hexdigest()
        self.assertEqual(registry.git_blob_hash(data), expect)


if __name__ == "__main__":
    unittest.main(verbosity=2)
