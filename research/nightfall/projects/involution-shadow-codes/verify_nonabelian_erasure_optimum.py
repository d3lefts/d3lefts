#!/usr/bin/env python3
"""Finite exhaustive test of optimal erasure resilience for the nonabelian S4 witness.
Uses raw orbit messages to decide recovery and independently enumerates every
13-ball-in-6-bin allocation for all possible retained coordinate counts.
"""
import json
from collections import Counter
from math import comb
from pathlib import Path

source=Path(__file__).with_name("S4_nonabelian_certificate.json")
x=json.loads(source.read_text());tab=x["cayley_table"];sigma=x["automorphism"]
trans=x["translations"];g=len(tab);m=len(trans);q=x["claims"]["label_count"]
assert (g,m,q)==(24,13,6)
code=[tuple(min(tab[i][t],sigma[tab[i][t]]) for t in trans) for i in range(g)]
pair_masks={
    sum(1<<j for j in range(m) if code[u][j]==code[v][j])
    for u in range(g) for v in range(u+1,g)
}
failed=Counter()
for mask in range(1<<m):
    if any(mask&c==mask for c in pair_masks):failed[mask.bit_count()]+=1
assert {r:failed[r] for r in range(m+1)}=={0:1,1:13,2:8,3:1,**{r:0 for r in range(4,14)}}

def parts(total,n):
    if n==1:
        yield (total,)
    else:
        for i in range(total+1):
            for tail in parts(total-i,n-1):
                yield (i,)+tail

a,b=divmod(m,q)
balanced=(a+1,)*b+(a,)*(q-b)
target=[sum(comb(k,r) if k>=r else 0 for k in balanced) for r in range(1,m+1)]
assert [failed[r] for r in range(1,m+1)]==target
configurations=ties=0
for ns in parts(m,q):
    configurations+=1
    scores=[sum(comb(k,r) if k>=r else 0 for k in ns) for r in range(1,m+1)]
    assert all(u>=v for u,v in zip(scores,target)),ns
    ties+=scores==target
assert configurations==8568 and ties==6
print(json.dumps({
 "status":"PASS","group":"S4","surviving_coordinate_subsets":1<<m,
 "erasure_ambiguity_counts":dict(sorted(failed.items())),
 "allocations_checked":configurations,"globally_optimal_allocations":ties,
 "statement":"A balanced label allocation simultaneously minimizes every fixed-size erasure-failure count"
},indent=2))
