#!/usr/bin/env python3
"""Exact finite falsifiers for uniform linear-code / graph intensity Wyner formula.

All fields are F2. No stochastic optimization or independent Lean/theorem certificate.
"""
from itertools import combinations
from collections import deque


def all_subspaces(m):
    """Build EVERY linear subspace via closure under adding new generators."""
    universe = 1 << m
    origin = frozenset([0])
    found = {origin}
    pending = [origin]
    while pending:
        space = pending.pop()
        for v in range(1, universe):
            if v not in space:
                next_space = frozenset(space | {u ^ v for u in space})
                if next_space not in found:
                    found.add(next_space)
                    pending.append(next_space)
    return found


def check_linear_subspace(space, m):
    assert (len(space) & (len(space) - 1)) == 0
    dim = len(space).bit_length() - 1
    axes = [i for i in range(m) if (1 << i) in space]
    free_mask = sum(1 << i for i in axes)
    nonfree_mask = ((1 << m) - 1) ^ free_mask
    fibers = {}
    for v in space:
        projection = v & nonfree_mask
        fibers.setdefault(projection, set()).add(v)
    assert len(fibers) == (1 << (dim - len(axes)))
    for projection, fiber in fibers.items():
        # Exact product form: each free axis varies independently.
        assert fiber == {projection ^ j for j in range(1 << m) if j & nonfree_mask == 0}
    for i in range(m):
        exists_edge = any((v ^ (1 << i)) in space for v in space)
        assert exists_edge == (i in axes)
    return dim, len(axes)


def components(n, edges):
    adj = [set() for _ in range(n)]
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    seen = set()
    count = 0
    for u in range(n):
        if u not in seen:
            count += 1
            seen.add(u)
            stack = [u]
            while stack:
                t = stack.pop()
                for v in adj[t]:
                    if v not in seen:
                        seen.add(v)
                        stack.append(v)
    return count


def graph_code(n, edges):
    """Method 1: generate actual squared-linear sensor outputs on all sign inputs."""
    vals = set()
    for sign_bits in range(1 << (n - 1)):
        signs = [1] + [-1 if ((sign_bits >> (v - 1)) & 1) else 1 for v in range(1, n)]
        intensities = [((signs[u] + signs[v]) ** 2) for u, v in edges]
        assert all(y in (0, 4) for y in intensities)
        mask = sum((1 << i) for i, y in enumerate(intensities) if y == 0)
        vals.add(mask)
    return vals


def check_graph(n, edges):
    c = components(n, edges)
    bridges = sum(components(n, edges[:j] + edges[j+1:]) > c for j in range(len(edges)))
    space = graph_code(n, edges)
    d, r = check_linear_subspace(space, len(edges))
    assert d == n - c, (n, edges, d, c)
    assert r == bridges, (n, edges, r, bridges)
    # An exact no-numerical-bound expression of the predicted Wyner bit count.
    assert d - r == n - c - bridges
    return d - r


def main():
    total_spaces = 0
    for m in range(5):
        spaces = all_subspaces(m)
        for space in spaces:
            check_linear_subspace(space, m)
        total_spaces += len(spaces)
        print(f"PASS F2^{m} all {len(spaces)} linear subspaces")
    assert len(all_subspaces(4)) == 67

    graphs = 0
    for n in range(2, 6):
        all_edges = list(combinations(range(n), 2))
        for mask in range(1 << len(all_edges)):
            edges = [e for j, e in enumerate(all_edges) if (mask >> j) & 1]
            check_graph(n, edges)
            graphs += 1
    assert graphs == 1098
    print(f"PASS {graphs} simple graphs (2..5 vertices), actual integer intensities and independent bridge audit")
    for n, edges, expected in [
        (4, [(0,1),(1,2),(2,3)], 0),
        (4, [(0,1),(1,2),(2,3),(3,0)], 3),
        (4, [(0,1),(1,2),(2,0),(2,3)], 2),
        (4, list(combinations(range(4), 2)), 3),
    ]:
        actual = check_graph(n, edges)
        assert actual == expected, (edges, actual, expected)
    print(f"PASS {total_spaces} independent binary subspace checks and graph transition controls")
    print("STATUS: exact finite regression only; no Wyner infimum optimization, Lean kernel or priority certificate")


if __name__ == "__main__":
    main()
