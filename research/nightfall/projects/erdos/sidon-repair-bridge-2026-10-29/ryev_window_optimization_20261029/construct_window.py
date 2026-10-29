#!/usr/bin/env python3
"""Construct real optimized-window finite Sidon extensions for several prime q.

Imports only Axiom's Bose-Chowla finite-field block generator, not his
selection, collision-counting, deletion or verification routines. This is a
separate implementation of the *new* two-endpoint window and all exact bounds.
"""
from fractions import Fraction as F
from pathlib import Path
import json
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent.parent/"prefix_boundary_20261029"))
from construct_prefix import field_and_sidon

A=(1,2,4,8,13)
R=len(A)
def ceil(v):return -(-v.numerator//v.denominator)
def floor(v):return v.numerator//v.denominator

def construct(p):
    L,S,theta,d=field_and_sidon(p)
    alpha=F(3,64*R);beta=F(1,32*R)
    J=ceil(alpha*L)+max(A)+2
    tmin=ceil((1-alpha)*L)
    tmax=floor((1-beta)*L)
    assert 2*J+1<=L and tmin>2*max(A) and tmin<=tmax

    # New independent O(L) rotation chooser: sliding window modular counts.
    flags=[0]*L
    for s in S: flags[s]=1
    flags2=flags+flags
    pref=[0]
    for x in flags2:pref.append(pref[-1]+x)
    chosen=None
    for offset in range(L):
        low_start=(-offset)%L
        high_start=(L-J-offset)%L
        v=pref[low_start+J+1]-pref[low_start]
        h=pref[high_start+J]-pref[high_start]
        candidate=(v+h,h,offset)
        if chosen is None or candidate<chosen:chosen=candidate
    _,_,offset=chosen
    V=sorted((s+offset)%L for s in S)
    low=[s for s in V if s<=J]
    high=[s for s in V if s>=L-J]
    v=len(low);h=len(high)
    W=F(p*(2*J+1),L)
    assert v+h<=W
    # Exact interval counts: every dangerous triple fixes one T.
    collision_map={}
    for high_point in high:
        for i,u in enumerate(low):
            for v2 in low[i:]:
                for old in A:
                    t=old+high_point-u-v2
                    if tmin<=t<=tmax:
                        collision_map.setdefault(t,[]).append((high_point,u,v2,old))
    T=min(range(tmin,tmax+1),key=lambda t:(len(collision_map.get(t,[])),t))
    touched=collision_map.get(T,[])
    removed={h0 for h0,_,_,_ in touched}
    # Two-old mixed sums: all prescribed old differences are checked
    # directly in the rotated finite block without trusting a Sidon oracle.
    values=set(V)
    for i,x in enumerate(A):
        for y in A[i+1:]:
            delta=y-x
            for s in V:
                if s+delta in values:
                    removed.add(s)
    kept=[s for s in V if s not in removed]
    U=sorted(A+tuple(T+s for s in kept))
    assert len(U)==len(A)+len(kept)
    assert len(set(U))==len(U)
    pair_sums=set()
    for i,u in enumerate(U):
        for z in U[i:]:
            pair=u+z
            assert pair not in pair_sums,("invalid Sidon candidate",p,i,pair)
            pair_sums.add(pair)
    bound=F(R*(R-1),2)+F(R,tmax-tmin+1)*(F(2,27)*W**3+F(1,8)*W**2)
    assert len(removed)<=bound,("finite deletion bound failed",p,len(removed),str(bound))
    assert U[-1]<=(2-beta)*L
    return {"q":p,"block":len(S),"translation":T,"rotatedBy":offset,
            "low":len(low),"high":len(high),"dangerousTriples":len(touched),
            "removed":len(removed),"boundFloatDisplayOnly":round(float(bound),6),
            "finalMarks":len(U),"maximum":U[-1],"pairSums":len(pair_sums),
            "aboveHalfSquared":2*len(U)*len(U)>U[-1],
            "newWindow":[tmin,tmax]}

if __name__=="__main__":
    for q in (101,257,1009):
        print(json.dumps(construct(q),sort_keys=True),flush=True)
    print("PASS: actual optimized-window finite constructions at q=101,257,1009; exact deletion budget and integer Sidon property")
