#!/usr/bin/env python3
"""Exact finite adversarial controls for V² <= d R² M. Not a proof.

Canonical centered monomials of original rational Bernoulli products guarantee
true Hoeffding degree <= d. The degree-free R bridge is FALSE (#823).
"""
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random
from math import prod

def model(n,d,weights,coeffs):
    assert n>=2 and d>=1
    p=[Q(w[1],sum(w)) for w in weights]
    masks=[S for k in range(1,d+1) for S in combinations(range(n),k)]
    assert len(coeffs)==len(masks)
    active=[(S,Q(c)) for S,c in zip(masks,coeffs) if c]
    assert active
    actual_degree=max(len(S) for S,c in active)
    varcoord=[z*(1-z) for z in p]
    V=Q(0);I=[Q(0)]*n
    for S,c in active:
        weight=c*c*prod((varcoord[i] for i in S),start=Q(1))
        V+=weight
        for i in S:I[i]+=weight
    M=max(I)
    states=list(product((0,1),repeat=n));f=[];D=[];R=Q(0)
    for x in states:
        centered=[Q(x[i])-p[i] for i in range(n)]
        value=Q(0);residual=[Q(0)]*n
        for S,c in active:
            term=c*prod((centered[i] for i in S),start=Q(1))
            value+=term
            for i in S:residual[i]+=term
        f.append(value);D.append(residual)
        R=max(R,sum(map(abs,residual),Q(0)))
    ratio=V*V/(actual_degree*R*R*M) if R*M else Q(0)
    return ratio,(V,M,R,actual_degree),states,p,f,D,I

def independent_replica_audit(result):
    _,(V,M,R,d),states,p,f,D,I=result
    n=len(p);index={s:j for j,s in enumerate(states)}
    w=[prod((p[i] if x[i] else 1-p[i] for i in range(n)),start=Q(1)) for x in states]
    assert sum(w,Q(0))==1
    mean=sum((w[j]*f[j] for j in range(len(states))),Q(0))
    Vcheck=sum((w[j]*(f[j]-mean)**2 for j in range(len(states))),Q(0))
    assert mean==0 and V==Vcheck
    assert R==max(sum(map(abs,v),Q(0)) for v in D)
    for i in range(n):
        resid=[]
        for j,x in enumerate(states):
            x0=x[:i]+(0,)+x[i+1:]
            x1=x[:i]+(1,)+x[i+1:]
            expected=(1-p[i])*f[index[x0]]+p[i]*f[index[x1]]
            resid.append(f[j]-expected)
        assert all(D[j][i]==resid[j] for j in range(len(states)))
        Icond=sum((w[j]*resid[j]**2 for j in range(len(states))),Q(0))
        Irep=Q(1,2)*sum((w[j]*law*(f[j]-f[index[x[:i]+(s,)+x[i+1:]]])**2
                 for j,x in enumerate(states) for s,law in enumerate((1-p[i],p[i]))),Q(0))
        assert Icond==Irep==I[i],(i,Icond,Irep,I[i])

def main():
    rng=Random(20261118)
    sources=(1,2,3,11,29,127)
    budget=((4,2,120),(6,2,90),(8,2,50),(4,3,120),(6,3,70))
    for n,d,count in budget:
        masks=[S for k in range(1,d+1) for S in combinations(range(n),k)]
        best=(-1,None)
        for trial in range(count):
            if trial%7==0:
                weights=[(1,1)]*n
                coeffs=[1 if len(S)==1 else 0 for S in masks]
            else:
                weights=[(rng.choice(sources),rng.choice(sources)) for _ in range(n)]
                mode=trial%7
                if mode==1: coeffs=[rng.choice((-4,-2,0,0,2,4)) for _ in masks]
                elif mode==2: coeffs=[rng.choice((0,0,0,-5,5)) for _ in masks]
                elif mode==3: coeffs=[rng.choice((-3,0,3)) if len(S)==d else 0 for S in masks]
                elif mode==4: coeffs=[rng.choice((-4,-1,1,4)) if len(S)<=d-1 else 0 for S in masks]
                elif mode==5: coeffs=[rng.choice((-1,1)) if len(S)==1 else rng.choice((0,0,0,0,1)) for S in masks]
                else: coeffs=[rng.choice((-3,-1,1,3)) for _ in masks]
                if not any(coeffs): coeffs[0]=1
            result=model(n,d,weights,coeffs)
            if result[0]>best[0]:best=(result[0],(weights,coeffs,result))
            if result[0]>1:
                independent_replica_audit(result)
                raise AssertionError(('EXACT C=1 COUNTEREXAMPLE',n,d,weights,coeffs,result[0]))
        ratio,(weights,coeffs,result)=best
        independent_replica_audit(result)
        print('PASS canonical original-law degree <=',d,'n=',n,'trials',count,
              'best V²/(degree R² M)=',str(ratio),'float',format(float(ratio),'.9f'),
              'best degree',result[1][3])
    print('NO sampled weighted-R violation. This does NOT prove the all-degree bound.')
if __name__=='__main__':main()
