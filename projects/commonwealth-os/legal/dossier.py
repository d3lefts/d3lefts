"""Neutral fictional civic dossier assembly, without profile storage or ballots."""
from __future__ import annotations

import json
from pathlib import Path
from kernel import evaluate
from independent_checker import check


class DossierError(ValueError):
    pass


def assemble(path: Path):
    path = Path(path).resolve()
    dossier = json.loads(path.read_text(encoding="utf-8"))
    if dossier.get("schema") != "commonwealth.civic-dossier.demo.v1" or dossier.get("mode") != "DEMO":
        raise DossierError("official or unknown dossier prohibited")
    if dossier.get("jurisdiction") != "FICTIONAL_RIVER_COUNTY":
        raise DossierError("real jurisdiction prohibited")
    if dossier.get("decision_authority") != "NOT_ESTABLISHED" or dossier.get("decision_mode") != "ADVISORY_SIMULATION":
        raise DossierError("this demo cannot certify official authority")
    privacy = dossier["privacy_contract"]
    if (not isinstance(privacy, dict) or
        set(privacy) != {"collect_response", "persist_response", "cast_ballot", "infer_profile", "share_with_party"} or
        any(value is not False for value in privacy.values())):
        raise DossierError("no consent/profile/ballot effects allowed")
    required_fields = {"zoning_and_review", "median_housing_cost",
                       "comparable_building_occupancy", "developer_and_beneficial_ownership",
                       "traffic_utilities_and_public_cost", "floodplain_environment"}
    sections = dossier["evidence_sections"]
    if (not isinstance(sections, list) or len(sections) != len(required_fields) or
        {row["field"] for row in sections} != required_fields):
        raise DossierError("incomplete evidence categories")
    if any(row.get("status") not in ("FICTIONAL_LEGAL_DERIVATION", "MISSING") for row in sections):
        raise DossierError("unsupported empirical certainty")
    name = dossier["legal_passport"]
    if not isinstance(name, str) or Path(name).name != name or name != "riverfront_passport.json":
        raise DossierError("unsupported proof bundle")
    proof_path = (path.parent / name).resolve()
    if proof_path.parent != path.parent:
        raise DossierError("invalid proof path")
    proof = json.loads(proof_path.read_text(encoding="utf-8"))
    if proof.get("jurisdiction") != dossier["jurisdiction"]:
        raise DossierError("jurisdiction mismatch")
    primary, independent = evaluate(proof), check(proof)
    if primary["status"] != independent["status"]:
        raise DossierError("legal checker disagreement")
    if primary["status"] == "SUPPORTED_IN_FICTIONAL_MODEL":
        if primary["dependencies"] != independent.get("dependencies"):
            raise DossierError("source dependency disagreement")
    if set(dossier["response_choices"]) != {
        "SUPPORT", "DO_NOT_SUPPORT", "NO_PREFERENCE", "NEED_MORE_INFORMATION", "SKIP"
    }:
        raise DossierError("missing/invalid response choices")
    # No input, event emitter, write path, identity lookup or response capture.
    return {
        "decision_id": dossier["decision_id"],
        "title": dossier["title"],
        "question": dossier["question"],
        "proposal_version": dossier["proposal_version"],
        "mode": "DEMO_ADVISORY_NO_VOTE",
        "decision_authority": "NOT_ESTABLISHED",
        "proof_status": primary["status"],
        "proof_goal": primary.get("goal"),
        "legal_as_of": proof["as_of"],
        "legal_known_at": proof["known_at"],
        "source_dependencies": primary.get("dependencies", {}),
        "evidence_sections": sections,
        "considerations": dossier["considerations"],
        "response_choices": dossier["response_choices"],
        "privacy_contract": privacy,
        "limitations": dossier["limits"],
    }


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Assemble FICTIONAL riverfront civic dossier")
    parser.add_argument("dossier", nargs="?", type=Path,
                        default=Path(__file__).parent / "fixtures" / "riverfront_dossier.json")
    args = parser.parse_args()
    print(json.dumps(assemble(args.dossier), sort_keys=True, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
