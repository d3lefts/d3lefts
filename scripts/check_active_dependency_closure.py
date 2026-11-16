#!/usr/bin/env python3
"""NIGHTFALL terminal-dependency recovery gate.

This validates a dated evidence *snapshot*, its dependency graph, and frozen
reported CI references. It does not compile Lean, replay proof artifacts, or
certify that a GitHub Actions success proves a mathematical statement.

Changes to accepted status, source identity, or graph require an explicit
versioned checker revision; editing the JSON alone cannot promote a theorem.
"""
from __future__ import annotations

import argparse
import copy
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "research/catalogue/ACTIVE_DEPENDENCY_CLOSURE.json"
SCHEMA = "nightfall.dependency-closure.v1"
HEADS = {
    645: "513bd8f46573e683d8343f8c9a3f619e4daafded",
    647: "23e279c25502777fc4f581c1142abd067bc74a05",
    655: "339cdeddcda925bc14dc593b950863005d6f6f9c",
}
# CI success is source-reported scope, NOT a verifier of mathematical closure.
RECEIPTS = {
    "q-physical-states": ("scoped_ci_reported", 647, 43917859989),
    "q-actual-operators": ("scoped_ci_reported", 647, 43917859989),
    "q-ghz-support": ("scoped_ci_reported", 655, 43917861968),
    "f-conditional-arithmetic": ("conditional_ci_reported", 645, 43811312747),
}
# These edges are mathematically load-bearing, not merely presentation links.
EDGES = {
    "q-physical-states": (),
    "q-actual-operators": ("q-physical-states",),
    "q-ghz-support": ("q-actual-operators",),
    "q-born-numerator": ("q-actual-operators", "q-ghz-support"),
    "q-optimal-povm": ("q-physical-states", "q-ghz-support"),
    "q-terminal": ("q-born-numerator", "q-optimal-povm"),
    "f-conditional-arithmetic": (),
    "f-decoder-bridge": (),
    "f-nonadaptive-bridge": (),
    "f-coding-transfer": ("f-nonadaptive-bridge",),
    "f-terminal": ("f-conditional-arithmetic", "f-decoder-bridge",
                   "f-nonadaptive-bridge", "f-coding-transfer"),
}
TERMINALS = {
    "quantum-physical-operator": "q-terminal",
    "f9-asymptotic-oracle": "f-terminal",
}
PRIORITIES = {"quantum-physical-operator": 1, "f9-asymptotic-oracle": 2}
OPEN = set(EDGES) - set(RECEIPTS)

def require(condition: bool, reason: str) -> None:
    if not condition:
        raise ValueError(reason)

def audit(doc: dict) -> dict:
    require(isinstance(doc, dict) and doc.get("schema") == SCHEMA, "schema changed")
    require(doc.get("snapshot_utc") == "2026-11-16", "unknown frozen snapshot")
    require(isinstance(doc.get("meaning"), str) and
            "no status promotion" in doc["meaning"], "boundary notice lost")
    frontiers = doc.get("frontiers")
    nodes = doc.get("nodes")
    require(isinstance(frontiers, list) and len(frontiers) == 2, "frontier cardinality")
    require(isinstance(nodes, list) and len(nodes) == len(EDGES), "node cardinality")
    require(all(isinstance(x, dict) for x in frontiers + nodes), "invalid objects")
    by_frontier = {f.get("id"): f for f in frontiers}
    by_id = {n.get("id"): n for n in nodes}
    require(set(by_frontier) == set(TERMINALS), "frontier identities changed")
    require(set(by_id) == set(EDGES), "node identities changed")
    for fid, f in by_frontier.items():
        require(f.get("terminal") == TERMINALS[fid], fid + ": terminal changed")
        require(f.get("priority") == PRIORITIES[fid], fid + ": priority changed")
        require(isinstance(f.get("scope"), str) and len(f["scope"]) > 60,
                fid + ": scope missing")
        require(isinstance(f.get("not_claimed"), list) and
                len(f["not_claimed"]) >= 2, fid + ": status limits missing")
        prs = f.get("snapshot_prs")
        require(isinstance(prs, list) and prs, fid + ": missing sources")
        for p in prs:
            require(isinstance(p, dict) and p.get("pr") in HEADS and
                    p.get("head") == HEADS[p["pr"]], fid + ": source head changed")
    require({p["pr"] for f in frontiers for p in f["snapshot_prs"]} ==
            set(HEADS), "PR source coverage changed")

    for nid, n in by_id.items():
        fid = n.get("frontier")
        require(fid in TERMINALS, nid + ": unknown frontier")
        require(n.get("deps") == list(EDGES[nid]),
                nid + ": proof dependencies altered")
        for dep in n["deps"]:
            require(dep in by_id and by_id[dep]["frontier"] == fid,
                    nid + ": dangling or cross-frontier dependency")
        require(isinstance(n.get("claim"), str) and len(n["claim"]) > 70,
                nid + ": quantified claim insufficient")
        require(isinstance(n.get("limitations"), list) and n["limitations"] and
                all(isinstance(x, str) and len(x) > 12 for x in n["limitations"]),
                nid + ": missing limitations")
        require(isinstance(n.get("assumptions"), list), nid + ": missing assumptions")
        if nid in RECEIPTS:
            status, pr, run = RECEIPTS[nid]
            require(n.get("status") == status, nid + ": CI scope promoted")
            require(n.get("evidence") == {"pr": pr, "run": run},
                    nid + ": CI receipt changed")
            require(n.get("next_experiment") is None, nid + ": settled component altered")
            if status == "conditional_ci_reported":
                require(len(n["assumptions"]) >= 2,
                        nid + ": conditional hypotheses erased")
            else:
                require(not n["assumptions"], nid + ": scoped premise mutated")
        else:
            require(n.get("status") == "open", nid + ": unearned terminal promotion")
            require(n.get("evidence") is None, nid + ": unverified evidence asserted")
            require(not n["assumptions"], nid + ": new unresolved premise inserted")
            test = n.get("next_experiment")
            require(isinstance(test, dict) and
                    set(test) == {"prediction", "alternative", "decisive_test",
                                  "independent_check"} and
                    all(isinstance(x, str) and len(x) > 35 for x in test.values()),
                    nid + ": missing preregistered independent decisive experiment")

    # General graph audit, in addition to versioned load-bearing edge locks.
    seen, active = set(), set()
    def visit(nid: str) -> None:
        require(nid not in active, nid + ": cycle")
        if nid in seen:
            return
        active.add(nid)
        for dep in by_id[nid]["deps"]:
            visit(dep)
        active.remove(nid)
        seen.add(nid)
    for nid in by_id:
        visit(nid)
    for fid, terminal in TERMINALS.items():
        closure = set()
        def pull(nid: str) -> None:
            if nid not in closure:
                closure.add(nid)
                for dep in by_id[nid]["deps"]:
                    pull(dep)
        pull(terminal)
        require({n["id"] for n in nodes if n["frontier"] == fid} == closure,
                fid + ": detached proof obligation")
    return {
        "frontiers": len(frontiers),
        "nodes": len(nodes),
        "open": len(OPEN),
        "scoped_ci_reported": sum(n["status"] == "scoped_ci_reported" for n in nodes),
        "conditional_ci_reported": sum(n["status"] == "conditional_ci_reported"
                                       for n in nodes),
        "terminal_proved": 0,
    }

def live_heads() -> None:
    """Optional freshness check; API access verifies PR heads only, not proofs."""
    token = os.environ.get("GITHUB_TOKEN")
    for pr, expected in sorted(HEADS.items()):
        request = urllib.request.Request(
            f"https://api.github.com/repos/d3lefts/d3lefts/pulls/{pr}",
            headers={"Accept": "application/vnd.github+json",
                     "User-Agent": "nightfall-dependency-recovery/1",
                     **({"Authorization": "Bearer " + token} if token else {})},
        )
        with urllib.request.urlopen(request, timeout=15) as response:
            current = json.load(response)["head"]["sha"]
        require(current == expected,
                f"PR #{pr} head changed: snapshot {expected}, now {current}; "
                "reconcile claim scopes before trusting this recovery graph")

def test_mutations(doc: dict) -> int:
    """Adversarial schema checks; these do not independently verify theorems."""
    def mutate(fn) -> None:
        forged = copy.deepcopy(doc)
        fn(forged)
        try:
            audit(forged)
        except ValueError:
            return
        raise AssertionError("Forged state passed the recovery gate")
    ix = lambda d, id: next(n for n in d["nodes"] if n["id"] == id)
    mutations = [
        lambda d: d.update(schema="nightfall.dependency-closure.v2"),
        lambda d: d.update(snapshot_utc="2026-11-17"),
        lambda d: ix(d, "q-terminal").update(status="scoped_ci_reported"),
        lambda d: ix(d, "q-ghz-support")["evidence"].update(run=43917861967),
        lambda d: ix(d, "f-conditional-arithmetic").update(assumptions=[]),
        lambda d: ix(d, "q-born-numerator").update(deps=[]),
        lambda d: ix(d, "f-terminal").update(deps=["q-terminal"]),
        lambda d: ix(d, "q-physical-states").update(deps=["q-terminal"]),
        lambda d: ix(d, "q-optimal-povm").update(evidence={"pr": 655, "run": 1}),
        lambda d: ix(d, "f-decoder-bridge")["next_experiment"].update(independent_check=""),
        lambda d: d["frontiers"][0]["snapshot_prs"][1].update(head="0"*40),
        lambda d: d["nodes"].append(copy.deepcopy(d["nodes"][0])),
    ]
    for fn in mutations:
        mutate(fn)
    return len(mutations)

def summary(doc: dict) -> None:
    by_id = {n["id"]: n for n in doc["nodes"]}
    print("NIGHTFALL source-scoped recovery | snapshot " + doc["snapshot_utc"])
    for f in sorted(doc["frontiers"], key=lambda x: x["priority"]):
        fid = f["id"]
        print(f"\n{fid}: terminal OPEN ({f['terminal']})")
        for n in doc["nodes"]:
            if n["frontier"] != fid or n["status"] != "open":
                continue
            unresolved = [i for i in n["deps"] if by_id[i]["status"] == "open"]
            state = "BLOCKED" if unresolved else "READY_FOR_CONSTRUCTION"
            print(f"  {state} {n['id']} | {n['next_experiment']['decisive_test']}")
            if unresolved:
                print("    depends on: " + ", ".join(unresolved))
    print("\nNo terminal theorem, physical deployment, or novelty has been certified.")

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--live", action="store_true",
                        help="Compare frozen PR-head identities to live GitHub")
    parser.add_argument("--summary", action="store_true")
    args = parser.parse_args()
    doc = json.loads(LEDGER.read_text(encoding="utf-8"))
    stats = audit(doc)
    if args.self_test:
        stats["forgeries_rejected"] = test_mutations(doc)
    if args.live:
        live_heads()
    print("PASS: " + json.dumps(stats, sort_keys=True))
    if args.summary:
        summary(doc)

if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError, TypeError) as exc:
        print("FAIL: " + str(exc), file=sys.stderr)
        sys.exit(1)
