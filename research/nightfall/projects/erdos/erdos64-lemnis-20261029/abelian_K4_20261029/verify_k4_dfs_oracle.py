#!/usr/bin/env python3
"""Fully separate exact adjacency-DFS oracle for finite K4 cyclic voltage covers."""
from collections import Counter
from itertools import product

def graph(n,a,b,c):
    adj=[[] for _ in range(4*n)]
    volt={(0,1):0,(0,2):0,(0,3):0,(1,2):a,(1,3):b,(2,3):c}
    for (u,v),w in volt.items():
        for x in range(n):
            p=u*n+x;q=v*n+(x+w)%n
            adj[p].append(q);adj[q].append(p)
    assert len(adj)==4*n and all(len(x)==3 and len(set(x))==3 for x in adj)
    return adj

def has_cycle(adj,length):
    n=len(adj)
    # Deck translations make it sufficient to test starts (base, group=0),
    # though no assumed base-vertex transitivity is used.
    layers={}
    def rec(v,start,depth,seen):
        if depth==length:
            return start in adj[v]
        for nxt in adj[v]:
            mask=1<<nxt
            if not seen&mask and rec(nxt,start,depth+1,seen|mask):return True
        return False
    for base in range(4):
        s=base*(n//4)
        if rec(s,s,1,1<<s):return True
    return False

counts=Counter(); inspected=0
for m in range(3,10):
    for a,b,c in product(range(m),repeat=3):
        adj=graph(m,a,b,c)
        first=next((l for l in (4,8,16) if has_cycle(adj,l)),None)
        assert first is not None,(m,a,b,c,'NO POWER CYCLE')
        counts[first]+=1;inspected+=1
print('PASS truly independent DFS across',inspected,'cyclic K4 covers, first cycle histogram',dict(counts))
