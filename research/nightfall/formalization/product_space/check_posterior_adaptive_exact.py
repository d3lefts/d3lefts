#!/usr/bin/env python3
"""Independent exact-fraction audit of posterior resampling and adaptive descent.

All nonconstant Boolean functions on two and three biased bits; every partial
observation state. Distinct implementations verify the conditional law, directed
resampling influence, Hoeffding-Moebius energy, and the whole Markov evolution.
This is a falsification check, not a proof of universal correctness.
"""
from fractions import Fraction as F
from itertools import product, combinations
from math import prod


def verify(n, biases):
    X = list(product((0, 1), repeat=n))
    P = [{0: 1 - q, 1: q} for q in biases]
    W = {x: prod(P[i][x[i]] for i in range(n)) for x in X}
    assert sum(W.values()) == 1
    states = list(product((None, 0, 1), repeat=n))
    cache = {}
    count = dict(functions=0, states=0, posterior_values=0, rounds=0)

    def dist(s):
        denom = prod(P[i][v] for i, v in enumerate(s) if v is not None)
        return {x: W[x] / denom if all(s[i] is None or s[i] == x[i] for i in range(n))
                else F(0) for x in X}

    def replace(x, j, a):
        return x[:j] + (a,) + x[j + 1:]

    for bits in product((0, 1), repeat=2 ** n):
        if len(set(bits)) < 2:
            continue
        g = dict(zip(X, bits))
        count['functions'] += 1
        cache.clear()

        def summary(s):
            if s in cache:
                return cache[s]
            m = dist(s)
            I = [F(0) if s[j] is not None else
                 sum((m[x] * P[j][a] for x in X for a in (0, 1)
                      if g[x] and not g[replace(x, j, a)]), F(0))
                 for j in range(n)]
            mean = sum((m[x] * g[x] for x in X), F(0))
            V = mean * (1 - mean)
            T = sum(I)
            cache[s] = (V, T, I)
            return V, T, I

        for s in states:
            m = dist(s)
            free = [i for i in range(n) if s[i] is None]
            V, T, I = summary(s)
            components = {}
            d = 0
            for r in range(len(free) + 1):
                for S in combinations(free, r):
                    means = {}
                    for x in X:
                        ys = [y for y in X if all(x[k] == y[k] for k in S)]
                        weight = sum((m[y] for y in ys), F(0))
                        means[x] = (sum((m[y] * g[y] for y in ys), F(0)) / weight
                                    if weight > 0 else F(0))
                    h = {x: means[x] -
                         sum((components[R][0][x] for k in range(r)
                              for R in combinations(S, k)), F(0))
                         for x in X}
                    E = sum((m[x] * h[x] ** 2 for x in X), F(0))
                    components[S] = (h, E)
                    if E:
                        d = max(d, r)
            assert sum((E for S, (_, E) in components.items() if S), F(0)) == V
            assert sum((len(S) * E for S, (_, E) in components.items()), F(0)) == T
            if V:
                assert 1 <= d <= len(free) and V <= T <= d * V
            else:
                assert T == 0
            count['states'] += 1
            for j in free:
                expected = F(0)
                for a in (0, 1):
                    updated = list(s)
                    updated[j] = a
                    updated = tuple(updated)
                    posterior = {x: m[x] / P[j][a] if x[j] == a else F(0)
                                 for x in X}
                    assert posterior == dist(updated)
                    nextI = [
                        F(0) if k == j or s[k] is not None else
                        sum((posterior[x] * P[k][v] for x in X for v in (0, 1)
                             if g[x] and not g[replace(x, k, v)]), F(0))
                        for k in range(n)]
                    assert nextI == summary(updated)[2]
                    expected += P[j][a] * sum(nextI)
                    count['posterior_values'] += 1
                assert expected == T - I[j]

        nu = {s: F(1) if all(v is None for v in s) else F(0) for s in states}
        V0, T0, _ = summary((None,) * n)
        rho = F(1) - F(1, n ** 3)
        for t in range(n + 1):
            assert sum(nu.values()) == 1
            ET = sum((nu[s] * summary(s)[1] for s in states), F(0))
            EV = sum((nu[s] * summary(s)[0] for s in states), F(0))
            assert EV <= ET <= rho ** t * T0
            assert EV <= n * V0 * rho ** t
            count['rounds'] += 1
            if t == n:
                break
            next_nu = {s: F(0) for s in states}
            for s, mass in nu.items():
                if not mass:
                    continue
                free = [j for j in range(n) if s[j] is None]
                if not free:
                    next_nu[s] += mass
                    continue
                for j in free:
                    for a in (0, 1):
                        next_s = list(s)
                        next_s[j] = a
                        next_nu[tuple(next_s)] += mass * F(1, len(free)) * P[j][a]
            nu = next_nu
    print(f"n={n}: {count}")
    return count


def main():
    x = verify(2, [F(1, 4), F(3, 5)])
    y = verify(3, [F(1, 4), F(2, 5), F(3, 4)])
    assert x['functions'] + y['functions'] == 268
    assert x['posterior_values'] + y['posterior_values'] == 13884
    print("PASS: 268 exhaustive functions, 6984 conditional states, 13884 posteriors")


if __name__ == '__main__':
    main()
