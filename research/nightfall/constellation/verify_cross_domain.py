#!/usr/bin/env python3
"""NIGHTFALL / CONSTELLATION: direct Sidon and cubical-square conflict-oracle replay.

Exact finite reductions, standard-library only; this is NOT a solution to #156/#86.
No external proof or originality is asserted by these tests.
"""
from collections import defaultdict
from itertools import combinations, combinations_with_replacement
from pathlib import Path
import hashlib
import json
import random


def sidon_hypergraph(n):
    by_sum = defaultdict(list)
    for a, b in combinations_with_replacement(range(1, n + 1), 2):
        by_sum[a + b].append((a, b))
    supports = set()
    for pairs in by_sum.values():
        for p, q in combinations(pairs, 2):
            supports.add(frozenset(p + q))
    return tuple(sorted((tuple(sorted(s)) for s in supports),
                        key=lambda e: (len(e), e)))


def sidon_direct(chosen):
    occupied = set()
    for a, b in combinations_with_replacement(sorted(chosen), 2):
        if a + b in occupied:
            return False
        occupied.add(a + b)
    return True


def independent(chosen, hyperedges):
    return all(not set(edge).issubset(chosen) for edge in hyperedges)


def maximal_by_hypergraph(chosen, universe, hyperedges):
    if not independent(chosen, hyperedges):
        return False
    return all(any(v in edge and (set(edge) - {v}).issubset(chosen)
                   for edge in hyperedges)
               for v in universe - chosen)


def sidon_maximal_direct(chosen, n):
    return sidon_direct(chosen) and all(
        not sidon_direct(chosen | {v})
        for v in range(1, n + 1) if v not in chosen)


def cube_hypergraph(n):
    edges = [(v, i) for v in range(1 << n)
             for i in range(n) if not (v & (1 << i))]
    index = {edge: j for j, edge in enumerate(edges)}
    squares = []
    for v in range(1 << n):
        for i, j in combinations(range(n), 2):
            if v & ((1 << i) | (1 << j)):
                continue
            squares.append(tuple(sorted((
                index[(v, i)], index[(v, j)],
                index[(v | (1 << i), j)],
                index[(v | (1 << j), i)]))))
    assert len(squares) == len(set(squares))
    return edges, tuple(squares)


def cube_c4_direct(chosen, edges, n):
    adjacent = [set() for _ in range(1 << n)]
    for e in chosen:
        v, i = edges[e]
        w = v ^ (1 << i)
        adjacent[v].add(w)
        adjacent[w].add(v)
    return all(len(adjacent[a] & adjacent[b]) < 2
               for a, b in combinations(range(1 << n), 2))


def cube_maximal_direct(chosen, edges, n):
    if not cube_c4_direct(chosen, edges, n):
        return False
    return all(not cube_c4_direct(chosen | {v}, edges, n)
               for v in range(len(edges)) if v not in chosen)


def replay():
    sidon_checked = 0
    sidon_saturated = 0
    per_n = {}
    n10_examples = []
    for n in range(1, 12):
        forbidden = sidon_hypergraph(n)
        count = 0
        for mask in range(1 << n):
            chosen = {v + 1 for v in range(n) if mask & (1 << v)}
            assert independent(chosen, forbidden) == sidon_direct(chosen)
            direct = sidon_maximal_direct(chosen, n)
            assert maximal_by_hypergraph(
                chosen, set(range(1, n + 1)), forbidden) == direct
            sidon_checked += 1
            count += direct
            if direct and n == 10:
                n10_examples.append(sorted(chosen))
        sidon_saturated += count
        per_n[str(n)] = {"conflict_hyperedges": len(forbidden),
                         "maximal_sets": count}
    assert [4, 6, 7] in n10_examples

    edges3, squares3 = cube_hypergraph(3)
    cube_maximal = 0
    low, high = len(edges3), 0
    for mask in range(1 << len(edges3)):
        chosen = {i for i in range(len(edges3)) if mask & (1 << i)}
        assert independent(chosen, squares3) == cube_c4_direct(
            chosen, edges3, 3)
        direct = cube_maximal_direct(chosen, edges3, 3)
        assert maximal_by_hypergraph(
            chosen, set(range(len(edges3))), squares3) == direct
        if direct:
            cube_maximal += 1
            low, high = min(low, len(chosen)), max(high, len(chosen))

    edges4, squares4 = cube_hypergraph(4)
    edges7, squares7 = cube_hypergraph(7)
    assert (len(edges3), len(squares3)) == (12, 6)
    assert (len(edges4), len(squares4)) == (32, 24)
    assert (len(edges7), len(squares7)) == (448, 672)
    rng = random.Random(1729)
    for _ in range(200):
        chosen = {i for i in range(32) if rng.getrandbits(1)}
        assert independent(chosen, squares4) == cube_c4_direct(
            chosen, edges4, 4)
        assert maximal_by_hypergraph(
            chosen, set(range(32)), squares4) == cube_maximal_direct(
                chosen, edges4, 4)
    assert not independent({1, 2, 3}, sidon_hypergraph(3))
    assert not independent(set(squares3[0]), squares3)
    assert (low, high) == (8, 9)  # maximal and maximum are different

    receipt = {
        "schema": "nightfall-cross-domain-hypergraph-v1",
        "date": "2026-10-29",
        "scientific_status": "Classical hypergraph encoding, exact bounded audit; neither open problem solved",
        "sidon_integer": {
            "N_tested": list(range(1, 12)),
            "subsets_checked": sidon_checked,
            "maximal_sets_checked": sidon_saturated,
            "per_N": per_n,
            "N10_sample": [4, 6, 7]
        },
        "cube": {
            "Q3": {"vertices": 8, "candidate_edges": 12,
                   "coordinate_squares": 6, "subgraphs_checked": 4096,
                   "maximal_subgraphs": cube_maximal,
                   "minimum_maximal_size": low,
                   "maximum_maximal_size": high},
            "Q4": {"candidate_edges": 32, "coordinate_squares": 24,
                   "seeded_checks": 200},
            "Q7": {"candidate_edges": 448, "coordinate_squares": 672,
                   "global_305_status": "undecided"}},
        "limitations": [
            "Hypergraph independence/maximality is classical",
            "N184 nine-mark Sidon SAT/UNSAT remains undecided",
            "Q7 305-edge C4-free existence remains undecided",
            "No transfer of optimal cardinalities between conflict hypergraphs"
        ]
    }
    result = Path(__file__).with_name("EXACT_REPLAY.json")
    encoded = json.dumps(receipt, sort_keys=True, indent=2) + "\n"
    if result.exists():
        assert result.read_text() == encoded, "Frozen receipt drift"
    else:
        result.write_text(encoded)
    print(json.dumps({
        "status": "PASS",
        "sidon_cases": sidon_checked,
        "cube_Q3_cases": 4096,
        "cube_Q4_cases": 200,
        "Q7_edges": 448,
        "Q7_squares": 672,
        "Q3_min_max_maximal": [low, high],
        "receipt_sha256": hashlib.sha256(encoded.encode()).hexdigest()
    }, sort_keys=True))


if __name__ == "__main__":
    replay()
