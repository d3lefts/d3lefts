#!/usr/bin/env python3
"""Independent small-q test: overlap of positive integer differences of cyclic Singer cuts.
Only q in (5,7) tested. Standard library, no external data.
"""
from math import gcd, comb, ceil
from collections import Counter
import json

def mul(x,y,q):
    a=[0]*5
    for i,xi in enumerate(x):
        for j,yj in enumerate(y):a[i+j]=(a[i+j]+xi*yj)%q
    # t^3=-t-1 for x^3+x+1, reduce highest first
    for k in (4,3):
        z=a[k]
        a[k]=0;a[k-2]=(a[k-2]-z)%q;a[k-3]=(a[k-3]-z)%q
    return tuple(a[:3])

def power(x,n,q):
    r=(1,0,0)
    while n:
        if n&1:r=mul(r,x,q)
        x=mul(x,x,q);n>>=1
    return r

def factor_primes(n):
    out=[];d=2
    while d*d<=n:
        if n%d==0:
            out.append(d)
            while n%d==0:n//=d
        d+=1
    if n>1:out.append(n)
    return out

def source(q):
    # explicitly validate polynomial has no roots (cubic => irreducible)
    assert all((x*x*x+x+1)%q for x in range(q))
    order=q**3-1; v=q*q+q+1
    for a in range(q):
        for b in range(q):
            for c in range(q):
                g=(a,b,c)
                if g==(0,0,0):continue
                if all(power(g,order//p,q)!=(1,0,0) for p in factor_primes(order)):
                    D=[]
                    x=(1,0,0)
                    for i in range(v):
                        t1=power(x,q,q);t2=power(x,q*q,q)
                        tr=tuple((x[j]+t1[j]+t2[j])%q for j in range(3))
                        assert tr[1:]==(0,0), (q,i,tr)
                        if tr[0]==0:D.append(i)
                        x=mul(x,g,q)
                    assert len(D)==q+1
                    differences=[(a-b)%v for a in D for b in D if a!=b]
                    assert len(differences)==v-1 and set(differences)==set(range(1,v))
                    return g,D
    raise RuntimeError('no generator')

def posdiff(D):
    return {b-a for i,a in enumerate(sorted(D)) for b in sorted(D)[i+1:]}

def audit(q):
    g,D=source(q)
    v=q*q+q+1;K=q+1
    units=[u for u in range(1,v) if gcd(u,v)==1]
    # independently compute full absolute diff sets under every cut/multiplier
    raw=[]
    for u in units:
        raw.append([posdiff({(u*d+c)%v for d in D}) for c in range(v)])
    P=[posdiff({(d+c)%v for d in D}) for c in range(v)]
    count=Counter(); minval=comb(K,2); maxval=0; minw=[]; maxw=[]
    sum_i=0
    for iu,u in enumerate(units):
        for c1,p in enumerate(P):
            for c2,t in enumerate(raw[iu]):
                overlap=len(p&t)
                sum_i+=overlap; count[overlap]+=1
                if overlap<minval:minval=overlap;minw=[u,c1,c2]
                if overlap>maxval:maxval=overlap;maxw=[u,c1,c2]
    # Every residue difference r is realized as an INTEGER positive difference
    # in exactly v-r cuts for each source and each unit multiplier.
    for iu in range(len(units)):
        hits=Counter(d for s in raw[iu] for d in s)
        assert all(hits[r]==v-r for r in range(1,v))
    hitsP=Counter(d for s in P for d in s)
    assert all(hitsP[r]==v-r for r in range(1,v))
    expected_num=sum((v-r)**2 for r in range(1,v))
    expected_den=v*v
    assert sum_i*expected_den == expected_num*sum(count.values())
    assert sum(count.values())==len(units)*v*v
    return {"q":q,"v":v,"K":K,"primitive":g,"source_D":D,
      "affine_unit_count":len(units),"cut_pair_trials":sum(count.values()),
      "min_positive_overlap":minval,"min_witness_u_c1_c2":minw,
      "max_positive_overlap":maxval,"max_witness_u_c1_c2":maxw,
      "histogram":dict(sorted(count.items())),
      "mean_overlap_exact":{"numerator":expected_num,"denominator":expected_den},
      "min_deletions_from_overlap":ceil(minval/(K-1)),
      "universal_cut_averaging_check":"PASS"}
if __name__=='__main__':
    print(json.dumps([audit(5),audit(7)],indent=2))
