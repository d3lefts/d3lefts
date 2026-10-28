#!/usr/bin/env python3
"""NIGHTFALL Discovery Engine external worker v1.

Runs ONLY fixed, source-controlled scientific checker paths from an exported
Discovery Engine ZIP. Always emits scoped machine-readable receipts.
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
import time
import zipfile

ROOT = Path(__file__).resolve().parents[3]
RUNNERS = {
    "werner": {
        "files": ["research/nightfall/projects/werner-final-4-25/construct_A.py",
                  "research/nightfall/projects/werner-final-4-25/verify_independent.py"],
        "steps": [("construct_A.py",), ("verify_independent.py",)],
        "outputs": ["certificate.json", "COPY4_TO_25.csv"],
        "scope": "Exact conditional rational Werner 4–25 checks. Source 2/3-copy premises remain external."
    },
    "phase": {
        "files": ["research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/verify_tail_A.py",
                  "research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/verify_tail_B.py"],
        "steps": [("verify_tail_A.py",), ("verify_tail_B.py",)],
        "outputs": [],
        "scope": "Downstream finite-field tail identities; original span-count lemma unverified."
    },
    "sidon": {
        "files": ["research/nightfall/projects/sidon-finite-30/verify_sidon30_standalone.py",
                  "research/nightfall/projects/sidon-finite-30/witness_30.txt"],
        "steps": [("verify_sidon30_standalone.py",)],
        "outputs": [],
        "scope": "One exact finite 30-point Sidon instance, not asymptotic novelty."
    },
    "sourcebound": {
        "files": ["research/nightfall/projects/ai-safety-peer-review-2026-10-28/finite_checks.py"],
        "steps": [("finite_checks.py",)],
        "outputs": [],
        "scope": "Small finite oversight assertions, not a held-out SourceBound performance result."
    },
    "ea36": {
        "files": ["scripts/verify_erdos_independent.py"],
        "steps": [("verify_erdos_independent.py", "--self-test")],
        "outputs": [],
        "scope": "Arithmetic checker self-test only; frozen 131072-cell witness remains a separate gate."
    }
}
FILES = ("README.md","problem.json","representations.json","operator-registry.json",
         "experiments.json","verification.json","HANDOFF.md","manifest.json")


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def parse_package(path: Path):
    if path.stat().st_size > 10_000_000:
        raise ValueError("Archive exceeds 10 MB safety limit")
    with zipfile.ZipFile(path) as z:
        if len(z.infolist()) != len(FILES) or set(z.namelist()) != set(FILES):
            raise ValueError("Expected exact eight-file Discovery package")
        if any(i.file_size > 5_000_000 for i in z.infolist()):
            raise ValueError("Oversized ZIP member")
        if z.testzip() is not None:
            raise ValueError("Corrupt ZIP entry")
        blobs = {name:z.read(name) for name in FILES}
    manifest = json.loads(blobs["manifest.json"])
    if manifest.get("schema") != "1.0.0" or manifest.get("hash_algorithm") != "SHA-256":
        raise ValueError("Manifest schema or hashing mismatch")
    hashes = manifest.get("files")
    if not isinstance(hashes,dict) or set(hashes)!=set(FILES)-{"manifest.json"}:
        raise ValueError("Manifest inventory mismatch")
    for name in FILES:
        if name != "manifest.json" and hashes[name] != digest(blobs[name]):
            raise ValueError("SHA-256 failed: " + name)
    problem = json.loads(blobs["problem.json"])
    experiments = json.loads(blobs["experiments.json"])
    if not isinstance(experiments,list) or not experiments:
        raise ValueError("Package has no preregistered experiments")
    project = problem.get("id")
    if project not in RUNNERS:
        raise ValueError("No allowlisted scientific worker for " + str(project))
    for ex in experiments:
        plan = ex.get("plan")
        if not isinstance(plan,dict) or plan.get("project")!=project or plan.get("operator")!=ex.get("operator"):
            raise ValueError("Invalid experiment plan lineage")
        if plan.get("representation")!=ex.get("repId"):
            raise ValueError("Representation mismatch")
        declared = ex.get("prereg_hash")
        packed = json.dumps(plan,ensure_ascii=False,separators=(",",":")).encode("utf-8")
        if declared != digest(packed):
            raise ValueError("Preregistration SHA-256 mismatch: "+str(ex.get("id")))
    return project,experiments,manifest


def execute(project: str, experiment: dict, timeout: int):
    spec=RUNNERS[project]
    receipt={
        "schema":"nightfall.worker.v1",
        "project":project,
        "experiment":experiment["id"],
        "preregistration_sha256":experiment["prereg_hash"],
        "scope":spec["scope"],
        "checked_at_utc":time.strftime("%Y-%m-%dT%H:%M:%SZ",time.gmtime()),
        "execution":"ALLOWLISTED_LOCAL_REPLAY",
        "independent_agent":"PENDING",
        "source_hashes":{},
        "steps":[],
        "outputs":{},
        "verdict":"INCONCLUSIVE"
    }
    with tempfile.TemporaryDirectory(prefix="nightfall-worker-") as tmp:
        work=Path(tmp)
        for path in spec["files"]:
            source=(ROOT/path).resolve()
            if not source.is_file() or not source.is_relative_to(ROOT):
                raise ValueError("Missing allowlisted research file: "+path)
            data=source.read_bytes()
            (work/source.name).write_bytes(data)
            receipt["source_hashes"][path]=digest(data)
        for argv in spec["steps"]:
            args=[sys.executable,*argv]
            try:
                proc=subprocess.run(args,cwd=work,capture_output=True,text=True,timeout=timeout,check=False,
                    env={"PATH":os.environ.get("PATH",""),"PYTHONIOENCODING":"utf-8","PYTHONDONTWRITEBYTECODE":"1"})
                step={"command":[Path(sys.executable).name,*argv],"return_code":proc.returncode,
                      "stdout_tail":proc.stdout[-8000:],"stderr_tail":proc.stderr[-8000:]}
                receipt["steps"].append(step)
                if proc.returncode:
                    receipt["verdict"]="FAIL"
                    return receipt
            except subprocess.TimeoutExpired:
                receipt["steps"].append({"command":list(argv),"timeout_seconds":timeout})
                receipt["verdict"]="INCONCLUSIVE"
                return receipt
        for path in spec["outputs"]:
            f=work/path
            if not f.is_file():
                receipt["verdict"]="FAIL"
                receipt["steps"].append({"missing_artifact":path})
                return receipt
            receipt["outputs"][path]={"sha256":digest(f.read_bytes()),"bytes":f.stat().st_size}
        receipt["verdict"]="PASS"
    return receipt


def main():
    parser=argparse.ArgumentParser(description="Execute an allowlisted NIGHTFALL research checker from a frozen Discovery Engine ZIP.")
    parser.add_argument("package",type=Path)
    parser.add_argument("--experiment",help="Experiment ID; defaults to the last preregistration")
    parser.add_argument("--out",type=Path,default=Path("nightfall-worker-receipt.json"))
    parser.add_argument("--timeout",type=int,default=120,help="Per-step timeout, 1..600 seconds")
    parser.add_argument("--plan-only",action="store_true",help="Validate ZIP and list allowlisted code without executing")
    args=parser.parse_args()
    try:
        if not 1<=args.timeout<=600:raise ValueError("timeout out of range")
        project,experiments,manifest=parse_package(args.package)
        matched=[e for e in experiments if e.get("id")==args.experiment] if args.experiment else experiments[-1:]
        if len(matched)!=1:raise ValueError("Unknown or duplicate experiment ID")
        ex=matched[0]
        if args.plan_only:
            print(json.dumps({"status":"VALID_PREREG","project":project,"experiment":ex["id"],
                              "files":RUNNERS[project]["files"],"steps":RUNNERS[project]["steps"],
                              "scope":RUNNERS[project]["scope"]},indent=2))
            return 0
        receipt=execute(project,ex,args.timeout)
        args.out.parent.mkdir(parents=True,exist_ok=True)
        with tempfile.NamedTemporaryFile(mode="w",dir=args.out.parent,delete=False,encoding="utf-8") as f:
            json.dump(receipt,f,indent=2,sort_keys=True)
            f.write("\n")
            candidate=f.name
        os.replace(candidate,args.out)
        print(json.dumps({"verdict":receipt["verdict"],"experiment":ex["id"],"receipt":str(args.out),
                          "scope":receipt["scope"]},indent=2))
        return 0 if receipt["verdict"]=="PASS" else 1
    except (ValueError,OSError,zipfile.BadZipFile,KeyError,json.JSONDecodeError) as e:
        print("INVALID PACKAGE / RUN: "+str(e),file=sys.stderr)
        return 2


if __name__=="__main__":
    raise SystemExit(main())
