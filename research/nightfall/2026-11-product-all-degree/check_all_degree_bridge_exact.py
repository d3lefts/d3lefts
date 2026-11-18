#!/usr/bin/env python3
"""Independent exact-rational finite-law audit of all-degree residual bridges.

This is NOT a proof. It uses two independently programmed representations
(Mobius conditional expectations and products of original-law heat baths),
positive/negative controls, zero atoms, and deliberately wrong uniform
weights. Requires stdlib only. Seed and case counts are fixed.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from random import Random

SEED = 20261118
rng = Random(SEED)


def subsets(items):
    items = tuple(items)
    return (set(c) for n in range(len(items) + 1)
            for c in combinations(items, n))


def engine(n, m, laws):
    words = list(product(range(m), repeat=n))

    def avg(i, f):
        return {x: sum((laws[i][a] * f[x[:i] + (a,) + x[i + 1:]]
                        for a in range(m)), Q(0)) for x in words}

    def delta(i, f):
        g = avg(i, f)
        return {x: f[x] - g[x] for x in words}

    def cond_exp(S, f):
        # Entire original product law, NOT a uniform substitution.
        return {x: sum((weight(y) * f[tuple(x[i] if i in S else y[i]
                                            for i in range(n))] for y in words),
                        Q(0)) for x in words}

    def weight(y):
        w = Q(1)
        for i, a in enumerate(y):
            w *= laws[i][a]
        return w

    def mobius(S, f):
        out = {x: Q(0) for x in words}
        for U in subsets(S):
            g = cond_exp(U, f)
            sign = (-1) ** (len(S) - len(U))
            for x in words:
                out[x] += sign * g[x]
        return out

    def hilbert(S, f):
        g = f.copy()
        for i in range(n):
            if i not in S:
                g = avg(i, g)
        for i in S:
            g = delta(i, g)
        return g

    return words, avg, delta, mobius, hilbert


def law(n, m):
    rows = []
    for _ in range(n):
        raw = [rng.randrange(5) for _ in range(m)]
        if sum(raw) == 0:
            raw[0] = 1
        rows.append([Q(v, sum(raw)) for v in raw])
    return rows


def synthetic_low_degree(words, n, m, d):
    f = {x: Q(0) for x in words}
    for S in subsets(range(n)):
        if len(S) > d:
            continue
        symbol = {i: rng.randrange(m) for i in S}
        c = Q(rng.randrange(-3, 4))
        for x in words:
            if all(x[i] == symbol[i] for i in S):
                f[x] += c
    return f


def iszero(g):
    return all(v == 0 for v in g.values())


def main():
    cases = 0
    found_zeros = 0
    for n, m in [(1, 2), (2, 3), (3, 2), (3, 3), (4, 3)]:
        for _ in range(6):
            p = law(n, m)
            words, avg, delta, mobius, hilbert = engine(n, m, p)
            for d in range(n + 1):
                f = synthetic_low_degree(words, n, m, d)
                for S in subsets(range(n)):
                    # Independent Mobius and projection/residual formulae.
                    es = mobius(S, f)
                    assert es == hilbert(S, f), (n, m, d, S, "ANOVA discrepancy")
                    g = f.copy()
                    for i in S:
                        g = delta(i, g)
                    if iszero(g):
                        found_zeros += 1
                        assert iszero(es), (n, m, d, S, "residual bridge failure")
                    if len(S) > d:
                        assert iszero(g), (n, m, d, S, "degree failure")
                    cases += 1

    # A pointwise table on zero atoms is NOT determined by its L² class.
    zero_law = [[Q(1), Q(0)], [Q(1, 2), Q(1, 2)]]
    words, _, delta, _, _ = engine(2, 2, zero_law)
    spike = {x: Q(int(x[0] == 1)) for x in words}
    source_energy = sum((zero_law[0][x[0]] * zero_law[1][x[1]] *
                         spike[x] ** 2 for x in words), Q(0))
    assert source_energy == 0
    assert delta(0, spike)[(1, 0)] != 0  # Prohibits invalid a.e. -> pointwise.

    # Mutation control: true nonuniform heat bath must not be silently
    # replaced by uniform-letter averaging.
    p = [[Q(1, 4), Q(3, 4)]]
    words, avg, _, _, _ = engine(1, 2, p)
    f = {(0,): Q(0), (1,): Q(1)}
    assert avg(0, f)[(0,)] == Q(3, 4)
    assert avg(0, f)[(0,)] != Q(1, 2)

    print(f"PASS seed={SEED} exact_rational_cases={cases} "
          f"zero_residual_controls={found_zeros} "
          "null_atom_obstruction=confirmed wrong_uniform_mutant=rejected")


if __name__ == "__main__":
    main()
