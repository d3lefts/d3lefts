#!/usr/bin/env python3
"""Exact finite Chebyshev witnesses for NIGHTFALL N-UE2(2).

This checker establishes finite identities only. The Gaussian limits are printed
as mathematical predictions, NOT certified by these finite calculations.
All influence terms use original-law conditional variance (fair-bit resampling).
"""
from fractions import Fraction as Q
from itertools import product
from math import comb, exp


def chebyshev(d, x):
    assert d >= 0
    if d == 0:
        return Q(1)
    a, b = Q(1), x
    for _ in range(2, d + 1):
        a, b = b, 2*x*b-a
    return b


def witness(d):
    assert 1 <= d <= 64
    n = d*d
    vals = [chebyshev(d, Q(2*k-n, n)) for k in range(n+1)]
    assert all(-1 <= t <= 1 for t in vals)
    B = (max(vals) - min(vals)) / 2  # actual essential centered radius
    assert B > 0
    probs = [Q(comb(n, k), 2**n) for k in range(n+1)]
    mean = sum((p*t for p,t in zip(probs, vals)), Q(0))
    second = sum((p*t*t for p,t in zip(probs, vals)), Q(0))
    V = second - mean**2
    if d % 2:
        assert mean == 0 and B == 1
    # Checker A: conditional variance with one coordinate unexposed.
    p_rest = [Q(comb(n-1,k),2**(n-1)) for k in range(n)]
    M_A = sum((p_rest[k]*(vals[k+1]-vals[k])**2/4 for k in range(n)),Q(0))
    # Checker B: orthogonal projection norm identity.
    cond_second = sum((p_rest[k]*((vals[k+1]+vals[k])/2)**2 for k in range(n)),Q(0))
    M_B = second - cond_second
    assert M_A == M_B and V > 0 and M_A > 0
    # Chebyshev T_d has nonzero leading coefficient, so degree is exactly d.
    # Under multilinear reduction the top-degree Walsh coefficient is
    # 2**(d-1)*factorial(d)/n**d (d>0), which cannot cancel with lower degrees.
    ratio = V**2/(B**2*d**2*M_A)
    return n, B, mean, V, M_A, ratio


def brute(d):
    n,B,mean,V,M,ratio=witness(d)
    assert n <= 9  # independent direct cube enumeration only on small tests
    states=list(product((-1,1),repeat=n))
    value=lambda xs: chebyshev(d,Q(sum(xs),n))
    g={x:value(x) for x in states}
    avg=sum(g.values(),Q(0))/len(states)
    var=sum(((v-avg)**2 for v in g.values()),Q(0))/len(states)
    assert avg==mean and var==V
    for i in range(n):
        direct=sum((((g[x]-g[x[:i]+(-x[i],)+x[i+1:]])/2)**2 for x in states),Q(0))/len(states)
        assert direct==M
    assert B==(max(g.values())-min(g.values()))/2


def main():
    brute(1)
    brute(2)
    brute(3)
    print('PASS independent full-cube conditional-variance check for d=1,2,3')
    for d in range(1,17):
        n,B,mean,V,M,ratio=witness(d)
        print(f'd={d:2d} n={n:3d} B={float(B):.10f} V={float(V):.10f} '
              f'd^2*M={float(d*d*M):.10f} V^2/(B^2*d^2*M)={float(ratio):.12f}')
    odd=(1-exp(-2))**2/(2*(1+exp(-2)))
    even=(1-exp(-1))**4/(2*(1-exp(-2)))
    print(f'Gaussian asymptotic predictions (not verified by finite checks): '
          f'odd={odd:.12f}; even={even:.12f}')
    assert Q(1) == witness(1)[-1]
    print('PASS exact rational finite Chebyshev audit; sharp degree exponent >=2 '
          'requires the separate CLT analytic argument.')


if __name__ == '__main__':
    main()
