#!/usr/bin/env python3
"""Independent F_(p^2) test using actual multiplication, division, and square oracles."""
from itertools import product
from random import Random

class Field:
    def __init__(self,p):
        self.p=p
        self.D=next(t for t in range(2,p) if pow(t,(p-1)//2,p)==p-1)
        self.zero=(0,0); self.one=(1,0)
        self.roots={}
        for x in product(range(p),repeat=2):
            self.roots.setdefault(self.mul(x,x),x)
        assert len(self.roots)==(p*p+1)//2
    def add(self,a,b):
        return ((a[0]+b[0])%self.p,(a[1]+b[1])%self.p)
    def mul(self,a,b):
        p=self.p
        return ((a[0]*b[0]+self.D*a[1]*b[1])%p,
                (a[0]*b[1]+a[1]*b[0])%p)
    def power(self,x,n):
        y=self.one
        while n:
            if n&1:y=self.mul(y,x)
            x=self.mul(x,x)
            n>>=1
        return y
    def div(self,a,b):
        return self.mul(a,self.power(b,self.p*self.p-2))
    def times(self,a,c):
        return (a[0]*c%self.p,a[1]*c%self.p)
    def neg(self,a):
        return self.times(a,-1)

def check(p,anchor,coeffs,trials=3000):
    F=Field(p)
    k=len(coeffs)+1
    lookup={}
    for eps in product((-1,1),repeat=k-1):
        z=anchor
        for w,e in zip(coeffs,eps):
            z=F.add(z,F.times(w,e))
        y=F.mul(z,z)
        assert y not in lookup,('phase collision',p,eps)
        lookup[y]=eps
    rng=Random(20261029+p)
    for case in range(trials):
        x=[(rng.randrange(p),rng.randrange(p)) for _ in range(k)]
        if case%19==0:x=[F.zero]*k
        elif case%17==0:x[0]=F.zero
        square=[F.mul(z,z) for z in x]
        u=[F.roots[y] for y in square]
        support=[j for j,z in enumerate(x) if z!=F.zero]
        if not support:
            assert not any(u)
            continue
        t=support[0]
        others=[j for j in support if j!=t]
        at=anchor
        for j in range(len(others),len(coeffs)):
            at=F.add(at,coeffs[j])  # known +1 phase padding
        z=F.mul(F.div(at,u[t]),x[t])
        for w,j in zip(coeffs,others):
            z=F.add(z,F.mul(F.div(w,u[j]),x[j]))
        phases=lookup[F.mul(z,z)]
        assert all(v==1 for v in phases[len(others):])
        reconstruction=[F.zero]*k
        reconstruction[t]=u[t]
        for j,e in zip(others,phases):
            reconstruction[j]=F.times(u[j],e)
        assert reconstruction==x or reconstruction==[F.neg(a) for a in x]
    return len(lookup),trials

def main():
    cases=[
        (5,(2,0),[(1,0),(0,1),(0,2)]),
        (7,(3,3),[(1,0),(0,1),(0,2),(2,0)]),
        (31,(15,15),[(1,0),(2,0),(4,0),(8,0),
                      (0,1),(0,2),(0,4),(0,8)]),
    ]
    for p,anchor,coeffs in cases:
        n,checked=check(p,anchor,coeffs)
        print('PASS: p=',p,'extension=2,phase-patterns=',n,'signals=',checked)

if __name__=='__main__':
    main()
