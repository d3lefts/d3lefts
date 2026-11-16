#!/usr/bin/env python3
"""Independent exact exhaustive verifier for finite correlated evidence repair.
No dependencies; all worlds, caches, allowlists and nested source enlargements.
Source-independent of NIGHTFALL's prior 2026-11 bridge checkers.
"""
from itertools import combinations
from hashlib import sha256
from pathlib import Path

WORLDS = tuple((a, b) for a in range(2) for b in range(2))
NOMINAL = (0, 0)
SENSORS = ("x", "y", "predicate")
COST = {"x": 1, "y": 1, "predicate": 3}


def safe(w):
    return w[0] == w[1]


def read(s, w):
    if s == "x": return w[0]
    if s == "y": return w[1]
    return safe(w)


def sound(worlds, selected):
    return all(safe(w) or any(read(s, w) != read(s, NOMINAL) for s in selected)
               for w in worlds)


def subsets(items):
    return [frozenset(items[i] for i in range(len(items)) if mask & (1 << i))
            for mask in range(1 << len(items))]


def optimized_bruteforce(worlds, cached, allowed):
    candidates = subsets(sorted(set(allowed) - set(cached)))
    feasible = [(sum(COST[s] for s in extra), tuple(sorted(extra)), extra)
                for extra in candidates if sound(worlds, cached | extra)]
    return min(feasible) if feasible else None


def independent_unsafe_transversal(worlds, cached, allowed):
    constraints = []
    for w in worlds:
        if safe(w):
            continue
        ds = frozenset(s for s in SENSORS if read(s, w) != read(s, NOMINAL))
        if not ds.intersection(cached):
            constraints.append(ds.difference(cached))
    candidates = subsets(sorted(set(allowed) - set(cached)))
    feasible = [(sum(COST[s] for s in extra), tuple(sorted(extra)), extra)
                for extra in candidates if all(extra & d for d in constraints)]
    return min(feasible) if feasible else None


def check():
    all_sets = [frozenset({NOMINAL} | {w for i, w in enumerate(WORLDS[1:]) if mask & (1 << i)})
                for mask in range(8)]
    n = 0
    for w0 in all_sets:
        for w1 in all_sets:
            if not w0 <= w1:
                continue
            for w2 in all_sets:
                if not w1 <= w2:
                    continue
                for cached in subsets(SENSORS):
                    if not sound(w0, cached):
                        continue
                    for allowed in subsets(SENSORS):
                        x = optimized_bruteforce(w2, cached, allowed)
                        y = independent_unsafe_transversal(w2, cached, allowed)
                        assert (None if x is None else x[:2]) == (None if y is None else y[:2]), (w0,w1,w2,cached,allowed,x,y)
                        if x is not None:
                            assert sound(w2, cached | x[2])
                            assert not any(not safe(w) and all(read(s,w)==read(s,NOMINAL) for s in cached | x[2]) for w in w2)
                        n += 1
    w0=frozenset(((0,0),(1,1)))
    w1=w0 | {(1,0)}
    w2=w1 | {(0,1)}
    assert sound(w0,frozenset())
    assert not sound(w1,frozenset())
    assert sound(w1, frozenset(("x",)))
    assert not sound(w2,frozenset(("x",)))
    assert optimized_bruteforce(w2,frozenset(),frozenset(SENSORS))[0] == 2
    assert optimized_bruteforce(w2,frozenset(("x",)),frozenset(SENSORS))[0] == 1
    assert optimized_bruteforce(w2,frozenset(),frozenset(("predicate",)))[0] == 3
    assert all(read("x",w)==read("x",NOMINAL) for w in ((0,1),))
    assert not safe((0,1))
    print(f"PASS nested exact sensor/authority audits={n}; true 0→1→2 repair; predicate-only=3")
    print('Checker source SHA-256:', sha256(Path(__file__).read_bytes()).hexdigest())


if __name__ == '__main__': check()
