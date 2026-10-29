#!/usr/bin/env python3
"""Fully exhaustive low-deletion test over ALL affine Singer source switch + cut pairs.
Independent incidence masks, not importing prior scripts.
"""
from itertools import combinations
from math import gcd
import json

DATA=[(5,31,(12,16,18,21,28,29)),(7,57,(3,19,21,29,32,33,38,53))]
def signed_spectrum(d,v):
    # Literal integer absolute differences, bits 1..v-1.
    s=sorted(d);masks=[0]*len(s)
    allmask=0
    for i in range(len(s)):
        for j in range(i+1,len(s)):
            bit=1 << (s[j]-s[i]);allmask|=bit
            masks[i]|=bit;masks[j]|=bit
    assert allmask.bit_count()==len(s)*(len(s)-1)//2
    return allmask,masks

def run(q,v,D):
    d0=[signed_spectrum([(d+c)%v for d in D],v) for c in range(v)]
    d1=[signed_spectrum([(u*d+c)%v for d in D],v) for u in range(1,v) if gcd(u,v)==1 for c in range(v)]
    mincost=3;witness=None
    budgetCounts={"pairs":0,"one_deletion_possible":0,"two_deletions_possible":0,"overlap_zero":0}
    for c1,(p,P) in enumerate(d0):
        for idx,(t,T) in enumerate(d1):
            budgetCounts['pairs']+=1
            inter=p&t
            if not inter:budgetCounts['overlap_zero']+=1;mincost=0;witness=(c1,idx);continue
            full=P+T
            if any((inter&~a)==0 for a in full):
                budgetCounts['one_deletion_possible']+=1;mincost=min(mincost,1);witness=(c1,idx)
                continue
            # enough to check exact <=2 because independent full-mask reachability
            two=any((inter&~(full[i]|full[j]))==0 for i in range(len(full)) for j in range(i+1,len(full)))
            if two:
                budgetCounts['two_deletions_possible']+=1
                mincost=min(mincost,2);witness=(c1,idx)
    return {"q":q,"v":v,"all_source_cuts":budgetCounts,'global_min_deletions_in_this_affine_class':mincost,'two_deletion_witness_index_if_any':witness}
if __name__=='__main__':print(json.dumps([run(*x) for x in DATA],indent=2))
