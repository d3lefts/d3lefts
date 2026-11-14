#!/usr/bin/env python3
"""Exact 100-model falsifier: source Parseval, influence and owned pair energy.

Independently reconstructs canonical singleton/pair kernels from original
function values with Fraction conditional expectations; includes heterogeneous
finite alphabets, rare atoms, and zero-mass symbols. Not a universal proof.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random
from collections import Counter

rng = Random(20261113)
counts = Counter()
for n in (2, 3, 4, 5):
    for trial in range(25):
        sizes = [rng.choice((2, 3)) for _ in range(n)]
        p = []
        for k in sizes:
            q = [rng.choice((1, 2, 3, 4, 7, 311, 100003)) for _ in range(k)]
            if trial % 5 == 0:
                q[rng.randrange(k)] = 0
            if not any(q):
                q[0] = 1
            p.append([Q(t, sum(q)) for t in q])
        linear = [[rng.randint(-5, 5) for _ in range(k)] for k in sizes]
        pairs = {e: [[rng.randint(-8, 8) for _ in range(sizes[e[1]])]
                      for _ in range(sizes[e[0]])]
                 for e in combinations(range(n), 2)}
        intercept = rng.randint(-5, 5)
        def f(x):
            return Q(intercept + sum(linear[i][x[i]] for i in range(n))
                     + sum(tab[x[i]][x[j]] for (i, j), tab in pairs.items()))
        xs = list(product(*(range(k) for k in sizes)))
        def prob(x):
            v = Q(1)
            for i, a in enumerate(x):
                v *= p[i][a]
            return v
        probs = {x: prob(x) for x in xs}
        assert sum(probs.values(), Q()) == 1
        vals = {x: f(x) for x in xs}
        mean = sum((probs[x]*vals[x] for x in xs), Q())
        def update(x, i, a):
            return tuple(a if k == i else x[k] for k in range(n))
        def cond(d):
            den = Q(1)
            for i, a in d.items():
                den *= p[i][a]
            if not den:
                return None
            return sum((probs[x]*vals[x] for x in xs
                        if all(x[i] == a for i, a in d.items())), Q())/den
        H1 = {(i, a): cond({i: a}) - mean if p[i][a] else Q()
              for i in range(n) for a in range(sizes[i])}
        H2 = {}
        for i, j in pairs:
            for a, b in product(range(sizes[i]), range(sizes[j])):
                H2[i,j,a,b] = (cond({i:a,j:b})-H1[i,a]-H1[j,b]-mean
                             if p[i][a]*p[j][b] else Q())
        var = sum((probs[x]*(vals[x]-mean)**2 for x in xs), Q())
        Es = {i: sum((p[i][a]*H1[i,a]**2 for a in range(sizes[i])), Q())
              for i in range(n)}
        Ep = {(i,j): sum((p[i][a]*p[j][b]*H2[i,j,a,b]**2
                          for a,b in product(range(sizes[i]), range(sizes[j]))), Q())
              for i,j in pairs}
        assert var == sum(Es.values(),Q())+sum(Ep.values(),Q())
        counts["source_parseval"] += 1
        for i in range(n):
            infl = sum((probs[x]*p[i][b]*(vals[x]-vals[update(x,i,b)])**2/2
                        for x in xs for b in range(sizes[i])), Q())
            energy = Es[i] + sum((Ep[min(i,j),max(i,j)]
                                  for j in range(n) if j!=i), Q())
            assert infl == energy, ("influence", n, trial, i)
            counts["coordinate_influence_energy"] += 1
        owners = {e:rng.choice(e) for e in pairs}
        for i in range(n):
            owned = sum((Ep[e] for e in pairs if owners[e]==i),Q())
            infl = Es[i] + sum((Ep[min(i,j),max(i,j)]
                                for j in range(n) if j!=i),Q())
            assert owned <= infl, ("owned energy", n, trial, i)
            counts["owned_energy_le_influence"] += 1
        counts["models"] += 1
print("PASS exact source Parseval, influence, and owned energies")
for name in sorted(counts):
    print(name, counts[name])
print("Finite exact Fraction tests, not Lean or universal certification.")
