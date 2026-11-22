#!/usr/bin/env python3
"""Exact finite GF(2) checks of graph-edge primitive XOR fibers.

Finite instances only: the all-graph forest argument and T2 quantum
operator theorem have separate mathematical and certification obligations.
"""
from collections import Counter, defaultdict, deque
from itertools import combinations, product
from math import factorial


def torus_edges(L):
    assert L >= 3
    vertex = lambda i, j: (i % L) * L + (j % L)
    edges = sorted({tuple(sorted((vertex(i, j), vertex(i+di, j+dj))))
                    for i in range(L) for j in range(L)
                    for di, dj in ((1, 0), (0, 1), (1, 1))})
    assert len(edges) == 3 * L * L
    return L * L, edges


def labels(edges):
    return [(1 << u) ^ (1 << v) for u, v in edges]


def independent_xor(values):
    for mask in range(1, 1 << len(values)):
        x = 0
        for j, a in enumerate(values):
            if mask & (1 << j):
                x ^= a
        if x == 0:
            return False
    return True


def is_forest_union_find(edge_subset):
    parents = {}

    def find(v):
        while parents[v] != v:
            parents[v] = parents[parents[v]]
            v = parents[v]
        return v

    for u, v in edge_subset:
        parents.setdefault(u, u)
        parents.setdefault(v, v)
        ru, rv = find(u), find(v)
        if ru == rv:
            return False
        parents[ru] = rv
    return True


def subset_fibers(edges, compare_alternate=False):
    """Method A: un-ordered forests, counted by ordered nonzero slot placements."""
    xs = labels(edges)
    hist = Counter()
    for k in range(1, 5):
        placements = factorial(4) // factorial(4-k)
        for inds in combinations(range(len(edges)), k):
            forest = is_forest_union_find([edges[i] for i in inds])
            if compare_alternate:
                assert forest == independent_xor([xs[i] for i in inds])
            if not forest:
                continue
            z = 0
            for i in inds:
                z ^= xs[i]
            assert z
            hist[z] += placements
    return hist


def pair_fibers(edges):
    D = (0,) + tuple(labels(edges))
    return Counter(a ^ b for a, b in product(D, repeat=2) if a ^ b)


def direct_tuple_fibers(edges):
    """Method B: independently enumerate all ordered 4-slot XOR tuples."""
    D = (0,) + tuple(labels(edges))
    hist = Counter()
    for t in product(D, repeat=4):
        nonzero = [a for a in t if a]
        if nonzero and len(nonzero) == len(set(nonzero)) and independent_xor(nonzero):
            z = t[0] ^ t[1] ^ t[2] ^ t[3]
            assert z
            hist[z] += 1
    return hist


def triangle_overlap_connected(n, edges):
    edge_id = {e: i for i, e in enumerate(edges)}
    adjacency = [set() for _ in range(n)]
    for u, v in edges:
        adjacency[u].add(v)
        adjacency[v].add(u)
    triangles = set()
    for u in range(n):
        for v, w in combinations(sorted(x for x in adjacency[u] if x > u), 2):
            if w in adjacency[v]:
                triangles.add(frozenset((
                    edge_id[tuple(sorted((u, v)))],
                    edge_id[tuple(sorted((u, w)))],
                    edge_id[tuple(sorted((v, w)))])))
    owner = defaultdict(list)
    for k, triangle in enumerate(triangles):
        for e in triangle:
            owner[e].append(k)
    assert len(owner) == len(edges), "edge not contained in a triangle"
    neighbors = [set() for _ in triangles]
    for ids in owner.values():
        for i, j in combinations(ids, 2):
            neighbors[i].add(j)
            neighbors[j].add(i)
    seen, pending = {0}, deque([0])
    while pending:
        for j in neighbors[pending.popleft()]:
            if j not in seen:
                seen.add(j)
                pending.append(j)
    assert len(seen) == len(triangles)
    # L=3 wraps produce nine extra 3-cycles; L>=4 has exactly 2L^2.
    assert len(triangles) == (2*n if n >= 16 else 3*n)
    return len(triangles)


def rank_gf2(values):
    pivots = {}
    for value in values:
        while value:
            i = value.bit_length() - 1
            if i not in pivots:
                pivots[i] = value
                break
            value ^= pivots[i]
    return len(pivots)


def test_small_source(n, edges):
    assert n <= 9
    R = labels(edges)
    code = {tuple((a & s).bit_count() % 2 for a in R)
            for s in range(1 << n)}
    assert len(code) == 2 ** (n - 1)
    for x in code:
        for j in range(len(R)):
            assert x[:j] + (x[j] ^ 1,) + x[j+1:] not in code
    print("PASS small source: full code size 2^(n-1), no Hamming-one neighbors")


def bridge_negative():
    R = labels([(0, 1), (1, 2)])
    code = {tuple((a & s).bit_count() % 2 for a in R) for s in range(8)}
    assert code == set(product((0, 1), repeat=2))
    print("PASS bridge negative control: raw edge support has Hamming-one neighbors")


def main():
    for L in (3, 4, 5):
        n, edges = torus_edges(L)
        assert rank_gf2(labels(edges)) == n-1
        triangles = triangle_overlap_connected(n, edges)
        freq = subset_fibers(edges, compare_alternate=(L <= 4))
        m2 = pair_fibers(edges)
        K, M = max(freq.values()), max(m2.values())
        expected = {3: (2400, 12), 4: (1464, 6), 5: (1056, 6)}[L]
        assert (K, M) == expected, (L, K, M, expected)
        if L == 3:
            assert freq == direct_tuple_fibers(edges)
            test_small_source(n, edges)
        assert M <= 14
        print(f"PASS torus L={L}: vertices={n}, edges={len(edges)}, "
              f"triangles={triangles}, K4={K}, M2={M}, rank={n-1}")
    bridge_negative()
    print("Finite exact combinatorics only; no all-graph Lean or quantum T2 certificate.")


if __name__ == "__main__":
    main()
