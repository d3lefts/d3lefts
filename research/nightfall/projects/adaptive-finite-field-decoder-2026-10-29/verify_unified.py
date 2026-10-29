#!/usr/bin/env python3
"""Standalone exact verifier: affine-subgroup projective packing over F_(p^2)."""
from itertools import product
from random import Random


def subgroup(p,d):
    assert (p-1)%d ==0
    H={pow(a,(p-1)//d,p) for a in range(1,p)}
    assert len(H)==d
    return tuple(sorted(H))

def find_nonresidue(p):
    return next(z for z in range(2,p) if pow(z,(p-1)//2,p)==p-1)

class Quad:
    def __init__(self,p,d):
        self.p,self.d=p,d
        self.Q=p*p
        self.D=find_nonresidue(p)
        self.H=subgroup(p,d)
        self.phases={}
        self.roots={}
        for v in range(self.Q):
            y=self.power(v,d)
            self.phases[v]=y
            self.roots.setdefault(y,v)
        assert len(self.roots) == 1+(self.Q-1)//d
    def add(self,a,b): return ((a%self.p+b%self.p)%self.p) + self.p*((a//self.p+b//self.p)%self.p)
    def mul(self,a,b):
        p=self.p
        x,y=a%p,a//p
        u,v=b%p,b//p
        return (x*u+self.D*y*v)%p + p*((x*v+y*u)%p)
    def power(self,a,n):
        v=1
        while n:
            if n&1:v=self.mul(v,a)
            a=self.mul(a,a)
            n>>=1
        return v
    def div(self,a,b):return self.mul(a,self.power(b,self.Q-2))
    def scalar(self,c):return c%self.p
    def basis(self,i):return self.p**i
    def coords(self,v):return (v%self.p,v//self.p)
    def phase(self,a):return self.phases[a]


def phase_map(F,cs,phase_vec):
    v=0
    for i,(c,t) in enumerate(zip(cs,phase_vec)):
        v=F.add(v,F.mul(F.basis(i), F.scalar(c+t)))
    return F.phase(v)


def phase_recover(F,cs,w):
    if w==0:
        v=0
    else:
        v=F.roots[w]
    coordinates=F.coords(v)
    candidates=[]
    for t in F.H:
        inv=pow(t,-1,F.p)
        phases=tuple(((inv*z-c)%F.p) for z,c in zip(coordinates,cs))
        if all(a in F.H for a in phases): candidates.append(phases)
    assert len(set(candidates))==1, (F.p,F.d,cs,w,candidates)
    return candidates[0]


def blocker_set(p,H,c):
    S={(c+a)%p for a in H}
    return {t for t in H if t!=1 and not (S & {(t*v)%p for v in S})}

def cover(p,H,cs):
    blocked=set()
    for c in cs:blocked|=blocker_set(p,H,c)
    return blocked==set(H)-{1}

def weak(p,H,c):
    S={(c+a)%p for a in H}
    return all((S&{t*v%p for v in S}) <= {0} for t in H if t!=1)


def decode(F,x,cs):
    k=len(x)
    known=[F.phase(v) for v in x]
    reps=[F.roots[y] for y in known]
    active=[i for i,v in enumerate(x) if v]
    result=[0]*k
    if not active:return result,k
    t=active[0]
    result[t]=reps[t]
    reads=k
    for start in range(0,len(active)-1,2):
        block=active[1+start:1+start+2]
        # Choose first len(block) phase shifts and basis vectors.
        mixed=0
        anchor_phase=F.div(x[t],reps[t])
        for i in range(2):
            if i<len(block):
                j=block[i]
                row_val=F.add(F.mul(F.scalar(cs[i]),anchor_phase), F.div(x[j],reps[j]))
            else:
                # Pad a short block with a known relative phase 1.
                row_val=F.mul(F.scalar(cs[i]+1),anchor_phase)
            mixed=F.add(mixed,F.mul(F.basis(i),row_val))
        w=F.phase(mixed)
        phases=phase_recover(F,cs,w)
        assert all(phase==1 for phase in phases[len(block):])
        for j,a in zip(block,phases):result[j]=F.mul(F.scalar(a),reps[j])
        reads+=1
    return result, reads


def run(p,d,cs,n,seed):
    F=Quad(p,d)
    H=F.H
    assert cover(p,H,cs) or (len(set(cs))==1 and weak(p,H,cs[0])), (p,d,cs)
    pairs={}
    for phases in product(H,repeat=2):
        y=phase_map(F,cs,phases)
        assert y not in pairs, ('collision',p,d,cs,phases,pairs.get(y))
        pairs[y]=phases
        assert phase_recover(F,cs,y)==phases
    for phase in H:
        y=phase_map(F,cs,(phase,1))
        assert phase_recover(F,cs,y)==(phase,1)
    rng=Random(seed)
    for j in range(n):
        k=3+(j%3)
        x=[rng.randrange(F.Q) for _ in range(k)]
        if j%41==0:x=[0]*k
        if j%43==0:x[0]=0
        result,reads=decode(F,x,cs)
        assert any(all(F.mul(h,a)==b for a,b in zip(x,result)) for h in H), ('bad decode',p,d,cs,x,result)
        support=sum(bool(z) for z in x)
        assert reads ==k+((max(support-1,0)+1)//2)
    print('PASS', 'p',p,'phase_subgroup_size',d,'basis_dimension',2,'shifts',cs,'all_phase_patterns',d*d,'signals',n,'nonadaptive? no')

if __name__=='__main__':
    cases=[(3,2,(1,1),1000),(5,2,(1,1),1000),(7,3,(3,3),1000),(13,3,(2,2),1000),(13,4,(2,4),2500),(17,4,(2,2),1000),(19,3,(2,2),1000),(31,5,(3,5),1500),(41,4,(2,2),1500)]
    for i,(p,d,cs,n) in enumerate(cases):run(p,d,cs,n,seed=20261029+i)
    print('TOTAL_PASS',sum(n for _,_,_,n in cases),'exact vector reconstructions across',len(cases),'subgroup models')

def all_shift_classification(p,d):
    F=Quad(p,d);H=F.H
    good=[]
    for cs in product(range(p),repeat=2):
        patterns=[phase_map(F,cs,phase) for phase in product(H,repeat=2)]
        if len(set(patterns))==d*d:good.append(cs)
    print('CLASSIFICATION', 'p',p,'d',d,'good_shifts',len(good),'examples',good[:8])
    return good

if __name__=='__main__':
    examples = [(3,2),(5,4),(7,3),(7,6),(13,4)]
    proven = {(p,d):bool(all_shift_classification(p,d)) for p,d in examples}
    assert proven == {(3,2):True,(5,4):False,(7,3):True,(7,6):False,(13,4):True},proven

