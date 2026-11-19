#!/usr/bin/env python3
"""Exact paired reviewer-score comparison: arithmetic only, no claimed trial."""
from __future__ import annotations

import argparse
from fractions import Fraction as Q
from math import comb
import json
from pathlib import Path


def mcnemar_two_sided_exact(b: int, c: int) -> Q:
    """Conditional sign/McNemar exact p-value for discordant matched cases."""
    if min(b, c) < 0:
        raise ValueError("discordant counts must be nonnegative")
    n = b + c
    if n == 0:
        return Q(1)
    return min(Q(1), Q(2*sum(comb(n, i) for i in range(min(b,c)+1)), 2**n))


def validate_report(report: dict, condition: str) -> dict:
    if report.get("schema") != "nightfall.exec-review.score.v1":
        raise ValueError("wrong score receipt schema")
    if report.get("condition") != condition or report.get("condition_enforced_by_oracle") is not False:
        raise ValueError("wrong or falsely enforced reviewer condition")
    if report.get("blind_holdout") is not False:
        raise ValueError("this comparison only handles public calibration")
    outcomes = report.get("outcomes", [])
    if len(outcomes) != 16 or len(set(c["id"] for c in outcomes)) != 16:
        raise ValueError("invalid paired outcome count")
    allowed = {"valid", "invalid", "uncertain"}
    for x in outcomes:
        if x["truth"] not in ("valid", "invalid") or x["verdict"] not in allowed:
            raise ValueError("invalid outcome truth/verdict")
        if x["correct"] != (x["verdict"] == x["truth"]):
            raise ValueError("incorrectly scored outcome")
    return {x["id"]: x for x in outcomes}


def compare(prose: dict, executable: dict) -> dict:
    p = validate_report(prose, "prose_only")
    e = validate_report(executable, "executable")
    if prose["reviewer_id"] == executable["reviewer_id"]:
        raise ValueError("reviewers must be distinct agents; IDs alone do not prove independence")
    if prose.get("case_sha256") != executable.get("case_sha256") or set(p) != set(e):
        raise ValueError("paired reviewers did not receive the same frozen cases")
    for cid in p:
        if p[cid]["truth"] != e[cid]["truth"] or p[cid]["family"] != e[cid]["family"]:
            raise ValueError("truth or family mismatch in paired case " + cid)
    invalid = [cid for cid in p if p[cid]["truth"] == "invalid"]
    valid = [cid for cid in p if p[cid]["truth"] == "valid"]
    p_fa = sum(p[cid]["verdict"] == "valid" for cid in invalid)
    e_fa = sum(e[cid]["verdict"] == "valid" for cid in invalid)
    p_fr = sum(p[cid]["verdict"] == "invalid" for cid in valid)
    e_fr = sum(e[cid]["verdict"] == "invalid" for cid in valid)
    b = sum(p[cid]["verdict"] == "valid" and e[cid]["verdict"] != "valid" for cid in invalid)
    c = sum(p[cid]["verdict"] != "valid" and e[cid]["verdict"] == "valid" for cid in invalid)
    return {
        "schema": "nightfall.exec-review.public-pair.v1",
        "status": "descriptive-arithmetic-only",
        "causal_claim_permitted": False,
        "blind_trial": False,
        "verified_equal_budgets": False,
        "verified_reviewer_independence": False,
        "prose_id": prose["reviewer_id"], "executable_id": executable["reviewer_id"],
        "case_sha256": prose["case_sha256"],
        "invalid_claims": len(invalid), "valid_claims": len(valid),
        "prose_false_accept": p_fa, "exec_false_accept": e_fa,
        "false_accept_reduction_fraction": str(Q(p_fa-e_fa, len(invalid))),
        "prose_false_reject": p_fr, "exec_false_reject": e_fr,
        "false_reject_increase_fraction": str(Q(e_fr-p_fr, len(valid))),
        "paired_discordant_prose_bad_exec_good": b,
        "paired_discordant_prose_good_exec_bad": c,
        "mcnemar_exact_two_sided_p": str(mcnemar_two_sided_exact(b, c)),
        "note": "Public calibration and self-declared conditions only. Do not interpret as a model effect; no costs, arm enforcement, or external review verified.",
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--prose", type=Path, required=True)
    parser.add_argument("--executable", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    report = compare(json.loads(args.prose.read_text()), json.loads(args.executable.read_text()))
    encoded = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.write_text(encoded, encoding="utf-8")
    print(encoded)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
