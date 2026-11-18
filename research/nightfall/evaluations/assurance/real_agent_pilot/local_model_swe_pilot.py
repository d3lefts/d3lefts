#!/usr/bin/env python3
"""Real local-model SWE *calibration* with mediated tools and no private grader.

- Real Ollama inference + real read/write/test tools.
- Code executes only in Docker with no network and no workflow credentials.
- A public smoke pass is never a scored or validated benchmark result.
- Output private candidate patches + full raw transcript to separate custody.
"""
from __future__ import annotations
import argparse
import difflib
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import tempfile
import time
from urllib.request import Request, urlopen

MODEL = "qwen2.5-coder:3b"
MAX_STEPS = 9
MAX_WALL = 900
MAX_CHARS = 18000
ALLOWED_TASKS = {
    "DispatchQ-B1": "dispatchq",
    "ArtifactGraph-B2": "artifactgraph",
}


class PilotFailure(RuntimeError):
    pass


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def canonical(data):
    return (json.dumps(data, sort_keys=True, separators=(",", ":"), ensure_ascii=False) + "\n").encode()


def model_meta(endpoint):
    with urlopen(endpoint + "/api/tags", timeout=20) as response:
        metadata = json.load(response)
    matching = [m for m in metadata["models"] if m["name"] == MODEL]
    if len(matching) != 1:
        raise PilotFailure("expected exactly one preloaded local model")
    digest = matching[0].get("digest")
    if not isinstance(digest, str) or not re.fullmatch(r"[a-f0-9]{64}", digest):
        raise PilotFailure("model weights are not digest-pinned by local metadata")
    return {"model": MODEL, "digest": digest}


def list_files(root: Path):
    output = []
    for f in sorted(root.rglob("*")):
        if f.is_symlink():
            raise PilotFailure("symlink in candidate source")
        if f.is_file():
            p = f.relative_to(root).as_posix()
            if ".git" in PurePosixPath(p).parts or "__pycache__" in PurePosixPath(p).parts:
                continue
            output.append(p)
    return output


def guarded_file(root: Path, path, *, write=False, package=None):
    if type(path) is not str or not path or len(path) > 200:
        raise PilotFailure("invalid path")
    rel = PurePosixPath(path)
    if rel.is_absolute() or rel.as_posix() != path or any(
        p in (".", "..", ".git", "__pycache__") for p in rel.parts
    ):
        raise PilotFailure("unsafe path")
    if write and not (len(rel.parts) == 2 and
                      rel.parts[0] == package and rel.parts[1].endswith(".py")):
        raise PilotFailure("only existing package Python implementation files may be edited")
    target = root / path
    if target.is_symlink() or not target.is_file() or not target.resolve().is_relative_to(root.resolve()):
        raise PilotFailure("file unavailable or symlinked")
    if target.stat().st_size > MAX_CHARS:
        raise PilotFailure("large file prohibited")
    return target


def docker_smoke(root: Path, docker_image: str, timeout=75):
    """Constant command; model never controls argv or executes host code."""
    cmd = [
        "docker", "run", "--rm", "--network", "none", "--pull", "never",
        "--read-only", "--cap-drop", "ALL", "--security-opt", "no-new-privileges",
        "--pids-limit", "64", "--memory", "768m", "--cpus", "1",
        "--user", "65534:65534", "--tmpfs", "/tmp:rw,nosuid,nodev,size=64m",
        "-e", "PYTHONDONTWRITEBYTECODE=1",
        "-v", str(root.resolve()) + ":/task:ro", "-w", "/task",
        docker_image, "python3", "-m", "unittest", "discover", "-s", "tests", "-v",
    ]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True,
                              timeout=timeout, check=False)
    except subprocess.TimeoutExpired:
        return {"status": "timeout", "exit_code": None, "tail": "public smoke timed out"}
    output = (proc.stdout + "\n" + proc.stderr)[-3500:]
    return {"status": "completed", "exit_code": proc.returncode,
            "tail": output}


def tool_action(root: Path, action, package, docker_image):
    if type(action) is not dict:
        raise PilotFailure("model action is not a JSON object")
    tool = action.get("tool")
    if tool == "list_files":
        return {"files": list_files(root)}
    if tool == "read_file":
        target = guarded_file(root, action.get("path"))
        return {"path": action["path"], "content": target.read_text(encoding="utf-8")}
    if tool == "write_file":
        target = guarded_file(root, action.get("path"), write=True, package=package)
        text = action.get("content")
        if type(text) is not str or not (10 <= len(text) <= MAX_CHARS):
            raise PilotFailure("replacement Python file too large or invalid")
        if "\0" in text:
            raise PilotFailure("NUL bytes forbidden")
        target.write_text(text, encoding="utf-8")
        return {"path": action["path"], "sha256": sha(text.encode()),
                "bytes": len(text.encode()), "result": "implementation file overwritten"}
    if tool == "run_smoke":
        return docker_smoke(root, docker_image)
    if tool == "finish":
        return {"finished": True}
    raise PilotFailure("tool not in fixed allowlist")


def inference(endpoint, messages):
    body = {
        "model": MODEL, "stream": False, "format": "json",
        "messages": messages,
        "options": {"temperature": 0.2, "seed": 20261118,
                    "top_p": 0.8, "num_ctx": 8192, "num_predict": 1850},
    }
    req = Request(endpoint + "/api/chat", data=json.dumps(body).encode(),
                  headers={"Content-Type": "application/json"})
    t = time.monotonic()
    with urlopen(req, timeout=270) as response:
        result = json.load(response)
    answer = result["message"]["content"]
    if not isinstance(answer, str) or len(answer) > 25000:
        raise PilotFailure("oversized or missing model output")
    try:
        parsed = json.loads(answer)
    except (ValueError, TypeError) as exc:
        raise PilotFailure("model response not JSON") from exc
    return parsed, answer, {
        "seconds": round(time.monotonic() - t, 3),
        "eval_tokens": result.get("eval_count"),
        "prompt_tokens": result.get("prompt_eval_count"),
        "response_model": result.get("model"),
    }


def make_patch(baseline: dict[str, bytes], changed: dict[str, bytes]):
    """Avoid running git hooks or Python from generated source."""
    chunks = []
    for file in sorted(baseline):
        old, new = baseline[file], changed[file]
        if old == new:
            continue
        old_lines = old.decode("utf-8").splitlines(keepends=True)
        new_lines = new.decode("utf-8").splitlines(keepends=True)
        chunks.append("diff --git a/" + file + " b/" + file + "\n")
        chunks.extend(difflib.unified_diff(old_lines, new_lines,
                      fromfile="a/" + file, tofile="b/" + file))
    return "".join(chunks).encode("utf-8")


def run(task, source, output, image_id, endpoint, *, steps=MAX_STEPS):
    if task not in ALLOWED_TASKS or not 1 <= steps <= MAX_STEPS:
        raise PilotFailure("unregistered task or budget")
    root = Path(source).resolve(strict=True)
    out = Path(output)
    if out.exists():
        raise PilotFailure("output directory already exists; cannot overwrite attempt")
    if not root.is_dir() or any(p.is_symlink() for p in root.rglob("*")):
        raise PilotFailure("source must be regular files without symlinks")
    issue = (root / "ISSUE.md").read_text(encoding="utf-8")
    package = ALLOWED_TASKS[task]
    files = list_files(root)
    baseline = {p: (root / p).read_bytes() for p in files}
    source_hash = sha(canonical({p: sha(v) for p, v in baseline.items()}))
    model = model_meta(endpoint)
    init = (
        "You are a local coding model performing a genuine mediated-tool SWE repair. "
        "The only executable tools are list_files, read_file, write_file, run_smoke, finish. "
        "Always emit exactly ONE JSON object, no markdown. Tool schemas: "
        '{"tool":"list_files"}, {"tool":"read_file","path":"relative/name.py"}, '
        '{"tool":"write_file","path":"package/module.py","content":"complete replacement file"}, '
        '{"tool":"run_smoke"}, {"tool":"finish"}. '
        "You may only overwrite existing implementation .py files in the package. "
        "Do not edit tests or ISSUE.md. You must call a real tool before finishing. "
        "The public tests are shallow; obey the full issue contract. "
        "Do not claim private grader scores. After a write, use run_smoke. "
        "No shell commands, external packages or network."
    )
    messages = [
        {"role": "system", "content": init},
        {"role": "user", "content": "Solve this task:\n" + issue +
         "\nVisible files:\n" + "\n".join(files) + "\nStart with a tool call."},
    ]
    transcript = []
    write_count = 0
    smoke_calls = 0
    tool_calls = 0
    reason = "budget_exhausted"
    start = time.monotonic()
    with tempfile.TemporaryDirectory(prefix="nf-agent-real-") as td:
        work = Path(td) / "candidate"
        shutil.copytree(root, work)
        for turn in range(steps):
            if time.monotonic() - start > MAX_WALL:
                reason = "wall_budget_exhausted"
                break
            try:
                action, answer, meta = inference(endpoint, messages)
            except Exception as exc:
                reason = "inference_failed:" + type(exc).__name__
                transcript.append({"turn": turn, "error": str(exc)[:300]})
                break
            event = {"turn": turn, "raw_model_response": answer,
                     "model_metadata": meta, "proposed_tool": action}
            try:
                result = tool_action(work, action, package, image_id)
                tool_calls += 1
                if action["tool"] == "write_file":
                    write_count += 1
                if action["tool"] == "run_smoke":
                    smoke_calls += 1
                event["tool_result"] = result
                if action["tool"] == "finish":
                    reason = "model_finished"
                    transcript.append(event)
                    break
            except (PilotFailure, UnicodeError, OSError) as exc:
                result = {"tool_error": str(exc)[:400]}
                event["tool_result"] = result
            transcript.append(event)
            messages.append({"role": "assistant", "content": answer})
            messages.append({"role": "user", "content":
                "The trusted mediator returned: " + json.dumps(result)[:11000] +
                "\nChoose your next JSON tool action."})
        after = {p: (work / p).read_bytes() for p in baseline}
        changed = [p for p in baseline if baseline[p] != after[p]]
        patch = make_patch(baseline, after)
        # ALWAYS grade public smoke after agent, even if model never edited.
        # This is NOT the held-out grader and not a benchmark score.
        smoke = docker_smoke(work, image_id, timeout=75)
    report = {
        "schema": "nightfall.swe.real-local-model-calibration.v1",
        "task": task,
        "model_name": MODEL,
        "model_digest": model["digest"],
        "candidate_source_sha256": source_hash,
        "issue_sha256": sha(issue.encode()),
        "docker_image_id": image_id,
        "steps_allowed": steps,
        "tool_calls_executed": tool_calls,
        "source_writes_executed": write_count,
        "smoke_tool_calls": smoke_calls,
        "changed_files": changed,
        "patch_sha256": sha(patch),
        "raw_transcript_sha256": sha(canonical(transcript)),
        "finish_reason": reason,
        "elapsed_seconds": round(time.monotonic() - start, 3),
        "public_smoke_exit_code": smoke["exit_code"],
        "public_smoke_status": smoke["status"],
        "no_private_grader_executed": True,
        "blind_agent_score": None,
        "external_review": False,
        "status": "genuine_local_model_tool_trial_unscored",
        "ceiling": "NOT_A_VALIDATED_BLIND_BENCHMARK",
    }
    out.mkdir(parents=True)
    # Source code and full transcript are not committed into public Git history.
    # CI artifact access remains a separate trust decision by the project owner.
    (out / "PRIVATE_RAW_TRANSCRIPT.json").write_bytes(canonical(transcript))
    (out / "PRIVATE_CANDIDATE_PATCH.diff").write_bytes(patch)
    (out / "PUBLIC_CALIBRATION_RECEIPT.json").write_bytes(canonical(report))
    (out / "PUBLIC_SMOKE_OUTPUT.txt").write_text(smoke["tail"][-3500:])
    print(json.dumps(report, sort_keys=True), flush=True)
    return report


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--task", choices=sorted(ALLOWED_TASKS), required=True)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--docker-image-id", required=True)
    parser.add_argument("--ollama-endpoint", default="http://127.0.0.1:11434")
    parser.add_argument("--steps", type=int, default=MAX_STEPS)
    args = parser.parse_args()
    run(args.task, args.source, args.output, args.docker_image_id,
        args.ollama_endpoint, steps=args.steps)


if __name__ == "__main__":
    main()
