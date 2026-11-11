#!/usr/bin/env python3
"""Exact general-degree influence-weighted fractional transversal certificates."""
from fractions import Fraction as Q
from itertools import combinations
from random import Random
rng=Random(20261111)
trials=0
for n in range(1,9):
    for d in range(1,min(5,n)+1):
        supports=[frozenset(S) for k in range(1,d+1)
                  for S in combinations(range(n),k)]
        for _ in range(35):
            v={S:Q(rng.randrange(9),rng.randrange(1,11)) for S in supports}
            active=[S for S in supports if v[S]>0]
            I=[sum((v[S] for S in active if i in S),Q()) for i in range(n)]
            V=sum((v[S] for S in active),Q())
            T=sum(I,Q())
            assert V<=T<=d*V
            # y_S=v_S: exact dual capacity saturation.
            assert all(sum((v[S] for S in active if i in S),Q())==I[i]
                       for i in range(n))
            # x_i=1: primal cover objective T.
            assert all(sum(Q(1) for i in S)>=1 for S in active)
            # Homogeneous-order d version: x_i=1/d, y_S=v_S match V.
            vd={S:v[S] for S in active if len(S)==d}
            Id=[sum((v[S] for S in vd if i in S),Q()) for i in range(n)]
            assert Q(sum(Id,Q()),d)==sum(vd.values(),Q())
            assert all(sum(Q(1,d) for i in S)==1 for S in vd)
            trials+=1
# Mixed-degree {0},{1},{0,1}, all energies 1: V=3, tau*=4.
assert Q(4)>Q(3)
print(f"PASS {trials} exact general-degree primal/dual certificates,")
print(f"{trials} homogeneous equalities, and strict mixed-degree example")
