#!/usr/bin/env python3
"""Independent exact-rational falsification screen for greedy Kaczmarz.

Standard-library Fraction arithmetic, fixed seed, 240 consistent systems,
12 projections per system; does not constitute a universal proof.
"""
from fractions import Fraction as F
from random import Random


def dot(a, b):
    return sum((x * y for x, y in zip(a, b)), F(0))


def sq(v):
    return dot(v, v)


def add_scaled(x, row, c):
    return [xi + c * ai for xi, ai in zip(x, row)]


def check(A, truth, initial, K):
    b = [dot(row, truth) for row in A]
    den = [sq(row) for row in A]
    W = sum(den, F(0))
    assert W > 0
    y = list(initial)
    init_energy = sq([u - v for u, v in zip(initial, truth)])
    cumulative = F(0)
    smallest = None
    for step in range(K):
        residual = [dot(row, y) - bi for row, bi in zip(A, b)]
        rho2 = sq(residual)
        smallest = rho2 if smallest is None else min(smallest, rho2)
        eligible = [(residual[i] ** 2 / den[i], i) for i in range(len(A)) if den[i]]
        gain, idx = max(eligible)
        assert gain * W >= rho2, ('weighted-max', step, A, y)
        before = sq([u - v for u, v in zip(y, truth)])
        y = add_scaled(y, A[idx], -residual[idx] / den[idx])
        after = sq([u - v for u, v in zip(y, truth)])
        assert before - after == gain, ('pythagoras', step, A, y)
        cumulative += gain
        assert cumulative == init_energy - after, ('telescope', step, A, y)
        assert after >= 0
    assert smallest * K <= W * init_energy, ('best-iterate', A, initial, truth)
    return smallest, W * init_energy / K


def main():
    rng = Random(20261111)
    cases = 0
    for n in range(1, 5):
        for case in range(60):
            m = n + rng.randint(0, 2)
            A = [[F(rng.randint(-3, 3)) for _ in range(n)] for _ in range(m)]
            if not any(sq(r) for r in A):
                A[0][0] = F(1)
            truth = [F(rng.randint(-3, 3)) for _ in range(n)]
            initial = [F(rng.randint(-3, 3)) for _ in range(n)]
            check(A, truth, initial, 12)
            cases += 1
    # Sharp coefficient for best-iterate bound at K=1:
    # one-dimensional diagonal system attains equality.
    z, bound = check([[F(2)]], [F(1)], [F(0)], 1)
    assert z == bound == 4 and z > bound / 2
    print(f'PASS: {cases} exact-rational random systems; 12 projections each')
    print('PASS: Pythagoras, weighted-max, telescoping, all-prefix best iterate')
    print('PASS: one-dimensional sharpness/negative control (coefficient 1/2 fails)')


if __name__ == '__main__':
    main()
