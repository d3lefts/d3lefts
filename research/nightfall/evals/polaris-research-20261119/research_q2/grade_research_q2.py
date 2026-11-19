#!/usr/bin/env python3
"""Research Q2 ProofGraph verifier: frozen target + trusted Bernstein source + candidate scalar proof.

Development harness only, not a sandbox. Untrusted Lean code MUST execute in an isolated VM.
A public reference is used exclusively for CI positive-control calibration.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
TOOLCHAIN = "leanprover/lean4:v4.36.0-rc2"
MATHLIB_COMMIT = "9d581dfff2e41de989072ea63abf3daf69311520"
LEAN_SOURCE_COMMIT = "b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a"
BERNSTEIN = ROOT / "research/nightfall/formalization/observability/ShiftedC4Bernstein.lean"
BERNSTEIN_BLOB = "d29a1e5f0396ca7f29fde24a34325fc324a3d3c0"
TARGET = HERE / "NightfallPolarisQ2Target.lean"
TARGET_BLOB = "7f0c86d5e6e04e0f6330f017aceff6bbb141c747"
DECL = "Nightfall.Polaris.ResearchQ2.locked_shifted_c4_interpolation"
ALLOW_AXIOMS = frozenset({"Classical.choice", "Quot.sound", "propext"})
BLOCKED = re.compile(r"\b(sorry|sorryAx|axiom|unsafe|native_decide|admit)\b")


class GradingError(RuntimeError):
    pass


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git_blob(path: Path) -> str:
    return subprocess.check_output(["git", "hash-object", str(path)], text=True).strip()


def verify_trusted() -> dict:
    sources = ((BERNSTEIN, BERNSTEIN_BLOB), (TARGET, TARGET_BLOB))
    hashes = {}
    for source, expected in sources:
        if source.is_symlink() or not source.is_file():
            raise GradingError("trusted source is absent or a symlink")
        actual = git_blob(source)
        if actual != expected:
            raise GradingError(f"trusted source Git blob mismatch: {source.name}: {actual}")
        hashes[source.name] = {"git_blob": actual, "sha256": digest(source)}
    if (ROOT / "lean-toolchain").read_text().strip() != TOOLCHAIN:
        raise GradingError("repository Lean toolchain changed")
    return hashes


def candidate_check(path: Path) -> str:
    if path.is_symlink() or not path.is_file():
        raise GradingError("candidate missing or symlink")
    text = path.read_text(encoding="utf-8")
    if BLOCKED.search(text):
        raise GradingError("candidate contains forbidden proof bypass token")
    if not text.startswith("import ShiftedC4Bernstein\n"):
        raise GradingError("candidate must import trusted ShiftedC4Bernstein")
    # Lexical inspection is only defense in depth; the theorem is checked by Lean.
    return digest(path)


def check_workspace(path: Path) -> str:
    if path.is_symlink() or not path.is_dir():
        raise GradingError("pinned Mathlib workspace unavailable")
    if (path / "lean-toolchain").read_text().strip() != TOOLCHAIN:
        raise GradingError("workspace toolchain mismatch")
    commit = subprocess.check_output(["git", "-C", str(path), "rev-parse", "HEAD"], text=True).strip()
    if commit != MATHLIB_COMMIT:
        raise GradingError("workspace Mathlib commit mismatch")
    if not (path / ".lake/build/lib/lean/Mathlib.olean").is_file():
        raise GradingError("Mathlib compiled artifacts unavailable")
    return commit


def run(argv: list[str], cwd: Path, timeout: int) -> tuple[dict, str]:
    start = time.monotonic()
    try:
        p = subprocess.run(argv, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                           text=True, encoding="utf-8", errors="replace",
                           timeout=timeout, env={**os.environ, "LEAN_ABORT_ON_PANIC": "1"})
    except subprocess.TimeoutExpired as exc:
        raise GradingError(f"Lean timeout: {' '.join(argv)}") from exc
    output = p.stdout + "\n" + p.stderr
    rec = {"argv": argv, "exit_code": p.returncode,
           "wall_seconds": round(time.monotonic() - start, 3),
           "output_sha256": hashlib.sha256(output.encode()).hexdigest(),
           "output_tail": output[-3000:]}
    if p.returncode != 0:
        raise GradingError(f"Lean command failure: {' '.join(argv)}:\n{output[-1400:]}")
    return rec, output


def check_compiler_identity(output: str) -> None:
    if "version 4.36.0-rc2" not in output or LEAN_SOURCE_COMMIT not in output:
        raise GradingError("installed Lean compiler does not match pinned source identity")


def axioms_from_output(output: str) -> list[str]:
    regex = (r"(?<![\w.])'?" + re.escape(DECL) +
             r"'?\s+(?:depends on axioms:\s*\[([^\]]*)\]|does not depend on any axioms)")
    found = re.findall(regex, output)
    if len(found) != 1:
        raise GradingError("missing or duplicated trusted terminal axiom report")
    axioms = sorted(set(a.strip() for a in found[0].split(",") if a.strip()))
    if not set(axioms).issubset(ALLOW_AXIOMS):
        raise GradingError("nonstandard axioms: " + repr(axioms))
    return axioms


def grade(candidate: Path, workspace: Path, timeout: int = 1200) -> dict:
    receipt = {"schema": "nightfall.polaris.research-q2.v1", "status": "fail",
               "benchmark_status": "unscored-development-calibration",
               "target": DECL, "pin": TOOLCHAIN,
               "independent_implementation_review": False}
    try:
        receipt["trusted_sources"] = verify_trusted()
        receipt["candidate_sha256"] = candidate_check(candidate)
        receipt["mathlib_commit"] = check_workspace(workspace)
        lake = shutil.which("lake")
        if lake is None:
            raise GradingError("Lake executable unavailable")
        receipt["lake_binary_sha256"] = digest(Path(lake).resolve())
        out = workspace / ".lake/build/lib/lean"
        steps = []
        identity_step, identity_output = run([lake, "env", "lean", "--version"], workspace, timeout)
        check_compiler_identity(identity_output)
        steps.append(identity_step)
        receipt["lean_source_commit"] = LEAN_SOURCE_COMMIT
        for name, source in (
            ("ShiftedC4Bernstein", BERNSTEIN),
            ("ShiftedC4Scalar", candidate),
            ("NightfallPolarisQ2Target", TARGET),
        ):
            dest = workspace / f"{name}.lean"
            # Only a pinned evaluator should have write access to workspace.
            shutil.copyfile(source, dest)
            if digest(dest) != digest(source):
                raise GradingError("copied source differs from expected source: " + name)
            command = [lake, "env", "lean", "-o", str(out / (name + ".olean")), dest.name]
            result, _ = run(command, workspace, timeout)
            steps.append(result)
            # Untrusted elaborator code may write to the staged file tree.
            if source in (BERNSTEIN, TARGET):
                expected = receipt["trusted_sources"][source.name]["sha256"]
                if digest(source) != expected or digest(dest) != expected:
                    raise GradingError("trusted source/staged copy changed during compilation")
        audit = workspace / "NightfallPolarisQ2Audit.lean"
        audit.write_text("import NightfallPolarisQ2Target\n#print axioms " + DECL +
                         "\n#check " + DECL + "\n", encoding="utf-8")
        result, output = run([lake, "env", "lean", audit.name], workspace, timeout)
        steps.append(result)
        receipt["axioms"] = axioms_from_output(output)
        result, _ = run([lake, "env", "leanchecker", "NightfallPolarisQ2Target"], workspace, timeout)
        steps.append(result)
        for name, source in (("ShiftedC4Bernstein", BERNSTEIN),
                             ("NightfallPolarisQ2Target", TARGET)):
            expected = receipt["trusted_sources"][source.name]["sha256"]
            if digest(source) != expected or digest(workspace / f"{name}.lean") != expected:
                raise GradingError("trusted source/staged copy changed after kernel replay")
        receipt["steps"] = steps
        receipt["status"] = "pass"
        receipt["certification"] = "pinned-Lean-kernel-replay; not externally audited"
        receipt["limits"] = (
            "PUBLIC positive-control proof; no blinded agents. No sandbox. "
            "Mathlib working directory is evaluator-managed and reused; independent external replay pending."
        )
    except (OSError, ValueError, GradingError, UnicodeError, subprocess.CalledProcessError) as error:
        receipt["error"] = str(error)
    return receipt


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--candidate", required=True, type=Path)
    parser.add_argument("--workspace", type=Path, default=Path("/tmp/mathlib4"))
    parser.add_argument("--receipt", type=Path)
    parser.add_argument("--timeout", type=int, default=1200)
    args = parser.parse_args()
    result = grade(args.candidate, args.workspace, args.timeout)
    encoded = json.dumps(result, sort_keys=True, indent=2) + "\n"
    print(encoded)
    if args.receipt:
        args.receipt.parent.mkdir(parents=True, exist_ok=True)
        args.receipt.write_text(encoded, encoding="utf-8")
    return 0 if result["status"] == "pass" else 1


if __name__ == "__main__":
    sys.exit(main())
