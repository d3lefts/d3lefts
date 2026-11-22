#!/usr/bin/env python3
"""Exact finite regression of affine dual-distance and graph cut-space risk transfer.

No third-party dependencies; integer counts and Fraction. This is not a Lean proof.
"""
from collections import Counter
from fractions import Fraction
from itertools import combinations, product


def bit_weight(v):
    return v.bit_count()


def project(word, indices):
    return tuple((word >> i) & 1 for i in indices)


def subspaces(m):
    seen = {frozenset((0,))}
    frontier = [frozenset((0,))]
    while frontier:
        L = frontier.pop()
        for v in range(1 << m):
            enlarged = frozenset(L | {a ^ v for a in L})
            if enlarged not in seen:
                seen.add(enlarged)
                frontier.append(enlarged)
    return seen


def dual_distance(m, L):
    dual = [h for h in range(1, 1 << m)
            if all(bit_weight(h & x) % 2 == 0 for x in L)]
    return min((bit_weight(h) for h in dual), default=float('inf'))


def check_affine_codes():
    count = 0
    for m in range(1, 5):
        for L in subspaces(m):
            g = dual_distance(m, L)
            cosets = {frozenset(a ^ x for x in L) for a in range(1 << m)}
            for C in cosets:
                count += 1
                for k in range(m + 1):
                    for idx in combinations(range(m), k):
                        table = Counter(project(x, idx) for x in C)
                        uniform = (len(table) == 1 << k and
                                   set(table.values()) == {len(C) // (1 << k)})
                        if k < g:
                            assert uniform, ("affine law below dual distance", m, L, C, idx, g)
                if g != float('inf'):
                    assert any(
                        len({project(x, idx) for x in C}) < (1 << int(g))
                        for idx in combinations(range(m), int(g))
                    ), ("missing dual-distance negative control", m, L, C, g)
    return count


def graph_girth(n, edges):
    adj = [[] for _ in range(n)]
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)
    result = float('inf')
    for root in range(n):
        dist = [-1] * n
        parent = [-1] * n
        dist[root] = 0
        queue = [root]
        for u in queue:
            for v in adj[u]:
                if dist[v] == -1:
                    dist[v] = dist[u] + 1
                    parent[v] = u
                    queue.append(v)
                elif parent[u] != v:
                    result = min(result, dist[u] + dist[v] + 1)
    return result


def check_graphs():
    count = 0
    for n in range(2, 6):
        possible = list(combinations(range(n), 2))
        for selected in product((0, 1), repeat=len(possible)):
            edges = [e for keep, e in zip(selected, possible) if keep]
            m = len(edges)
            g = graph_girth(n, edges)
            source = [tuple((bits[u] ^ bits[v]) for u, v in edges)
                      for bits in product((0, 1), repeat=n)]
            count += 1
            for k in range(min(4, m) + 1):
                if k >= g:
                    continue
                for idx in combinations(range(m), k):
                    counts = Counter(tuple(w[i] for i in idx) for w in source)
                    assert len(counts) == 1 << k
                    assert set(counts.values()) == {1 << (n - k)}
            if g != float('inf'):
                assert any(
                    len({tuple(w[i] for i in idx) for w in source}) < 1 << int(g)
                    for idx in combinations(range(m), int(g))
                ), ("graph girth-boundary negative control", n, edges, g)
    return count


def check_cycle_risk():
    cycle4 = [(0, 1), (1, 2), (2, 3), (3, 0)]
    code = {tuple((bits[u] ^ bits[v]) for u, v in cycle4)
            for bits in product((0, 1), repeat=4)}
    unif = set(product((0, 1), repeat=4))
    f = lambda w: int(w[0] == w[1])
    tree = lambda w: int(w[2] == w[3])

    def risk(support):
        return sum((Fraction((f(w) - tree(w)) ** 2, len(support))
                    for w in support), Fraction(0))

    assert risk(unif) == Fraction(1, 2)
    assert risk(code) == Fraction(0)
    return risk(unif), risk(code)


if __name__ == '__main__':
    na = check_affine_codes()
    ng = check_graphs()
    before, after = check_cycle_risk()
    assert ng == 1098
    print(f'PASS: {na} affine-code cosets (m=1..4), {ng} simple graphs (n=2..5)')
    print(f'PASS: shortest dual/cycle negative controls; C4 MSE product={before}, cut={after}')
    print('SCOPE: exact finite checks only; not analytic or Lean certification')
