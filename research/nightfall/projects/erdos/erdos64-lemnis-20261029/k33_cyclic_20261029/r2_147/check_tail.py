#!/usr/bin/env python3
"""Exact integer-voltage spectrum; complements modular-147 transfer certificate."""
from collections import Counter, defaultdict
W={(1,4):1,(1,5):5,(2,4):17,(2,5):64}
ADJ={v:tuple(range(3,6)) if v<3 else tuple(range(3)) for v in range(6)}
def dv(u,v):
    a,b=sorted((u,v))
    return (1 if u<3 else -1)*W.get((a,b),0)
def spectrum(length):
    counts=Counter()
    for root in range(6):
        for first in ADJ[root]:
            current={(root,first,dv(root,first)):1}
            for length_so_far in range(2,length+1):
                later=defaultdict(int)
                for (prev,cur,volt),number in current.items():
                    for nxt in ADJ[cur]:
                        if nxt!=prev:later[(cur,nxt,volt+dv(cur,nxt))]+=number
                current=later
            for (prev,cur,volt),number in current.items():
                if cur==root and prev!=first:counts[volt]+=number
    return counts
data={n:spectrum(n) for n in (4,6,8,10,16)}
assert {n:sum(c.values()) for n,c in data.items()}=={4:72,6:72,8:648,10:1800,16:133128}
assert all(0 not in c for c in data.values())
assert max(abs(v) for c in data.values() for v in c)==256
assert 256 in {abs(v) for v in data[16]}
assert all(all(v%m!=0 for v in c) for m in [257,258,1009] for c in data.values())
print('PASS all lengths 4,6,8,10,16: nonzero integer voltage, |V|<=256')
print('PASS: every modulus >=257 excludes these cyclically nonbacktracking base walks')
print('PASS: length 16 realizes |V|=256; m=256 needs explicit simple-cycle control')
