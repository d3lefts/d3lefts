#!/usr/bin/env python3
"""Independent exact posterior-drift falsification.
Every legal transcript, every next coordinate, heterogeneous categorical laws.
The identity checked is E[T_after | transcript] = T_before - I_i,
NOT the false analogous variance identity. Python stdlib, exact Fractions.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from math import prod
from random import Random
import json

def run(seed, n):
    r = Random(2718281828 + seed)
    p = []
    for i in range(n):
        k = r.choice((2, 3))
        w = [r.choice((1, 2, 3, 7, 11, 101)) for _ in range(k)]
        if seed % 3 == 0 and i in (0, n - 1):
            w[0], w[-1] = 1, 10007
        p.append(tuple(Q(z, sum(w)) for z in w))
    A = {i: [Q(r.randrange(-8, 9)) for _ in p[i]] for i in range(n)}
    P = {(i, j): [[Q(r.randrange(-6, 7)) for _ in p[j]] for _ in p[i]]
         for i, j in combinations(range(n), 2)}
    xs = list(product(*[range(len(x)) for x in p]))
    f = {x: sum((A[i][x[i]] for i in range(n)), Q(0)) +
         sum((v[x[i]][x[j]] for (i, j), v in P.items()), Q(0)) for x in xs}
    count = false_var = 0
    for d in range(n):
        for S in combinations(range(n), d):
            for vals in product(*[range(len(p[i])) for i in S]):
                fixed = dict(zip(S, vals))
                free = tuple(i for i in range(n) if i not in fixed)
                mass = {x: prod(p[j][x[j]] for j in free)
                        for x in xs if all(x[i] == v for i, v in fixed.items())}
                assert sum(mass.values(), Q(0)) == 1
                mean = sum((w * f[x] for x, w in mass.items()), Q(0))
                var = sum((w * (f[x] - mean)**2 for x, w in mass.items()), Q(0))
                inf = {}
                for j in free:
                    inf[j] = sum((w * p[j][a] *
                        (f[x] - f[tuple(a if t == j else x[t] for t in range(n))])**2 / 2
                        for x, w in mass.items() for a in range(len(p[j]))), Q(0))
                T = sum(inf.values(), Q(0))
                assert var <= T <= 2 * var
                for i in free:
                    nxtT = nxtVar = Q(0)
                    for a, weight in enumerate(p[i]):
                        reduced = {x: prod(p[j][x[j]] for j in free if j != i)
                                   for x in mass if x[i] == a}
                        assert sum(reduced.values(), Q(0)) == 1
                        new_mean = sum((w * f[x] for x, w in reduced.items()), Q(0))
                        nxtVar += weight * sum(
                            (w * (f[x] - new_mean)**2 for x, w in reduced.items()), Q(0))
                        for j in free:
                            if j == i: continue
                            nxtT += weight * sum((w * p[j][b] *
                                (f[x] - f[tuple(b if t == j else x[t] for t in range(n))])**2 / 2
                                for x, w in reduced.items() for b in range(len(p[j]))), Q(0))
                    assert nxtT == T - inf[i], (seed, fixed, i, nxtT, T, inf[i])
                    assert var - inf[i] <= nxtVar <= var
                    false_var += nxtVar != var - inf[i]
                    count += 1
    return count, false_var

if __name__ == "__main__":
    cases = [run(t, 4 + t % 2) for t in range(12)]
    result = {"status": "PASS", "models": len(cases),
              "transcript_next_query_checks": sum(x for x, _ in cases),
              "false_variance_drift_controls": sum(y for _, y in cases)}
    assert result["transcript_next_query_checks"] == 5360
    assert result["false_variance_drift_controls"] == 3851
    print(json.dumps(result, indent=2))
