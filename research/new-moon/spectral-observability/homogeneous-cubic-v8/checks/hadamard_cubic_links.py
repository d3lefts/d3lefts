#!/usr/bin/env python3
"""Exact integer Hadamard pure-cubic link controls, not a conjecture proof."""
from math import isqrt
from itertools import combinations

def check(k):
    n=1<<(2*k)
    s=isqrt(n)
    assert s*s==n
    H=[[1 if (a&e).bit_count()%2==0 else -1
        for e in range(n)] for a in range(n)]
    for a in range(n):
        for b in range(n):
            assert sum(H[a][e]*H[b][e] for e in range(n))==(n if a==b else 0)
    bent=[-1 if sum(((e>>t)&1)*((e>>(t+k))&1)
        for t in range(k))%2 else 1 for e in range(n)]
    transform=[sum(H[a][e]*bent[e] for e in range(n)) for a in range(n)]
    assert set(map(abs,transform))=={s}
    den=n*s
    assert sum(map(abs,transform))==den # B=1 witness
    assert den*den==n**3                 # V=n^2/den^2=1/n
    assert n**4==n*den**2               # V^2=M=n/den^2=1/n^2
    assert n*n==s*den                  # link l1 matching cost=s
    print(f'PASS n={n}: HHt=nI, bent witness B=1, V=1/{n}, M=1/{n*n}, link cost={s}')
for k in (1,2,3):
    check(k)

n=4
edges=[frozenset((a,n+e,2*n+e)) for a in range(n) for e in range(n)]
cover=3*n+1
delete=3*n+1
for mask in range(1<<(3*n)):
    T={i for i in range(3*n) if (mask>>i)&1}
    size=len(T)
    if size<cover and all(e&T for e in edges):
        cover=size
    if size<delete:
        rem=[e for e in edges if not e&T]
        if all(len(x&y)<=1 for x,y in combinations(rem,2)):
            delete=size
assert (cover,delete)==(n,n-1)
print('PASS n=4: all 4096 deletion sets; min cover=4, min linearization delete=3')
print('LIMIT: no unrestricted influence proof or independent novelty review')
