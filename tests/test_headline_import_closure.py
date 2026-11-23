#!/usr/bin/env python3
"""Mutation controls for conservative Lean import dependency guard."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

R = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("closure", R / "scripts/check_headline_import_closure.py")
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class ImportClosureTests(unittest.TestCase):
    def test_header_only(self):
        s = 'import A B\n\ntheorem t : True := by\n  let s := "/-"\n  trivial\nimport WrongBody\n'
        self.assertEqual(m.header_imports(s), ["A", "B"])

    def test_nested_comments_before_import(self):
        s = '/- preface /- nested -/ end -/\nimport Actual\nnamespace N\n'
        self.assertEqual(m.header_imports(s), ["Actual"])

    def test_local_change_requires_replay(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            parent = root / "research/nightfall/formalization"
            parent.mkdir(parents=True)
            (parent / "Entry.lean").write_text("import Helper\n")
            (parent / "Helper.lean").write_text("import Mathlib\n")
            a = "research/nightfall/formalization/Entry.lean"
            b = "research/nightfall/formalization/Helper.lean"
            c, unknown = m.closure(root, [a])
            self.assertEqual(c, {a, b})
            self.assertIn("Mathlib", unknown)
            manifest = {"records": [{"source": {"path": a}}]}
            self.assertEqual(m.validate(root, manifest, set())["status"], "NO_BRANCH_LOCAL_IMPORT_CLOSURE_DRIFT")
            with self.assertRaisesRegex(ValueError, "DEPENDENCY"):
                m.validate(root, manifest, {b})

    def test_toolchain_change_requires_replay(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            f = root / "Entry.lean"
            f.write_text("import Mathlib\n")
            manifest = {"records": [{"source": {"path": "Entry.lean"}}]}
            with self.assertRaisesRegex(ValueError, "TOOLCHAIN"):
                m.validate(root, manifest, {"lean-toolchain"})

    def test_ambiguous_basename_is_conservative(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            for p in ("A/Helper.lean", "B/Helper.lean"):
                t = root / p
                t.parent.mkdir(parents=True, exist_ok=True)
                t.write_text("import Mathlib\n")
            (root / "Entry.lean").write_text("import Helper\n")
            c, _ = m.closure(root, ["Entry.lean"])
            self.assertEqual(c, {"Entry.lean", "A/Helper.lean", "B/Helper.lean"})


if __name__ == "__main__":
    unittest.main()
