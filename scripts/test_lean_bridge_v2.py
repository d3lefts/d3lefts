#!/usr/bin/env python3
"""Adversarial tests for Lean Bridge v2 (no Lean installation required).

The mocked compiler tests the bridge and receipt plumbing, NOT mathematical
proof validity. The workflow separately invokes the real pinned Lean compiler.
"""
import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import lean_bridge

ROOT = Path(__file__).resolve().parents[1]
import sys
sys.path.insert(0, str(ROOT / "research/nightfall/formalization/product_space"))
import check_receipts


class BridgeV2Test(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix=".lean-v2-test-", dir=ROOT)
        self.addCleanup(self.temp.cleanup)
        self.folder = Path(self.temp.name)
        self.workspace = self.folder / "workspace"
        self.workspace.mkdir()
        (self.workspace / "lean-toolchain").write_text("leanprover/lean4:v4.35.0\n")
        self.source = self.folder / "Fixture.lean"
        self.source.write_text("theorem Nightfall.Fixture.answer (n : Nat) : n = n := rfl\n")
        self.name = "Nightfall.Fixture.answer"
        self.statement = "∀ (n : Nat), n = n"
        self.contract = self.folder / "contract.json"
        self.contract.write_text(json.dumps({
            "schema": "nightfall-theorem-contract/v1",
            "source": self.source.relative_to(ROOT).as_posix(),
            "workspace_commit": "a" * 40,
            "targets": [{"declaration": self.name, "expected_type": self.statement}]
        }))
        self.lean_text = ""

    def mock_invoke(self, cmd, cwd, timeout):
        def result(out="", err="", code=0):
            return {"stdout": out, "stderr": err, "returncode": code, "timed_out": False}
        if cmd[0] == "git":
            return result("a" * 40 + "\n")
        if "--version" in cmd:
            return result("Lean (version 4.35.0, fake, commit " + "b" * 40 + ")\n")
        self.lean_text = Path(cmd[-1]).read_text()
        return result("'" + self.name + "' depends on axioms: [propext, Classical.choice, Quot.sound]\n")

    def run_bridge(self, contract=True):
        with patch.object(lean_bridge, "choose_compiler", return_value=["fakelean"]), \
             patch.object(lean_bridge, "invoke", side_effect=self.mock_invoke):
            return lean_bridge.check(
                self.source, self.workspace, [self.name], 5, None,
                {"propext", "Classical.choice", "Quot.sound"},
                self.contract if contract else None,
            )

    def test_exact_contract_injected_and_receipt_accepts(self):
        receipt = self.run_bridge()
        self.assertEqual(receipt["status"], "COMPILED")
        self.assertIn("example : " + self.statement, self.lean_text)
        self.assertIn("exact " + self.name, self.lean_text)
        self.assertEqual(receipt["workspace_commit"], "a" * 40)
        path = self.folder / "receipt.json"
        path.write_text(json.dumps(receipt))
        check_receipts.audit(path)

    def test_missing_workspace_pin_rejected(self):
        (self.workspace / "lean-toolchain").unlink()
        self.assertEqual(self.run_bridge(False)["status"], "TOOLCHAIN_MISMATCH")

    def test_wrong_toolchain_rejected(self):
        (self.workspace / "lean-toolchain").write_text("leanprover/lean4:v4.33.0")
        self.assertEqual(self.run_bridge()["status"], "TOOLCHAIN_MISMATCH")

    def test_invalid_contract_signature_rejected(self):
        c = json.loads(self.contract.read_text())
        c["targets"][0]["declaration"] = "Nightfall.Fixture.other"
        self.contract.write_text(json.dumps(c))
        with self.assertRaises(ValueError):
            self.run_bridge()

    def test_untrusted_contract_rejected(self):
        c = json.loads(self.contract.read_text())
        c["targets"][0]["expected_type"] = "True := by sorry"
        self.contract.write_text(json.dumps(c))
        with self.assertRaises(ValueError):
            self.run_bridge()

    def test_wrong_workspace_commit_rejected(self):
        c = json.loads(self.contract.read_text())
        c["workspace_commit"] = "c" * 40
        self.contract.write_text(json.dumps(c))
        self.assertEqual(self.run_bridge()["status"], "WORKSPACE_PIN_MISMATCH")

    def test_mutated_compiled_source_rejected(self):
        r = self.run_bridge()
        path = self.folder / "receipt.json"
        path.write_text(json.dumps(r))
        self.source.write_text(self.source.read_text() + "\n-- altered after compile\n")
        with self.assertRaisesRegex(ValueError, "contents differ"):
            check_receipts.audit(path)

    def test_mutated_contract_rejected(self):
        r = self.run_bridge()
        path = self.folder / "receipt.json"
        path.write_text(json.dumps(r))
        self.contract.write_text(self.contract.read_text() + "\n ")
        with self.assertRaisesRegex(ValueError, "contents differ"):
            check_receipts.audit(path)

    def test_unauthorized_axiom_rejected(self):
        r = self.run_bridge()
        r["stdout"] = r["stdout"].replace("Quot.sound", "sorryAx")
        r["axiom_dependencies"][self.name] = ["sorryAx"]
        path = self.folder / "receipt.json"
        path.write_text(json.dumps(r))
        with self.assertRaisesRegex(ValueError, "unauthorized axioms"):
            check_receipts.audit(path)

    def test_forged_axiom_metadata_rejected(self):
        r = self.run_bridge()
        r["axiom_dependencies"][self.name] = []
        path = self.folder / "receipt.json"
        path.write_text(json.dumps(r))
        with self.assertRaisesRegex(ValueError, "metadata disagrees"):
            check_receipts.audit(path)


if __name__ == "__main__":
    unittest.main(verbosity=2)
