#!/usr/bin/env python3
"""Independent finite witness search over two distinct GF9 polynomial presentations."""
from itertools import product
from collections import Counter
from random import Random

class GF9:
    def __init__(self, c0, c1):
        self.c0, self.c1 = c0, c1
        self.elems = tuple(product(range(3), repeat=2))
        self.z, self.one, self.two, self.t = (0,0), (1,0), (2,0), (0,1)
    def add(self,a,b): return ((a[0]+b[0])%3,(a[1]+b[1])%3)
    def neg(self,a): return ((-a[0])%3,(-a[1])%3)
    def sub(self,a,b): return self.add(a,self.neg(b))
    def mul(self,a,b):
        return ((a[0]*b[0]+self.c0*a[1]*b[1])%3,
                (a[0]*b[1]+a[1]*b[0]+self.c1*a[1]*b[1])%3)
    def sq(self,a): return self.mul(a,a)
    def inv(self,a):
        assert a != self.z
        return next(b for b in self.elems if self.mul(a,b)==self.one)
    def dot(self,a,x):
        t=self.z
        for ai,xi in zip(a,x): t=self.add(t,self.mul(ai,xi))
        return t
    def root(self,s): return next(a for a in self.elems if self.sq(a)==s)

def decoder(F,x):
    k=len(x);obs=[F.sq(v) for v in x];roots=[F.root(z) for z in obs]
    support=[j for j,z in enumerate(obs) if z!=F.z]
    if not support: return tuple(F.z for _ in x),k
    anchor=support[0];signs={anchor:F.one};cost=k
    for i in range(0,len(support)-1,2):
        block=support[1+i:3+i];basis=[F.one,F.t][:len(block)]
        s=F.z
        for b in basis:s=F.add(s,b)
        row=[F.z for _ in x]
        row[anchor]=F.mul(s,F.inv(roots[anchor]))
        for j,b in zip(block,basis):
            row[j]=F.mul(b,F.inv(roots[j]))
        measured=F.sq(F.dot(row,x));cost+=1
        choices=[]
        for options in product((F.one,F.two),repeat=len(block)):
            t=F.z
            for b,sgn in zip(basis,options):
                t=F.add(t,F.mul(b,F.add(F.one,sgn)))
            if F.sq(t)==measured:choices.append(options)
        assert len(choices)==1,(x,block,choices)
        for j,sgn in zip(block,choices[0]):signs[j]=sgn
    out=[F.z]*k
    for j in support:out[j]=F.mul(signs[j],roots[j])
    return tuple(out),cost

def signed(F,x,y):
    return x==y or x==tuple(F.neg(v) for v in y)

def kernel(F,rows,k):
    A=[list(row) for row in rows];m=len(A);pivot=[];r=0
    for j in range(k):
        i=next((t for t in range(r,m) if A[t][j]!=F.z),None)
        if i is None: continue
        A[r],A[i]=A[i],A[r]
        inv=F.inv(A[r][j]);A[r]=[F.mul(q,inv) for q in A[r]]
        for t in range(m):
            if t!=r and A[t][j]!=F.z:
                h=A[t][j]
                A[t]=[F.sub(v,F.mul(h,w)) for v,w in zip(A[t],A[r])]
        pivot.append(j);r+=1
    free=next((j for j in range(k) if j not in pivot),None)
    if free is None:return None
    x=[F.z]*k;x[free]=F.one
    for t,j in reversed(list(enumerate(pivot))):
        value=F.z
        for h in range(j+1,k):
            value=F.add(value,F.mul(A[t][h],x[h]))
        x[j]=F.neg(value)
    assert all(F.dot(row,x)==F.z for row in rows)
    return tuple(x)

def obstruction(F,rows,k):
    assert len(rows)<=2*k-2
    u=kernel(F,rows,k)
    if u is not None:
        v=tuple(F.z for _ in range(k))
    else:
        n=min(k-1,len(rows))
        u=kernel(F,rows[:n],k)
        v=kernel(F,rows[n:],k)
        assert u is not None and v is not None
        u,v=(tuple(F.add(a,b) for a,b in zip(u,v)),
             tuple(F.sub(a,b) for a,b in zip(u,v)))
    assert not signed(F,u,v)
    assert all(F.sq(F.dot(row,u))==F.sq(F.dot(row,v)) for row in rows)

def audit(F):
    counts=Counter()
    for k in range(1,5):
        for x in product(F.elems,repeat=k):
            y,n=decoder(F,x)
            assert signed(F,x,y)
            assert n<=k+(k//2)
            counts[(k,n)]+=1
    rng=Random(20261116+F.c0+F.c1)
    attacks=0
    for k in range(2,6):
        for m in range(2*k-1):
            for _ in range(30):
                rows=[tuple(rng.choice(F.elems) for _ in range(k)) for _ in range(m)]
                obstruction(F,rows,k);attacks+=1
    assert sum(counts.values())==7380 and attacks==720
    print("PASS GF9 polynomial",F.c0,F.c1,"vectors",sum(counts.values()),
          "adversarial matrices",attacks,"histogram",dict(sorted(counts.items())))

if __name__=="__main__":
    audit(GF9(2,0)) # irreducible t^2+1
    audit(GF9(1,2)) # irreducible t^2+t+2
    print("Scope: finite k<=4 and 720 nonadaptive configurations per field model, not all-k Lean closure.")
