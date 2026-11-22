#!/usr/bin/env python3
"""Audit named NIGHTFALL Lean receipts against scoped warrants, not Lean itself.

This inventory is additive to the frozen historical source ledger.  A reported
CI receipt, source custody, mathematical statement equivalence, independent
kernel replay, and worldwide priority are different evidence gates.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
BRIDGE = "docs/lean-warrant-bridge-v1.json"
HISTORICAL = "docs/lean-certificate-provenance.json"
PENDING = "docs/lean-pending-source-custody.json"
ACTIVE = "docs/active-proof-passport.json"
RECONCILED = "docs/active-passport-source-reconciliation-v2.json"
RECENT = "docs/recent-research.json"
V2 = "docs/proof-passport-v2.json"
OVERLAY = "docs/lean-proof-passport-overlay.json"
CERTIFIED_TIERS = {"merged-lean", "branch-lean"}
HEX40 = re.compile(r"[0-9a-f]{40}\Z")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def read_json(path: str) -> dict:
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def file(path: str) -> Path:
    require(isinstance(path, str) and path and not path.startswith("/"),
            "Unsafe/empty repository path")
    require(".." not in Path(path).parts and "\\" not in path,
            "Escaping repository path: " + path)
    return ROOT / path


def git_blob(path: str) -> str:
    data = file(path).read_bytes()
    return hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()


def verify_blob(path: str, sha: str) -> None:
    require(isinstance(sha, str) and HEX40.fullmatch(sha) is not None,
            "Invalid source SHA: " + path)
    require(file(path).is_file(), "Missing source: " + path)
    require(git_blob(path) == sha, "Source SHA drift: " + path)


def validate_bridge(records: list, historical: set, pending: set) -> None:
    ids: set[str] = set()
    paths: set[str] = set()
    for row in records:
        uid = row.get("id")
        src = row.get("source_path")
        require(isinstance(uid, str) and re.fullmatch(r"NF-LEAN-[A-Z0-9-]+", uid),
                "Bad warrant identity")
        require(uid not in ids, "Duplicate warrant: " + uid)
        ids.add(uid)
        require(isinstance(src, str) and src.startswith("research/nightfall/")
                and src.endswith(".lean"), "Nonresearch Lean source in warrant: " + uid)
        require(src not in paths, "Same source declared twice in bridge: " + src)
        paths.add(src)
        require(src in historical or src in pending,
                "Warrant source omitted from canonical source custody: " + src)
        verify_blob(src, row.get("source_blob_sha1"))
        decl = row.get("declaration")
        require(isinstance(decl, str) and "." in decl,
                "Missing precise declaration: " + uid)
        name = decl.rsplit(".", 1)[-1]
        source = file(src).read_text(encoding="utf-8")
        require(re.search(r"\b(?:theorem|lemma|def)\s+" + re.escape(name) + r"\b",
                          source) is not None,
                "Declaration name absent from source: " + uid)
        require(row.get("evidence_status") == "historical-run-referenced-not-replayed"
                and row.get("global_coverage") == "unverified"
                and row.get("statement_review") == "open"
                and row.get("prior_art") == "open",
                "Warrant improperly promoted: " + uid)
        run = row.get("run_id")
        require(type(run) is int and run > 0, "Missing original run: " + uid)
        require(type(row.get("pr")) is int and row["pr"] > 0,
                "Missing PR number: " + uid)
        head = row.get("merged_pr_head")
        require(isinstance(head, str) and HEX40.fullmatch(head) is not None,
                "Missing merged PR head: " + uid)
        original_head = row.get("receipt_head")
        require(original_head is None or
                (isinstance(original_head, str)
                 and HEX40.fullmatch(original_head) is not None),
                "Invalid historical exact-run head: " + uid)
        wp = row.get("warrant_path")
        require(isinstance(wp, str) and wp.startswith(
            "research/nightfall/2026-11-lean-warrants/"),
            "Warrant outside correct collection: " + uid)
        require(wp.endswith("/" + uid + ".md"), "Warrant ID/name drift: " + uid)
        require(file(wp).is_file(), "Missing individual warrant: " + uid)
        document = file(wp).read_text(encoding="utf-8")
        for needle in (uid, src, row["source_blob_sha1"], decl,
                       "/actions/runs/" + str(run), "## Scope",
                       "## Exclusions", "not independently"):
            require(needle in document,
                    "Incomplete or detached warrant " + uid + ": " + needle)
        require(isinstance(row.get("limits"), str) and len(row["limits"]) > 30,
                "Warrant missing mathematical scope limit: " + uid)


def audit() -> dict:
    bridge = read_json(BRIDGE)
    require(bridge.get("schema") == "nightfall.lean-warrant-bridge.v1",
            "Incorrect bridge schema")
    hist = read_json(HISTORICAL)
    pending = read_json(PENDING)
    require(hist.get("schema") == "nightfall-lean-provenance-v1",
            "Historical source registry mismatch")
    require(pending.get("schema") == "nightfall-lean-pending-source-custody-v1",
            "Pending source registry mismatch")
    h = [r["path"] for r in hist["modules"]]
    p = [r["path"] for r in pending["sources"]]
    require(len(h) == len(set(h)) and len(p) == len(set(p))
            and not set(h).intersection(p), "Duplicate or conflicting source custody")
    actual = {str(f.relative_to(ROOT)) for f in
              (ROOT / "research/nightfall").rglob("*.lean")}
    require(set(h).union(p) == actual,
            "Unclassified or stale research/nightfall Lean source inventory: " +
            str(sorted(actual.symmetric_difference(set(h).union(p)))[:12]))
    # Only the canonical source-custody script may promote its frozen records.
    require(all(x.get("ci_source_match_status") == "no-verified-receipt" and
                x.get("classification") == "unreviewed-source" and
                x.get("historical_run") is None
                for x in pending["sources"]),
            "Pending registry silently promoted historical receipts")
    validate_bridge(bridge["records"], set(h), set(p))

    active = read_json(ACTIVE)
    reconciled = read_json(RECONCILED)
    require(active.get("version") == 16, "Unexpected active registry version")
    ac = [r["id"] for r in active["claims"]]
    rc = [r["id"] for r in reconciled["records"]]
    require(len(ac) == len(set(ac)) and len(rc) == len(set(rc))
            and set(ac) == set(rc),
            "Original active claim IDs omitted from source-reconciled registry")
    active_with_lean = 0
    for item in reconciled["records"]:
        dossier = item["dossier"]
        verify_blob(dossier["path"], dossier["git_blob_sha1"])
        primary = item.get("primary_source")
        if primary and primary.get("type") == "lean":
            verify_blob(primary["path"], primary["git_blob_sha1"])
            active_with_lean += 1

    recent = read_json(RECENT)
    certified = []
    for claim in recent["claims"]:
        id_ = claim["id"]
        warrant = "research/nightfall/2026-11-recent-passports/" + id_ + ".md"
        require(file(warrant).is_file(), "Missing recent warrant: " + id_)
        if claim["tier"] in CERTIFIED_TIERS:
            require(isinstance(claim.get("run"), int) and claim["run"] > 0
                    and claim.get("declaration"),
                    "Recent named Lean certificate has no run/declaration: " + id_)
            require("/actions/runs/" + str(claim["run"]) in
                    file(warrant).read_text(encoding="utf-8"),
                    "Recent Lean warrant missing original run: " + id_)
            certified.append(id_)
        else:
            require(not claim.get("run"),
                    "Paper/pending claim mislabeled as named kernel: " + id_)

    v2 = read_json(V2)
    require(v2.get("schema") == "nightfall.proof-passport-overlay.v2",
            "Unexpected v2 schema")
    v2_named = 0
    for item in v2["records"]:
        if item.get("source", {}).get("kind") == "repository":
            src = item["source"]
            verify_blob(src["path"], src["git_blob_sha1"])
            require(item.get("formal", {}).get("declaration")
                    and type(item.get("receipt", {}).get("run_id")) is int,
                    "V2 original named receipt is missing: " + item["id"])
            require(item.get("certification", {}).get(
                "kernel_replayed_in_this_change") is False,
                "V2 metadata checker cannot certify kernel replay")
            v2_named += 1

    overlay = read_json(OVERLAY)
    overlay_named = 0
    for item in overlay["records"]:
        src = item.get("source_path")
        if src and item.get("source_location") == "main":
            verify_blob(src, item["git_blob_sha1"])
        if item.get("theorem_declaration"):
            overlay_named += 1

    nonresearch = sorted(str(f.relative_to(ROOT)) for f in ROOT.rglob("*.lean")
                         if not str(f.relative_to(ROOT)).startswith(
                             "research/nightfall/"))
    return {
        "schema": "nightfall.lean-warrant-coverage-audit.v1",
        "result": "scoped-known-ledger-coverage-not-global-census",
        "research_lean_source_files": len(actual),
        "historical_source_matched": len(h),
        "source_custody_pending": len(p),
        "out_of_scope_lean_files": len(nonresearch),
        "out_of_scope_paths": nonresearch,
        "active_claims_source_reconciled": len(rc),
        "active_lean_primary_sources": active_with_lean,
        "recent_named_lean_claims_with_passports": len(certified),
        "recent_named_ids": certified,
        "v2_named_lean_entries": v2_named,
        "lean_overlay_declaration_entries": overlay_named,
        "additional_individual_warrants": len(bridge["records"]),
        "additional_warrant_ids": [r["id"] for r in bridge["records"]],
        "named_receipt_exhaustiveness": "not-established",
        "fresh_kernel_replay": False,
        "independent_statement_review": False,
        "worldwide_novelty": False
    }


def self_test() -> None:
    original = read_json(BRIDGE)["records"]
    h = set(r["path"] for r in read_json(HISTORICAL)["modules"])
    p = set(r["path"] for r in read_json(PENDING)["sources"])
    mutate = [
        ("duplicate", lambda a: a.append(copy.deepcopy(a[0]))),
        ("bad_hash", lambda a: a[0].update(source_blob_sha1="0" * 40)),
        ("missing_run", lambda a: a[0].update(run_id=None)),
        ("promotion", lambda a: a[0].update(statement_review="complete")),
        ("wrong_declaration", lambda a: a[0].update(declaration="Nightfall.Fake.not_proved")),
        ("missing_warrant", lambda a: a[0].update(warrant_path=a[0]["warrant_path"] + ".bad")),
        ("wrong_custody", lambda a: a[0].update(source_path="research/nightfall/never.lean")),
        ("bogus_head", lambda a: a[0].update(receipt_head="bogus")),
    ]
    for label, bad in mutate:
        altered = copy.deepcopy(original)
        bad(altered)
        try:
            validate_bridge(altered, h, p)
        except (ValueError, FileNotFoundError):
            continue
        raise AssertionError("Failed closed mutation control: " + label)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--json-out")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()
    report = audit()
    if args.self_test:
        self_test()
    if args.json_out:
        target = Path(args.json_out)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))
    print("PASS scoped warrant coverage; global named-certification census still OPEN")


if __name__ == "__main__":
    main()
