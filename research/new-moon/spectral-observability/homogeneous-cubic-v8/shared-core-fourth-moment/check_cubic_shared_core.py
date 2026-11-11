#!/usr/bin/env python3
"""Exact-rational obstruction to the naive quadratic fourth-moment transfer.

No external packages.  Recompute E|S_m|^2 and E|S_m|^4 by binomial
counting, independently of the closed-form Rademacher moment identities.
"""
from fractions import Fraction as Q
from math import comb


def sample(m, p):
    assert m >= 2 and Q(0) < p < Q(1)
    moment2 = sum(Q(comb(m, k) * (2*k-m)**2, 2**m)
                  for k in range(m+1))
    moment4 = sum(Q(comb(m, k) * (2*k-m)**4, 2**m)
                  for k in range(m+1))
    assert moment2 == m
    assert moment4 == 3*m*m-2*m
    v = p*(1-p)
    y4 = p*(1-p)**4+(1-p)*p**4
    # H_0=L^2({-1,+1}) and increments T_j=x0*(A-p)*Z_j/m.
    s = v*moment2/Q(m*m)
    fourth = y4*moment4/Q(m**4)
    c = (1-p)/m
    iid_rhs = c*c*s + 3*s*s
    # Independent-increment moment estimate would demand fourth<=iid_rhs.
    return s, fourth, iid_rhs, fourth/iid_rhs


def run():
    # A fixed exact numerical witness: m=16, p=1/64.
    s, q4, bound, ratio = sample(16, Q(1, 64))
    assert s == Q(63, 65536)
    assert q4 == Q(5661243, 34359738368)
    assert bound == Q(440559, 68719476736)
    assert ratio == Q(179722, 6993)
    assert q4 > bound
    print(f"fixed witness m=16,p=1/64: s={s}; E fourth={q4}; iid RHS={bound}; ratio={ratio} ({float(ratio):.6f})")

    # Diverging family p=1/m^2.  As m grows, ratio/m -> 3.
    ms = [4, 8, 16, 32, 64, 128]
    values=[]
    for m in ms:
        _,_,_,r = sample(m, Q(1, m*m))
        values.append(r)
        print(f"m={m}, p=1/{m*m}: ratio={float(r):.8f}, ratio/m={float(r/m):.8f}")
    assert all(values[i] < values[i+1] for i in range(len(values)-1))
    assert values[-1] > 300
    # These finite checks support an exact symbolic asymptotic proof; do not
    # mistake a growing finite list for proof of unboundedness.
    print("PASS: exact rational moment identities, strict violation, growing family")


if __name__ == '__main__':
    run()
