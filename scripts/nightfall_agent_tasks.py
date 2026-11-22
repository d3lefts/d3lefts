#!/usr/bin/env python3
"""Shell-independent NIGHTFALL agent task contract.

Only dispatches existing source-owned verification commands. A PASS here means
the named command passed, NOT that a theorem, independent review or priority
claim has been certified. No arbitrary commands or shell interpolation.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
SCHEMA = "nightfall.agent-task-receipt.v1"
ROLES = ("constructor", "independent-reproducer", "auditor", "formalizer", "coordinator")
# A task is a fixed argv tail, the exact checker source, and its limited scope.
TASKS: dict[str, tuple[tuple[str, ...], str]] = {
    "passport": (
        ("scripts/check_proof_passport_v2.py", "--self-test"),
        "passport-v2-metadata-and-adversarial-controls-only",
    ),
    "compiler-lock": (
        ("scripts/check_nightfall_compiler_lock.py", "--checkout", "."),
        "checked-in-lean-toolchain-lock-only-not-installed-kernel",
    ),
    "differential-guards": (
        ("scripts/check_formalization_differential.py", "--self-test"),
        "differential-contract-mutation-controls-not-exact-math-replay",
    ),
    "research-archive": (
        ("scripts/check_research_archive.py", "--self-test"),
        "research-catalogue-integrity-only",
    ),
    "lake-manifest": (
        ("scripts/generate_nightfall_lake.py", "--check"),
        "lean-import-closure-metadata-only-not-kernel-build",
    ),
}
HASH = re.compile(r"^[a-f0-9]{64}$")
GIT = re.compile(r"^[a-f0-9]{40}$")


def digest(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def file_sha256(name: str) -> str:
    path = ROOT / name
    if not path.is_file() or not path.resolve().is_relative_to(ROOT.resolve()):
        raise ValueError("missing or unsafe pinned input: " + name)
    return digest(path.read_bytes())


def get_git_head() -> str:
    p = subprocess.run(
        ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True, capture_output=True,
        check=True, timeout=10,
    )
    head = p.stdout.strip()
    if not GIT.fullmatch(head):
        raise ValueError("git HEAD is not a full commit SHA")
    return head


def get_dirty() -> bool:
    p = subprocess.run(
        ["git", "status", "--porcelain"], cwd=ROOT, text=True,
        capture_output=True, check=True, timeout=10,
    )
    return bool(p.stdout.strip())


def task_list() -> dict:
    return {
        "schema": "nightfall.agent-task-catalogue.v1",
        "tasks": [
            {"name": name, "argv": ["python3", *tail], "scope": scope}
            for name, (tail, scope) in sorted(TASKS.items())
        ],
        "proof_certification": False,
    }


def run_task(name: str, problem: str, role: str, timeout: int) -> dict:
    if name not in TASKS:
        raise ValueError("unknown task (no arbitrary command execution): " + name)
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._:-]{0,99}", problem):
        raise ValueError("invalid problem identifier")
    if role not in ROLES:
        raise ValueError("unknown agent role")
    if timeout < 1 or timeout > 1800:
        raise ValueError("timeout must be 1..1800 seconds")
    tail, scope = TASKS[name]
    anchors = {
        "scripts/nightfall_agent_tasks.py": file_sha256("scripts/nightfall_agent_tasks.py"),
        tail[0]: file_sha256(tail[0]),
        "docs/lean-compiler-lock.json": file_sha256("docs/lean-compiler-lock.json"),
    }
    # Hashing anchor files is not proof that every transitive input is captured:
    # git HEAD and worktree state qualify the complete repository snapshot.
    start = time.monotonic()
    try:
        run = subprocess.run(
            [sys.executable, *tail], cwd=ROOT, capture_output=True,
            timeout=timeout, check=False,
        )
        code = run.returncode
        out, err = run.stdout, run.stderr
        timed_out = False
    except subprocess.TimeoutExpired as ex:
        code = None
        out, err = ex.stdout or b"", ex.stderr or b""
        timed_out = True
    except OSError as ex:
        code = None
        out, err = b"", str(ex).encode("utf-8", "replace")
        timed_out = False
    if isinstance(out, str):
        out = out.encode()
    if isinstance(err, str):
        err = err.encode()
    return {
        "schema": SCHEMA,
        "task": name,
        "problem_id": problem,
        "agent_role_claimed": role,
        "command": ["python3", *tail],
        "execution": {
            "status": "PASS" if code == 0 and not timed_out else "FAIL",
            "exit_code": code,
            "timed_out": timed_out,
            "duration_ms": round((time.monotonic() - start) * 1000),
            "stdout_sha256": digest(out),
            "stderr_sha256": digest(err),
            "stdout_bytes": len(out),
            "stderr_bytes": len(err),
        },
        "source": {
            "git_head": get_git_head(),
            "worktree_dirty": get_dirty(),
            "anchor_sha256": dict(sorted(anchors.items())),
        },
        "toolchain": {"python": ".".join(str(x) for x in sys.version_info[:3])},
        "scope": scope,
        "certification": {
            "mathematical_theorem": False,
            "independent_semantic_audit": False,
            "global_priority": False,
        },
    }


def verify_receipt(d: object) -> None:
    if not isinstance(d, dict) or d.get("schema") != SCHEMA:
        raise ValueError("unknown task receipt schema")
    name = d.get("task")
    if name not in TASKS:
        raise ValueError("unregistered task")
    tail, scope = TASKS[name]
    if d.get("command") != ["python3", *tail] or d.get("scope") != scope:
        raise ValueError("task/command/scope mismatch")
    if d.get("certification") != {
        "mathematical_theorem": False,
        "independent_semantic_audit": False,
        "global_priority": False,
    }:
        raise ValueError("orchestrator cannot certify mathematical or review claims")
    if d.get("agent_role_claimed") not in ROLES:
        raise ValueError("invalid claimed role")
    if not isinstance(d.get("problem_id"), str) or not re.fullmatch(
        r"[A-Za-z0-9][A-Za-z0-9._:-]{0,99}", d["problem_id"]
    ):
        raise ValueError("invalid problem ID")
    src, exe = d.get("source"), d.get("execution")
    if not isinstance(src, dict) or not GIT.fullmatch(str(src.get("git_head", ""))):
        raise ValueError("missing full source commit")
    if type(src.get("worktree_dirty")) is not bool:
        raise ValueError("invalid dirty state")
    anchors = src.get("anchor_sha256")
    needed = {"scripts/nightfall_agent_tasks.py", tail[0], "docs/lean-compiler-lock.json"}
    if not isinstance(anchors, dict) or set(anchors) != needed or not all(
        isinstance(v, str) and HASH.fullmatch(v) for v in anchors.values()
    ):
        raise ValueError("missing/invalid source anchors")
    if not isinstance(exe, dict):
        raise ValueError("missing execution")
    code = exe.get("exit_code")
    if code is not None and (type(code) is not int or code < -255 or code > 255):
        raise ValueError("invalid exit code")
    if type(exe.get("timed_out")) is not bool or (
        exe.get("status") != ("PASS" if code == 0 and not exe["timed_out"] else "FAIL")
    ):
        raise ValueError("forged or inconsistent status")
    if not isinstance(exe.get("duration_ms"), int) or exe["duration_ms"] < 0:
        raise ValueError("invalid duration")
    for stream in ("stdout", "stderr"):
        if not HASH.fullmatch(str(exe.get(stream + "_sha256", ""))):
            raise ValueError("invalid output digest")
        if type(exe.get(stream + "_bytes")) is not int or exe[stream + "_bytes"] < 0:
            raise ValueError("invalid output length")
    if not isinstance(d.get("toolchain"), dict) or not re.fullmatch(
        r"\d+\.\d+\.\d+", str(d["toolchain"].get("python", ""))
    ):
        raise ValueError("invalid Python toolchain")
    if exe["status"] == "PASS" and src["worktree_dirty"]:
        # A successful metadata check against dirty sources remains a PASS
        # of the command; it cannot become a source-pinned certificate.
        pass


def replay_receipt(d: dict, timeout: int = 180) -> dict:
    """Bind receipt to this clean checkout and rerun the SAME source checker.

    This is an integrity/replay check, not independent mathematics. There is
    no claim that agent identity, mathematical soundness, or source originality
    is attested by this function.
    """
    verify_receipt(d)
    if d["execution"]["status"] != "PASS":
        raise ValueError("cannot replay-promote a failed execution receipt")
    recorded = d["source"]
    if recorded["worktree_dirty"] or get_dirty():
        raise ValueError("source-bound replay requires a clean working tree")
    head = get_git_head()
    if recorded["git_head"] != head:
        raise ValueError("recorded source commit differs from checked-out HEAD")
    for source_name, expected_hash in recorded["anchor_sha256"].items():
        if file_sha256(source_name) != expected_hash:
            raise ValueError("source anchor byte hash mismatch: " + source_name)
    fresh = run_task(d["task"], d["problem_id"],
                     d["agent_role_claimed"], timeout)
    if fresh["source"] != recorded:
        raise ValueError("replay source identity changed during checker execution")
    if fresh["toolchain"] != d["toolchain"]:
        raise ValueError("replay Python interpreter/toolchain differs")
    for key in ("status", "exit_code", "timed_out", "stdout_sha256",
                "stderr_sha256", "stdout_bytes", "stderr_bytes"):
        if d["execution"][key] != fresh["execution"][key]:
            raise ValueError("checker output or exit outcome mismatch: " + key)
    return {
        "schema": "nightfall.agent-task-validation.v1",
        "valid_structure": True,
        "replay_bound_to_this_checkout": True,
        "same_checker_source_reexecuted": True,
        "independent_math_audit": False,
        "mathematical_certification": False,
        "source_commit": head,
        "task": d["task"],
    }


def write_receipt(d: dict, path: Path) -> None:
    # Do not overwrite existing receipts; leave historical certificates intact.
    if path.exists():
        raise ValueError("receipt already exists (immutable-by-default): " + str(path))
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("x", encoding="utf-8") as f:
        json.dump(d, f, sort_keys=True, indent=2)
        f.write("\n")


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    sub = p.add_subparsers(dest="operation", required=True)
    sub.add_parser("list", help="Emit JSON task catalogue")
    run = sub.add_parser("run", help="Run one frozen existing verifier")
    run.add_argument("task", choices=sorted(TASKS))
    run.add_argument("--problem", default="NIGHTFALL-PROGRAM")
    run.add_argument("--role", default="coordinator", choices=ROLES)
    run.add_argument("--timeout", type=int, default=180)
    run.add_argument("--receipt", type=Path, help="Write immutable JSON receipt to a new path")
    verify = sub.add_parser("verify", help="Validate receipt structure (not truth)")
    verify.add_argument("receipt", type=Path)
    replay = sub.add_parser("replay", help="Reexecute checker, binding source and output to current clean checkout")
    replay.add_argument("receipt", type=Path)
    replay.add_argument("--timeout", type=int, default=180)
    args = p.parse_args()
    try:
        if args.operation == "list":
            d = task_list()
        elif args.operation == "run":
            d = run_task(args.task, args.problem, args.role, args.timeout)
            verify_receipt(d)
            if args.receipt is not None:
                write_receipt(d, args.receipt)
        elif args.operation == "verify":
            d = json.loads(args.receipt.read_text(encoding="utf-8"))
            verify_receipt(d)
            d = {"schema": "nightfall.agent-task-validation.v1",
                 "valid_structure": True, "mathematical_certification": False}
        else:
            d = json.loads(args.receipt.read_text(encoding="utf-8"))
            d = replay_receipt(d, args.timeout)
        print(json.dumps(d, sort_keys=True, separators=(",", ":")))
        return 1 if args.operation == "run" and d["execution"]["status"] != "PASS" else 0
    except (ValueError, KeyError, TypeError, OSError, json.JSONDecodeError,
            subprocess.CalledProcessError, subprocess.TimeoutExpired) as ex:
        print("FAIL: " + str(ex), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
