"""Offline checks of the isolated submission contract. Does NOT run Docker."""
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

from grade_research_q2 import BERNSTEIN, MATHLIB_COMMIT, candidate_check
from sandbox_runner import (GRADER_REL, REQUIRED_FILES, docker_argv,
                            sealed_sources, evaluate)

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


if __name__ == "__main__":
    unittest.main()
