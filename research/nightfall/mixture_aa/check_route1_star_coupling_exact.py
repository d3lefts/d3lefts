#!/usr/bin/env python3
"""Independent exact-rational regression for Route 1's finite star-coupling proof.

Tests are finite counterexample searches and algebraic witnesses, NOT a universal
theorem, Lean certification, or external proof review. Stdlib only.
"""
from fractions import Fraction as F
from itertools import product, combinations
from random import Random
from hashlib import sha256
from pathlib import Path
import argparse


def law(k, rng):
    counts = [rng.randrange(5) for _ in range(k)]
    if not any(counts):
        counts[rng.randrange(k)] = 1
    return [F(a, sum(counts)) for a in counts]


def max_joint(p, q):
    """Exact maximal coupling matrix, including zero atoms."""
    k = len(p)
    m = [min(p[a], q[a]) for a in range(k)]
    rp = [p[a] - m[a] for a in range(k)]
    rq = [q[a] - m[a] for a in range(k)]
    tv = sum(rp, F(0))
    assert tv == sum(rq, F(0))
    joint = [[(m[a] if a == b else F(0)) +
              (rp[a] * rq[b] / tv if tv else F(0))
              for b in range(k)] for a in range(k)]
    assert all(sum(joint[a], F(0)) == p[a] for a in range(k))
    assert all(sum((joint[a][b] for a in range(k)), F(0)) == q[b] for b in range(k))
    assert sum((joint[a][b] for a in range(k) for b in range(k) if a != b), F(0)) == tv
    return joint, tv


def star_kernel(p, joint, q):
    k = len(p)
    ker = [[joint[a][b] / p[a] if p[a] else q[b] for b in range(k)]
           for a in range(k)]
    assert all(sum(row, F(0)) == 1 for row in ker)
    assert all(sum((p[a] * ker[a][b] for a in range(k)), F(0)) == q[b] for b in range(k))
    return ker


def ftable(n, k, d, rng):
    words = list(product(range(k), repeat=n))
    coeff = []
    for size in range(1, d + 1):
        for ids in combinations(range(n), size):
            for syms in product(range(k), repeat=size):
                coeff.append((ids, syms, F(rng.randint(-3, 3), 13)))
    raw = {x: sum((c for ids, syms, c in coeff
                   if all(x[i] == a for i, a in zip(ids, syms))), F(0)) for x in words}
    low, high = min(raw.values()), max(raw.values())
    return {x: (v - low) / (high - low) if high > low else F(0)
            for x, v in raw.items()}


def osc_sum(f, x, k):
    out = F(0)
    for j in range(len(x)):
        vals = [f[x[:j] + (a,) + x[j + 1:]] for a in range(k)]
        out += max(vals) - min(vals)
    return out


def one_case(n, k, m, d, seed):
    rng = Random(seed * 100003 + n * 97 + k * 11 + m * 13 + d)
    pi = law(m, rng)
    sources = [[law(k, rng) for _ in range(n)] for _ in range(m)]
    bar = [[sum((pi[t] * sources[t][j][a] for t in range(m)), F(0))
            for a in range(k)] for j in range(n)]
    f = ftable(n, k, d, rng)
    words = list(product(range(k), repeat=n))
    assert all(osc_sum(f, x, k) <= 2 * d * d for x in words)
    checks = len(words)
    joints, tvs, kernels = [], [], []
    for t in range(m):
        jj, vv, kk = [], [], []
        for j in range(n):
            joint, tv = max_joint(bar[j], sources[t][j])
            ker = star_kernel(bar[j], joint, sources[t][j])
            jj.append(joint)
            vv.append(tv)
            kk.append(ker)
            checks += 4 * k + 2
        joints.append(jj)
        tvs.append(vv)
        kernels.append(kk)

    # Verify all component/reference marginals are simultaneously realized
    # by the SAME finite seed alphabet U_j=(bar symbol, tuple of component symbols).
    for j in range(n):
        for a in range(k):
            for bs in product(range(k), repeat=m):
                weight = bar[j][a]
                for t in range(m):
                    weight *= kernels[t][j][a][bs[t]]
                assert weight >= 0
                checks += 1
        for t in range(m):
            for a in range(k):
                for b in range(k):
                    marginal = F(0)
                    for bs in product(range(k), repeat=m):
                        if bs[t] == b:
                            weight = bar[j][a]
                            for s in range(m):
                                weight *= kernels[s][j][a][bs[s]]
                            marginal += weight
                    assert marginal == joints[t][j][a][b]
                    checks += 1

    Jstar = max(sum((pi[t] * tvs[t][j] ** 2 for t in range(m)), F(0))
                for j in range(n))
    for eta in (F(1, 4), F(1, 2), F(3, 4)):
        total = large = small = F(0)
        large_freq = [sum((pi[t] for t in range(m) if tvs[t][j] > eta), F(0))
                      for j in range(n)]
        for t in range(m):
            L = {j for j in range(n) if tvs[t][j] > eta}
            states = []
            for j in range(n):
                states.append([(a, b, joints[t][j][a][b])
                               for a in range(k) for b in range(k)
                               if joints[t][j][a][b] > 0])
            for pairs in product(*states):
                x = tuple(a for a, _, _ in pairs)
                y = tuple(b for _, b, _ in pairs)
                z = tuple(y[j] if j in L else x[j] for j in range(n))
                mass = pi[t]
                for _, _, w in pairs:
                    mass *= w
                total += mass * abs(f[x] - f[y])
                large += mass * abs(f[x] - f[z])
                small += mass * abs(f[z] - f[y])
                checks += 1
        assert total <= large + small
        assert large <= n * max(large_freq)
        assert small <= 2 * d * d * eta
        assert max(large_freq) <= Jstar / eta**2
        assert total <= n * Jstar / eta**2 + 2 * d * d * eta
        checks += 5
    return checks


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--seeds', type=int, default=12)
    args = parser.parse_args()
    cases = ((3, 3, 3, 2), (4, 2, 4, 2), (4, 2, 3, 3))
    total = 0
    for n, k, m, d in cases:
        for seed in range(args.seeds):
            total += one_case(n, k, m, d, seed)
    print(f"PASS {total} exact rational checks over {len(cases) * args.seeds} "
          "star-coupled finite mixtures, including zero atoms.")
    print("SHA256", sha256(Path(__file__).read_bytes()).hexdigest())


if __name__ == '__main__':
    main()
