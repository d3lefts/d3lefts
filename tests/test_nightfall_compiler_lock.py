#!/usr/bin/env python3
"""Adversarial regression tests for Lean compiler-lock attestation.

No Lean installation needed: test cross-registry tampering and independent
installed-binary/source-commit checks with a mock Git HEAD.
"""
from __future__ import annotations
import copy
import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "nightfall_lock", ROOT / "scripts/check_nightfall_compiler_lock.py")
lockcheck = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(lockcheck)

FIXTURES = [
    "lean-toolchain",
    "docs/lean-compiler-lock.json",
    "docs/current-lean-proof-receipts-20261116.json",
    "docs/lean-proof-passport-overlay.json",
    "projects/commonwealth-os/assurance/lean/passport-contract.json",
]


class CompilerLockTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        for filename in FIXTURES:
            dest = self.root / filename
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / filename, dest)

    def change(self, filename, mutate):
        path = self.root / filename
        obj = json.loads(path.read_text())
        mutate(obj)
        path.write_text(json.dumps(obj))

    def test_success(self):
        self.assertEqual(lockcheck.audit_checkout(self.root)["toolchain"],
                         "leanprover/lean4:v4.36.0-rc2")

    def test_root_toolchain_mismatch(self):
        (self.root / "lean-toolchain").write_text("leanprover/lean4:v4.35.0\n")
        with self.assertRaisesRegex(ValueError, "root lean-toolchain"):
            lockcheck.audit_checkout(self.root)

    def test_receipt_mathlib_pin_mismatch(self):
        self.change("docs/current-lean-proof-receipts-20261116.json",
                    lambda obj: obj["pin"].update(mathlib_commit="0"*40))
        with self.assertRaisesRegex(ValueError, "receipt Mathlib"):
            lockcheck.audit_checkout(self.root)

    def test_passport_pin_mismatch(self):
        self.change("docs/lean-proof-passport-overlay.json",
                    lambda obj: obj["policy"].update(lean_pin="leanprover/lean4:v4.35.0"))
        with self.assertRaisesRegex(ValueError, "Proof Passport Lean"):
            lockcheck.audit_checkout(self.root)

    def test_contract_pin_mismatch(self):
        self.change("projects/commonwealth-os/assurance/lean/passport-contract.json",
                    lambda obj: obj.update(workspace_commit="0"*40))
        with self.assertRaisesRegex(ValueError, "Commonwealth"):
            lockcheck.audit_checkout(self.root)

    def test_lake_dependency_pin_mismatch(self):
        (self.root / "lakefile.toml").write_text(
            'name = "nightfall"\n[[require]]\nname = "mathlib"\n'
            'rev = "' + "0"*40 + '"\n')
        with self.assertRaisesRegex(ValueError, "Lake dependency"):
            lockcheck.audit_checkout(self.root)

    def test_installed_compiler_and_git_revision(self):
        lock = lockcheck.audit_checkout(self.root)
        mathlib = self.root / "mathlib"
        mathlib.mkdir()
        (mathlib / "lean-toolchain").write_text(lock["toolchain"] + "\n")
        version = "(Lean (version 4.36.0-rc2, x86_64-unknown-linux-gnu, commit " + (
            lock["lean_source_commit"]) + "))"
        with patch.object(lockcheck.subprocess, "run",
                          return_value=SimpleNamespace(stdout=lock["mathlib_commit"]+"\n")):
            lockcheck.audit_installed(mathlib, lock["toolchain"], lock["mathlib_commit"],
                                      lock["lean_source_commit"], version)
            with self.assertRaisesRegex(ValueError, "Lean Git source"):
                lockcheck.audit_installed(mathlib, lock["toolchain"], lock["mathlib_commit"],
                                          lock["lean_source_commit"], version.replace(
                                              lock["lean_source_commit"], "a"*40))
            with self.assertRaisesRegex(ValueError, "Lean version"):
                lockcheck.audit_installed(mathlib, lock["toolchain"], lock["mathlib_commit"],
                                          lock["lean_source_commit"], version.replace(
                                              "version 4.36.0-rc2", "version 4.35.0"))
        with patch.object(lockcheck.subprocess, "run",
                          return_value=SimpleNamespace(stdout="0"*40+"\n")):
            with self.assertRaisesRegex(ValueError, "Mathlib HEAD"):
                lockcheck.audit_installed(mathlib, lock["toolchain"], lock["mathlib_commit"],
                                          lock["lean_source_commit"], version)


if __name__ == "__main__":
    unittest.main(verbosity=2)
