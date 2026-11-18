#!/usr/bin/env python3
"""Exact rational finite witnesses for the sharp-constant UE2(2, C=1) conjecture.

No conjectural inequality is assumed. The finite checker verifies rational
Chebyshev/Bernoulli statistics; the n->infinity theorem is an analytic
delta-method argument, not established by finite runs.
"""
from fractions import Fraction as F
from itertools import product


def cheb(d, z):
    if d == 0:
        return F(1)
    a, b = F(1), z
    for _ in range(2, d + 1):
        a, b = b, 2*z*b - a
    return b


def chebprime(d, z):
    assert d >= 1
    if d == 1:
        return F(1)
    a, b = F(1), 2*z
    for _ in range(2, d):
        a, b = b, 2*z*b - a
    return d*b


def binomial_weights(n, p):
    assert 0 < p < 1
    r = [(1-p)**n]
    for k in range(n):
        r.append(r[-1]*F(n-k, k+1)*p/(1-p))
    assert len(r) == n+1 and sum(r) == 1
    return r


def certificate(d, n, p):
    assert 1 <= d <= n and isinstance(p, F) and 0 < p < 1
    y = [cheb(d, F(2*k-n, n)) for k in range(n+1)]
    assert all(-1 <= v <= 1 for v in y)
    B = (max(y)-min(y))/2
    assert B > 0
    w = binomial_weights(n, p)
    mean = sum((w[k]*y[k] for k in range(n+1)), F(0))
    V = sum((w[k]*(y[k]-mean)**2 for k in range(n+1)), F(0))
    w_other = binomial_weights(n-1, p)
    M = p*(1-p)*sum((w_other[k]*(y[k+1]-y[k])**2 for k in range(n)), F(0))
    # Independently reconstruct resampling influence via the conditional-
    # expectation Pythagorean identity, not the squared-difference formula.
    M_cond = sum((w_other[k]*(p*y[k+1]**2+(1-p)*y[k]**2 -
                (p*y[k+1]+(1-p)*y[k])**2) for k in range(n)), F(0))
    assert M == M_cond and V > 0 and M > 0
    ratio = V**2/(B**2*M*d*d)
    deriv = 2*chebprime(d, 2*p-1)
    limit_ratio = p*(1-p)*deriv*deriv/(d*d)
    spectral_avg = n*M/V  # sum_i I_i / V = mean Hoeffding level
    return B, V, M, ratio, limit_ratio, spectral_avg


def brute(d, n, p):
    assert n <= 7
    B,V,M,_,_,_ = certificate(d, n, p)
    states = list(product((0,1), repeat=n))
    vals = {}
    weights = {}
    for x in states:
        k = sum(x)
        vals[x] = cheb(d,F(2*k-n,n))
        weights[x] = p**k*(1-p)**(n-k)
    assert sum(weights.values()) == 1
    avg = sum((weights[x]*vals[x] for x in states), F(0))
    VV = sum((weights[x]*(vals[x]-avg)**2 for x in states), F(0))
    assert V == VV and B == (max(vals.values())-min(vals.values()))/2
    for i in range(n):
        ms = F(0)
        for other in product((0,1),repeat=n-1):
            x0 = other[:i]+(0,)+other[i:]
            x1 = other[:i]+(1,)+other[i:]
            w = p**sum(other)*(1-p)**(n-1-sum(other))
            ms += w*p*(1-p)*(vals[x1]-vals[x0])**2
        assert ms == M


def main():
    # All probabilities are rational; no floating-point acceptance tolerance.
    cases = [
        (1, 10, F(1,2)),
        (2, 120, F(17,20)),
        (3, 160, F(14,15)),
        (4, 240, F(25,26)),
        (5, 300, F(39,40)),
        (6, 400, F(983,1000)),
    ]
    brute(2, 5, F(17,20))
    brute(3, 7, F(14,15))
    print("PASS independent full-cube Bernoulli enumeration: (d,n)=(2,5),(3,7)")
    for d,n,p in cases:
        B,V,M,R,L,s = certificate(d,n,p)
        assert R > F(94,100), (d,R)
        assert L > F(999,1000), (d,L)
        print(f"degree={d} n={n} bias={p} exact_R_over_d2={float(R):.12f} "
              f"exact_limit_prediction={float(L):.12f} spectral_avg={float(s):.9f} "
              f"actual_B={float(B):.12f}")
    assert certificate(2,120,F(17,20))[4] == F(2499,2500)
    print("PASS exact rational Chebyshev/binomial sharpness checks.")
    print("LIMIT n->infinity AND UNIVERSAL C=1 INEQUALITY NOT proved by this code.")


if __name__ == "__main__":
    main()
