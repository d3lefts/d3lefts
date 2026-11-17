#!/usr/bin/env python3
"""Fail-closed Lean/Mathlib compiler-lock audit.

Checks pin agreement and, in CI, the *actual installed* toolchain and
Mathlib Git object. Does NOT execute kernel proof checks or certify claims.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import tomllib
from pathlib import Path

LOCK = "docs/lean-compiler-lock.json"
RECEIPTS = "docs/current-lean-proof-receipts-20261116.json"
OVERLAY = "docs/lean-proof-passport-overlay.json"
CONTRACT = "projects/commonwealth-os/assurance/lean/passport-contract.json"
SHA40 = re.compile(r"[a-f0-9]{40}\Z")
ALLOWED = {"propext", "Classical.choice", "Quot.sound"}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def load_json(root: Path, path: str) -> dict:
    return json.loads((root / path).read_text(encoding="utf-8"))


def audit_checkout(root: Path) -> dict:
    root = root.resolve()
    lock = load_json(root, LOCK)
    require(lock.get("schema") == "nightfall-lean-compiler-lock/v1", "unknown lock schema")
    version = lock.get("toolchain")
    require(isinstance(version, str) and re.fullmatch(
        r"leanprover/lean4:v[0-9]+\.[0-9]+\.[0-9]+(?:-(?:rc|beta|alpha)[0-9]+)?",
        version), "invalid exact Lean toolchain")
    require(isinstance(lock.get("lean_source_commit"), str) and
            SHA40.fullmatch(lock["lean_source_commit"]), "invalid Lean source commit")
    require(isinstance(lock.get("mathlib_commit"), str) and
            SHA40.fullmatch(lock["mathlib_commit"]), "invalid Mathlib source commit")
    require(lock.get("mathlib_tag") == version.removeprefix("leanprover/lean4:"),
            "Mathlib tag disagrees with Lean version")
    require(set(lock.get("allowed_axioms", [])) == ALLOWED,
            "lock must allow exactly Lean foundational axioms")
    require((root / "lean-toolchain").read_text(encoding="utf-8").strip() == version,
            "root lean-toolchain disagrees with compiler lock")
    receipts = load_json(root, RECEIPTS)
    require(receipts["pin"]["lean"] == version, "receipt compiler pin drift")
    require(receipts["pin"]["mathlib_commit"] == lock["mathlib_commit"],
            "receipt Mathlib pin drift")
    require(set(receipts["pin"]["allowed_axioms"]) == ALLOWED,
            "receipt allowlisted axioms drift")
    contract = load_json(root, CONTRACT)
    require(contract.get("workspace_commit") == lock["mathlib_commit"],
            "Commonwealth theorem-contract Mathlib revision drift")
    overlay = root / OVERLAY
    if overlay.is_file():
        policy = load_json(root, OVERLAY)["policy"]
        require(policy["lean_pin"] == version, "Proof Passport Lean pin drift")
        require(policy["mathlib_commit"] == lock["mathlib_commit"],
                "Proof Passport Mathlib pin drift")
        require(set(policy["allowed_axioms"]) == ALLOWED,
                "Proof Passport axiom policy drift")
    lakefile = root / "lakefile.toml"
    if lakefile.is_file():
        lake = tomllib.loads(lakefile.read_text(encoding="utf-8"))
        mathlibs = [x for x in lake.get("require", []) if x.get("name") == "mathlib"]
        require(len(mathlibs) == 1 and mathlibs[0].get("rev") == lock["mathlib_commit"],
                "Lake dependency is not exactly locked")
    return lock


def audit_installed(mathlib: Path, version: str, commit: str,
                    lean_commit: str, version_output: str) -> None:
    require(mathlib.is_dir(), "pinned Mathlib checkout unavailable")
    actual = subprocess.run(["git", "-C", str(mathlib), "rev-parse", "HEAD"],
                            text=True, capture_output=True, check=True).stdout.strip()
    require(actual == commit, "installed Mathlib HEAD differs from lock")
    require((mathlib / "lean-toolchain").read_text().strip() == version,
            "installed Mathlib Lean toolchain differs from lock")
    tag = version.removeprefix("leanprover/lean4:v")
    require(bool(re.search(r"\bversion\s+" + re.escape(tag) + r"\b",
                           version_output, re.I)), "installed Lean version differs from lock")
    require(lean_commit in version_output,
            "installed Lean Git source commit differs from lock")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--checkout", type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--installed-mathlib", type=Path)
    parser.add_argument("--lean-version-file", type=Path)
    args = parser.parse_args(argv)
    try:
        lock = audit_checkout(args.checkout)
        if (args.installed_mathlib is None) != (args.lean_version_file is None):
            raise ValueError("both --installed-mathlib and --lean-version-file are required")
        if args.installed_mathlib:
            audit_installed(args.installed_mathlib, lock["toolchain"],
                            lock["mathlib_commit"], lock["lean_source_commit"],
                            args.lean_version_file.read_text(encoding="utf-8"))
        print("PASS: exact NIGHTFALL Lean/Mathlib compiler lock and "+(
            "installed Git source revision" if args.installed_mathlib else "cross-registry pins"))
        return 0
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError,
            tomllib.TOMLDecodeError) as exc:
        print("FAIL: compiler lock: " + str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
