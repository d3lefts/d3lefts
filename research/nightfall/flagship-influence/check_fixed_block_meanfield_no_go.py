#!/usr/bin/env python3
"""Exact source-law checks for signed two-block biased quadratic mean-field.

Research scope: finite examples and formulas, NOT any universal UE2 bound.
Standard library only. Independent direct Bernoulli enumeration for n <= 4.
"""
from fractions import Fraction as F
from itertools import product
from math import comb


def formula(n,m):
    assert n>=2 and n%2==0 and F(-1)<m<F(1)
    v=1-m*m
    B=F(1,2) # both block means grids contain 0 and +/-1
    V=F(n-1,n**3)*(2*(n-1)*m*m*v+v*v)
    M=v*(n-1)*(v+(n-1)*m*m)/n**4
    R=V*V/(B*B*M)
    return B,V,M,R


def binom(n,p):
    return [F(comb(n,k))*p**k*(1-p)**(n-k) for k in range(n+1)]


def independent(n,m):
    p=(1+m)/2
    ps=binom(n,p)
    means=[F(2*k-n,n) for k in range(n+1)]
    g=[F(z*z,2) for z in means]
    E=sum((ps[k]*g[k] for k in range(n+1)),F(0))
    Eg2=sum((ps[k]*g[k]**2 for k in range(n+1)),F(0))
    V=2*(Eg2-E*E)
    pother=binom(n-1,p)
    M=sum((pother[k]*p*(1-p)*(F((2*(k+1)-n)**2-(2*k-n)**2,2*n*n))**2 for k in range(n)),F(0))
    B=(max(g)-min(g))*1 # f=(g(A)-g(B)); range [-max(g)+min(g), +max(g)-min(g)]
    return B,V,M,V*V/(B*B*M)


def brute(n,m):
    p=(1+m)/2
    probs={0:1-p,1:p}
    states=tuple(product((0,1),repeat=2*n))
    fs={}
    weights={}
    for x in states:
        A=F(2*sum(x[:n])-n,n)
        Z=F(2*sum(x[n:])-n,n)
        fs[x]=(A*A-Z*Z)/2
        weights[x]=p**sum(x)*(1-p)**(2*n-sum(x))
    assert sum(weights.values())==1
    avg=sum((weights[x]*fs[x] for x in states),F(0))
    V=sum((weights[x]*(fs[x]-avg)**2 for x in states),F(0))
    B=(max(fs.values())-min(fs.values()))/2
    inf=[]
    for i in range(2*n):
        I=F(0)
        for yy in product((0,1),repeat=2*n-1):
            xx0=yy[:i]+(0,)+yy[i:];xx1=yy[:i]+(1,)+yy[i:]
            I+=p**sum(yy)*(1-p)**(2*n-1-sum(yy))*p*(1-p)*(fs[xx1]-fs[xx0])**2
        inf.append(I)
    assert len(set(inf))==1
    return B,V,max(inf),V*V/(B*B*max(inf))


def main():
    for m in (F(0),F(3,5),F(7,10),F(9,10)):
        for n in (2,4,6,8,16,40):
            rec=formula(n,m)
            indep=independent(n,m)
            assert rec==indep,(n,m,rec,indep)
            if n<=4:assert rec==brute(n,m)
            assert rec[3]<=4, (n,m,rec[3])
        print('PASS exact variance, influence, radius, R<=4; mean',m)
    m=F(7,10)
    limit=16*m*m*(1-m*m)
    assert limit==F(2499,625)
    assert formula(1000,m)[3]>F(39,10)
    # Special irrational optimal mean: m^2=1/2; all formulas rational in m^2.
    n=8; v=F(1,2); mm=F(1,2)
    B=F(1,2)
    V=F(n-1,n**3)*(2*(n-1)*mm*v+v*v)
    M=v*(n-1)*(v+(n-1)*mm)/n**4
    R=V*V/(B*B*M)
    assert R==F(4*(n-1)*(2*n-1)**2,4*n**3)
    assert R==F(4*(n-1)*(n-F(1,2))**2,n**3)
    print('PASS irrational optimum reduced to exact rational formulas; n=8 ratio',R)
    print('PROOF SCOPE: finite product checks only; multiblock Bernstein theorem is analytical and unreviewed.')

if __name__=='__main__':main()
