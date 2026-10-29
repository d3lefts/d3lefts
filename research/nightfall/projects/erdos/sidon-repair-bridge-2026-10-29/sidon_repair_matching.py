#!/usr/bin/env python3
"""Exact matching reduction for inserting one point into a finite Sidon set.

Finite test implementation uses bitmask matching DP (exponential); the theorem
allows any polynomial-time general-graph maximum matching implementation.
"""
from functools import lru_cache
from hashlib import sha256
from itertools import combinations
import json


def sidon_sums(D, mod):
    out = {}
    for i, x in enumerate(D):
        for y in D[i:]:
            s = x + y if mod is None else (x + y) % mod
            if s in out:
                raise ValueError('input not Sidon')
            out[s] = (x, y)
    return out


def repair_cost(D, a, mod=None):
    D = tuple(sorted(D))
    assert a not in D
    sums = sidon_sums(D, mod)
    triples = set()
    for z in D:
        s = a + z if mod is None else (a + z) % mod
        if s in sums:
            x, y = sums[s]
            assert z != x and z != y
            triples.add(tuple(sorted(set((x, y, z)))))
    triples = tuple(sorted(triples))
    exceptional = sums.get(2*a if mod is None else (2*a) % mod)

    def min_cover(forced):
        remaining = [c for c in triples if forced not in c]
        incidence = {t: [] for t in D if t != forced}
        for i, c in enumerate(remaining):
            for t in c:
                incidence[t].append(i)
        assert all(len(v) <= 2 for v in incidence.values())
        adj = [set() for _ in remaining]
        for ids in incidence.values():
            if len(ids) == 2:
                u, v = ids
                adj[u].add(v)
                adj[v].add(u)

        @lru_cache(None)
        def match(mask):
            if not mask:
                return 0
            bit = mask & -mask
            i = bit.bit_length() - 1
            best = match(mask ^ bit)
            for j in adj[i]:
                if mask & (1 << j):
                    best = max(best, 1 + match(mask ^ bit ^ (1 << j)))
            return best

        return len(remaining) - match((1 << len(remaining)) - 1)

    if exceptional is None:
        return min_cover(None)
    return 1 + min(min_cover(t) for t in set(exceptional))


def audit_rows():
    for v in range(3, 16):
        for mask in range(1, 1 << v):
            if mask.bit_count() > 6:
                continue
            D = tuple(i for i in range(v) if mask & (1 << i))
            try:
                sidon_sums(D, v)
            except ValueError:
                continue
            for a in range(v):
                if a not in D:
                    yield f'{v}|{",".join(map(str,D))}|{a}|{repair_cost(D,a,v)}\n'


if __name__ == '__main__':
    rows = list(audit_rows())
    print(json.dumps({'schema': 'nightfall-sidon-repair-matching-v1',
                      'date': '2026-10-29',
                      'tested_moduli': [3, 15],
                      'max_set_size': 6,
                      'cases': len(rows),
                      'canonical_rows_sha256': sha256(''.join(rows).encode()).hexdigest(),
                      'scope': 'bounded exact tests; theorem proof awaits external referee'},
                     indent=2, sort_keys=True))
