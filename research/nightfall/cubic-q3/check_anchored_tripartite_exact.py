#!/usr/bin/env python3
"""Independent Fraction audit of anchored tripartite cubic e2; finite examples only."""
from fractions import Fraction as Q
from itertools import product
from math import prod

def audit(anchor_laws, seed=1):
    n = len(anchor_laws)
    assert 1 <= n <= 3
    all_signs = tuple(product((-1, 1), repeat=4))
    atoms = tuple(product(*(range(len(p)) for p in anchor_laws)))
    weights = {a:prod(anchor_laws[i][a[i]] for i in range(n)) for a in atoms}
    assert sum(weights.values()) == 1
    # Dense bilinear links with multiple categorical modes per anchor.
    c = {}
    for i, law in enumerate(anchor_laws):
        for j in range(2):
            for k in range(2):
                for a in range(len(law)):
                    raw = [Q((seed+i*11+j*7+k*5+t*t*3+2*t*i)%13-6,5) for t in range(len(law))]
                    avg = sum(law[t]*raw[t] for t in range(len(law)))
                    c[i,j,k,a] = raw[a]-avg
                assert sum(law[a]*c[i,j,k,a] for a in range(len(law))) == 0
    def row(i,a,s):
        b1,b2,d1,d2=s
        b=(b1,b2);d=(d1,d2)
        return sum(c[i,j,k,a]*b[j]*d[k] for j in range(2) for k in range(2))
    def f(a,s):
        return sum(row(i,a[i],s) for i in range(n))
    states=tuple((a,s) for a in atoms for s in all_signs)
    prob=lambda a: weights[a]*Q(1,16)
    mean=sum(prob(a)*f(a,s) for a,s in states)
    assert mean==0
    var=sum(prob(a)*f(a,s)**2 for a,s in states)
    B=max(abs(f(a,s)) for a,s in states)
    influence=[]
    for i in range(n):
        I=Q(0)
        for a,s in states:
            for t,pt in enumerate(anchor_laws[i]):
                a2=tuple(t if m==i else a[m] for m in range(n))
                I+=prob(a)*pt*(f(a,s)-f(a2,s))**2/2
        influence.append(I)
    for m in range(4):
        I=Q(0)
        for a,s in states:
            sp=tuple(-x if t==m else x for t,x in enumerate(s))
            I+=prob(a)*((f(a,s)-f(a,sp))/2)**2
        influence.append(I)
    M=max(influence)
    ratio=var**2/(B**2*M) if M>0 and B>0 else Q(0)
    assert ratio<=4,ratio
    by_anchor=[]
    for i,law in enumerate(anchor_laws):
        vi=sum(law[t]*c[i,j,k,t]**2 for j in range(2) for k in range(2) for t in range(len(law)))
        assert vi == influence[i]
        by_anchor.append(vi)
    assert var==sum(by_anchor)
    print(f'PASS seed={seed}, anchors={[len(p) for p in anchor_laws]}, B={B}, V={var}, M={M}, ratio={ratio}')

def routing(z):
    a=z[:4]; b1,b2,c1,c2=z[4:]
    st=tuple(product((-1,1),repeat=2))
    return sum(a[t]*(b1+s*b2)*(c1+r*c2) for t,(s,r) in enumerate(st))/4

if __name__=='__main__':
    cases=[[(Q(2,5),Q(3,5))],
           [(Q(1,2),Q(1,3),Q(1,6))],
           [(Q(2,5),Q(3,5)),(Q(1,2),Q(1,3),Q(1,6))],
           [(Q(1,4),Q(3,4)),(Q(2,7),Q(5,7)),(Q(1,2),Q(1,3),Q(1,6))]]
    for laws in cases:
        for seed in [1,2,4,7]:
            audit(laws,seed)
    bits=tuple(product((-1,1),repeat=8))
    assert {routing(z) for z in bits}=={Q(-1),Q(1)}
    rv=sum(routing(z)**2 for z in bits)/256
    infs=[]
    for i in range(8):
        infs.append(sum(((routing(z)-routing(z[:i]+(-z[i],)+z[i+1:]))/2)**2 for z in bits)/256)
    assert rv==1 and max(infs)==Q(1,2) and rv**2/max(infs)==2
    print('PASS exact 256-state routing: variance 1, B 1, M 1/2, ratio 2 <= 4')
    print('PASS all 16 heterogeneous anchor cases and routing stress test')
