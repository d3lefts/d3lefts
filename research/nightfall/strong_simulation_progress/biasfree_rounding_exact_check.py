#!/usr/bin/env python3
"""Exact-rational checks for candidate bias-free dyadic strong-simulation transfer.
Tests finite product expectation Markov stability and dyadic TV with zero
atoms; plus a nontrivial exact event-smoother transfer. NOT a proof of
Markov's inequality, the quantum pullback, or the mixture theorem.
"""
from fractions import Fraction as F
from itertools import product
from math import comb, ceil, floor, log
import random


def tv(p, q):
    return sum((abs(a - b) for a, b in zip(p, q)), F(0)) / 2


def dyadic(p, m):
    scale = 2 ** m
    raw = [x * scale for x in p]
    counts = [v.numerator // v.denominator for v in raw]
    need = scale - sum(counts)
    indices = sorted(range(len(raw)), key=lambda i: (raw[i]-counts[i],-i), reverse=True)
    for i in indices[:need]:
        counts[i] += 1
    result = tuple(F(c, scale) for c in counts)
    assert sum(result) == 1
    assert all(abs(x-y) <= F(1, scale) for x, y in zip(p, result))
    return result


def expectation(marginals, f):
    ans = F(0)
    for x in product(*(range(len(p)) for p in marginals)):
        w = F(1)
        for i, a in enumerate(x):
            w *= marginals[i][a]
        ans += w * f(x)
    return ans


def poly_f(x):
    # All monomials use <=2 distinct coordinates, with f(x) in [0,1].
    return F(1,10) + F(1,5)*(x[0]==1) + F(1,7)*(x[0]==2 and x[1]==0) + F(1,9)*(x[1]==1 and x[2]==2)


def tree_t(x):
    return F(3,5) if x[0]==1 else F(1,4)


def phi(z, k, r):
    v = z*z
    return sum((F(comb(k,j))*v**j*(1-v)**(k-j) for j in range(r+1,k+1)), F(0))


def main():
    rng = random.Random(20261119)
    count = 0
    alphabet = (3,2,3)
    for trial in range(180):
        P = []; Q = []
        for a in alphabet:
            if trial == 0:
                p = [F(0)]*(a-1) + [F(1)]
                q = [F(1)] + [F(0)]*(a-1)
            else:
                aa = [rng.choice([0,1,2,3,7,100,1200]) for _ in range(a)]
                bb = [rng.choice([0,1,2,3,7,100,1200]) for _ in range(a)]
                if sum(aa) == 0: aa[0] = 1
                if sum(bb) == 0: bb[-1] = 1
                p = [F(z,sum(aa)) for z in aa]
                q = [F(z,sum(bb)) for z in bb]
            P.append(tuple(p)); Q.append(tuple(q))
        delta = max(tv(p,q) for p,q in zip(P,Q))
        assert abs(expectation(P,poly_f)-expectation(Q,poly_f)) <= 8*delta
        for m in (4,8,13):
            R = [dyadic(p,m) for p in P]
            delta_r = max(tv(p,r) for p,r in zip(P,R))
            assert delta_r <= F(max(alphabet), 2**(m+1))
            assert abs(expectation(P,poly_f)-expectation(R,poly_f)) <= 8*delta_r
            count += 1
    eps = F(1,4); eta = F(1,4)
    k = ceil((2/(9*float(eps)**4))*log(1/float(eta)))
    r = floor(5*k*eps*eps/2)
    assert phi(eps,k,r) <= eta
    assert phi(2*eps,k,r) >= 1-eta
    P = [(F(0),F(1,3),F(2,3)), (F(1,997),F(996,997)), (F(7,12),F(0),F(5,12))]
    Q = [dyadic(p,30) for p in P]
    def G(x):
        return phi(poly_f(x)-tree_t(x),k,r)
    h = 2*k*(2+1)
    measured = abs(expectation(P,G)-expectation(Q,G))
    b = h*h*max(alphabet)*F(1,2**30)
    assert measured <= b and b < eta
    print("exact-check PASS", "cases", count, "smoother-degree", 2*k,
          "zero-atoms", True, "rounding-transfer-bound", str(b),
          "measured/upper ratio", float(measured/b))


if __name__ == "__main__":
    main()
