#!/usr/bin/env python3
"""Independent finite audit of the periodic forest-gauge defect identity.

Exact integer arithmetic. Finite samples test the implementation only; the
universal counting proof is in 02-periodic-forest.md.
"""
from itertools import combinations, product
from random import Random


def audit(L, dimension=4, seed=0):
    vertices = list(product(range(L), repeat=dimension))
    vid = {v: i for i, v in enumerate(vertices)}
    edges = [(v, a) for v in vertices for a in range(dimension)]

    def step(v, a):
        w = list(v)
        w[a] = (w[a] + 1) % L
        return tuple(w)

    parent = list(range(len(vertices)))
    rank = [0] * len(vertices)

    def find(x):
        while x != parent[x]:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def unite(x, y):
        x, y = find(x), find(y)
        if x == y:
            return False
        if rank[x] < rank[y]:
            x, y = y, x
        parent[y] = x
        rank[x] += rank[x] == rank[y]
        return True

    rand = Random(seed)
    shuffled = list(edges)
    rand.shuffle(shuffled)
    fixed = set()
    for e in shuffled:
        if rand.random() > 0.78:
            continue
        v, a = e
        if unite(vid[v], vid[step(v, a)]):
            fixed.add(e)

    c = len({find(i) for i in range(len(vertices))})
    assert c == len(vertices) - len(fixed)
    adjacency = {e: set() for e in edges if e not in fixed}
    n = [0, 0, 0, 0, 0]
    pair_counts = {}
    for v in vertices:
        for i, j in combinations(range(dimension), 2):
            plaquette = [(v, i), (v, j),
                         (step(v, i), j), (step(v, j), i)]
            assert len(set(plaquette)) == 4
            r = sum(e in fixed for e in plaquette)
            n[r] += 1
            free = [e for e in plaquette if e not in fixed]
            for a, b in combinations(free, 2):
                p = frozenset((a, b))
                pair_counts[p] = pair_counts.get(p, 0) + 1
                adjacency[a].add(b)
                adjacency[b].add(a)
    assert all(x == 1 for x in pair_counts.values())
    assert n[4] == 0
    degrees = [len(v) for v in adjacency.values()]
    lhs = sum(deg - 4 * (dimension - 1) for deg in degrees)
    rhs = ((dimension - 1) * ((dimension - 4) * len(vertices) + 4 * c)
           + 2 * (n[0] + n[3]) + 6 * n[4])
    assert lhs == rhs, (lhs, rhs)
    assert max(degrees) >= 4 * (dimension - 1) + 1
    return L, dimension, c, len(fixed), lhs, max(degrees)


if __name__ == '__main__':
    runs = [audit(L, d, seed)
            for d in (4, 5) for L in (3, 4) for seed in range(8)]
    for d in (4, 5):
        subset = [r for r in runs if r[1] == d]
        print(f'd={d}: {len(subset)} integer tests passed; '
              f'min defect={min(r[4] for r in subset)}, '
              f'min max-degree={min(r[5] for r in subset)}')
