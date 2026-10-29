#!/usr/bin/env python3
"""Independent exact audit: F_4 base subfield inside F_16 and F_64.
Powered oracle (a·x)^3, global ambiguity F_4^×. No dependencies.
"""
from itertools import product
import random
from math import ceil

class F2Power:
    def __init__(self,degree,poly,base=4):
        self.degree,self.poly,self.Q,self.q=degree,poly,1<<degree,base
        assert degree%2==0 and (poly>>degree)==1
        self.r=degree//2
        self.mask=(1<<degree)-1
        self.mul_table=[[self._mul(a,b) for b in range(self.Q)] for a in range(self.Q)]
        self.inv=[0]+[self.power(z,self.Q-2) for z in range(1,self.Q)]
        self.base=[0]+[z for z in range(1,self.Q) if self.power(z,3)==1]
        assert len(self.base)==4
        self.groupphases=self.base[1:]
        self.basis=[self.power(2,i) for i in range(self.r)]
        self.coords={}
        for v in product(self.base,repeat=self.r):
            z=0
            for i,c in enumerate(v):z ^= self.mul(c,self.basis[i])
            if z in self.coords:raise ValueError('F4 basis rank failed')
            self.coords[z]=v
        assert len(self.coords)==self.Q
        self.phase=[self.power(z,3) for z in range(self.Q)]
        self.roots={}
        for z,y in enumerate(self.phase):self.roots.setdefault(y,z)
        assert len(self.roots)==1+(self.Q-1)//3
    def _mul(self,a,b):
        result=0
        while b:
            if b&1:result ^=a
            b>>=1
            a<<=1
            if a & (1<<self.degree):a ^= self.poly
        return result&self.mask
    def mul(self,a,b):return self.mul_table[a][b]
    def power(self,a,n):
        z=1
        while n:
            if n&1:z=self.mul(z,a)
            a=self.mul(a,a);n>>=1
        return z
    def div(self,a,b):return self.mul(a,self.inv[b])

def decode(F,x):
    k=len(x)
    yy=[F.phase[v] for v in x]
    reps=[F.roots[y] for y in yy]
    support=[i for i,y in enumerate(yy) if y]
    y=[0]*k
    if not support:return y,k
    t=support[0];y[t]=reps[t]
    n=k
    for start in range(0,len(support)-1,F.r-1):
        block=support[1+start:1+start+F.r-1]
        mixed=F.div(x[t],reps[t])
        for i,j in enumerate(block,1):
            rowcoeff=F.div(F.basis[i],reps[j])
            mixed ^=F.mul(rowcoeff,x[j])
        value=F.phase[mixed]
        root=F.roots[value]
        c=F.coords[root]
        assert c[0] in F.groupphases
        for i,j in enumerate(block,1):
            phase=F.div(c[i],c[0])
            assert phase in F.groupphases
            y[j]=F.mul(phase,reps[j])
        n+=1
    return y,n

def run(degree,poly,k,limit=None):
    F=F2Power(degree,poly);n=0
    rnd=random.Random(739+degree*10+k)
    inputs=product(range(F.Q),repeat=k) if limit is None else [tuple(rnd.randrange(F.Q) for _ in range(k)) for _ in range(limit)]
    for x in inputs:
        y,m=decode(F,x)
        assert any(all(F.mul(a,t)==v for t,v in zip(x,y)) for a in F.groupphases),(degree,k,x,y)
        s=sum(bool(v) for v in x)
        assert m==k+ceil(max(s-1,0)/(F.r-1)),(degree,k,x,m)
        n+=1
    return n

def kernel(F,rows,k):
    mat=[list(row) for row in rows]; rank=0; piv=[]
    for col in range(k):
        q=next((j for j in range(rank,len(mat)) if mat[j][col]),None)
        if q is None:continue
        mat[rank],mat[q]=mat[q],mat[rank]
        z=F.inv[mat[rank][col]]
        mat[rank]=[F.mul(z,t) for t in mat[rank]]
        for j in range(len(mat)):
            if j!=rank and mat[j][col]:
                m=mat[j][col]
                mat[j]=[u^F.mul(m,v) for u,v in zip(mat[j],mat[rank])]
        piv.append(col);rank+=1
        if rank==len(mat):break
    if len(piv)==k:return None
    free=next(j for j in range(k) if j not in piv)
    vector=[0]*k;vector[free]=1
    for j,col in enumerate(piv):vector[col]=mat[j][free]
    for row in rows:assert xor_sum(F.mul(a,b) for a,b in zip(row,vector))==0
    return vector

def xor_sum(it):
    v=0
    for x in it:v^=x
    return v

def collision_audit(degree,poly,k,trial_count=500):
    F=F2Power(degree,poly);rand=random.Random(7391+degree*10+k)
    scalar=next(a for a in F.groupphases if a!=1)
    for it in range(trial_count):
        rows=[[rand.randrange(F.Q) for _ in range(k)] for _ in range(2*k-2)]
        null=kernel(F,rows,k)
        if null is not None:
            x=null;z=[0]*k
        else:
            u=kernel(F,rows[:k-1],k)
            v=kernel(F,rows[k-1:],k)
            assert u is not None and v is not None
            x=[a^b for a,b in zip(u,v)]
            z=[a^F.mul(scalar,b) for a,b in zip(u,v)]
        assert not any(all(F.mul(c,t)==a for t,a in zip(x,z)) for c in F.groupphases)
        for row in rows:
            assert F.phase[xor_sum(F.mul(a,b) for a,b in zip(row,x))]==F.phase[xor_sum(F.mul(a,b) for a,b in zip(row,z))]
    return trial_count

if __name__=='__main__':
    tests=[(4,0b10011,1,None),(4,0b10011,2,None),(4,0b10011,3,None),
           (6,0b1000011,2,None),(6,0b1000011,3,None),
           (8,0b100011101,3,4000),(8,0b100011101,5,4000)]
    n=0
    for d,poly,k,limit in tests:
        t=run(d,poly,k,limit)
        n+=t
        print(f'PASS q=4 r={d//2} k={k} cases={t}')
    frames=sum(collision_audit(d,poly,k) for d,poly,k in [(4,0b10011,3),(6,0b1000011,4),(8,0b100011101,4)])
    print(f'PASS q=4 characteristic-two subfield: {n} exact reconstructions and {frames} nonadaptive collisions')

