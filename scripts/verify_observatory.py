#!/usr/bin/env python3
"""NIGHTFALL Observatory evidence, transfer and frozen-identity audit.
Standard library only. Mechanical integrity gate, not a general theorem prover.
"""
from __future__ import annotations

import copy
from fractions import Fraction as F
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
DIR = ROOT / "research/nightfall/observatory"
GRAPH = DIR / "claims-v1.json"
LOCKS = DIR / "claim-identities.lock.json"
GATES = DIR / "RELEASE_GATES.json"
ALLOWED_TYPES = {
    "proven-implication", "certified-computational-dependency",
    "shared-mathematical-mechanism", "proposed-transfer", "falsified-transfer"
}
ALLOWED_STATES = {
    "certified-finite", "established-method", "empirical-negative",
    "conditional", "candidate", "proposed", "falsified", "withdrawn"
}
# Every claimed proven implication must be individually reviewed, scoped
# and allowlisted. The v1 proof is a classical exact rational demonstration.
ALLOWED_PROVEN = {"TR-001": ("NF-WEIGHTED-SCHUR-v1", "NF-BLOCK-EXAMPLE-v1")}
ALLOWED_COMPUTATIONAL = {"TR-002": ("NF-SIDON30-v1", "NF-SIDON-CHECK-v1")}


def identity_hash(claim: dict) -> str:
    fields = {k: claim[k] for k in ("id", "revision", "statement", "scope", "source_key")}
    canonical = json.dumps(fields, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def safe_file(rel: str) -> bool:
    if not isinstance(rel, str) or not rel or rel.startswith("/") or "\\" in rel:
        return False
    relative = Path(rel)
    return ".." not in relative.parts and (ROOT / relative).is_file()


def exact_positivity_example() -> list[str]:
    errors = []
    b = F(4, 5)
    diagonal = [F(2), F(1), F(2)]
    weights = [F(1), F(2), F(1)]
    margins = [
        diagonal[0] - b * weights[1] / weights[0],
        diagonal[1] - b * (weights[0] + weights[2]) / weights[1],
        diagonal[2] - b * weights[1] / weights[2],
    ]
    if margins != [F(2, 5), F(1, 5), F(2, 5)]:
        errors.append("Exact weighted margins differ from the stated 3-block witness")
    minor1 = diagonal[0]
    minor2 = diagonal[0] * diagonal[1] - b * b
    minor3 = diagonal[0] * diagonal[1] * diagonal[2] - 2 * diagonal[0] * b * b
    if [minor1, minor2, minor3] != [F(2), F(34, 25), F(36, 25)]:
        errors.append("Exact rational Sylvester minors disagree")
    uniform_middle = diagonal[1] - 2 * b
    if uniform_middle != F(-3, 5) or min(margins) != F(1, 5):
        errors.append("Weighted-vs-unweighted comparison incorrect")
    return errors


def validate(graph: dict, locks: dict, gates: dict) -> list[str]:
    errors: list[str] = []
    if graph.get("schema_version") != "1.0.0":
        errors.append("Unsupported graph schema")
    nodes = graph.get("nodes", [])
    edges = graph.get("edges", [])
    if not isinstance(nodes, list) or not isinstance(edges, list):
        return ["Nodes/edges must be arrays"]
    ids = [n.get("id") for n in nodes]
    if len(ids) != len(set(ids)) or len(ids) < 10:
        errors.append("Claim IDs duplicated or catalogue incomplete")
    by_id = {n.get("id"): n for n in nodes}
    frozen = locks.get("claims", {})
    if set(frozen) != set(ids):
        errors.append("Frozen claim identity register mismatches the graph")
    for n in nodes:
        ident = n.get("id", "<missing>")
        required = ("id", "revision", "title", "statement", "scope", "source_key",
                    "status", "owner", "boundary", "identity_sha256",
                    "dependencies", "provenance", "reproduce", "failure_conditions")
        if any(k not in n for k in required):
            errors.append(f"{ident}: missing required claim field")
            continue
        if n["revision"] != 1 or not re.fullmatch(r"NF-[A-Z0-9-]+-v1", ident):
            errors.append(f"{ident}: invalid immutable identity")
        if n["status"] not in ALLOWED_STATES:
            errors.append(f"{ident}: invalid claim status")
        if not all(isinstance(n.get(k), str) and n[k].strip()
                   for k in ("title", "statement", "scope", "source_key", "owner", "boundary")):
            errors.append(f"{ident}: empty scientific claim/scope/owner/boundary")
        if not safe_file(n["source_key"]):
            errors.append(f"{ident}: source artifact missing/unsafe")
        if n["identity_sha256"] != identity_hash(n) or frozen.get(ident) != identity_hash(n):
            errors.append(f"{ident}: frozen identity mismatch; issue a NEW claim identity")
        if not n["reproduce"] or not n["failure_conditions"]:
            errors.append(f"{ident}: missing reproduction/falsification")
        if not n["provenance"] or any(p.get("path") != n["source_key"] or
                                   not isinstance(p.get("revision"), str) or
                                   not p.get("url", "").startswith("https://github.com/d3lefts/d3lefts/blob/")
                                   for p in n["provenance"]):
            errors.append(f"{ident}: missing/invalid provenance")
        for d in n["dependencies"]:
            if d not in by_id or d == ident:
                errors.append(f"{ident}: absent/self proof dependency {d}")
    seen_edges = set()
    for e in edges:
        eid = e.get("id", "<missing>")
        if eid in seen_edges:
            errors.append(f"{eid}: repeated edge identity")
        seen_edges.add(eid)
        for required in ("id", "from", "to", "type", "statement", "assumptions",
                         "evidence", "experiment", "status"):
            if not isinstance(e.get(required), str) or not e[required].strip():
                errors.append(f"{eid}: missing {required}")
        if e.get("from") not in by_id or e.get("to") not in by_id:
            errors.append(f"{eid}: unresolved edge endpoint")
        if e.get("type") not in ALLOWED_TYPES:
            errors.append(f"{eid}: unapproved scientific edge classification")
        if not safe_file(e.get("evidence", "")):
            errors.append(f"{eid}: missing proof/evidence source")
        source_link = e.get("provenance_url", "")
        if not source_link.startswith("https://github.com/d3lefts/d3lefts/blob/") or not source_link.endswith("/" + e.get("evidence", "<missing>")) or "/blob/main/" in source_link:
            errors.append(f"{eid}: missing immutable source revision")
        if e.get("type") == "proven-implication":
            if ALLOWED_PROVEN.get(eid) != (e.get("from"), e.get("to")) or \
               e.get("verifier") != "scripts/verify_observatory.py" or \
               e.get("status") != "reproduced":
                errors.append(f"{eid}: unsupported implication BLOCKED")
        elif e.get("type") == "certified-computational-dependency":
            if ALLOWED_COMPUTATIONAL.get(eid) != (e.get("from"), e.get("to")) or \
               not safe_file(e.get("verifier", "")) or e.get("status") != "reproduced":
                errors.append(f"{eid}: unsupported computational dependency BLOCKED")
        elif e.get("type") == "proposed-transfer" and e.get("status") != "untested":
            errors.append(f"{eid}: proposed transfer incorrectly promoted")
        elif e.get("type") == "falsified-transfer" and e.get("status") != "falsified":
            errors.append(f"{eid}: falsification suppressed")
        elif e.get("type") == "shared-mathematical-mechanism" and e.get("status") != "classified":
            errors.append(f"{eid}: analogy incorrectly promoted")
    if len(seen_edges) < 5 or {e.get("type") for e in edges} != ALLOWED_TYPES:
        errors.append("Each of five required scientific relationship classes must be represented")
    errors.extend(exact_positivity_example())
    gate_records = gates.get("gates", {})
    if set(gate_records) != {"A", "B", "C", "D"}:
        errors.append("Release gate A/B/C/D missing")
    if gate_records.get("D", {}).get("status") != "blocked":
        errors.append("Gate D must stay BLOCKED while B/C lack independently audited receipts")
    if gate_records.get("B", {}).get("status") != "pending" or \
       gate_records.get("C", {}).get("status") != "pending":
        errors.append("Independent B/C evaluations have been promoted without evidence")
    return errors


def self_test(graph: dict, locks: dict, gates: dict) -> list[str]:
    errors = []
    changed = copy.deepcopy(graph)
    changed["nodes"][0]["scope"] += " unverified strengthening"
    if not any("frozen identity mismatch" in msg for msg in validate(changed, locks, gates)):
        errors.append("MUTATION CONTROL failed to catch changed claim scope")
    changed = copy.deepcopy(graph)
    changed["edges"].append({
        "id": "TR-UNAPPROVED", "from": "NF-WERNER6-v1", "to": "NF-SPECTRAL-BRIDGE-v1",
        "type": "proven-implication", "statement": "unsupported transfer",
        "assumptions": "missing", "evidence": "research/nightfall/observatory/TRANSFER_0001.md",
        "experiment": "none", "verifier": "scripts/verify_observatory.py", "status": "reproduced"
    })
    if not any("unsupported implication" in msg for msg in validate(changed, locks, gates)):
        errors.append("MUTATION CONTROL failed to block fabricated implication")
    changed = copy.deepcopy(graph)
    for e in changed["edges"]:
        if e["type"] == "proposed-transfer":
            e["status"] = "reproduced"
            break
    if not any("incorrectly promoted" in msg for msg in validate(changed, locks, gates)):
        errors.append("MUTATION CONTROL failed to block proposed-transfer promotion")
    return errors


def main() -> int:
    graph = json.loads(GRAPH.read_text(encoding="utf-8"))
    locks = json.loads(LOCKS.read_text(encoding="utf-8"))
    gates = json.loads(GATES.read_text(encoding="utf-8"))
    errors = validate(graph, locks, gates) + self_test(graph, locks, gates)
    if errors:
        print("OBSERVATORY GATE A FAILED")
        for issue in errors:
            print(" -", issue)
        return 1
    print(f"PASS: {len(graph['nodes'])} frozen claims, {len(graph['edges'])} typed edges, "
          "five edge classes, exact 3-block fractions, three adversarial mutations")
    print("GATE A: mechanical data integrity PASS (pending external scientific editorial review)")
    print("GATES B/C: PENDING; GATE D: BLOCKED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
