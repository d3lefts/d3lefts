#!/usr/bin/env python3
"""NIGHTFALL exact-integer checker: Simon hidden matching / grouped Finner.

Finite exhaustive/sampled audit only. It does NOT certify the all-N theorem,
the hypergraph Holder theorem, independent external review, or novelty.
Every weighted matching/Finner assertion uses integer squares, no tolerance.
"""
from collections import defaultdict
from fractions import Fraction
from itertools import combinations, permutations, product
from math import ceil, comb, lgamma, log, prod
from random import Random

rng = Random(20261122)
stats = defaultdict(int)

def partitions(xs):
    if not xs:
        yield ()
        return
    x, *rest = xs
    for p in partitions(rest):
        yield ((x,),) + p
        for j in range(len(p)):
            p2 = list(p)
            p2[j] = tuple(sorted((x,) + p2[j]))
            yield tuple(sorted(p2))

def matching(N, s):
    unused = set(range(N))
    result = []
    while unused:
        i = min(unused)
        j = i ^ s
        assert i != j and j in unused
        unused.discard(i)
        unused.discard(j)
        result.append((i, j))
    return result

def fixed_shift_tables(N, s):
    pairs = matching(N, s)
    for labels in permutations(range(N), N // 2):
        arr = [-1] * N
        for (i, j), a in zip(pairs, labels):
            arr[i] = arr[j] = a
        yield tuple(arr)

def simon_support(N):
    return tuple(x for s in range(1, N) for x in fixed_shift_tables(N, s))

def random_block_weights(N, partition, allow_zeros=False):
    ans = []
    for B in partition:
        W = {z: rng.randrange(5) if allow_zeros else 1 + rng.randrange(4)
             for z in product(range(N), repeat=len(B))}
        if not any(W.values()):
            W[next(iter(W))] = 1
        Z = sum(v * v for v in W.values())
        assert Z > 0
        ans.append((B, W, Z))
    return ans

def internal_pairs(N, s, partition):
    return sum(1 for i, j in matching(N, s)
               if any(i in B and j in B for B in partition))

def assert_finner_for_fixed_shift(N, s, partition, weights):
    # q_B(z)=W_B(z)^2 / Z_B; the square-root integral numerator
    # over injectively labeled matching edges is an INTEGER.
    A = 0
    for x in fixed_shift_tables(N, s):
        A += prod(W[tuple(x[i] for i in B)]
                  for B, W, Z in weights)
    Z = prod(norm for B, W, norm in weights)
    h = internal_pairs(N, s, partition)
    assert A*A <= N**h * Z, (N, s, partition, A*A, N**h * Z)
    stats["integer_finner"] += 1

def exact_mixture_check(N, partition, components, support):
    M = len(components)
    qmin = None
    for x in support:
        qx = sum(
            (prod(Fraction(W[tuple(x[i] for i in B)]**2, Z)
                  for B, W, Z in blocks) for blocks in components),
            Fraction(0)) / M
        if qmin is None or qx < qmin:
            qmin = qx
    assert qmin is not None and qmin > 0
    J = prod(range(N//2 + 1, N + 1))
    L = (N - 1) * J
    R = Fraction(1, L) / qmin
    hmin = min(internal_pairs(N, s, partition) for s in range(1, N))
    # Exact all-M, all-partition domination inequality.
    assert M * R * (N - 1) * N**hmin >= J, (
        "failed mixture lower bound", N, partition, M, R, hmin)
    stats["exact_mixtures"] += 1
    return R

def decoder_fiber_check(N, support):
    # Verify failure of EVERY nonadaptive query set smaller than ceil(b/2),
    # for EVERY supported input and EVERY candidate block B. Together with
    # transcript consistency, this checks the finite adaptive lower-bound
    # mechanism. It does not prove it for arbitrary N.
    for b in range(1, N + 1):
        for B in combinations(range(N), b):
            for q in range(ceil(b / 2)):
                for asked in combinations(range(N), q):
                    fibers = defaultdict(set)
                    for x in support:
                        fibers[tuple(x[i] for i in asked)].add(
                            tuple(x[i] for i in B))
                    assert all(len(v) > 1 for v in fibers.values())
                    stats["decoder_fibers"] += 1

for N in (2, 4, 8):
    if N == 2:
        plist = [((0,), (1,)), ((0, 1),)]
    elif N == 4:
        plist = sorted(set(tuple(sorted(p))
                           for p in partitions(list(range(N)))))
        assert len(plist) == 15
    else:
        plist = [
            tuple((i,) for i in range(8)),
            ((0, 1), (2, 3), (4, 5), (6, 7)),
            ((0, 2), (1, 3), (4, 6), (5, 7)),
            ((0, 4), (1, 5), (2, 6), (3, 7)),
            ((0, 1, 2), (3, 4, 5), (6,), (7,)),
            ((0, 1, 2, 3), (4, 5), (6, 7)),
            ((0, 1, 2, 3), (4, 5, 6, 7)),
            ((0, 1), (2, 3, 4), (5, 6, 7)),
        ]
    support = simon_support(N)
    J = prod(range(N//2 + 1, N + 1))
    assert len(support) == (N - 1) * J
    assert len(set(support)) == len(support)
    if N <= 4:
        decoder_fiber_check(N, support)
    for partition in plist:
        assert sorted(i for B in partition for i in B) == list(range(N))
        hs = [internal_pairs(N, s, partition) for s in range(1, N)]
        assert sum(hs) == sum(comb(len(B), 2) for B in partition)
        b = max(len(B) for B in partition)
        assert min(hs) * 2 * (N - 1) <= N * (b - 1)
        stats["matching_partitions"] += 1
        for trial in range(3 if N <= 4 else 2):
            weights = random_block_weights(N, partition)
            for s in range(1, N):
                assert_finner_for_fixed_shift(N, s, partition, weights)
            # Zeros stress the inequality, but do not enter D_infty
            # whenever they leave a supported input with Q(x)=0.
            if trial == 0:
                zero_weights = random_block_weights(
                    N, partition, allow_zeros=True)
                for s in range(1, N):
                    assert_finner_for_fixed_shift(
                        N, s, partition, zero_weights)
            if N <= 4 or (N == 8 and trial == 0 and b <= 2):
                other = random_block_weights(N, partition)
                exact_mixture_check(
                    N, partition, [weights, other], support)
    print("N=", N, "tables=", len(support), "partitions=", len(plist))

# Fully deterministic XOR difference-cover reconstruction.
for m in range(1, 13):
    N = 1 << m
    a = (m + 1) // 2
    b = m // 2
    left = {(u << b) for u in range(1 << a)}
    right = set(range(1 << b))
    queried = left | right
    differences = {x ^ y for x in left for y in right}
    assert differences == set(range(N))
    assert len(queried) == 2**a + 2**b - 1
    assert len(queried) <= 2**a + 2**b
    stats["difference_covers"] += 1

# Numeric asymptotic squeeze is only a guard on bookkeeping; not a proof.
for m in range(1, 15):
    N = 1 << m
    H = lgamma(N + 1) - lgamma(N//2 + 1) - log(N - 1)
    alpha = N * log(N) / (N - 1)
    lower = (1 + H) / (1 + alpha)
    q0 = 2**((m+1)//2) + 2**(m//2) - 1
    upper = min(N - 1, N//2 + q0)
    assert 0 < lower <= upper <= N
    stats["asymptotic_bounds"] += 1

print("PASS Simon matching/Finner exact source audit")
for key in sorted(stats):
    print(" ", key + ":", stats[key])
print("NOTICE finite checks do not prove Finner, all-N sharp limit, or novelty.")
