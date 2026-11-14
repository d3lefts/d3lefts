#!/usr/bin/env python3
"""Exact-rational regression checker for source-section energy = resampling influence.

Checks a deterministic finite family of original-product laws and arbitrary
real tables. All arithmetic uses Fraction; there are no tolerances, floats,
or synthetic independent-neighbor distributions.

This finite regression test is NOT a proof of the universal identity and
is NOT a substitute for the pinned Lean theorem/axiom receipt.
"""
from fractions import Fraction as Q
from itertools import product
from math import prod


def check(n, m, law, values):
    states = list(product(range(m), repeat=n))

    def mass(x):
        return prod((law[i][x[i]] for i in range(n)), start=Q(1))

    for i in range(n):
        energy, influence = Q(0), Q(0)
        for x in states:
            px = mass(x)
            fvals = [
                values[x[:i] + (a,) + x[i + 1 :]]
                for a in range(m)
            ]
            avg = sum((law[i][a] * fvals[a] for a in range(m)), Q(0))
            energy += px * sum(
                (law[i][a] * (fvals[a] - avg) ** 2 for a in range(m)), Q(0)
            )
            influence += px * sum(
                (law[i][a] * (values[x] - fvals[a]) ** 2 / 2 for a in range(m)),
                Q(0),
            )
        assert energy == influence, (n, m, i, law, energy, influence)


def main():
    tests = 0
    for n in (1, 2, 3, 4):
        for m in (2, 3):
            laws = [
                [[Q(1, m)] * m for _ in range(n)],
                [[Q(1) if a == i % m else Q(0) for a in range(m)]
                 for i in range(n)],
                [[Q(a + 1, m * (m + 1) // 2) for a in range(m)]
                 for _ in range(n)],
                [[Q(0)] * (m - 1) + [Q(1)] for _ in range(n)],
            ]
            states = list(product(range(m), repeat=n))
            for seed in range(15):
                f = {
                    x: Q((sum((t + 2) * (k + 1)
                                  for k, t in enumerate(x))
                          + 7 * seed
                          + 3 * prod(t + 1 for t in x)) % 13 - 6, 3)
                    for x in states
                }
                for law in laws:
                    check(n, m, law, f)
                    tests += 1
    assert tests == 480
    print("PASS: 480 exact original-law source energy/influence checks")


if __name__ == "__main__":
    main()
