#!/usr/bin/env python3
"""Independent GF(9) regression for NIGHTFALL's dimension-uniform gap theorem.

Exact model: K = F3[t]/(t^2+1), H = {+1,-1}, oracle (a.x)^2.
This finite test checks k=3; the all-k theorem is proved algebraically in THEOREM.md.
No external packages, no floating point, no claim of historical novelty.
"""
from collections import Counter
from itertools import product


def plus(a, b):
    return (a % 3 + b % 3) % 3 + 3 * ((a // 3 + b // 3) % 3)


def mul(a, b):
    a0, a1 = a % 3, a // 3
    b0, b1 = b % 3, b // 3
    return (a0 * b0 + 2 * a1 * b1) % 3 + 3 * ((a0 * b1 + a1 * b0) % 3)


def square(a):
    return mul(a, a)


def negate(a):
    return mul(2, a)


def total(items):
    result = 0
    for a in items:
        result = plus(result, a)
    return result


def inner(row, x):
    return total(mul(a, b) for a, b in zip(row, x, strict=True))


ROOTS = {y: min(a for a in range(9) if square(a) == y)
         for y in {square(a) for a in range(9)}}
INVERSES = {a: next(b for b in range(1, 9) if mul(a, b) == 1)
            for a in range(1, 9)}
H = (1, 2)
BASIS = (1, 3)
assert len(ROOTS) == 5
assert set(a for a in range(9) if square(a) == 1) == set(H)
assert all(mul(a, INVERSES[a]) == 1 for a in range(1, 9))


def recover(x):
    k = len(x)
    readings = [square(a) for a in x]
    support = [i for i, y in enumerate(readings) if y != 0]
    if not support:
        return (0,) * k, k

    representatives = {i: ROOTS[readings[i]] for i in support}
    anchor = support[0]
    result = [0] * k
    result[anchor] = representatives[anchor]
    queries = k

    for start in range(0, len(support) - 1, 2):
        block = support[1 + start: 1 + start + 2]
        row = [0] * k
        row[anchor] = mul(
            total(BASIS[:len(block)]), INVERSES[representatives[anchor]]
        )
        for i, beta in zip(block, BASIS[:len(block)], strict=True):
            row[i] = mul(beta, INVERSES[representatives[i]])

        # Only legal powered observation is used to select the relative phases.
        observation = square(inner(row, x))
        inverse_code = {}
        for phases in product(H, repeat=len(block)):
            unpowered = total(
                mul(beta, (1 + phase) % 3)
                for beta, phase in zip(BASIS[:len(block)], phases, strict=True)
            )
            reading = square(unpowered)
            assert reading not in inverse_code
            inverse_code[reading] = phases
        assert len(inverse_code) == 2 ** len(block)
        for i, phase in zip(block, inverse_code[observation], strict=True):
            result[i] = mul(phase, representatives[i])
        queries += 1

    assert queries == k + (len(support) - 1 + 1) // 2
    assert any(tuple(mul(h, z) for z in result) == x for h in H)
    return tuple(result), queries


def audit():
    histogram = Counter()
    for x in product(range(9), repeat=3):
        _, queries = recover(x)
        histogram[queries] += 1
    assert histogram == {3: 25, 4: 704}
    assert sum(histogram.values()) == 9 ** 3

    # Concrete complement-property negative control with four fixed queries.
    matrix = ((1, 0, 0), (0, 1, 0), (0, 0, 1), (1, 1, 1))
    x = (1, 2, 1)
    y = (2, 1, 1)
    assert x != y and x != tuple(negate(a) for a in y)
    assert tuple(square(inner(row, x)) for row in matrix) == (1, 1, 1, 1)
    assert tuple(square(inner(row, y)) for row in matrix) == (1, 1, 1, 1)

    # Small independent exhaustive check of the general fixed-design obstruction.
    representatives = sorted({
        min(z, tuple(negate(a) for a in z))
        for z in product(range(9), repeat=2)
    })
    assert len(representatives) == (9 ** 2 + 1) // 2 == 41
    best = 0
    for coeff in product(range(9), repeat=4):
        rows = (coeff[:2], coeff[2:])
        unique_outputs = len({
            tuple(square(inner(row, z)) for row in rows)
            for z in representatives
        })
        best = max(best, unique_outputs)
    assert best == 25 < 41

    assert 5 ** 3 < (9 ** 3 + 1) // 2 <= 5 ** 4
    print("PASS: exhaustive 729 GF9^3 signals; query histogram {3:25, 4:704}")
    print("PASS: fixed four-query ambiguous pair, oracle outputs (1,1,1,1)")
    print("PASS: all 6561 fixed 2x2 GF9 designs; most distinguish 25/41 classes")
    print("PASS: information bound needs at least four adaptive queries at k=3")
    print("STATUS: exact finite regression only; all-k proof is separate")


if __name__ == "__main__":
    audit()
