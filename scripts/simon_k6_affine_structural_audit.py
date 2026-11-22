#!/usr/bin/env python3
"""Exact, independently constructed k=6 affine-orbit structural audit.
Classifies four six-point F_2 affine-matroid types, enumerates all
720 permutations, exact stabilizers, and all no-singleton partitions.
This does NOT compute a 24x24 affine probe matrix or prove the all-k claim.
"""
from itertools import permutations
from collections import Counter

K=6
def xor(vals):
    z=0
    for x in vals: z^=x
    return z

def partitions(n):
    out=[]
    def rec(v,top):
        if len(v)==n:
            if all(s>=2 for s in Counter(v).values()):out.append(tuple(v))
            return
        for t in range(top+2):rec(v+[t],max(top,t))
    rec([0],0)
    return out

PARTS=partitions(K)
assert len(PARTS)==41

def relations(S):
    return {mask for mask in range(1,1<<K)
      if mask.bit_count()%2==0 and
      xor(S[i] for i in range(K) if mask>>i&1)==0}

def rank(S):
    base={}
    for v in [p^S[0] for p in S[1:]]:
        while v:
            b=v.bit_length()-1
            if b in base:v^=base[b]
            else:base[b]=v;break
    return len(base)

def stabilizer(S):
    R=relations(S); out=[]
    for p in permutations(range(K)):
        if all(sum(1<<p[i] for i in range(K) if mask>>i&1) in R for mask in R):
            out.append(p)
    return out

def normalize(p):
    rename={}
    return tuple(rename.setdefault(x,len(rename)) for x in p)

def partition_orbits(G):
    remaining=set(PARTS); out=[]
    while remaining:
        p=next(iter(remaining))
        orbit={normalize(tuple(p[g[i]] for i in range(K))) for g in G}
        assert orbit<=set(PARTS)
        remaining-=orbit
        out.append(len(orbit))
    return sorted(out)

REPS={
 'cube_six_rank3':([0,1,2,3,4,5],3,48,8),
 'four_circuit_rank4':([0,1,2,3,4,8],4,48,8),
 'six_circuit_rank4':([0,1,2,4,8,15],4,720,4),
 'independent_rank5':([0,1,2,4,8,16],5,720,4),
}
D=0
for name,(S,rr,st,dd) in REPS.items():
    assert len(S)==6 and len(set(S))==6
    G=stabilizer(S); O=partition_orbits(G)
    assert rank(S)==rr and len(G)==st and len(O)==dd,(name,rank(S),len(G),len(O))
    assert sum(O)==41
    D+=len(O)
    print(name, 'rank',rr,'|G|',len(G),'partition orbits',len(O),'sizes',O)
assert D==24
print('PASS: k=6 stable invariant basis dimension D_6=24 (finite orbit combinatorics only)')
