#!/usr/bin/env python3
"""Independent exact check of the adaptive conditional-seed lifting invariant.

This does NOT prove the quantum hybrid lemma or the BDST transformation.
All probabilities are exact Fractions. The public source check certifies:
* one-sided rounding yields dyadic q, including zero-atom p;
* a maximal one-sided coupling C(Y|X) has correct marginals;
* choosing U uniformly from the preimage of Y makes unconditional U uniform;
* the seed-bit queries reveal a consistent fixed uniform block, in any order.
"""
from fractions import Fraction as F
from itertools import combinations
from random import Random

SEED, TRIALS = 20261119, 240
rng = Random(SEED)
checks = 0

def round_law(p, m):
    N = 1 << m
    s = len(p)
    anchor = max(range(s), key=lambda i: p[i])
    q = [F(0)] * s
    for a in range(s):
        if a != anchor:
            z = N * p[a]
            q[a] = F((z.numerator + z.denominator - 1) // z.denominator, N)
    q[anchor] = 1 - sum(q)
    assert min(q) >= 0 and sum(q) == 1
    return q, anchor

def decoder(q, m):
    N = 1 << m
    outputs = []
    for a, mass in enumerate(q):
        count = int(N * mass)
        assert F(count, N) == mass
        outputs.extend([a] * count)
    assert len(outputs) == N
    return outputs

def coupling(p, q, anchor):
    s = len(p)
    assert p[anchor] > 0
    C = [[F(0)] * s for _ in range(s)]
    for x in range(s):
        if x != anchor:
            C[x][x] = F(1)
    for y in range(s):
        if y == anchor:
            C[anchor][y] = q[y] / p[anchor]
        else:
            C[anchor][y] = (q[y] - p[y]) / p[anchor]
    assert all(c >= 0 for row in C for c in row)
    assert all(sum(row) == 1 for row in C)
    assert all(sum(p[x]*C[x][y] for x in range(s)) == q[y] for y in range(s))
    return C

def check_one(p, m):
    global checks
    s = len(p)
    q, anchor = round_law(p, m)
    C = coupling(p, q, anchor)
    dec = decoder(q, m)
    N = 1 << m
    # Joint distribution P(X=x, U=u); the preimage of each Y is equally likely.
    joint = [[F(0)] * N for _ in range(s)]
    for x in range(s):
        for u, y in enumerate(dec):
            if q[y] > 0:
                joint[x][u] = p[x] * C[x][y] / (N * q[y])
    assert all(sum(joint[x]) == p[x] for x in range(s))
    assert all(sum(joint[x][u] for x in range(s)) == F(1, N) for u in range(N))
    assert all(sum(joint[x][u] for x in range(s) for u in range(N) if dec[u] == y) == q[y]
               for y in range(s))
    gamma = F(s*s, N)
    for x in range(s):
        if p[x]:
            mismatch = sum(C[x][y] for y in range(s) if y != x)
            assert mismatch <= gamma
    # Adaptive seed-bit queries are jointly uniform, with exact stored answers.
    for bits in combinations(range(m), min(m, 3)):
        pattern_probs = {}
        for u in range(N):
            pattern = tuple((u >> b) & 1 for b in bits)
            pattern_probs[pattern] = pattern_probs.get(pattern, F(0)) + sum(joint[x][u] for x in range(s))
        assert len(pattern_probs) == (1 << len(bits))
        assert all(v == F(1, 1 << len(bits)) for v in pattern_probs.values())
    checks += 1

for s in range(2, 6):
    for m in range(5, 9):
        if (1 << m) < s*(s-1):
            continue
        check_one([F(1)] + [F(0)] * (s-1), m)
        check_one([F(0)] * (s-1) + [F(1)], m)
        for _ in range(TRIALS // 16):
            raw = [rng.choice([0, 0, 1, 2, 3, 7, 101, 1009]) for _ in range(s)]
            if sum(raw) == 0:
                raw[0] = 1
            p = [F(x, sum(raw)) for x in raw]
            check_one(p, m)

print(f"PASS: {checks} exact dyadic lifting cases; seed={SEED}; zero atoms included")
print("Scope: finite probability/coupling/consistent blocks, not quantum-oracle or high-probability formalization")
