#!/usr/bin/env python3
"""Audit maintained NIGHTFALL Lean CI on the exact 4.36 lock.

Historical workflows are inventoried (not silently rewritten/certified).
This is a configuration audit, NOT an end-to-end theorem replay.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACTIVE = (
    ".github/actions/setup-nightfall-lean/action.yml",
    ".github/workflows/nightfall-integrated-lake.yml",
    ".github/workflows/commonwealth-assurance-lean.yml",
    ".github/workflows/nightfall-compiler-lock.yml",
    ".github/workflows/nightfall-active-passports.yml",
    ".github/workflows/nightfall-lean-receipts-v16.yml",
)
RE_COMMIT = re.compile(r"\b[0-9a-f]{40}\b")
RE_TOOLCHAIN = re.compile(r"leanprover/lean4:v\d+\.\d+\.\d+(?:-(?:rc|beta|alpha)\d+)?")
RE_PRIOR_PIN = re.compile(r"\bv4\.(?:3[0-5])(?:\.\d+)?(?:-(?:rc|beta|alpha)\d+)?\b")


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)


def audit(root: Path) -> dict:
    root = root.resolve()
    lock = json.loads((root / "docs/lean-compiler-lock.json").read_text("utf-8"))
    toolchain = lock["toolchain"]
    require(toolchain == (root / "lean-toolchain").read_text("utf-8").strip(),
            "root toolchain differs from active compiler lock")
    require(toolchain == "leanprover/lean4:v4.36.0-rc2",
            "active workflow policy must be explicitly re-reviewed for new compiler")
    files_checked = []
    for relative in ACTIVE:
        file = root / relative
        require(file.is_file(), "missing active entry point " + relative)
        source = file.read_text("utf-8")
        files_checked.append(relative)
        mismatches = sorted(set(RE_TOOLCHAIN.findall(source)) - {toolchain})
        require(not mismatches, relative + ": unexpected Lean versions " + str(mismatches))
        require(not RE_PRIOR_PIN.search(source),
                relative + ": old toolchain tag in maintained active configuration")
        # A workflow doing real compilation must use the centrally verified
        # installer rather than invoking an unrelated compiler from PATH.
        if relative.startswith(".github/workflows/") and (
            "scripts/lean_bridge.py" in source or "lake build Nightfall" in source
            or "lake check" in source
        ):
            require("uses: ./.github/actions/setup-nightfall-lean" in source,
                    relative + ": compiler action bypass")
    action = (root / ACTIVE[0]).read_text("utf-8")
    require("docs/lean-compiler-lock.json" in action and
            "NIGHTFALL_LEAN_TOOLCHAIN" in action and
            "NIGHTFALL_MATHLIB_COMMIT" in action,
            "shared compiler setup does not derive toolchain and Mathlib from lock")
    require("scripts/check_nightfall_compiler_lock.py" in action,
            "shared compiler setup lacks independent source identity audit")
    lake = (root / ACTIVE[1]).read_text("utf-8")
    for command in ("scripts/generate_nightfall_lake.py --check",
                    "lake build Nightfall", "lake check",
                    "--installed-mathlib .lake/packages/mathlib"):
        require(command in lake, "integrated 4.36 workflow missing " + command)
    generator = (root / "scripts/generate_nightfall_lake.py").read_text("utf-8")
    require("locked_mathlib_commit()" in generator and
            'docs/lean-compiler-lock.json' in generator,
            "Lake generator does not consume active compiler lock")
    # Report other workflow files with explicit older versions. These
    # are *not* automatically migrated: compile them before reclassifying.
    historical = []
    folder = root / ".github/workflows"
    for file in sorted(folder.glob("*.yml")):
        if file.relative_to(root).as_posix() in ACTIVE:
            continue
        for found in sorted(set(RE_TOOLCHAIN.findall(file.read_text("utf-8")))):
            if found != toolchain:
                historical.append({"path": file.relative_to(root).as_posix(),
                                   "toolchain": found})
    return {"compiler": toolchain, "mathlib_commit": lock["mathlib_commit"],
            "active_checked": files_checked, "historical_noncanonical": historical,
            "conclusion": "active_4_36_config_consistent_only"}


def main() -> int:
    try:
        result = audit(ROOT)
        print(json.dumps(result, indent=2))
        return 0
    except (ValueError, OSError, KeyError, json.JSONDecodeError) as e:
        print("FAIL active Lean 4.36 configuration: " + str(e), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
