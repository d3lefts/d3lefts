"""Adversarial tests: constructor and independent checker intentionally separate."""
import copy
import hashlib
import json
import unittest
from pathlib import Path

from legal_kernel.derive import derive
from legal_kernel.verify import verify, source_impact
from legal_kernel.dossier import build

CASE = Path(__file__).resolve().parents[1] / "fixtures" / "riverfront.json"


def model():
    return json.loads(CASE.read_text(encoding="utf-8"))


class LegalKernelTests(unittest.TestCase):
    def setUp(self):
        self.case = model()
        self.proof = derive(self.case)

    def check(self, case=None, proof=None):
        return verify(self.case if case is None else case, self.proof if proof is None else proof)

    def test_exact_model_derivations(self):
        result = self.check()
        self.assertEqual(result["status"], "MODEL_VALID")
        self.assertEqual([g["status"] for g in result["goals"]],
                         ["MODEL_DERIVED", "MODEL_DERIVED", "INDETERMINATE"])
        self.assertEqual(result["legal_authority"], "NOT_ASSESSED")

    def test_dossier_never_casts_vote(self):
        result = build(self.case)
        self.assertFalse(result["preference"]["ballot_cast"])
        self.assertFalse(result["preference"]["stored"])
        self.assertTrue(result["notice"].startswith("No source"))

    def test_source_tamper(self):
        case = copy.deepcopy(self.case)
        case["sources"][0]["raw_text"] += " altered"
        self.assertEqual(self.check(case=case)["status"], "INVALID")

    def test_fabricated_fact(self):
        proof = copy.deepcopy(self.proof)
        proof["steps"][0]["conclusion"] = {"predicate": "development_approved", "args": ["project-001"]}
        self.assertEqual(self.check(proof=proof)["status"], "INVALID")

    def test_fabricated_rule_conclusion(self):
        proof = copy.deepcopy(self.proof)
        target = next(s for s in proof["steps"] if s["id"] == "rule:Z7-r1")
        target["conclusion"] = {"predicate": "development_approved", "args": ["project-001"]}
        self.assertEqual(self.check(proof=proof)["status"], "INVALID")

    def test_forged_premise(self):
        proof = copy.deepcopy(self.proof)
        target = next(s for s in proof["steps"] if s["id"] == "rule:F2-r1")
        target["premises"][0] = "fact:DEV-f1"
        self.assertEqual(self.check(proof=proof)["status"], "INVALID")

    def test_cross_jurisdiction(self):
        case = copy.deepcopy(self.case)
        case["sources"][1]["jurisdiction"] = "another-city"
        self.assertEqual(self.check(case=case)["status"], "INVALID")

    def test_unknown_external_source(self):
        case = copy.deepcopy(self.case)
        case["sources"][0]["source_uri"] = "https://example.com/fake-law"
        self.assertEqual(self.check(case=case)["status"], "INVALID")

    def test_future_effective_source_holds(self):
        case = copy.deepcopy(self.case)
        case["sources"][0]["effective_at"] = "2026-12-01T00:00:00Z"
        result = self.check(case=case)
        self.assertEqual(result["status"], "INDETERMINATE")
        self.assertEqual(result["goals"][0]["status"], "INDETERMINATE")
        self.assertEqual(result["goals"][1]["status"], "MODEL_DERIVED")

    def test_source_not_known_at_cutoff(self):
        case = copy.deepcopy(self.case)
        case["sources"][1]["observed_at"] = "2026-11-20T00:00:00Z"
        result = self.check(case=case)
        self.assertEqual(result["status"], "INDETERMINATE")
        self.assertEqual(result["goals"][1]["status"], "INDETERMINATE")

    def test_supersession_changes_scope(self):
        case = copy.deepcopy(self.case)
        old = case["sources"][0]
        newer = copy.deepcopy(old)
        newer["id"] = "Z7-v2"
        newer["supersedes"] = ["Z7"]
        newer["effective_at"] = "2026-12-01T00:00:00Z"
        newer["observed_at"] = "2026-12-01T00:00:00Z"
        newer["facts"] = []
        newer["rules"] = []
        case["sources"].append(newer)
        case["legal_at"] = case["known_at"] = "2026-12-05T00:00:00Z"
        proof = derive(case)
        result = verify(case, proof)
        self.assertEqual(result["status"], "INDETERMINATE")
        self.assertEqual(result["goals"][0]["status"], "INDETERMINATE")
        self.assertEqual(result["goals"][1]["status"], "MODEL_DERIVED")

    def test_snapshot_mismatch(self):
        proof = copy.deepcopy(self.proof)
        proof["legal_at"] = "2026-12-03T00:00:00Z"
        self.assertEqual(self.check(proof=proof)["status"], "INVALID")

    def test_duplicate_step_attack(self):
        proof = copy.deepcopy(self.proof)
        proof["steps"].append(proof["steps"][0])
        self.assertEqual(self.check(proof=proof)["status"], "INVALID")

    def test_unsupported_inference(self):
        proof = copy.deepcopy(self.proof)
        proof["steps"].append({"id": "magic", "kind": "oracle", "conclusion": {"predicate": "development_approved", "args": ["project-001"]}})
        self.assertEqual(self.check(proof=proof)["status"], "INVALID")

    def test_missing_prerequisite(self):
        proof = copy.deepcopy(self.proof)
        proof["steps"] = [s for s in proof["steps"] if s["id"] != "fact:MAP-f1"]
        self.assertEqual(self.check(proof=proof)["status"], "INVALID")

    def test_source_change_impact_is_targeted(self):
        r = source_impact(self.case, self.proof, ["Z7"])
        self.assertEqual(r["affected_goals"], [{"predicate": "zoning_review_eligible", "args": ["project-001"]}])
        self.assertIn("rule:Z7-r1", r["affected_proof_steps"])
        self.assertNotIn("rule:F2-r1", r["affected_proof_steps"])

    def test_change_impact_conservative_with_alternative_witnesses(self):
        proof = copy.deepcopy(self.proof)
        original = next(s for s in proof["steps"] if s["id"] == "rule:Z7-r1")
        another = copy.deepcopy(original)
        another["id"] = "alternative:Z7"
        proof["steps"].append(another)
        affected = source_impact(self.case, proof, ["Z7"])["affected_goals"]
        self.assertEqual(affected, [{"predicate": "zoning_review_eligible", "args": ["project-001"]}])

    def test_rules_are_grounded_not_general_statutes(self):
        self.assertTrue(all(isinstance(r["conclusion"]["args"], list)
                            for s in self.case["sources"] for r in s["rules"]))

    def test_all_source_hashes_reproducible(self):
        for s in self.case["sources"]:
            self.assertEqual(hashlib.sha256(s["raw_text"].encode()).hexdigest(), s["content_sha256"])


if __name__ == "__main__":
    unittest.main()
