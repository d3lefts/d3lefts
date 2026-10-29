#!/usr/bin/env python3
"""Exact batched Sidon insertion by branching on a high-incidence core.

Research reference solver: matching uses bitmask DP for reproducible small
tests. The proved FPT runtime uses a polynomial-time *general graph* matching
algorithm in place of this deliberately transparent small-instance routine.
The input group is a finite direct product of cyclic groups.
"""
from collections import defaultdict
from functools import lru_cache


def add(moduli, a, b):
    return tuple((x + y) % q for x, y, q in zip(a, b, moduli))


def sidon(moduli, marks):
    seen = set()
    for i, a in enumerate(marks):
        for b in marks[i:]:
            s = add(moduli, a, b)
            if s in seen:
                return False
            seen.add(s)
    return True


def collision_system(moduli, D, E):
    """Return (ordinary supports, special supports), indexed by D; or None.

    Ordinary: a+z=x+y with a in E and x,y,z in D.
    Specials: E+D versus E+D, E+E versus D+D, E+E versus E+D.
    """
    if not sidon(moduli, E):
        return None  # New marks are untouchable: an intrinsic collision is fatal.
    old = {}
    for i, x in enumerate(D):
        for j in range(i, len(D)):
            s = add(moduli, x, D[j])
            if s in old:
                raise ValueError("D must be Sidon")
            old[s] = (i, j)
    fresh = {}
    for i, x in enumerate(E):
        for j in range(i, len(E)):
            s = add(moduli, x, E[j])
            if s in fresh:
                return None
            fresh[s] = (i, j)
    mixed = defaultdict(list)
    for a, x in enumerate(E):
        for z, y in enumerate(D):
            mixed[add(moduli, x, y)].append((a, z))

    ordinary, special = set(), set()
    for s, old_new in mixed.items():
        if s in old:
            x, y = old[s]
            for a, z in old_new:
                ordinary.add(frozenset((x, y, z)))
        for j, (a, x) in enumerate(old_new):
            for b, y in old_new[j+1:]:
                if a != b:
                    special.add(frozenset((x, y)))
        if s in fresh:
            for _, z in old_new:
                special.add(frozenset((z,)))
    for s, xy in old.items():
        if s in fresh:
            special.add(frozenset(xy))
    return tuple(sorted(ordinary, key=lambda x: tuple(sorted(x)))), tuple(
        sorted(special, key=lambda x: tuple(sorted(x)))
    )


def solve(moduli, D, E, protected=(), omit_special=False):
    """Return a minimum deletion tuple, or None when infeasible.

    omit_special exists ONLY for a negative-control test. It must never be
    used for a validated repair solution.
    """
    D, E = tuple(D), tuple(E)
    if len(D) != len(set(D)) or len(E) != len(set(E)):
        raise ValueError("Marks must be distinct")
    if set(D) & set(E):
        raise ValueError("Insertion marks must be outside D")
    F = set(protected)
    if not F <= set(D):
        raise ValueError("Protected marks must belong to D")
    if not sidon(moduli, D):
        raise ValueError("D must be Sidon")
    families = collision_system(moduli, D, E)
    if families is None:
        return None
    ordinary, special = families
    if omit_special:
        special = ()
    degree = [sum(i in s for s in ordinary) for i in range(len(D))]
    if any(t > 2*len(E) for t in degree):
        raise AssertionError("Sidon ordered-difference uniqueness violated")
    core = {i for i, v in enumerate(degree) if v >= 3}
    for s in special:
        core.update(s)
    core = tuple(sorted(core))
    protected_idx = {D.index(x) for x in F}
    best = None
    for mask in range(1 << len(core)):
        chosen = {core[j] for j in range(len(core)) if mask & (1 << j)}
        if chosen & protected_idx or any(not (chosen & s) for s in special):
            continue
        supports = [s for s in ordinary if not (chosen & s)]
        available = set(range(len(D))) - set(core) - protected_idx
        if any(not (s & available) for s in supports):
            continue
        by_mark = defaultdict(list)
        for j, s in enumerate(supports):
            for i in s & available:
                by_mark[i].append(j)
        adjacency = [dict() for _ in supports]
        for i, vertices in by_mark.items():
            if len(vertices) > 2:
                raise AssertionError("Core omitted high-incidence mark")
            if len(vertices) == 2:
                u, v = vertices
                adjacency[u][v] = i
                adjacency[v][u] = i

        @lru_cache(None)
        def matching(bits):
            if bits == 0:
                return 0, ()
            first = bits & -bits
            u = first.bit_length() - 1
            answer = matching(bits ^ first)
            for v, i in sorted(adjacency[u].items()):
                if bits & (1 << v):
                    score, marks = matching(bits ^ first ^ (1 << v))
                    if score + 1 > answer[0]:
                        answer = (score + 1, marks + (i,))
            return answer

        nu, paired_marks = matching((1 << len(supports)) - 1)
        deletes = chosen | set(paired_marks)
        for s in supports:
            if not (s & deletes):
                deletes.add(min(s & available))
        if len(deletes) != len(chosen) + len(supports) - nu:
            raise AssertionError("Edge-cover/matching cardinality mismatch")
        witness = tuple(D[i] for i in sorted(deletes))
        if best is None or len(witness) < len(best):
            best = witness

    return best
