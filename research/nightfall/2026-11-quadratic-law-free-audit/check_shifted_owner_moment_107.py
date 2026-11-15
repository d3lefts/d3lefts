#!/usr/bin/env python3
"""Exact rational positivity audit for a shifted Hilbert fourth-moment inequality.

For x,t in [0,1], certify
  P(x,t)=3-(1-t)^2*[3-2*x^4+16*t*x*(1-x^2)+16*t^2*(1-x^2)] >= 0.

Bernstein coefficients are convex-hull bounds on rectangles; all fractions
and subdivisions are exact. This does NOT certify the Hilbert/source
moment lemmas in Lean, nor any novelty or world-priority claim.
"""
from fractions import Fraction as Q
from math import comb


def multiply(left, right):
    out = {}
    for (i, j), a in left.items():
        for (k, l), b in right.items():
            key = (i+k, j+l)
            out[key] = out.get(key, Q(0)) + a*b
    return {key: val for key, val in out.items() if val}


f = {
    (0, 0): Q(3), (4, 0): Q(-2),
    (1, 1): Q(16), (3, 1): Q(-16),
    (0, 2): Q(16), (2, 2): Q(-16),
}
weight = {(0, 0): Q(1), (0, 1): Q(-2), (0, 2): Q(1)}
p = {(0, 0): Q(3)}
for key, value in multiply(weight, f).items():
    p[key] = p.get(key, Q(0)) - value
p = {key: value for key, value in p.items() if value}
assert max(i for i, _ in p) == 4
assert max(j for _, j in p) == 4


def bernstein_from_power(coefficients):
    result = []
    for i in range(5):
        row = []
        for j in range(5):
            row.append(sum((
                value * Q(comb(i, k), comb(4, k)) *
                Q(comb(j, l), comb(4, l))
                for (k, l), value in coefficients.items()
                if k <= i and l <= j
            ), Q(0)))
        result.append(tuple(row))
    return tuple(result)


def split_one(row):
    pyramid = [list(row)]
    while len(pyramid[-1]) > 1:
        old = pyramid[-1]
        pyramid.append([(old[i] + old[i+1])/2
                        for i in range(len(old)-1)])
    return (tuple(v[0] for v in pyramid),
            tuple(pyramid[-i-1][i] for i in range(len(row))))


def split(matrix, axis):
    if axis == 0:
        columns = [
            split_one(tuple(matrix[i][j] for i in range(5)))
            for j in range(5)
        ]
        return (
            tuple(tuple(columns[j][0][i] for j in range(5))
                  for i in range(5)),
            tuple(tuple(columns[j][1][i] for j in range(5))
                  for i in range(5)),
        )
    pairs = [split_one(row) for row in matrix]
    return tuple(v[0] for v in pairs), tuple(v[1] for v in pairs)


def evaluate(x, t):
    return sum((value*x**i*t**j for (i, j), value in p.items()), Q(0))


basis = bernstein_from_power(p)
assert basis[0][0] == evaluate(Q(0), Q(0))
assert basis[4][4] == evaluate(Q(1), Q(1))
stack = [(basis, 0, Q(0), Q(1), Q(0), Q(1))]
leaves = []
nodes = 0
while stack:
    b, depth, xlo, xhi, tlo, thi = stack.pop()
    nodes += 1
    lower = min(value for row in b for value in row)
    if lower >= 0:
        # Cross-check all four corners against the expanded polynomial.
        assert b[0][0] == evaluate(xlo, tlo)
        assert b[4][0] == evaluate(xhi, tlo)
        assert b[0][4] == evaluate(xlo, thi)
        assert b[4][4] == evaluate(xhi, thi)
        leaves.append((xlo, xhi, tlo, thi, lower))
        continue
    assert depth < 24, ("unresolved rational box", xlo, xhi, tlo, thi)
    lo, hi = split(b, depth % 2)
    if depth % 2 == 0:
        mid = (xlo+xhi)/2
        stack.extend(((lo, depth+1, xlo, mid, tlo, thi),
                      (hi, depth+1, mid, xhi, tlo, thi)))
    else:
        mid = (tlo+thi)/2
        stack.extend(((lo, depth+1, xlo, xhi, tlo, mid),
                      (hi, depth+1, xlo, xhi, mid, thi)))

expected = [
    (Q(0), Q(1, 4), Q(0), Q(1, 2), Q(0)),
    (Q(0), Q(1, 2), Q(1, 2), Q(1), Q(11, 16)),
    (Q(1, 4), Q(1, 2), Q(0), Q(1, 4), Q(1, 128)),
    (Q(1, 4), Q(1, 2), Q(1, 4), Q(1, 2), Q(21, 256)),
    (Q(1, 2), Q(3, 4), Q(0), Q(1, 4), Q(15, 256)),
    (Q(1, 2), Q(3, 4), Q(1, 4), Q(1, 2), Q(15, 128)),
    (Q(1, 2), Q(1), Q(1, 2), Q(1), Q(25, 32)),
    (Q(3, 4), Q(1), Q(0), Q(1, 2), Q(1693, 3072)),
]
assert nodes == 15 and len(leaves) == 8
assert sorted(leaves) == sorted(expected), (sorted(leaves), sorted(expected))
print("PASS exact shifted moment c/4 interpolation: 15 Bernstein nodes, 8 rational boxes")
for xlo, xhi, tlo, thi, minimum in sorted(leaves):
    print(f"x=[{xlo},{xhi}] t=[{tlo},{thi}] min={minimum}")
print("SCOPE: exact polynomial only; source-to-Hilbert and terminal Lean gates remain open")
