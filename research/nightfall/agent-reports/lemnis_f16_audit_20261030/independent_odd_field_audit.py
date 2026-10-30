#!/usr/bin/env python3
"""Lemnis independent proof falsifier: odd-p square orbit and gcd-power transfer.
Does not import producer sources. Python 3.11+ standard library.
"""
from itertools import product
from collections import Counter
from math import gcd, ceil
import hashlib

class QuadraticField:
    def __init__(self,p,d):
        assert all(d != (x*x)%p for x in range(p))
        self.p,self.d,self.q=p,d,p*p
        self.add=lambda a,b: ((a%p+b%p)%p)+p*((a//p+b//p)%p)
        self.neg=lambda a: ((-a%p)%p)+p*((-a//p)%p)
        self.mul=lambda a,b: ((a%p*b%p+d*(a//p)*(b//p))%p)+p*(((a%p)*(b//p)+(a//p)*(b%p))%p)
        self.pow=lambda a,e:self._pow(a,e)
        self.inv={a:next(b for b in range(1,p*p) if self.mul(a,b)==1) for a in range(1,p*p)}
        self.roots={self.mul(a,a):min(b for b in range(p*p) if self.mul(b,b)==self.mul(a,a)) for a in range(p*p)}
        assert len(self.roots)==(self.q+1)//2
        assert {a for a in range(self.q) if self.mul(a,a)==1}=={1,p-1}
    def _pow(self,a,e):
        v=1
        while e:
            if e&1:v=self.mul(v,a)
            a=self.mul(a,a);e//=2
        return v
    def lin(self,row,x):
        s=0
        for a,b in zip(row,x,strict=True): s=self.add(s,self.mul(a,b))
        return s
    def decode(self,x,e):
        p,q=self.p,self.q;k=len(x)
        assert gcd(e,q-1)==2
        t=e//2;it=pow(t,-1,(q-1)//2)
        sq=lambda a:self.pow(a,2)
        oracle=lambda row:self.pow(self.lin(row,x),e)
        # convert legal powered readings to square via invertible relabelling
        coords=[]
        for j in range(k):
            row=[0]*k;row[j]=1
            coords.append(self.pow(oracle(row),it))
        support=[i for i,z in enumerate(coords) if z]
        if not support:return (0,)*k,k
        roots={i:self.roots[coords[i]] for i in support}
        anchor=support[0];out=[0]*k;out[anchor]=roots[anchor];count=k
        basis=[1,p]
        for start in range(0,len(support)-1,2):
            block=support[1+start:3+start]
            row=[0]*k
            for i,b in enumerate(block):
                beta=basis[i]
                row[anchor]=self.add(row[anchor],self.mul(beta,self.inv[roots[anchor]]))
                row[b]=self.mul(beta,self.inv[roots[b]])
            y=self.pow(oracle(row),it);count+=1
            table={}
            for ph in product((1,p-1),repeat=len(block)):
                pre=0
                for i,z in enumerate(ph):pre=self.add(pre,self.mul(basis[i],(1+z)%p))
                key=sq(pre)
                assert key not in table,(p,e,ph)
                table[key]=ph
            assert y in table,(p,e,k,x,y,table)
            for i,z in zip(block,table[y],strict=True):out[i]=self.mul(z,roots[i])
        assert any(tuple(self.mul(h,v) for v in out)==x for h in (1,p-1)),(p,e,k,x,out)
        assert count==k+ceil((len(support)-1)/2)
        return tuple(out),count

def test(p,d,k,es):
    F=QuadraticField(p,d); q=p*p
    print(f'Field GF({q})=F_{p}[t]/(t²-{d}), k={k}, exponents={es}')
    assert all(gcd(e,q-1)==2 for e in es)
    n=q**k
    buckets=[]
    for e in es:
        hist=Counter(); reps=set()
        for x in product(range(q),repeat=k):
            z,c=F.decode(x,e)
            hist[c]+=1
            reps.add(z)
        want=(q**k+1)//2
        assert len(reps)==want,(len(reps),want)
        print(f' e={e} PASS all {n} signals, {want} sign-orbits, cost histogram {dict(sorted(hist.items()))}')
        buckets.append(hist)
    assert len(set(map(lambda c:tuple(sorted(c.items())),buckets)))==1

if __name__=='__main__':
    test(3,2,4,(2,6))
    test(5,2,3,(2,10))
    test(7,3,2,(2,10))
    print('CERTIFICATION: exhaustive finite checks; all-k theorem needs symbolic proof')
