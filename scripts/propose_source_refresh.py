#!/usr/bin/env python3
"""Propose, but NEVER apply, refreshed proof evidence when GitHub heads move.

Reads live PRs, exact source blobs and successful matching named workflow runs.
Writes an immutable-review candidate JSON for humans/agents to inspect.
Does NOT edit frozen claims, evidence manifests, PRs or certificate status.
"""
import argparse
import base64
import json
import re
import urllib.parse
from pathlib import Path

import reconcile_source_linked_passports as gate


def candidates(manifest, graph, active, fetch=gate.github_get):
    entries = gate.local_check(manifest, graph, active)
    output = []
    for old in entries:
        pr = fetch(f"pulls/{old['pr']}")
        head = pr["head"]["sha"]
        item = {"id": old["id"], "node": old["node"],
                "previous_head": old["head"], "current_head": head,
                "head_drift": head != old["head"],
                "claim_promotion": False, "eligible_for_source_review": False}
        if pr["state"] != "open" or pr.get("merged_at"):
            item["blocker"] = "PR lifecycle changed; explicit registry reconciliation required"
            output.append(item)
            continue
        path = urllib.parse.quote(old["file"], safe="/")
        src = fetch(f"contents/{path}?ref={head}")
        if src.get("type") != "file" or src.get("encoding") != "base64":
            item["blocker"] = "source type unsupported"
            output.append(item)
            continue
        code = base64.b64decode(src["content"]).decode("utf8")
        if not re.search(r"\btheorem\s+" + re.escape(old["declaration"]) + r"\b", code):
            item["blocker"] = "named theorem no longer found"
            output.append(item)
            continue
        runs = fetch(f"actions/runs?head_sha={head}&per_page=100")["workflow_runs"]
        matches = [r for r in runs
                   if r.get("head_sha") == head
                   and r.get("name") == old["workflow_name"]
                   and r.get("status") == "completed"
                   and r.get("conclusion") == "success"]
        if not matches:
            item["blocker"] = "no successful named source-head workflow"
            output.append(item)
            continue
        best = max(matches, key=lambda r: r["id"])
        item["eligible_for_source_review"] = True
        item["proposed_source_head"] = head
        item["proposed_blob"] = src["sha"]
        item["proposed_run"] = best["id"]
        item["requires_manual_scope_comparison"] = True
        item["unchanged_proof_gate"] = old["remaining"]
        output.append(item)
    return {"schema": "nightfall.source-refresh-proposals.v1",
            "scope": "source custody proposals only; no automatic proof promotion",
            "proposals": output}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", help="write a reviewable proposal artifact")
    args = parser.parse_args()
    m = json.loads(gate.MANIFEST.read_text())
    g = json.loads(gate.GRAPH.read_text())
    a = json.loads(gate.ACTIVE.read_text())
    result = candidates(m, g, a)
    doc = json.dumps(result, indent=2, sort_keys=True) + "\n"
    if args.output:
        target = Path(args.output)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(doc, encoding="utf8")
    print(doc, end="")


if __name__ == "__main__":
    main()
