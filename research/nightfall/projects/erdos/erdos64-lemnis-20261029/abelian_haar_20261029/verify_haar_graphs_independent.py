#!/usr/bin/env python3
"""Independent literal Cayley/Haar graph generator + simple-cycle DFS; no symbolic winding data."""
from itertools import product
from random import Random
from collections import Counter

# Vertices (side,a) in Z_m x Z_n; side=0 and 1 distinguish the bipartition.
def haar(m,n,g,h):
    points=list(product(range(m),range(n)))
    P={x:i for i,x in enumerate(points)}
    off=((0,0),g,h)
    N=len(points)
    graph=[set() for _ in range(2*N)]
    for x in points:
        i=P[x]
        for a,b in off:
            v=P[((x[0]+a)%m,(x[1]+b)%n)]+N
            graph[i].add(v);graph[v].add(i)
    assert all(len(neighbors)==3 for neighbors in graph)
    return tuple(tuple(sorted(s)) for s in graph)

def cycle(g,length):
    N=len(g)
    used=bytearray(N)
    def dfs(st,v,depth):
        if depth==length:
            return st in g[v]
        for u in g[v]:
            if u<=st or used[u]:continue
            used[u]=1
            if dfs(st,u,depth+1):return True
            used[u]=0
        return False
    for root in range(N):
        used[root]=1
        for nbr in g[root]:
            if nbr<=root:continue
            used[nbr]=1
            if dfs(root,nbr,2):return True
            used[nbr]=0
        used[root]=0
    return False

# Another independently implemented literal walk; uses user-supplied alphabet only.
witness=(0,1,0,1,0,1,2,0,1,0,2,0,1,2,1,2)
def check_witness(m,n,g,h):
    x=y=0
    used={(0,0,0)}
    for k,z in enumerate(witness):
        dx,dy=((0,0),g,h)[z]
        if k%2==0: x=(x+dx)%m;y=(y+dy)%n
        else:x=(x-dx)%m;y=(y-dy)%n
        v=((k+1)%2,x,y)
        if k==15:assert v==(0,0,0)
        else:
            assert v not in used,(m,n,g,h,k,v)
            used.add(v)
    return True

counts=Counter(); rng=Random(20261029)
# All cyclic three-offset graphs with 7 <= modulus <= 65, excluding automorphism duplicates not required.
for m in range(7,66):
    for a in range(2,m):
        g=haar(m,1,(1,0),(a,0));counts['cyclic']+=1
        if cycle(g,4):continue
        counts['cyclic_no4']+=1
        if cycle(g,8):continue
        counts['cyclic_no4no8']+=1
        assert check_witness(m,1,(1,0),(a,0))
        assert cycle(g,16)
# Genuine noncyclic groups Z_p x Z_p with independent offsets
for p in (5,7,11,13):
    for _ in range(25):
        g=(rng.randrange(p),rng.randrange(p));h=(rng.randrange(p),rng.randrange(p))
        if g==(0,0) or h==(0,0) or g==h:continue
        G=haar(p,p,g,h);counts['noncyclic']+=1
        if cycle(G,4):continue
        counts['noncyclic_no4']+=1
        if cycle(G,8):continue
        counts['noncyclic_no4no8']+=1
        assert check_witness(p,p,g,h)
        assert cycle(G,16)
print(dict(counts))
assert counts['cyclic_no4no8']>0 and counts['noncyclic_no4no8']>0
print('PASS independent literal graph and simple-cycle checks')
