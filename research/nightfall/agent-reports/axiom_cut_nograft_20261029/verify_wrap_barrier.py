#!/usr/bin/env python3
"""Independent finite-field reconstruction and exact cyclic-cut collision audit."""
from math import isqrt
from hashlib import sha256
import json

def factor(n):
    f=[];i=2
    while i*i<=n:
        if n%i==0:
            f.append(i)
            while n%i==0:n//=i
        i+=1
    if n>1:f.append(n)
    return f

def field(p):
    c=next(c for c in range(2,p) if pow(c,(p-1)//2,p)==p-1)
    mul=lambda a,b:((a[0]*b[0]+c*a[1]*b[1])%p,(a[0]*b[1]+a[1]*b[0])%p)
    def power(a,n):
        z=(1,0)
        while n:
            if n&1:z=mul(z,a)
            a=mul(a,a);n//=2
        return z
    L=p*p-1
    theta=next((a,b) for a in range(p) for b in range(1,p) if all(power((a,b),L//f)!=(1,0) for f in factor(L)))
    S=[];z=(1,0)
    for e in range(L):
        if z[1]==theta[1]:S.append(e)
        z=mul(z,theta)
    assert z==(1,0) and len(S)==p
    return c,theta,sorted(S)

def sidon(A):
    seen={}
    for i,a in enumerate(A):
        for b in A[i:]:
            if a+b in seen:return False
            seen[a+b]=(a,b)
    return True

def run():
    A=[1,2,4,8,13]
    dvals=sorted({b-a for i,a in enumerate(A) for b in A[i+1:]})
    results=[]
    for p in (17,19,23,29,31):
        c,theta,S=field(p);L=p*p-1;H={j*(p+1) for j in range(p-1)}
        assert sidon(S)
        ordered={}
        for a in S:
            for b in S:
                if a!=b:
                    d=(a-b)%L
                    assert d not in ordered
                    ordered[d]=(a,b)
        assert set(ordered)==set(range(1,L))-H
        wrap_counts={}
        for d in dvals:
            a,b=ordered[d]
            counts=[0,0]
            for shift in range(L):
                A1=(a+shift)%L;B1=(b+shift)%L
                assert (A1-B1)%L==d
                if A1-B1==d:counts[0]+=1
                else:
                    assert A1-B1==d-L
                    counts[1]+=1
            assert counts==[L-d,d]
            wrap_counts[str(d)]=counts[1]
        # Distinct implementation of mixed-term check: enumerate raw A+(T+S) sums.
        T=2*L+100
        survivors=[]
        for shift in range(L):
            block=sorted((s+shift)%L for s in S)
            points=sorted(A+[T+s for s in block])
            if sidon(points): survivors.append(shift)
        assert len(survivors)==0, survivors # sharper 1-and-2 wrap obstruction
        # Sharpness control: a two-point prefix with only difference 1 has exactly
        # one collision-free cut, because the unique +1 edge must wrap.
        short_prefix=[1,2]
        survivors2=[]
        for shift in range(L):
            block=sorted((s+shift)%L for s in S)
            if sidon(sorted(short_prefix+[T+s for s in block])):survivors2.append(shift)
        assert len(survivors2)==1, survivors2
        results.append({'q':p,'L':L,'nonresidue_c':c,'theta':theta,'block_sha256':sha256(','.join(map(str,S)).encode()).hexdigest(),'distinct_nonzero_differences':len(ordered),'forbidden_subgroup_size':p-1,'old_difference_values':dvals,'zero_mixed_collision_rotations':survivors,'two_point_prefix_one_free_cut':survivors2,'wrap_counts':wrap_counts})
    for r in results:
        print('PASS',r['q'],'L',r['L'],'diffs',r['distinct_nonzero_differences'],'zero_collision_rotations',r['zero_mixed_collision_rotations'],'two_mark_sharp',r['two_point_prefix_one_free_cut'])
    with open('/mnt/data/axiom_own_wrap/field_receipt.json','w') as f:json.dump(results,f,indent=2)

if __name__=='__main__':run()
