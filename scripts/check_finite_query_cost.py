#!/usr/bin/env python3
"""Exact finite conditional query-cost accounting; no oracle-correctness proof.

A node specifies the cost charged at that node and the conditional probability
of the 'yes' branch. No unsupported assumption of input-independent branching
or quantum physical oracle equivalence is made. Proved claims are ONLY rational
arithmetic properties of this supplied finite tree.
"""
import argparse
import hashlib
import json
import re
from fractions import Fraction
from pathlib import Path

LIMIT_DEPTH = 32
LIMIT_NODES = 4096
RATIONAL = re.compile(r"-?\d+(?:/[1-9]\d*)?\Z")


def rat(value):
    if not isinstance(value, str) or len(value) > 80 or not RATIONAL.fullmatch(value):
        raise ValueError("probability/bound must be an exact rational string")
    result = Fraction(value)
    if abs(result.numerator) > 10**30 or result.denominator > 10**30:
        raise ValueError("rational too large")
    return result


def evaluate(tree):
    nodes = [0]
    def walk(t, depth):
        nodes[0] += 1
        if nodes[0] > LIMIT_NODES or depth > LIMIT_DEPTH:
            raise ValueError("finite tree exceeds budget")
        if not isinstance(t, dict):
            raise ValueError("node is not an object")
        if t.get("kind") == "leaf":
            if set(t) != {"kind", "outcome"} or not isinstance(t["outcome"], str) or not t["outcome"]:
                raise ValueError("leaf needs explicit outcome")
            return Fraction(0), 0, {t["outcome"]: Fraction(1)}
        if t.get("kind") != "query" or set(t) != {"kind", "oracle_calls", "p_yes", "yes", "no"}:
            raise ValueError("query requires exact charge, probability, two branches")
        charge = t["oracle_calls"]
        if type(charge) is not int or not 1 <= charge <= 10**6:
            raise ValueError("oracle query charge must be a positive integer")
        p = rat(t["p_yes"])
        if p < 0 or p > 1:
            raise ValueError("invalid conditional probability")
        yes_e, yes_w, yes_dist = walk(t["yes"], depth + 1)
        no_e, no_w, no_dist = walk(t["no"], depth + 1)
        dist = {key: p * yes_dist.get(key, 0) + (1-p) * no_dist.get(key, 0)
                for key in yes_dist.keys() | no_dist.keys()}
        return charge + p*yes_e + (1-p)*no_e, charge + max(yes_w, no_w), dist
    result = walk(tree, 0)
    if sum(result[2].values(), Fraction(0)) != 1:
        raise ValueError("probability mass not conserved")
    return result


def check_contract(spec):
    if spec.get("schema") != "nightfall.finite-conditional-query-cost/v1":
        raise ValueError("unknown resource contract")
    for key in ("physical_oracle_equivalence_proven", "branch_probability_model_proven",
                "algorithm_correctness_proven", "general_query_simulation_proven"):
        if spec.get(key) is not False:
            raise ValueError("unproved model/correctness promotion: " + key)
    if spec.get("scope") != "finite-conditional-query-tree":
        raise ValueError("cost theorem scope drift")
    if not isinstance(spec.get("assumptions"), list) or len(spec["assumptions"]) < 3:
        raise ValueError("conditional branch and oracle assumptions must be explicit")
    expect, worst, dist = evaluate(spec.get("tree"))
    upper = rat(spec.get("expected_upper_bound"))
    bound_worst = spec.get("worst_upper_bound")
    if type(bound_worst) is not int or bound_worst < 0:
        raise ValueError("worst bound must be an integer")
    if expect > upper or worst > bound_worst:
        raise ValueError("claimed query resource bound is false")
    if upper < 0:
        raise ValueError("negative cost bound")
    return {
        "schema": "nightfall.finite-conditional-query-cost-receipt/v1",
        "status": "EXACT_FINITE_CONDITIONAL_COST_ONLY",
        "expected_oracle_calls": str(expect), "worst_case_calls": worst,
        "outcome_masses": {k: str(v) for k,v in sorted(dist.items())},
        "probability_mass": "1", "bound_verified": True,
        "model_validated": False, "algorithm_correctness_proven": False,
        "physical_oracle_equivalence_proven": False
    }


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("contract", type=Path)
    p.add_argument("--json-out", type=Path)
    a = p.parse_args()
    data = a.contract.read_bytes()
    result = check_contract(json.loads(data))
    result["contract_sha256"] = hashlib.sha256(data).hexdigest()
    if a.json_out:
        a.json_out.parent.mkdir(parents=True, exist_ok=True)
        a.json_out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
