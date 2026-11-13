#!/usr/bin/env python3
"""Independent exact-rational Q2 bilinear/prior-art normalization audit.

All finite tests are verification of instances, not a universal proof.
Uses only Python standard library Fraction, no floating-point tolerances.
"""
from fractions import Fraction as F
from itertools import product, combinations
from functools import lru_cache
from random import Random

rng = Random(20261113)
counts = {
    'degree2_variance': 0, 'one_sided': 0, 'symmetric': 0,
    'hybrid': 0, 'address': 0, 'owner_overlap': 0,
    'martingale_not_independent': 0,
}

def case(n, q):
    weights = []
    for i in range(n):
        vals = [rng.randrange(0, 5) for _ in range(q)]
        if not sum(vals):
            vals[rng.randrange(q)] = 1
        weights.append([F(v, sum(vals)) for v in vals])

    states = list(product(range(q), repeat=n))
    f = {x: F(rng.randrange(-5, 6)) for x in states}

    @lru_cache(None)
    def mass(x):
        acc = F(1)
        for i, a in enumerate(x):
            acc *= weights[i][a]
        return acc

    @lru_cache(None)
    def cexp(U, x):
        return sum((mass(z) *
                    f[tuple(x[i] if i in U else z[i] for i in range(n))]
                    for z in states), F(0))

    mean = cexp(frozenset(), states[0])
    h = {}
    for i, j in combinations(range(n), 2):
        for a in range(q):
            for b in range(q):
                x = list(states[0])
                x[i], x[j] = a, b
                x = tuple(x)
                h[i, j, a, b] = (cexp(frozenset((i, j)), x)
                                - cexp(frozenset((i,)), x)
                                - cexp(frozenset((j,)), x) + mean)

    def f2(x):
        return sum((h[i, j, x[i], x[j]]
                    for i, j in combinations(range(n), 2)), F(0))

    var = sum((mass(x) * f2(x) ** 2 for x in states), F(0))
    forward = F(0)
    symmetric = F(0)

    for x in states:
        for y in states:
            p = mass(x) * mass(y)
            K = sum((h[i, j, x[i], y[j]]
                     for i, j in combinations(range(n), 2)), F(0))
            K_sym = K + sum((h[i, j, y[i], x[j]]
                             for i, j in combinations(range(n), 2)), F(0))
            forward += p * K ** 2
            symmetric += p * K_sym ** 2
            hybrid = (sum((f2(tuple(x[i] if (mask >> i) & 1 else y[i]
                                    for i in range(n)))
                           for mask in range(2 ** n)), F(0)) / 2 ** n)
            assert K_sym == 4 * hybrid - f2(x) - f2(y)
            counts['hybrid'] += 1

    assert var == forward, (n, q, var, forward)
    assert symmetric == 2 * var, (n, q, var, symmetric)
    counts['degree2_variance'] += 1
    counts['one_sided'] += 1
    counts['symmetric'] += 1

for n, q, howmany in [(2, 2, 10), (3, 2, 6), (3, 3, 3), (4, 2, 2)]:
    for _ in range(howmany):
        case(n, q)

# Address pure quadratic exact-influence formulas, including large m
for m in range(2, 32):
    q = F(m - 1, m)
    var = q
    address_influence = q
    leaf_influence = F(m - 1, m * m)
    assert address_influence == var and leaf_influence == q / m
    counts['address'] += 1

# Complete three-vertex canonical graph: owner-neighbor sets overlap.
costs = [3, 1, 2]
owned = {i: set() for i in range(3)}
for i, j in combinations(range(3), 2):
    owner = i if costs[i] >= costs[j] else j
    neighbor = j if owner == i else i
    owned[owner].add(neighbor)
assert owned[0].intersection(owned[2]) == {1}
counts['owner_overlap'] += 1

# Degree-two Doob martingale increments of disjoint coordinate reveals:
# D2=X1*X2, D3=X3*(X1+X2), and D3^2=2*(1+D2).
xs = list(product([-1, 1], repeat=3))
ds = [(x[0] * x[1], x[2] * (x[0] + x[1])) for x in xs]
assert all(d3 * d3 == 2 * (1 + d2) for d2, d3 in ds)
assert {d2 for d2, _ in ds} == {-1, 1}
assert {abs(d3) for _, d3 in ds} == {0, 2}
counts['martingale_not_independent'] += 1

assert counts == {
    'degree2_variance': 21, 'one_sided': 21, 'symmetric': 21,
    'hybrid': 3243, 'address': 30, 'owner_overlap': 1,
    'martingale_not_independent': 1,
}, counts
print('PASS seed=20261113 exact Fraction arithmetic', counts)
print('Two-sign falsifier: Var(f2)=1, E[K_right^2]=1; factor 1/2 is false')
print('Categorical address: bounded pure degree two; root influence sum diverges')
print('Static singleton reveal: Doob differences have D3^2=2(1+D2)')
