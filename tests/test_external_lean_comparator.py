#!/usr/bin/env python3
"""Negative controls for frozen Lean contract comparator; no compiler required."""
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path

path = Path(__file__).resolve().parents[1] / "scripts/external_lean_comparator.py"
spec = importlib.util.spec_from_file_location("external_comparator", path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class ComparatorTests(unittest.TestCase):
    def setUp(self):
        self.source = b"theorem sample : True := trivial\n"
        self.contract = json.dumps({"schema": "nightfall-theorem-contract/v1",
            "source": "sample.lean", "targets": [
                {"declaration": "sample", "expected_type": "True"}]}).encode()
        self.receipt = {
            "status": "COMPILED", "version_matches_pin": True,
            "source_relpath": "sample.lean",
            "source_sha256": hashlib.sha256(self.source).hexdigest(),
            "contract_sha256": hashlib.sha256(self.contract).hexdigest(),
            "declarations_requested": ["sample"], "contract_targets": ["sample"],
            "policy_findings": [], "explicit_allowed_axioms": ["propext"],
            "axiom_audit": {"sample": "none_reported"},
            "axiom_dependencies": {"sample": []}}

    def test_valid_receipt(self):
        self.assertEqual(module.validate(self.contract, self.contract, self.receipt, self.source)["status"],
                         "FROZEN_CONTRACT_MATCH")

    def rejects(self, changed_contract=None, changed_source=None):
        with self.assertRaises(ValueError):
            module.validate(self.contract, changed_contract if changed_contract is not None else self.contract,
                            self.receipt, changed_source if changed_source is not None else self.source)

    def test_mutated_contract(self):
        self.rejects(changed_contract=self.contract + b" ")

    def test_changed_source(self):
        self.rejects(changed_source=self.source + b"\n")

    def test_unauthorized_axiom(self):
        self.receipt["axiom_audit"]["sample"] = "dependencies_reported"
        self.receipt["axiom_dependencies"]["sample"] = ["new_axiom"]
        self.rejects()

    def test_allowlist_drift(self):
        self.receipt["explicit_allowed_axioms"] = ["untrusted"]
        self.rejects()

    def test_missing_target(self):
        self.receipt["contract_targets"] = []
        self.rejects()

    def test_failed_compile(self):
        self.receipt["status"] = "COMPILATION_FAILED"
        self.rejects()

    def test_untrusted_token(self):
        self.receipt["policy_findings"] = [{"token": "sorry"}]
        self.rejects()

    def test_toolchain_drift(self):
        self.receipt["version_matches_pin"] = False
        self.rejects()

if __name__ == "__main__":
    unittest.main()
