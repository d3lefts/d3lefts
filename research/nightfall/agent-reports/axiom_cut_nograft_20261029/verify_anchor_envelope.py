#!/usr/bin/env python3
"""Exact affine-isometry ceiling from direct pair-sum and insertion checks."""
import json
ANCHORS={
 'S1':[16,49,50,56,78,93,104,125,139,149],
 'S2':[49,50,56,78,93,104,125,139,149,166],
}
def sidon(A):
    sums=[]
    for j,a in enumerate(A):
        for b in A[j:]:sums.append(a+b)
    return len(set(sums))==len(sums)
def maximal(A,left,right):
    if not sidon(A) or min(A)<left or max(A)>right:return False,[]
    holes=[]
    for x in range(left,right+1):
        if x not in A and sidon(sorted(A+[x])):holes.append(x)
    return not holes,holes
rows=[]
for name,S in ANCHORS.items():
    assert sidon(S)
    left=min(S)
    while maximal(S,left-1,max(S))[0]:left-=1
    right=max(S)
    while maximal(S,left,right+1)[0]:right+=1
    assert not maximal(S,left-1,right)[0]
    assert not maximal(S,left,right+1)[0]
    B=sorted(a-left+1 for a in S)
    N=right-left+1
    ok,holes=maximal(B,1,N)
    assert ok
    next_ok,holes2=maximal(B,1,N+1)
    assert not next_ok and holes2==[N+1]
    # Reflection preserves the entire collision equality structure,
    # so every translated/reflected copy with all marks in [1,N']
    # has N'<=N.
    rows.append({'anchor':name,'N':N,'translation':1-left,'marks':B,
                 'pair_sums':len(B)*(len(B)+1)//2,
                 'blocked_exclusions':N-len(B),'first_unblocked':N+1})
    print('PASS',name,'N',N,'maximal',ok,'first_unblocked',holes2)
with open('/mnt/data/axiom_own_wrap/anchor_receipt.json','w') as f:json.dump(rows,f,indent=2)
