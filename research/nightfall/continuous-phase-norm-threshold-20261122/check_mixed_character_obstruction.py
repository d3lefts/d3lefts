#!/usr/bin/env python3
"""Independent exact finite checker for mixed-character obstruction algebra.

This is NOT a proof of a product-sphere zero theorem. It checks an algebraic
coefficient formula using (1) repeated polynomial multiplication modulo
(alpha^n,beta^n), (2) integer binomial coefficients modulo 2, and
(3) Lucas's binary no-carry condition, plus exact rational negative controls.
"""
from fractions import Fraction
from math import comb


def multiply_truncated(n, r, s, t):
    if r >= n or s >= n:
        return set()
    support = {(r, s)}
    for _ in range(t):
        nxt = set()
        for i, j in support:
            for pair in ((i + 1, j), (i, j + 1)):
                if pair[0] >= n or pair[1] >= n:
                    continue
                if pair in nxt:
                    nxt.remove(pair)
                else:
                    nxt.add(pair)
        support = nxt
    return support


def binomial_support(n, r, s, t):
    return {(r+i, s+t-i) for i in range(t+1)
            if r+i < n and s+t-i < n and comb(t, i) % 2}


def binary_support(n, r, s, t):
    return {(r+i, s+t-i) for i in range(t+1)
            if r+i < n and s+t-i < n and (i & t) == i}


def rational_circle(p):
    q = Fraction(p)
    return ((1-q*q)/(1+q*q), 2*q/(1+q*q))


def complex_product(u, v):
    a, b = u
    c, d = v
    return (a*c-b*d, a*d+b*c)


def main():
    tests = 0
    for n in range(1, 9):
        for r in range(n + 2):
            for s in range(n + 2):
                for t in range(2*n + 6):
                    a = multiply_truncated(n, r, s, t)
                    b = binomial_support(n, r, s, t)
                    c = binary_support(n, r, s, t)
                    assert a == b == c, (n, r, s, t, a, b, c)
                    tests += 1

    # Explicit zero obstruction, but NOT a zero-forcing theorem: complex
    # multiplication gives a nowhere-zero two-mixed-character map on S^1×S^1.
    assert multiply_truncated(2, 0, 0, 2) == set()

    rational_tests = 0
    params = [-5, -3, -2, -1, 0, 1, 2, 3, 5]
    for x in params:
        for y in params:
            u = rational_circle(x)
            v = rational_circle(y)
            F = complex_product(u, v)
            assert u[0]**2 + u[1]**2 == 1
            assert v[0]**2 + v[1]**2 == 1
            assert F[0]**2 + F[1]**2 == 1
            assert complex_product((-u[0], -u[1]), v) == (-F[0], -F[1])
            assert complex_product(u, (-v[0], -v[1])) == (-F[0], -F[1])
            rational_tests += 1
    print(f"PASS: {tests} exact obstruction cross-checks, "
          f"{rational_tests} rational geometric negative controls")


if __name__ == "__main__":
    main()
