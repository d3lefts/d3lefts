#!/usr/bin/env python3
"""Exact original-product finite-output full-row transfer audit.

No numerical optimizer, network, float thresholds, or third-party dependency.
The infinite-family argument is mathematical and NOT certified by finite tests.
"""
from fractions import Fraction as Q
from functools import reduce
from itertools import product
from math import prod
import random


def f4(x):
    a,b,c,d=x
    return Q(-a+b-c-d,2)+Q((a+b)*(c-d),4)


# Primal rows discovered separately using a linear optimizer, but ALL rows
# below are checked directly using integers/Fractions; no solver trust needed.
FOURBIT_ROWS = (
    (2,1,2,0), (2,1,2,0), (1,2,2,0), (1,2,2,0),
    (2,2,1,1), (2,1,1,1), (1,2,1,1), (1,1,1,1),
    (1,1,1,1), (2,1,1,1), (1,2,1,1), (2,2,1,1),
    (1,2,0,2), (2,1,0,2), (1,2,0,2), (2,1,0,2),
)


def fourbit_certificate():
    states=tuple(product((-1,1),repeat=4))
    f={x:f4(x) for x in states}
    R=0
    for x,a in zip(states,FOURBIT_ROWS):
        assert all(z>=0 for z in a)
        assert sum(a)<=6
        assert all(abs(f[x]-f[y])<=sum(a[i] for i in range(4) if x[i]!=y[i])
                   for y in states)
        R=max(R,sum(abs(f[x]-f[x[:i]+(-x[i],)+x[i+1:]]) for i in range(4)))
    assert R==4
    # Exact two disjoint positive dual packing constraints at the same x.
    x=(-1,1,-1,-1)
    y1=(-1,-1,1,-1)
    y2=(1,1,-1,1)
    A={i for i in range(4) if x[i]!=y1[i]}
    B={i for i in range(4) if x[i]!=y2[i]}
    assert A=={1,2} and B=={0,3} and not A&B
    assert f[x]==2 and f[y1]==f[y2]==-1
    assert abs(f[x]-f[y1])+abs(f[x]-f[y2])==6
    # Every full row must allocate >=3 to A and >=3 to B, hence >=6.
    # Thus (primal max 6, dual min 6) proves the exact uniform row optimum.
    V=sum((f[x]**2 for x in states),Q())/16
    I=[sum(((f[x]-f[x[:i]+(-x[i],)+x[i+1:]])**2/4
             for x in states),Q())/16 for i in range(4)]
    assert V==Q(5,4) and I==[Q(3,8)]*4
    assert 4*V*V/(R*R*max(I))==Q(25,24)
    assert 4*V*V/(Q(6)**2*max(I))==Q(25,54)
    print("PASS full 16-row primal certificate K<=6, disjoint 2-block dual K>=6")
    print("PASS singleton R=4, original variance=5/4, all influences=3/8")
    print("PASS PSI ratio 25/24 >1 but full-row c=4 ratio 25/54 <1")


def original_influence(states,mu,vals,laws,i):
    # Genuine source-resampling: half the expected squared replacement
    # difference, including nonuniform symbol masses and zero-prob atoms.
    E=Q()
    for x in states:
        for sym,py in enumerate(laws[i]):
            if py==0:continue
            y=x[:i]+(sym,)+x[i+1:]
            E+=mu[x]*py*(vals[x]-vals[y])**2/2
    return E


def audit(laws, f, label):
    n=len(laws)
    support=[tuple(i for i,p in enumerate(law) if p>0) for law in laws]
    states=tuple(product(*support))
    mu={x:prod(laws[i][x[i]] for i in range(n)) for x in states}
    assert sum(mu.values(),Q())==1
    vals={x:Q(f(x)) for x in states}
    levels=sorted(set(vals.values()))
    if len(levels)<2:return
    m=len(levels)
    # Construct a universally feasible source row *directly* from
    # all-pairs differences. This is NOT assumed to be LP optimal.
    rows={}
    for x in states:
        rows[x]=tuple(
            max((abs(vals[x]-vals[y])/sum(x[j]!=y[j] for j in range(n))
                 for y in states if x[i]!=y[i]), default=Q())
            for i in range(n))
    K=max(sum(row) for row in rows.values())
    assert K>0
    for x in states:
        assert all(z>=0 for z in rows[x])
        for y in states:
            assert sum(rows[x][i] for i in range(n) if x[i]!=y[i]) >= abs(vals[x]-vals[y])
    mean=sum(mu[x]*vals[x] for x in states)
    V=sum(mu[x]*(vals[x]-mean)**2 for x in states)
    influence=[original_influence(states,mu,vals,laws,i) for i in range(n)]
    M=max(influence)
    assert V>0 and M>0
    cuts=[]
    for k in range(m-1):
        delta=levels[k+1]-levels[k]
        g={x:Q(int(vals[x]>=levels[k+1])) for x in states}
        p=sum(mu[x]*g[x] for x in states)
        q=p*(1-p)
        gi=[original_influence(states,mu,g,laws,i) for i in range(n)]
        assert all(influence[i]>=delta*delta*gi[i] for i in range(n))
        # Boolean two-sided theorem's stated finite-product consequence
        # is checked as an exact finite inequality, not assumed as a proof.
        assert K*K*max(gi)>=delta*delta*q
        assert all(sum(rows[x][i]/delta for i in range(n) if x[i]!=y[i])>=abs(g[x]-g[y])
                   for x in states for y in states)
        cuts.append((delta,p,q,g))
    # Independent threshold covariance expansion, exact rational.
    threshmean=[sum(mu[x]*g[x] for x in states) for _,_,_,g in cuts]
    reconstructed=Q()
    for j,(dj,pj,qj,gj) in enumerate(cuts):
        for k,(dk,pk,qk,gk) in enumerate(cuts):
            cov=sum(mu[x]*gj[x]*gk[x] for x in states)-threshmean[j]*threshmean[k]
            reconstructed+=dj*dk*cov
    assert reconstructed==V
    maxcut=max(delta**4*q for delta,p,q,g in cuts)
    bound=Q(4)*V**2/(Q(m-1)**4)
    assert K*K*M>=maxcut>=bound,(label,K,M,V,maxcut,bound)
    print("PASS",label,"states",len(states),"outputs",m,
          "K",K,"V",V,"M",M,"cut/target",str(maxcut/bound))


def limit_barrier(m,epsilon):
    # One categorical coordinate, positive laws at ALL levels.
    assert m>=3 and 0<epsilon<1
    law=[(1-epsilon)/2]+[epsilon/Q(m-2)]*(m-2)+[(1-epsilon)/2]
    levels=[-1+Q(2*j,m-1) for j in range(m)]
    pvals=[sum(law[k+1:]) for k in range(m-1)]
    delta=Q(2,m-1)
    mean=sum(law[j]*levels[j] for j in range(m))
    V=sum(law[j]*(levels[j]-mean)**2 for j in range(m))
    maxcut=max(delta**4*p*(1-p) for p in pvals)
    # The exact true row cost is two, because there is one coordinate.
    K=2
    M=V
    assert maxcut/V**2 > Q(4,(m-1)**4)
    assert abs(maxcut/V**2-Q(4,(m-1)**4))<Q(2,1000) if epsilon==Q(1,100000) else True
    assert K*K*M/V**2==Q(4)/V
    return maxcut/V**2,Q(4,(m-1)**4)


def main():
    fourbit_certificate()
    # Dictator (m=2) exactly saturates the coefficient-four row theorem.
    audit([(Q(1,2),Q(1,2))],lambda x: -1+2*x[0],"fair dictator")
    rng=random.Random(20261117)
    specs=[
        ((Q(1,2),Q(1,2)),(Q(1,4),Q(1,2),Q(1,4))),
        ((Q(0),Q(1,7),Q(6,7)),(Q(1,3),Q(2,3))),
        ((Q(1,5),Q(4,5)),(Q(1,4),Q(1,4),Q(1,2)),(Q(1,3),Q(2,3))),
    ]
    for j,laws in enumerate(specs):
        for t in range(20):
            field={}
            for x in product(*(range(len(a)) for a in laws)):
                field[x]=rng.randint(-2,2)
            audit(laws,lambda x,tab=field: tab[x],f"source{j}-{t}")
    for m in range(3,10):
        ratio,lim=limit_barrier(m,Q(1,100000))
        print(f"PASS one-coordinate multilevel m={m}, exact cut/V^2={ratio}, sharp limit={lim}")
    print("SCOPE: exact finite checks and imported Boolean row input; no full real-valued bilinear inequality")


if __name__=="__main__":
    main()
