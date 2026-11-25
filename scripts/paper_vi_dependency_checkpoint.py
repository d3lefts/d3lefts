#!/usr/bin/env python3
"""Exact-key AA/Q2 + Route1 compiler checkpoint; never a theorem receipt."""
import hashlib
import json
import os
import platform
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path.cwd()
ML = Path("/tmp/mathlib4")
LIB = ML / ".lake/build/lib/lean"
CACHE = Path("/tmp/nightfall-paper-vi-deps-v1")
CLOSURE = Path("research/nightfall/formalization/aa_product/CLOSURE.txt")
BASE = Path("research/nightfall/formalization/product_space")
ROUTE = """Route1LatentDegree Route1DegreeSourceBridge Route1FiniteMaxCoupling
Route1FiniteJointMass Route1MaximalConditionalKernel Route1StarCoupling
Route1StarMaximalBridge Route1PolylogTools Route1Entropy Route1KeyLemma
Route1Lift Route1PolylogSimulation Route1WynerSimulation Route1WynerGeneral""".split()

def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def canonical(x):
    return (json.dumps(x, sort_keys=True, separators=(",", ":")) + "\n").encode()

def modules():
    rows = [tuple(line.split()) for line in CLOSURE.read_text().splitlines() if line.strip()]
    rows += [(m, str(BASE / (m + ".lean"))) for m in ROUTE]
    seen = set()
    for m, p in rows:
        assert re.fullmatch(r"[A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)*", m), m
        assert m not in seen, m
        seen.add(m)
        assert Path(p).is_file() and (ROOT / p).resolve().is_relative_to(ROOT), p
    return rows

def inputs():
    return {
        "schema": 1,
        "platform": [platform.system(), platform.machine()],
        "compiler": subprocess.check_output(["lean", "--version"], text=True).strip(),
        "mathlib_commit": subprocess.check_output(["git", "-C", str(ML), "rev-parse", "HEAD"], text=True).strip(),
        "mathlib_manifest": digest(ML / "lake-manifest.json"),
        "lock": digest(Path("docs/lean-compiler-lock.json")),
        "toolchain": digest(Path("lean-toolchain")),
        "builder": digest(Path(__file__)),
        "closure": digest(CLOSURE),
        "modules": [[m, p, digest(Path(p))] for m, p in modules()],
    }

def rel(m):
    return Path(*m.split("."))

def artifacts(r):
    # Lean may emit split .olean data and .ilean alongside the .olean.
    d = LIB / r.parent
    return sorted(p for p in d.glob(r.name + ".*") if p.is_file() and
                  (p.name.startswith(r.name + ".olean") or p.name == r.name + ".ilean"))

def copy_source(m, p):
    dest = ML / rel(m).with_suffix(".lean")
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(p, dest)

def build():
    if CACHE.exists():
        shutil.rmtree(CACHE)
    (CACHE / "files").mkdir(parents=True)
    (CACHE / "logs").mkdir()
    (CACHE / "inputs.json").write_bytes(canonical(inputs()))
    for m, p in modules():
        r = rel(m)
        copy_source(m, p)
        (LIB / r.parent).mkdir(parents=True, exist_ok=True)
        for old in artifacts(r):
            old.unlink()
        out = LIB / r.with_suffix(".olean")
        log = CACHE / "logs" / (m + ".log")
        print("compile", m, flush=True)
        with log.open("w") as f:
            proc = subprocess.run(["lake", "env", "lean", "-o", str(out), str(ML / r.with_suffix(".lean"))],
                cwd=ML, env={**os.environ, "LEAN_NUM_THREADS": "1"}, stdout=f, stderr=subprocess.STDOUT)
        s = log.read_text(errors="replace")
        if proc.returncode or re.search(r"(^|:)error:|declaration uses .sorry", s, re.M):
            print(s)
            raise SystemExit("compiler failed: " + m)
        assert out.is_file() and out.stat().st_size, m
        for a in artifacts(r):
            dest = CACHE / "files" / a.relative_to(LIB)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(a, dest)
    manifest = {str(p.relative_to(CACHE)): digest(p) for folder in ["files", "logs"]
                for p in (CACHE / folder).rglob("*") if p.is_file()}
    (CACHE / "manifest.json").write_bytes(canonical(manifest))

def install(receipts):
    assert (CACHE / "inputs.json").read_bytes() == canonical(inputs()), "checkpoint input mismatch"
    manifest = json.loads((CACHE / "manifest.json").read_text())
    actual = {str(p.relative_to(CACHE)): digest(p) for folder in ["files", "logs"]
              for p in (CACHE / folder).rglob("*") if p.is_file()}
    assert actual == manifest, "checkpoint artifact mismatch"
    for m, p in modules():
        r = rel(m)
        assert str(Path("files") / r.with_suffix(".olean")) in manifest, m
        assert str(Path("logs") / (m + ".log")) in manifest, m
        copy_source(m, p)
        for old in artifacts(r):
            old.unlink()
    for p in (CACHE / "files").rglob("*"):
        if p.is_file():
            dest = LIB / p.relative_to(CACHE / "files")
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(p, dest)
    receipts.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(CACHE / "inputs.json", receipts / "dependency-inputs.json")
    shutil.copyfile(CACHE / "manifest.json", receipts / "dependency-artifacts.json")
    for m in ROUTE:
        shutil.copyfile(CACHE / "logs" / (m + ".log"), receipts / (m + ".log"))
    print("Installed exact-key dependency checkpoint; terminal replay still required.", flush=True)

if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "key":
        print("key=nightfall-aa-q2-route1-v1-" + hashlib.sha256(canonical(inputs())).hexdigest())
    elif cmd == "build":
        build()
    elif cmd == "install":
        install(Path(sys.argv[2]))
    else:
        raise SystemExit("unknown command")
