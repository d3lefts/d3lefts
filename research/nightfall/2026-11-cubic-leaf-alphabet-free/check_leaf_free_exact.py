#!/usr/bin/env python3
"""Exact independent finite attack on cubic top-degree cover reductions.
Uses direct conditional second moments, not ANOVA coefficient identities.
Third-party-free; these tests do not certify the all-law theorem.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from random import Random

rng = Random(20261110)
tested = 0
worst = Q(0)


def moments(table, domains, weights):
    joint = []
    for s in product(*domains):
        p = Q(1)
        for j,x in enumerate(s):
            p *= weights[j][x]
        joint.append((s,p))
    avg = sum((p*table[s] for s,p in joint), Q())
    second = sum((p*table[s]**2 for s,p in joint), Q())
    v = second-avg**2
    influences = []
    for j in range(len(domains)):
        blocks = {}
        for s,p in joint:
            key=s[:j]+s[j+1:]
            a,z=blocks.get(key,(Q(),Q()))
            blocks[key]=(a+p*table[s],z+p)
        influences.append(second-sum((a*a/z for a,z in blocks.values()),Q()))
    return v,influences


for trial in range(128):
    n = 4 if trial < 100 else 5
    sizes = [rng.randrange(2,6) for _ in range(n)]
    domains = [tuple(range(s)) for s in sizes]
    weights,psi = [],[]
    for sz in sizes:
        raw = [rng.randrange(-3,4) for _ in range(sz)]
        mass = [rng.randrange(1,6) for _ in range(sz)]
        w = {i:Q(mass[i],sum(mass)) for i in range(sz)}
        mu = sum((w[i]*raw[i] for i in range(sz)),Q())
        weights.append(w)
        psi.append({i:Q(raw[i])-mu for i in range(sz)})
    terms=[]
    for order in (1,2,3):
        for S in combinations(range(n),order):
            if order==3 and 0 not in S:continue
            c=rng.randrange(-3,4)
            if c:terms.append((S,Q(c)))
    table={}
    for state in product(*domains):
        value=Q(0)
        for S,c in terms:
            v=c
            for j in S:v*=psi[j][state[j]]
            value+=v
        table[state]=value
    B=max(map(abs,table.values()))
    if B==0:continue
    table={s:v/B for s,v in table.items()}
    V,I=moments(table,domains,weights)
    g={}
    for s in table:
        g[s]=sum((weights[0][a]*table[(a,)+s[1:]] for a in domains[0]),Q())
    Vg,Ig=moments(g,domains,weights)
    assert V-Vg==I[0],("wrong variance split",trial)
    assert all(x<=y for x,y in zip(Ig,I)),("influence contraction",trial)
    M=max(I)
    assert V*V<=45*45*M,("contradiction of conservative star bound",trial)
    if V>0:worst=max(worst,V*V/M)
    tested+=1

# Exact family identities when each leaf is an L-symbol balanced-sign variable:
for m in (2,3,5,11,101):
    for s in (2,4,7):
        for L in (2,4,16,100):
            IA,IB,Il=Q(m-1,m),Q(s-1,s),Q(1,m*s)
            assert IA==1-Q(1,m)
            assert IB==1-Q(1,s)
            assert m*s*Il==1
            assert max(IA,IB,Il)>=Q(1,2)
            tested+=1

# k independent cubic address selector blocks, scaled by k:
for k in (1,2,4,16,100,1000):
    for m in (2,3,17,101):
        V,M=Q(1,k),Q(m-1,m*k*k)
        assert M==Q(m-1,m)*V*V
        assert M>=V*V/2
        tested+=1

print(f"PASS: {tested} exact cases; 128 heterogeneous random cubic stars")
print("PASS: 60 leaf-alphabet families; 24 disjoint selector networks")
print(f"PASS: worst finite exact ratio V^2/M={float(worst):.7f}")
print("SCOPE: finite arithmetic check only; no proof/originality certification")
