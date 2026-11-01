#!/usr/bin/env python3
"""Exact direct-pair-sum replay of a frozen 30-point (4,5) set.

A second internal computational route, not an independent human proof.
Unlike verify_sidon30_standalone.py, this code never constructs an AP
hypergraph or solves a hitting-set problem. It enumerates potential Sidon
subsets using the definition of Sidon: all unordered pair sums, including
diagonal pairs, must be distinct.

A depth-first search visits every increasing candidate sequence of target
size unless a pair-sum collision or a cardinality bound makes extension
mathematically impossible. Therefore an exhausted target-18 search, alongside
a target-17 witness, establishes h(A)=17 for the *frozen input*.
"""
from hashlib import sha256
from itertools import combinations
from pathlib import Path
import json


WITNESS_HASH = "dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f"
HERE = Path(__file__).resolve().parent


def read_frozen(path):
    raw = Path(path).read_bytes()
    observed = sha256(raw).hexdigest()
    if observed != WITNESS_HASH:
        raise ValueError("Witness SHA-256 mismatch: " + observed)
    values = tuple(int(x) for x in raw.strip().split(b","))
    if len(values) != 30 or tuple(sorted(set(values))) != values:
        raise ValueError("Expected exactly 30 distinct, sorted integers")
    return values


def check_45(values):
    tested = 0
    for four in combinations(values, 4):
        tested += 1
        differences = {v-u for u, v in combinations(four, 2)}
        if len(differences) < 5:
            raise AssertionError("(4,5) counterexample: " + repr(four))
    return tested


def search_exact_size(values, target):
    counts = {"visited_nodes": 0, "accepted_extensions": 0,
              "pair_sum_collisions": 0}
    n = len(values)

    def visit(start, selected, old_sums):
        counts["visited_nodes"] += 1
        if len(selected) == target:
            return tuple(selected)
        if len(selected) + n - start < target:
            return None
        for i in range(start, n):
            if len(selected) + n - i < target:
                break
            v = values[i]
            new_sums = {v + u for u in selected}
            new_sums.add(2 * v)
            if len(new_sums) != len(selected) + 1 or not new_sums.isdisjoint(old_sums):
                counts["pair_sum_collisions"] += 1
                continue
            counts["accepted_extensions"] += 1
            witness = visit(i+1, selected+(v,), old_sums | new_sums)
            if witness is not None:
                return witness
        return None

    answer = visit(0, (), set())
    return answer, counts


def verify(path=HERE/"witness_30.txt"):
    values = read_frozen(path)
    tested = check_45(values)
    subset17, counts17 = search_exact_size(values, 17)
    if subset17 is None:
        raise AssertionError("Could not construct a 17-point Sidon subset")
    subset18, counts18 = search_exact_size(values, 18)
    if subset18 is not None:
        raise AssertionError("Counterexample: 18-point Sidon subset: " + repr(subset18))
    return {
        "status": "PASS",
        "statement": "For this frozen 30-point (4,5) set, maximum Sidon subset size is 17",
        "witness_sha256": WITNESS_HASH,
        "four_point_checks": tested,
        "explicit_17_subset": list(subset17),
        "no_18_subset": True,
        "max_sidon_subset_size": 17,
        "size_17_search": counts17,
        "size_18_exhaustion": counts18,
        "method": "direct pair sums, distinct from arithmetic-progression hitting-set verification",
        "review_status": "internal computational reproduction; external human review not performed",
    }


if __name__ == "__main__":
    print(json.dumps(verify(), sort_keys=True, indent=2))
