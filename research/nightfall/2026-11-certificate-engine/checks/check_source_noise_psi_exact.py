#!/usr/bin/env python3
"""Exact rational falsifier of real-valued PSI and source-noise Bernstein bounds.

Universal source-noise bounds are analytically derived separately: finite
checks alone are not universal certificates. Zero-probability atoms included.
"""
from fractions import Fraction as F
from itertools import combinations, product
from math import prod
import random


def direct_psi_witness():
    states = list(product((-1, 1), repeat=4))
    def f(x):
        a, b, c, d = x
        return F(-a+b-c-d, 2)+F((a+b)*(c-d), 4)
    values = {x: f(x) for x in states}
    assert set(values.values()) == {-2, -1, 0, 1, 2}
    mean = sum(values.values(), F())/16
    V = sum(((v-mean)**2 for v in values.values()), F())/16
    I = [sum(((values[x]-values[x[:i]+(-x[i],)+x[i+1:]])**2/4
              for x in states), F())/16 for i in range(4)]
    R = max(sum((abs(values[x]-values[x[:i]+(-x[i],)+x[i+1:]])
                for i in range(4)), F()) for x in states)
    M = max(I)
    B = (max(values.values())-min(values.values()))/2
    assert (mean, V, R, M, B) == (0, F(5, 4), 4, F(3, 8), 2)
    assert I == [F(3,8)]*4
    assert 4*V**2/(R**2*M) == F(25, 24)

    spectrum = {}
    for k in range(5):
        for S in combinations(range(4), k):
            coeff = sum((values[x]*prod(x[i] for i in S)
                         for x in states), F())/16
            if coeff:
                spectrum[S] = coeff
    assert spectrum == {
        (0,):F(-1,2), (1,):F(1,2), (2,):F(-1,2), (3,):F(-1,2),
        (0,2):F(1,4), (0,3):F(-1,4),
        (1,2):F(1,4), (1,3):F(-1,4)}
    assert sum((a*a for a in spectrum.values()), F()) == V
    assert all(sum((a*a for S,a in spectrum.items() if i in S), F()) == M for i in range(4))
    print("PASS pure exact 4-bit degree-two PSI falsifier: V=5/4, R=4, M=3/8, ratio=25/24")

    # Dictator negative control: exact equality in original proposed PSI.
    g = {x:F(x[0]) for x in states}
    v = sum((y*y for y in g.values()),F())/16
    r = max(sum((abs(g[x]-g[x[:i]+(-x[i],)+x[i+1:]])
                 for i in range(4)),F()) for x in states)
    m = max(sum(((g[x]-g[x[:i]+(-x[i],)+x[i+1:]])**2/4
                  for x in states),F())/16 for i in range(4))
    assert (v,r,m)==(1,2,1) and 4*v*v==r*r*m
    print("PASS dictator PSI equality / resampling-normalization negative control")


def source_trial(seed):
    rng=random.Random(seed)
    laws=[(F(1,3),F(2,3)), (F(1,12),F(5,12),F(1,2)),
          (F(0),F(1,5),F(4,5)), (F(2,7),F(5,7))]
    n=len(laws)
    states=list(product(*(range(len(law)) for law in laws)))
    valid=[x for x in states if all(laws[i][x[i]]>0 for i in range(n))]
    mass={x:prod(laws[i][x[i]] for i in range(n)) for x in states}
    assert sum(mass.values(),F())==1
    data=[]
    for k in range(1,4):
        for S in combinations(range(n),k):
            h={}
            for i in S:
                raw=[F(rng.randint(-3,3)) for _ in laws[i]]
                mu=sum((laws[i][a]*raw[a] for a in range(len(laws[i]))),F())
                h[i]=tuple(v-mu for v in raw)
            data.append((S,rng.choice((-3,-2,-1,1,2,3)),h))
    def f(x):
        return sum((coef*prod(h[i][x[i]] for i in S)
                    for S,coef,h in data),F())
    vals={x:f(x) for x in states}
    B=(max(vals[x] for x in valid)-min(vals[x] for x in valid))/2
    assert B>=0
    def noise(x,rho):
        # Actual original-law refresh: not fairizing rare atoms.
        return sum((prod(rho*int(x[i]==y[i])+(1-rho)*laws[i][y[i]]
                         for i in range(n))*vals[y] for y in states),F())
    for rho in (F(1,4),F(1,2),F(3,4),F(1)):
        T={x:noise(x,rho) for x in states}
        for x in valid:
            D=[]
            for i in range(n):
                mean=sum((laws[i][z]*T[x[:i]+(z,)+x[i+1:]]
                          for z in range(len(laws[i]))),F())
                D.append(T[x]-mean)
            L=sum(map(abs,D),F())
            if rho<1:
                assert L**2*(1-rho)<=(3*B)**2*rho,(seed,rho,x,L,B)
            else:
                assert L<=4*3*3*B,(seed,x,L,B)

    # Independently compute the genuine fourfold heat-bath residual.
    # No ANOVA sector decomposition assumed by checker.
    for x in valid:
        D4=F()
        for mask in product((0,1),repeat=4):
            active=[i for i in range(n) if mask[i]]
            for ys in product(*(range(len(laws[i])) for i in active)):
                prob=prod(laws[i][y] for i,y in zip(active,ys))
                if prob==0:continue
                z=list(x)
                for i,y in zip(active,ys):z[i]=y
                D4+=(-1)**len(active)*prob*vals[tuple(z)]
        assert D4==0,(seed,x,D4)


if __name__=="__main__":
    direct_psi_witness()
    for seed in range(20261117,20261129):
        source_trial(seed)
    print("PASS 12 exact heterogeneous original-law degree-three models, including null atoms")
    print("PASS source-noise residual budgets at rho=1/4,1/2,3/4,1 on every supported state")
    print("SCOPE: finite exact replay; no unrestricted cubic exponent-two proof")
