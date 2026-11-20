#!/usr/bin/env python3
"""Independent exact finite star-coupling and mixture L1-potential replay.
Author-side review of Route 1 at ac8b92df211b946bcd32cb6ed734ecb9b41368ee.
Passing finite examples is not a general theorem or Lean certificate.
"""
from fractions import Fraction as F
from itertools import product
from math import log

def norm(v):
    t=sum(v,F(0))
    return tuple(F(x)/t for x in v) if t else None

def star(p,q):
    m=len(q); c=[min(p[i],q[i]) for i in range(m)]
    delta=sum((abs(p[i]-q[i]) for i in range(m)),F(0))/2
    J=[[F(0) for _ in range(m)] for _ in range(m)]
    for i in range(m):
        J[i][i]+=c[i]
        if delta:
            for j in range(m):
                J[i][j]+=(q[i]-c[i])*(p[j]-c[j])/delta
    assert all(sum(J[i],F(0))==q[i] for i in range(m))
    assert all(sum((J[i][j] for i in range(m)),F(0))==p[j] for j in range(m))
    assert sum((J[i][j] for i in range(m) for j in range(m) if i!=j),F(0))==delta
    return J

def test_star():
    count=0
    for m in (2,3,4):
        ps=[v for w in product(range(3),repeat=m) if (v:=norm(w)) is not None]
        for p in ps:
            for q in ps:star(p,q);count+=1
    pi=[F(1,2),F(1,3),F(1,6),F(0)]
    laws=[(F(1),F(0),F(0),F(0)),(F(0),F(1),F(0),F(0)),
          (F(0),F(1,3),F(2,3),F(0)),(F(0),F(0),F(0),F(1))]
    q=tuple(sum((pi[t]*laws[t][i] for t in range(4)),F(0)) for i in range(4))
    assert q[3]==0
    for p in laws:star(p,q)
    return count

def f(x):
    return F(1,2)+(F(x[0])-F(1,2))*(F(x[1])-F(1,2))/2+\
        (F(x[2])-F(1,2))*(F(x[3])-F(1,2))/2

def L(mu,j):
    s=F(0);n=len(mu)
    for x in product((0,1),repeat=n):
        prob=F(1)
        for i,a in enumerate(x):prob*=mu[i][a]
        for b in (0,1):
            y=x[:j]+(b,)+x[j+1:]
            s+=prob*mu[j][b]*abs(f(x)-f(y))
    return s

def Phi(mu,pi):
    return sum((pi[t]*sum((L(mu[t],j) for j in range(len(mu[t]))),F(0))
                for t in range(len(pi))),F(0))

def test_drift():
    pi=[F(1,2),F(1,3),F(1,6)]
    mu=[[(F(1),F(0)),(F(1,2),F(1,2)),(F(0),F(1)),(F(1,3),F(2,3))],
        [(F(0),F(1)),(F(1,3),F(2,3)),(F(1,2),F(1,2)),(F(1),F(0))],
        [(F(1,4),F(3,4)),(F(0),F(1)),(F(1,4),F(3,4)),(F(1),F(0))]]
    before=Phi(mu,pi)
    for j in range(4):
        drop=sum((pi[t]*L(mu[t],j) for t in range(3)),F(0))
        after=F(0)
        h0=-sum(float(p)*log(float(p)) for p in pi if p)
        h1=0.
        for a in (0,1):
            qa=sum((pi[t]*mu[t][j][a] for t in range(3)),F(0))
            if not qa:continue
            post=[pi[t]*mu[t][j][a]/qa for t in range(3)]
            fixed=((F(1),F(0)) if a==0 else (F(0),F(1)))
            mus=[[fixed if i==j else mu[t][i] for i in range(4)] for t in range(3)]
            after+=qa*Phi(mus,post)
            h1+=float(qa)*(-sum(float(p)*log(float(p)) for p in post if p))
        assert before-after==drop
        assert h0+1e-12>=h1
    return before

if __name__=="__main__":
    n=test_star()
    print("ROUTE1_STAR_COUPLING_EXACT_PASS",n,"distribution pairs")
    print("ROUTE1_PHI_DRIFT_EXACT_PASS",test_drift())
    print("SCOPE: finite checks; full theorem not Lean certified")
