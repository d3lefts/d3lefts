#!/usr/bin/env python3
"""Independent exact partial trace audit, no signed-Hamming kernel, no symplectic logic."""
from itertools import product,combinations
from collections import defaultdict

def scaled_Q(entries,k=4):
    # entries = sequence (word, integer coefficient), for diagonal matrix
    ans=0
    for mask in range(1<<k):
        reduced=defaultdict(int)
        retain=[i for i in range(k) if mask>>i&1==0]
        for word,c in entries:
            reduced[tuple(word[i] for i in retain)]+=c
        tr_count=k-len(retain)
        ans += (-1 if tr_count%2 else 1) * (1<<(k-tr_count))*sum(v*v for v in reduced.values())
    return ans # 2^k Q

k=4
B=list(product((0,1),repeat=k))
X=list(product((0,1,2), repeat=k))
pair_checks=0
for a,b in combinations(X,2):
  for s in (-1,1):
    assert scaled_Q([(a,1),(b,s)],k)>=0
    pair_checks+=1
n=0
for y in set(X)-set(B):
    bad_for_y=0
    for a,b in combinations(B,2):
        # Try all four sign choices; a=-1 scale redundant.
        values=[scaled_Q([(a,1),(b,bs),(y,ys)],k) for bs in (-1,1) for ys in (-1,1)]
        if min(values)<0:
            assert min(values)==-3,(y,a,b,values)
            bad_for_y+=1
            n+=1
    assert bad_for_y==64,(y,bad_for_y)
assert n==65*64
A=[(x,y,(x+y)%3,(x+2*y)%3) for x in range(3) for y in range(3)]
for a,b,c in combinations(A,3):
    assert min(scaled_Q([(a,1),(b,bs),(c,cs)],k) for bs in (-1,1) for cs in (-1,1))==-3
print({'status':'PASS','pair_checks':pair_checks,'negative_triplets_16_cube_plus_one':n,'source_code_negative_triplets':84,'Q_per_obstruction':'-3/16'})
