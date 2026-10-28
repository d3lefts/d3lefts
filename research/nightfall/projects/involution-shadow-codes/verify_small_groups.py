#!/usr/bin/env python3
"""Independent exhaustive small-group audit of the involution shadow-code formula.

This enumerates the observation code directly, rather than relying on the
algebraic collision-class proof to compute its distance.
Research program: Devin J. Wright / NIGHTFALL PHASESHIFT
Additional verification date: 2026-10-28.
"""
from itertools import product
from random import Random

def distance(code, a, b):
    return sum(x != y for x, y in zip(code[a], code[b]))

def audit_sign(rng):
    checked = 0
    for n in range(3, 16):
        for m in range(2, 7):
            for _ in range(45):
                t = [rng.randrange(n) for _ in range(m)]
                tags = [(2 * v) % n for v in t]
                expected = m - max(tags.count(c) for c in set(tags))
                code = {x: tuple(min((x+v) % n, (-(x+v)) % n) for v in t)
                        for x in range(n)}
                actual = min(distance(code, x, y)
                             for x in range(n) for y in range(x+1, n))
                assert actual == expected, (n, m, t, actual, expected)
                checked += 1
    return checked

def audit_swaps(rng):
    checked = 0
    for n in range(2, 6):
        A = list(product(range(n), repeat=2))
        plus = lambda a,b: ((a[0]+b[0])%n, (a[1]+b[1])%n)
        swap = lambda a: (a[1], a[0])
        shadow = lambda a: min(a, swap(a))
        tag = lambda a: ((a[1]-a[0])%n, (a[0]-a[1])%n)
        for _ in range(100):
            shifts = [rng.choice(A) for _ in range(4)]
            tags = [tag(t) for t in shifts]
            expected = 4-max(tags.count(c) for c in set(tags))
            code = {x: tuple(shadow(plus(x, t)) for t in shifts)
                    for x in A}
            actual = min(distance(code, x, y)
                         for j, x in enumerate(A) for y in A[j+1:])
            assert actual == expected, (n, shifts, actual, expected)
            checked += 1
    return checked

if __name__ == "__main__":
    rng=Random(20261028)
    sign=audit_sign(rng)
    swaps=audit_swaps(rng)
    print(f"PASS: {sign} sign-shift cases; {swaps} coordinate-swap cases; {sign+swaps} total.")
