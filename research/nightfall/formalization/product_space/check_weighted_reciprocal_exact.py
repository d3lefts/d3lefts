#!/usr/bin/env python3
"""Independent exact-rational finite checks of the weighted reciprocal theorem.

This is a finite counterexample checker, not a proof. It does not call Lean.
All Boolean functions are tested in four small product configurations;
all certificate rows have entries >= 1 and hence satisfy the row condition.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random


def check_case(n, alphabet, probs, weights, values, rows):
    points = list(product(range(alphabet), repeat=n))
    mass = {}
    for x in points:
        m = Q(1)
        for j in range(n):
            m *= probs[j][x[j]]
        mass[x] = m

    lhs = Q(0)
    boundary = [Q(0) for _ in range(n)]
    for x in points:
        for y in points:
            joint = mass[x] * mass[y]
            if values[x] and not values[y]:
                denom = sum(
                    (weights[j] * rows[x][j] * rows[y][j]
                     for j in range(n) if x[j] != y[j]), Q(0))
                assert denom > 0
                lhs += joint / denom
            for j in range(n):
                replaced = x[:j] + (y[j],) + x[j + 1:]
                if values[x] and not values[replaced]:
                    boundary[j] += joint
    rhs = sum((boundary[j] / weights[j] for j in range(n)), Q(0))
    assert lhs <= rhs, (
        f"counterexample: n={n}, alphabet={alphabet}, lhs={lhs}, rhs={rhs}")
    return lhs, rhs


def main():
    rng = Random(295)
    checked = 0
    equalities = 0
    for n, alphabet in ((1, 2), (2, 2), (3, 2), (2, 3)):
        points = list(product(range(alphabet), repeat=n))
        assert len(points) <= 9
        for support_case in (0, 1):
            probs = []
            for j in range(n):
                raw = [Q(1 + 2 * a + j) for a in range(alphabet)]
                if support_case:
                    raw[-1] = Q(0)
                scale = sum(raw, Q(0))
                probs.append([v / scale for v in raw])
            for mask in range(1 << len(points)):
                values = {x: bool(mask & (1 << k)) for k, x in enumerate(points)}
                for row_case in (0, 1):
                    rows = {
                        x: tuple(Q(1) if not row_case
                                 else Q(1 + rng.randrange(1, 6))
                                 for _ in range(n))
                        for x in points
                    }
                    weights = tuple(
                        Q(1 + rng.randrange(1, 6), 1 + rng.randrange(1, 6))
                        for _ in range(n))
                    lhs, rhs = check_case(n, alphabet, probs, weights, values, rows)
                    checked += 1
                    equalities += (lhs == rhs)
    assert checked == 3152
    print(f"PASS: {checked} exact rational cases; {equalities} equalities; "
          "all Boolean functions for sizes 2, 4, 8, and 9.")


if __name__ == "__main__":
    main()
