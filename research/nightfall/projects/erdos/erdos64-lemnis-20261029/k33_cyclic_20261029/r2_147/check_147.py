#!/usr/bin/env python3
"""Self-contained exact certificate for the Lemnis 147r cyclic K3,3 family."""
from collections import defaultdict
from hashlib import sha256

P = 147
W = {(1,4):1, (1,5):5, (2,4):17, (2,5):64}
LENS = (4,6,8,10,16)
ADJ = tuple(tuple(range(3,6)) if u < 3 else tuple(range(3)) for u in range(6))

def dv(u,v):
    a,b=sorted((u,v))
    return W.get((a,b),0) * (1 if u<3 else -1)

def spectrum(n):
    # Closed cyclic nonbacktracking walk transfer; retain first edge to exclude end backtracking.
    out = defaultdict(int)
    for root in range(6):
        for first in ADJ[root]:
            states = {(root,first,dv(root,first)):1}
            for step in range(2,n+1):
                nxt=defaultdict(int)
                for (prev,cur,vol),mult in states.items():
                    for y in ADJ[cur]:
                        if y!=prev: nxt[cur,y,(vol+dv(cur,y))%P]+=mult
                states=nxt
            for (prev,cur,vol),mult in states.items():
                if cur==root and prev!=first:out[vol]+=mult
    return out

results=[]
for n in LENS:
    sp=spectrum(n)
    assert 0 not in sp, (n,sp[0])
    results.append((n,sum(sp.values()),len(sp)))
assert results == [(4,72,18),(6,72,12),(8,648,90),(10,1800,78),(16,133128,146)],results

def positive(word):
    base=list(map(int,word));fiber=0;vertices=set();fiber_min=0;fiber_max=0
    for u,v in zip(base,base[1:]+base[:1]):
        assert v in ADJ[u]
        assert (u,fiber%P) not in vertices,('collision',u,fiber)
        vertices.add((u,fiber%P))
        fiber+=dv(u,v)
        fiber_min=min(fiber_min,fiber);fiber_max=max(fiber_max,fiber)
    assert fiber==0
    return len(vertices), (fiber_min,fiber_max)
assert positive('031405130415')==(12,(-5,1))
assert positive('03140523041325140314031403140314')==(32,(-64,1))
print('PASS: all cyclically nonbacktracking base walks of lengths 4,6,8,10,16 have nonzero voltage modulo 147')
print('counts length,total,distinct-residues:',results)
print('PASS: C12 and C32 are literal simple lifted cycles with zero integer voltage')
print('THEOREM: all cyclic covers of moduli 147*r, r>=1, with constant weights (1,5,17,64) have girth 12, avoid C16 and contain C32')
