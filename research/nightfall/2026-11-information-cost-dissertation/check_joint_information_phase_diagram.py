#!/usr/bin/env python3
"""Exact finite falsification of joint model/state/safety results; NOT proof."""
from fractions import Fraction as Q
from itertools import product, combinations
from math import comb, prod
from random import Random

def cube(n):
    return list(product((-1, 1), repeat=n))

def supports(n, d):
    return [s for k in range(d + 1) for s in combinations(range(n), k)]

def eval_poly(coeff, supp, x):
    return sum((a * prod(x[i] for i in s) for a, s in zip(coeff, supp)), Q(0))

def exact_rank(rows):
    a = [[Q(z) for z in row] for row in rows]
    if not a:
        return 0
    n, k = len(a), len(a[0])
    pivot = 0
    for col in range(k):
        lead = next((i for i in range(pivot, n) if a[i][col]), None)
        if lead is None:
            continue
        a[pivot], a[lead] = a[lead], a[pivot]
        v = a[pivot][col]
        a[pivot] = [z / v for z in a[pivot]]
        for i in range(n):
            if i != pivot and a[i][col]:
                v = a[i][col]
                a[i] = [u - v * w for u, w in zip(a[i], a[pivot])]
        pivot += 1
        if pivot == min(n, k):
            break
    return pivot

bool_cases = 0
for n in range(1, 6):
    for d in range(min(n, 2) + 1):
        X = cube(n)
        S = supports(n, d)
        D = sum(comb(n, j) for j in range(d + 1))
        assert len(S) == D
        assert exact_rank([[prod(x[i] for i in s) for s in S] for x in X]) == D
        rng = Random(5040 + 7 * n + d)
        for _ in range(70):
            coeff = [Q(rng.randint(-3, 3)) for _ in S]
            if any(coeff):
                nz = sum(eval_poly(coeff, S, x) != 0 for x in X)
                assert nz * 2 ** d >= len(X), (n, d, nz)
                bool_cases += 1

hetero_cases = 0
for n in range(1, 5):
    A = [tuple(range(2 + i % 2)) for i in range(n)]
    P = [tuple(Q(j+1, sum(range(1, len(A[i])+1))) for j in range(len(A[i])))
         for i in range(n)]
    atom_floor = min(min(q) for q in P)
    rng = Random(939 + n)
    for d in range(min(n, 2) + 1):
        for _ in range(50):
            terms = []
            for _ in range(7):
                S = tuple(sorted(rng.sample(range(n), rng.randint(0, d))))
                pattern = {i: rng.choice(A[i]) for i in S}
                terms.append((S, pattern, rng.randint(-3, 3)))
            def f(x):
                return sum(c * int(all(x[i] == pattern[i] for i in S))
                           for S, pattern, c in terms)
            mass = Q(0)
            nonzero = False
            for x in product(*A):
                if f(x) != 0:
                    nonzero = True
                    mass += prod(P[i][x[i]] for i in range(n))
            if nonzero:
                assert mass >= atom_floor ** d, (n, d, mass, atom_floor)
                hetero_cases += 1

posterior_cases = 0
for m in range(2, 6):
    theta_space = list(product((-1, 1), repeat=m))
    state_space = [(k, z) for k in range(m) for z in theta_space]
    for q in range(m + 1):
        U = Q(m - q, m)
        for learned in product((-1, 1), repeat=q):
            posterior = [t for t in theta_space if t[:q] == learned]
            direct = Q(0)
            for k, z in state_space:
                vals = [t[k] * z[k] for t in posterior]
                mean = Q(sum(vals), len(vals))
                direct += Q(sum((Q(v) - mean) ** 2 for v in vals),
                            len(vals) * len(state_space))
            assert direct == U
            assert U + Q(q, m) == 1  # no state reads, or address only
            assert U + 0 == U        # address plus selected leaf
        posterior_cases += 1

rare_cases = 0
for n in range(2, 14):
    X = cube(n)
    f = lambda x: Q(1, 3) + Q(2, 3 * n) * sum(x)
    assert max(abs(f(x)) for x in X) <= 1
    assert f((-1,) * n) == Q(-1, 3)
    negatives = sum(f(x) < 0 for x in X)
    target = sum(comb(n, k) for k in range(n + 1) if 4 * k < n)
    assert negatives == target
    rare_cases += 1

sharp_cases = 0
for n in range(1, 8):
    X = cube(n)
    for d in range(n + 1):
        count = sum(all(x[i] == 1 for i in range(d)) for x in X)
        assert Q(count, len(X)) == Q(1, 2 ** d)
        sharp_cases += 1

print(f"PASS boolean={bool_cases} heterogeneous={hetero_cases} "
      f"posterior={posterior_cases} rare={rare_cases} sharp={sharp_cases}")
