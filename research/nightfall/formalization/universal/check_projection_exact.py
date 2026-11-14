#!/usr/bin/env python3
"""Independent exact finite model audit of cylinder projection/influence contraction.

Finite audits do NOT certify infinitary L2 density, independence, or Lean.
Standard library only. Seed and source algorithm printed for reproduction.
"""
from fractions import Fraction as Q
from itertools import product, combinations
import hashlib
import random
import sys

SEED = 20261114
R = random.Random(SEED)


def all_states(n, m):
    return list(product(range(m), repeat=n))


def law(n, m):
    rows = []
    for _ in range(n):
        counts = [R.randrange(4) for _ in range(m)]
        if sum(counts) == 0:
            counts[R.randrange(m)] = 1
        rows.append([Q(x, sum(counts)) for x in counts])
    return rows


def expected(table, masses):
    return sum((masses[x] * table[x] for x in masses), Q(0))


def proj(table, masses, F):
    # Independent implementation: conditional mean on finite-coordinate cells.
    bucket_sum, bucket_mass = {}, {}
    for x, w in masses.items():
        key = tuple(x[j] for j in F)
        bucket_sum[key] = bucket_sum.get(key, Q(0)) + w * table[x]
        bucket_mass[key] = bucket_mass.get(key, Q(0)) + w
    return {x: (bucket_sum[key] / bucket_mass[key]
                if bucket_mass[key] != 0 else Q(0))
            for x in masses for key in [tuple(x[j] for j in F)]}


def norm2(table, masses):
    return expected({x: v * v for x, v in table.items()}, masses)


def var(table, masses):
    mean = expected(table, masses)
    return norm2({x: table[x] - mean for x in masses}, masses)


def influence(table, masses, n, i):
    rest = tuple(j for j in range(n) if j != i)
    p = proj(table, masses, rest)
    return norm2({x: table[x] - p[x] for x in masses}, masses)


def verify(n, m, case):
    states = all_states(n, m)
    p = law(n, m)
    masses = {x: __import__('functools').reduce(lambda a,b: a*b,
               (p[i][x[i]] for i in range(n)), Q(1)) for x in states}
    f = {x: Q(R.randrange(-5, 6), R.choice([1,2,3])) for x in states}
    Fsets = [tuple(s) for k in range(n+1) for s in combinations(range(n), k)]
    true_inf = {i: influence(f, masses, n, i) for i in range(n)}
    full_var = var(f, masses)
    assert full_var <= sum(true_inf.values(), Q(0)), ('fullES', case)
    assert sum(masses.values(), Q(0)) == 1
    checks = 0
    for F in Fsets:
        pf = proj(f, masses, F)
        v = var(pf, masses)
        total = Q(0)
        for i in F:
            a = influence(pf, masses, n, i)
            total += a
            assert 0 <= a <= true_inf[i], ('contraction', case, F, i, a, true_inf[i])
            checks += 1
        assert v <= total, ('finiteES', case, F, v, total)
        assert v <= full_var, ('projection', case, F)
        checks += 2
        for j in range(n):
            if j not in F:
                assert influence(pf, masses, n, j) == 0, ('outside', case, F, j)
                checks += 1
    assert var(proj(f, masses, tuple(range(n))), masses) == full_var
    return checks, len(Fsets), any(x == 0 for row in p for x in row)


def main():
    total = count_F = zeros = 0
    for case in range(24):
        n = 2 + case % 3
        m = 2 + (case // 3) % 2
        q, nf, z = verify(n, m, case)
        total += q
        count_F += nf
        zeros += int(z)
    digest = hashlib.sha256(open(__file__, 'rb').read()).hexdigest()
    print(f'EXACT_FRACTION_AUDIT PASS seed={SEED} cases=24 finite_sets={count_F} assertions={total} zero_atom_models={zeros}')
    print(f'checker_sha256={digest}')
    print('LIMIT: finite exact model test only; NOT a proof of arbitrary L2 or Lean certification')

if __name__ == '__main__':
    main()
