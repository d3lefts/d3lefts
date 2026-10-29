#!/usr/bin/env python3
"""Original sums and direct insertion oracle. Independent of difference SAT representation."""
from itertools import combinations_with_replacement

def sums(A):
    out={}
    for a,b in combinations_with_replacement(A,2):
        t=a+b
        if t in out:return None
        out[t]=(a,b)
    return out

def classify(A,N):
    A=tuple(sorted(A));occupied=sums(A)
    if occupied is None:return {'sidon':False,'saturated':False,'holes':None}
    holes=[];covered={}
    for x in range(1,N+1):
        if x in A:continue
        old=sums((*A,x))
        if old is not None:holes.append(x)
        else:
            # Independently find the lexicographically first exact collision.
            seen={};hit=None
            for a,b in combinations_with_replacement(sorted((*A,x)),2):
                sm=a+b
                if sm in seen:
                    hit={'pair1':seen[sm],'pair2':(a,b)};break
                seen[sm]=(a,b)
            assert hit is not None
            covered[x]=hit
    return {'sidon':True,'saturated':not holes,'holes':holes,'blockers':covered}

if __name__=='__main__':
    print(classify((8,48,68,69,71,75,104,120),144)['saturated'])
