"""Adversarial and source-different checks for the fictional legal kernel."""
import copy
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from kernel import evaluate, source_change_status
from independent_checker import check


class LegalPassportTests(unittest.TestCase):
    def setUp(self):
        self.doc = json.loads((ROOT / "fixtures" / "riverfront_passport.json").read_text(encoding="utf-8"))

    def outcome(self, expected):
        a, b = evaluate(self.doc), check(self.doc)
        self.assertEqual(expected, a["status"], a)
        self.assertEqual(expected, b["status"], b)
        if expected == "SUPPORTED_IN_FICTIONAL_MODEL":
            self.assertEqual(a["dependencies"], b["dependencies"])
        return a

    def test_valid_fictional_derivation(self):
        result = self.outcome("SUPPORTED_IN_FICTIONAL_MODEL")
        self.assertEqual(set(result["dependencies"]), {"law-r12", "parcel-map", "application", "clerk-registry"})
        self.assertEqual(result["goal"], "planning_review_required")

    def test_official_mode_cannot_be_promoted(self):
        self.doc["mode"] = "OFFICIAL"
        self.outcome("INVALID")

    def test_real_jurisdiction_cannot_be_promoted(self):
        self.doc["jurisdiction"] = "HUNTSVILLE_AL"
        self.outcome("INVALID")

    def test_tampered_source_text(self):
        self.doc["sources"][0]["text"] += " A changed clause."
        self.outcome("INVALID")

    def test_false_digest(self):
        self.doc["sources"][1]["sha256"] = "f" * 64
        self.outcome("INVALID")

    def test_missing_verbatim_citation(self):
        self.doc["rules"][0]["quote"] = "A nonexistent legal section"
        self.outcome("INVALID")

    def test_unreviewed_inference(self):
        self.doc["rules"][0]["reviewer"] = ""
        self.outcome("INVALID")

    def test_conflicting_premises(self):
        conflict = copy.deepcopy(self.doc["facts"][0])
        conflict["id"] = "f-conflict"
        conflict["value"] = False
        self.doc["facts"].append(conflict)
        self.outcome("INVALID")

    def test_missing_negative_exception_evidence(self):
        self.doc["proof"] = [s for s in self.doc["proof"] if s.get("ref") != "f-exemption"]
        self.outcome("INDETERMINATE")

    def test_missing_positive_premise(self):
        self.doc["proof"] = [s for s in self.doc["proof"] if s.get("ref") != "f-overlay"]
        self.outcome("INDETERMINATE")

    def test_proof_order_cannot_shortcut(self):
        step = self.doc["proof"].pop()
        self.doc["proof"].insert(0, step)
        self.outcome("INDETERMINATE")

    def test_unsupported_goal(self):
        self.doc["goal"] = "construction_authorized"
        self.outcome("INDETERMINATE")

    def test_expired_law(self):
        self.doc["sources"][0]["valid_until"] = "2026-11-15"
        self.outcome("INDETERMINATE")

    def test_future_unobserved_law(self):
        self.doc["sources"][0]["observed_at"] = "2026-11-16"
        self.outcome("INDETERMINATE")

    def test_withdrawn_source(self):
        self.doc["sources"][0]["status"] = "WITHDRAWN"
        self.outcome("INVALID")

    def test_nonfictional_source_is_forbidden(self):
        self.doc["sources"][0]["authenticity"] = "OFFICIAL"
        self.outcome("INVALID")

    def test_ambiguous_or_unknown_rule_requires_explicit_evidence(self):
        self.doc["rules"][0]["when_false"].append("historic_exception_granted")
        self.outcome("INDETERMINATE")

    def test_missing_source(self):
        self.doc["sources"].pop()
        self.outcome("INVALID")

    def test_unknown_step(self):
        self.doc["proof"].append({"kind": "assert_legal_truth", "ref": "auto"})
        self.outcome("INVALID")

    def test_duplicate_source_ids(self):
        self.doc["sources"].append(copy.deepcopy(self.doc["sources"][0]))
        self.outcome("INVALID")

    def test_tampered_claim_value_not_justified_by_quote(self):
        # Numeric/semantic correctness of parsed facts is OUTSIDE this kernel.
        # This test documents the trust gap rather than falsely certifying it.
        self.doc["facts"][0]["value"] = False
        result = self.outcome("INDETERMINATE")
        self.assertEqual(result["status"], "INDETERMINATE")

    def test_change_dependency_recheck(self):
        receipt = self.outcome("SUPPORTED_IN_FICTIONAL_MODEL")
        changed = copy.deepcopy(self.doc["sources"])
        changed[0]["sha256"] = "0" * 64
        status = source_change_status(receipt, changed)
        self.assertEqual(status["status"], "RECHECK_REQUIRED")
        self.assertEqual(status["changed_dependencies"], ["law-r12"])
        self.assertEqual(source_change_status(receipt, self.doc["sources"])["status"], "SOURCE_DIGESTS_UNCHANGED")


if __name__ == "__main__":
    unittest.main()
