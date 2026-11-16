#!/usr/bin/env python3
"""Fail-closed live evidence overlay for NIGHTFALL Proof Passports.

The frozen dependency ledger and 15-claim public registry are not rewritten.
A passing check says a source blob, named declaration and CI run are attached
to the exact current PR head; it is not a mathematical peer review or an
automatic claim-status promotion. No code from external sources is executed.
"""
from __future__ import annotations

import argparse
import base64
import copy
import json
import os
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "research/catalogue/SOURCE_LINKED_PASSPORT_EVIDENCE.json"
GRAPH = ROOT / "research/catalogue/ACTIVE_DEPENDENCY_CLOSURE.json"
ACTIVE = ROOT / "docs/active-proof-passport.json"
SCHEMA = "nightfall.source-linked-passport-evidence.v1"
EXPECTED = {
    "quantum-normalized-terminal": {
        "node": "q-terminal",
        "pr": 658,
        "file": "research/nightfall/formalization/quantum/PhysicalGainNormalized.lean",
        "declaration": "actual_physical_optimal_gain_normalized",
        "workflow_name": "NIGHTFALL actual physical Born and full POVM terminal Lean",
    },
    "f9-fixed-same-oracle-lower": {
        "node": "f-nonadaptive-bridge",
        "pr": 659,
        "file": "research/nightfall/formalization/finite_field/F9ConcreteLower.lean",
        "declaration": "actual_fixed_family_lower",
        "workflow_name": "NIGHTFALL F9 same-oracle decoder and complement bridge Lean",
    },
}


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)


def local_check(manifest: dict, graph: dict, active: dict) -> list[dict]:
    require(manifest.get("schema") == SCHEMA, "invalid manifest schema")
    require(manifest.get("as_of") == "2026-11-16", "snapshot date changed")
    require(manifest.get("active_registry") == "docs/active-proof-passport.json",
            "public registry link changed")
    require(manifest.get("frozen_dependency_graph") ==
            "research/catalogue/ACTIVE_DEPENDENCY_CLOSURE.json",
            "frozen graph link changed")
    require("Never promote" in manifest.get("policy", ""),
            "fail-closed status rule absent")
    require(active.get("claim_count") == 15 and len(active.get("claims", [])) == 15,
            "active registry changed: reconcile explicitly")
    require(graph.get("schema") == "nightfall.dependency-closure.v1",
            "frozen dependency contract changed")
    by_node = {n["id"]: n for n in graph["nodes"]}
    entries = manifest.get("entries", [])
    require(isinstance(entries, list) and len(entries) == len(EXPECTED),
            "unexpected evidence entries")
    require({e.get("id") for e in entries} == set(EXPECTED),
            "unexpected or duplicate evidence id")
    for e in entries:
        expected = EXPECTED[e["id"]]
        for key, val in expected.items():
            require(e.get(key) == val, e["id"] + ": " + key + " changed")
        require(e.get("frontier") == by_node[e["node"]]["frontier"],
                "frontier mismatch")
        require(by_node[e["node"]]["status"] == "open",
                "frozen graph was silently promoted")
        require(re.fullmatch(r"[0-9a-f]{40}", str(e.get("head"))) is not None,
                "untrusted source commit")
        require(re.fullmatch(r"[0-9a-f]{40}", str(e.get("blob"))) is not None,
                "untrusted source blob")
        require(type(e.get("workflow_run")) is int and e["workflow_run"] > 0,
                "untrusted workflow receipt")
        require(e.get("proposed_status") in {
            "candidate-terminal-source-ci-passed", "component-source-ci-passed"
        }, "unapproved promotion")
        require(isinstance(e.get("remaining"), str) and len(e["remaining"]) >= 35,
                "missing remaining proof obligation")
    require(next(e for e in entries if e["id"] == "f9-fixed-same-oracle-lower")
            ["proposed_status"] == "component-source-ci-passed",
            "F9 terminal cannot be promoted")
    return entries


def github_get(api_path: str) -> dict:
    url = "https://api.github.com/repos/d3lefts/d3lefts/" + api_path
    token = os.environ.get("GITHUB_TOKEN")
    headers = {"Accept": "application/vnd.github+json",
               "User-Agent": "nightfall-source-linked-passport/1"}
    if token:
        headers["Authorization"] = "Bearer " + token
    request = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(request, timeout=20) as response:
        return json.load(response)


def live_check(entries: list[dict], fetch=github_get) -> list[dict]:
    report = []
    for e in entries:
        pr = fetch(f"pulls/{e['pr']}")
        require(pr["head"]["sha"] == e["head"],
                e["id"] + ": PR HEAD DRIFT: a new proof review is required")
        require(pr["state"] == "open" and not pr.get("merged_at"),
                e["id"] + ": PR lifecycle changed; review promotion explicitly")
        run = fetch(f"actions/runs/{e['workflow_run']}")
        require(run["head_sha"] == e["head"], e["id"] + ": CI source mismatch")
        require(run["status"] == "completed" and run["conclusion"] == "success",
                e["id"] + ": CI is not successful")
        require(run["name"] == e["workflow_name"],
                e["id"] + ": wrong workflow identity")
        file_path = urllib.parse.quote(e["file"], safe="/")
        source = fetch("contents/" + file_path + "?ref=" + e["head"])
        require(source["sha"] == e["blob"], e["id"] + ": source blob drift")
        require(source["type"] == "file" and source["encoding"] == "base64",
                e["id"] + ": unsupported source format")
        body = base64.b64decode(source["content"], validate=False).decode("utf-8")
        # Presence is a link check only. The pinned Lean CI is the compilation check.
        require(re.search(r"\btheorem\s+" + re.escape(e["declaration"]) + r"\b", body),
                e["id"] + ": named theorem missing from source")
        report.append({
            "node": e["node"], "proposal": e["proposed_status"],
            "source_head": e["head"], "source_blob": e["blob"],
            "run": e["workflow_run"], "verified_linkage": True,
            "promoted_frozen_status": False,
            "remaining": e["remaining"],
        })
    return report


def self_test(manifest: dict, graph: dict, active: dict) -> int:
    entries = local_check(manifest, graph, active)
    fixtures: dict[str, dict] = {}
    for e in entries:
        fixtures[f"pulls/{e['pr']}"] = {
            "state": "open", "merged_at": None, "head": {"sha": e["head"]}}
        fixtures[f"actions/runs/{e['workflow_run']}"] = {
            "head_sha": e["head"], "status": "completed",
            "conclusion": "success", "name": e["workflow_name"]}
        path = urllib.parse.quote(e["file"], safe="/")
        fixtures["contents/" + path + "?ref=" + e["head"]] = {
            "sha": e["blob"], "type": "file", "encoding": "base64",
            "content": base64.b64encode(
                ("theorem " + e["declaration"] + " : True := by trivial\n").encode()
            ).decode(),
        }
    def checked(fx: dict) -> None:
        require(len(live_check(entries, lambda path: fx[path])) == 2,
                "unexpected checked entry count")
    checked(fixtures)

    def must_reject(action) -> None:
        bad = copy.deepcopy(fixtures)
        action(bad)
        try:
            checked(bad)
        except (ValueError, KeyError):
            return
        raise AssertionError("forged source/CI linkage was accepted")
    q, f = entries
    qpath = "contents/" + urllib.parse.quote(q["file"], safe="/") + "?ref=" + q["head"]
    actions = [
        lambda fx: fx[f"pulls/{q['pr']}"]["head"].update(sha="0"*40),
        lambda fx: fx[f"actions/runs/{q['workflow_run']}"].update(head_sha="0"*40),
        lambda fx: fx[f"actions/runs/{q['workflow_run']}"].update(conclusion="failure"),
        lambda fx: fx[f"actions/runs/{q['workflow_run']}"].update(status="in_progress"),
        lambda fx: fx[f"actions/runs/{f['workflow_run']}"].update(name="wrong workflow"),
        lambda fx: fx[qpath].update(sha="0"*40),
        lambda fx: fx[qpath].update(content=base64.b64encode(b"theorem other : True := by trivial").decode()),
        lambda fx: fx[f"pulls/{f['pr']}"].update(merged_at="2026-11-16T00:00:00Z"),
    ]
    for action in actions:
        must_reject(action)
    forged = copy.deepcopy(manifest)
    forged["entries"][1]["proposed_status"] = "certified-terminal"
    try:
        local_check(forged, graph, active)
    except ValueError:
        pass
    else:
        raise AssertionError("F9 terminal status promotion accepted")
    return len(actions) + 1


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--live", action="store_true",
                        help="compare PR head, exact source blob, and passing named workflow")
    parser.add_argument("--self-test", action="store_true",
                        help="run negative source/CI/claim-promotion mutation tests")
    args = parser.parse_args()
    manifest = json.loads(MANIFEST.read_text())
    graph = json.loads(GRAPH.read_text())
    active = json.loads(ACTIVE.read_text())
    entries = local_check(manifest, graph, active)
    print(f"PASS: {len(entries)} source proposals, active registry still 15, frozen graph unchanged")
    if args.self_test:
        print(f"PASS: {self_test(manifest, graph, active)} adversarial mutation tests")
    if args.live:
        result = live_check(entries)
        print(json.dumps({"status": "linked_receipts_confirmed",
                          "terminal_promotion": False, "proposals": result},
                         indent=2, sort_keys=True))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, AssertionError, KeyError, OSError, TypeError) as exc:
        print("FAIL: " + str(exc), file=sys.stderr)
        sys.exit(1)
