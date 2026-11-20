#!/usr/bin/env python3
"""Independent exact Fraction checks of reference-star maximal coupling and Phi.
FINITE REGRESSIONS ONLY. Does not prove the full mixture-AA theorem.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random
import json

def tv(p,q): return sum((abs(a-b) for a,b in zip(p,q)),Q())/2

def star_coupling(p,q):
    """Joint R[b][y] with B~q, Y~p. Includes zero atoms and TV=0."""
    k=len(p); overlap=[min(a,b) for a,b in zip(p,q)]
    dp=[p[i]-overlap[i] for i in range(k)]
    dq=[q[i]-overlap[i] for i in range(k)]
    t=tv(p,q)
    R=[[Q(int(b==y))*overlap[b]+(dq[b]*dp[y]/t if t else Q()) for y in range(k)] for b in range(k)]
    assert all(z>=0 for row in R for z in row)
    assert all(sum(R[b],Q())==q[b] for b in range(k))
    assert all(sum((R[b][y] for b in range(k)),Q())==p[y] for y in range(k))
    assert sum((R[b][y] for b in range(k) for y in range(k) if b!=y),Q())==t
    return R

def rand_p(r,k):
    x=[r.randrange(0,8) for _ in range(k)]
    if not sum(x): x[r.randrange(k)]=1
    return [Q(z,sum(x)) for z in x]

def mean_increment(p,values,coord,shape):
    n=len(shape)
    ans=Q()
    for x in product(*(range(k) for k in shape)):
        px=Q(1)
        for i in range(n): px*=p[i][x[i]]
        for b in range(shape[coord]):
            y=x[:coord]+(b,)+x[coord+1:]
            ans+=px*p[coord][b]*abs(values[x]-values[y])
    return ans

def potential_identity(weights,probs,values,shape):
    n=len(shape);m=len(weights)
    before=sum((weights[t]*sum((mean_increment(probs[t],values,i,shape) for i in range(n)),Q()) for t in range(m)),Q())
    for j in range(n):
        Lj=sum((weights[t]*mean_increment(probs[t],values,j,shape) for t in range(m)),Q())
        after=Q()
        for b in range(shape[j]):
            pred=sum((weights[t]*probs[t][j][b] for t in range(m)),Q())
            if pred==0: continue # posterior undefined, branch has probability 0
            post=[weights[t]*probs[t][j][b]/pred for t in range(m)]
            assert sum(post,Q())==1
            Ppost=[]
            for t in range(m):
                Ppost.append([([Q(int(a==b)) for a in range(shape[i])]
                               if i==j else probs[t][i]) for i in range(n)])
            after+=pred*sum((post[t]*sum((mean_increment(Ppost[t],values,i,shape) for i in range(n)),Q()) for t in range(m)),Q())
        assert before-after==Lj,(before,after,Lj,j)

def run():
    r=Random(20261119)
    counters={'component_reference_pairs':0,'zero_weight_branches':0,'potential_queries':0,'zero_mass_component_values':0,'fixtures':0}
    for trial in range(240):
        n=r.randint(1,3);m=r.randint(1,4)
        shape=tuple(r.randint(2,3) for _ in range(n))
        raw=[r.randrange(0,8) for _ in range(m)]
        if sum(raw)==0: raw[0]=1
        w=[Q(v,sum(raw)) for v in raw]
        probs=[[rand_p(r,shape[j]) for j in range(n)] for t in range(m)]
        vals={x:Q(r.randrange(-5,6),10) for x in product(*(range(k) for k in shape))}
        for j in range(n):
            bar=[sum((w[t]*probs[t][j][a] for t in range(m)),Q()) for a in range(shape[j])]
            for t in range(m):
                R=star_coupling(probs[t][j],bar)
                for b in range(shape[j]):
                    if bar[b]:
                        cond=[R[b][a]/bar[b] for a in range(shape[j])]
                        assert sum(cond,Q())==1
                        assert all(z>=0 for z in cond)
                    else:
                        assert sum(R[b],Q())==0
                counters['component_reference_pairs']+=1
                if w[t]==0: counters['zero_mass_component_values']+=1
        for j in range(n):
            counters['zero_weight_branches']+=sum(1 for a in range(shape[j]) if all(w[t]*probs[t][j][a]==0 for t in range(m)))
            counters['potential_queries']+=1
        potential_identity(w,probs,vals,shape)
        counters['fixtures']+=1
    print(json.dumps({'status':'EXACT_FINITE_REGRESSIONS_NOT_PROOF','seed':20261119,'counts':counters},indent=2))
if __name__=='__main__': run()
