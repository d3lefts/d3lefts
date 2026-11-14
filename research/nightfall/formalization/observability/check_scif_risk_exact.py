#!/usr/bin/env python3
"""Exact rational falsification of actual-source finite law-change risk.
Not a Lean proof or arbitrary-space certificate.
"""
from itertools import product
from fractions import Fraction as Q
import random

rnd = random.Random(20261114)
checks = 0
for trial in range(24):
    n = 2 + trial % 3
    m = 2 + (trial // 3) % 2
    states = list(product(range(m), repeat=n))
    def law():
        out = []
        for _ in range(n):
            w = [rnd.randrange(5) for j in range(m)]
            if sum(w) == 0:
                w[0] = 1
            out.append([Q(v, sum(w)) for v in w])
        return out
    p, q = law(), law()
    f = {x: Q(rnd.randrange(-7, 8), rnd.randint(1, 5)) for x in states}
    def masses(v):
        return {x: __import__('math').prod(v[i][x[i]] for i in range(n)) for x in states}
    P, Qmass = masses(p), masses(q)
    def upd(x, i, a):
        return x[:i] + (a,) + x[i+1:]
    infl_q = []
    for i in range(n):
        R = {x: f[x] - sum((p[i][a]*f[upd(x,i,a)] for a in range(m)), Q(0))
             for x in states}
        D = {x: sum(((q[i][a]-p[i][a])*f[upd(x,i,a)]
                     for a in range(m)), Q(0)) for x in states}
        Ip = sum((P[x]*R[x]**2 for x in states), Q(0))
        Iq = sum((Qmass[x]*(R[x]-D[x])**2 for x in states), Q(0))
        shift = (
            sum(((Qmass[x]-P[x])*R[x]**2 for x in states), Q(0))
            - 2*sum((Qmass[x]*R[x]*D[x] for x in states), Q(0))
            + sum((Qmass[x]*D[x]**2 for x in states), Q(0))
        )
        assert Iq == Ip + shift, (trial, i, Iq, Ip, shift)
        infl_q.append(Ip+shift)
        checks += 1
    mean = sum((Qmass[x]*f[x] for x in states), Q(0))
    variance = sum((Qmass[x]*(f[x]-mean)**2 for x in states), Q(0))
    assert variance <= sum(infl_q, Q(0)), (trial, variance, infl_q)
    checks += 1
print(f'EXACT_LAW_CHANGE PASS models=24 assertions={checks} seed=20261114')
print('LIMIT: finite models only; neither source-generated owner repair nor infinitePi is certified')
