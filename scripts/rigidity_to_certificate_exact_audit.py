#!/usr/bin/env python3
"""Exact arithmetic stress tests for rigidity-to-certificate v1.
Hypothetical fibers are SYNTHETIC, not claims about actual zeta zeros.
No Lean proof, no full analytic-continuation certificate.
"""
from fractions import Fraction as Q
from itertools import product
from math import lcm, comb
from random import Random

def mu(n):
    assert n >= 1
    sign=1
    p=2
    while p*p <= n:
        if n%p == 0:
            n//=p
            if n%p == 0: return 0
            sign=-sign
        p+=1
    return -sign if n>1 else sign

def vp(n,p):
    v=0
    while n%p==0:
        n//=p
        v+=1
    return v

def prime_factors(n):
    out=[]
    d=2
    while d*d <= n:
        if n%d==0:
            out.append(d)
            while n%d==0: n//=d
        d+=1
    if n>1:out.append(n)
    return out

def fiber(mults):
    active=[n for n in mults if mu(n)]
    D=lcm(*active) if active else 1
    A=sum(mu(n)*(D//n)*mults[n] for n in active)
    alternate=sum((Q(mu(n)*r,n) for n,r in mults.items()),Q())
    assert Q(A,D)==alternate
    for p in prime_factors(D):
        vmax=max(vp(n,p) for n in active)
        r=sum(mu(n)*(D//n)*mults[n] for n in active if vp(n,p)==vmax)%p
        assert A%p==r
    if A: assert abs(Q(A,D))>=Q(1,D)
    return D,A

def matinv(M):
    n=len(M)
    a=[[Q(z) for z in row]+[Q(i==j) for j in range(n)] for i,row in enumerate(M)]
    for k in range(n):
        j=next(j for j in range(k,n) if a[j][k])
        a[k],a[j]=a[j],a[k]
        div=a[k][k]
        a[k]=[z/div for z in a[k]]
        for i in range(n):
            if i!=k:
                s=a[i][k]
                a[i]=[u-s*v for u,v in zip(a[i],a[k])]
    return [row[n:] for row in a]

def mv(M,v):
    return [sum((a*b for a,b in zip(row,v)),Q()) for row in M]

def inf_norm(M):
    return max(sum(map(abs,row),Q()) for row in M)

def nearest(x):
    return (2*x.numerator+x.denominator)//(2*x.denominator)

def main():
    # Exact nonzero multi-fiber obstruction, exact zero counter-control,
    # and zero Möbius coefficient on a squareful denominator.
    assert fiber({2:1,3:1})==(6,-5)
    assert fiber({1:1,2:2})==(2,0)
    assert fiber({4:99,6:1})==(6,1)
    rng=Random(140624)
    for _ in range(1700):
        nodes=rng.sample(range(1,36),rng.randint(1,12))
        fiber({n:rng.randint(1,5) for n in nodes})
    print("PASS 1700 exact synthetic fibers, denominator gaps, modular reductions")
    # Product lower bound for Re(lambda)<=1/2, exactly rational.
    for k in range(1,51):
        lhs=Q(1)
        for j in range(1,k+1):lhs*=Q(2*j-1,2*j)
        assert lhs==Q(comb(2*k,k),4**k)
    print("PASS exact central-binomial Pochhammer lower-bound identity k<=50")
    # All rows below are genuine probability-distribution probes.
    M=[[Q(1),Q(0),Q(0)],
       [Q(1,2),Q(1,2),Q(0)],
       [Q(1,3),Q(1,3),Q(1,3)]]
    B=matinv(M)
    for i,row in enumerate(M):
        for j,col in enumerate(zip(*B)):
            assert sum((u*v for u,v in zip(row,col)),Q())==Q(i==j)
    denoms=[15,10,6]
    ints=[2,-1,3]
    noise=[Q(1,100),-Q(1,120),Q(1,150)]
    eta=max(map(abs,noise))
    K=inf_norm(B)
    sharp=inf_norm([[d*x for x in row] for d,row in zip(denoms,B)])
    assert (K,sharp)==(5,30)
    assert sharp*eta<Q(1,2) and max(denoms)*K*eta>=Q(1,2)
    b=[Q(a,d) for a,d in zip(ints,denoms)]
    y=[a+e for a,e in zip(mv(M,b),noise)]
    recovered=mv(B,y)
    assert [nearest(d*z) for d,z in zip(denoms,recovered)]==ints
    print("PASS integer lattice rounding with η=1/100, sharp norm=30 vs coarse=75; gain=5/2")
    # Rigidity does not control ill-conditioning of bounded expectation probes.
    for n in (2,4,8,16,32,64):
        eps=Q(1,n)
        M=[[Q(1),Q(0)],[Q(1)-eps,eps]]
        B=matinv(M)
        L=[Q(-1),Q(1)]
        w=mv([list(x) for x in zip(*B)],L)
        assert w==[-n,n]
        assert sum(map(abs,w))==2*n
    print("PASS 2-source rigid but ill-conditioned inverse, cost=2/eps")
    print("NOTE: analytic germ theorem depends on separate source local-continuation hypotheses")

if __name__=="__main__":
    main()
