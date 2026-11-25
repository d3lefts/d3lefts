#!/usr/bin/env python3
"""Externally controlled frozen-contract gate for NIGHTFALL Lean bridge receipts.

This is a comparator *wrapper*, not Google's Lean Comparator. The Lean kernel
check remains in lean_bridge.py; this gate prevents candidate changes to the
reviewed contract from being silently accepted and audits its receipt.
"""
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

AXIOMS = {"propext", "Quot.sound", "Classical.choice"}
SHA = re.compile(r"[0-9a-f]{64}\Z")


def git_bytes(ref, path):
    if not re.fullmatch(r"[A-Za-z0-9_./-]+", ref) or ref.startswith("-"):
        raise ValueError("invalid trusted base ref")
    if Path(path).is_absolute() or ".." in Path(path).parts:
        raise ValueError("unsafe contract path")
    return subprocess.check_output(["git", "show", f"{ref}:{path}"])


def validate(contract_bytes, candidate_bytes, receipt, source_bytes):
    if candidate_bytes != contract_bytes:
        raise ValueError("FROZEN_CONTRACT_CHANGED")
    spec = json.loads(contract_bytes)
    if spec.get("schema") != "nightfall-theorem-contract/v1":
        raise ValueError("unknown contract schema")
    targets = spec.get("targets")
    if not isinstance(targets, list) or not targets:
        raise ValueError("missing frozen targets")
    names = [t["declaration"] for t in targets]
    if len(set(names)) != len(names):
        raise ValueError("duplicate targets")
    if receipt.get("status") != "COMPILED" or receipt.get("version_matches_pin") is not True:
        raise ValueError("no successful pinned Lean compilation")
    if receipt.get("source_relpath") != spec.get("source"):
        raise ValueError("source path drift")
    if receipt.get("source_sha256") != hashlib.sha256(source_bytes).hexdigest():
        raise ValueError("source bytes drift")
    if receipt.get("contract_sha256") != hashlib.sha256(contract_bytes).hexdigest():
        raise ValueError("contract digest drift")
    if receipt.get("declarations_requested") != names or receipt.get("contract_targets") != names:
        raise ValueError("target mismatch")
    if spec.get("workspace_commit") and receipt.get("workspace_commit") != spec["workspace_commit"]:
        raise ValueError("workspace drift")
    if receipt.get("policy_findings"):
        raise ValueError("untrusted source tokens")
    if set(receipt.get("explicit_allowed_axioms", [])) - AXIOMS:
        raise ValueError("unexpected axiom allowlist")
    audits = receipt.get("axiom_audit", {})
    deps = receipt.get("axiom_dependencies", {})
    allowed = set(receipt.get("explicit_allowed_axioms", []))
    for name in names:
        if name not in audits or name not in deps:
            raise ValueError("missing axiom evidence")
        if audits[name] not in ("none_reported", "allowlisted_dependencies"):
            raise ValueError("axiom audit unresolved")
        if set(deps[name]) - allowed:
            raise ValueError("axiom dependency outside explicit allowlist")
    return {"status": "FROZEN_CONTRACT_MATCH", "contract_sha256": hashlib.sha256(contract_bytes).hexdigest(),
            "source_sha256": receipt["source_sha256"], "declarations": names,
            "note": "receipt consistency only; Lean compilation must run independently"}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--trusted-base", required=True, help="trusted base git ref, e.g. origin/main")
    p.add_argument("--contract", required=True)
    p.add_argument("--receipt", required=True)
    p.add_argument("--json-out")
    a = p.parse_args()
    root = Path(__file__).resolve().parents[1]
    contract = root / a.contract
    candidate = contract.read_bytes()
    frozen = git_bytes(a.trusted_base, a.contract)
    spec = json.loads(frozen)
    source = (root / spec["source"]).resolve()
    if not source.is_relative_to(root.resolve()) or not source.is_file():
        raise ValueError("invalid source path")
    receipt = json.loads(Path(a.receipt).read_text())
    result = validate(frozen, candidate, receipt, source.read_bytes())
    if a.json_out:
        Path(a.json_out).write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
