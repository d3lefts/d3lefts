"""Offline verifier preflight tests. No mathematical proof is certified by this file."""
import tempfile
from pathlib import Path
import unittest

from grade_research_q2 import (
    ALLOW_AXIOMS, BERNSTEIN, TARGET, GradingError, LEAN_SOURCE_COMMIT,
    axioms_from_output, candidate_check, check_compiler_identity, verify_trusted,
)


class ResearchQ2PreflightTests(unittest.TestCase):
    def test_both_trusted_source_blobs(self):
        checked = verify_trusted()
        self.assertEqual(len(checked), 2)
        self.assertIn("ShiftedC4Bernstein.lean", checked)
        self.assertIn("NightfallPolarisQ2Target.lean", checked)

    def test_reference_proof_is_a_positive_preflight(self):
        original = (BERNSTEIN.parent / "ShiftedC4Scalar.lean")
        self.assertEqual(len(candidate_check(original)), 64)

    def test_lexical_bypass_sorry(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / "proof.lean"
            p.write_text("import ShiftedC4Bernstein\n theorem fake : True := by sorry\n")
            with self.assertRaisesRegex(GradingError, "forbidden"):
                candidate_check(p)

    def test_lexical_bypass_axiom(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / "proof.lean"
            p.write_text("import ShiftedC4Bernstein\naxiom falseProof : False\n")
            with self.assertRaisesRegex(GradingError, "forbidden"):
                candidate_check(p)

    def test_missing_candidate(self):
        with self.assertRaisesRegex(GradingError, "missing"):
            candidate_check(Path("/definitely/missing/NightfallQ2Candidate.lean"))

    def test_wrong_import(self):
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp) / "proof.lean"
            p.write_text("import Mathlib\n")
            with self.assertRaisesRegex(GradingError, "import trusted"):
                candidate_check(p)

    def test_unexpected_axioms(self):
        with self.assertRaisesRegex(GradingError, "nonstandard"):
            axioms_from_output(
                "'Nightfall.Polaris.ResearchQ2.locked_shifted_c4_interpolation' depends on axioms: [Nightfall.NewAxiom]"
            )

    def test_duplicate_axiom_report(self):
        s = "'Nightfall.Polaris.ResearchQ2.locked_shifted_c4_interpolation' does not depend on any axioms\n"
        with self.assertRaisesRegex(GradingError, "missing or duplicated"):
            axioms_from_output(s+s)

    def test_missing_axiom_report(self):
        with self.assertRaisesRegex(GradingError, "missing or duplicated"):
            axioms_from_output("no theorem")

    def test_axiom_report_positive(self):
        s = "'Nightfall.Polaris.ResearchQ2.locked_shifted_c4_interpolation' depends on axioms: [propext, Classical.choice]"
        self.assertEqual(axioms_from_output(s), ["Classical.choice", "propext"])

    def test_locked_target_binds_original_lemma(self):
        text = TARGET.read_text(encoding="utf-8")
        self.assertIn("shifted_c4_from_strong_moments", text)
        self.assertIn("Real.sqrt e ≤ Real.sqrt 3*u+c/4", text)

    def test_real_lean_compiler_identity_is_accepted(self):
        check_compiler_identity(
            "Lean (version 4.36.0-rc2, x86_64-unknown-linux-gnu, commit "
            + LEAN_SOURCE_COMMIT + ", Release)"
        )

    def test_modified_lean_source_commit_fails(self):
        with self.assertRaisesRegex(GradingError, "compiler"):
            check_compiler_identity(
                "Lean (version 4.36.0-rc2, x86_64, commit "
                + "0" * 40 + ", Release)"
            )

    def test_modified_lean_release_fails(self):
        with self.assertRaisesRegex(GradingError, "compiler"):
            check_compiler_identity(
                "Lean (version 4.35.0, x86_64, commit "
                + LEAN_SOURCE_COMMIT + ", Release)"
            )

    def test_allowlist_is_standard_only(self):
        self.assertEqual(ALLOW_AXIOMS, {"Classical.choice", "Quot.sound", "propext"})

    def test_bundle_omits_known_reference_solution(self):
        from prepare_agent_bundle import prepare
        with tempfile.TemporaryDirectory() as tmp:
            folder = Path(tmp) / "agent_input"
            manifest = prepare(folder)
            self.assertTrue(manifest["not_blind_or_uncontaminated"])
            self.assertIn("ShiftedC4Scalar.lean", manifest["editable_only"])
            stub = (folder / "ShiftedC4Scalar.lean").read_text()
            known_proof = (BERNSTEIN.parent / "ShiftedC4Scalar.lean").read_text()
            self.assertNotEqual(stub, known_proof)
            self.assertNotIn("have hmoment :", stub)
            self.assertFalse(any("ShiftedC4Scalar.lean" == p.name for p in
                                 folder.iterdir() if p.is_symlink()))
            self.assertTrue((folder / "INPUT_MANIFEST.json").is_file())

    def test_weakened_statement_survives_lexical_preflight(self):
        # Only Lean's frozen target catches the semantically invalid theorem.
        p = Path(__file__).parent / "examples/weakened_to_true.lean"
        self.assertEqual(len(candidate_check(p)), 64)


if __name__ == "__main__":
    unittest.main()
