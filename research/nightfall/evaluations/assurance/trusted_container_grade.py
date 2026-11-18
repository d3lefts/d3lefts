#!/usr/bin/env python3
"""Fail-closed trusted-host Docker grader capture for frozen SWE tasks.

This executes a grader after the agent phase, from a pristine source tree and
a pinned submitted patch. It is NOT an AI-agent runner, external attestation,
proof of grader correctness, or substitute for a separately protected holdout.
Python 3.10+, Docker and git required. Never publish private grader bytes.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import selectors
import shutil
import subprocess
import tempfile
import time
import uuid

from frozen_run_gate import InvalidEvidence, need, no_duplicates, sha_file, validate_plan

PATCH_PATH = re.compile(r"[A-Za-z0-9_.\-/]{1,220}\Z")
HEX_SHA = re.compile(r"[0-9a-f]{64}\Z")
MAX_PATCH_BYTES = 1024 * 1024
MAX_GRADER_OUTPUT_BYTES = 16384


def tree_sha256(root: Path) -> str:
    """Canonical source tree digest: relative POSIX path, executable bit, file SHA."""
    need(root.is_dir() and not root.is_symlink(), "missing/non-directory source tree")
    h = hashlib.sha256()
    entries = sorted(root.rglob("*"), key=lambda p: p.relative_to(root).as_posix())
    need(entries, "empty source tree")
    for entry in entries:
        rel = entry.relative_to(root).as_posix()
        need(not entry.is_symlink(), "symlink in task tree")
        need(".git" not in PurePosixPath(rel).parts, "git metadata in task tree")
        if entry.is_dir():
            continue
        need(entry.is_file(), "nonregular file in task tree")
        executable = "1" if entry.stat().st_mode & 0o111 else "0"
        h.update(rel.encode("utf-8") + b"\0" + executable.encode() + b"\0")
        h.update(sha_file(entry).encode("ascii") + b"\n")
    return h.hexdigest()


def patch_paths(patch: Path):
    need(patch.is_file() and not patch.is_symlink(), "missing patch file")
    need(0 < patch.stat().st_size <= MAX_PATCH_BYTES, "patch size invalid")
    try:
        text = patch.read_text(encoding="utf-8")
    except UnicodeError as exc:
        raise InvalidEvidence("patch is not UTF-8 text") from exc
    targets = []
    for line in text.splitlines():
        if line.startswith("diff --git "):
            match = re.fullmatch(r"diff --git a/(\S+) b/(\S+)", line)
            need(match is not None and match.group(1) == match.group(2),
                 "ambiguous or unsafe diff header")
            rel = match.group(1)
            p = PurePosixPath(rel)
            need(PATCH_PATH.fullmatch(rel) is not None and
                 not p.is_absolute() and
                 all(x not in (".", "..", ".git") for x in p.parts),
                 "unsafe diff target")
            targets.append(rel)
        if line.startswith(("GIT binary patch", "Binary files ", "literal ", "delta ")):
            raise InvalidEvidence("binary patches are not supported by this trial runner")
    need(targets and len(set(targets)) == len(targets),
         "missing or duplicated git patch headers")
    return targets


def limited_process(argv, timeout_seconds, limit=MAX_GRADER_OUTPUT_BYTES):
    """Bound stdout/stderr bytes and elapsed time; reject rather than truncate."""
    started = time.monotonic()
    process = subprocess.Popen(argv, stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL,
                               start_new_session=True)
    data = bytearray()
    selector = selectors.DefaultSelector()
    try:
        assert process.stdout is not None
        selector.register(process.stdout, selectors.EVENT_READ)
        while selector.get_map():
            remaining = timeout_seconds - (time.monotonic() - started)
            need(remaining > 0, "grader execution timeout")
            for key, _ in selector.select(min(remaining, 0.25)):
                chunk = os.read(key.fd, 4096)
                if not chunk:
                    selector.unregister(key.fileobj)
                    break
                data.extend(chunk)
                need(len(data) <= limit, "unbounded grader output rejected")
        code = process.wait(timeout=max(0.05, timeout_seconds -
                                           (time.monotonic() - started)))
        return code, bytes(data), time.monotonic() - started
    except (InvalidEvidence, subprocess.TimeoutExpired):
        process.kill()
        process.wait(timeout=5)
        raise InvalidEvidence("grader timed out or output limit exceeded")
    finally:
        selector.close()
        if process.poll() is None:
            process.kill()
            process.wait(timeout=5)
        if process.stdout is not None:
            process.stdout.close()


def validate_result(text: bytes, plan, attempt_id):
    try:
        parsed = json.loads(text.decode("utf-8"),
                            object_pairs_hook=no_duplicates,
                            parse_constant=lambda x: (_ for _ in ()).throw(
                                InvalidEvidence("nonfinite grader value")))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise InvalidEvidence("grader did not output a single JSON object") from exc
    need(type(parsed) is dict and
         set(parsed) == {"tests_passed", "tests_total", "score_points", "max_points"},
         "grader output keys wrong")
    need(all(type(x) is int and x >= 0 for x in parsed.values()),
         "grader output contains noninteger/negative values")
    need(parsed["tests_total"] == plan["grading"]["tests_total"] and
         parsed["max_points"] == plan["grading"]["max_points"],
         "grader score denominator drift")
    need(parsed["tests_passed"] <= parsed["tests_total"] and
         parsed["score_points"] <= parsed["max_points"],
         "grader output exceeds score ceiling")
    return {
        "schema": "nightfall.eval.grade.v1",
        "task_id": plan["task_id"],
        "attempt_id": attempt_id,
        "grader_sha256": plan["grader_sha256"],
        **parsed,
        "grader_exit_code": 0,
    }


def capture(plan_path: Path, externally_pinned_plan_sha256: str,
            attempt_id: str, seed: Path, patch: Path, grader: Path,
            destination: Path, timeout_seconds: int = 90,
            docker: str = "docker"):
    need(type(externally_pinned_plan_sha256) is str and
         HEX_SHA.fullmatch(externally_pinned_plan_sha256) is not None,
         "external plan commitment required")
    need(plan_path.is_file() and not plan_path.is_symlink(),
         "missing or symlinked frozen plan")
    raw_plan = plan_path.read_bytes()
    need(hashlib.sha256(raw_plan).hexdigest() ==
         externally_pinned_plan_sha256, "frozen plan SHA-256 mismatch")
    try:
        plan = json.loads(raw_plan, object_pairs_hook=no_duplicates,
                          parse_constant=lambda x: (_ for _ in ()).throw(
                              InvalidEvidence("nonfinite plan value")))
    except (UnicodeError, json.JSONDecodeError) as exc:
        raise InvalidEvidence("frozen plan is not strict JSON") from exc
    validate_plan(plan)
    # STOP-SHIP GUARD: this adapter runs candidate-controlled Python within
    # the grader interpreter and exposes /opt/grader/score.py to that process.
    # A malicious candidate can emit forged grade JSON and call os._exit(0).
    # This host-level grading architecture is SYNTHETIC-ONLY until the
    # score authority and untrusted candidate are process/mount separated.
    # Names are a policy guard, NOT authentication of model identity.
    need(plan["task_id"].lower().startswith("synthetic-") and
         plan["model_id"].startswith("laboratory/synthetic-"),
         "UNTRUSTED_SCORE_ORIGIN: same-process grader synthetic-only; "
         "real task/model scores prohibited until scorer isolation")
    need(attempt_id in plan["attempt_ids"], "attempt not preregistered")
    need(type(timeout_seconds) is int and 1 <= timeout_seconds <= 240,
         "grader timeout outside fixed bounds")
    need(grader.is_file() and not grader.is_symlink() and
         sha_file(grader) == plan["grader_sha256"],
         "private grader does not match frozen bytes")
    need(grader.suffix == ".py", "single-file Python grader required")
    need(not destination.exists() and destination.parent.is_dir(),
         "trusted output must be new and outside workspace")
    # The reference and grader must never be copied into the agent tree.
    need(not seed.is_symlink() and not patch.is_symlink(),
         "symlinked seed/patch input")
    seed = seed.resolve(strict=True)
    grader = grader.resolve(strict=True)
    patch = patch.resolve(strict=True)
    need(not grader.is_relative_to(seed) and
         not patch.is_relative_to(seed), "grader/patch inside task seed")
    need(not destination.resolve(strict=False).is_relative_to(seed),
         "output inside task source")
    targets = patch_paths(patch)
    original_sha = tree_sha256(seed)
    need(original_sha == plan["candidate_tree_sha256"],
         "candidate seed changed since plan freeze")

    image = plan["runner_image_digest"]
    need(image.startswith("sha256:") and HEX_SHA.fullmatch(image[7:]),
         "unusable runner image ID")
    inspected = subprocess.run(
        [docker, "image", "inspect", "--format", "{{.Id}}", image],
        capture_output=True, text=True, timeout=15, check=False)
    need(inspected.returncode == 0 and inspected.stdout.strip() == image,
         "the precise frozen container image is not locally available")
    need(hasattr(os, "getuid") and os.getuid() != 0,
         "refuse to grade as root host user")
    uid = f"{os.getuid()}:{os.getgid()}"
    with tempfile.TemporaryDirectory(prefix="nightfall-grader-") as tempdir:
        workspace = Path(tempdir) / "work"
        locked_patch = Path(tempdir) / "submitted.patch"
        locked_grader = Path(tempdir) / "score.py"
        shutil.copyfile(patch, locked_patch)
        shutil.copyfile(grader, locked_grader)
        need(sha_file(locked_grader) == plan["grader_sha256"] and
             sha_file(locked_patch) == sha_file(patch),
             "grader/patch bytes drifted during custody copy")
        locked_grader.chmod(0o444)
        shutil.copytree(seed, workspace)
        need(tree_sha256(workspace) == original_sha,
             "source copy changed before patch")
        for phase in (["--check"], []):
            result = subprocess.run(
                ["git", "apply", *phase, str(locked_patch)],
                cwd=workspace, capture_output=True, text=True,
                timeout=15, check=False)
            need(result.returncode == 0, "submitted patch failed git apply")
        # Re-check to reject symlink additions, paths outside the seed, etc.
        final_sha = tree_sha256(workspace)
        need(all((workspace / rel).resolve(strict=False).is_relative_to(workspace)
                 for rel in targets), "patch escapes worktree")
        name = "nf-grader-" + uuid.uuid4().hex[:16]
        cmd = [
            docker, "run", "--rm", "--name", name, "--pull", "never",
            "--network", "none", "--read-only", "--cap-drop", "ALL",
            "--security-opt", "no-new-privileges", "--pids-limit", "64",
            "--memory", "768m", "--cpus", "1",
            "--user", uid, "--tmpfs", "/tmp:rw,nosuid,nodev,size=64m",
            "--volume", str(workspace) + ":/work:rw",
            "--volume", str(locked_grader) + ":/opt/grader/score.py:ro",
            "--workdir", "/work", "--env", "PYTHONDONTWRITEBYTECODE=1",
            image, "python3", "-I", "/opt/grader/score.py", "/work",
        ]
        try:
            code, output, seconds = limited_process(cmd, timeout_seconds)
            need(code == 0, "executed grader failed with nonzero exit")
            grade = validate_result(output, plan, attempt_id)
        finally:
            # --rm normally cleans up. Force-remove if stopped Docker CLI left it.
            subprocess.run([docker, "rm", "-f", name], capture_output=True,
                           timeout=12, check=False)
        grade_bytes = (json.dumps(grade, sort_keys=True,
                                  separators=(",", ":")) + "\n").encode()
        grade_sha = hashlib.sha256(grade_bytes).hexdigest()
        custody = {
            "schema": "nightfall.eval.local-grader-capture.v1",
            "status": "trusted_host_local_execution_not_independent_attestation",
            "plan_sha256": externally_pinned_plan_sha256,
            "task_id": plan["task_id"],
            "attempt_id": attempt_id,
            "image_id": image,
            "original_candidate_tree_sha256": original_sha,
            "patched_candidate_tree_sha256": final_sha,
            "submitted_patch_sha256": sha_file(locked_patch),
            "grader_sha256": sha_file(locked_grader),
            "grade_json_sha256": grade_sha,
            "grader_exit_code_observed": code,
            "grader_duration_seconds": round(seconds, 3),
            "network_disabled": True,
            "agent_model_not_run_by_this_script": True,
            "grader_file_never_in_agent_workspace": True,
            "not_authenticated_against_malicious_host": True,
        }
        # Write only after a successful executable grader run, never partial scores.
        destination.mkdir(mode=0o700)
        (destination / "grade.json").write_bytes(grade_bytes)
        (destination / "capture.json").write_text(
            json.dumps(custody, indent=2, sort_keys=True) + "\n",
            encoding="utf-8")
        return custody


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--plan", type=Path, required=True)
    ap.add_argument("--externally-pinned-plan-sha256", required=True)
    ap.add_argument("--attempt-id", required=True)
    ap.add_argument("--seed", type=Path, required=True)
    ap.add_argument("--patch", type=Path, required=True)
    ap.add_argument("--private-grader", type=Path, required=True)
    ap.add_argument("--output", type=Path, required=True)
    ap.add_argument("--timeout", type=int, default=90)
    args = ap.parse_args()
    try:
        result = capture(args.plan, args.externally_pinned_plan_sha256,
                         args.attempt_id, args.seed, args.patch,
                         args.private_grader, args.output, args.timeout)
    except (InvalidEvidence, OSError, subprocess.SubprocessError) as exc:
        print(json.dumps({"status": "REJECT", "reason": str(exc)}))
        raise SystemExit(1)
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
