#!/usr/bin/env python3
"""Exact minimum independent-reproof shield on a directed claim-dependency graph.

Standard-library independent mincut and exhaustive deletion-set oracle.
The scientific meaning of a selected vertex is a *fresh independent proof*
with all external dependencies cleared; a citation-only check is insufficient.
"""
from collections import deque
from itertools import combinations
from random import Random
import hashlib, json


def reachable(nodes, arcs, sources, targets, removed):
    adj = {u: [] for u in nodes}
    for u, v in arcs:
        if u not in removed and v not in removed:
            adj[u].append(v)
    seen = set(sources) - set(removed)
    todo = list(seen)
    while todo:
        u = todo.pop()
        if u in targets:
            return True
        for v in adj[u]:
            if v not in seen:
                seen.add(v)
                todo.append(v)
    return False


def exact_shield(nodes, arcs, sources, targets, costs):
    nodes = tuple(sorted(set(nodes)))
    idx = {x: i for i, x in enumerate(nodes)}
    sources, targets = set(sources), set(targets)
    assert sources and targets and sources.isdisjoint(targets)
    assert sources | targets <= set(nodes)
    assert all(x in idx and y in idx for x, y in arcs)
    eligible = set(nodes) - sources - targets
    assert all(type(costs[x]) is int and costs[x] >= 0 for x in eligible)
    cap_inf = 1 + sum(costs[x] for x in eligible)
    n = len(nodes)
    S, T = 2*n, 2*n+1
    graph = [dict() for _ in range(2*n+2)]
    def add(u, v, c):
        graph[u][v] = graph[u].get(v, 0) + c
        graph[v].setdefault(u, 0)
    for x, i in idx.items():
        add(2*i, 2*i+1, costs[x] if x in eligible else cap_inf)
    for x, y in arcs:
        add(2*idx[x]+1, 2*idx[y], cap_inf)
    for x in sources:
        add(S, 2*idx[x], cap_inf)
    for x in targets:
        add(2*idx[x]+1, T, cap_inf)
    flow = 0
    while flow < cap_inf:
        parent = {S: None}
        queue = deque([S])
        while queue and T not in parent:
            u = queue.popleft()
            for v, c in graph[u].items():
                if c > 0 and v not in parent:
                    parent[v] = u
                    queue.append(v)
        if T not in parent:
            break
        df = cap_inf
        v = T
        while v != S:
            u = parent[v]
            df = min(df, graph[u][v])
            v = u
        v = T
        while v != S:
            u = parent[v]
            graph[u][v] -= df
            graph[v][u] += df
            v = u
        flow += df
    if flow >= cap_inf:
        return None  # A direct source-to-target dependency cannot be audited internally.
    seen = {S}
    todo = [S]
    while todo:
        u = todo.pop()
        for v, c in graph[u].items():
            if c > 0 and v not in seen:
                seen.add(v)
                todo.append(v)
    picked = tuple(x for x in nodes if x in eligible and 2*idx[x] in seen and 2*idx[x]+1 not in seen)
    assert sum(costs[x] for x in picked) == flow
    assert not reachable(nodes, arcs, sources, targets, set(picked))
    return flow, picked


def brute_shield(nodes, arcs, sources, targets, costs):
    available = sorted(set(nodes) - set(sources) - set(targets))
    best = None
    for k in range(len(available)+1):
        for choice in combinations(available, k):
            if not reachable(nodes, arcs, sources, targets, set(choice)):
                weight = sum(costs[x] for x in choice)
                if best is None or weight < best:
                    best = weight
    return best


def main():
    root, target = ('s1','s2'), ('t',)
    nodes = ('s1','s2','a','b','c','d','e','t')
    arcs = [('s1','a'),('s1','b'),('a','d'),('b','d'),('d','t'),('s2','c'),('c','e'),('e','c'),('e','t')]
    costs = {'a':2,'b':3,'c':1,'d':4,'e':2}
    assert exact_shield(nodes, arcs, root, target, costs) == (5, ('c','d'))
    assert brute_shield(nodes, arcs, root, target, costs) == 5
    assert exact_shield(['s','t'], [('s','t')], ['s'], ['t'], {}) is None
    assert exact_shield(['s','a','t'], [('s','a'),('a','t')], ['s'], ['t'], {'a':0}) == (0, ('a',))

    count = 0
    # Exhaust every directed simple digraph on four vertices for distinct root/target.
    four = tuple(range(4))
    possible = [(u,v) for u in four for v in four if u != v]
    for mask in range(1 << len(possible)):
        edges = [e for i,e in enumerate(possible) if mask & (1<<i)]
        for c1,c2 in ((1,1),(1,3),(4,2)):
            c={1:c1,2:c2}
            fast=exact_shield(four,edges,{0},{3},c)
            slow=brute_shield(four,edges,{0},{3},c)
            assert (None if fast is None else fast[0]) == slow, (mask,c,fast,slow)
            count += 1
    rng = Random(20261029)
    for _ in range(3000):
        size = rng.randrange(4,9)
        vertices = tuple(range(size))
        edges = [(i,j) for i in vertices for j in vertices if i!=j and rng.randrange(5)<2]
        prices = {i: rng.randrange(6) for i in vertices[1:-1]}
        fast=exact_shield(vertices,edges,{0},{size-1},prices)
        slow=brute_shield(vertices,edges,{0},{size-1},prices)
        assert (None if fast is None else fast[0]) == slow
        count += 1
    receipt = {'tests':count,'fixed_example_min_cost':5,'fixed_shield':['c','d'],
               'direct_source_target':'infeasible','cyclic_dependency_supported':True,
               'oracle':'independent subset enumeration','algorithm':'node-split integer max-flow'}
    encoded=json.dumps(receipt,sort_keys=True,separators=(',',':')).encode()
    print(json.dumps({**receipt,'receipt_sha256':hashlib.sha256(encoded).hexdigest()},sort_keys=True))

if __name__=='__main__':
    main()
