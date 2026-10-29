#!/usr/bin/env python3
"""Exact unrestricted Sidon append capacity: q=5,7 Singer prefix, all new subsets.
No solver, no field/model assumption on the *new* marks. Python stdlib.
"""
from collections import Counter
from hashlib import sha256
FAMILIES=(
 (31,(0,1,3,8,12,18),(32,46),(1,31,128,22),(1,27,69,0)),
 (57,(0,1,3,13,32,36,43,52),(90,98,112),(1,57,692,1683,644,3),(1,23,73,19,0,0)),
)
def sidon(V):
    sums=set()
    for i,a in enumerate(V):
        for b in V[i:]:
            z=a+b
            if z in sums:return False
            sums.add(z)
    return True

def verify(v,D,Bbest,expected_cliques,expected_good):
    K=len(D);A=tuple(d+1 for d in D)
    differences=sorted((a-b)%v for a in D for b in D if a!=b)
    assert differences==list(range(1,v))
    assert sidon(A) and sidon(A+Bbest)
    assert all(v<=b<2*v for b in Bbest)
    forbidden={b-a for i,a in enumerate(D) for b in D[i+1:]}
    assert len(forbidden)==K*(K-1)//2
    neighbors=[frozenset(j for j in range(i+1,v) if j-i not in forbidden) for i in range(v)]
    cliques=Counter();valid=Counter()
    def dfs(R,P):
        k=len(R)
        cliques[k]+=1
        if sidon(A+tuple(v+x for x in R)):valid[k]+=1
        for j,x in enumerate(P):
            dfs(R+(x,),tuple(y for y in P[j+1:] if y in neighbors[x]))
    dfs((),tuple(range(v)))
    levels=range(len(expected_cliques))
    assert tuple(cliques[k] for k in levels)==expected_cliques
    assert tuple(valid[k] for k in levels)==expected_good
    assert set(cliques)==set(levels)
    assert max(k for k,n in valid.items() if n)==len(Bbest)
    assert not sidon(A+(v,v+1)) # deliberate negative control
    print('PASS',v,'K',K,'A',A,'cliques',dict(sorted(cliques.items())),
          'valid',dict(sorted(valid.items())),'global_max_append',len(Bbest),'witness',Bbest)
    return (v,tuple(sorted(cliques.items())),tuple(sorted(valid.items())),Bbest)
if __name__=='__main__':
    data=[verify(*args) for args in FAMILIES]
    digest=sha256(repr(data).encode()).hexdigest()
    assert digest=='2c8de726cdd8878ae2eee1a8ec569550f026d2c69fd5ec9067fdc4fc1481ca6d'
    print('PASS SHA256',digest)
