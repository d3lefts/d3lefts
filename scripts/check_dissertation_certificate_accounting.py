#!/usr/bin/env python3
"""Audit a dissertation's claims against scoped Lean sources. This does NOT compile Lean."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "research/nightfall/2026-11-information-cost-dissertation/DISSERTATION_V2_CERTIFICATE_LEDGER_20261112.json"
PDF_HASH = "a65cc94daa4392dc8a79ca8ebbf5d5f63744db6465107a24f9ba397aca6c51fc"
LOCAL_HASH = "d3ddb18999cdc0e87e2ef5c131eac821c74a4141cc9a722b10581de5858cdb35"
LOCAL = "papers/conditional-section-duality/lean/FixedObservationSelector.lean"
EXPECTED_KINDS = {"Theorem": 28, "Proposition": 15, "Lemma": 7, "Corollary": 4}
EXPECTED_GRADES = {"LOCAL_KERNEL_SCOPE": 1, "EXTERNAL_KERNEL_SCOPE": 1,
    "SCOPED_COMPONENTS": 22, "FINITE_CHECK_ONLY": 19, "ANALYTIC_ONLY": 11}

def audit(pdf=None):
    data = json.loads(LEDGER.read_text(encoding="utf-8"))
    claims = data["claims"]
    assert data["schema"] == "nightfall-dissertation-machine-certificates/v1"
    assert len(claims) == 54
    assert len({r["number"] for r in claims}) == 54
    assert all(r["id"] == "D2-" + r["number"] for r in claims)
    assert dict(Counter(r["kind"] for r in claims)) == EXPECTED_KINDS
    assert dict(Counter(r["machine_status"] for r in claims)) == EXPECTED_GRADES
    assert data["inventory"]["statuses"] == EXPECTED_GRADES
    assert data["inventory"]["fully_end_to_end_lean_certified_claims"] == 0
    assert data["source_manuscript"]["sha256"] == PDF_HASH
    assert data["source_manuscript"]["physical_pages"] == 69
    assert all(not r["full_end_to_end_lean"] and not r["novelty_verified"]
               and not r["non_author_review"] for r in claims)
    assert all(r["missing_for_exact_endpoint"] for r in claims)
    assert next(r for r in claims if r["number"] == "1.1")["machine_status"] == "SCOPED_COMPONENTS"
    assert next(r for r in claims if r["number"] == "1.4")["machine_status"] == "SCOPED_COMPONENTS"
    assert next(r for r in claims if r["number"] == "2.1")["machine_status"] == "LOCAL_KERNEL_SCOPE"
    assert next(r for r in claims if r["number"] == "2.4")["machine_status"] == "EXTERNAL_KERNEL_SCOPE"
    assert next(r for r in claims if r["number"] == "5.5")["machine_status"] == "FINITE_CHECK_ONLY"
    assert next(r for r in claims if r["number"] == "6.9")["kind"] == "Theorem"

    registry = json.loads((ROOT / data["inventory"]["canonical_registry"]).read_text(encoding="utf-8"))
    by_path = {m["path"]: m for m in registry["modules"]}
    assert len(by_path) == data["inventory"]["canonical_registry_modules"] == 67
    assert registry["revision"] == data["inventory"]["canonical_registry_revision"]
    assert registry["counts"] == data["inventory"]["canonical_registry_counts"]
    assert Counter(m["classification"] for m in registry["modules"]) == {
        "quarantine": 56, "derived-transfer": 10, "finite-construction": 1}
    assert data["inventory"]["paper_local"] == [LOCAL]
    checked = set()
    for claim in claims:
        grade = claim["machine_status"]
        if grade in ("SCOPED_COMPONENTS", "LOCAL_KERNEL_SCOPE"):
            assert claim["source_certificates"], claim["number"]
        else:
            assert not claim["source_certificates"], claim["number"]
        for entry in claim["source_certificates"]:
            name = entry["path"]
            assert name.endswith(".lean")
            src = ROOT / name
            assert src.is_file(), name
            if name == LOCAL:
                assert name not in by_path and entry["ci_run"] == 43285738660
                assert entry["scope"] == "paper_local_not_in_67_module_registry"
                assert hashlib.sha256(src.read_bytes()).hexdigest() == LOCAL_HASH
            else:
                assert name in by_path, name
                m = by_path[name]
                for key in ("ci_run", "source_blob_sha"):
                    assert entry[key] == m[key], (name, key)
                assert entry["ci_head_sha"] == m["ci_run_head_sha"]
                actual = subprocess.check_output(["git", "hash-object", str(src)],
                    cwd=ROOT, text=True).strip()
                assert actual == entry["source_blob_sha"], name
            checked.add(name)
        for evidence in claim["finite_evidence"]:
            if evidence["path"]:
                assert (ROOT / evidence["path"]).is_file(), evidence["path"]
            else:
                assert "not located" in evidence["verification"]

    if pdf is not None:
        import fitz
        assert hashlib.sha256(pdf.read_bytes()).hexdigest() == PDF_HASH
        document = fitz.open(str(pdf))
        assert len(document) == 69
        found = {}
        for i, page in enumerate(document, 1):
            for m in re.finditer(r"(?m)^\\s*(Theorem|Proposition|Lemma|Corollary)\\s+(\\d+\\.\\d+)\\s*\\(", page.get_text(sort=True)):
                found.setdefault(m.group(2), (m.group(1), i))
        assert len(found) == 54, sorted(set(found) ^ {r["number"] for r in claims})
        for claim in claims:
            assert found[claim["number"]] == (claim["kind"], claim["pdf_page"]), claim["number"]

    direct = {p for p in checked if p in by_path}
    result = {
        "claims": 54, "full_same_scope_claims": 0,
        "grades": EXPECTED_GRADES, "registered_modules": 67,
        "directly_mapped_modules": len(direct),
        "registered_modules_without_direct_claim_link": len(by_path) - len(direct),
        "paper_local_sources": len(checked - direct),
        "pdf_digest_and_page_inventory_checked": pdf is not None,
        "warning": "This is an accounting and source-custody test; NOT a Lean compilation."
    }
    print("PASS claims=54 end_to_end=0 registry=67 mapped=%d paper_local=%d" %
          (len(direct), len(checked - direct)))
    return result

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--pdf", type=Path, default=None)
    ap.add_argument("--json-out", type=Path, default=None)
    args = ap.parse_args()
    result = audit(pdf=args.pdf)
    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(result, indent=2, sort_keys=True)+"\\n", encoding="utf-8")
