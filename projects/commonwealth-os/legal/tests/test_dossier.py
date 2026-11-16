"""Negative-case dossier controls: no voting or political profile persistence."""
import json
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from dossier import assemble, DossierError


class DossierTests(unittest.TestCase):
    def setUp(self):
        self.path = ROOT / "fixtures" / "riverfront_dossier.json"
        self.example = json.loads(self.path.read_text(encoding="utf-8"))

    def test_assembly_replays_both_checkers(self):
        result = assemble(self.path)
        self.assertEqual(result["proof_status"], "SUPPORTED_IN_FICTIONAL_MODEL")
        self.assertEqual(result["mode"], "DEMO_ADVISORY_NO_VOTE")
        self.assertEqual(result["decision_authority"], "NOT_ESTABLISHED")
        self.assertTrue(all(v is False for v in result["privacy_contract"].values()))
        self.assertEqual(len(result["source_dependencies"]), 4)
        self.assertEqual(len(result["source_library"]), 4)
        self.assertEqual(len(result["legal_derivation"]["proof"]), 4)
        self.assertIn("FICTIONAL", result["source_disclosure"])

    def test_real_mode_is_rejected(self):
        self.example["mode"] = "OFFICIAL"
        self.assert_invalid_dossier()

    def test_no_implicit_profile_collection(self):
        self.example["privacy_contract"]["infer_profile"] = True
        self.assert_invalid_dossier()

    def test_no_ballot_cast(self):
        self.example["privacy_contract"]["cast_ballot"] = True
        self.assert_invalid_dossier()

    def test_missing_evidence_categories_fail(self):
        self.example["evidence_sections"].pop()
        self.assert_invalid_dossier()

    def test_truthfulness_status_cannot_be_promoted(self):
        self.example["evidence_sections"][1]["status"] = "VERIFIED"
        self.assert_invalid_dossier()

    def test_disallowed_proof_path(self):
        self.example["legal_passport"] = "../some-other-proof.json"
        self.assert_invalid_dossier()

    def test_incomplete_response_options_fail(self):
        self.example["response_choices"].remove("NEED_MORE_INFORMATION")
        self.assert_invalid_dossier()

    def assert_invalid_dossier(self):
        # Preserve the valid fictional proof file beside the modified dossier.
        with tempfile.TemporaryDirectory() as tmp:
            folder = Path(tmp)
            (folder / "riverfront_passport.json").write_text(
                (ROOT / "fixtures" / "riverfront_passport.json").read_text(encoding="utf-8"),
                encoding="utf-8")
            candidate = folder / "riverfront_dossier.json"
            candidate.write_text(json.dumps(self.example), encoding="utf-8")
            with self.assertRaises(DossierError):
                assemble(candidate)


if __name__ == "__main__":
    unittest.main()
