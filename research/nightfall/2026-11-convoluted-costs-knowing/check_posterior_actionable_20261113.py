#!/usr/bin/env python3
"""Exact finite posterior influence and address-oracle counterexample replay.
This is an independent-instance falsifier, not a proof of quantified theorems.
"""
from fractions import Fraction as Q
from itertools import product
from math import comb

posterior = {1: Q(2, 3), -1: Q(1, 3)}
states = list(product((-1, 1), repeat=2))

def f(theta, x):
    return Q(theta*x[0] + x[0]*x[1], 2)

def m(x):
    return sum((p*f(theta, x) for theta, p in posterior.items()), Q(0))

def replace(x, y, i):
    return tuple(y[k] if k == i else x[k] for k in range(2))

def influence(g, i):
    return sum(((g(x)-g(replace(x,y,i)))**2 for x in states for y in states), Q(0))/32

def W(thetas, x, y, i):
    a, b, c, d = thetas
    z = replace(x, y, i)
    return (f(a,x)-f(b,z))*(f(c,x)-f(d,z))/2

count = 0
for i in (0, 1):
    I_m = influence(m, i)
    I_avg = sum((p*influence(lambda x: f(th,x),i) for th,p in posterior.items()), Q(0))
    I_epi = sum((p*influence(lambda x:f(th,x)-m(x),i) for th,p in posterior.items()), Q(0))
    assert I_avg == I_m + I_epi
    expected_W = Q(0)
    for x in states:
        for y in states:
            for ts in product(posterior, repeat=4):
                p = Q(1,16)
                for th in ts:
                    p *= posterior[th]
                expected_W += p*W(ts, x, y, i)
                count += 1
    assert expected_W == I_m
    print(f'coordinate={i} average={I_avg} actionable={I_m} epistemic={I_epi} W={expected_W}')

for beta in (Q(1,2),Q(1,3)):
    p = (1+beta)/2
    for r in (1,3,5,9,15,25,41):
        err = sum((Q(comb(r,k))*p**k*(1-p)**(r-k)
                   for k in range(r//2+1)), Q(0))
        excess_majority = 4*beta*beta*err
        excess_sample_mean = (1-beta*beta)/r
        assert excess_majority < excess_sample_mean
    print(f'beta={beta}: majority strictly better than raw mean for 7 exact cases')

assert count == 512, count
print('PASS exact 512 four-posterior atoms; 2 Hilbert influence identities; 14 oracle-risk comparisons')
