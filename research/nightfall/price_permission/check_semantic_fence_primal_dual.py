#!/usr/bin/env python3
"""Model-bound primal+dual optimality certificates for finite semantic fences.

The original model is a complete enumerated bitcube *by specification*.
An unsafe baseline-to-final history has touched set = baseline XOR final;
this models one epoch transition, not all physical or ABA write sequences.
The exact checker reconstructs every unsafe hyperedge, validates a Boolean
feasible fence and rational dual packing, then proves matching cost.

No floating point or optimizer; no claim of external history completeness.
"""
from __future__ import annotations
import argparse
import copy
from fractions import Fraction as Q
from hashlib import sha256
from itertools import product
import json
from pathlib import Path

SCHEMA = "nightfall-price-permission-primal-dual/v1"
SOURCE_KIND = "full-bitcube-semantic-fence/v1"
HISTORY = "all-baseline-to-final-world-single-epoch"


def parse_q(value):
    if isinstance(value, bool) or not isinstance(value, (str, int)):
        raise ValueError("only integer / exact rational strings permitted")
    return Q(str(value))


def canonical(value):
    return json.dumps(value, ensure_ascii=True, sort_keys=True, separators=(",", ":")).encode()


def sha(value):
    return sha256(canonical(value)).hexdigest()


def source_edges(source):
    if not isinstance(source, dict) or source.get("kind") != SOURCE_KIND:
        raise ValueError("unrecognized source model")
    if source.get("history_policy") != HISTORY:
        raise ValueError("unrecognized history policy")
    n = source.get("num_sources")
    if type(n) is not int or not (1 <= n <= 12):
        raise ValueError("invalid source count")
    baselines, unsafe, rawcost = (source.get(k) for k in
                                   ("baseline_worlds", "unsafe_worlds", "version_check_costs"))
    if (not isinstance(baselines, list) or not isinstance(unsafe, list)
            or not isinstance(rawcost, list) or len(rawcost) != n
            or not baselines or not unsafe):
        raise ValueError("missing source worlds or costs")
    domain = 1 << n
    for worlds in (baselines, unsafe):
        if any(type(x) is not int or x < 0 or x >= domain for x in worlds):
            raise ValueError("invalid world index")
        if len(set(worlds)) != len(worlds):
            raise ValueError("duplicate worlds")
    if set(baselines) & set(unsafe):
        raise ValueError("unsafe baseline")
    costs = [parse_q(x) for x in rawcost]
    if any(x <= 0 for x in costs):
        raise ValueError("version check costs must be strictly positive")
    # Enumerate the complete declared final-state bitcube, not submitted edges.
    edges = set()
    for b in baselines:
        for final in range(domain):
            if final not in unsafe:
                continue
            touched = b ^ final
            edge = tuple(i for i in range(n) if touched & (1 << i))
            edges.add(edge)
    if () in edges:
        raise ValueError("unsafe zero-change history: no version-only fence exists")
    if not edges:
        raise ValueError("no risky histories in source model")
    ordered = sorted(edges)
    A = [[int(i in edge) for i in range(n)] for edge in ordered]
    return {
        "edges": [list(edge) for edge in ordered],
        "A": A,
        "costs": [str(x) for x in costs]
    }


def evaluate(obj):
    if not isinstance(obj, dict) or obj.get("schema") != SCHEMA:
        raise ValueError("invalid certificate schema")
    source, model, cert = obj.get("source_model"), obj.get("derived_instance"), obj.get("certificate")
    if not isinstance(source, dict) or not isinstance(model, dict) or not isinstance(cert, dict):
        raise ValueError("missing model, derived instance or certificate")
    actual = source_edges(source)
    if actual != model:
        raise ValueError("derived incidence matrix disagrees with original source histories")
    if sha(source) != cert.get("source_sha256"):
        raise ValueError("original source SHA-256 mismatch")
    if sha(model) != cert.get("model_sha256"):
        raise ValueError("derived matrix SHA-256 mismatch")
    n = source["num_sources"]
    rows = model["A"]
    m = len(rows)
    primal, dual = cert.get("primal_fence"), cert.get("dual_packing")
    if not isinstance(primal, list) or len(primal) != n or not isinstance(dual, list) or len(dual) != m:
        raise ValueError("witness dimensions mismatch")
    if any(type(x) is not int or x not in (0, 1) for x in primal):
        raise ValueError("primal must be Boolean")
    lam = [parse_q(x) for x in dual]
    if any(x < 0 for x in lam):
        raise ValueError("dual must be nonnegative")
    c = [parse_q(x) for x in model["costs"]]
    for e in range(m):
        if sum(rows[e][i] * primal[i] for i in range(n)) < 1:
            raise ValueError("primal fence misses an unsafe history")
    for i in range(n):
        if sum((lam[e] * rows[e][i] for e in range(m)), Q(0)) > c[i]:
            raise ValueError("dual exceeds source cost")
    pcost = sum((c[i] * primal[i] for i in range(n)), Q(0))
    dcost = sum(lam, Q(0))
    claimed = parse_q(cert.get("claimed_optimal_cost"))
    if pcost != dcost or pcost != claimed:
        raise ValueError("matching optimality equality fails")
    return {
        "status": "PASS", "sources": n, "unsafe_edges": m,
        "optimal_cost": str(pcost), "primal_cost": str(pcost),
        "dual_lower_bound": str(dcost), "source_sha256": sha(source),
        "derived_sha256": sha(model),
        "scope": "complete finite declared bitcube and version-only guard; not physical enforcement or joint sensing optimum"
    }


def test():
    source = {
        "kind": SOURCE_KIND, "history_policy": HISTORY, "num_sources": 4,
        "baseline_worlds": [0], "unsafe_worlds": [3, 6, 12],
        "version_check_costs": ["3", "2", "2", "3"]
    }
    derived = source_edges(source)
    assert derived["edges"] == [[0, 1], [1, 2], [2, 3]]
    original = {
        "schema": SCHEMA, "source_model": source, "derived_instance": derived,
        "certificate": {"source_sha256": sha(source), "model_sha256": sha(derived),
                        "primal_fence": [0, 1, 1, 0],
                        "dual_packing": ["2", "0", "2"], "claimed_optimal_cost": "4"}
    }
    assert evaluate(original)["optimal_cost"] == "4"
    # An independent direct-guard enumeration verifies all 16 candidate fences.
    allowed = []
    for bits in product((0, 1), repeat=4):
        if all(any(bits[i] for i in range(4) if (b ^ u) & (1 << i))
               for b in source["baseline_worlds"] for u in source["unsafe_worlds"]):
            allowed.append((sum(Q(source["version_check_costs"][i]) * bits[i]
                                for i in range(4)), bits))
    assert min(allowed)[0] == Q(4)
    bad = []
    def mutate(path, val):
        obj = copy.deepcopy(original)
        cur = obj
        for key in path[:-1]:
            cur = cur[key]
        cur[path[-1]] = val
        bad.append(obj)
    mutate(["certificate", "primal_fence"], [0, 1, 0, 0])
    mutate(["certificate", "primal_fence"], [1, 1, 1, 0])
    mutate(["certificate", "primal_fence"], [0, 1, 1, 0.0])
    mutate(["certificate", "dual_packing"], ["3", "0", "2"])
    mutate(["certificate", "dual_packing"], ["2", "-1", "2"])
    mutate(["certificate", "dual_packing"], ["2", "0", "1"])
    mutate(["certificate", "claimed_optimal_cost"], "5")
    mutate(["certificate", "model_sha256"], "0" * 64)
    mutate(["certificate", "source_sha256"], "0" * 64)
    mutate(["source_model", "unsafe_worlds"], [3, 6, 12, 9])
    mutate(["source_model", "version_check_costs"], ["3", "1", "2", "3"])
    mutate(["derived_instance", "A"], [[1, 1, 0, 0], [0, 1, 1, 0]])
    mutate(["source_model", "baseline_worlds"], [0, 3])
    mutate(["source_model", "history_policy"], "arbitrary-unbounded-writes")
    for ix, candidate in enumerate(bad):
        try:
            evaluate(candidate)
        except (ValueError, TypeError, ZeroDivisionError):
            pass
        else:
            raise AssertionError("forged certificate accepted, mutation " + str(ix))
    print(f"PASS: exact original-world primal/dual cost 4, 16 exhaustive fences; {len(bad)} negative controls")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("path", nargs="?", type=Path)
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()
    if args.self_test:
        test()
    if args.path:
        print(json.dumps(evaluate(json.loads(args.path.read_text())), sort_keys=True, indent=2))
    if not args.self_test and not args.path:
        ap.error("supply a certificate path or --self-test")


if __name__ == "__main__":
    main()
