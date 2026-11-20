#!/usr/bin/env python3
"""Independent exact Fraction audit of Route 1's posterior Phi drift and variance decomposition.

Finite regression only. No universal or Lean theorem is claimed.
"""
from fractions import Fraction as F
from itertools import product
from random import Random
from hashlib import sha256
from pathlib import Path
import argparse


def law(k, rng):
    v = [rng.randrange(5) for _ in range(k)]
    if not any(v): v[rng.randrange(k)] = 1
    return [F(z, sum(v)) for z in v]


def ftable(n, k, rng):
    words = list(product(range(k), repeat=n))
    a = [[F(rng.randrange(-5, 6), 13) for _ in range(k)] for _ in range(n)]
    b = {(i, j): [[F(rng.randrange(-5, 6), 17) for _ in range(k)] for _ in range(k)]
         for i in range(n) for j in range(i + 1, n)}
    raw = {x: sum((a[i][x[i]] for i in range(n)), F(0)) +
           sum((b[i, j][x[i]][x[j]] for i, j in b), F(0)) for x in words}
    lo, hi = min(raw.values()), max(raw.values())
    return {x: (v - lo) / (hi - lo) if hi > lo else F(0) for x, v in raw.items()}


def one_case(n, k, m, seed):
    rng = Random(20261119 + 131 * seed + 7 * n + 11 * k + 19 * m)
    pi0 = law(m, rng)
    p = [[law(k, rng) for _ in range(n)] for _ in range(m)]
    f = ftable(n, k, rng)
    count = 0

    def product_mass(t, fixed):
        z = F(1)
        for j, a in fixed.items(): z *= p[t][j][a]
        return z

    def posterior(fixed):
        w = [pi0[t] * product_mass(t, fixed) for t in range(m)]
        s = sum(w, F(0))
        return [v / s for v in w] if s else None

    def free_words(fixed):
        free = [j for j in range(n) if j not in fixed]
        for vals in product(range(k), repeat=len(free)):
            x = [fixed.get(j, 0) for j in range(n)]
            for j, a in zip(free, vals): x[j] = a
            yield tuple(x), free

    def mean_var(t, fixed):
        E = E2 = F(0)
        for x, free in free_words(fixed):
            mass = F(1)
            for j in free: mass *= p[t][j][x[j]]
            E += mass * f[x]
            E2 += mass * f[x] ** 2
        return E, E2 - E * E

    def Lj(t, fixed, j):
        assert j not in fixed
        out = F(0)
        for x, free in free_words(fixed):
            mass = F(1)
            for h in free: mass *= p[t][h][x[h]]
            for b in range(k):
                y = x[:j] + (b,) + x[j + 1:]
                out += mass * p[t][j][b] * abs(f[x] - f[y])
        return out

    def phi(pi, fixed):
        return sum((pi[t] * Lj(t, fixed, j) for t in range(m)
                    for j in range(n) if j not in fixed), F(0))

    for prefix in range(n):
        for vals in product(range(k), repeat=prefix):
            fixed = dict(enumerate(vals))
            pi = posterior(fixed)
            if pi is None: continue
            Phi = phi(pi, fixed)
            assert 0 <= Phi <= 8  # d=2: 2d^2=8
            count += 1
            for j in range(prefix, n):
                child_phi = F(0)
                drop = sum((pi[t] * Lj(t, fixed, j) for t in range(m)), F(0))
                E = sum((pi[t] * mean_var(t, fixed)[0] for t in range(m)), F(0))
                E2 = sum((pi[t] * (mean_var(t, fixed)[1] + mean_var(t, fixed)[0]**2)
                          for t in range(m)), F(0))
                Var = E2 - E**2
                child_var = child_mean2 = F(0)
                child_mean = F(0)
                for b in range(k):
                    mass = sum((pi[t] * p[t][j][b] for t in range(m)), F(0))
                    if not mass: continue
                    next_fixed = {**fixed, j: b}
                    next_pi = [pi[t] * p[t][j][b] / mass for t in range(m)]
                    child_phi += mass * phi(next_pi, next_fixed)
                    mu_b = sum((next_pi[t] * mean_var(t, next_fixed)[0] for t in range(m)), F(0))
                    m2_b = sum((next_pi[t] * (mean_var(t, next_fixed)[1] + mean_var(t, next_fixed)[0]**2)
                                for t in range(m)), F(0))
                    child_var += mass * (m2_b - mu_b**2)
                    child_mean += mass * mu_b
                    child_mean2 += mass * mu_b**2
                assert Phi - child_phi == drop, ('Phi drift', n, k, m, seed, fixed, j)
                assert E == child_mean, ('tower mean', n, k, m, seed, fixed, j)
                assert Var == child_var + child_mean2 - child_mean**2, ('variance law', n, k, m, seed, fixed, j)
                count += 3
    return count


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--seeds', type=int, default=12)
    args = parser.parse_args()
    total = 0
    for n, k, m in ((3, 3, 3), (4, 2, 4), (4, 2, 3)):
        for seed in range(args.seeds): total += one_case(n, k, m, seed)
    print(f'PASS {total} exact rational posterior Phi/variance assertions across {3*args.seeds} zero-atom mixtures')
    print('SHA256', sha256(Path(__file__).read_bytes()).hexdigest())


if __name__ == '__main__': main()
