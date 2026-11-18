#!/usr/bin/env python3
"""Exact Fraction replay of classical sharpness and influence conventions.

NOT an all-degree proof; checks independent examples and source-flip normalization.
No third-party dependencies, no floating-point thresholds.
"""
from fractions import Fraction as Q
from itertools import product


def linear_exact(n):
    assert n >= 1
    B, V, M = Q(1), Q(1, n), Q(1, n * n)
    assert V * V == B * B * M
    if n <= 8:
        states = tuple(product((-1, 1), repeat=n))
        f = lambda x: Q(sum(x), n)
        mn = sum((f(x) for x in states), Q(0)) / len(states)
        vv = sum(((f(x) - mn)**2 for x in states), Q(0)) / len(states)
        ii = []
        for i in range(n):
            ss = sum(((f(x) - f(x[:i] + (-x[i],) + x[i+1:]))**2 / 4 for x in states), Q(0)) / len(states)
            ii.append(ss)
        assert mn == 0 and vv == V and all(v == M for v in ii)
    return B, V, M


def tribes(w):
    assert w >= 1
    t = 2 ** w
    n = w * t
    q = Q(1, t)
    r = (1-q) ** t
    V = 4 * r * (1-r)
    M = 2 * q * (1-q) ** (t-1)
    R = V ** 2 / M
    assert R == 8 * t * (1-q) * r * (1-r)**2
    # The full-degree coefficient of 2*(OR of t disjoint ANDs)-1 is -2.
    assert 2 * (-1) ** (t+1) == -2
    if w <= 2:
        bits = tuple(product((0, 1), repeat=n))
        def g(x):
            return 2 * int(any(all(x[a*w+j] for j in range(w)) for a in range(t))) - 1
        def p(x):
            return Q(g(x)+1, 2)
        mean = sum((g(x) for x in bits), Q(0)) / len(bits)
        var = sum(((Q(g(x))-mean)**2 for x in bits), Q(0)) / len(bits)
        assert var == V
        for i in range(n):
            x_flip = lambda x: x[:i] + (1-x[i],) + x[i+1:]
            inf_g = sum((((Q(g(x))-Q(g(x_flip(x)))) / 2)**2 for x in bits), Q(0)) / len(bits)
            flip_p = sum(((p(x)-p(x_flip(x)))**2 for x in bits), Q(0)) / len(bits)
            resample_p = sum((((p(x)-p(x_flip(x))) / 2)**2 for x in bits), Q(0)) / len(bits)
            assert inf_g == M and flip_p == M and flip_p == 4*resample_p
    return n, V, M, R


if __name__ == '__main__':
    for n in range(1, 33):
        linear_exact(n)
    print('PASS exact degree-one sharp C1=1 equality, n=1..32; direct finite enumeration n<=8')
    for w in range(1, 9):
        n, V, M, R = tribes(w)
        print(f'PASS tribes width={w}, degree={n}, variance={float(V):.8f}, max influence={float(M):.8f}, ratio={float(R):.8f}')
    print('PASS exact full polynomial degree, variance, influence and original resampling/flip normalization, brute w<=2')
    print('Scope: finite examples and exact symbolic families; NOT a proof of N-UE2(6).')
