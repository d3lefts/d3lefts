#!/usr/bin/env python3
"""Fail-closed, clean-target Lean grading adapter.

This reconstructs a candidate from *trusted* files and a narrow proof overlay.
It is NOT a security sandbox: execute submissions only in an isolated container/VM.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import sys
import tempfile

SCHEMA = "nightfall.proofgraph.task.v1"
RECEIPT_SCHEMA = "nightfall.proofgraph.receipt.v1"
EXCLUDED = {".git", ".lake", "__pycache__", "build"}
ALLOWED_AXIOMS = {"propext", "Quot.sound", "Classical.choice"}
FORBIDDEN = re.compile(r"\b(sorry|sorryAx|axiom|unsafe|native_decide|admit)\b")
LEAN_NAME = re.compile(r"^[A-Za-z_][A-Za-z0-9_.']*$")


class InvalidSubmission(ValueError):
    pass


def valid_path(raw: str, suffix: str = ".lean") -> Path:
    if not isinstance(raw, str) or not raw or "\\" in raw:
        raise InvalidSubmission("invalid relative file path")
    pure = PurePosixPath(raw)
    if pure.is_absolute() or ".." in pure.parts or "." in pure.parts or str(pure) != raw:
        raise InvalidSubmission("noncanonical relative path")
    if suffix and pure.suffix != suffix:
        raise InvalidSubmission("submission path must have .lean suffix")
    return Path(*pure.parts)


def source_files(root: Path):
    """Collect all source-tree files; never follow symlinks or include build caches."""
    if root.is_symlink() or not root.is_dir():
        raise InvalidSubmission("root must be a real directory")
    files = []
    for directory, dirs, names in os.walk(root, followlinks=False):
        dirs[:] = sorted(d for d in dirs if d not in EXCLUDED)
        for d in dirs:
            if (Path(directory) / d).is_symlink():
                raise InvalidSubmission("symlink in source tree")
        for name in sorted(names):
            p = Path(directory) / name
            if p.is_symlink() or not p.is_file():
                raise InvalidSubmission("symlink or non-regular source file")
            files.append(p)
    return sorted(files, key=lambda p: p.relative_to(root).as_posix())


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tree_sha256(root: Path) -> str:
    h = hashlib.sha256()
    for p in source_files(root):
        rel = p.relative_to(root).as_posix().encode("utf-8")
        h.update(len(rel).to_bytes(8, "big") + rel)
        data = p.read_bytes()
        h.update(len(data).to_bytes(8, "big") + data)
    return h.hexdigest()


def load_task(manifest: Path, trusted: Path) -> dict:
    task = json.loads(manifest.read_text(encoding="utf-8"))
    if task.get("schema") != SCHEMA:
        raise InvalidSubmission("unsupported task schema")
    toolchain = task.get("toolchain")
    if not isinstance(toolchain, str) or not toolchain.startswith("leanprover/lean4:"):
        raise InvalidSubmission("toolchain must be an explicit Lean 4 pin")
    if (trusted / "lean-toolchain").read_text().strip() != toolchain:
        raise InvalidSubmission("lean-toolchain differs from trusted manifest")
    digest = task.get("trusted_tree_sha256")
    if not isinstance(digest, str) or not re.fullmatch(r"[a-f0-9]{64}", digest):
        raise InvalidSubmission("trusted project hash missing")
    if tree_sha256(trusted) != digest:
        raise InvalidSubmission("trusted project hash mismatch")
    target = task.get("target_module")
    names = task.get("required_theorems")
    paths = task.get("allowed_submission_paths")
    axioms = task.get("allowed_axioms")
    if not isinstance(target, str) or not LEAN_NAME.fullmatch(target):
        raise InvalidSubmission("invalid target module")
    if not isinstance(names, list) or not names or len(set(names)) != len(names) or any(not isinstance(n, str) or not LEAN_NAME.fullmatch(n) for n in names):
        raise InvalidSubmission("invalid theorem names")
    if not isinstance(paths, list) or not paths or len(set(paths)) != len(paths):
        raise InvalidSubmission("invalid submission path list")
    for p in paths:
        valid_path(p)
        if (trusted / p).exists():
            raise InvalidSubmission("candidate may not overwrite a trusted file")
    if not isinstance(axioms, list) or set(axioms) != ALLOWED_AXIOMS:
        raise InvalidSubmission("axiom allowlist may not be weakened or expanded")
    target_path = trusted / (target.replace(".", "/") + ".lean")
    if not target_path.is_file() or target_path.is_symlink():
        raise InvalidSubmission("trusted target module missing")
    return task


def check_submission(submission: Path, allowed_paths: list[str]) -> dict[str, str]:
    allowed = set(allowed_paths)
    actual = {}
    for p in source_files(submission):
        rel = p.relative_to(submission).as_posix()
        if rel not in allowed:
            raise InvalidSubmission("unapproved submission file: " + rel)
        data = p.read_text(encoding="utf-8")
        if FORBIDDEN.search(data):
            raise InvalidSubmission("forbidden proof token in " + rel)
        actual[rel] = sha256_file(p)
    if set(actual) != allowed:
        raise InvalidSubmission("submission file set differs from allowlist")
    return actual


def parse_axioms(output: str, theorem_names: list[str]) -> dict[str, list[str]]:
    result = {}
    for theorem in theorem_names:
        # Lean '#print axioms' emits: 'T' depends on axioms: [...] or
        # 'T' does not depend on any axioms.
        pattern = rf"(?<![\w.])'?{re.escape(theorem)}'?\s+(?:depends on axioms:\s*\[([^\]]*)\]|does not depend on any axioms)"
        matches = re.findall(pattern, output)
        if len(matches) != 1:
            raise InvalidSubmission("missing or duplicate axiom report: " + theorem)
        deps = sorted({t.strip() for t in matches[0].split(",") if t.strip()})
        if not set(deps) <= ALLOWED_AXIOMS:
            raise InvalidSubmission("forbidden axiom dependency: " + theorem + " -> " + repr(deps))
        result[theorem] = deps
    return result


def execute(cmd: list[str], cwd: Path, timeout: int) -> dict:
    try:
        p = subprocess.run(cmd, cwd=cwd, text=True, encoding="utf-8", errors="replace",
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=timeout,
                           env={**os.environ, "LEAN_ABORT_ON_PANIC": "1"})
    except subprocess.TimeoutExpired as e:
        raise InvalidSubmission("command timeout: " + " ".join(cmd)) from e
    output = p.stdout + "\n" + p.stderr
    receipt = {"argv": cmd, "exit_code": p.returncode,
               "output_sha256": hashlib.sha256(output.encode()).hexdigest(),
               "output_tail": output[-2400:]}
    if p.returncode != 0:
        raise InvalidSubmission("Lean command failed: " + " ".join(cmd) + "\n" + output[-1200:])
    return {"receipt": receipt, "output": output}


def grade(manifest: Path, trusted: Path, submission: Path, lake: str = "lake", timeout: int = 180) -> dict:
    receipt = {"schema": RECEIPT_SCHEMA, "status": "fail", "certification": "not-certified",
               "harness_mode": "custom-runner-test" if lake != "lake" else "pinned-lake-requested"}
    try:
        task = load_task(manifest, trusted)
        receipt["trusted_tree_sha256"] = task["trusted_tree_sha256"]
        receipt["toolchain"] = task["toolchain"]
        receipt["required_theorems"] = task["required_theorems"]
        receipt["submission_sha256"] = check_submission(submission, task["allowed_submission_paths"])
        lake_path = shutil.which(lake)
        if lake_path is None:
            raise InvalidSubmission("lake executable not installed")
        receipt["runner_path"] = str(Path(lake_path).resolve())
        receipt["runner_sha256"] = sha256_file(Path(lake_path))
        with tempfile.TemporaryDirectory(prefix="polaris-proofgraph-") as tmp:
            stage = Path(tmp) / "project"
            shutil.copytree(trusted, stage, ignore=shutil.ignore_patterns(*EXCLUDED), symlinks=False)
            for rel in task["allowed_submission_paths"]:
                dst = stage / rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(submission / rel, dst)
            # Grader-owned audit module, generated AFTER the candidate overlay.
            audit = stage / "NightfallProofGraphAudit.lean"
            if audit.exists():
                raise InvalidSubmission("reserved audit module collision")
            audit.write_text("import " + task["target_module"] + "\n" + "\n".join(
                "#print axioms " + n for n in task["required_theorems"]
            ) + "\n" + "\n".join("#check " + n for n in task["required_theorems"]) + "\n", encoding="utf-8")
            commands = []
            commands.append(execute([lake_path, "build", task["target_module"]], stage, timeout))
            commands.append(execute([lake_path, "env", "lean", audit.name], stage, timeout))
            receipt["axioms"] = parse_axioms(commands[-1]["output"], task["required_theorems"])
            receipt["commands"] = [c["receipt"] for c in commands]
            for p in source_files(trusted):
                rel = p.relative_to(trusted)
                if sha256_file(p) != sha256_file(stage / rel):
                    raise InvalidSubmission("trusted source mutated during execution: " + rel.as_posix())
        receipt["status"] = "pass"
        receipt["certification"] = "harness-smoke-only" if lake != "lake" else "automated-kernel-check-pending-independent-replay"
        receipt["limitations"] = "Does not sandbox malicious Lean code; run inside a restricted, network-disabled VM/container and independently replay."
    except (OSError, ValueError, json.JSONDecodeError, UnicodeError, subprocess.SubprocessError) as exc:
        receipt["error"] = str(exc)
    return receipt


def main(argv=None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--manifest", type=Path, required=True)
    p.add_argument("--trusted-root", type=Path, required=True)
    p.add_argument("--submission", type=Path, required=True)
    p.add_argument("--lake", default="lake", help="testing override; custom runner cannot produce formal certification")
    p.add_argument("--timeout", type=int, default=180)
    p.add_argument("--receipt", type=Path)
    args = p.parse_args(argv)
    report = grade(args.manifest, args.trusted_root, args.submission, lake=args.lake, timeout=args.timeout)
    serialized = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.receipt:
        args.receipt.write_text(serialized, encoding="utf-8")
    print(serialized)
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    sys.exit(main())
