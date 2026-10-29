#!/usr/bin/env python3
"""Independent permutation-monodromy and nonregular iterated double-cover tests."""
from itertools import combinations
from random import Random
from collections import Counter


def make_perm_cover(n,edges,N,perm):
    adj=[set() for _ in range(n*N)]
    for u,v in edges:
        p=perm[(min(u,v),max(u,v))]
        assert sorted(p)==list(range(N))
        for sheet in range(N):
            w=sheet if u<v else p.index(sheet)
            z=p[sheet] if u<v else sheet
            a=u*N+w; b=v*N+z
            adj[a].add(b);adj[b].add(a)
    assert sum(map(len,adj))==2*len(edges)*N
    return adj

def simple_cycle(adj,L):
    # Independent depth-first cycle oracle, no use of voltage/group code.
    for root in range(len(adj)):
        stack=[(root,[root],{root})]
        while stack:
            v,path,seen=stack.pop()
            if len(path)==L:
                if root in adj[v]:return path
                continue
            for w in adj[v]:
                if w>root and w not in seen:
                    stack.append((w,path+[w],seen|{w}))
    return None


def lift_path(path,perm,N):
    ans=[]
    x=0
    for _ in range(N):
        for a,b in zip(path,path[1:]):
            ans.append(a*N+x)
            if a<b:x=perm[(a,b)][x]
            else:x=perm[(b,a)].index(x)
        if x==0:break
    assert len(ans)==len(set(ans))
    assert ans[0]==path[0]*N
    return ans


def sheet_cycle_lengths(p):
    seen=set();result=[]
    for i in range(len(p)):
        if i in seen:continue
        x=i;c=0
        while x not in seen:
            seen.add(x);c+=1;x=p[x]
        assert x==i
        result.append(c)
    return sorted(result)

# Nonregular 8-sheeted cover of C4: permutation has cycles of lengths 3 and 5.
C4=[(0,1),(1,2),(2,3),(0,3)]
sigma=[1,2,0,4,5,6,7,3]
assert sheet_cycle_lengths(sigma)==[3,5]
p={e:list(range(8)) for e in C4};p[(0,1)]=sigma
adj=make_perm_cover(4,C4,8,p)
assert all(len(nbrs)==2 for nbrs in adj)
assert simple_cycle(adj,12) and simple_cycle(adj,20)
assert not simple_cycle(adj,4) and not simple_cycle(adj,8) and not simple_cycle(adj,16) and not simple_cycle(adj,32)
assert len(adj)==32
print('PASS: 8-sheeted C4 cover with monodromy (3)(5) gives C12 disjoint C20, no power-of-two cycle')

# General 2-cover step: lift each edge with two possible transpositions.
def double_cover(adj,rng):
    n=len(adj);out=[set() for _ in range(2*n)]
    for i in range(n):
        for j in adj[i]:
            if i>=j:continue
            flip=rng.randrange(2)
            for s in (0,1):
                a=2*i+s;b=2*j+(s^flip)
                out[a].add(b);out[b].add(a)
    assert all(len(out[2*i])==len(adj[i]) and len(out[2*i+1])==len(adj[i]) for i in range(n))
    return out

base=[set() for i in range(4)]
for a,b in combinations(range(4),2):base[a].add(b);base[b].add(a)
rng=Random(160402)
for i in range(30):
    G=base
    # Each 2-lift doubles or preserves some power-two base cycle.
    for depth in (1,2,3):
        G=double_cover(G,rng)
        sizes=[L for L in (4,8,16,32) if L<=len(G) and simple_cycle(G,L)]
        assert sizes,(i,depth)
print('PASS: 30 independently sampled towers of three arbitrary 2-lifts of K4 preserve power-of-two cycles')
