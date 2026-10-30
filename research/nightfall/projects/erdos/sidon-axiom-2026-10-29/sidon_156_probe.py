#!/usr/bin/env python3
"""Bounded experiment only: tests one-mark lift of Huber's 144 witness."""
import json
from itertools import combinations
HUBER=(8,48,68,69,71,75,104,120)
NEAR=(49,50,56,78,93,104,125,139,149)
N=184

def score(A):
    A=tuple(sorted(A)); ds=[y-x for x,y in combinations(A,2)]
    if len(set(ds))!=len(ds):return None
    occ=set(A); D=set(ds)
    for a in A:
        for d in D: occ.add(a+d);occ.add(a-d)
    for a,b in combinations(A,2):
        if (a+b)%2==0:occ.add((a+b)//2)
    return [x for x in range(1,N+1) if x not in occ]

if __name__=='__main__':
    assert score(HUBER) is not None
    assert all(x<=144 or x in score(HUBER) for x in range(1,N+1) if x in score(HUBER))
    rows=[]
    for x in range(145,N+1):
        miss=score(HUBER+(x,))
        rows.append({"new_mark":x,"sidon":miss is not None,"missing":miss})
    data={"schema":"nightfall-sidon156-one-mark-lift-v1","date":"2026-10-29",
          "N":N,"source_witness":list(HUBER),"near_candidate":list(NEAR),
          "near_candidate_missing":score(NEAR),"one_mark_extensions":rows,
          "scope":"exhaustive only for the fixed 8-mark Huber witness; not exhaustive for all 9-mark sets"}
    print(json.dumps(data,indent=2,sort_keys=True))
