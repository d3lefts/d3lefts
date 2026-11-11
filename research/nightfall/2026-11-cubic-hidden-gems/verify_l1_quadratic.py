#!/usr/bin/env python3
"""Exact rational tests of l1-bounded vector quadratic and fair-leaf selector bounds.
Finite tests do not establish a general-product proof.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from math import prod
import random
rng=random.Random(2026111017)

for trial in range(65):
    n=5; k=6
    ps=[Q(1,4),Q(2,5),Q(3,7),Q(4,9),Q(1,3)]
    supports=[()]+[s for d in (1,2) for s in combinations(range(n),d)]
    coeff={(i,s):Q(rng.randrange(-4,5),rng.randrange(1,5))
           for i in range(k) for s in supports}
    states=list(product((0,1),repeat=n))
    def g(i,x):
        return sum((coeff[(i,s)]*prod((Q(x[j])-ps[j] for j in s),start=Q(1))
                    for s in supports),Q(0))
    B=max(sum(abs(g(i,x)) for i in range(k)) for x in states)
    energies={i:sum((coeff[(i,s)]**2*
          prod((ps[j]*(1-ps[j]) for j in s),start=Q(1))
          for s in supports),Q(0)) for i in range(k)}
    var={i:sum((coeff[(i,s)]**2*
          prod((ps[j]*(1-ps[j]) for j in s),start=Q(1))
          for s in supports if s),Q(0)) for i in range(k)}
    infl_control={j:sum((coeff[(i,s)]**2*
          prod((ps[l]*(1-ps[l]) for l in s),start=Q(1))
          for i in range(k) for s in supports if j in s),Q(0))
          for j in range(n)}
    W=sum(var.values(),Q(0))
    M_control=max(infl_control.values())
    if W and M_control:
        ratio=W*W/(B*B*M_control)
        assert ratio <=2048 or (ratio-2048)**2 <=Q(3*1024*1024),(trial,ratio)
    V=sum(energies.values(),Q(0))
    M=max(M_control,max(energies.values()))
    assert V*V <= 63*63*B*B*M,(trial,V,M,B)
    Bmixed=max(abs(g(0,x))+sum(abs(g(i,x)) for i in range(1,k))
               for x in states)
    Vmixed=var[0]+sum((energies[i] for i in range(1,k)),Q(0))
    Mmixed=max(M_control,max((energies[i] for i in range(1,k))))
    assert Vmixed*Vmixed<=63*63*Bmixed*Bmixed*Mmixed,(trial,Vmixed,Mmixed,Bmixed)

for n in (1,2,3,5,20):
    B=Q(1); W=Q(1,n); M=Q(1,n*n)
    assert W*W==B*B*M
print('PASS: 65 exact biased-product quadratic-vector/fair-selector/control-offset examples')
print('PASS: 5 exact exponent-two scale-equality constructions')
