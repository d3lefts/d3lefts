#!/usr/bin/env python3
"""Independent exact Fraction falsifier for sharp likelihood-ratio loss transport.

GREEDY: sorts exact density ratios and fractionally fills reference mass.
VERTICES: independent exhaustive knapsack-vertex enumeration.
DUAL: independent exact minimization at all breakpoints.
A PASS covers only these finite instances; it is NOT an infinite theorem proof.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random
from hashlib import sha256

SEED = 261111
rng = Random(SEED)

def greedy(p, q, t):
    out, left = Q(0), t
    z = [Q(0)] * len(p)
    for i in sorted(range(len(p)), key=lambda j: q[j] / p[j], reverse=True):
        take = min(left, p[i])
        z[i] = take / p[i]
        out += q[i] * z[i]
        left -= take
        if left == 0:
            break
    return out, z

def vertices(p, q, t):
    # A vertex of the one-budget box knapsack has at most one fractional z_i.
    n, best = len(p), Q(0)
    for bits in product((0, 1), repeat=n):
        cost = sum((p[i] * bits[i] for i in range(n)), Q(0))
        gain = sum((q[i] * bits[i] for i in range(n)), Q(0))
        if cost <= t:
            best = max(best, gain)
        for j in range(n):
            if bits[j]:
                continue
            z = (t - cost) / p[j]
            if 0 <= z <= 1:
                best = max(best, gain + q[j] * z)
    return best

def dual(p, q, t):
    # Convex piecewise-linear dual minimizes at zero or a density-ratio breakpoint.
    return min(a * t + sum((max(q[i] - a * p[i], 0)
                            for i in range(len(p))), Q(0))
               for a in [Q(0)] + [q[i] / p[i] for i in range(len(p))])

def random_prob(n):
    v = [rng.randrange(1, 15) for _ in range(n)]
    s = sum(v)
    return tuple(Q(x, s) for x in v)

trials = 0
for n in range(1, 7):
    reps = 100 if n <= 4 else 30
    for _ in range(reps):
        p, q = random_prob(n), random_prob(n)
        for t in [Q(0), Q(1), Q(1, 11), Q(3, 7), Q(5, 6),
                  Q(rng.randrange(0, 23), 23)]:
            val, z = greedy(p, q, t)
            independent = vertices(p, q, t)
            dual_val = dual(p, q, t)
            assert val == independent == dual_val, (p, q, t, val, independent, dual_val)
            assert all(0 <= zz <= 1 for zz in z)
            assert sum((pp * zz for pp, zz in zip(p, z)), Q(0)) <= t
            trials += 1

# Adversarial sequence: absolutely continuous target laws but NO uniform rate
# over the full target family. A 1/n source event can have target mass one.
for n in range(2, 30):
    p = tuple(Q(1, n) for _ in range(n))
    q = tuple(Q(1) if i == 0 else Q(0) for i in range(n))
    assert greedy(p, q, Q(1, n))[0] == 1

assert trials == 2760
receipt = f"status=PASS exact_cases={trials} adversarial_family=28 seed={SEED}"
print(receipt)
print("receipt_sha256", sha256(receipt.encode()).hexdigest())
