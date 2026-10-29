#!/usr/bin/env python3
"""TESSERA #117: standalone exact affine Singer source census. Python stdlib only."""
from collections import Counter, defaultdict
from itertools import combinations
from math import gcd
SOURCES={
 5:(31,(0,1,3,8,12,18),(1,2,4,9)),
 7:(57,(0,7,16,21,22,24,34,53),(1,8,17,22,23)),
 25:(651,(0,30,61,99,117,140,143,151,188,213,217,223,245,266,281,308,320,321,367,455,506,515,520,522,539,631),
     (1,31,62,100,118,141,144,152,189,214,218,224,246,267,282,309,321)),
}
def graph(A,B):
    by_sum=defaultdict(list)
    for i,a in enumerate(A):
        for j,b in enumerate(B):by_sum[a+b].append(j)
    E=set()
    for js in by_sum.values():
        for i,j in combinations(js,2):
            assert i!=j
            E.add((min(i,j),max(i,j)))
    return E

def alpha_exact(edges,n):
    # Bron–Kerbosch pivot search, independent of archived C++ coloring solver.
    g=[0]*n
    for x,y in edges:g[x]|=1<<y;g[y]|=1<<x
    mask=(1<<n)-1
    h=[mask&~(g[i]|(1<<i)) for i in range(n)]
    best=0
    def recurse(P,X,r):
        nonlocal best
        if r+P.bit_count()<=best:return
        if not P and not X:best=max(best,r);return
        pool=P|X
        pivot=max((i for i in range(n) if pool>>i&1),key=lambda i:(P&h[i]).bit_count()) if pool else -1
        candidates=P&~h[pivot] if pivot>=0 else P
        while candidates:
            bit=candidates&-candidates;j=bit.bit_length()-1
            recurse(P&h[j],X&h[j],r+1)
            P&=~bit;X|=bit;candidates&=~bit
            if r+P.bit_count()<=best:break
    recurse(mask,0,0)
    return best

def full_edges(A,B,T):
    V=A+tuple(T+b for b in B);m=len(A)
    by_sum=defaultdict(list)
    for i,x in enumerate(V):
        for j in range(i,len(V)):by_sum[x+V[j]].append((i,j))
    edges=set()
    for pairs in by_sum.values():
        for a,b in combinations(pairs,2):
            mask=0
            for x in set(a+b):
                if x>=m:mask|=1<<(x-m)
            assert mask
            edges.add(mask)
    return edges

def min_cover_small(edges,n):
    for r in range(n+1):
        for I in combinations(range(n),r):
            mask=sum(1<<j for j in I)
            if all(mask&e for e in edges):return r,I
    raise AssertionError()

# Independently validate all Singer differences and protected Sidon prefixes.
assert all(len(set(D))==len(D) and
           len({(x-y)%v for x in D for y in D if x!=y})==v-1 and
           len({a+b for i,a in enumerate(A) for b in A[i:]})==len(A)*(len(A)+1)//2
           for v,D,A in SOURCES.values())

EXPECTED={
 5:(930,205,{2:354,3:576}),
 7:(2052,319,{2:12,3:1206,4:834}),
 25:(234360,9708,{15:3840,16:3972,17:6876,18:78780,19:125856,20:15036})
}
for q,(v,D,A) in SOURCES.items():
    n=len(D);H=Counter();states=total=0
    for u in range(1,v):
        if gcd(u,v)>1:continue
        transformed=[u*x%v for x in D]
        cuts=sorted({0}|{x+1 for x in transformed if x<v-1})
        for i,c in enumerate(cuts):
            weight=(cuts[i+1] if i+1<len(cuts) else v)-c
            B=[(x-c)%v for x in transformed]
            cover=n-alpha_exact(graph(A,B),n)
            H[cover]+=weight;states+=1;total+=weight
    assert (total,states,dict(H))==EXPECTED[q],(q,total,states,H)
    print('PASS AB/AB q',q,'pairs',total,'states',states,'histogram',dict(sorted(H.items())))

v,D,A=SOURCES[7]
B=tuple((29*x-12)%v for x in D);T=49
supp=full_edges(A,B,T)
k,deleted=min_cover_small(supp,len(D))
assert k==2 and deleted==(3,6)
V=sorted(A+tuple(T+x for j,x in enumerate(B) if j not in deleted))
assert V==[1,8,17,22,23,49,69,92,94,102,105]
assert len({a+b for i,a in enumerate(V) for b in V[i:]})==66
print('PASS full q7 extension:',V,'2-deletion minimum')
H=Counter()
for u in range(1,v):
    if gcd(u,v)>1:continue
    for c in range(v):
        B=tuple((u*x-c)%v for x in D)
        for T in range(47,57):
            cost,_=min_cover_small(full_edges(A,B,T),len(D))
            H[cost]+=1
assert dict(H)=={2:6,3:6171,4:13356,5:987},H
print('PASS all 20,520 q7 full instances:',dict(sorted(H.items())))
