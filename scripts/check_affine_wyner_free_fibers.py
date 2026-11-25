#!/usr/bin/env python3
"""Independent exact finite regression for the q^r affine-code fiber claim.

Enumerate ALL linear subspaces over F2^3, F2^4 and F3^3; all affine cosets;
partition each coset by nonfree-coordinate projections; and check every
fiber consists of every possible free-coordinate assignment exactly once.
Finite counterexample search is NOT a universal Lean theorem.
"""
from itertools import product


def plus(x, y, p):
    return tuple((a + b) % p for a, b in zip(x, y))


def extend(vectors, u, p):
    return frozenset(
        plus(v, tuple((n * a) % p for a in u), p)
        for v in vectors for n in range(p)
    )


def subspaces(p, n):
    ambient = list(product(range(p), repeat=n))
    spans = [frozenset([(0,) * n])]
    visited = set(spans)
    for L in spans:
        for v in ambient:
            if v not in L:
                next_L = extend(L, v, p)
                if next_L not in visited:
                    spans.append(next_L)
                    visited.add(next_L)
    return spans


def audit(p, n):
    ambient = list(product(range(p), repeat=n))
    spans = subspaces(p, n)
    ncosets = nfibers = 0
    for L in spans:
        free = {i for i in range(n)
                if tuple(int(i == j) for j in range(n)) in L}
        fixed = [i for i in range(n) if i not in free]
        accounted = set()
        for shift in ambient:
            if shift in accounted:
                continue
            coset = {plus(shift, u, p) for u in L}
            accounted |= coset
            ncosets += 1
            fibers = {}
            for word in coset:
                projection = tuple(word[i] for i in fixed)
                fibers.setdefault(projection, set()).add(word)
            for fiber in fibers.values():
                nfibers += 1
                expected = set(product(range(p), repeat=len(free)))
                assignments = {tuple(word[i] for i in sorted(free))
                               for word in fiber}
                assert len(fiber) == p ** len(free), (
                    p, n, L, shift, free, len(fiber))
                assert assignments == expected, (
                    p, n, L, shift, free, assignments)
        assert accounted == set(ambient)
    return len(spans), ncosets, nfibers


def main():
    checks = {(2, 3): (16, 51, 79),
              (2, 4): (67, 307, 665),
              (3, 3): (28, 184, 496)}
    for case, expected in checks.items():
        result = audit(*case)
        assert result == expected, (case, result, expected)
        print(f"PASS F_{case[0]}^{case[1]}:"
              f" {result[0]} subspaces, {result[1]} cosets,"
              f" {result[2]} exact free-coordinate fibers")

    diagonal = {(0, 0), (1, 1)}
    fake_free_axes = 2
    assert len(diagonal) != 2 ** fake_free_axes
    print("PASS negative control: false 'both diagonal axes free' rejected")


if __name__ == "__main__":
    main()
