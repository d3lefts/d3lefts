#!/usr/bin/env python3
"""Independent exhaustive small-field checker for extension-degree packing.

Only integer polynomial arithmetic; no pre-existing NIGHTFALL decoder imports.
Measurement: (a dot x)^(p-1), K=F_p[t]/(irreducible m(t)).
The theorem covers prime-power q; this harness tests prime q=p examples.
"""
from itertools import product
from math import ceil
import random

class Field:
    def __init__(self,p,poly):
        assert poly[-1] == 1
        self.p,self.poly,self.r=p,tuple(poly),len(poly)-1
        self.Q=p**self.r
        self.digits=[self.unpack(i) for i in range(self.Q)]
        self.powp=[p**i for i in range(self.r)]
        self.mul_table=[[self._mul(i,j) for j in range(self.Q)] for i in range(self.Q)]
        self.inverse=[0]+[self.power(x,self.Q-2) for x in range(1,self.Q)]
        self.phases=[self.power(x,p-1) for x in range(self.Q)]
        self.roots={}
        for x,y in enumerate(self.phases):
            if y not in self.roots:self.roots[y]=x
        assert self.roots[0]==0
        assert len(self.roots) == 1+(self.Q-1)//(p-1)
    def unpack(self,x):
        d=[]
        for _ in range(self.r):d.append(x%self.p);x//=self.p
        return tuple(d)
    def pack(self,d):return sum(t*self.p**i for i,t in enumerate(d))
    def add(self,x,y):
        return self.pack([(a+b)%self.p for a,b in zip(self.digits[x],self.digits[y])])
    def _mul(self,x,y):
        r,p=self.r,self.p;a=self.digits[x];b=self.digits[y]
        t=[0]*(2*r-1)
        for i,u in enumerate(a):
            for j,v in enumerate(b):t[i+j]+=u*v
        for i in range(2*r-2,r-1,-1):
            val=t[i]%p
            for j in range(r):t[i-r+j]-=val*self.poly[j]
        return self.pack([t[i]%p for i in range(r)])
    def mul(self,x,y):return self.mul_table[x][y]
    def power(self,x,n):
        z=1
        while n:
            if n&1:z=self.mul_table[z][x]
            n>>=1
            if n:x=self.mul_table[x][x]
        return z
    def phase(self,x):return self.phases[x]
    def basis(self,i):return self.p**i
    def div(self,x,y):return self.mul(x,self.inverse[y])

# Each mixed measurement packs up to r-1 base-field phases.
def packed_decode(F,x):
    k=len(x);out=[0]*k
    if F.p==2:
        # The base-field phase group F_2^× is trivial.
        return list(x),k
    y=[F.phase(v) for v in x]
    reps=[F.roots[v] for v in y]
    supp=[i for i,v in enumerate(y) if v]
    if not supp:return out,k
    t=supp[0]
    out[t]=reps[t]
    remaining=supp[1:]
    reads=k
    for start in range(0,len(remaining),F.r-1):
        block=remaining[start:start+F.r-1]
        # One measurement with anchor and one per basis direction.
        linear=F.div(x[t],reps[t])
        for j,h in zip(block,range(1,F.r)):
            coefficient=F.div(F.basis(h),reps[j])
            linear=F.add(linear,F.mul(coefficient,x[j]))
        # Phaseless measurement and independent canonical root selection.
        returned=F.phase(linear)
        root=F.roots[returned]
        decoded=F.digits[root]
        assert decoded[0]!=0,(F.p,F.r,x,start)
        ref_inv=pow(decoded[0],-1,F.p)
        for j,h in zip(block,range(1,F.r)):
            lam=decoded[h]*ref_inv%F.p
            assert lam!=0
            out[j]=F.mul(lam,reps[j])
        reads+=1
    return out,reads

def equivalence(F,x,z):
    return any(all(F.mul(a,v)==w for v,w in zip(x,z)) for a in range(1,F.p)) or (all(t==0 for t in x) and all(t==0 for t in z))

def exercise(F,k,limit=None,seed=1729):
    total=F.Q**k
    gen=product(range(F.Q),repeat=k) if limit is None or total<=limit else []
    rand=random.Random(seed+k+100*F.r)
    if not gen:gen=[tuple(rand.randrange(F.Q) for _ in range(k)) for _ in range(limit)]
    counts={};n=0;improvements=0
    for x in gen:
        z,m=packed_decode(F,x)
        assert equivalence(F,x,z),(F.p,F.r,k,x,z,m)
        support=sum(v!=0 for v in x)
        upper=k if F.p==2 else k+ceil(max(0,support-1)/(F.r-1))
        assert m==upper, (m,upper,x)
        assert m<= (k if F.p==2 else k+ceil((k-1)/(F.r-1)))
        if m<k+max(support-1,0):improvements+=1
        counts[m]=counts.get(m,0)+1
        n+=1
    return (F.p,F.r,k,n,max(counts),improvements)

def null_vector(F,rows,k):
    """Return a deterministic nonzero K-kernel vector when rows have rank < k."""
    p=F.Q
    mat=[list(row) for row in rows]
    pivots=[];pivot_row=0
    for col in range(k):
        idx=next((i for i in range(pivot_row,len(mat)) if mat[i][col]),None)
        if idx is None:continue
        mat[pivot_row],mat[idx]=mat[idx],mat[pivot_row]
        inv=F.inverse[mat[pivot_row][col]]
        mat[pivot_row]=[F.mul(inv,x) for x in mat[pivot_row]]
        for i in range(len(mat)):
            if i==pivot_row or not mat[i][col]:continue
            scalar=mat[i][col]
            mat[i]=[F.add(a,F.mul(F.p-1,F.mul(scalar,b))) for a,b in zip(mat[i],mat[pivot_row])]
        pivots.append(col)
        pivot_row+=1
        if pivot_row==len(mat):break
    if len(pivots)==k:return None
    free=next(j for j in range(k) if j not in pivots)
    vec=[0]*k;vec[free]=1
    for i,col in enumerate(pivots):
        vec[col]=F.mul(F.p-1,mat[i][free])
    assert all(sum_field(F,(F.mul(a,b) for a,b in zip(row,vec)))==0 for row in rows)
    return vec

def sum_field(F,values):
    v=0
    for x in values:v=F.add(v,x)
    return v

def complement_collision_test(F,k,trials,seed=2341):
    """For any nonadaptive set of <=2k-2 rows, exhibit a collision."""
    assert F.p>2 and k>=2
    rand=random.Random(seed+F.p*100+F.r*10+k)
    for trial in range(trials):
        count=2*k-2
        rows=[[rand.randrange(F.Q) for _ in range(k)] for _ in range(count)]
        u=null_vector(F,rows,k)
        if u is not None:
            x=u;z=[0]*k
        else:
            u=null_vector(F,rows[:k-1],k)
            v=null_vector(F,rows[k-1:],k)
            assert u is not None and v is not None
            x=[F.add(a,b) for a,b in zip(u,v)]
            z=[F.add(a,F.mul(2,b)) for a,b in zip(u,v)]
        assert not equivalence(F,x,z)
        for row in rows:
            observed_x=F.phase(sum_field(F,(F.mul(a,b) for a,b in zip(row,x))))
            observed_z=F.phase(sum_field(F,(F.mul(a,b) for a,b in zip(row,z))))
            assert observed_x==observed_z,(trial,row,x,z)
    return trials

def information_minimum(q,r,k):
    outputs=1+(q**r-1)//(q-1)
    classes=1+(q**(r*k)-1)//(q-1)
    depth=0; capacity=1
    while capacity < classes:
        capacity*=outputs;depth+=1
    return depth

if __name__=='__main__':
    examples=[
       (3,[1,0,1],[1,2,3,4],None),
       (3,[1,2,0,1],[1,2,3],None),
       (3,[2,1,0,0,1],[2,3,4,5],1200),
       (5,[2,0,1],[1,2,3],None),
       (5,[1,1,0,1],[2,3,4,5],1000),
       (2,[1,1,0,1],[1,2,3],None)
    ]
    tested=0
    for p,poly,ks,cap in examples:
        F=Field(p,poly)
        for k in ks:
            quota=cap if cap is not None else (20000 if F.Q**k>20000 else None)
            case=exercise(F,k,quota)
            tested+=case[3]
            print('p,r,k,total,worst,improvements',*case,'lower',information_minimum(p,F.r,k),flush=True)
    frames=sum(complement_collision_test(Field(p,pol),k,500) for p,pol,k in [(3,[1,2,0,1],3),(3,[2,1,0,0,1],4),(5,[1,1,0,1],4)])
    print('PASS',tested,'exact inputs and',frames,'nonadaptive collision certificates',flush=True)

