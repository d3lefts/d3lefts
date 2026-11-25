#!/usr/bin/env python3
"""Exact-input AA/Q2 + Route1 dependency checkpoint, not a proof certificate."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

root = Path.cwd()
mathlib = Path("/tmp/mathlib4")
cache = Path("/tmp/nightfall-proof-deps-v1")
lib = mathlib / ".lake/build/lib/lean"
closure = root / "research/nightfall/formalization/aa_product/CLOSURE.txt"
base = "research/nightfall/formalization/product_space"
route = """Route1LatentDegree Route1DegreeSourceBridge Route1FiniteMaxCoupling
Route1FiniteJointMass Route1MaximalConditionalKernel Route1StarCoupling
Route1StarMaximalBridge Route1PolylogTools Route1Entropy Route1KeyLemma
Route1Lift Route1PolylogSimulation Route1WynerSimulation Route1WynerGeneral""".split()

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

entries = [line.split() for line in closure.read_text().splitlines() if line.strip()]
entries += [[m, f"{base}/{m}.lean"] for m in route]
assert len({m for m, _ in entries}) == len(entries)
for m, p in entries:
    assert re.fullmatch(r"[A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)*", m), m
    assert (root / p).resolve().is_relative_to(root.resolve()), p
inputs = {
    "schema": 1,
    "compiler": subprocess.check_output(["lean", "--version"], text=True).strip(),
    "mathlib": subprocess.check_output(["git", "-C", str(mathlib), "rev-parse", "HEAD"], text=True).strip(),
    "platform": [os.environ.get("RUNNER_OS"), os.environ.get("RUNNER_ARCH"), os.environ.get("ImageOS")],
    "inputs": [[p, sha(root/p)] for p in [
        "lean-toolchain", "docs/lean-compiler-lock.json",
        "research/nightfall/formalization/aa_product/CLOSURE.txt",
        "scripts/nightfall_proof_deps_cache.py",
        ".github/actions/setup-nightfall-proof-deps/action.yml"]],
    "modules": [[m, p, sha(root/p)] for m,p in entries],
}
key = hashlib.sha256(json.dumps(inputs, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
mode = sys.argv[1]
if mode == "key":
    with open(os.environ["GITHUB_OUTPUT"], "a") as f:
        print("key=" + key, file=f)
    print("Exact dependency key:", key, "modules:", len(entries))
    sys.exit(0)

def rel(m):
    return Path(*m.split("."))

def copy_source(m,p):
    dst = mathlib / rel(m).with_suffix(".lean")
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists() and dst.read_bytes() != (root/p).read_bytes():
        raise RuntimeError(f"Refusing to overwrite different source: {dst}")
    shutil.copyfile(root/p, dst)

if mode == "build":
    if cache.exists():
        shutil.rmtree(cache)
    cache.mkdir()
    artifacts = {}
    for m,p in entries:
        copy_source(m,p)
        r = rel(m)
        target = lib / r.with_suffix(".olean")
        target.parent.mkdir(parents=True, exist_ok=True)
        cmd = ["lake", "env", "lean", "-o", str(target.relative_to(mathlib)), str(r.with_suffix(".lean"))]
        run = subprocess.run(cmd, cwd=mathlib, env={**os.environ, "LEAN_NUM_THREADS":"1"},
                             stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        log = cache / "logs" / (m + ".log")
        log.parent.mkdir(exist_ok=True)
        log.write_text(run.stdout)
        if run.returncode or re.search(r"(^|:)error:|declaration uses .sorry", run.stdout, re.M):
            print(run.stdout)
            raise RuntimeError(f"Dependency failed: {m}")
        assert target.is_file(), target
        for obj in sorted(target.parent.glob(target.name+"*")):
            if not obj.is_file():
                continue
            relative = obj.relative_to(lib)
            dst = cache / "objects" / relative
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(obj,dst)
            artifacts[str(relative)] = sha(dst)
        print("Compiled", m, flush=True)
    (cache/"manifest.json").write_text(json.dumps({"key":key,"inputs":inputs,"objects":artifacts},sort_keys=True))
elif mode != "restore":
    raise SystemExit("expected key, build, or restore")

manifest = json.loads((cache/"manifest.json").read_text())
assert manifest["key"] == key and manifest["inputs"] == inputs, "source or pin mismatch"
objects = manifest["objects"]
allowed = {str(rel(m).with_suffix(".olean")) for m,_ in entries}
assert allowed <= objects.keys(), "missing primary object"
for name,digest in objects.items():
    assert any(name == a or name.startswith(a+".") for a in allowed), name
    assert (cache/"objects"/name).is_file() and sha(cache/"objects"/name)==digest, name
for m,p in entries:
    copy_source(m,p)
for name in objects:
    dst=lib/name
    dst.parent.mkdir(parents=True,exist_ok=True)
    shutil.copyfile(cache/"objects"/name,dst)
print("Exact dependency checkpoint installed:",key,len(entries),"modules",len(objects),"objects")
