#!/usr/bin/env python3
"""Adversarial small-universe oracle and invalid-Q7 controls for depth5.py.
This independently enumerates every selected subset rather than using the
optimized hitting-set recursion from the claimed theorem checker.
"""
from itertools import combinations
import random
import depth5

def brute(groups,r,universe):
    for size in range(r+1):
        for picks in combinations(range(universe),size):
            if all(set(picks).intersection(g) for g in groups):
                return set(picks)
    return None

rng=random.Random(1729)
checks=0
for n in range(3,10):
    for trial in range(170):
        groups=[tuple(sorted(rng.sample(range(n),rng.randint(1,min(n,3)))))
                for _ in range(rng.randint(1,9))]
        for budget in range(0,min(n,5)+1):
            fast=depth5.transverse(groups,budget)
            oracle=brute(groups,budget,n)
            assert (fast is None)==(oracle is None),("hitting discrepancy",n,groups,budget)
            if fast is not None:
                D={j for j in range(n) if (fast>>j)&1}
                assert len(D)<=budget and all(D.intersection(g) for g in groups)
            checks+=1

# Independently enumerate all cliques on 8 vertices, including k=6.
clique_checks=0
for trial in range(200):
    n=8
    graph=[0]*n
    adj=set()
    for i,j in combinations(range(n),2):
        if rng.randrange(2):
            adj.add((i,j))
            graph[i]|=1<<j;graph[j]|=1<<i
    for k in (2,3,4,5,6):
        expected={tuple(v) for v in combinations(range(n),k)
                  if all((a,b) in adj for a,b in combinations(v,2))}
        actual=set(depth5.k_cliques(graph,k))
        assert expected==actual,("clique discrepancy",k,trial)
        clique_checks+=1

edges,squares,incident=depth5.cube()
old=[(v,v|(1<<d)) for d in range(7) for v in range(128) if not (v&(1<<d))]
perm=[{e:i for i,e in enumerate(edges)}[e] for e in old]
mask=depth5.MASKS.read_text().splitlines()[0]
seed=depth5.decode(mask,perm)
assert len(seed)==304 and all(len(seed.intersection(sq))<=3 for sq in squares)
# A count-preserving witness mutation must trigger an independent C4 failure.
missing=[x for x in range(448) if x not in seed]
selected=None
for fresh in missing:
    tight=[set(sq)-{fresh} for sq in incident[fresh] if len(seed.intersection(sq))==3]
    if tight:
        blocks=set().union(*tight)
        oldedge=next((e for e in seed if e not in blocks),None)
        if oldedge is not None:
            selected=(seed-{oldedge})|{fresh}
            break
assert selected is not None and len(selected)==304
assert any(len(selected.intersection(sq))==4 for sq in squares)
try:
    depth5.verify_one(selected,edges,squares,incident)
except AssertionError:
    pass
else:
    raise AssertionError("Invalid C4-bearing 304-edge witness was accepted")
print("PASS: %d naive transversal comparisons; %d brute-force clique checks; invalid 304-edge C4 negative control rejected."%(checks,clique_checks))
