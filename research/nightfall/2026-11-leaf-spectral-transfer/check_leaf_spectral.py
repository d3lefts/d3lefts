#!/usr/bin/env python3
"""Independent exact finite controls for NIGHTFALL leaf-spectral reduction.

Checks a Hilbert counterexample using direct product sums and verifies
Parseval / resampling influence identities for randomly chosen low-degree,
heterogeneous leaf-section coefficient arrays. Does not prove Q2 or the
unrestricted cubic influence theorem.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random

RNG = Random(20261111)
WALSH = ((1, 1, -1, -1), (1, -1, 1, -1), (1, -1, -1, 1))


def average(values):
    vals = list(values)
    return sum(vals, Q(0)) / len(vals)


def control_counterexample(n):
    """G(X)(y) = X_y - average_i X_i, H=L2_0(uniform [n])."""
    states = list(product((-1, 1), repeat=n))

    def G(x, y):
        return Q(x[y]) - Q(sum(x), n)

    w = average(G(x, y)**2 for x in states for y in range(n))
    assert w == Q(n - 1, n), (n, 'variance', w)
    for i in range(n):
        def flip(x):
            v = list(x)
            v[i] *= -1
            return tuple(v)
        j = average((G(x, y) - G(flip(x), y))**2 / 4
                    for x in states for y in range(n))
        assert j == Q(n - 1, n*n), (n, 'control influence', j)
    assert all(average(G(x, y) for y in range(n)) == 0 for x in states)
    assert all(average(G(x, y)**2 for y in range(n)) <= 1 for x in states)
    return w


def selector_trial(n, t):
    """Verify direct resampling against finite leaf-spectrum coefficient sums."""
    k_count, a_count = 2, 3
    states = list(product((-1, 1), repeat=n))
    leaves = list(product(range(4), repeat=k_count))
    # Every control coefficient is a polynomial of degree at most two.
    polys = []
    for _ in range(k_count*a_count):
        const = RNG.randrange(-2, 3)
        lin = [RNG.randrange(-2, 3) for _ in range(n)]
        pair = {(i, j): RNG.randrange(-2, 3)
                for i in range(n) for j in range(i+1, n)}
        polys.append((const, lin, pair))

    def coeff(k, a, x):
        c, lin, pair = polys[k*a_count + a]
        return Q(c + sum(lin[i]*x[i] for i in range(n)) +
                 sum(v*x[i]*x[j] for (i, j), v in pair.items()), 20)

    def piece(k, x, y):
        return sum((coeff(k, a, x)*WALSH[a][y] for a in range(a_count)), Q(0))

    def f(x, ys):
        return sum((piece(k, x, ys[k]) for k in range(k_count)), Q(0))

    allvals = [f(x, ys) for x in states for ys in leaves]
    assert average(allvals) == 0
    V = average(v*v for v in allvals)
    direct_energy = sum((average(coeff(k, a, x)**2 for x in states)
                         for k in range(k_count) for a in range(a_count)), Q(0))
    tail = sum((average(coeff(k, a, x)**2 for x in states)
                for k in range(k_count) for a in range(t, a_count)), Q(0))
    selected = direct_energy - tail
    assert V == selected + tail
    B = max(abs(v) for v in allvals)
    # Width identity for independent leaves and exact f-bound.
    for x in states:
        widths = sum(max(piece(k, x, y) for y in range(4)) -
                     min(piece(k, x, y) for y in range(4))
                     for k in range(k_count))
        assert widths <= 2*B
    for k in range(k_count):
        direct = average(
            (f(x, ys) - f(x, ys[:k] + (z,) + ys[k+1:]))**2 / 2
            for x in states for ys in leaves for z in range(4))
        expected = sum((average(coeff(k, a, x)**2 for x in states)
                        for a in range(a_count)), Q(0))
        assert direct == expected, ('leaf influence', direct, expected)
    for i in range(n):
        direct = average(
            (f(x, ys) - f(x[:i] + (-x[i],) + x[i+1:], ys))**2 / 4
            for x in states for ys in leaves)
        expected = sum((average(
            (coeff(k, a, x) - coeff(k, a, x[:i] + (-x[i],) + x[i+1:]))**2 / 4
            for x in states) for k in range(k_count) for a in range(a_count)), Q(0))
        assert direct == expected, ('control influence', direct, expected)
    return V


def main():
    counterexamples = [control_counterexample(n) for n in range(2, 9)]
    tests = 0
    for n in (2, 3, 4):
        for t in (1, 2, 3):
            for _ in range(5):
                selector_trial(n, t)
                tests += 1
    print('PASS: exact Hilbert obstruction for n=2,...,8:', counterexamples)
    print('PASS: exact spectral energy and direct-resampling controls:', tests)
    print('SCOPE: finite identities only; Q2 and universal cubic exponent two remain unproved')


if __name__ == '__main__':
    main()
