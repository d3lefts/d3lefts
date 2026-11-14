#!/usr/bin/env python3
"""Exact independent audit of hereditary TV stability of variance and conditional influence.
The bound with constant 1229 is a finite falsifier, not a universal certificate.
"""
from fractions import Fraction as F
from itertools import product, combinations
import json

checks=0

def assert_exact(ok,why):
    global checks
    checks+=1
    if not ok:raise AssertionError(why)

def base_law(n,z,t,eps):
    nu={}
    mu0={}
    for x in product((-1,1),repeat=n):
        p=F(1)
        for u in x:p*=(1+t*z*u)/2
        L=F(1)
        for j in range(n-1):L*=1+eps*x[j]*x[j+1]
        nu[x]=p; mu0[x]=p*L
    s=sum(mu0.values(),F(0))
    return nu,{x:v/s for x,v in mu0.items()}

def conditional(law,obs):
    tab={x:p for x,p in law.items() if all(x[i]==a for i,a in obs)}
    total=sum(tab.values(),F(0))
    return {x:p/total for x,p in tab.items()}

def val(x):
    return F(sum(x[2*i]*x[2*i+1] for i in range(len(x)//2)),len(x)//2)

def variance(law):
    mean=sum((p*val(x) for x,p in law.items()),F(0))
    return sum((p*(val(x)-mean)**2 for x,p in law.items()),F(0))

def influence(law,j):
    e2=sum((p*val(x)**2 for x,p in law.items()),F(0))
    groups={}
    for x,p in law.items():
        key=x[:j]+x[j+1:]
        if key not in groups:groups[key]=[F(0),F(0)]
        groups[key][0]+=p
        groups[key][1]+=p*val(x)
    conditional_mean_sq=sum((num*num/den for den,num in groups.values()),F(0))
    return e2-conditional_mean_sq

def tv(mu,nu):
    return sum((abs(mu.get(x,F(0))-nu.get(x,F(0))) for x in nu),F(0))/2

def main():
    models=0; histories=0
    for m in (1,2,3):
        n=2*m
        for z in (-1,1):
            for t in (F(1,4),F(2,3)):
                for eps in ((F(1,100),F(1,4)) if m<3 else (F(1,20),)):
                    nu,mu=base_law(n,z,t,eps)
                    R=((1+eps)/(1-eps))**(n-1)
                    models+=1
                    for pattern in product((0,-1,1),repeat=n):
                        obs=tuple((i,v) for i,v in enumerate(pattern) if v)
                        p=conditional(nu,obs); q=conditional(mu,obs)
                        d=tv(q,p)
                        # Exact test d <= (sqrt(R)-1)/(sqrt(R)+1).
                        assert_exact(((1+d)/(1-d))**2<=R,'hereditary ratio-TV failure')
                        vq=variance(q);vp=variance(p)
                        assert_exact(abs(vq-vp)<=4*d,'variance TV stability failure')
                        unread=[i for i in range(n) if not pattern[i]]
                        for j in unread:
                            iq=influence(q,j);ip=influence(p,j)
                            assert_exact(abs(iq-ip)<=4*d,'influence TV stability failure')
                        M=max((influence(q,j) for j in unread),default=F(0))
                        assert_exact(max(vq-4*d,F(0))**2<=1229*(M+4*d),'approx-Q2 implication failure')
                        histories+=1
    print(json.dumps({'status':'PASS','models':models,'histories':histories,'exact_checks':checks,
        'scope':'All 3^n conditional histories for n=2,4,6 on rational connected Ising-star residuals.'},indent=2))
if __name__=='__main__':main()
