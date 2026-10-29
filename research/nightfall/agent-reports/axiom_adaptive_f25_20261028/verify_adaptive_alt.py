#!/usr/bin/env python3
"""Independent tuple-field replication in F5[v]/(v^2-3). No shared imports.
Verifies one-adaptive-query phase separation and exact F25^2, F25^3 signals.
"""
from itertools import product
from collections import defaultdict
import json
F=list(product(range(5),repeat=2))
O=(0,0);E=(1,0);W=(0,1)
def plus(u,v):return ((u[0]+v[0])%5,(u[1]+v[1])%5)
def multiply(u,v):return ((u[0]*v[0]+3*u[1]*v[1])%5,(u[0]*v[1]+u[1]*v[0])%5)
def exponent(base,e):
    out=E
    for i in range(e):out=multiply(out,base)
    return out
def quotient(u,v):assert v!=O;return multiply(u,exponent(v,23))
roots={y:tuple(z for z in F if exponent(z,4)==y) for y in F}
phases=roots[E]
assert len(phases)==4 and all(z[1]==0 for z in phases)
def orb(vec):return min(tuple(multiply(p,z) for z in vec) for p in phases)
def evalrow(a,x):
    accum=O
    for i in range(len(x)):accum=plus(accum,multiply(a[i],x[i]))
    return exponent(accum,4)
def decode(v):
    k=len(v)
    ys=[exponent(z,4) for z in v];obs=k
    active=[j for j,t in enumerate(ys) if t!=O]
    if not active:return (O,)*k,obs
    ref=active[0]; alpha=roots[ys[ref]][0]
    answer=[O]*k;answer[ref]=alpha
    for j in active[1:]:
        ratio=quotient(ys[j],ys[ref]); c=W if ratio==E else E
        a=[O]*k;a[ref]=E;a[j]=c
        data=quotient(evalrow(a,v),ys[ref]);obs+=1
        poss=[z for z in roots[ratio] if exponent(plus(E,multiply(c,z)),4)==data]
        assert len(poss)==1,(v,j,poss)
        answer[j]=multiply(alpha,poss[0])
    assert orb(v)==orb(tuple(answer))
    return tuple(answer),obs

for v in F:
    if v==O:continue
    cs=W if exponent(v,4)==E else E
    values={exponent(plus(E,multiply(cs,multiply(v,p))),4) for p in phases}
    assert len(values)==4
samples=0
for k in (2,3):
    for v in product(F,repeat=k):
        _,m=decode(v);assert m<=2*k-1;samples+=1
# independent 5-row nonadaptive obstruction and full 625 signal orbit enumeration
R=[((1,0),(j,0)) for j in range(5)]
seen=defaultdict(set)
for v in product(F,repeat=2):
    seen[tuple(evalrow(a,v) for a in R)].add(orb(v))
assert len(seen)==157 and all(len(z)==1 for z in seen.values())
assert all(exponent((j,0),5)==(j,0) for j in range(5))
print(json.dumps({'result':'PASS','field':'F5[v]/(v^2-3)','signals_decoded':samples,'nonadaptive_obstruction_phase_classes':len(seen),'four_phase_separation':'ALL 24 ratios','bound':'<=2k-1 adaptive fourth powers'},indent=2))
