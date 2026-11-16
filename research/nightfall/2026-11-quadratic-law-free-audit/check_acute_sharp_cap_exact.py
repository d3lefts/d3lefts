#!/usr/bin/env python3
"""Exact rational checks: all-length acute-ray equality and nonorthogonal witness.

Finite tests corroborate an independent all-length analytic argument; no universal
Hilbert or Lean proof is supplied by this test script.
"""
from fractions import Fraction as Q
from itertools import product

pvals = (Q(1, 8), Q(1, 4), Q(1, 3), Q(1, 2))
for n in range(1, 9):
    for p in pvals:
        u = Q(0)
        gplus, gminus = [Q(0)]*n, [Q(0)]*n
        for bits in product((0, 1), repeat=n):
            prob = p**sum(bits) * (1-p)**(n-sum(bits))
            F = Q(sum(bits))
            u += prob * F
            for i in range(n):
                if bits[i]:
                    gplus[i] += prob * F / p
                else:
                    gminus[i] += prob * F / (1-p)
        W1 = sum((p*(1-p)*(gplus[i]-gminus[i])**2 for i in range(n)), Q(0))
        c = 1-p  # exact centered increment norm bound when p<=1/2
        assert u == n*p
        assert W1 == n*p*(1-p)
        assert W1 == c*u

# Exact nonorthogonal R^2 example: v1=(1,0), v2=(3/5,4/5),
# p1=1/4, p2=1/3, r=||v1+v2||=4/sqrt(5), r^2=16/5.
# Exact quadratic field Q[r]/(r^2-16/5), no floating point.
R2 = Q(16, 5)
def A(x, y): return (x[0]+y[0], x[1]+y[1])
def S(x, t): return (t*x[0], t*x[1])
def M(x, y): return (x[0]*y[0] + R2*x[1]*y[1],
                      x[0]*y[1] + x[1]*y[0])
def sq(x): return M(x, x)
zero, one, r = (Q(0), Q(0)), (Q(1), Q(0)), (Q(0), Q(1))
p1, p2 = Q(1, 4), Q(1, 3)
F = {(0,0):zero, (1,0):one, (0,1):one, (1,1):r}
P = {z:(p1 if z[0] else 1-p1)*(p2 if z[1] else 1-p2)
     for z in F}
u = zero
for z in F: u = A(u, S(F[z],P[z]))
W1 = zero
for i,p in ((0,p1),(1,p2)):
    gp, gm = zero, zero
    for z in F:
        if z[i]: gp = A(gp, S(F[z], P[z]/p))
        else: gm = A(gm, S(F[z],P[z]/(1-p)))
    diff = A(gp, S(gm, -1))
    W1 = A(W1, S(sq(diff), p*(1-p)))
c = Q(3,4)
slack = A(S(u,c),S(W1,-1))
assert u == (Q(5,12), Q(1,12))   # (5+r)/12
assert W1 == (Q(27,144), Q(14,144))
assert slack == (Q(18,144), Q(-5,144))
r_lower, r_upper = Q(89,50), Q(9,5)
assert 0 < r_lower**2 < R2 < r_upper**2
slack_lower = slack[0] + slack[1]*r_upper
assert slack_lower == Q(1,16)
print('PASS: 32 exact collinear n/p cases, sharp equality W1=c*u')
print('PASS: original-law 2D W1/u exact in Q[r], slack >',slack_lower)
