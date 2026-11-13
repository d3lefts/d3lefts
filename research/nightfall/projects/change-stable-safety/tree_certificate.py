"""Exact dynamic programming for tree-convex safety certificates.

Author-side research software; Python 3.11+; Fraction-compatible costs.
Source authentication, correctness of safety bounds, and change-manifest
completeness are assumptions, not outputs of this checker.
"""
from functools import lru_cache
from itertools import combinations
from fractions import Fraction as F
from collections import defaultdict


def parents_and_depth(parent):
    n = len(parent)
    assert n >= 1 and parent[0] is None
    children = [[] for _ in range(n)]
    depth = [-1] * n
    depth[0] = 0
    for v in range(1, n):
        p = parent[v]
        assert isinstance(p, int) and 0 <= p < v
        children[p].append(v)
        depth[v] = depth[p] + 1
    return children, depth


def valid_subtrees(parent, rows):
    children, depth = parents_and_depth(parent)
    for row in rows:
        S = set(row['support'])
        assert S and all(isinstance(v, int) and 0 <= v < len(parent) for v in S)
        top = min(S, key=lambda v: depth[v])
        assert all(parent[v] in S for v in S if v != top), 'disconnected support'
        assert row['delta'] >= 0 and row['e'] >= 0 and row['t'] >= 0
    return children, depth


def top(depth, support):
    return min(support, key=lambda v: depth[v])


def independent(rows):
    seen = set()
    for r in rows:
        S = set(r['support'])
        if seen & S:
            return False
        seen |= S
    return True


def min_pair(a, b):
    if a is None:
        return b
    if b is None:
        return a
    return a if a[0] <= b[0] else b


def subtree_packing_greedy(parent, rows):
    """Returns pairwise-disjoint selected row IDs and a minimum hitting set."""
    _, depth = valid_subtrees(parent, rows)
    left = list(rows)
    pack, hits = [], []
    while left:
        row = max(left, key=lambda r: depth[top(depth, r['support'])])
        v = top(depth, row['support'])
        pack.append(row['id'])
        hits.append(v)
        left = [r for r in left if v not in r['support']]
    return pack, hits


def worst_margin_tree(parent, rows, k):
    if not rows:
        return None
    valid_subtrees(parent, rows)
    durable = max(r['b'] - r['delta'] for r in rows)
    bottleneck = None
    for threshold in sorted({r['b'] for r in rows}, reverse=True):
        adequate = [r for r in rows if r['b'] >= threshold]
        packing, _ = subtree_packing_greedy(parent, adequate)
        if len(packing) > k:
            bottleneck = threshold
            break
    return max(durable, bottleneck) if bottleneck is not None else durable


def optimal_certificate(parent, rows, k, gamma, cap):
    """Exact minimum acquisition sum with every selected leaf-check cost <= cap.

    Returns (cost, selected row IDs), or (None, []) if infeasible.
    An admissible certificate uses either one durable item or k+1 pairwise-
    disjoint baseline-adequate items. The checker must separately authenticate
    item bounds, update provenance, and the declared support/tree structure.
    """
    assert isinstance(k, int) and k >= 0
    children, depth = valid_subtrees(parent, rows)
    eligible = [dict(r, support=frozenset(r['support'])) for r in rows if r['t'] <= cap]
    by_id = {r['id']: r for r in eligible}
    assert len(by_id) == len(eligible)
    best = None
    for r in eligible:
        if r['b'] - r['delta'] >= gamma:
            best = min_pair(best, (r['e'], (r['id'],)))
    good = [r for r in eligible if r['b'] >= gamma]
    target = k + 1
    if len(good) < target:
        return (best[0], list(best[1])) if best else (None, [])
    starts = defaultdict(list)
    for r in good:
        starts[top(depth, r['support'])].append(r)

    def combine(first, second):
        result = [None] * (target + 1)
        for i, a in enumerate(first):
            if a is None:
                continue
            for j, b in enumerate(second[:target + 1 - i]):
                if b is not None:
                    result[i+j] = min_pair(result[i+j], (a[0]+b[0], a[1]+b[1]))
        return tuple(result)

    @lru_cache(None)
    def solve(v, active):
        # active is an already selected, already paid-for row containing v,
        # whose highest node is a strict ancestor of v.
        options = [None] if active is not None else [None] + [r['id'] for r in starts[v]]
        best_at_v = [None] * (target + 1)
        for chosen in options:
            selected = active if active is not None else chosen
            state = [None] * (target + 1)
            if chosen is None:
                state[0] = (F(0), ())
            else:
                state[1] = (by_id[chosen]['e'], (chosen,))
            for child in children[v]:
                active_child = (selected if selected is not None
                                and child in by_id[selected]['support'] else None)
                state = list(combine(state, solve(child, active_child)))
            for j, candidate in enumerate(state):
                best_at_v[j] = min_pair(best_at_v[j], candidate)
        return tuple(best_at_v)

    best = min_pair(best, solve(0, None)[target])
    if best is None:
        return None, []
    ids = list(best[1])
    chosen = [by_id[i] for i in ids]
    assert len(ids) == len(set(ids))
    assert len(ids) == 1 or independent(chosen)
    return best[0], ids


def witness_after_update(rows, changed_nodes, gamma):
    changed = set(changed_nodes)
    for row in rows:
        bound = row['b'] - (row['delta'] if changed & set(row['support']) else 0)
        if bound >= gamma:
            return row['id'], bound
    return None, None
