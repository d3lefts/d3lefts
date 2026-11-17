#!/usr/bin/env python3
"""Exact rational spot audits of the finite-mixture Q2 transfer identities."""
from fractions import Fraction
from itertools import product
from math import prod

def laws(n,a):
    states=list(product((-1,1),repeat=n))
    components=[]
    for z in (-1,1):
        d={x:prod((1+z*a*xj)/2 for xj in x) for x in states}
        assert sum(d.values())==1
        components.append(d)
    mix={x:(components[0][x]+components[1][x])/2 for x in states}
    assert sum(mix.values())==1
    return states,components,mix

def mean(states,law,f):
    return sum((law[x]*f(x) for x in states),Fraction(0))
def variance(states,law,f):
    m=mean(states,law,f)
    return mean(states,law,lambda x:(f(x)-m)**2)
def influence(states,law,f,i):
    groups={}
    for x in states:
        y=x[:i]+x[i+1:]
        p,v=groups.get(y,(Fraction(0),Fraction(0)))
        groups[y]=(p+law[x],v+law[x]*f(x))
    out=Fraction(0)
    for x in states:
        p,v=groups[x[:i]+x[i+1:]]
        out+=law[x]*(f(x)-v/p)**2
    return out

def audit(n,a):
    states,components,mix=laws(n,a)
    tests={
        'pair':lambda x:Fraction(x[0]*x[1]),
        'square_mean':lambda x:Fraction(sum(x)**2,n*n),
        'mean':lambda x:Fraction(sum(x),n),
    }
    for name,f in tests.items():
        v=variance(states,mix,f)
        vz=[variance(states,p,f) for p in components]
        mz=[mean(states,p,f) for p in components]
        between=sum(((m-(mz[0]+mz[1])/2)**2/2 for m in mz),Fraction(0))
        assert v==sum(vz)/2+between
        I=[influence(states,mix,f,i) for i in range(n)]
        Iz=[[influence(states,p,f,i) for i in range(n)] for p in components]
        assert all(I[i]>=(Iz[0][i]+Iz[1][i])/2 for i in range(n))
        assert (sum(vz)/2)**2 <= 212*max(I) # C2<106, m=2, B<=1
        if name=='mean':
            assert between==a*a and v==a*a+(1-a*a)/n
            assert all(Ii<=Fraction(1,n*n) for Ii in I)
        else:
            assert between==0
        print('PASS n=',n,'a=',a,'f=',name,'Var=',v,'H=',between,'maxI=',max(I))

if __name__=='__main__':
    for n in (3,4,5,6,8):
        audit(n,Fraction(1,3))
    print('All exact finite two-regime spot tests PASS; not a universal proof.')
