#!/usr/bin/env python3
"""Verify a source-bound finite Bellman policy + subsolution certificate.

Model: finite binary source coordinates and complete declared bitcube of
baseline-to-final histories. Evidence reads are exact and coherent; each grant
is protected by an assumed atomic version-only fence. This is *not* an
operational proof that physical source versions are complete or authentic.

The checker never calls the policy generator/optimizer. It validates all
nonempty baseline subsets (not merely states reached by the claimed policy),
every available stop/read Bellman lower-bound inequality, each chosen
upper-bound action, and all source-derived guard safety conditions.
"""
from __future__ import annotations
import argparse
import copy
import hashlib
import json
from fractions import Fraction
from pathlib import Path

SCHEMA = "nightfall-semantic-bellman-certificate/v1"
MODEL = "nightfall-complete-bitcube-evidence/v1"


def rational(v):
    if isinstance(v, bool) or not isinstance(v, (str, int)):
        raise ValueError("expected exact rational string/integer")
    return Fraction(str(v))


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()


def sha(value):
    return hashlib.sha256(canonical(value)).hexdigest()


def parse_model(src):
    if not isinstance(src, dict) or src.get("kind") != MODEL:
        raise ValueError("unrecognized semantic model")
    if src.get("change_history") != "complete-baseline-to-final-xor":
        raise ValueError("unsupported change history; physical versioning not certified")
    n = src.get("sources")
    if type(n) is not int or not 1 <= n <= 7:
        raise ValueError("invalid finite source count")
    baseline, unsafe = src.get("baseline_worlds"), src.get("unsafe_worlds")
    if not isinstance(baseline, list) or not baseline or not isinstance(unsafe, list):
        raise ValueError("missing world sets")
    if any(type(i) is not int or not 0 <= i < 2 ** n for i in baseline + unsafe):
        raise ValueError("world outside declared bitcube")
    if len(set(baseline)) != len(baseline) or len(set(unsafe)) != len(unsafe):
        raise ValueError("duplicate world IDs")
    if set(baseline) & set(unsafe):
        raise ValueError("unsafe snapshot declared certified-safe")
    if len(baseline) > 10:
        raise ValueError("enumeration budget exceeded")
    rd, gc = src.get("read_costs"), src.get("guard_costs")
    if not isinstance(rd, list) or not isinstance(gc, list) or len(rd) != n or len(gc) != n:
        raise ValueError("cost dimension mismatch")
    r, c = [rational(z) for z in rd], [rational(z) for z in gc]
    if any(z <= 0 for z in r + c):
        raise ValueError("positive costs required")
    return n, tuple(sorted(baseline)), frozenset(unsafe), r, c


def masks_from_source(base):
    top = sum(1 << w for w in base)
    return top, {mask for mask in range(1, top + 1) if (mask & ~top) == 0}


def guard_safety(mask, guard, base, unsafe):
    for b in base:
        if mask & (1 << b):
            for u in unsafe:
                if (b ^ u) & guard == 0:
                    return False
    return True


def guard_cost(guard, costs):
    return sum((costs[i] for i in range(len(costs)) if guard & (1 << i)), Fraction(0))


def split(mask, i, base):
    z = sum(1 << b for b in base if (mask & (1 << b)) and (b & (1 << i)) == 0)
    return z, mask ^ z


def check(payload):
    if not isinstance(payload, dict) or payload.get("schema") != SCHEMA:
        raise ValueError("unknown Bellman certificate format")
    src, cert = payload.get("source_model"), payload.get("certificate")
    if not isinstance(src, dict) or not isinstance(cert, dict):
        raise ValueError("missing source model or proof object")
    if cert.get("source_sha256") != sha(src):
        raise ValueError("original model digest mismatch")
    n, base, unsafe, reads, guards = parse_model(src)
    root, masks = masks_from_source(base)
    if cert.get("root_belief") != root:
        raise ValueError("root belief mismatches genuine baseline")
    states = cert.get("states")
    if not isinstance(states, dict) or set(states) != {str(k) for k in masks}:
        raise ValueError("Bellman table must include EVERY nonempty baseline subset")
    values, actions = {}, {}
    for mask in masks:
        data = states[str(mask)]
        if not isinstance(data, dict) or set(data) != {"value", "choice"}:
            raise ValueError("state has extra/absent fields")
        v = rational(data["value"])
        if v < 0:
            raise ValueError("negative cost-to-go")
        values[mask] = v
        actions[mask] = data["choice"]

    alternative_checks = 0
    for mask in sorted(masks):
        lower = values[mask]
        candidate = actions[mask]
        if not isinstance(candidate, dict):
            raise ValueError("malformed policy node")
        # Every feasible immediate grant is a competing action. The source
        # predicate is reconstructed from worlds, not submitted hyperedges.
        for J in range(1 << n):
            if guard_safety(mask, J, base, unsafe):
                alternative_checks += 1
                if lower > guard_cost(J, guards):
                    raise ValueError("Bellman lower potential exceeds feasible grant")
        for i in range(n):
            zero, one = split(mask, i, base)
            if zero and one:
                alternative_checks += 1
                option = reads[i] + max(values[zero], values[one])
                if lower > option:
                    raise ValueError("Bellman lower potential exceeds a splitting read")
        kind = candidate.get("kind")
        if kind == "grant":
            if set(candidate) != {"kind", "guard"}:
                raise ValueError("unrecognized grant fields")
            J = candidate["guard"]
            if type(J) is not int or not 0 <= J < (1 << n):
                raise ValueError("invalid guard bits")
            if not guard_safety(mask, J, base, unsafe):
                raise ValueError("chosen grant admits unsafe source change")
            charged = guard_cost(J, guards)
        elif kind == "read":
            if set(candidate) != {"kind", "source"}:
                raise ValueError("unrecognized read fields")
            i = candidate["source"]
            if type(i) is not int or not 0 <= i < n:
                raise ValueError("invalid observed source")
            zero, one = split(mask, i, base)
            if not zero or not one:
                raise ValueError("read does not strictly shrink belief in both branches")
            charged = reads[i] + max(values[zero], values[one])
        else:
            raise ValueError("unrecognized policy action")
        if lower != charged:
            raise ValueError("claimed policy does not attain Bellman lower bound")
    # The tree has finite depth: every read strictly reduces belief cardinality,
    # and a granted leaf has been verified against all unsafe modeled finals.
    claimed = rational(cert.get("claimed_optimal_cost"))
    if values[root] != claimed:
        raise ValueError("root value differs from claimed optimum")
    return {
        "status": "PASS", "source_bound": True, "root": root,
        "cost": str(values[root]), "belief_states": len(masks),
        "alternative_action_checks": alternative_checks,
        "source_sha256": sha(src),
        "scope": "exact finite coherent-snapshot Bellman minimax, complete declared XOR histories only"
    }


def self_test():
    source = {
        "kind": MODEL, "change_history": "complete-baseline-to-final-xor",
        "sources": 2, "baseline_worlds": [0, 1, 2], "unsafe_worlds": [3],
        "read_costs": ["1", "1"], "guard_costs": ["4", "4"]
    }
    states = {
        "1": {"value": "4", "choice": {"kind": "grant", "guard": 1}},
        "2": {"value": "4", "choice": {"kind": "grant", "guard": 2}},
        "3": {"value": "4", "choice": {"kind": "grant", "guard": 2}},
        "4": {"value": "4", "choice": {"kind": "grant", "guard": 1}},
        "5": {"value": "4", "choice": {"kind": "grant", "guard": 1}},
        "6": {"value": "5", "choice": {"kind": "read", "source": 0}},
        "7": {"value": "5", "choice": {"kind": "read", "source": 0}}
    }
    payload = {"schema": SCHEMA, "source_model": source, "certificate": {
        "source_sha256": sha(source), "root_belief": 7,
        "states": states, "claimed_optimal_cost": "5"
    }}
    assert check(payload)["cost"] == "5"
    mutations = []
    def mutate(keys, value):
        p = copy.deepcopy(payload)
        node = p
        for k in keys[:-1]:
            node = node[k]
        node[keys[-1]] = value
        mutations.append(p)
    mutate(["certificate", "source_sha256"], "0" * 64)
    mutate(["certificate", "root_belief"], 3)
    mutate(["certificate", "claimed_optimal_cost"], "4")
    mutate(["certificate", "states", "7", "value"], "4")
    mutate(["certificate", "states", "7", "value"], "6")
    mutate(["certificate", "states", "7", "choice"], {"kind": "grant", "guard": 1})
    mutate(["certificate", "states", "7", "choice"], {"kind": "read", "source": 2})
    mutate(["certificate", "states", "1", "choice"], {"kind": "grant", "guard": 0})
    mutate(["certificate", "states", "1", "choice"], {"kind": "read", "source": 0})
    mutate(["certificate", "states", "3", "value"], "5")
    mutate(["certificate", "states", "6", "value"], "4")
    mutate(["certificate", "states", "4", "value"], "3")
    mutate(["certificate", "states", "5", "choice"], {"kind": "grant", "guard": 2})
    mutate(["certificate", "states", "7", "choice"], {"kind": "deny"})
    mutate(["source_model", "unsafe_worlds"], [1, 3])
    mutate(["source_model", "change_history"], "unsensed-ABA-changes")
    mutate(["source_model", "baseline_worlds"], [0, 1])
    p = copy.deepcopy(payload); del p["certificate"]["states"]["5"]; mutations.append(p)
    p = copy.deepcopy(payload); p["certificate"]["states"]["8"] = {"value": "0", "choice": {"kind": "grant", "guard": 0}}; mutations.append(p)
    for k, mutant in enumerate(mutations):
        try:
            check(mutant)
        except (ValueError, TypeError, KeyError, ZeroDivisionError):
            pass
        else:
            raise AssertionError(f"accepted forged certificate #{k}")
    print(f"PASS: source-derived Bellman policy lower+upper cost 5, 7 beliefs, {len(mutations)} rejected mutations")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("certificate", nargs="?", type=Path)
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()
    if args.self_test:
        self_test()
    if args.certificate:
        print(json.dumps(check(json.loads(args.certificate.read_text())), sort_keys=True, indent=2))
    if not args.certificate and not args.self_test:
        ap.error("pass a model-bound Bellman certificate or --self-test")


if __name__ == "__main__":
    main()
