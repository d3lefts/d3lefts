#!/usr/bin/env python3
"""Exact finite fair cube rainbow/degree-3 identities (NOT a general proof).
Run: python3 -I research/nightfall/cubic-q3/check_cubic_fair_rainbow.py
"""
from fractions import Fraction as Q
from itertools import product, combinations
from math import factorial
from random import Random


def character(x, support):
    v = 1
    for i in support:
        v *= x[i]
    return v


def experiment(n, d, seed):
    rng = Random(seed)
    supports = [s for k in range(1, d + 1) for s in combinations(range(n), k)]
    a = {s: Q(rng.randrange(-3, 4), 2) for s in supports}
    a = {s: v for s, v in a.items() if v}
    cube = list(product((-1, 1), repeat=n))
    f = {x: sum((v * character(x, s) for s, v in a.items()), Q()) for x in cube}
    B = max((abs(v) for v in f.values()), default=Q())
    V = sum((v*v for v in a.values()), Q())
    Vd = sum((v*v for s, v in a.items() if len(s) == d), Q())
    I = [sum((v*v for s, v in a.items() if i in s), Q()) for i in range(n)]
    M = max(I, default=Q())

    # Independent input-table influence, with no Fourier formula assumed.
    for i in range(n):
        I_physical = sum((
            (f[x] - f[x[:i]+(-x[i],)+x[i+1:]])**2 / 4
            for x in cube
        ), Q()) / len(cube)
        assert I_physical == I[i], (n,d,seed,i,I_physical,I[i])

    total = Q()
    for color in product(range(d), repeat=n):
        rainbow = {s:v for s,v in a.items()
                   if len(s) == d and len({color[i] for i in s}) == d}
        VR = sum((v*v for v in rainbow.values()), Q())
        total += VR
        IR = [sum((v*v for s,v in rainbow.items() if i in s),Q())
              for i in range(n)]
        assert all(IR[i] <= I[i] for i in range(n))

        # This calculation is deliberately independent of coefficient selection.
        # Compare signed-average of the ORIGINAL physical function table against
        # the Fourier-subset reconstruction at EVERY vertex and coloring.
        max_rainbow = Q()
        for x in cube:
            direct = sum((
                Q(character(sig,tuple(range(d))),2**d) *
                f[tuple(x[i]*sig[color[i]] for i in range(n))]
                for sig in product((-1,1),repeat=d)
            ),Q())
            spectral = sum((v*character(x,s) for s,v in rainbow.items()),Q())
            assert direct == spectral, (n,d,seed,color,x,direct,spectral)
            max_rainbow = max(max_rainbow, abs(direct))
        assert max_rainbow <= B, (n,d,seed,color,max_rainbow,B)
        assert VR*VR <= 2**(d-1)*B*B*M

    p = Q(factorial(d), d**d)
    assert total == len(range(d))**n*p*Vd, (n,d,seed,total,Vd)
    if B and M:
        assert Vd*Vd <= Q(2**(d-1),1)/p**2*B*B*M
    if d == 3:
        c3 = {s:v for s,v in a.items() if len(s)==3}
        V3 = sum((v*v for v in c3.values()),Q())
        h3 = {x:sum((v*character(x,s) for s,v in c3.items()),Q())
              for x in cube}
        assert V3*V3 <= 81*B*B*M
        assert max(map(abs,h3.values()),default=Q()) <= 4*B
        assert max((abs(f[x]-h3[x]) for x in cube),default=Q()) <= 5*B
        # C2<106 and 5sqrt(106)+9<121/2: exact rational corollary.
        assert V*V <= Q(14641,4)*B*B*M
    return 1


def check_router():
    # Eight fair signs, four anchor cells, exactly one row active.
    cube=list(product((-1,1), repeat=8))
    def f(x):
        A=x[:4]; b=x[4:6]; c=x[6:8]
        return sum(A[2*u+v] *
                   (b[0]+(-1 if u else 1)*b[1]) *
                   (c[0]+(-1 if v else 1)*c[1]) // 4
                   for u in (0,1) for v in (0,1))
    values={x:f(x) for x in cube}
    assert set(values.values())=={-1,1}
    infl=[Q(sum((values[x]-values[x[:i]+(-x[i],)+x[i+1:]])**2
                for x in cube),4*len(cube)) for i in range(8)]
    assert infl[:4]==[Q(1,4)]*4
    assert infl[4:]==[Q(1,2)]*4
    assert Q(1)/max(infl)==2


if __name__=="__main__":
    count=0
    for d,ns in ((2,(3,4,5)),(3,(3,4,5,6)),(4,(4,5))):
        for n in ns:
            for seed in range(5):
                count+=experiment(n,d,100*n+seed)
    check_router()
    print("PASS: exact Fraction arithmetic;",count,
          "models; every coloring and vertex; 8-sign router")
