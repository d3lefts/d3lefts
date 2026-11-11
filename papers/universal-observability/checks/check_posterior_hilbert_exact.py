#!/usr/bin/env python3
"""Independent exact finite audit for product ANOVA, Hilbert signs and posterior drift.

No imported NIGHTFALL helper or floating probability arithmetic. This is a
falsification suite, NOT a proof of all-law analytic inequalities.
"""
from fractions import Fraction as F
from itertools import product, combinations
import random
import json

SEED=20261111
rng=random.Random(SEED)

def distributions(n):
    out=[]
    for j in range(n):
        weights=[rng.randrange(0,5) for _ in range(rng.randrange(2,4))]
        if not any(weights):weights[0]=1
        z=sum(weights)
        out.append(tuple(F(k,z) for k in weights))
    return out

def states(probs, pins):
    for x in product(*(range(len(q)) for q in probs)):
        if any(x[i]!=a for i,a in pins.items()):continue
        p=F(1)
        for i,q in enumerate(probs):
            if i not in pins:p*=q[x[i]]
        if p:yield x,p

def sample_function(probs,r):
    # Degree at most two, including nontrivial non-Boolean alphabets.
    n=len(probs)
    a=[tuple(rng.randrange(-3,4) for _ in q) for q in probs]
    b={(i,j):tuple(tuple(rng.randrange(-3,4) for _ in probs[j]) for _ in probs[i])
       for i in range(n) for j in range(i+1,n)}
    shift=[rng.randrange(-2,3) for _ in range(r)]
    vals={}
    for x in product(*(range(len(q)) for q in probs)):
        base=sum(a[i][x[i]] for i in range(n))
        pair=sum(b[i,j][x[i]][x[j]] for i in range(n) for j in range(i+1,n))
        vals[x]=tuple(F((k+1)*base+(r-k)*pair+shift[k],20) for k in range(r))
    return vals

def dot(a,b):
    return sum((x*y for x,y in zip(a,b)),F(0))

def conditional_average(vals,probs,i,x):
    z=tuple(F(0) for _ in vals[x])
    return tuple(sum((probs[i][v]*vals[x[:i]+(v,)+x[i+1:]][k]
        for v in range(len(probs[i]))),F(0)) for k in range(len(z)))

def total_influence(vals,probs,pins):
    n=len(probs)
    infl=[]
    for i in range(n):
        if i in pins:
            infl.append(F(0));continue
        itotal=F(0)
        for x,p in states(probs,pins):
            dif=tuple(vals[x][k]-conditional_average(vals,probs,i,x)[k]
                for k in range(len(vals[x])))
            itotal+=p*dot(dif,dif)
        infl.append(itotal)
    return infl

def variance(vals,probs,pins):
    mu=tuple(sum((p*vals[x][k] for x,p in states(probs,pins)),F(0))
             for k in range(len(next(iter(vals.values())))))
    return sum((p*dot(tuple(z-m for z,m in zip(vals[x],mu)),
                       tuple(z-m for z,m in zip(vals[x],mu)))
                for x,p in states(probs,pins)),F(0))

def matrix_influence(vals,probs,pins,i):
    r=len(next(iter(vals.values())))
    a=[[F(0)]*r for _ in range(r)]
    if i in pins:return a
    for x,p in states(probs,pins):
        dif=[z-m for z,m in zip(vals[x],conditional_average(vals,probs,i,x))]
        for j in range(r):
            for k in range(r):a[j][k]+=p*dif[j]*dif[k]
    return a

def audit(trials=72):
    transcripts=0; drifts=0; signs=0; bounds=0
    for trial in range(trials):
        n=rng.randrange(2,5);r=rng.randrange(1,4)
        probs=distributions(n);vals=sample_function(probs,r)
        for depth in range(min(3,n)+1):
            for chosen in combinations(range(n),depth):
                for observed in product(*(range(len(probs[i])) for i in chosen)):
                    pins=dict(zip(chosen,observed))
                    if any(probs[i][v]==0 for i,v in pins.items()):continue
                    transcripts+=1
                    inf=total_influence(vals,probs,pins)
                    var=variance(vals,probs,pins)
                    P=sum(inf);assert var<=P<=2*var,(trial,pins,var,P)
                    bounds+=1
                    for i in range(n):
                        if i in pins:continue
                        Pnext=sum((probs[i][a]*sum(total_influence(vals,probs,pins|{i:a}))
                                   for a in range(len(probs[i]))),F(0))
                        assert P-Pnext==inf[i],(trial,pins,i,P,Pnext,inf[i])
                        drifts+=1
                        A=matrix_influence(vals,probs,pins,i)
                        assert sum(A[j][j] for j in range(r))==inf[i]
                        for eps in product((-1,1),repeat=r):
                            e=tuple(map(F,eps))
                            q=dot(e,tuple(dot(row,e) for row in A))
                            signed={x:(dot(vals[x],e),) for x in vals}
                            q_direct=total_influence(signed,probs,pins)[i]
                            assert q==q_direct
                            signs+=1
    return {'status':'PASS','seed':SEED,'exact_trials':trials,
            'positive_probability_transcripts':transcripts,
            'degree_two_energy_bounds':bounds,
            'exact_posterior_total_influence_drift_identities':drifts,
            'exact_signed_hilbert_influence_identities':signs,
            'notes':'No proof of universal all-law claim, independent finite falsification only.'}

if __name__=='__main__':
    print(json.dumps(audit(),sort_keys=True,indent=2))
