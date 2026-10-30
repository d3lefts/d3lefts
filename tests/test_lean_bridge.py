"""Unit tests for receipt logic only; not a substitute for real Lean compilation."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/lean_bridge.py"
spec = importlib.util.spec_from_file_location("lean_bridge", SCRIPT)
bridge = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bridge)


class BridgeTests(unittest.TestCase):
    def test_nested_comments_and_strings_not_flagged(self):
        text = 'def x := "sorry axiom"\n/- sorry /- native_decide -/ axiom -/\n-- partial\ntheorem t : True := by trivial\n'
        self.assertEqual(bridge.policy_findings(text), [])

    def test_untrusted_tokens_flagged_with_lines(self):
        self.assertEqual([(x["token"], x["line"]) for x in bridge.policy_findings("axiom h : True\nby sorry")],
                         [("axiom", 1), ("sorry", 2)])

    def test_diagnostic_parser(self):
        self.assertEqual(bridge.diagnostics("A.lean:3:8: error: unknown identifier 'x'\n")[0]["line"], 3)

    def test_missing_compiler_receipt(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "lean-toolchain").write_text("leanprover/lean4:v4.35.0\n")
            source = root / "Test.lean"
            source.write_text("theorem t : True := by trivial\n")
            receipt = bridge.check(source, root, [], 2, str(root / "absent-lean"))
            self.assertEqual(receipt["status"], "UNAVAILABLE")
            self.assertEqual(len(receipt["source_sha256"]), 64)

    def test_fake_compiler_protocol_only(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "lean-toolchain").write_text("leanprover/lean4:v4.35.0\n")
            fake = root / "fake-lean"
            fake.write_text("#!/usr/bin/env python3\nimport sys\nfrom pathlib import Path\nif '--version' in sys.argv: print('Lean (version 4.35.0, mock)')\nelse:\n p=Path(sys.argv[-1]).read_text()\n if 'FAIL' in p:\n  print(sys.argv[-1]+':1:1: error: test failure'); sys.exit(1)\n if '#print axioms Test.t' in p: print('Test.t does not depend on any axioms')\n")
            fake.chmod(0o755)
            source = root / "Test.lean"
            source.write_text("namespace Test\ntheorem t : True := by trivial\nend Test\n")
            result = bridge.check(source, root, ["Test.t"], 3, str(fake))
            self.assertEqual(result["status"], "COMPILED")
            self.assertEqual(result["axiom_audit"]["Test.t"], "none_reported")
            self.assertFalse(list(root.glob(".lean_bridge_*.lean")), "temporary source must be deleted")
            source.write_text("FAIL")
            self.assertEqual(bridge.check(source, root, [], 3, str(fake))["status"], "COMPILATION_FAILED")


if __name__ == "__main__":
    unittest.main()
