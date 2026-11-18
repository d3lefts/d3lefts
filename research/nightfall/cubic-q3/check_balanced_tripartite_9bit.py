#!/usr/bin/env python3
"""Exact 9-bit pure cubic balanced tensor source checker; standard library only.

Uses a full independent input truth table, an independent Walsh transform,
original source resampling flips, a finite hypergraph cover search, and
tensorization of the exact distribution by integer convolution.
"""
from collections import Counter
from fractions import Fraction as Q
from itertools import combinations, product
from math import prod

T = (
    ((0,-1,-1),(1,1,0),(-1,0,1)),
    ((1,-1,0),(0,1,-1),(1,0,-1)),
    ((1,0,1),(1,0,1),(0,0,0)),
)
WORDS=tuple(product((-1,1),repeat=9))
EDGES=tuple((i,3+j,6+k,T[i][j][k])
            for i in range(3) for j in range(3) for k in range(3)
            if T[i][j][k]!=0)

def f(x):
    return sum(w*x[i]*x[j]*x[k] for i,j,k,w in EDGES)

def audit():
    values={x:f(x) for x in WORDS}
    assert len(values)==512
    assert (min(values.values()),max(values.values()))==(-4,4)
    mean=Q(sum(values.values()),512)
    V=sum((Q(z*z,512) for z in values.values()),Q())-mean*mean
    B=Q(max(values.values())-min(values.values()),2)
    assert mean==0 and V==16 and B==4

    actual=[]
    for i in range(9):
        inf=sum((Q((v-values[x[:i]+(-x[i],)+x[i+1:]])**2,4*512)
                 for x,v in values.items()),Q())
        actual.append(inf)
    assert actual==[6,6,4,6,6,4,6,4,6]

    # Every Walsh coefficient is recomputed from the truth table independently
    # of the source tensor term list, including all 512 subsets.
    walsh={}
    for k in range(10):
        for S in combinations(range(9),k):
            coeff=sum((Q(values[x]*prod(x[i] for i in S),512)
                        for x in WORDS),Q())
            if coeff:walsh[S]=coeff
    expected={tuple((i,j,k)):Q(w) for i,j,k,w in EDGES}
    assert walsh==expected and len(walsh)==16
    assert all(len(S)==3 for S in walsh)
    assert sum((a*a for a in walsh.values()),Q())==V
    assert all(sum((a*a for S,a in walsh.items() if i in S),Q())==actual[i] for i in range(9))
    assert V**2/(B**2*max(actual))==Q(8,3)
    print('PASS 512 source states and 512 Walsh modes: pure cubic, B=4, Var=16, M=6, ratio=8/3')
    print('PASS 9 genuine source resampling influences:',','.join(map(str,actual)))

    # Full enumeration of all possible 9-site vertex cover subsets.
    edge_sets=[{i,j,k} for i,j,k,w in EDGES]
    first=None
    for size in range(10):
        hits=[S for S in combinations(range(9),size)
              if all(set(S)&e for e in edge_sets)]
        if hits:
            first=(size,hits)
            break
    assert first==(3,[(0,1,2),(3,4,5),(6,7,8)])
    print('PASS exact cubic cover number 3, with precisely three minimal covers')

    # Local discrete coefficient mutation audit, not global optimization.
    def score(t):
        active=[(a//9,3+(a//3)%3,6+a%3,z)
                for a,z in enumerate(t) if z]
        ys=[sum(w*x[i]*x[j]*x[k] for i,j,k,w in active) for x in WORDS]
        bb=Q(max(ys)-min(ys),2)
        vv=sum(z*z for z in t)
        mm=max(sum(t[a]*t[a] for a in range(27)
                   if (a//9==i if i<3 else ((a//3)%3==i-3 if i<6 else a%3==i-6)))
               for i in range(9))
        return Q(vv*vv,bb*bb*mm)
    coeff=[T[i][j][k] for i in range(3) for j in range(3) for k in range(3)]
    assert score(coeff)==Q(8,3)
    trials=0
    for a in range(27):
        for z in (-1,0,1):
            if coeff[a]==z:continue
            test=coeff.copy();test[a]=z
            trials+=1
            assert score(test)<=Q(8,3),(a,z,score(test))
    assert trials==54
    print('PASS exact 54 one-entry +/-1/0 perturbations, no improvement')

    # Independent disjoint-block convolution, no Gaussian/float approximation.
    single=Counter(values.values())
    histogram=Counter({0:1})
    for m in range(1,5):
        nxt=Counter()
        for a,na in histogram.items():
            for b,nb in single.items():
                nxt[a+b]+=na*nb
        histogram=nxt
        mass=512**m
        assert sum(histogram.values())==mass
        fm=Q(sum(s*num for s,num in histogram.items()),mass*m)
        Vm=Q(sum(s*s*num for s,num in histogram.items()),mass*m*m)-fm**2
        Bm=Q(max(histogram)-min(histogram),2*m)
        Mm=Q(6,m*m)
        assert fm==0 and Vm==Q(16,m) and Bm==4
        assert Vm**2/(Bm**2*Mm)==Q(8,3)
    print('PASS independent block m=1..4 exact convolution, invariant 8/3 ratio')
    print('SCOPE exact finite witness; does not prove a universal cubic bound')

if __name__=='__main__':
    audit()
