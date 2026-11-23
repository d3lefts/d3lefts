#!/usr/bin/env python3
"""Validate predeclared independent review tasks without claiming review was run."""
import argparse
import json
from pathlib import Path

HERE = Path(__file__).resolve().parents[1]
PATH = "research/nightfall/verification/HEADLINE_REVIEW_PREREG_V1.json"
LEDGER = "research/nightfall/verification/HEADLINE_TRUST_BOUNDARIES_V1.json"


def validate(plan, ledger):
    if plan.get("schema") != "nightfall.headline-review-prereg/v1":
        raise ValueError("wrong review plan schema")
    if plan.get("dated") != "2026-11-23" or plan.get("status") != "not_executed":
        raise ValueError("historical preregistration cannot be rewritten as an executed audit")
    if plan.get("independence_not_established") is not True:
        raise ValueError("role labels are not actual independence")
    if not isinstance(plan.get("role_assignment"), dict) or len(plan["role_assignment"]) != 5:
        raise ValueError("review roles missing")
    trials = plan.get("trials")
    if not isinstance(trials, list) or [t.get("id") for t in trials] != [r["id"] for r in ledger["records"]]:
        raise ValueError("review tasks must cover the exact eight identities")
    for t in trials:
        if t.get("status") != "not_run" or t.get("receipt") is not None or t.get("independent_audit_completed") is not False:
            raise ValueError("unsupported evidence or retrospective audit promotion")
        for key in ("prediction", "alternative", "cheapest_decisive_test", "discriminator"):
            if not isinstance(t.get(key), str) or len(t[key]) < 35:
                raise ValueError("incomplete predeclared falsification experiment")
    return {"status": "EIGHT_REVIEW_PLANS_PREREGISTERED_UNRUN",
            "plans": len(trials), "independent_reviews_executed": 0,
            "counterexample_tests_executed": 0, "release_authorized": False}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--root", type=Path, default=HERE)
    p.add_argument("--json-out", type=Path)
    a = p.parse_args()
    plan = json.loads((a.root / PATH).read_text())
    ledger = json.loads((a.root / LEDGER).read_text())
    r = validate(plan, ledger)
    if a.json_out:
        a.json_out.parent.mkdir(parents=True, exist_ok=True)
        a.json_out.write_text(json.dumps(r, indent=2) + "\n")
    print(json.dumps(r, indent=2))


if __name__ == "__main__":
    main()
