#!/usr/bin/env python3
"""Independent exact-rational full-product SCIF source recertification falsifier.

Two implementations are intentionally different:
  - canonical Efron–Stein sectors are recomputed from full product sums
    and inclusion/exclusion on every old/new source point;
  - SCIF repair uses ONLY old singleton/pair sectors and the new k law.
No sampled arithmetic, positivity floors, or sourced new sectors occur
inside the repair formulas. The checker is finite-only, not a theorem.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from functools import lru_cache
from random import Random

def trial(seed, n=3, a=3):
    rng = Random(seed)
    worlds = tuple(product(range(a), repeat=n))
    source = [
        tuple(Q(t, sum(row)) for t in row)
        for row in (
            [rng.randint(0, 3) for _ in range(a)]
            for _ in range(n)
        )
        if sum(row) != 0
    ]
    # Replace rare all-zero rows explicitly, keeping n marginals.
    while len(source) < n:
        source.append(tuple(Q(1, a) for _ in range(a)))
    qraw = [rng.randint(0, 3) for _ in range(a)]
    if not any(qraw):
        qraw[0] = 1
    q = tuple(Q(t, sum(qraw)) for t in qraw)
    target = [q if i == 0 else source[i] for i in range(n)]
    const = Q(rng.randint(-4, 4))
    unary = [[Q(rng.randint(-3, 3)) for _ in range(a)] for _ in range(n)]
    pair = {(i, j): [[Q(rng.randint(-3, 3)) for _ in range(a)]
                      for _ in range(a)]
            for i, j in combinations(range(n), 2)}
    def f(x):
        return (const + sum((unary[i][x[i]] for i in range(n)), Q(0)) +
                sum((pair[i, j][x[i]][x[j]]
                     for i, j in combinations(range(n), 2)), Q(0)))
    def mass(law, x):
        ans = Q(1)
        for i in range(n):
            ans *= law[i][x[i]]
        return ans
    @lru_cache(None)
    def canonical(which, mask, x):
        law = source if which == 0 else target
        ans = Q(0)
        for U in range(1 << n):
            if U & ~mask:
                continue
            c = Q(0)
            for y in worlds:
                z = tuple(x[i] if U & (1 << i) else y[i]
                          for i in range(n))
                c += mass(law, y) * f(z)
            ans += (-1 if (mask.bit_count() - U.bit_count()) & 1 else 1) * c
        return ans
    checks = 0
    p = source[0]
    def with_k(x, value):
        return (value,) + x[1:]
    for x in worlds:
        beta = sum((q[v] * canonical(0, 1, with_k(x, v))
                    for v in range(a)), Q(0))
        bs = {j: sum((q[v] * canonical(0, 1 | (1 << j), with_k(x, v))
                       for v in range(a)), Q(0)) for j in range(1, n)}
        assert sum((canonical(0, S, x) for S in range(1 << n)), Q(0)) == f(x)
        assert sum((canonical(1, S, x) for S in range(1 << n)), Q(0)) == f(x)
        for which in (0, 1):
            assert canonical(which, (1 << n)-1, x) == 0
        assert canonical(1, 0, x) == canonical(0, 0, x) + beta
        assert canonical(1, 1, x) == canonical(0, 1, x) - beta
        for j in range(1, n):
            assert canonical(1, 1 << j, x) == canonical(0, 1 << j, x) + bs[j]
            assert canonical(1, 1 | (1 << j), x) == (
                canonical(0, 1 | (1 << j), x) - bs[j]
            )
        for i, j in combinations(range(1, n), 2):
            assert canonical(1, (1 << i) | (1 << j), x) == (
                canonical(0, (1 << i) | (1 << j), x)
            )
        checks += 7 + 3 * (n-1)
    def influence(law, i):
        return sum((mass(law, x) * (
            f(x) - sum((law[i][v] * f(tuple(v if z == i else x[z]
                                          for z in range(n)))
                        for v in range(a)), Q(0))) ** 2
            for x in worlds), Q(0))
    old = [influence(source, i) for i in range(n)]
    new = [influence(target, i) for i in range(n)]
    base = worlds[0]
    hk = lambda u: canonical(0, 1, with_k(base, u))
    beta = sum((q[u] * hk(u) for u in range(a)), Q(0))
    delta_k = sum(((q[u]-p[u])*hk(u)**2 for u in range(a)), Q(0))-beta**2
    for j in range(1, n):
        hj = lambda v: canonical(0, 1 << j, tuple(v if z == j else 0
                                                for z in range(n)))
        hkj = lambda u,v: canonical(0, 1 | (1 << j),
                                   tuple(u if z == 0 else v if z == j
                                         else 0 for z in range(n)))
        bj = lambda v: sum((q[u]*hkj(u,v) for u in range(a)), Q(0))
        delta_j = (2 * sum((source[j][v]*hj(v)*bj(v)
                            for v in range(a)), Q(0)) +
                   sum(((q[u]-p[u])*source[j][v]*hkj(u,v)**2
                        for u in range(a) for v in range(a)), Q(0)))
        assert new[j]-old[j] == delta_j, (seed,j,new[j]-old[j],delta_j)
        delta_k += (sum(((q[u]-p[u])*source[j][v]*hkj(u,v)**2
                          for u in range(a) for v in range(a)), Q(0)) -
                    sum((source[j][v]*bj(v)**2 for v in range(a)), Q(0)))
        checks += 2
    assert new[0]-old[0] == delta_k, (seed, new[0]-old[0], delta_k)
    return checks + 1

def main():
    checks = 0
    for seed in range(40):
        checks += trial(seed)
    print("PASS exact old/new canonical ANOVA and actual source influences:",
          checks, "assertion families; 40 random fully specified 3x3 source laws")
if __name__ == "__main__":
    main()
