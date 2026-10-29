#!/usr/bin/env python3
"""NIGHTFALL independent exact Q7 local-obstruction audit, 2026-10-29.

Reads a 448-bit edge-mask transcription of the public 304-edge Minamoto witness.
Enumerates all coordinate squares and every deletion cover of size <=4.
Standard library only; the source witness is not a NIGHTFALL construction.
"""
from collections import Counter, defaultdict
from itertools import product
import hashlib
import json

MASK = "eceb7e3f7e576f69d6bf5f7c5f69fb63f7799773ccb4f776bbb6ed379fcd76b7be2eee1ddd3ebf39e1ddf397d99f6bf7bcdfa65fdcd7d3fc"
bits = [int(b) for b in bin(int(MASK, 16))[2:].zfill(448)]
edge_coordinates = [(v, d) for v in range(128) for d in range(7) if v & (1 << d) == 0]
assert len(edge_coordinates) == 448
index = {e: i for i, e in enumerate(edge_coordinates)}
selected = {i for i, b in enumerate(bits) if b}
missing = [i for i in range(448) if i not in selected]
assert len(selected) == 304 and len(missing) == 144

def square(edge, second_axis):
    vertex, first_axis = edge_coordinates[edge]
    assert first_axis != second_axis
    base = vertex & ~(1 << second_axis)
    pairs = ((base, first_axis), (base, second_axis),
             (base | (1 << second_axis), first_axis),
             (base | (1 << first_axis), second_axis))
    return frozenset(index[(u & ~(1 << axis), axis)] for u, axis in pairs)

all_squares = {square(edge, other_axis)
               for edge in range(448) for other_axis in range(7)
               if other_axis != edge_coordinates[edge][1]}
assert len(all_squares) == 672
assert all(len(sq & selected) <= 3 for sq in all_squares)
occupancy = Counter(len(sq & selected) for sq in all_squares)

# Every square with exactly three selected edges imposes a necessary deletion
# for its fourth edge to become insertable. Tight squares around one missing
# edge have pairwise disjoint sets of three selected edges.
requirements = {}
for missing_edge in missing:
    axis = edge_coordinates[missing_edge][1]
    requirements[missing_edge] = [
        square(missing_edge, other_axis) - {missing_edge}
        for other_axis in range(7) if other_axis != axis
        and len(square(missing_edge, other_axis) & selected) == 3
    ]
distribution = Counter(map(len, requirements.values()))
assert distribution == {3: 60, 4: 84}, distribution

# Exhaustively generate all four-element deletion sets capable of unlocking
# any originally absent edge. A tight-3 edge needs 3 hits + arbitrary fourth;
# a tight-4 edge needs exactly 4 hits. This covers all possibilities.
unlocked = defaultdict(int)
for k, absent in enumerate(missing):
    groups = requirements[absent]
    if len(groups) == 3:
        for a, b, c in product(*groups):
            core = (1 << a) | (1 << b) | (1 << c)
            assert core.bit_count() == 3
            for extra in selected:
                if extra not in (a, b, c):
                    unlocked[core | (1 << extra)] |= (1 << k)
    elif len(groups) == 4:
        for choices in product(*groups):
            key = 0
            for edge in choices:
                key |= (1 << edge)
            assert key.bit_count() == 4
            unlocked[key] |= (1 << k)
    else:
        raise AssertionError("unexpected number of tight squares")

counts = Counter(mask.bit_count() for mask in unlocked.values())
assert len(unlocked) == 475234, len(unlocked)
assert counts == {1: 464579, 2: 6980, 3: 3675}, counts
assert max(counts) == 3

# With r original edges deleted, an improved graph needs >=r+1 old nonedges
# inserted. Every old nonedge insertable after <=4 deletions is counted above.
# Monotonicity of individually insertable edges covers r<4 as well.
proof = {
    "source": "minamominamoto/c4free-hypercube/selected_edges_best.json",
    "result": "PASS",
    "edges": 448, "four_cycles": len(all_squares),
    "source_witness_edges": len(selected),
    "square_occupancy": dict(sorted(occupancy.items())),
    "tight_square_distribution_missing_edges": dict(sorted(distribution.items())),
    "nonempty_four_deletion_sets": len(unlocked),
    "four_deletion_unlock_histogram": dict(sorted(counts.items())),
    "max_insertable_after_four_deletions": max(counts),
    "deduction": "Any C4-free Q7 graph with >=305 edges differs from this 304-edge witness in at least 11 edge coordinates."
}
print(json.dumps(proof, indent=2))
