#!/usr/bin/env python3
"""Standalone exact verifier for characteristic-three cancellation packing.
All arithmetic is native integer arithmetic in F_3[T]/(monic irreducible).
No decoder package imports; no random network calls.
"""
from itertools import product
from math import ceil
from random import Random

class Field3:
    def __init__(self, poly):
        assert poly[-1] == 1
        self.poly = tuple(poly)
        self.r = len(poly)-1
        self.Q = 3**self.r
        self.digits = [tuple(i//3**h % 3 for h in range(self.r)) for i in range(self.Q)]
        self.M = [[self._mul(a,b) for b in range(self.Q)] for a in range(self.Q)]
        self.squares = [self.M[a][a] for a in range(self.Q)]
        self.roots = {}
        for a, w in enumerate(self.squares): self.roots.setdefault(w,a)
        assert len(self.roots) == (self.Q+1)//2
        self.inv = [0] + [self._pow(a,self.Q-2) for a in range(1,self.Q)]
        assert all(self.M[a][self.inv[a]]==1 for a in range(1,self.Q))
    def _mul(self,a,b):
        t=[0]*(2*self.r-1)
        for i,x in enumerate(self.digits[a]):
            for j,y in enumerate(self.digits[b]): t[i+j]+=x*y
        for h in range(2*self.r-2,self.r-1,-1):
            c=t[h]%3
            for j in range(self.r):t[h-self.r+j]-=c*self.poly[j]
        return sum((t[i]%3)*3**i for i in range(self.r))
    def _pow(self,a,n):
        z=1
        while n:
            if n&1:z=self.M[z][a]
            a=self.M[a][a]; n>>=1
        return z
    def add(self,a,b):return sum(((a//3**i+b//3**i)%3)*3**i for i in range(self.r))
    def sub(self,a,b):return sum(((a//3**i-b//3**i)%3)*3**i for i in range(self.r))
    def mul(self,a,b):return self.M[a][b]
    def div(self,a,b):return self.M[a][self.inv[b]]
    def basis(self,j):return 3**j

def decode(F,x):
    k=len(x)
    obs=[F.squares[v] for v in x]
    reps=[F.roots[w] for w in obs]
    support=[j for j,w in enumerate(obs) if w]
    out=[0]*k
    if not support:return out,k
    anchor=support[0]
    out[anchor]=reps[anchor]
    queries=k
    others=support[1:]
    for start in range(0,len(others),F.r):
        block=others[start:start+F.r]
        anchor_sign=F.div(x[anchor],reps[anchor]); assert anchor_sign in (1,2)
        linear=0
        for index,j in enumerate(block):
            sign=F.div(x[j],reps[j]); assert sign in (1,2)
            beta=F.basis(index)
            linear=F.add(linear,F.mul(beta,F.add(anchor_sign,sign)))
        # The oracle supplies only the square of the mixed K-linear form.
        returned=F.squares[linear]
        witness=F.roots[returned]
        for index,j in enumerate(block):
            # A basis coefficient vanishes exactly if the signs disagree.
            equal=(F.digits[witness][index] != 0)
            out[j]=reps[j] if equal else F.mul(2,reps[j])
        queries+=1
    return out,queries

def equivalent(F,x,y):
    return all(a==b for a,b in zip(x,y)) or all(F.mul(2,a)==b for a,b in zip(x,y))

def exhaustive(F,k,cap=None):
    n=0; random=Random(78123+F.r*19+k)
    total=F.Q**k
    cases=product(range(F.Q),repeat=k) if cap is None or total<=cap else (tuple(random.randrange(F.Q) for _ in range(k)) for _ in range(cap))
    strict=0
    for x in cases:
        y,m=decode(F,x)
        assert equivalent(F,x,y),(F.r,k,x,y)
        s=sum(v!=0 for v in x)
        expected=k+ceil(max(s-1,0)/F.r)
        assert m==expected,(F.r,k,x,m,expected)
        previous=k+ceil(max(s-1,0)/(F.r-1))
        if m<previous:strict+=1
        n+=1
    return n,strict

def information_lower(r,k):
    n1=(3**r+1)//2
    nk=(3**(r*k)+1)//2
    m=0;bound=1
    while bound<nk:bound*=n1;m+=1
    return m

def one_query_collision(F,h,seed=1123):
    """Find collision for any affine row on h>r independent signs."""
    rand=Random(seed+F.r+h)
    coeffs=[rand.randrange(F.Q) for _ in range(h+1)]
    outputs={}
    for phases in product((1,2),repeat=h):
        v=coeffs[0]
        for c,s in zip(coeffs[1:],phases):v=F.add(v,F.mul(c,s))
        obs=F.squares[v]
        if obs in outputs and outputs[obs]!=phases:
            return coeffs,outputs[obs],phases,obs
        outputs[obs]=phases
    raise AssertionError('pigeonhole collision missing')

if __name__=='__main__':
    setups=[([1,0,1],[1,2,3,4],None),([1,2,0,1],[1,2,3,4],None),([2,1,0,0,1],[1,2,3],None)]
    total=0;improvements=0
    for polynomial,ks,cap in setups:
        F=Field3(polynomial)
        for k in ks:
            n,better=exhaustive(F,k,cap=10000 if F.Q**k>20000 else None)
            total+=n;improvements+=better
            print(f'PASS F_3^{F.r}, k={k}, cases={n}, improved_vs_previous={better}, information_lower={information_lower(F.r,k)}, new_upper={k+ceil((k-1)/F.r)}',flush=True)
        for h in [F.r+1,F.r+2]:
            cs,a,b,v=one_query_collision(F,h)
            print(f'PASS sharp_one_query_obstruction r={F.r} h={h} collision={a},{b} value={v}',flush=True)
    print(f'PASS total={total} exact reconstructions, strict_improvements={improvements}, 6 independent one-query obstruction witnesses')

