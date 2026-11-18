#!/usr/bin/env python3
"""Exact source audit for anchored multipartite exponent-two theorem.

Independent construction: exhaustive categorical+fair-sign source tables and
actual resampling influences. No ANOVA decomposition is assumed in verifier.
This checks examples, not a universal mathematical proof.
"""
from fractions import Fraction as Q
from itertools import product
from math import prod
import random


def test_model(laws_a, groups, seed):
    rng=random.Random(seed)
    p=len(laws_a)
    sign_counts=[len(g) for g in groups]
    d=len(groups)+1
    all_anchor=list(product(*(range(len(x)) for x in laws_a)))
    sign_flats=list(product((-1,1),repeat=sum(sign_counts)))
    signs=list(product(*[list(product((-1,1),repeat=n)) for n in sign_counts]))
    nsign=2**sum(sign_counts)
    # coefficients are arbitrary centered functions of each full categorical atom
    coeff={}
    for i,law in enumerate(laws_a):
        for inds in product(*(range(k) for k in sign_counts)):
            raw=[Q(rng.randrange(-5,6)) for _ in law]
            mu=sum(raw[a]*law[a] for a in range(len(law)))
            coeff[i,inds]=tuple(raw[a]-mu for a in range(len(law)))
    def parts(aa,ee):
        v=[]
        for i in range(p):
            z=sum((coeff[i,inds][aa[i]]*prod(ee[g][inds[g]] for g in range(d-1))
                   for inds in product(*(range(k) for k in sign_counts))),Q())
            v.append(z)
        return tuple(v)
    states=[]
    vals={}
    for aa in all_anchor:
        for ee in signs:
            key=tuple(aa)+tuple(x for group in ee for x in group)
            states.append(key)
            vals[key]=sum(parts(aa,ee),Q())
    def weight(xx):
        return prod(laws_a[i][xx[i]] for i in range(p))/nsign
    B=max(abs(v) for x,v in vals.items() if weight(x) > 0)
    mean=sum(weight(x)*v for x,v in vals.items())
    V=sum(weight(x)*(v-mean)**2 for x,v in vals.items())
    assert mean==0
    influences=[]
    for i in range(p+sum(sign_counts)):
        if i<p:
            # influence as 1/2 expected squared difference with independent resampling
            I=sum((weight(x)*laws_a[i][new]*(
                 vals[x]-vals[x[:i]+(new,)+x[i+1:])**2/2
                 for x in states for new in range(len(laws_a[i]))),Q())
        else:
            I=sum((weight(x)*(vals[x]-vals[x[:i]+(-x[i],)+x[i+1:])**2/4
                 for x in states),Q())
        influences.append(I)
    a_inf=[]
    for i in range(p):
        vi=sum((weight(x)*parts(x[:p], tuple(
            x[p+sum(sign_counts[:j]):p+sum(sign_counts[:j+1])] for j in range(d-1)))[i]**2
            for x in states),Q())
        assert influences[i]==vi,(i,influences[i],vi)
        a_inf.append(vi)
    assert sum(a_inf)==V,(V,a_inf)
    assert V*V <= Q(2)**(d-1)*B*B*max(influences[:p])
    # exact conditional-oscillation certificate: sum of ranges <=2 B
    for ee in signs:
        osc=Q()
        for i in range(p):
            ss=[]
            for atom in range(len(laws_a[i])):
                if laws_a[i][atom] == 0:
                    continue
                aa=tuple(atom if j==i else 0 for j in range(p))
                ss.append(parts(aa,ee)[i])
            osc+=max(ss)-min(ss)
        assert osc<=2*B,(osc,B,ee)
    return dict(d=d,states=len(states),B=str(B),V=str(V),M=str(max(influences[:p])),ratio=str(V*V/(B*B*max(influences[:p]))) if B and max(influences[:p]) else '0')


def main():
    # Vary all anchor laws; no atom lower floor. Fair sign blocks of varying sizes.
    trials=0
    best={}
    settings=[
      ([(Q(1,3),Q(2,3)),(Q(1,7),Q(2,7),Q(4,7))],[(0,1),(0,1)]),
      ([(Q(1,23),Q(22,23)),(Q(1,11),Q(4,11),Q(6,11))],[(0,1),(0,1)]),
      ([(Q(1,5),Q(4,5)),(Q(1,3),Q(2,3))],[(0,1),(0,1),(0,)]),
      ([(Q(0),Q(1,7),Q(6,7)),(Q(1,9),Q(0),Q(8,9))],[(0,1),(0,1)]),
    ]
    for laws,groups in settings:
        for k in range(18):
            got=test_model(laws,groups,seed=91023+97*trials)
            trials+=1
            if got['d'] not in best or Q(got['ratio'])>Q(best[got['d']]['ratio']):
                best[got['d']]=got
    print('PASS',trials,'exact heterogeneous multipartite source trials')
    for d,x in sorted(best.items()):
        print('degree',d,'max observed ratio',x['ratio'],'bound',2**(d-1), 'states',x['states'])
    print('PASS each actual resampling influence, anchor energy partition, pointwise range budget')
    print('SCOPE exact finite instances only, NOT unrestricted cubic / Lean certification')


if __name__=='__main__':
    main()
