#!/usr/bin/env python3
"""Adversarial regression tests for maintained 4.36 Lean workflow consistency."""
from __future__ import annotations

import importlib.util
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("audit_lean436",
                                              ROOT / "scripts/audit_active_lean_436.py")
scanner = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(scanner)


class ActiveLean436Test(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        needed = list(scanner.ACTIVE) + [
            "lean-toolchain", "docs/lean-compiler-lock.json",
            "scripts/generate_nightfall_lake.py",
        ]
        for relative in needed:
            dst = self.root / relative
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / relative, dst)

    def change(self, filename, content):
        path = self.root / filename
        path.write_text(content, encoding="utf-8")

    def test_active_policy_passes(self):
        result = scanner.audit(self.root)
        self.assertEqual(len(result["active_checked"]), len(scanner.ACTIVE))
        self.assertEqual(result["historical_noncanonical"], [])

    def test_old_compiler_tag_fails(self):
        filename = scanner.ACTIVE[2]
        original = (self.root / filename).read_text("utf-8")
        self.change(filename, original + "\n# leanprover/lean4:v4.35.0\n")
        with self.assertRaisesRegex(ValueError, "unexpected Lean versions"):
            scanner.audit(self.root)

    def test_missing_shared_compiler_setup_fails(self):
        filename = scanner.ACTIVE[1]
        original = (self.root / filename).read_text("utf-8")
        self.change(filename, original.replace(
            "uses: ./.github/actions/setup-nightfall-lean", "uses: actions/checkout@v4"))
        with self.assertRaisesRegex(ValueError, "compiler action bypass"):
            scanner.audit(self.root)

    def test_generator_must_use_lock(self):
        filename = "scripts/generate_nightfall_lake.py"
        original = (self.root / filename).read_text("utf-8")
        self.change(filename, original.replace("locked_mathlib_commit()", "old_constant()"))
        with self.assertRaisesRegex(ValueError, "Lake generator"):
            scanner.audit(self.root)

    def test_historical_version_is_reported_not_promoted(self):
        legacy = self.root / ".github/workflows/historical-old-test.yml"
        legacy.write_text("name: old\n# leanprover/lean4:v4.35.0\n")
        report = scanner.audit(self.root)
        self.assertEqual(report["historical_noncanonical"],
                         [{"path": ".github/workflows/historical-old-test.yml",
                           "toolchain": "leanprover/lean4:v4.35.0"}])


if __name__ == "__main__":
    unittest.main(verbosity=2)
