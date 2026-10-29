#!/usr/bin/env python3
"""Exact 551-case adversarial audit for TESSERA Sidon prefix grafting lemma.
No dependencies; checker uses explicit independent cyclic perfect difference sets.
"""
from itertools import combinations
from collections import defaultdict
from fractions import Fraction
from math import comb

SOURCES={31:(0,1,3,8,12,18),57:(0,1,3,13,32,36,43,52)}

def sidon(seq):
    return len({seq[i]+seq[j] for i in range(len(seq)) for j in range(i,len(seq))})==len(seq)*(len(seq)+1)//2

def collision_types(A,Q,T):
    F=A+tuple(T+x for x in Q); m=len(A); representations={}
    for i,x in enumerate(F):
        for j in range(i,len(F)):
            s=x+F[j]
            tag='AA' if j<m else 'AB' if i<m else 'BB'
            if s in representations:
                yield tuple(sorted((tag,representations[s])))
            else:representations[s]=tag

cases=0
for v,D in SOURCES.items():
    assert len({(a-b)%v for a in D for b in D if a!=b})==v-1
    for m in (2,3):
        for raw in combinations(range(1,7),m):
            if not sidon(raw):continue
            A=tuple(raw);N=max(A)
            for h in range(1,v//4):
                L=h+N+1
                if v-h<=2*N or 2*L>=v:continue
                turns=[tuple(sorted((d+c)%v for d in D)) for c in range(v)]
                boundary=[sum(x<L or x>=v-L for x in Q) for Q in turns]
                R=Fraction(2*len(D)*L,v)
                assert Fraction(sum(boundary),v)==R
                c=min(range(v),key=lambda j:boundary[j])
                assert boundary[c]<=R
                Q=turns[c]
                lo=v-h;hi=v-(h+1)//2
                t=hi-lo+1
                E=Fraction(m,t)*(Fraction(2,27)*R**3+Fraction(1,8)*R**2)
                triples=[]
                for T in range(lo,hi+1):
                    types=list(collision_types(A,Q,T))
                    assert set(types)<={('AB','AB'),('AB','BB')},(v,A,h,T,types)
                    assert types.count(('AB','AB'))<=comb(m,2)
                    triples.append(types.count(('AB','BB')))
                assert min(triples)<=E,(v,A,h,E,min(triples))
                cases+=1
assert cases==551,cases
print('PASS 551 complete finite cases, exact rational averaging, literal collision classification')
