"""Produce a neutral, source-traceable, synthetic civic dossier as JSON.

Never writes a user preference or creates a ballot. No network requests.
"""
import argparse
import json
from pathlib import Path

try:
    from .derive import derive
    from .verify import verify, source_impact
except ImportError:
    from derive import derive
    from verify import verify, source_impact


def build(case):
    proof = derive(case)
    verification = verify(case, proof)
    evidence = [
        {"source_id": source["id"], "kind": source["kind"],
         "issuer": source["issuer"], "content_sha256": source["content_sha256"],
         "source_uri": source["source_uri"], "status": "FABRICATED_EXAMPLE",
         "facts": source["facts"]}
        for source in case["sources"]
    ]
    return {
        "schema": "commonwealth.synthetic.dossier.v1",
        "title": case["title"], "question": case["decision_question"],
        "case_id": case["case_id"], "notice": case["caution"],
        "legal_at": case["legal_at"], "known_at": case["known_at"],
        "proof": proof, "verification": verification,
        "evidence": evidence,
        "considerations": {
            "potential_benefits": ["Additional housing units", "Potential municipal revenue"],
            "potential_costs": ["Flood exposure", "Traffic and utility capacity", "Environmental impacts"],
            "status": "HYPOTHESES_ONLY_NOT_EVALUATED"
        },
        "unanswered": ["Actual property ownership and title", "Binding municipal zoning and amendments",
                       "Engineering/flood and infrastructure assessments",
                       "Accurate housing market sample and affordability impacts",
                       "Competent approval authority and required public process",
                       "Funding obligations, alternatives, and conflicts of interest"],
        "preference": {"choices": ["SUPPORT", "DO_NOT_SUPPORT", "NO_PREFERENCE", "NEED_MORE_INFORMATION", "SKIP"],
                       "stored": False, "ballot_cast": False, "identity_collected": False,
                       "mode": "DEMO_ONLY_EXPLICIT_CHOICE_REQUIRED"}
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", type=Path, default=Path(__file__).parent / "fixtures" / "riverfront.json")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--changed-source", action="append", default=[])
    args = parser.parse_args()
    case = json.loads(args.case.read_text(encoding="utf-8"))
    result = build(case)
    if args.changed_source:
        result["recertification"] = source_impact(case, result["proof"], args.changed_source)
    payload = json.dumps(result, indent=2, ensure_ascii=False, sort_keys=True) + "\n"
    if args.output:
        args.output.write_text(payload, encoding="utf-8")
    else:
        print(payload, end="")
    if result["verification"]["status"] == "INVALID":
        raise SystemExit(1)


if __name__ == "__main__":
    main()
