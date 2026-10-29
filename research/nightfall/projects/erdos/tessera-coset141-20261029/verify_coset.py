#!/usr/bin/env python3
"""Standalone exact subgroup-profile and quotient-autocorrelation verifier."""
from collections import Counter
from math import gcd
SOURCES={
31:(0,1,3,8,12,18),
57:(0,7,16,21,22,24,34,53),
651:(21,72,81,86,88,105,197,217,247,278,316,334,357,360,
368,405,430,434,440,462,483,498,525,537,538,584)
}

def perfect(v,D):
    assert len(D)*(len(D)-1)==v-1
    diffs=Counter((a-b)%v for a in D for b in D if a!=b)
    assert diffs==Counter({j:1 for j in range(1,v)})

def profile(v,D,h):
    assert v%h==0
    s=v//h;n=[0]*s
    for d in D:n[d%s]+=1
    assert sum(n)==len(D)
    assert sum(x*(x-1) for x in n)==h-1
    assert sum(x*x for x in n)==len(D)+h-1
    for t in range(1,s):
        assert sum(n[j]*n[(j+t)%s] for j in range(s))==h
    return n

def derived_q25(D):
    v=651;h=31;s=21;n=profile(v,D,h)
    assert n[0]==6 and sorted(n)==[1]*20+[6]
    S={i for i,x in enumerate(n) if x==1}
    assert S==set(range(1,s))
    for t in range(1,s):
        corr=sum(1 for x in S if (x+t)%s in S)
        assert corr==31-6*((t in S)+((-t)%s in S))
        assert corr in (19,25,31)

def exhaustive_affine(D):
    v=651;s=21;count=0
    for u in range(1,v):
        if gcd(u,v)!=1:continue
        for c in range(s):
            n=profile(v,[(u*d+c)%v for d in D],31)
            assert n[c]==6 and all(x<=1 for j,x in enumerate(n) if j!=c)
            S={j for j,x in enumerate(n) if x==1}
            assert len(S)==20
            for t in range(1,s):
                corr=sum(1 for j in S if (j+t)%s in S)
                rhs=31-6*(((c+t)%s in S)+((c-t)%s in S))
                assert corr==rhs
            count+=1
    assert count==7560
    return count

def false_control(D):
    trial=list(D);v=651
    candidate=next(x for x in range(v)
                   if x not in trial and x%21==trial[1]%21)
    assert candidate!=trial[1] and trial[1]%21!=0
    trial[2]=candidate
    n=[0]*21
    for x in trial:n[x%21]+=1
    assert n[0]==6 and max(n[1:])>=2
    try: perfect(v,trial)
    except AssertionError:pass
    else:raise AssertionError('Invalid duplicate-rich source accepted')

if __name__=='__main__':
    for v,D in SOURCES.items():
        perfect(v,D)
        for h in range(2,v+1):
            if v%h==0:
                n=profile(v,D,h)
                print('v',v,'h',h,'profile',sorted(Counter(n).items()))
    derived_q25(SOURCES[651])
    print('AFFINE CLASSES',exhaustive_affine(SOURCES[651]))
    false_control(SOURCES[651])
    print('PASS: exact coset moments, all quotient correlations, affine families, negative control')
