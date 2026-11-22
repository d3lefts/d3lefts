#!/usr/bin/env python3
"""Preregistered, source-scoped agent-contract A/B timing experiment.

This benchmark deliberately DOES NOT import nightfall_agent_tasks: its direct
checker invocation table and mode comparisons are independently authored.
It measures shell/orchestration process latency, not agent cognition or
mathematical correctness. See AGENT_CONTRACT_AB_PREREG_20261122.md.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import random
import statistics
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[3]  # repository root from agent-operations/
ROLES = ("constructor", "independent-reproducer", "auditor")
MODES = ("legacy", "python-contract", "just-contract", "nushell-contract")
CHECKERS = {
    "passport": ("scripts/check_proof_passport_v2.py", "--self-test"),
    "compiler-lock": ("scripts/check_nightfall_compiler_lock.py", "--checkout", "."),
    "differential-guards": ("scripts/check_formalization_differential.py", "--self-test"),
}
MUTANTS = (
    "forged-mathematical-proof",
    "inconsistent-success-status",
    "invalid-git-head",
    "invalid-role",
    "plausible-wrong-git-head",
    "plausible-wrong-stdout-sha",
    "plausible-wrong-source-anchor",
)
TRUE_ERRORS = set(MUTANTS[:4])
SCHEMA = "nightfall.agent-contract-ab-measurement.v1"


def sha(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def invocation(task: str, mode: str, role: str) -> list[str]:
    args = CHECKERS[task]
    if mode == "legacy":
        return [sys.executable, *args]
    if mode == "python-contract":
        return [sys.executable, "scripts/nightfall_agent_tasks.py", "run", task,
                "--problem", "NIGHTFALL-AB", "--role", role]
    if mode == "just-contract":
        return ["just", "--quiet", task]
    if mode == "nushell-contract":
        # Each argument originates from a frozen allowlist, not arbitrary user input.
        expression = ("use research/nightfall/agent-operations/task-interface.nu *; "
                      f"task-run {task} --problem NIGHTFALL-AB --role {role} | to json -r")
        return ["nu", "-c", expression]
    raise ValueError("unknown mode")


def execute(argv: list[str], env: dict[str, str], timeout: int = 120) -> dict:
    start = time.perf_counter_ns()
    try:
        p = subprocess.run(argv, cwd=ROOT, capture_output=True, check=False,
                           env=env, timeout=timeout)
        code, stdout, stderr, timed_out = p.returncode, p.stdout, p.stderr, False
    except subprocess.TimeoutExpired as e:
        code, stdout, stderr, timed_out = None, e.stdout or b"", e.stderr or b"", True
    end = time.perf_counter_ns()
    return {
        "duration_ns": end - start, "exit_code": code, "timed_out": timed_out,
        "stdout_sha256": sha(stdout), "stderr_sha256": sha(stderr),
        "stdout_length": len(stdout), "stderr_length": len(stderr),
        "_stdout": stdout, "_stderr": stderr,
    }


def git_head(env: dict[str, str]) -> str:
    run = execute(["git", "rev-parse", "HEAD"], env)
    if run["exit_code"] != 0:
        raise RuntimeError("cannot resolve frozen source commit")
    return run["_stdout"].decode().strip()


def parse_json(raw: bytes) -> dict:
    d = json.loads(raw.decode("utf-8"))
    if not isinstance(d, dict):
        raise ValueError("non-object JSON")
    return d


def audit_receipt(receipt: dict, task: str, role: str, baseline_sha: str,
                  mode: str, source_commit: str) -> None:
    if receipt.get("schema") != "nightfall.agent-task-receipt.v1":
        raise ValueError("bad contract schema")
    if receipt.get("task") != task:
        raise ValueError("task mismatch")
    if receipt.get("problem_id") != ("NIGHTFALL-PROGRAM" if mode == "just-contract"
                                     else "NIGHTFALL-AB"):
        raise ValueError("problem mismatch")
    if receipt.get("agent_role_claimed") != ("coordinator" if mode == "just-contract"
                                            else role):
        raise ValueError("role mismatch")
    if receipt.get("execution", {}).get("status") != "PASS":
        raise ValueError("contract did not report a successful verifier execution")
    if receipt["execution"].get("stdout_sha256") != baseline_sha:
        raise ValueError("underlying verifier output differs from direct baseline")
    if receipt["source"].get("git_head") != source_commit:
        raise ValueError("source commit drift")
    if receipt["certification"] != {
        "mathematical_theorem": False,
        "independent_semantic_audit": False,
        "global_priority": False,
    }:
        raise ValueError("unwarranted certificate promotion")


def mutate(receipt: dict, mutation: str) -> dict:
    d = json.loads(json.dumps(receipt))
    if mutation == "forged-mathematical-proof":
        d["certification"]["mathematical_theorem"] = True
    elif mutation == "inconsistent-success-status":
        d["execution"]["status"] = "FAIL"
    elif mutation == "invalid-git-head":
        d["source"]["git_head"] = "bad-sha"
    elif mutation == "invalid-role":
        d["agent_role_claimed"] = "unreviewed-non-author"
    elif mutation == "plausible-wrong-git-head":
        h = d["source"]["git_head"]
        d["source"]["git_head"] = ("0" if h[0] != "0" else "1") + h[1:]
    elif mutation == "plausible-wrong-stdout-sha":
        h = d["execution"]["stdout_sha256"]
        d["execution"]["stdout_sha256"] = ("0" if h[0] != "0" else "1") + h[1:]
    elif mutation == "plausible-wrong-source-anchor":
        key = sorted(d["source"]["anchor_sha256"])[0]
        h = d["source"]["anchor_sha256"][key]
        d["source"]["anchor_sha256"][key] = ("0" if h[0] != "0" else "1") + h[1:]
    else:
        raise ValueError("unknown mutation")
    return d


def negative_controls(role: str, receipt: dict, env: dict[str, str]) -> list[dict]:
    cases = []
    with tempfile.TemporaryDirectory(prefix="nightfall-contract-ab-") as tmp:
        for name in MUTANTS:
            path = Path(tmp) / (name + ".json")
            path.write_text(json.dumps(mutate(receipt, name)), encoding="utf-8")
            for mode in ("python-contract", "nushell-contract"):
                if mode == "python-contract":
                    args = [sys.executable, "scripts/nightfall_agent_tasks.py",
                            "verify", str(path)]
                    local_env = env
                else:
                    args = ["nu", "-c",
                            ("use research/nightfall/agent-operations/task-interface.nu *; "
                             "task-verify $env.NIGHTFALL_BAD_RECEIPT | to json -r")]
                    local_env = dict(env, NIGHTFALL_BAD_RECEIPT=str(path))
                result = execute(args, local_env)
                cases.append({
                    "role": role,
                    "mutation": name,
                    "control_kind": "reject-required" if name in TRUE_ERRORS
                                    else "structurally-plausible-source-or-output-tamper",
                    "mode": mode,
                    "accepted": result["exit_code"] == 0,
                    "exit_code": result["exit_code"],
                    "duration_ns": result["duration_ns"],
                })
    return cases


def bench(role: str, repeats: int, output: Path) -> None:
    if role not in ROLES or not 1 <= repeats <= 20:
        raise ValueError("unsupported role or repetition count")
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1", PYTHONHASHSEED="0")
    source_commit = git_head(env)
    records, control_base = [], None
    # First direct run is an independent reference for deterministic output
    # from each actual verifier; NOT counted as a timed sample.
    reference_sha = {}
    for task in CHECKERS:
        direct = execute(invocation(task, "legacy", role), env)
        if direct["exit_code"] != 0 or direct["timed_out"]:
            raise RuntimeError(f"source checker failure in baseline {task}: "
                               + direct["_stderr"].decode("utf8", "replace")[-600:])
        reference_sha[task] = direct["stdout_sha256"]
    for task in CHECKERS:
        for round_id in range(repeats):
            seed = int.from_bytes(hashlib.sha256(
                f"{role}:{task}:{round_id}".encode()).digest()[:8], "big")
            order = list(MODES)
            random.Random(seed).shuffle(order)
            for mode in order:
                result = execute(invocation(task, mode, role), env)
                if result["exit_code"] != 0 or result["timed_out"]:
                    raise RuntimeError(f"verifier failed in {role}/{task}/{mode}/"
                                       f"{round_id}: " +
                                       result["_stderr"].decode("utf8", "replace")[-600:])
                if mode == "legacy":
                    if result["stdout_sha256"] != reference_sha[task]:
                        raise RuntimeError(f"legacy checker output drift: {task}")
                else:
                    receipt = parse_json(result["_stdout"])
                    audit_receipt(receipt, task, role, reference_sha[task],
                                  mode, source_commit)
                    if control_base is None and mode == "python-contract":
                        control_base = receipt
                records.append({
                    "task": task, "role": role, "round": round_id,
                    "mode": mode, "duration_ns": result["duration_ns"],
                    "exit_code": result["exit_code"],
                    "stdout_sha256": result["stdout_sha256"],
                    "checker_output_sha256": (reference_sha[task] if mode == "legacy"
                                              else receipt["execution"]["stdout_sha256"]),
                    "checker_output_equal": True,
                })
    if control_base is None:
        raise RuntimeError("no contract receipt collected")
    negative = negative_controls(role, control_base, env)
    if any(c["accepted"] for c in negative if c["control_kind"] == "reject-required"):
        raise RuntimeError("a mandatory negative control was accepted")
    report = {
        "schema": SCHEMA, "source_commit": source_commit,
        "role": role, "repeats": repeats,
        "runner": {"python": sys.version.split()[0],
                   "just": execute(["just", "--version"], env)["_stdout"].decode().strip(),
                   "nushell": execute(["nu", "--version"], env)["_stdout"].decode().strip()},
        "timing_scope": "warm-process-execution-only; setup/install excluded",
        "role_is_simulated": True,
        "mathematical_certification": False,
        "primary_records": records, "negative_controls": negative,
        "source_checker_sha256": reference_sha,
        "independent_agent_productivity_measured": False,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, sort_keys=True, indent=2) + "\n")
    print(json.dumps({
        "role": role, "source_commit": source_commit,
        "samples": len(records), "negatives": len(negative),
        "accepted_plausible_hash_mutations": sum(
            x["accepted"] for x in negative if x["control_kind"] != "reject-required"
        ),
        "output": str(output),
    }, sort_keys=True))


def summarize(paths: list[Path], output: Path) -> None:
    if len(paths) != len(ROLES):
        raise ValueError("require one measurement file per role")
    reports = [json.loads(p.read_text()) for p in paths]
    if {r.get("role") for r in reports} != set(ROLES):
        raise ValueError("roles not exact or duplicated")
    commits = {r.get("source_commit") for r in reports}
    if len(commits) != 1 or any(r.get("schema") != SCHEMA for r in reports):
        raise ValueError("different source commits or experiment schemas")
    rows, comparisons = [], []
    for r in reports:
        if any(not x["checker_output_equal"] for x in r["primary_records"]):
            raise ValueError("checker-output drift")
        for task in CHECKERS:
            legacy = [x["duration_ns"] for x in r["primary_records"]
                      if x["task"] == task and x["mode"] == "legacy"]
            if len(legacy) != r["repeats"]:
                raise ValueError("missing baseline round")
            base = statistics.median(legacy)
            for mode in MODES:
                times = [x["duration_ns"] for x in r["primary_records"]
                         if x["task"] == task and x["mode"] == mode]
                if len(times) != r["repeats"]:
                    raise ValueError("missing A/B samples")
                med = statistics.median(times)
                row = {
                    "role": r["role"], "task": task, "mode": mode,
                    "n": len(times), "median_ms": round(med / 1e6, 3),
                    "p90_ms": round(sorted(times)[int(.9 * (len(times) - 1))] / 1e6, 3),
                    "ratio_to_legacy": round(med / base, 4),
                }
                rows.append(row)
                if mode != "legacy":
                    comparisons.append(row["ratio_to_legacy"])
    negative = [c for r in reports for c in r["negative_controls"]]
    if len(negative) != len(ROLES) * len(MUTANTS) * 2:
        raise ValueError("missing negative control results")
    acceptance = {
        mutation: {
            "tested": len([c for c in negative if c["mutation"] == mutation]),
            "accepted": sum(c["accepted"] for c in negative if c["mutation"] == mutation),
        }
        for mutation in MUTANTS
    }
    if any(acceptance[x]["accepted"] != 0 for x in TRUE_ERRORS):
        raise ValueError("unsafe acceptance of required rejection controls")
    bymode = {
        mode: {
            "median_ratio_to_legacy": round(statistics.median(
                x["ratio_to_legacy"] for x in rows if x["mode"] == mode), 4),
            "median_duration_ms": round(statistics.median(
                x["median_ms"] for x in rows if x["mode"] == mode), 3),
        }
        for mode in MODES
    }
    gate = {
        mode: (
            sum(statistics.median(x["ratio_to_legacy"] for x in rows
                                  if x["mode"] == mode and x["task"] == task) <= .8
                for task in CHECKERS) >= 2
            and all(x["ratio_to_legacy"] < 1.0 for x in rows if x["mode"] == mode)
        )
        for mode in MODES if mode != "legacy"
    }
    result = {
        "schema": "nightfall.agent-contract-ab-summary.v1",
        "source_commit": next(iter(commits)),
        "roles": sorted(ROLES),
        "role_is_simulated": True,
        "tasks": sorted(CHECKERS),
        "raw_samples": sum(len(r["primary_records"]) for r in reports),
        "negative_cases": len(negative),
        "latency_ratios": bymode,
        "per_role_task": rows,
        "negative_control_acceptance": acceptance,
        "preregistered_runtime_gain_gate_passed": gate,
        "setup_overhead_measured": False,
        "actual_parallel_agents_measured": False,
        "actual_mathematical_certification_errors_measured": False,
        "mathematical_certification": False,
        "conclusion_scope": "process latency and simulated receipt mutation tests only",
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps({k: result[k] for k in (
        "schema", "source_commit", "raw_samples", "negative_cases",
        "latency_ratios", "negative_control_acceptance",
        "preregistered_runtime_gain_gate_passed"
    )}, indent=2, sort_keys=True))


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    commands = p.add_subparsers(dest="command", required=True)
    b = commands.add_parser("bench")
    b.add_argument("--role", choices=ROLES, required=True)
    b.add_argument("--repeats", type=int, default=8)
    b.add_argument("--out", type=Path, required=True)
    s = commands.add_parser("summarize")
    s.add_argument("--inputs", type=Path, nargs=3, required=True)
    s.add_argument("--out", type=Path, required=True)
    args = p.parse_args()
    if args.command == "bench":
        bench(args.role, args.repeats, args.out)
    else:
        summarize(args.inputs, args.out)


if __name__ == "__main__":
    main()
