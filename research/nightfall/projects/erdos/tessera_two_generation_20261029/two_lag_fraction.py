#!/usr/bin/env python3
"""Exact rational two-lag boundary-corrected PSD identity for Erdős #36.
Internal algebraic unit test, not a new lower bound or an external proof review.
"""
from fractions import Fraction as F
from random import Random


def pieces(v):
    h = F(2, len(v))
    return [(i*h, (i+1)*h, F(x)) for i,x in enumerate(v)]


def overlap(a,b,t):
    return max(F(0), min(a[1], b[1]-t)-max(a[0], b[0]-t))


def R(v,t):
    p=pieces(v)
    return sum((overlap(a,b,t)*a[2]*(1-b[2]) for a in p for b in p), F(0))


def boundary(v,t):
    """B(t)=integral f(x)*(2-1_I(x+t)-1_I(x-t)) dx, t>=0."""
    assert t>=0
    p=pieces(v)
    def strip(a,lo,hi):
        return max(F(0), min(a[1],hi)-max(a[0],lo))*a[2]
    return sum((strip(a,0,min(t,F(2)))+strip(a,max(F(0),F(2)-t),F(2)) for a in p),F(0))


def energy(v,t):
    """Direct integration of (F(x)-2F(x+t)+F(x+2t))^2 over R."""
    p=pieces(v)
    cuts=set()
    for shift in (F(0),t,2*t):
        for a,b,_ in p:
            cuts.add(a-shift);cuts.add(b-shift)
    cuts=sorted(cuts)
    def val(x):
        return next((z for a,b,z in p if a<=x<b),F(0))
    return sum(((cuts[i+1]-cuts[i])*(val((cuts[i]+cuts[i+1])/2)-
           2*val((cuts[i]+cuts[i+1])/2+t)+val((cuts[i]+cuts[i+1])/2+2*t))**2
           for i in range(len(cuts)-1)),F(0))


def S(v):
    h=F(2,len(v))
    return max(R(v,k*h) for k in range(-len(v),len(v)+1))


def check(v,t):
    assert all(0<=x<=1 for x in v)
    assert sum((F(x) for x in v),F(0))*F(2,len(v))==1
    r0=R(v,F(0));s1=R(v,t)+R(v,-t);s2=R(v,2*t)+R(v,-2*t)
    b1=boundary(v,t);b2=boundary(v,2*t)
    raw=4*s1-s2-6*r0
    corrected=raw+4*b1-b2
    assert corrected==energy(v,t), (v,t,corrected,energy(v,t))
    assert corrected>=0
    return raw,corrected


def main():
    # Bare two-lag positivity is FALSE even at constant f=1/2.
    raw,positive=check([F(1,2),F(1,2)],F(1,2))
    assert raw==F(-1,2) and positive==F(1,2)
    # Exact negative control for the missing zero-extension boundary term.
    assert raw<0 and raw+4*boundary([F(1,2)]*2,F(1,2))-boundary([F(1,2)]*2,F(1))==positive
    tests=0
    rng=Random(20261029)
    for n in (2,3,4,6,8):
        for _ in range(30):
            a=[F(rng.randrange(21),20) for _ in range(n-1)]
            # Mirror-complement profile has mass one exactly.
            v=a+[F(1,2)]+[1-z for z in reversed(a)]
            for t in (F(1,5),F(1,2),F(3,4)):
                check(v,t);tests+=1
    for n in (1,2,3,4,8):
        v=[F(x) for _ in range(n) for x in (1,0)]
        check(v,F(1,n));tests+=1
        # The same N cell averages cannot distinguish S=1 from S=1/2.
        assert S(v)==1 and S([F(1,2)]*n)==F(1,2)
    print(f'PASS exact corrected two-lag PSD identity; {tests} rational cases; raw constant counterexample -1/2, corrected +1/2')

if __name__=='__main__':main()
