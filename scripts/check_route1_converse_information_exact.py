#!/usr/bin/env python3
"""NIGHTFALL independent finite checker for the Route1 converse information note.

This checks finite exact identities and selected numerical inequalities, not the
general Shannon/Pinsker theorem or the Gaussian arcsine formula. No dependencies.
Seed and all loops fixed. Author-side checks, not an independent human referee.
"""
from fractions import Fraction as F
from itertools import combinations, permutations, product
from math import asin, factorial, log, pi, sqrt, prod
from random import Random

SEED = 20261121
rng = Random(SEED)
counts = dict(support=0, coupling=0, bessel=0, parseval=0,
              mutual_info=0, simon=0, bv=0, hadamard=0)
def bits(m):
    return tuple(tuple(1 if (z >> i) & 1 else -1 for i in range(m))
                 for z in range(1 << m))
def has_edge(s):
    return any(sum(a[i] != b[i] for i in range(len(a))) == 1
               for a, b in combinations(s, 2))
def has_product_box(s, m):
    # Every independent coordinate support is a product of nonempty choices.
    # For binary alphabets, choices are {-1}, {+1}, {-1,+1}.
    for choices in product(((-1,), (1,), (-1, 1)), repeat=m):
        if all(len(ch) == 1 for ch in choices):
            continue
        if all(v in s for v in product(*choices)):
            return True
    return False

# Exhaustively check rectangle/edge equivalence through 3 queried bits.
for m in range(1, 4):
    allv = bits(m)
    for mask in range(1, 1 << len(allv)):
        s = frozenset(allv[i] for i in range(len(allv)) if (mask >> i) & 1)
        assert has_edge(s) == has_product_box(s, m), (m, mask)
        counts["support"] += 1

# Exact rational Bessel + independent Walsh-Parseval checker of every column.
for m in range(1, 5):
    v = bits(m)
    M = len(v)
    repetitions = 60 if m < 4 else 22
    for trial in range(repetitions):
        k = 1 + rng.randrange(1, 8)
        maps = []
        weights = [1 + rng.randrange(1, 7) for _ in range(k)]
        for _ in range(k):
            perm = list(range(M))
            rng.shuffle(perm)
            maps.append(tuple(perm))
        total = sum(weights)
        P = [[F(0) for _ in range(M)] for _ in range(M)]
        for w, pm in zip(weights, maps):
            for x in range(M):
                P[x][pm[x]] += F(w, M * total)
        assert all(sum(row) == F(1, M) for row in P)
        assert all(sum(P[x][y] for x in range(M)) == F(1, M)
                   for y in range(M))
        counts["coupling"] += 1
        cors = [[sum(P[x][y] * v[x][i] * v[y][j]
                     for x in range(M) for y in range(M))
                 for j in range(m)] for i in range(m)]
        mi = 0.0
        for x in range(M):
            for y in range(M):
                if P[x][y] > 0:
                    z = float(P[x][y])
                    mi += z * log(z * M * M)
        frob = sum(c * c for row in cors for c in row)
        assert mi + 2e-11 >= 0.5 * float(frob), (m, trial, mi, frob)
        counts["mutual_info"] += 1
        for j in range(m):
            cm = [sum(P[x][y] * M * v[y][j] for y in range(M))
                  for x in range(M)]
            q = sum(z * z for z in cm) / M
            b = sum(cors[i][j] ** 2 for i in range(m))
            assert q >= b, (m, trial, j, q, b)
            counts["bessel"] += 1
            # Parseval: independently compute all 2^m Walsh coefficients.
            coeffs = []
            for mask in range(M):
                z = sum(cm[x] * prod(v[x][i] for i in range(m)
                                      if (mask >> i) & 1)
                        for x in range(M)) / M
                coeffs.append(z)
            assert sum(z * z for z in coeffs) == q
            for i in range(m):
                assert coeffs[1 << i] == cors[i][j]
            counts["parseval"] += 1

# Exact support geometry for BV parity truth tables, including m=1 exception.
for m in range(1, 5):
    domain = range(1 << m)
    support = []
    for secret in domain:
        truth = tuple((secret & inp).bit_count() & 1 for inp in domain)
        support.append(truth)
    edge = has_edge(support)
    assert edge == (m == 1), (m, edge)
    assert len(set(support)) == 1 << m
    counts["bv"] += 1

# Standard injective-label Simon: support is Hamming-edge-free.
for n in (1, 2):
    D = 1 << n
    seen = set()
    for s in range(1, D):
        unseen = set(range(D))
        cosets = []
        while unseen:
            x = min(unseen)
            pair = (x, x ^ s)
            unseen.difference_update(pair)
            cosets.append(pair)
        for labels in permutations(range(D), D // 2):
            table = [None] * D
            for pair, label in zip(cosets, labels):
                for x in pair:
                    table[x] = label
            seen.add(tuple(table))
    expected = (D - 1) * factorial(D) // factorial(D // 2)
    assert len(seen) == expected, (n, len(seen), expected)
    assert not has_edge(seen), n
    counts["simon"] += 1

# Integer-only Hadamard orthogonality; floating check is just the closed formula.
for k in range(0, 9):
    N = 1 << k
    # No need to materialize an NxN square for large N.
    if N <= 32:
        rows = [[(-1) ** ((i & j).bit_count() % 2) for j in range(N)]
                for i in range(N)]
        for i in range(N):
            for j in range(N):
                assert sum(rows[i][a] * rows[j][a] for a in range(N)) == (
                    N if i == j else 0)
    for lam in (0.0, 0.25, 0.5, 1.0):
        exact_formula = 2 * lam * lam * N * N / (pi * pi) * asin(1 / sqrt(N)) ** 2
        linear_bound = 2 * lam * lam * N / (pi * pi)
        assert exact_formula + 1e-12 >= linear_bound
        assert exact_formula <= 2 * N * log(2) + 1e-12
        counts["hadamard"] += 1

print("PASS route1-converse-information author-side checks")
for key in sorted(counts):
    print(f"  {key}: {counts[key]}")
print("NOTE: general entropy/gaussian/latent theorems require independent proof and prior-art review")
