#!/usr/bin/env python3
"""Exact finite audit for a stationary multiclass completion mechanism.

q=2 integrates continuous shifts by the exact triangular CDF. q=3 uses
a rational shift grid and proves an additive discretization slack. The
chain may be nonreversible. This is finite testing, not a universal proof.
"""
from fractions import Fraction as F
from itertools import product
from random import Random
from collections import defaultdict

RNG=Random(20261113)

def cdf_triangle(t):
    if t <= -1: return F(0)
    if t >= 1: return F(1)
    if t <= 0: return (t+1)**2/2
    return 1-(1-t)**2/2

def make_heatbath(states,masses,i):
    by_fiber=defaultdict(list)
    for x in states:
        by_fiber[x[:i]+x[i+1:]].append(x)
    K={}
    for fiber in by_fiber.values():
        tot=sum((masses[x] for x in fiber),F(0))
        for x in fiber:
            K[x]={y:masses[y]/tot for y in fiber if masses[y]>0} if tot else {x:F(1)}
    return K

def make_stationary_cycle(states,masses,i,alpha):
    # Nonreversible cyclic stationary flow for positive triads.
    assert alpha[i]>=3
    by_fiber=defaultdict(list)
    for x in states:
        by_fiber[x[:i]+x[i+1:]].append(x)
    K={x:{x:F(1)} for x in states}
    for fiber in by_fiber.values():
        active=[x for x in fiber if masses[x]>0]
        if len(active)<3: continue
        eps=min(masses[x] for x in active)/2
        for j,x in enumerate(active):
            y=active[(j+1)%len(active)]
            a=eps/masses[x]
            K[x]={x:1-a,y:a}
    return K

def check_stationary(states,masses,kernels,alpha):
    for i,K in enumerate(kernels):
        for x in states:
            assert sum(K[x].values(),F(0))==1
            assert all(p>=0 and all(
                x[j]==y[j] for j in range(len(alpha)) if j!=i)
                for y,p in K[x].items())
        for y in states:
            incoming=sum((masses[x]*K[x].get(y,F(0)) for x in states),F(0))
            assert incoming==masses[y],(i,y,incoming,masses[y])

def distances(states,label,lam):
    classes=sorted(set(label.values()))
    d={}
    for x in states:
        d[x]={b:min(sum(
            (lam[a][i] for i in range(len(x)) if x[i]!=a[i]),F(0))
            for a in states if label.get(a)==b) for b in classes}
    return d

def f_value(d,x,u):
    return min(d[x],key=lambda b:(d[x][b]+u[b],b))

def audit(alpha,labels,masses,kernels,lam,grid=4):
    n=len(alpha)
    states=list(product(*(range(a) for a in alpha)))
    K=max(sum(v,F(0)) for v in lam.values())
    q=len(set(labels.values()))
    d=distances(states,labels,lam)
    for x,b in labels.items():
        assert d[x][b]==0
        assert all(d[x][c]>=1 for c in d[x] if c!=b)
    for b in sorted(set(labels.values())):
        positive=sum((masses[x]*prob*max(F(0),d[y][b]-d[x][b])
                      for K_i in kernels for x in states
                      for y,prob in K_i[x].items()),F(0))
        absmean=sum((masses[x]*prob*abs(d[y][b]-d[x][b])
                     for K_i in kernels for x in states
                     for y,prob in K_i[x].items()),F(0))
        assert absmean==2*positive
        assert positive<=K
    if q==2:
        c0,c1=sorted(set(labels.values()))
        t={x:d[x][c0]-d[x][c1] for x in states}
        value=sum((masses[x]*prob*abs(cdf_triangle(t[x])-cdf_triangle(t[y]))/2
                   for K_i in kernels for x in states
                   for y,prob in K_i[x].items()),F(0))
        assert value<=q*K,(value,q,K)
        return q,K,value
    # GRID^q shifts and a rigorous q*n/(2GRID) discretization slack.
    shifts=[dict(zip(sorted(set(labels.values())),[F(j,grid) for j in vec]))
            for vec in product(range(grid),repeat=q)]
    total=F(0)
    for u in shifts:
        val={x:f_value(d,x,u) for x in states}
        total+=sum((masses[x]*prob*F(val[x]!=val[y],2)
                    for K_i in kernels for x in states
                    for y,prob in K_i[x].items()),F(0))
    average=total/len(shifts)
    assert average<=q*K+F(q*n,2*grid)
    return q,K,average

def run():
    tests=0;q2=0;q3=0;nonreversible=0
    for _ in range(320):
        n=RNG.randint(1,3)
        alpha=[RNG.randint(2,3) for i in range(n)]
        states=list(product(*(range(a) for a in alpha)))
        q=RNG.randint(2,min(3,len(states)))
        labels={}
        for b,x in enumerate(RNG.sample(states,q)):
            labels[x]=b
        for x in states:
            if x not in labels and RNG.random()<.28:
                labels[x]=RNG.randrange(q)
        dmin=min(sum(x[i]!=y[i] for i in range(n))
                 for x in labels for y in labels if labels[x]!=labels[y])
        assert dmin>=1
        lam={x:tuple(F(1,dmin) for _ in range(n)) for x in labels}
        for x in labels:
            for y in labels:
                if labels[x]!=labels[y]:
                    assert sum((min(lam[x][i],lam[y][i])
                                for i in range(n) if x[i]!=y[i]),F(0))>=1
        nums=[RNG.randint(0,5) for x in states]
        if not sum(nums):nums[0]=1
        masses={x:F(t,sum(nums)) for x,t in zip(states,nums)}
        kernels=[make_heatbath(states,masses,i) for i in range(n)]
        if 3 in alpha and RNG.random()<.5:
            i=alpha.index(3)
            kernels[i]=make_stationary_cycle(states,masses,i,alpha)
            nonreversible+=1
        check_stationary(states,masses,kernels,alpha)
        qc,K,v=audit(alpha,labels,masses,kernels,lam)
        tests+=1;q2+=(qc==2);q3+=(qc==3)
    print({'exact_source_models':tests,'binary_continuous_integral':q2,
           'ternary_discrete_integral_with_slack':q3,
           'nonreversible_kernels':nonreversible,'result':'all passed'})

if __name__=='__main__':
    run()
