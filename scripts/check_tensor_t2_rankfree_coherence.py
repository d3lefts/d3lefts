#!/usr/bin/env python3
"""Exact F2 audit of four-slot classification for PR #1016.

Independent rational two-query circuit: direct acceptance, path expansion,
uniform Walsh coefficients, primitive/repeated/zero-triple partition.
Finite evidence only, not a general simulator or Lean proof.
"""
from fractions import Fraction as F
from collections import defaultdict, Counter
from itertools import product


def rows(L):
    R=[1]; n=1
    for _ in range(L):
        R=R+[x<<n for x in R]+[(x<<n)|x for x in R]
        n*=2
    return [0]+R


def rank(masks):
    piv={}
    for m in masks:
        x=m
        while x:
            n=x.bit_length()-1
            if n in piv:
                x^=piv[n]
            else:
                piv[n]=x
                break
    return len(piv)


def chi(z,s):
    return F(-1) if (z&s).bit_count()%2 else F(1)


def dot(a,b):
    return sum((x*y for x,y in zip(a,b)),F(0))


def main():
    D=rows(2); n=len(D)
    assert n==10
    psi=[F(4,5)]+[-F(1,5)]*(n-1)
    v=[F(i) for i in range(1,n+1)]
    denom=dot(v,v)
    U=[[F(i==j)-2*v[i]*v[j]/denom for j in range(n)] for i in range(n)]
    assert all(sum((U[i][k]*U[j][k] for k in range(n)),F(0))==F(i==j)
               for i in range(n) for j in range(n))
    assert dot(psi,psi)==1
    # Full-rank valid terminal effect; P=I/2+|psi><psi|/4.
    P=[[F(i==j,2)+psi[i]*psi[j]/4 for j in range(n)] for i in range(n)]
    paths={(a,b):psi[a]*U[b][a] for a in range(n) for b in range(n)}
    entries=defaultdict(lambda:F(0))
    groups=defaultdict(lambda:F(0))
    count=Counter()
    single=defaultdict(lambda:F(0))
    crossed=defaultdict(lambda:F(0))
    for a,b,c,d in product(range(n),repeat=4):
        z=D[a]^D[b]^D[c]^D[d]
        amp=paths[a,b]*paths[c,d]*P[b][d]
        if not amp:
            continue
        entries[z]+=amp
        if a==c or b==d:
            single[z]+=amp
        else:
            crossed[z]+=amp
        labels=[D[a],D[b],D[c],D[d]]
        if len(set(labels))<4:
            cat='repeated'
        elif rank([x for x in labels if x])==len([x for x in labels if x]):
            cat='primitive'
        else:
            assert z==0 or any((labels[i]^labels[j]^labels[k])==0
                                for i in range(4) for j in range(i+1,4)
                                for k in range(j+1,4))
            cat='zero-triple' if z else 'zero-frequency'
        groups[z,cat]+=amp
        count[z,cat]+=1
    actual=[]
    for s in range(16):
        x=[chi(D[a],s)*psi[a] for a in range(n)]
        y=[sum((U[b][a]*x[a] for a in range(n)),F(0))*chi(D[b],s)
           for b in range(n)]
        assert dot(y,y)==1
        f=F(1,2)+dot(psi,y)**2/4
        actual.append(f)
        assert f==sum((entries[z]*chi(z,s) for z in entries),F(0))
    for z in range(16):
        exact=sum((f*chi(z,s) for s,f in enumerate(actual)),F(0))/16
        assert exact==entries[z]
        assert single[z]+crossed[z]==entries[z]
        if z:
            assert sum((groups[z,cat] for cat in ('repeated','primitive','zero-triple')),F(0))==entries[z]
        else:
            assert sum((groups[z,cat] for cat in ('repeated','primitive','zero-frequency')),F(0))==entries[z]
    assert len(set(actual))==7
    assert any(crossed[z] for z in range(1,16))
    stats={k:sum(v for (z,cat),v in count.items() if cat==k and z)
           for k in ('repeated','primitive','zero-triple')}
    assert stats=={'repeated':4680,'primitive':3816,'zero-triple':864}
    print('PASS rational L=2 T2 circuit, 16 secrets and 7 nonconstant acceptance values')
    print('PASS direct/paths/Walsh and three-way nonzero-frequency partition',stats)
    print('PASS nonzero cross-stage coherence; not an all-circuit proof')


if __name__=='__main__':
    main()
