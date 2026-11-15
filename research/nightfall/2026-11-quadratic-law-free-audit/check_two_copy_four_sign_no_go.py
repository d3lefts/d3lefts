#!/usr/bin/env python3
"""Independent exact rational four-sign rejection of two-copy energy bound."""
from fractions import Fraction as Q
from itertools import product, combinations

n = 4
states = list(product((-1, 1), repeat=n))
F = lambda x: abs(sum(x))
prod = lambda xs: __import__('math').prod(xs)
u = sum(map(F, states), Q(0))/16
levels = {}
for k in range(1, n+1):
    coeffs = []
    for S in combinations(range(n), k):
        hat = sum((F(x)*prod(x[i] for i in S) for x in states), Q(0))/16
        coeffs.append(hat)
    levels[k] = sum((z*z for z in coeffs), Q(0))

two_copy = Q(0)
for a in states:
    for b in states:
        t = [Q(0)]*n
        for eps in states:
            selected = tuple(a[i] if eps[i] == 1 else b[i] for i in range(n))
            for i in range(n):
                t[i] += Q(eps[i]*F(selected), 16)
        two_copy += sum((v*v for v in t), Q(0))/256
signed_energy = 2*two_copy
spectral = sum((Q(k, 2**(k-1))*levels[k] for k in levels), Q(0))
assert u == Q(3,2)
assert levels == {1: Q(0), 2: Q(3,2), 3: Q(0), 4: Q(1,4)}
assert signed_energy == spectral == Q(13,8)
assert signed_energy - u == Q(1,8) > 0
print('PASS exact: u=',u,'W1=',levels[1],
      'two_copy=',signed_energy,'false_bound_violation=',signed_energy-u)
