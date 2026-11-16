"""Generate a candidate ground proof, never an authority or an official vote."""
from __future__ import annotations


def derive(case):
    steps, proven = [], {}
    for src in case["sources"]:
        for fact in src["facts"]:
            sid = "fact:" + fact["id"]
            steps.append({"id": sid, "kind": "source_fact", "source_id": src["id"],
                          "fact_id": fact["id"], "conclusion": fact["proposition"]})
            proven[fact["id"]] = sid
    remaining = [(s["id"], r) for s in case["sources"] for r in s["rules"]]
    while remaining:
        advanced = False
        next_round = []
        for source_id, rule in remaining:
            if all(k in proven for k in rule["requires"]):
                sid = "rule:" + rule["id"]
                steps.append({"id": sid, "kind": "apply_rule", "source_id": source_id,
                              "rule_id": rule["id"],
                              "premises": [proven[k] for k in rule["requires"]],
                              "conclusion": rule["conclusion"]})
                proven[rule["id"]] = sid
                advanced = True
            else:
                next_round.append((source_id, rule))
        if not advanced:
            break
        remaining = next_round
    return {"case_id": case["case_id"], "jurisdiction": case["jurisdiction"],
            "legal_at": case["legal_at"], "known_at": case["known_at"],
            "steps": steps, "unresolved_rule_ids": [r["id"] for _, r in remaining]}
