#!/usr/bin/env python3
"""Fail-closed, no-compiler required audit of active NIGHTFALL Lean CI pins.

This checks active GitHub Actions workflows only. Existing archived sources,
historical version labels in receipts, and retired proof claims are untouched.
A passing audit is NOT Lean compilation or theorem certification.
"""
from __future__ import annotations

from pathlib import Path
import tempfile
import sys

ROOT = Path(__file__).resolve().parents[1]
COMPILER = "leanprover/lean4:v4.36.0-rc2"
COMPILER_SHA = "b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a"
MATHLIB_SHA = "9d581dfff2e41de989072ea63abf3daf69311520"
FORBIDDEN = (
    "leanprover/lean4:v4.33.0",
    "leanprover/lean4:v4.35.0",
    "physical-superintelligence/aaronson-ambainis",
    "/tmp/aa/",
    "--branch v4.35.0",
)


def audit(root: Path) -> int:
    toolchain = (root / "lean-toolchain").read_text().strip()
    assert toolchain == COMPILER, f"Unexpected active toolchain: {toolchain}"
    setup = (root / ".github/actions/setup-nightfall-lean/action.yml").read_text()
    for token in (COMPILER, COMPILER_SHA, MATHLIB_SHA):
        assert token in setup, f"Missing exact compiler/dependency pin: {token}"
    workflows = sorted((root / ".github/workflows").glob("*.yml"))
    assert workflows, "No active workflows found"
    for workflow in workflows:
        source = workflow.read_text()
        for forbidden in FORBIDDEN:
            assert forbidden not in source, f"Retired dependency or compiler in {workflow}: {forbidden}"
    return len(workflows)


def self_test() -> None:
    with tempfile.TemporaryDirectory() as folder:
        root = Path(folder)
        (root / ".github/actions/setup-nightfall-lean").mkdir(parents=True)
        (root / ".github/workflows").mkdir(parents=True)
        (root / "lean-toolchain").write_text(COMPILER + "\n")
        (root / ".github/actions/setup-nightfall-lean/action.yml").write_text(
            COMPILER + " " + COMPILER_SHA + " " + MATHLIB_SHA
        )
        workflow = root / ".github/workflows/test.yml"
        workflow.write_text("name: Independent scoped kernel check\n")
        assert audit(root) == 1
        for bad in FORBIDDEN:
            workflow.write_text("name: bad\n# " + bad + "\n")
            try:
                audit(root)
            except AssertionError:
                pass
            else:
                raise AssertionError("Missing negative-control detection: " + bad)
        workflow.write_text("name: scoped check\n")
        (root / "lean-toolchain").write_text("leanprover/lean4:v4.36.0\n")
        try:
            audit(root)
        except AssertionError:
            pass
        else:
            raise AssertionError("Stable/release-candidate mismatch accepted")
    print("PASS: six fail-closed toolchain and retired-workflow negative controls")


if __name__ == "__main__":
    if "--self-test" in sys.argv[1:]:
        self_test()
    count = audit(ROOT)
    print(f"PASS: {count} active CI workflows audited for exact Lean 4.36.0-rc2 and Mathlib pins")
