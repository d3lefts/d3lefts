#!/usr/bin/env python3
"""Post-agent PUBLIC contract canary in a no-network Docker sandbox.

No hidden grader. Runs only AFTER model has finished, from an independently
pinned audit tree. This is finite public API coverage, not a blind benchmark.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

from local_model_swe_pilot import ALLOWED_TASKS, PilotFailure, sha


def public_canary(task, source, audit_script, patch, pilot_receipt,
                  output, image_id):
    if task not in ALLOWED_TASKS:
        raise PilotFailure("unregistered task")
    source, audit_script, patch = map(Path,(source,audit_script,patch))
    receipt = json.loads(Path(pilot_receipt).read_text())
    if receipt["task"] != task or sha(patch.read_bytes()) != receipt["patch_sha256"]:
        raise PilotFailure("model-submitted patch identity mismatch")
    if not audit_script.is_file() or audit_script.is_symlink():
        raise PilotFailure("missing independently pinned public canary")
    if Path(output).exists():
        raise PilotFailure("no overriding previous audit receipt")
    auditor_sha = sha(audit_script.read_bytes())
    with tempfile.TemporaryDirectory(prefix="nf-agent-audit-") as d:
        workspace = Path(d) / "project"
        candidate = workspace/"candidate"
        shutil.copytree(source,candidate,symlinks=False)
        a = workspace/"audit"
        a.mkdir(parents=True)
        shutil.copy2(audit_script,a/"public_contract_probe.py")
        if patch.stat().st_size:
            result = subprocess.run(["git","apply","--check",str(patch.resolve())],
                   cwd=candidate, capture_output=True,text=True,timeout=20)
            if result.returncode:
                raise PilotFailure("model patch cannot apply to untouched source")
            result = subprocess.run(["git","apply",str(patch.resolve())],
                   cwd=candidate,capture_output=True,text=True,timeout=20)
            if result.returncode:
                raise PilotFailure("model patch apply failed unexpectedly")
        # Do not load agent-controlled module on the trusted host, even in a
        # subprocess. The public audit importer runs ONLY in locked Docker.
        command = [
            "docker","run","--rm","--network","none","--pull","never",
            "--read-only","--cap-drop","ALL","--security-opt","no-new-privileges",
            "--pids-limit","64","--memory","1g","--cpus","1",
            "--user","65534:65534","--tmpfs","/tmp:rw,nosuid,nodev,size=64m",
            "-e","PYTHONDONTWRITEBYTECODE=1",
            "-v",str(workspace.resolve())+":/task:ro","-w","/task",
            image_id,"python3","-I","/task/audit/public_contract_probe.py",
            "--mode","observe",
        ]
        try:
            p = subprocess.run(command,capture_output=True,text=True,timeout=120)
        except subprocess.TimeoutExpired as exc:
            raise PilotFailure("public auditor timed out") from exc
        if p.returncode != 0:
            raise PilotFailure("isolated public canary failed to run: "+p.stderr[-600:])
        try:
            findings = json.loads(p.stdout)
        except ValueError as exc:
            raise PilotFailure("public canary did not emit JSON") from exc
    if task=="DispatchQ-B1":
        if findings.get("schema")!="nightfall.dispatchq.public-canary.v1":
            raise PilotFailure("wrong B1 audit schema")
        total, passed, failed = (findings.get(k) for k in
                                 ("total_public_checks","passed","failed"))
        bad = 0
    else:
        if findings.get("schema")!="nightfall.artifactgraph.public-audit.v1":
            raise PilotFailure("wrong B2 audit schema")
        total,passed,failed,bad = (findings.get(k) for k in
                                 ("total","positive","violations","errors"))
    if (any(type(x) is not int or x<0 for x in (total,passed,failed,bad)) or
        total != passed+failed+bad or
        total != (13 if task=="DispatchQ-B1" else 20)):
        raise PilotFailure("auditor totals inconsistent")
    result = {
        "schema":"nightfall.swe.independent-public-canary.v1",
        "task":task,
        "candidate_source_sha256":receipt["candidate_source_sha256"],
        "model_patch_sha256":receipt["patch_sha256"],
        "public_auditor_source_sha256":auditor_sha,
        "docker_image_id":image_id,
        "total_public_contract_checks":total,
        "public_contract_checks_passed":passed,
        "public_contract_checks_violated":failed,
        "unexpected_public_audit_errors":bad,
        "no_private_grader_executed":True,
        "blind_agent_score":None,
        "label":"post_agent_independently_authored_public_contract_canary",
        "ceiling":"NOT_PRIVATE_GRADER_NOT_BLIND_BENCHMARK",
    }
    Path(output).write_text(json.dumps(result,sort_keys=True,indent=2)+"\n")
    print(json.dumps(result,sort_keys=True))
    return result


def main():
    p=argparse.ArgumentParser()
    p.add_argument("--task",required=True)
    p.add_argument("--source",type=Path,required=True)
    p.add_argument("--audit-script",type=Path,required=True)
    p.add_argument("--patch",type=Path,required=True)
    p.add_argument("--pilot-receipt",type=Path,required=True)
    p.add_argument("--output",type=Path,required=True)
    p.add_argument("--docker-image-id",required=True)
    a=p.parse_args()
    public_canary(a.task,a.source,a.audit_script,a.patch,
                  a.pilot_receipt,a.output,a.docker_image_id)


if __name__=="__main__":
    main()
