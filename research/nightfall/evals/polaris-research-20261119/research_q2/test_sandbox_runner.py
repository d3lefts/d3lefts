"""Offline checks of the isolated submission contract. Does NOT run Docker."""
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

from grade_research_q2 import BERNSTEIN, MATHLIB_COMMIT, LEAN_SOURCE_COMMIT, DECL, TOOLCHAIN, candidate_check
from sandbox_runner import (GRADER_REL, REQUIRED_FILES, docker_argv,
                            sealed_sources, evaluate, verify_grader_receipt)

REF = BERNSTEIN.parent / "ShiftedC4Scalar.lean"
DIGEST_IMAGE = "example.invalid/polaris-q2@sha256:" + "a" * 64


class SandboxContractTests(unittest.TestCase):
    def test_sealed_source_manifest_exactly_five_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            stage = Path(tmp) / "sealed"
            manifest = sealed_sources(REF, stage)
            self.assertEqual(set(manifest["source_files"]), REQUIRED_FILES)
            self.assertEqual(set(str(x.relative_to(stage)) for x in stage.rglob("*") if x.is_file()),
                             REQUIRED_FILES)
            self.assertFalse((stage / "research/nightfall/formalization/observability/ShiftedC4Scalar.lean").exists())
            self.assertEqual(manifest["candidate_sha256"], candidate_check(REF))
            self.assertFalse(manifest["reference_solution_preloaded"])
            self.assertTrue(manifest["candidate_matches_public_reference"])
            self.assertEqual(manifest["mathlib_commit"], MATHLIB_COMMIT)

    def test_stage_refuses_extra_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            stage = Path(tmp)
            (stage / "unrelated").write_text("fail")
            with self.assertRaisesRegex(ValueError, "stage must be initially empty"):
                sealed_sources(REF, stage)

    def test_stage_refuses_symlink_candidate(self):
        with tempfile.TemporaryDirectory() as tmp:
            candidate = Path(tmp) / "candidate.lean"
            candidate.symlink_to(REF)
            with self.assertRaisesRegex(Exception, "symlink"):
                sealed_sources(candidate, Path(tmp) / "stage")

    def test_container_contract_includes_security_flags(self):
        args = docker_argv(DIGEST_IMAGE, Path("/var/tmp/task"), Path("/var/tmp/receipt"))
        def pair(a,b):
            self.assertIn(a, args)
            self.assertIn(b, args)
        pair("--network", "none")
        pair("--read-only", "--cap-drop")
        pair("--security-opt", "no-new-privileges")
        pair("--user", "10001:10001")
        pair("--pids-limit", "256")
        pair("--memory", "8g")
        pair("--cpus", "2")
        self.assertIn("--tmpfs", args)
        self.assertIn("type=bind,src=/var/tmp/task,dst=/task,readonly", args)
        self.assertNotIn("type=bind,src=/var/tmp/receipt,dst=/results", args)
        self.assertIn(DIGEST_IMAGE, args)
        self.assertIn("cp -r /opt/mathlib4 /tmp/mathlib4;", args[-1])
        self.assertIn(GRADER_REL, args[-1])

    def test_unpinned_image_rejected(self):
        for image in ("latest", "image:latest", "example/q2@sha256:bad",
                      "example/q2@sha256:" + "b"*63):
            with self.subTest(image=image):
                with self.assertRaisesRegex(ValueError, "pinned"):
                    docker_argv(image, Path("/tmp/task"), Path("/tmp/out"))

    def test_relative_mount_rejected(self):
        with self.assertRaisesRegex(ValueError, "absolute"):
            docker_argv(DIGEST_IMAGE, Path("relative"), Path("/tmp/out"))

    def test_no_docker_fails_closed(self):
        with mock.patch("sandbox_runner.shutil.which", return_value=None):
            with self.assertRaisesRegex(RuntimeError, "untrusted evaluation refused"):
                evaluate(REF, DIGEST_IMAGE, Path("/tmp/no-output"))

    def test_no_image_digest_fails_before_docker(self):
        with self.assertRaisesRegex(ValueError, "digest"):
            evaluate(REF, "polaris-q2:latest", Path("/tmp/no-output"))

    def test_image_recipe_pins_compiler_mathlib_and_nonroot_user(self):
        recipe = (Path(__file__).with_name("Dockerfile")).read_text()
        self.assertIn("b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a", recipe)
        self.assertIn(MATHLIB_COMMIT, recipe)
        self.assertIn("USER 10001:10001", recipe)
        self.assertIn("lake exe cache get", recipe)
        self.assertNotIn("COPY . ", recipe)

    def test_no_candidate_reference_repo_mount(self):
        args = docker_argv(DIGEST_IMAGE, Path("/var/tmp/input"), Path("/var/tmp/output"))
        mounts = [args[i+1] for i, v in enumerate(args) if v == "--mount"]
        self.assertEqual(mounts, ["type=bind,src=/var/tmp/input,dst=/task,readonly"])
        self.assertNotIn("/var/tmp/output", " ".join(mounts))
        self.assertTrue(any("src=/var/tmp/input" in m for m in mounts))
        self.assertTrue(any("readonly" in m for m in mounts))


def synthetic_positive_receipt(manifest):
    """Schema fixture only. NOT evidence that Lean commands executed."""
    lake="/opt/elan/bin/lake"
    out="/tmp/mathlib4/.lake/build/lib/lean/"
    argv = [
        [lake,"env","lean","--version"],
        [lake,"env","lean","-o",out+"ShiftedC4Bernstein.olean","ShiftedC4Bernstein.lean"],
        [lake,"env","lean","-o",out+"ShiftedC4Scalar.olean","ShiftedC4Scalar.lean"],
        [lake,"env","lean","-o",out+"NightfallPolarisQ2Target.olean","NightfallPolarisQ2Target.lean"],
        [lake,"env","lean","NightfallPolarisQ2Audit.lean"],
        [lake,"env","leanchecker","NightfallPolarisQ2Target"],
    ]
    return {
        "schema": "nightfall.polaris.research-q2.v1",
        "status": "pass",
        "benchmark_status": "unscored-development-calibration",
        "certification": "pinned-Lean-kernel-replay; not externally audited",
        "independent_implementation_review": False,
        "target": DECL, "pin": TOOLCHAIN,
        "candidate_sha256": manifest["candidate_sha256"],
        "mathlib_commit": MATHLIB_COMMIT, "lean_source_commit": LEAN_SOURCE_COMMIT,
        "lake_binary_sha256": "f"*64, "limits": "synthetic schema test only",
        "trusted_sources": {
            "ShiftedC4Bernstein.lean": {"sha256": manifest["source_files"]["research/nightfall/formalization/observability/ShiftedC4Bernstein.lean"]},
            "NightfallPolarisQ2Target.lean": {"sha256": manifest["source_files"]["research/nightfall/evals/polaris-research-20261119/research_q2/NightfallPolarisQ2Target.lean"]},
        },
        "axioms": ["propext", "Classical.choice", "Quot.sound"],
        "steps": [{"argv": a, "exit_code": 0, "output_sha256": "a"*64} for a in argv],
    }


class SandboxReceiptTests(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.manifest = sealed_sources(REF, Path(self.folder.name) / "sealed")
        self.ok = synthetic_positive_receipt(self.manifest)

    def test_complete_synthetic_schema_accepted_only_as_schema(self):
        verify_grader_receipt(self.ok, self.manifest)

    def test_missing_kernel_replay_fails(self):
        self.ok["steps"].pop()
        with self.assertRaisesRegex(RuntimeError, "incomplete"):
            verify_grader_receipt(self.ok, self.manifest)

    def test_forged_theorem_name_fails(self):
        self.ok["target"] = "Nightfall.Polaris.ResearchQ2.easy"
        with self.assertRaisesRegex(RuntimeError, "target"):
            verify_grader_receipt(self.ok, self.manifest)

    def test_forged_axiom_fails(self):
        self.ok["axioms"].append("Nightfall.falseAxiom")
        with self.assertRaisesRegex(RuntimeError, "axiom"):
            verify_grader_receipt(self.ok, self.manifest)

    def test_wrong_candidate_digest_fails(self):
        self.ok["candidate_sha256"] = "0" * 64
        with self.assertRaisesRegex(RuntimeError, "candidate"):
            verify_grader_receipt(self.ok, self.manifest)

    def test_wrong_mathlib_commit_fails(self):
        self.ok["mathlib_commit"] = "0" * 40
        with self.assertRaisesRegex(RuntimeError, "compiler/Mathlib"):
            verify_grader_receipt(self.ok, self.manifest)

    def test_unverified_success_step_fails(self):
        self.ok["steps"][5]["exit_code"] = 1
        with self.assertRaisesRegex(RuntimeError, "failed proof step"):
            verify_grader_receipt(self.ok, self.manifest)

    def test_invalid_proof_output_hash_fails(self):
        self.ok["steps"][2]["output_sha256"] = "not-a-hash"
        with self.assertRaisesRegex(RuntimeError, "hash"):
            verify_grader_receipt(self.ok, self.manifest)

    def test_extra_model_success_claim_is_rejected(self):
        self.ok["frontier_success_rate"] = 1.0
        with self.assertRaisesRegex(RuntimeError, "receipt fields"):
            verify_grader_receipt(self.ok, self.manifest)

    def test_model_score_cannot_be_injected(self):
        self.ok["benchmark_status"] = "certified-frontier-solver"
        with self.assertRaisesRegex(RuntimeError, "unexpectedly scored"):
            verify_grader_receipt(self.ok, self.manifest)


if __name__ == "__main__":
    unittest.main()
