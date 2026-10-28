#!/usr/bin/env python3
"""Independent exact checker of the frozen Sidon-30 finite UNSAT proof DAG.

This independently verifies each stored proof step, unlike the source DAG
generator (which chooses branches and constructs the proof), and unlike the
existing recursive standalone search (which explores fresh states).
All arithmetic is exact integer arithmetic. No external solver.
"""
from __future__ import annotations
from itertools import combinations
from pathlib import Path
import hashlib
import json
import sys

ROOT = Path(__file__).resolve().parent.parent
D = ROOT / "research/nightfall/projects/sidon-finite-30"
INPUT_SHA = "dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f"
DAG_SHA = "4e31c53667cba63db34354eb861f503ac7284a0e76cd7219306dff8239032181"
# Explicit 17-set is independently checked from integers; finding this witness
# and proving 18 impossible are deliberately separate proof obligations.
LOWER_WITNESS = (0,7091378,7308461,7782977,7797503,7829255,7830227,7835411,
                 7836059,7849019,7874975,7884659,8078339,8466237,8610959,11505399,19465109)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate(data: dict, values: tuple[int, ...]) -> dict:
    if data.get("format") != "NIGHTFALL-SIDON-UNSAT-DAG-v1" or \
       data.get("n") != 30 or data.get("target_deletions") != 12:
        raise ValueError("Incorrect proof format, number of integers or deletion budget")
    if len(values) != 30 or values != tuple(sorted(set(values))):
        raise ValueError("The 30-point source witness is malformed")
    tests = 0
    for i, j, k, l in combinations(range(30), 4):
        tests += 1
        q = (values[i], values[j], values[k], values[l])
        differences = {q[y] - q[x] for x in range(4) for y in range(x + 1, 4)}
        if len(differences) < 5:
            raise ValueError(f"Weak Sidon property fails on indices {(i,j,k,l)}")
    if tests != 27405:
        raise ValueError("Unexpected 4-subset enumeration count")
    if len(set(LOWER_WITNESS)) != 17 or not set(LOWER_WITNESS).issubset(values):
        raise ValueError("Lower 17-element witness missing or duplicated")
    unordered_pair_sums = {LOWER_WITNESS[i] + LOWER_WITNESS[j]
                           for i in range(17) for j in range(i,17)}
    if len(unordered_pair_sums) != 153:
        raise ValueError("Lower 17-element witness contains additive collisions")

    progressions = frozenset(
        (1 << i) | (1 << j) | (1 << k)
        for i,j,k in combinations(range(30),3)
        if values[i] + values[k] == 2 * values[j]
    )
    if len(progressions) != 28:
        raise ValueError("AP hypergraph count incorrect")
    nodes = data.get("nodes", {})
    if not isinstance(nodes, dict) or len(nodes) != 7801:
        raise ValueError("Proof DAG number of states incorrect")
    if data.get("root") != "0:12" or data["root"] not in nodes:
        raise ValueError("Proof root missing")
    all_bits = (1 << 30) - 1
    for key, v in nodes.items():
        try:
            deleted_text, budget_text = key.split(":")
            deleted, budget = int(deleted_text), int(budget_text)
        except (ValueError, AttributeError) as exc:
            raise ValueError(f"Malformed state key {key}") from exc
        if deleted < 0 or deleted & ~all_bits or budget < 0 or \
           budget != 12 - deleted.bit_count() or v.get("deleted") != deleted or \
           v.get("budget") != budget:
            raise ValueError(f"Invalid state identity or budget {key}")
        uncovered = progressions.difference(e for e in progressions if e & deleted)
        if not uncovered:
            raise ValueError(f"A legal 18-point transversal exists at state {key}")
        if v.get("kind") == "packing":
            p = v.get("packing")
            if not isinstance(p,list) or len(p) <= budget:
                raise ValueError(f"Packing lower bound does not exceed budget {key}")
            used = 0
            for edge in p:
                if edge not in uncovered or used & edge:
                    raise ValueError(f"Packing is invalid or overlaps at {key}")
                used |= edge
        elif v.get("kind") == "branch":
            edge = v.get("edge")
            child_keys = v.get("children")
            if edge not in uncovered or not isinstance(child_keys,list):
                raise ValueError(f"Invalid uncovered branching edge {key}")
            expected = {f"{deleted | (1 << i)}:{budget-1}"
                        for i in range(30) if edge & (1 << i)}
            if len(expected) != 3 or set(child_keys) != expected or \
               len(child_keys) != 3 or any(child not in nodes for child in expected):
                raise ValueError(f"Branch omits or repeats a deletion choice at {key}")
        else:
            raise ValueError(f"Unknown proof node at {key}")
    reached = set()
    pending = [data["root"]]
    while pending:
        key = pending.pop()
        if key in reached:
            continue
        reached.add(key)
        v = nodes[key]
        if v["kind"] == "branch":
            pending.extend(v["children"])
    if reached != set(nodes):
        raise ValueError("Unreachable proof nodes remain in DAG")

    return {
        "status":"PASS",
        "claim":"30-point weak Sidon witness has maximum Sidon subset cardinality 17",
        "scope":"This exact finite 30-element witness only; no new asymptotic or priority claim",
        "four_point_tests":tests,
        "three_term_progressions":len(progressions),
        "lower_sidon_subset_size":17,
        "upper_sidon_subset_size":17,
        "all_proof_states":len(nodes),
        "reachable_states":len(reached),
        "proof_method":"Independently checked complete 3-way AP-hitting branch DAG with disjoint edge packing leaves",
    }


def main() -> int:
    witness=D/"witness_30.txt"
    proof=D/"sidon_no_18_proof.json"
    if digest(witness) != INPUT_SHA:
        raise ValueError("Original witness SHA-256 mismatch")
    if not proof.is_file() or digest(proof) != DAG_SHA:
        raise ValueError("Proof DAG absent or SHA-256 differs from archival generator")
    values=tuple(map(int,witness.read_text(encoding="utf-8").strip().split(",")))
    data=json.loads(proof.read_text(encoding="utf-8"))
    result=validate(data,values)
    # Deliberate negative fixture: a valid proof fails when one branch choice
    # is dropped. Inspect this independently of the source DAG generator.
    import copy
    mutation=copy.deepcopy(data)
    root=mutation["nodes"][mutation["root"]]
    if root["kind"] == "branch":
        root["children"]=root["children"][:-1]
    else:
        root["packing"]=[]
    try:
        validate(mutation,values)
    except ValueError:
        result["corrupt_proof_negative_control"]="PASS (rejected)"
    else:
        raise AssertionError("DAG tamper control was accepted")
    result["witness_sha256"]=digest(witness)
    result["dag_sha256"]=digest(proof)
    result["dag_generator_sha256"]=digest(D/"generate_proof_dag.py")
    result["independent_dag_checker_sha256"]=digest(Path(__file__))
    result["standalone_search_checker_sha256"]=digest(D/"verify_sidon30_standalone.py")
    receipt=ROOT/"nightfall_gate_b_sidon_receipt.json"
    receipt.write_text(json.dumps(result,sort_keys=True,indent=2)+"\n",encoding="utf-8")
    print(json.dumps(result,sort_keys=True,indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
