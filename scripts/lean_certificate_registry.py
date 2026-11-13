#!/usr/bin/env python3
"""One fail-closed entrypoint for the NIGHTFALL Lean *source provenance* register.

A source blob in a successful historical CI head is not, by itself, a checked
declaration, a same-pin joint build, a new theorem, or a priority certificate.
No Lean compilation is performed here. For fresh theorem receipts use the
separate strict lean_bridge.py + check_receipts.py pipeline.
"""
from __future__ import annotations

import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = Path("docs/lean-certificate-provenance.json")
CI_MATCH = "same-git-blob-as-successful-ci-head"
CLASSES = {
    "quarantine": "quarantine",
    "derived-transfer": "derived_transfer",
    "finite-construction": "finite_construction",
}
HEX40 = re.compile(r"[0-9a-f]{40}\Z")


def require(test: bool, message: str) -> None:
    if not test:
        raise ValueError(message)


def git_blob_hash(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()


def group_for(path: str) -> str:
    parts = Path(path).parts
    if "formalization" in parts:
        idx = parts.index("formalization")
        return parts[idx + 1] if idx + 1 < len(parts) else "formalization"
    return "/".join(parts[2:-1]) or "other"


def inspect(root: Path) -> dict:
    """Audit current checkout bytes, authoritative ledger and custody boundaries."""
    manifest = json.loads((root / MANIFEST).read_text(encoding="utf-8"))
    require(manifest.get("schema") == "nightfall-lean-provenance-v1",
            "Unrecognized certificate registry schema")
    records = manifest.get("modules")
    require(isinstance(records, list) and records, "Missing source records")
    listed = [r.get("path") for r in records]
    require(all(isinstance(p, str) and p.startswith("research/nightfall/")
                and p.endswith(".lean") and ".." not in Path(p).parts for p in listed),
            "Illegal/out-of-tree Lean source path")
    require(len(set(listed)) == len(listed), "Duplicate certificate source path")
    actual = sorted(p.relative_to(root).as_posix()
                    for p in (root / "research/nightfall").rglob("*.lean"))
    # The published ledger is a *historical source-matched checkpoint*, not an
    # automatic certification service for files added after that checkpoint.
    # Missing/changed registered sources still fail closed. Fresh sources are
    # recorded as pending, without invented CI runs, theorem checks or priority.
    require(set(listed).issubset(actual),
            "Missing registered Lean source(s): " +
            str(sorted(set(listed) - set(actual))))
    pending = sorted(set(actual) - set(listed))
    pending_entries = [{
        "path": p,
        "git_blob_sha1": git_blob_hash((root / p).read_bytes()),
        "classification": "unreviewed-source",
        "ci_source_match_status": "no-verified-receipt",
        "historical_run": None,
        "historical_head": None,
        "receipt_scope": "Unregistered in the historical certificate ledger; no Lean declaration or source-matched CI receipt is claimed.",
        "global_priority": "unverified",
    } for p in pending]
    classification = Counter()
    families = defaultdict(Counter)
    entries = []
    for rec in sorted(records, key=lambda r: r["path"]):
        p = rec["path"]
        kind = rec.get("classification")
        require(kind in CLASSES, "Unclassified source: " + p)
        classification[kind] += 1
        family = group_for(p)
        families[family][kind] += 1
        data = (root / p).read_bytes()
        blob = git_blob_hash(data)
        require(rec.get("source_blob_sha") == blob, "Source blob changed: " + p)
        require(rec.get("global_priority") == "unverified",
                "Unexpected global novelty promotion: " + p)
        require(rec.get("ci_source_match_status") == CI_MATCH,
                "No successful source-matched CI head: " + p)
        require(isinstance(rec.get("ci_run"), int) and rec["ci_run"] > 0,
                "Missing historical CI run: " + p)
        require(isinstance(rec.get("ci_run_head_sha"), str)
                and HEX40.fullmatch(rec["ci_run_head_sha"]) is not None,
                "Missing exact historical CI head: " + p)
        require(isinstance(rec.get("ci_receipt_scope"), str)
                and len(rec["ci_receipt_scope"]) > 30,
                "Missing receipt scope limitation: " + p)
        if kind != "quarantine":
            passport = rec.get("passport")
            require(isinstance(passport, str) and (root / "docs" / passport).is_file(),
                    "Missing scoped passport: " + p)
        entries.append({
            "path": p,
            "family": family,
            "classification": kind,
            "git_blob_sha1": blob,
            "historical_run": rec["ci_run"],
            "historical_head": rec["ci_run_head_sha"],
            "ci_url": f"https://github.com/d3lefts/d3lefts/actions/runs/{rec['ci_run']}",
            "receipt_scope": rec["ci_receipt_scope"],
            "global_priority": rec["global_priority"],
        })
    declared = manifest.get("counts", {})
    for kind, key in CLASSES.items():
        require(classification[kind] == declared.get(key),
                "Classification count drift: " + kind)
    totals = manifest.get("ci_source_match_counts", {})
    require(totals.get("matched_successful_ci_head") == len(records)
            and totals.get("no_direct_receipt_identified") == 0,
            "CI source matching incomplete or stale")
    off_main = manifest.get("off_main_certificates", [])
    require(isinstance(off_main, list), "Off-main custody register missing")
    for record in off_main:
        p = record.get("path")
        require(isinstance(p, str) and p not in actual
                and record.get("merged_to_main") is False,
                "Unmerged branch evidence counted as main: " + str(p))
    return {
        "schema": "nightfall-unified-lean-source-audit/v1",
        "registry_revision": manifest.get("revision"),
        "frozen_source_checkpoint": manifest.get("source_commit"),
        "inventory_count": len(records),
        "current_checkout_lean_source_count": len(actual),
        "unreviewed_source_count": len(pending_entries),
        "unreviewed_sources": pending_entries,
        "classification_counts": dict(sorted(classification.items())),
        "families": {k: dict(sorted(v.items())) for k, v in sorted(families.items())},
        "off_main_count": len(off_main),
        "historical_source_match_count": len(records),
        "current_checkout_source_integrity": not pending_entries,
        "registered_source_integrity": True,
        "all_checkout_sources_source_matched": not pending_entries,
        "fresh_compiler_replay": False,
        "named_declaration_coverage_reevaluated": False,
        "same_pin_all_modules_compiled": False,
        "universal_theorem_certified": False,
        "worldwide_priority_verified": False,
        "entries": entries,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--audit", action="store_true",
                        help="also run the existing site/passport provenance assertions")
    parser.add_argument("--json-out", type=Path,
                        help="write a machine-readable, explicit-scope certificate index")
    args = parser.parse_args()
    try:
        result = inspect(ROOT)
        if args.audit:
            subprocess.run(["node", "scripts/test_lean_certificate_provenance.cjs"],
                           cwd=ROOT, check=True)
    except (ValueError, OSError, subprocess.CalledProcessError) as exc:
        parser.exit(1, f"FAIL: {exc}\n")
    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n",
                                 encoding="utf-8")
    print(f"PASS: {result['inventory_count']} registered historical Lean source blobs "
          "checked against the authoritative registry")
    print(f"PENDING, NOT CERTIFIED: {result['unreviewed_source_count']} "
          "new checkout Lean source(s) without a registered source-matched receipt")
    for pending in result["unreviewed_sources"]:
        print(f"  PENDING: {pending['path']} sha1={pending['git_blob_sha1']}")
    for family, kinds in result["families"].items():
        print(f"  {family:26} {sum(kinds.values()):2d}  " +
              ", ".join(f"{k}={v}" for k, v in kinds.items()))
    print(f"Off-main historical custody records: {result['off_main_count']}")
    print("SCOPE: registered source integrity + historical successful-head pointers only.")
    print("UNREVIEWED SOURCES: no successful CI, declaration, or originality claim inferred.")
    print("NOT CHECKED HERE: fresh Lean kernel, declared theorem types/axioms, "
          "single-pin integration, universal theorem, novelty.")


if __name__ == "__main__":
    main()
