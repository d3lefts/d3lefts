#!/usr/bin/env python3
"""Independent original-world tests of the quadratic observation-unlock identity.

For degree-two f and independent coordinates, the gain from reading j after
an already-read k rather than before it differs by the true source pair energy
w_{j,k}. Hence a marginal change at k leaves every candidate's *expected*
incremental observation gain unchanged for all j not adjacent to k.

The test does NOT trust an ANOVA decomposition to compute its first side:
conditional means are calculated by exhaustive rational original-world sums.
"""
from fractions import Fraction as Q
from itertools import product
from math import prod

COORDS = (-1, 1)
EDGES = {(0, 1): Q(3), (1, 2): Q(2), (2, 3): Q(-2)}
SINGLETONS = (Q(2), Q(-1), Q(1), Q(0))


def mass(world, laws):
    return prod((laws[i][v] for i, v in enumerate(world)), start=Q(1))


def conditional(f, S, x, laws):
    n = len(laws)
    fixed = prod((laws[i][x[i]] for i in S), start=Q(1))
    if fixed == 0:
        return Q(0)
    return sum((f(y) * mass(y, laws) / fixed for y in product(COORDS, repeat=n)
                if all(y[i] == x[i] for i in S)), Q(0))


def explained(f, S, laws):
    worlds = tuple(product(COORDS, repeat=len(laws)))
    mean = sum((f(x) * mass(x, laws) for x in worlds), Q(0))
    return sum((mass(x, laws) * (conditional(f, S, x, laws) - mean)**2
                for x in worlds if mass(x, laws)), Q(0))


def gain(f, S, j, laws):
    return explained(f, S | {j}, laws) - explained(f, S, laws)


def run():
    n = 4
    f = lambda x: sum((SINGLETONS[i] * x[i] for i in range(n)), Q(0)) + sum(
        (v * x[i] * x[j] for (i, j), v in EDGES.items()), Q(0))
    cases = 0
    laws0 = [{-1: Q(1, 2), 1: Q(1, 2)} for _ in range(n)]
    baseline = {}
    for j in (2, 3):
        for S in (set(), {1}, {2}, {3}, {1, 3}, {1, 2}):
            if j in S:
                continue
            baseline[j, tuple(sorted(S))] = gain(f, S, j, laws0)
    for p in (Q(0), Q(1, 4), Q(1, 2), Q(3, 4), Q(1)):
        laws = [dict(x) for x in laws0]
        laws[0] = {-1: 1 - p, 1: p}
        for j in (1, 2, 3):
            for S in (set(), {1}, {2}, {3}, {1, 3}, {1, 2}):
                if j in S or 0 in S:
                    continue
                unlocked = gain(f, S | {0}, j, laws) - gain(f, S, j, laws)
                pair = EDGES.get((0, j), Q(0))
                expected = pair * pair * (1 - (2 * p - 1)**2)
                assert unlocked == expected, (p, j, S, unlocked, expected)
                cases += 1
                if j in (2, 3):
                    assert gain(f, S, j, laws) == baseline[j, tuple(sorted(S))]
    # Dropping degree-two invalidates the graph-locality implication:
    # a pure cubic with no 0-2 pair term has source-law dependent gain at j=2.
    triple = lambda x: Q(x[0] * x[2] * x[3])
    fair = laws0
    shifted = [dict(z) for z in fair]
    shifted[0] = {-1: Q(0), 1: Q(1)}
    cub_before = gain(triple, {3}, 2, fair)
    cub_after = gain(triple, {3}, 2, shifted)
    assert cub_before == 0 and cub_after == 1
    print("PASS: original-world quadratic unlock/locality", cases,
          "exact expected gain checks, zero-mass marginals included;"
          " cubic counterexample 0 -> 1")


if __name__ == "__main__":
    run()
