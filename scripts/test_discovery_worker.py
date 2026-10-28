#!/usr/bin/env python3
"""Small independent test harness for the Discovery Engine worker integrity gate."""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import zipfile

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"research/nightfall/discovery-engine"))
from runner import FILES,parse_package,execute

def digest(data):
    return hashlib.sha256(data).hexdigest()

def compact(data):
    return json.dumps(data,ensure_ascii=False,separators=(",",":")).encode()

with tempfile.TemporaryDirectory() as d:
    dest=Path(d)/"fixture.zip"
    plan={"schema":"1.0.0","project":"sourcebound","contract":{"objective":"finite test"},
          "representation":"r0","operator":"dual","prediction":"finite pass",
          "discriminator":"deliberate hash mutation rejected","cost":"low",
          "config":{"n":19,"mass":7,"seed":42,"steps":200},"created":"2026-10-28T00:00:00.000Z"}
    exp={"id":"test-001","created":plan["created"],"operator":"dual","repId":"r0",
         "prediction":"finite pass","discriminator":plan["discriminator"],"cost":"low",
         "plan":plan,"prereg_hash":digest(compact(plan))}
    files={
      "README.md":b"test\n",
      "problem.json":json.dumps({"id":"sourcebound"}).encode(),
      "representations.json":b"[]\n",
      "operator-registry.json":b"[]\n",
      "experiments.json":json.dumps([exp]).encode(),
      "verification.json":b"[]\n",
      "HANDOFF.md":b"test\n",
    }
    manifest={"schema":"1.0.0","hash_algorithm":"SHA-256",
              "files":{k:digest(v) for k,v in files.items()}}
    files["manifest.json"]=json.dumps(manifest).encode()
    with zipfile.ZipFile(dest,"w") as z:
        for k,v in files.items():z.writestr(k,v)
    project,entries,loaded=parse_package(dest)
    assert project=="sourcebound" and entries[0]["id"]==exp["id"]
    receipt=execute(project,entries[0],120)
    assert receipt["verdict"]=="PASS",receipt
    assert len(receipt["source_hashes"])==1
    assert len(receipt["steps"])==1
    files["experiments.json"]=files["experiments.json"].replace(b"finite pass",b"false pass")
    with zipfile.ZipFile(dest,"w") as z:
        for k,v in files.items():z.writestr(k,v)
    try:parse_package(dest)
    except ValueError as err:assert "SHA-256" in str(err)
    else:raise AssertionError("Tamper was accepted")
print("PASS: Discovery worker plan, allowlisted exact external replay, tamper rejection")
