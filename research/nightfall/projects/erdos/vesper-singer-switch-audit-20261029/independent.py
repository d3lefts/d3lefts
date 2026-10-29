#!/usr/bin/env python3
"""Separate exhaustive reconstruction and literal unordered-sum checker for two minimal witnesses.
No import of primary audit module; different pair-sum representation and deletion solver.
"""
from itertools import combinations
from collections import defaultdict
import json
CASES=[
    (5,31,[12,16,18,21,28,29],3,13,8),
    (7,57,[3,19,21,29,32,33,38,53],2,25,51),
]
def strong_sidon(S):
    pairs={}
    for i,a in enumerate(S):
        for j in range(i,len(S)):
            z=a+S[j]
            if z in pairs:return False,(pairs[z],(i,j),z)
            pairs[z]=(i,j)
    return True,None

def run(q,v,D,u,c1,c2):
    x=sorted((d+c1)%v for d in D)
    y=sorted((u*d+c2)%v for d in D)
    k=len(x)
    # Independent modular source check
    residues=defaultdict(list)
    for a in D:
        for b in D:
            if a!=b:residues[(a-b)%v].append((a,b))
    assert len(residues)==v-1 and all(len(t)==1 for t in residues.values())
    P={x[j]-x[i]:(i,j) for i in range(k) for j in range(i+1,k)}
    Q={y[j]-y[i]:(i,j) for i in range(k) for j in range(i+1,k)}
    common=sorted(set(P)&set(Q))
    # Exact hitting hyperedges. A cross pair sum collides precisely when differences match.
    edges=[tuple(sorted([P[d][0],P[d][1],k+Q[d][0],k+Q[d][1]])) for d in common]
    assert len(common)==len(edges)
    shifted=x+[a+10*v for a in y]
    assert strong_sidon(x)[0] and strong_sidon(y)[0]
    ok,bad=strong_sidon(shifted)
    assert not ok
    answer=None
    for t in range(2*k+1):
        for removed in combinations(range(2*k),t):
            rem=set(removed)
            if any(all(e not in rem for e in edge) for edge in edges):continue
            remaining=[shifted[i] for i in range(2*k) if i not in rem]
            valid,_=strong_sidon(remaining)
            assert valid, 'pair-sum checker rejects supposedly feasible cover'
            answer=(t,removed,remaining)
            break
        if answer:break
    assert answer
    return {'q':q,'v':v,'source_D':D,'cut1':x,'cut2':y,'common_differences':common,
        'hyperedges':edges,'min_removed_exact':answer[0],
        'removed_indices':list(answer[1]),'retained_two_block_integer_set':answer[2],
        'retained_cardinality':len(answer[2]),'certificate':'exact exhaustive hitting sets plus literal pair sums PASS'}
if __name__=='__main__':print(json.dumps([run(*x) for x in CASES],indent=2))
