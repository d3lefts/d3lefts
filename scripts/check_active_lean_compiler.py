#!/usr/bin/env python3
"""Fail-closed active Lean 4.36 CI check; original historical receipts untouched.

Read version and source commits from the authoritative lock, not from
literal repetitions in the shared installer. This is a metadata audit,
not a compiler or theorem proof check.
"""
from __future__ import annotations

import json
from pathlib import Path
import tempfile
import sys

ROOT = Path(__file__).resolve().parents[1]
ACTIVE_COMPILER = "leanprover/lean4:v4.36.0-rc2"
FORBIDDEN = (
    "leanprover/lean4:v4.33.0",
    "leanprover/lean4:v4.35.0",
    "physical-superintelligence/aaronson-ambainis",
    "/tmp/aa/",
    "--branch v4.35.0",
)


def audit(root: Path) -> int:
    lock = json.loads((root / "docs/lean-compiler-lock.json").read_text())
    assert lock["schema"] == "nightfall-lean-compiler-lock/v1"
    assert lock["toolchain"] == ACTIVE_COMPILER, "Active 4.36 policy changed"
    toolchain = (root / "lean-toolchain").read_text().strip()
    assert toolchain == lock["toolchain"], f"Unexpected active toolchain: {toolchain}"
    assert len(lock["lean_source_commit"]) == len(lock["mathlib_commit"]) == 40
    setup = (root / ".github/actions/setup-nightfall-lean/action.yml").read_text()
    for token in ("docs/lean-compiler-lock.json", "NIGHTFALL_LEAN_TOOLCHAIN",
                  "NIGHTFALL_LEAN_COMMIT", "NIGHTFALL_MATHLIB_COMMIT",
                  "check_nightfall_compiler_lock.py"):
        assert token in setup, f"Shared installer does not consume/verify lock: {token}"
    workflows = sorted((root / ".github/workflows").glob("*.yml"))
    assert workflows, "No active workflows found"
    for workflow in workflows:
        text = workflow.read_text()
        for forbidden in FORBIDDEN:
            assert forbidden not in text, f"Retired dependency or compiler in {workflow}: {forbidden}"
    return len(workflows)


def self_test() -> None:
    with tempfile.TemporaryDirectory() as folder:
        root = Path(folder)
        (root / ".github/actions/setup-nightfall-lean").mkdir(parents=True)
        (root / ".github/workflows").mkdir(parents=True)
        (root / "docs").mkdir()
        lock = {
            "schema": "nightfall-lean-compiler-lock/v1",
            "toolchain": ACTIVE_COMPILER,
            "lean_source_commit": "a" * 40,
            "mathlib_commit": "b" * 40,
        }
        (root / "docs/lean-compiler-lock.json").write_text(json.dumps(lock))
        (root / "lean-toolchain").write_text(ACTIVE_COMPILER + "\n")
        (root / ".github/actions/setup-nightfall-lean/action.yml").write_text(
            "docs/lean-compiler-lock.json NIGHTFALL_LEAN_TOOLCHAIN "
            "NIGHTFALL_LEAN_COMMIT NIGHTFALL_MATHLIB_COMMIT "
            "check_nightfall_compiler_lock.py"
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
        (root / "lean-toolchain").write_text(ACTIVE_COMPILER + "\n")
        lock["mathlib_commit"] = "c" * 40
        (root / "docs/lean-compiler-lock.json").write_text(json.dumps(lock))
        assert audit(root) == 1  # only the lock controls the source revision
        (root / ".github/actions/setup-nightfall-lean/action.yml").write_text(
            "leanprover/lean4:v4.36.0-rc2 b" * 40)
        try:
            audit(root)
        except AssertionError:
            pass
        else:
            raise AssertionError("Installer bypassing the lock was accepted")
    print("PASS: eight fail-closed toolchain, installer and retired-workflow controls")


if __name__ == "__main__":
    if "--self-test" in sys.argv[1:]:
        self_test()
    count = audit(ROOT)
    print(f"PASS: {count} active workflow files audited against canonical Lean 4.36 lock")
