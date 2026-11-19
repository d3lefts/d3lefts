#!/usr/bin/env python3
"""Exact finite categorical selector theorem: V <= (k+t) max original resampling influence.

Independent enumerative checker, not a universal Lean proof.
"""
from itertools import product
from fractions import Fraction as F
from random import Random


def test(k, t, seed):
    rng=Random(seed)
    address_alph=(2,)*k
    addresses=list(product(*[range(q) for q in address_alph]))
    m=len(addresses)
    address_probs=[[F(rng.choice([1,2,3,4]),5),F(0)] for _ in range(k)]
    # use positive normalized categorical binary distributions
    address_probs=[[p[0],1-p[0]] for p in address_probs]
    leaf_probs=[F(rng.choice([1,2,3,4]),5) for _ in range(m*t)]
    g=[{yy:rng.randrange(-7,8) for yy in product((0,1),repeat=t)} for _ in addresses]
    allstates=list(product((0,1),repeat=k+m*t))
    def weight(x):
        w=F(1)
        for i in range(k):w*=address_probs[i][x[i]]
        for h,j in enumerate(range(k,k+m*t)):
            w*=leaf_probs[h] if x[j] else 1-leaf_probs[h]
        return w
    values={}; weights={}
    for x in allstates:
        a=addresses.index(tuple(x[:k]))
        values[x]=F(g[a][tuple(x[k+a*t:k+(a+1)*t])])
        weights[x]=weight(x)
    assert sum(weights.values())==1
    mu=sum((weights[x]*values[x] for x in allstates),F(0))
    V=sum((weights[x]*(values[x]-mu)**2 for x in allstates),F(0))
    supp=[values[x] for x in allstates if weights[x]]
    B=F(max(supp)-min(supp),2)
    inf=[]
    for i in range(k+m*t):
        agg={}
        for x in allstates:
            key=x[:i]+x[i+1:]
            z=agg.setdefault(key,[F(0),F(0),F(0)])
            z[0]+=weights[x]
            z[1]+=weights[x]*values[x]
            z[2]+=weights[x]*values[x]**2
        I=sum((z[2]-z[1]*z[1]/z[0] for z in agg.values() if z[0]),F(0))
        inf.append(I)
    M=max(inf)
    assert V<=(k+t)*M, (k,t,seed,V,M)
    assert V*V<=(k+t)*B*B*M
    # Independent ANOVA/tower reconstruction: original leaf source variance
    leaf_projection_var=F(0)
    for a in range(m):
        pa=F(1)
        for j,v in enumerate(addresses[a]):pa*=address_probs[j][v]
        lws={yy:F(1) for yy in product((0,1),repeat=t)}
        for yy in lws:
            for j,yj in enumerate(yy):
                q=leaf_probs[a*t+j]
                lws[yy]*=q if yj else 1-q
        mg=sum((lws[y]*g[a][y] for y in lws),F(0))
        vg=sum((lws[y]*(g[a][y]-mg)**2 for y in lws),F(0))
        leaf_projection_var+=pa*pa*vg
    assert V-leaf_projection_var>=0
    assert V-leaf_projection_var<=sum(inf[:k]), (k,t,seed)
    assert leaf_projection_var<=t*M
    return V,M,B


def main():
    n=0
    for k,t,number in [(1,1,40),(1,2,30),(2,1,30),(2,2,15)]:
        for j in range(number):
            test(k,t,34001+97*k+91*t+j)
            n+=1
    print('PASS',n,'independent exact categorical-selector tests, including cubic k=2,t=1')
    print('Scope: scoped selector inequality; NOT unrestricted degree-three UE2')

if __name__=='__main__':main()
