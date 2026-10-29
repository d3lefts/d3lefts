#!/usr/bin/env python3
"""Reproducible, conservative inventory audit of NIGHTFALL's curated 33.
No model judgement, no inference of missing denominators or prospective hit rates.
"""
import argparse, collections, json, pathlib

LEDGER = pathlib.Path(__file__).parents[2] / "SITE_CURATED_33_20261029.json"


def compute(path):
    data = json.loads(path.read_text())
    entries = data["entries"]
    ids = [e["id"] for e in entries]
    assert len(entries) == 33 and len(set(ids)) == len(ids)
    assert all(e.get("source") and e.get("evidence") and e.get("category") for e in entries)
    categories = dict(sorted(collections.Counter(e["category"] for e in entries).items()))
    evidence = dict(sorted(collections.Counter(e["evidence"] for e in entries).items()))
    assert sum(categories.values()) == sum(evidence.values()) == len(entries)
    result = {
        "cohort": data["snapshot"] + ":curated33",
        "cohort_size": len(entries),
        "categories": categories,
        "editorial_evidence_labels": evidence,
        "original_findings_core_whitelist_in_this_registry": data["original_findings_whitelist_count"],
        "original_findings_addendum_separate": 2,
        "total_editorially_approved_scoped_findings": 5,
        "candidate_to_certificate_survival": None,
        "preregistered_prediction_hit_rate": None,
        "demotion_rate": None,
        "kernel_checked_headline_theorem_count": None,
        "flags": [
            "Evidence labels count catalogue entries, not theorem certification stages.",
            "The two additional Original Findings come from a separate approval document.",
            "Missing stage-transition history prevents survival-rate estimation.",
            "Preregistration denominators require immutable pre-experiment timestamps.",
            "The original 2026-10-28 originality audit lists group-level disposition rows, not a claim-level event ledger.",
            "Kernel-proof status requires a pinned proof source and a successful Lean kernel check.",
        ],
    }
    return result


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--ledger", type=pathlib.Path, default=LEDGER)
    args = p.parse_args()
    print(json.dumps(compute(args.ledger), sort_keys=True, indent=2))
