#!/usr/bin/env python3
"""Fail-closed Docker *entrypoint* for untrusted ProofGraph-Hard Q2 submissions.

The container image must be separately built/audited and pinned by digest.
This script never runs candidate Lean code on the host and never mounts the
full repository or reference proof. Not a VM, not a guarantee against container
escape, and not a blind evaluation of a publicly known theorem.
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
import tempfile

from grade_research_q2 import (
    BERNSTEIN, TARGET, TOOLCHAIN, MATHLIB_COMMIT, LEAN_SOURCE_COMMIT,
    ALLOW_AXIOMS, DECL, digest, git_blob, verify_trusted, candidate_check,
)

IMAGE_PIN = re.compile(r"^[a-zA-Z0-9][a-zA-Z0-9._:/-]*@sha256:[a-f0-9]{64}$")
REQUIRED_FILES = frozenset({
    "lean-toolchain",
    "research/nightfall/formalization/observability/ShiftedC4Bernstein.lean",
    "research/nightfall/evals/polaris-research-20261119/research_q2/NightfallPolarisQ2Target.lean",
    "research/nightfall/evals/polaris-research-20261119/research_q2/grade_research_q2.py",
    "candidate/ShiftedC4Scalar.lean",
})
GRADER_REL = "research/nightfall/evals/polaris-research-20261119/research_q2/grade_research_q2.py"
BERNSTEIN_REL = "research/nightfall/formalization/observability/ShiftedC4Bernstein.lean"
TARGET_REL = "research/nightfall/evals/polaris-research-20261119/research_q2/NightfallPolarisQ2Target.lean"


def sealed_sources(candidate: Path, stage: Path) -> dict:
    trusted = verify_trusted()
    candidate_hash = candidate_check(candidate)
    if stage.exists() and any(stage.iterdir()):
        raise ValueError("stage must be initially empty")
    stage.mkdir(parents=True, exist_ok=True)
    grader = Path(__file__).with_name("grade_research_q2.py")
    sources = {
        "lean-toolchain": None,
        BERNSTEIN_REL: BERNSTEIN,
        TARGET_REL: TARGET,
        GRADER_REL: grader,
        "candidate/ShiftedC4Scalar.lean": candidate,
    }
    for rel, src in sources.items():
        dst = stage / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        if src is None:
            dst.write_text(TOOLCHAIN + "\n", encoding="utf-8")
        else:
            if src.is_symlink() or not src.is_file():
                raise ValueError("input must be regular file: " + rel)
            shutil.copyfile(src, dst)
    files = {p.relative_to(stage).as_posix(): digest(p) for p in stage.rglob("*") if p.is_file()}
    if set(files) != REQUIRED_FILES:
        raise ValueError("sealed stage contains unexpected paths")
    for name, original in (
        (BERNSTEIN_REL, BERNSTEIN),
        (TARGET_REL, TARGET),
        ("candidate/ShiftedC4Scalar.lean", candidate),
    ):
        if files[name] != digest(original):
            raise ValueError("source mismatch after staging: " + name)
    if files["candidate/ShiftedC4Scalar.lean"] != candidate_hash:
        raise ValueError("candidate hash mismatch")
    if files[BERNSTEIN_REL] != trusted[BERNSTEIN.name]["sha256"]:
        raise ValueError("Bernstein source mismatch")
    if files[TARGET_REL] != trusted[TARGET.name]["sha256"]:
        raise ValueError("frozen target mismatch")
    return {
        "schema": "nightfall.polaris.sealed-submission.v1",
        "source_files": files, "candidate_sha256": candidate_hash,
        "compiler_pin": TOOLCHAIN, "mathlib_commit": MATHLIB_COMMIT,
        "reference_solution_preloaded": False,
        "candidate_matches_public_reference": git_blob(candidate) == "c978b8343785911162fd1028c96be32a0c9de242",
    }


def docker_argv(image: str, stage: Path, output: Path, *, memory: str = "8g",
                cpus: str = "2", pids: int = 256) -> list[str]:
    if not IMAGE_PIN.fullmatch(image):
        raise ValueError("image must be pinned via registry/name@sha256:<64-hex>")
    if not stage.is_absolute() or not output.is_absolute():
        raise ValueError("paths must be absolute")
    if not re.fullmatch(r"[1-9][0-9]*[mg]", memory) or not re.fullmatch(r"[1-9][0-9]*(?:\.[0-9]+)?", cpus):
        raise ValueError("invalid resource limits")
    if not isinstance(pids, int) or not 16 <= pids <= 1024:
        raise ValueError("pids out of range")
    # Image contract: /opt/mathlib4 contains the pinned Git checkout, cached
    # Mathlib .olean files and compiler. Installed tools include python3, git, lake.
    # Runtime copies this image-owned workspace to ephemeral tmpfs.
    task = (
        "cp -r /opt/mathlib4 /tmp/mathlib4; "
        "test \"$(git -C /tmp/mathlib4 rev-parse HEAD)\" = " + MATHLIB_COMMIT + "; "
        "python3 /task/" + GRADER_REL +
        " --candidate /task/candidate/ShiftedC4Scalar.lean"
        " --workspace /tmp/mathlib4 --receipt /results/proofgraph-q2.json"
    )
    return [
        "docker", "run", "--rm", "--network", "none", "--read-only",
        "--cap-drop", "ALL", "--security-opt", "no-new-privileges",
        "--user", "10001:10001", "--pids-limit", str(pids),
        "--memory", memory, "--cpus", cpus,
        "--tmpfs", "/tmp:rw,nosuid,nodev,size=6g,mode=1777",
        "--tmpfs", "/results:rw,nosuid,nodev,size=32m,mode=1777",
        "--env", "HOME=/tmp",
        "--mount", "type=bind,src=" + str(stage) + ",dst=/task,readonly",
        "--workdir", "/task", image, "sh", "-euc", task,
    ]



def verify_grader_receipt(report: dict, manifest: dict) -> None:
    """Structural post-run audit of the *reported* command trace.

    This cannot establish runtime honesty independently of the pinned
    evaluator image. It does reject partial/malformed or forged-looking
    success receipts before any host-side score is recorded.
    """
    if not isinstance(report, dict) or report.get("schema") != "nightfall.polaris.research-q2.v1":
        raise RuntimeError("wrong grader receipt schema")
    if report.get("status") != "pass" or report.get("benchmark_status") != "unscored-development-calibration":
        raise RuntimeError("nonpassing or unexpectedly scored grader receipt")
    if report.get("certification") != "pinned-Lean-kernel-replay; not externally audited":
        raise RuntimeError("unexpected grader certification")
    if report.get("independent_implementation_review") is not False:
        raise RuntimeError("external review cannot be self-certified")
    if report.get("target") != DECL or report.get("pin") != TOOLCHAIN:
        raise RuntimeError("target/toolchain mismatch")
    if report.get("candidate_sha256") != manifest["candidate_sha256"]:
        raise RuntimeError("candidate hash differs from sealed source")
    if report.get("mathlib_commit") != MATHLIB_COMMIT or report.get("lean_source_commit") != LEAN_SOURCE_COMMIT:
        raise RuntimeError("compiler/Mathlib source identity mismatch")
    trusted = report.get("trusted_sources", {})
    if not isinstance(trusted, dict):
        raise RuntimeError("trusted sources absent")
    for filename, rel in (("ShiftedC4Bernstein.lean", BERNSTEIN_REL),
                          ("NightfallPolarisQ2Target.lean", TARGET_REL)):
        source_record = trusted.get(filename, {})
        if not isinstance(source_record, dict) or source_record.get("sha256") != manifest["source_files"][rel]:
            raise RuntimeError("trusted source digest mismatch: " + filename)
    axioms = report.get("axioms")
    if not isinstance(axioms, list) or len(axioms) != len(set(axioms)) or not set(axioms) <= ALLOW_AXIOMS:
        raise RuntimeError("invalid axiom report")
    steps = report.get("steps")
    if not isinstance(steps, list) or len(steps) != 6:
        raise RuntimeError("incomplete Lean build/axiom/kernel trace")
    expect = [
        ("lean", "--version"),
        ("lean", "ShiftedC4Bernstein.lean"),
        ("lean", "ShiftedC4Scalar.lean"),
        ("lean", "NightfallPolarisQ2Target.lean"),
        ("lean", "NightfallPolarisQ2Audit.lean"),
        ("leanchecker", "NightfallPolarisQ2Target"),
    ]
    for item, (tool, terminal) in zip(steps, expect):
        if not isinstance(item, dict) or item.get("exit_code") != 0:
            raise RuntimeError("missing or failed proof step")
        argv = item.get("argv", [])
        if (not isinstance(argv, list) or len(argv) < 4 or
                not argv[0].endswith("/lake") or argv[1] != "env" or
                argv[2] != tool or argv[-1] != terminal):
            raise RuntimeError("unexpected Lean command sequence")
        if tool == "lean" and terminal.endswith(".lean") and terminal != "NightfallPolarisQ2Audit.lean":
            if len(argv) != 6 or argv[3] != "-o":
                raise RuntimeError("missing .olean output from compiled proof")
            if Path(argv[4]).name != terminal.replace(".lean", ".olean"):
                raise RuntimeError("compiled .olean output does not match source")
        if not re.fullmatch(r"[a-f0-9]{64}", str(item.get("output_sha256", ""))):
            raise RuntimeError("invalid command output hash")


def evaluate(candidate: Path, image: str, output: Path) -> dict:
    if not IMAGE_PIN.fullmatch(image):
        raise ValueError("explicit immutable image digest required")
    if not shutil.which("docker"):
        raise RuntimeError("Docker missing: untrusted evaluation refused")
    # Docker is trusted infrastructure. No host result directory is writable by the candidate.
    with tempfile.TemporaryDirectory(prefix="polaris-q2-sealed-") as folder:
        stage = Path(folder) / "sealed"
        manifest = sealed_sources(candidate, stage)
        Path(folder).chmod(0o755)
        output = output.resolve()
        output.mkdir(parents=True, exist_ok=True)
        # Docker uses remapped/nonroot uid, must be able to read staged sources.
        for p in stage.rglob("*"):
            p.chmod(0o755 if p.is_dir() else 0o444)
        stage.chmod(0o755)
        cmd = docker_argv(image, stage.resolve(), output)
        completed = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                   encoding="utf-8", errors="replace", timeout=5400)
        # Parse the grader output as data, not as host-executable instructions.
        # Receipt on host is written ONLY by this wrapper after post-run validation.
        if not completed.stdout.strip():
            raise RuntimeError("sandbox produced no JSON report")
        report = json.loads(completed.stdout)
        if completed.returncode:
            raise RuntimeError("sandbox exited unsuccessfully")
        verify_grader_receipt(report, manifest)
        report["host_sandbox_wrapper"] = {
            "mode": "docker-nonprivileged-network-disabled",
            "image": image, "sealed_files": manifest["source_files"],
            "docker_exit_code": completed.returncode,
            "security_limitations": "Docker/runtime and image not independently assessed; public theorem; no blind model trial",
        }
        path = output / "proofgraph-q2.json"
        if path.exists() or path.is_symlink():
            raise RuntimeError("output receipt already exists: refusing overwrite")
        path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--candidate", required=True, type=Path)
    parser.add_argument("--image", required=True, help="prebuilt audited image pinned by immutable SHA-256 digest")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--print-command-only", action="store_true",
                        help="testing/design audit only: does not execute or certify candidate")
    args = parser.parse_args()
    if args.print_command_only:
        with tempfile.TemporaryDirectory() as temp:
            stage = Path(temp) / "sealed"
            sealed = sealed_sources(args.candidate, stage)
            cmd = docker_argv(args.image, stage.resolve(), Path(temp).resolve())
            print(json.dumps({"status": "dry-run-only", "manifest": sealed, "argv": cmd}, indent=2))
        return 0
    result = evaluate(args.candidate, args.image, args.output)
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
