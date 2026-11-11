#!/usr/bin/env python3
"""Audit a claim/dependency graph without confusing compilation with closure.

This is an editorial/provenance gate, not a replacement for the Lean kernel.
"""
import argparse
import json
import re
import subprocess
from pathlib import Path

KINDS = {"kernel_scoped", "analytic_only", "conditional", "conjecture", "kernel_closed"}
SCHEMA = "nightfall-proof-graph/v1"


def check(graph, verify_hashes=True):
    if graph.get("schema") != SCHEMA:
        raise ValueError("invalid proof graph schema")
    nodes = graph.get("claims")
    if not isinstance(nodes, list) or not nodes:
        raise ValueError("empty proof graph")
    ids = [n.get("id") for n in nodes if isinstance(n, dict)]
    if len(ids) != len(nodes) or len(ids) != len(set(ids)) or not all(isinstance(x, str) and x for x in ids):
        raise ValueError("duplicate/missing claim id")
    lookup = {n["id"]: n for n in nodes}
    for n in nodes:
        if verify_hashes and n.get("status") == "kernel_scoped":
            blob = n.get("source_git_blob_sha")
            source = n.get("source")
            if not isinstance(blob, str) or re.fullmatch(r"[0-9a-f]{40}", blob) is None or not isinstance(source, str):
                raise ValueError("kernel claim missing pinned source blob: " + n["id"])
            root = Path(__file__).resolve().parents[1]
            path = (root / source).resolve()
            if not path.is_relative_to(root) or not path.is_file():
                raise ValueError("kernel claim source missing or outside repo: " + n["id"])
            actual = subprocess.run(["git", "hash-object", str(path)], cwd=root,
                                    text=True, capture_output=True, check=True).stdout.strip()
            if actual != blob:
                raise ValueError("kernel receipt source changed; invalidate/review: " + n["id"])
        kind = n.get("status")
        if kind not in KINDS:
            raise ValueError("unrecognized status for " + n["id"])
        deps = n.get("depends_on", [])
        if not isinstance(deps, list) or len(set(deps)) != len(deps):
            raise ValueError("duplicate/bad dependencies for " + n["id"])
        if any(dep not in lookup for dep in deps):
            raise ValueError("unresolved dependency for " + n["id"])
        obligations = n.get("open_obligations", [])
        if not isinstance(obligations, list):
            raise ValueError("invalid obligations")
        if n.get("promoted_full"):
            if kind != "kernel_closed" or obligations:
                raise ValueError("premature full theorem promotion: " + n["id"])
            if not n.get("exact_type_contract") or not n.get("kernel_receipt"):
                raise ValueError("full theorem missing exact-type contract/receipt")
            for dep in deps:
                if lookup[dep]["status"] not in ("kernel_scoped", "kernel_closed"):
                    raise ValueError("full theorem depends on unproved premise: " + dep)
        if kind == "kernel_closed" and (obligations or not n.get("exact_type_contract")):
            raise ValueError("invalid kernel_closed certification: " + n["id"])
    colors = {}
    def visit(i):
        if colors.get(i) == "gray":
            raise ValueError("cyclic dependency at " + i)
        if colors.get(i) == "black":
            return
        colors[i] = "gray"
        for j in lookup[i].get("depends_on", []):
            visit(j)
        colors[i] = "black"
    for i in ids:
        visit(i)
    return {
        "claim_count": len(ids),
        "kernel_scoped": sum(lookup[i]["status"] == "kernel_scoped" for i in ids),
        "analytical_or_open": sum(lookup[i]["status"] not in ("kernel_scoped", "kernel_closed") for i in ids),
        "full_certified": [i for i in ids if lookup[i].get("promoted_full")],
    }


def self_test():
    g = {
        "schema": SCHEMA,
        "claims": [
            {"id": "finite", "status": "kernel_scoped", "depends_on": []},
            {"id": "target", "status": "analytic_only", "depends_on": ["finite"],
             "open_obligations": ["integration"], "promoted_full": False},
        ]
    }
    assert check(g, verify_hashes=False)["full_certified"] == []
    for mutation, expected in [
        (lambda d: d["claims"][1].update(promoted_full=True), "premature"),
        (lambda d: d["claims"][0].update(depends_on=["target"]), "cyclic"),
        (lambda d: d["claims"][1].update(depends_on=["missing"]), "unresolved"),
    ]:
        altered = json.loads(json.dumps(g))
        mutation(altered)
        try:
            check(altered, verify_hashes=False)
        except ValueError as e:
            if expected not in str(e):
                raise
        else:
            raise AssertionError("accepted invalid graph: " + expected)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("graph", nargs="?", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        print("PASS graph mutation controls")
    if args.graph:
        print(json.dumps(check(json.loads(args.graph.read_text())), indent=2))
