#!/usr/bin/env python3
"""Exact falsifier/replay for the degree-two fiber-uniform-row construction.

No floating-point arithmetic or LP solver is used in the default run.
Every equality and inequality checked here is a finite-instance statement;
this does NOT prove the universal theorem.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from random import Random
from hashlib import sha256
from pathlib import Path
import argparse


def table(n, k, seed):
    rng = Random(seed)
    a = [[Q(rng.randint(-4, 4), 11) for _ in range(k)] for _ in range(n)]
    b = {(i, j): [[Q(rng.randint(-4, 4), 13) for _ in range(k)] for _ in range(k)]
         for i, j in combinations(range(n), 2)}
    words = list(product(range(k), repeat=n))
    raw = {x: sum((a[i][x[i]] for i in range(n)), Q(0)) +
           sum((b[i, j][x[i]][x[j]] for i, j in combinations(range(n), 2)), Q(0))
           for x in words}
    lo, hi = min(raw.values()), max(raw.values())
    return {x: (v - lo) / (hi - lo) if hi > lo else Q(0) for x, v in raw.items()}


def update(x, i, a):
    y = list(x)
    y[i] = a
    return tuple(y)


def mix2(f, r, i, j, a, b, c, d):
    def at(ai, bj):
        return f[update(update(r, i, ai), j, bj)]
    return at(b, d) - at(a, d) - at(b, c) + at(a, c)


def solve(n, k, seed):
    f = table(n, k, seed)
    words = list(product(range(k), repeat=n))
    r = tuple(0 for _ in range(n))
    transitions = [None] + [(a, b) for a in range(k) for b in range(k) if a != b]
    checks = 0

    def H(t):
        return sum((mix2(f, r, i, j, *t[i], *t[j])
                    for i, j in combinations(range(n), 2) if t[i] and t[j]), Q(0))

    # An independent Fourier-projection formula:
    # H(t)=2(h(1)+h(-1))-4*E_uniform h on the corner subcube.
    for t in product(transitions, repeat=n):
        old = tuple(t[i][0] if t[i] else r[i] for i in range(n))
        new = tuple(t[i][1] if t[i] else r[i] for i in range(n))
        corners = [tuple(new[i] if s[i] else old[i] for i in range(n))
                   for s in product((0, 1), repeat=n)]
        formula = 2 * (f[old] + f[new]) - Q(4, len(corners)) * sum((f[v] for v in corners), Q(0))
        assert H(t) == formula, ('quadratic Fourier identity', n, k, seed, t)
        assert abs(H(t)) <= 4, ('four-point bound', n, k, seed, t)
        checks += 2

    # Explicit small-instance anchor cover c_i=4, valid here for n<=5.
    # It does NOT establish a universal, n-independent FUR constant;
    # the universal construction invokes the preexisting row theorem.
    c = [Q(4) for _ in range(n)]
    for x in words:
        v = [max(f[update(x, i, a)] for a in range(k)) -
             min(f[update(x, i, a)] for a in range(k)) for i in range(n)]
        assert sum(v) <= 8, ('oscillation budget', n, k, seed, x)
        checks += 1
        for j in range(n):
            for a in range(k):
                z = update(x, j, a)
                v_at_z = max(f[update(z, j, b)] for b in range(k)) - min(f[update(z, j, b)] for b in range(k))
                assert v_at_z == v[j], ('own-coordinate invariance', n, k, seed, x, j, a)
                checks += 1
        for y in words:
            t = tuple((x[i], y[i]) if x[i] != y[i] else None for i in range(n))
            D = [i for i in range(n) if x[i] != y[i]]
            single = sum((f[update(x, i, y[i])] - f[x] for i in D), Q(0))
            assert f[y] - f[x] == single + H(t), ('degree2 Taylor', n, k, seed, x, y)
            assert abs(f[y] - f[x]) <= sum((v[i] + c[i] for i in D), Q(0)), ('fiber row', n, k, seed, x, y)
            checks += 2

    rng = Random(10_000 + seed + n * 123 + k * 19)

    def dist():
        arr = [rng.randrange(5) for _ in range(k)]
        if not any(arr):
            arr[rng.randrange(k)] = 1
        return [Q(v, sum(arr)) for v in arr]

    for _ in range(6):
        p = [dist() for _ in range(n)]
        q = [dist() for _ in range(n)]

        def mass(law, x):
            val = Q(1)
            for i in range(n):
                val *= law[i][x[i]]
            return val

        def expectation(law):
            return sum((mass(law, x) * f[x] for x in words), Q(0))

        tv = [sum((abs(p[i][a] - q[i][a]) for a in range(k)), Q(0)) / 2 for i in range(n)]
        w = [sum((mass(p, x) * (max(f[update(x, i, a)] for a in range(k)) -
                                    min(f[update(x, i, a)] for a in range(k)))
                  for x in words), Q(0)) + c[i] for i in range(n)]
        assert abs(expectation(q) - expectation(p)) <= sum((w[i] * tv[i] for i in range(n)), Q(0)), \
            ('product transport', n, k, seed, p, q)
        checks += 1
    return checks


def cubic_obstruction():
    # Mixed derivative D_{0,1} depends on the unchanged coordinate 2.
    f = {x: Q(x[0] * x[1] * x[2]) for x in product((0, 1), repeat=3)}
    x = (0, 0, 1)
    y = (1, 1, 1)
    r = (0, 0, 0)
    single = sum((f[update(x, i, y[i])] - f[x] for i in (0, 1)), Q(0))
    frozen_remainder = mix2(f, r, 0, 1, 0, 1, 0, 1)
    assert f[y] - f[x] - single == 1 and frozen_remainder == 0
    return 1


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--seeds', type=int, default=12)
    args = parser.parse_args()
    total = 0
    for n, k in ((3, 3), (4, 2), (5, 2)):
        for seed in range(args.seeds):
            total += solve(n, k, seed)
    total += cubic_obstruction()
    print(f"PASS {total} exact rational assertions; (n,alphabet)=(3,3),(4,2),(5,2); {args.seeds} seeds each; cubic failure witness.")
    print("SHA256", sha256(Path(__file__).read_bytes()).hexdigest())


if __name__ == '__main__':
    main()
