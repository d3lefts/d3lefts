#!/usr/bin/env python3
"""TESSERA #100: exact Singer repair-hypergraph integrality-gap checker.
Pure Python 3 standard library. Separate sum oracle and exhaustive cover/packing.
"""
from itertools import combinations
from collections import defaultdict
from hashlib import sha256
import json

CASES = (
  dict(v=31,D=(0,1,3,8,12,18),A=(1,2,4),cut=8,T=24,h=7,
       H=((0,3),(3,4),(3,5),(4,5),(0,1,4),(0,1,5))),
  dict(v=57,D=(0,1,3,13,32,36,43,52),A=(1,6),cut=1,T=43,h=14,
       H=((0,5),(6,7),(1,2,6),(1,2,7))),
)
def reps(values):
    d=defaultdict(list)
    for i,a in enumerate(values):
        for j in range(i,len(values)):
            d[a+values[j]].append((i,j))
    return d
def audit(case):
    v,D,A,cut,T,h = (case[k] for k in ('v','D','A','cut','T','h'))
    assert sorted((a-b)%v for a in D for b in D if a!=b)==list(range(1,v))
    assert len(reps(A))==len(A)*(len(A)+1)//2
    N=max(A);L=h+N+1
    assert h<v/4 and v-h>2*N and 2*L<v and v-h<=T<=v-(h+1)//2
    Q=tuple(sorted((d-cut)%v for d in D)); B=tuple(T+x for x in Q)
    m=len(A)
    sums=reps(A+B)
    H=set()
    repeats={}
    for total,pairings in sums.items():
        if len(pairings)>1:
            repeats[str(total)]=[[ (A+B)[i],(A+B)[j] ] for i,j in pairings]
        for a,b in combinations(pairings,2):
            support=tuple(sorted({i-m for i in (*a,*b) if i>=m}))
            assert support
            H.add(support)
    H=tuple(sorted(H,key=lambda e:(len(e),e)))
    assert H==tuple(sorted(case['H'],key=lambda e:(len(e),e)))
    # Cover oracle enumerates deletion subsets of candidate marks.
    cover=None
    for k in range(len(B)+1):
        for S in combinations(range(len(B)),k):
            if all(set(e)&set(S) for e in H):
                cover=S; break
        if cover is not None: break
    assert cover is not None
    # Independent matching oracle enumerates disjoint families of hyperedges.
    packing=None
    for k in range(len(H),-1,-1):
        for inds in combinations(range(len(H)),k):
            elems=[i for j in inds for i in H[j]]
            if len(elems)==len(set(elems)):
                packing=inds; break
        if packing is not None: break
    assert len(cover)==3 and len(packing)==2
    # Verify all 0- and 1- and 2-deletion choices fail, directly via sums.
    for k in (0,1,2):
        for S in combinations(range(len(B)),k):
            V=tuple(sorted(A+tuple(x for i,x in enumerate(B) if i not in S)))
            assert any(len(p)>1 for p in reps(V).values())
    V=tuple(sorted(A+tuple(x for i,x in enumerate(B) if i not in cover)))
    assert all(len(p)==1 for p in reps(V).values())
    result=dict(v=v,D=list(D),prefix=list(A),cut=cut,T=T,h=h,L=L,
                Q=list(Q),B=list(B),repeated_sums=dict(sorted(repeats.items())),
                supports=[list(e) for e in H],matching=2,
                packing=[list(H[i]) for i in packing],cover_number=3,
                deletions=list(cover),survivors=list(V),verified_sums=len(reps(V)))
    return result

if __name__=='__main__':
    output=[audit(c) for c in CASES]
    digest=sha256(json.dumps(output,sort_keys=True,separators=(',',':')).encode()).hexdigest()
    print(json.dumps(output,sort_keys=True,indent=2))
    print('PASS: two planar Singer difference sets, exact near-boundary windows')
    print('PASS: matching=2, cover=3, all two-deletion repairs rejected')
    print('SHA256:',digest)
