#!/usr/bin/env python3
"""NIGHTFALL: source-exact small Simon/parity/density-domination checks.

Finite exhaustive + exact-rational tests, not a proof of Route1, of arbitrary
mixture domination, or a human novelty review. Run with Python 3.11+ stdlib.
"""
from collections import Counter
from fractions import Fraction as F
from itertools import combinations, permutations, product
from math import comb, factorial, lgamma, log, prod
from random import Random

SEED = 20261121
rng = Random(SEED)
stats = dict(simon_support=0, simon_marginal=0, product_candidates=0,
             mixture_candidates=0, mixture_family=0, parity=0, duplication=0,
             collision_subsets=0, formula=0)

def simon_tables(m):
    N = 1 << m
    S = set()
    for s in range(1, N):
        unused = set(range(N))
        cosets = []
        while unused:
            x = min(unused)
            coset = (x, x ^ s)
            unused.difference_update(coset)
            cosets.append(coset)
        assert len(cosets) == N // 2
        for ys in permutations(range(N), N // 2):
            table = [-1] * N
            for (x, xx), label in zip(cosets, ys):
                table[x] = table[xx] = label
            S.add(tuple(table))
    return tuple(sorted(S))

def integer_product_min(S, W):
    """Q_i(a)=W[i][a]/sum_b W[i][b]; use integer cross multiplication."""
    numerator = min(
        prod(W[i][tab[i]] for i in range(len(W))) for tab in S)
    denominator = prod(sum(row) for row in W)
    return F(numerator, denominator)

def random_weights(N):
    # Positive integer weights, so support is full and the entropy test applies.
    return [[1 + rng.randrange(1, 9) for _ in range(N)] for _ in range(N)]

for m in range(1, 4):
    N = 1 << m
    S = simon_tables(m)
    L = (N - 1) * factorial(N) // factorial(N // 2)
    assert len(S) == L
    stats["simon_support"] += 1
    # Exact one-coordinate uniform marginals, not an asymptotic approximation.
    for i in range(N):
        C = Counter(tab[i] for tab in S)
        assert len(C) == N and set(C.values()) == {L // N}, (m, i, C)
        stats["simon_marginal"] += 1
    # Uniform iid reference has q(x)=N^-N, so R=N^N/L exactly.
    U_min = F(1, N ** N)
    exact_R = F(N ** N, L)
    assert exact_R == F(1, L) / U_min
    # The M=1 minimax theorem predicts every product law has min_S Q <= N^-N.
    for trial in range(125 if m < 3 else 45):
        W = random_weights(N)
        observed_min = integer_product_min(S, W)
        assert observed_min <= U_min, (m, trial, observed_min, U_min)
        stats["product_candidates"] += 1
    # M=2 exploratory screen: not a lower bound for the mixture class.
    if m <= 2:
        for trial in range(200):
            W = random_weights(N)
            V = random_weights(N)
            dW = prod(sum(row) for row in W)
            dV = prod(sum(row) for row in V)
            qmin = min(
                (F(prod(W[i][tab[i]] for i in range(N)), 2 * dW)
                 + F(prod(V[i][tab[i]] for i in range(N)), 2 * dV))
                for tab in S)
            assert 0 <= qmin <= 1
            stats["mixture_candidates"] += 1
    # Explicit M>1 output-subset envelope: sum product q_A over every
    # t-subset A of output symbols. All Simon tables use exactly N/2 labels.
    for t in range(N // 2, N + 1):
        M = comb(N, t)
        containing = comb(N // 2, t - N // 2)
        qt = F(containing, M * t ** N)
        Rt = F(M * t ** N, L * containing)
        assert Rt * qt == F(1, L)
        if t == N:
            assert M == 1 and Rt == exact_R
        if t == N // 2:
            assert M == comb(N, N // 2)
            assert Rt < exact_R
        for table in S[:40]:
            used = set(table)
            assert len(used) == N // 2
            direct_count = sum(used.issubset(A)
                               for A in combinations(range(N), t))
            assert direct_count == containing
            q_from_mixture = F(direct_count, M * t ** N)
            assert q_from_mixture == qt
        if N == 4 and t == 3:
            assert M == 4 and Rt == F(9, 2)
        if N == 4 and t == 2:
            assert M == 6 and Rt == F(8, 3)
        stats["mixture_family"] += 1
    stats["formula"] += 1
    print("Simon m=", m, "N=", N, "L=", L, "R_min_product=", exact_R,
          "D∞ nats=", round(log(N) * N - log(L), 8))

# Check parity ν=2 U on parity-zero support, irrespective of dimension.
for m in range(2, 10):
    S = [x for x in product((0, 1), repeat=m) if sum(x) % 2 == 0]
    assert len(S) == 1 << (m - 1)
    U = F(1, 1 << m)
    P = F(1, len(S))
    assert P / U == 2
    # Any proper subset's projection is uniform: there are 2^(m-b-1)
    # completions for every fixed assignment to b<m queried bits.
    for b in range(m):
        complete = 1 << (m - b - 1)
        C = Counter(x[:b] for x in S)
        assert set(C.values()) == {complete}
    stats["parity"] += 1

# Query-reconstructible grouping: each duplicated pair costs one original query.
for m in range(1, 9):
    words = [tuple(v for z in s for v in (z, z))
             for s in product((0, 1), repeat=m)]
    assert len(set(words)) == 1 << m
    for x in words:
        recovered = tuple((x[2*j], x[2*j]) for j in range(m))
        assert recovered == tuple(x[2*j:2*j+2] for j in range(m))
    # The block values have the fully independent fair-bit law, so R=M=kappa=1.
    stats["duplication"] += 1

# For all possible paths with q distinct addresses, Simon collision event
# is s in their set of nonzero pairwise XOR differences, <= choose(q,2).
# The future adaptive path of the fake injection oracle is s-independent.
for m in range(1, 5):
    N = 1 << m
    for q in range(1, min(N, 4) + 1):
        for addresses in combinations(range(N), q):
            differences = {a ^ b for a, b in combinations(addresses, 2)}
            assert 0 not in differences
            assert len(differences) <= comb(q, 2)
            assert F(len(differences), N - 1) <= F(comb(q, 2), N - 1)
            stats["collision_subsets"] += 1

print("PASS query-aware density and Simon finite exact checker")
for k in sorted(stats):
    print(" ", k + ":", stats[k])
print("Scope: no M>1 optimality, no formal Route1 block bridge, no quantum lower-bound certificate.")
