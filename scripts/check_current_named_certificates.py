#!/usr/bin/env python3
"""Fail-closed offline integrity audit for the 2026-11-14 current Lean certificate index.

This checks exact source Git blob SHA-1, separately scoped PR-head receipts,
and preserved historical eight Q2 entries. It NEVER calls Lean or GitHub:
a PASS is not a new kernel compilation, reviewer decision, or novelty proof.
"""
from __future__ import annotations
import argparse
import copy
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INDEX = Path("docs/current-lean-proof-receipts-20261114.json")
CUSTODY = Path("docs/lean-pending-source-custody.json")
HISTORICAL_Q2 = Path("docs/q2-source-lean-certificate-20261114.json")
EXPECTED = {494: (43627249467, 3), 495: (43630294034, 3),
            496: (43630623548, 6), 497: (43629420558, 2),
            500: (43632243900, 1), 501: (43631863039, 1),
            503: (43632931330, 2), 506: (43632637271, 1),
            498: (43633180605, 4)}
PIN = "leanprover/lean4:v4.36.0-rc2"
MATHLIB = "9d581dfff2e41de989072ea63abf3daf69311520"
AXIOMS = {"Classical.choice", "Quot.sound", "propext"}


def demand(condition: bool, reason: str) -> None:
    if not condition:
        raise ValueError(reason)


def git_blob(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()


def audit(index: dict, custody: dict, historical: dict, root: Path) -> dict:
    demand(index.get("schema") == "nightfall-current-named-lean-proof-receipts-v1",
           "invalid current certificate index schema")
    demand(index.get("pin", {}).get("lean") == PIN, "compiler pin changed")
    demand(index.get("pin", {}).get("mathlib_commit") == MATHLIB, "Mathlib pin changed")
    demand(set(index.get("pin", {}).get("allowed_axioms", [])) == AXIOMS,
           "unexpected axiom allowlist")
    demand(historical.get("schema") == "nightfall-q2-source-named-lean-certificate-v1",
           "missing immutable Q2 named certificate")
    demand(len(historical.get("stages", [])) == 8,
           "historical Q2 eight-stage source receipt changed")
    demand(custody.get("schema") == "nightfall-lean-pending-source-custody-v1",
           "custody schema changed")
    rows = custody.get("sources", [])
    old = [r for r in rows if "current_named_declaration_certificate" in r]
    new = [r for r in rows if "current_scoped_named_lean_receipt" in r]
    demand(len(old) == 8, "legacy Q2 exact-eight named certificate field changed")
    demand(len(new) == 23, "unexpected current scoped receipt coverage")
    by_path = {r["path"]: r for r in rows}
    demand(len(by_path) == len(rows), "duplicate custody source path")
    seen = set()
    for group in index.get("new_proof_groups", []):
        pr = group.get("pr")
        demand(pr in EXPECTED, "unknown merged PR in current certificate index")
        demand(pr not in seen, "duplicated merged PR evidence group")
        seen.add(pr)
        run, count = EXPECTED[pr]
        demand(group.get("run") == run, f"misidentified current run for #{pr}")
        demand(group.get("artifact_id", 0) > 0, f"artifact missing for #{pr}")
        digest = group.get("artifact_sha256", "")
        demand(isinstance(digest, str) and len(digest) == 64 and
               all(c in "0123456789abcdef" for c in digest),
               f"artifact digest missing or invalid for #{pr}")
        demand(group.get("run_url") ==
               f"https://github.com/d3lefts/d3lefts/actions/runs/{run}",
               f"run URL mismatch for #{pr}")
        mods = group.get("source_modules", [])
        demand(len(mods) == count, f"unexpected number of source modules #{pr}")
        for mod in mods:
            p = mod["path"]
            demand(p.startswith("research/nightfall/formalization/") and
                   p.endswith(".lean") and ".." not in Path(p).parts,
                   "invalid Lean source path")
            demand(p not in seen, "duplicate current source module")
            seen.add(p)
            rec = by_path.get(p)
            demand(rec is not None, f"missing current custody source {p}")
            demand(rec.get("classification") == "unreviewed-source" and
                   rec.get("ci_source_match_status") == "no-verified-receipt" and
                   rec.get("global_priority") == "unverified",
                   "improper historical/novelty status promotion")
            scoped = rec.get("current_scoped_named_lean_receipt", {})
            demand(scoped.get("certificate") == str(INDEX) and
                   scoped.get("run") == run and
                   scoped.get("named_declaration") ==
                   mod["representative_named_declaration"] and
                   scoped.get("source_commit") == group["head_sha"],
                   f"source/receipt mismatch for {p}")
            path = root / p
            demand(path.is_file(), f"source missing: {p}")
            sha = git_blob(path.read_bytes())
            demand(sha == mod["git_blob_sha1"] ==
                   rec.get("source_blob_sha"),
                   f"Git source blob changed: {p}")
    demand(seen.intersection(EXPECTED) == set(EXPECTED),
           "current source family missing")
    demand(len([x for x in seen if isinstance(x, str)]) == 23,
           "current indexed source count mismatch")
    flags = index.get("status", {})
    demand(flags.get("independent_human_review") is False and
           flags.get("global_novelty") is False and
           flags.get("full_infinite_product_theorem") is False and
           flags.get("full_source_matched_SCIF_terminal") is False and
           flags.get("physical_agent_enforcement") is False,
           "unjustified certification/novelty promotion")
    return {"status": "PASS", "scoped_prs": 9, "current_source_hashes": 23,
            "historical_q2_stages_preserved": 8,
            "scope": "offline integrity only; no new Lean kernel build"}


def self_test(index: dict, custody: dict, historical: dict) -> None:
    cases = []
    a = copy.deepcopy(index)
    a["new_proof_groups"][0]["source_modules"][0]["git_blob_sha1"] = "0"*40
    cases.append(("source-hash tamper", a, custody, historical))
    a = copy.deepcopy(index)
    a["new_proof_groups"][1]["run"] = 1
    cases.append(("run spoof", a, custody, historical))
    a = copy.deepcopy(index)
    a["status"]["full_infinite_product_theorem"] = True
    cases.append(("infinite theorem inflation", a, custody, historical))
    a = copy.deepcopy(index)
    c = copy.deepcopy(custody)
    for rec in c["sources"]:
        if "current_scoped_named_lean_receipt" in rec:
            rec["ci_source_match_status"] = "same-git-blob-as-successful-ci-head"
            break
    cases.append(("historical scope promotion", a, c, historical))
    for name, idx, cus, hist in cases:
        try:
            audit(idx, cus, hist, ROOT)
        except ValueError:
            continue
        raise ValueError(f"negative control failed open: {name}")
    print(f"PASS: {len(cases)} certificate integrity negative controls")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    index = json.loads((ROOT / INDEX).read_text(encoding="utf-8"))
    custody = json.loads((ROOT / CUSTODY).read_text(encoding="utf-8"))
    hist = json.loads((ROOT / HISTORICAL_Q2).read_text(encoding="utf-8"))
    try:
        result = audit(index, custody, hist, ROOT)
        print(json.dumps(result, sort_keys=True))
        if args.self_test:
            self_test(index, custody, hist)
    except ValueError as e:
        parser.exit(1, f"FAIL: {e}\n")


if __name__ == "__main__":
    main()
