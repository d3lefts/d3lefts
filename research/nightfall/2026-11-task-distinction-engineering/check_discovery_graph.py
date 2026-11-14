#!/usr/bin/env python3
"""Semantic metadata consistency check; NOT a mathematical proof of portfolio claims."""
import json
from pathlib import Path

p=Path(__file__).with_name("DISCOVERY_GRAPH.json")
g=json.loads(p.read_text())
assert g["schema_version"]==1
claims=g["claims"]
names=[c["id"] for c in claims]
assert len(names)==len(set(names))>=10
source=set(names)
for c in claims:
    assert c["claim"] and c["source"] and c["limit"] and c["certificate"]
    assert c["status"] in {
        "independent_finite_certificate","exact_constructive_witness",
        "analytic_elementary_verified_finite","historically_scoped_lean_with_import",
        "author_analytic_candidate","exact_identity_conditional_algorithm",
        "synthesis_not_mathematical_theorem",
    }
    for d in c.get("dependencies",[]):
        assert d in source and d!=c["id"]
for e in g["transfers"]:
    assert e["from"] in source and e["to"] in source
    assert e["operator"] and e["test"]
    assert e["relation"] in {
        "case_study_not_logical_implication","conditional_source_reuse",
        "conditional_theorem_import",
    }
    if e["relation"]=="conditional_theorem_import":
        assert e["from"] in {"product_all_degree","q2"}
deps={c["id"]:set(c.get("dependencies",[])) for c in claims}
closed=set()
def visit(x,stack):
    assert x not in stack,("dependency_cycle",x,stack)
    if x in closed:return
    for y in deps[x]:visit(y,stack|{x})
    closed.add(x)
for x in names:visit(x,set())
# Never promote still-open Q2 and history claims in metadata.
assert next(c for c in claims if c["id"]=="q2")["status"]=="author_analytic_candidate"
assert next(c for c in claims if c["id"]=="thesis")["status"]=="synthesis_not_mathematical_theorem"
assert next(c for c in claims if c["id"]=="four_shuffle")["limit"].lower().find("priority")>=0
print({"claims":len(claims),"transfers":len(g["transfers"]),
       "dependency_DAG":True,"research_status_contract":"PASS"})
