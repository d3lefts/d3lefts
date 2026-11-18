#!/usr/bin/env python3
"""Exact rational checks for latent-product influence theorem.
These are counterexample regression tests, not a proof of the general theorem.
"""
from fractions import Fraction as Q
from itertools import product

def mean(p, f):
    return sum((w*f(x) for x, w in p.items()), Q(0))

def variance(p, f):
    m = mean(p, f)
    return mean(p, lambda x: (f(x)-m)**2)

def conditional_variance_influence(p, f, i):
    # Work with unnormalized conditionals grouped by all coordinates except i.
    groups = {}
    for x, w in p.items():
        z = x[:i]+x[i+1:]
        groups.setdefault(z, []).append((x,w))
    result = Q(0)
    for points in groups.values():
        mass = sum((w for x,w in points),Q(0))
        if mass == 0:
            continue
        avg = sum((w*f(x) for x,w in points),Q(0))/mass
        result += sum((w*(f(x)-avg)**2 for x,w in points),Q(0))
    return result

def example(N):
    points = list(product((0,1),repeat=N+1))
    weights=[Q(1,2),Q(1,2)]
    comps=[]
    for theta in (0,1):
        p=Q(1,4) if theta==0 else Q(3,4)
        comp = {x: (Q(1) if x[0]==theta else Q(0))*
                product_q([(p if b else (1-p)) for b in x[1:]]) for x in points}
        assert sum(comp.values())==1
        comps.append(comp)
    nu={x: sum((weights[t]*comps[t][x] for t in (0,1)),Q(0)) for x in points}
    reference={x:Q(1,2**(N+1)) for x in points}
    assert all(nu[x]>0 for x in points)
    minratio=min(nu[x]/reference[x] for x in points)
    assert minratio==Q(1,2**N), (N,minratio)
    f=lambda x: Q(int(x[1]!=x[2]))
    V=variance(nu,f)
    Vcomps=[variance(c,f) for c in comps]
    W=sum((weights[t]*Vcomps[t] for t in (0,1)),Q(0))
    assert V==W==Q(15,64)
    trueI=[conditional_variance_influence(nu,f,i) for i in range(N+1)]
    assert trueI[0]==0 and trueI[1:3]==[Q(3,16),Q(3,16)]
    assert all(y==0 for y in trueI[3:])
    for i in range(N+1):
        mixtureI=sum((weights[t]*conditional_variance_influence(comps[t],f,i)
                      for t in (0,1)),Q(0))
        assert trueI[i]>=mixtureI
    return N, minratio, V, max(trueI)

def product_q(items):
    result=Q(1)
    for a in items:
        result*=a
    return result

for n in (2,4,8):
    values=example(n)
    print("PASS N=%s minimum-density=%s variance=%s max-true-influence=%s" % values)
print("PASS: exact component-variance identity and true correlated influence domination")
