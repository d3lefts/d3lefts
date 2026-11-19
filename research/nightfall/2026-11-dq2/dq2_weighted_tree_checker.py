#!/usr/bin/env python3
"""Exact-rational weighted-tree DQ2 transfer checks. Finite instances only."""
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random
from collections import deque
import json


def tree_paths(n, edges):
    adj=[[] for _ in range(n)]
    for u,v in edges: adj[u].append(v); adj[v].append(u)
    P={}
    for a in range(n):
        queue=deque([a]); parent={a:None}
        while queue:
            z=queue.popleft()
            for w in adj[z]:
                if w not in parent:
                    parent[w]=z; queue.append(w)
        for b in range(n):
            z=b; p=[]
            while z!=a:
                w=parent[z]; p.append(tuple(sorted((z,w))));z=w
            P[(a,b)]=frozenset(p)
    return P, adj


def eval_polynomial(x,a,b):
    return sum(a[i]*x[i] for i in a)+sum(c*x[i]*x[j] for (i,j),c in b.items())


def mean(law, f):
    return sum((p*f(x) for x,p in law.items()),Q(0))


def variance(law,f):
    z=mean(law,f);return mean(law,lambda x:f(x)**2)-z*z


def inf(law,f,i):
    grouped={}
    for x,p in law.items():
        key=x[:i]+x[i+1:]
        if key not in grouped:grouped[key]=[Q(0),Q(0),Q(0)]
        q=grouped[key];q[0]+=p;q[1]+=p*f(x);q[2]+=p*f(x)**2
    return sum((z2-z1*z1/den for den,z1,z2 in grouped.values()),Q(0))


def check(n,edges,ts,seed):
    P,adj=tree_paths(n,edges)
    t={tuple(sorted(e)):v for e,v in zip(edges,ts)}
    r={e:abs(v) for e,v in t.items()}
    weights={(u,v):_prod(r[e] for e in P[(u,v)]) for u in range(n) for v in range(n)}
    S=max(sum(weights[(u,v)] for v in range(n)) for u in range(n))
    D=max(1+sum(r[tuple(sorted((u,v)))]/(1-r[tuple(sorted((u,v)))]) for v in adj[u]) for u in range(n))
    vv=[]
    for u in range(n):
        rr=[r[tuple(sorted((u,v)))] for v in adj[u]]
        plus=_prod(1+q for q in rr); minus=_prod(1-q for q in rr)
        vv.append(4*plus*minus/(plus+minus)**2)
    vmin=min(vv)
    law={x:Q(1,2**n)*_prod(1+t[e]*x[e[0]]*x[e[1]] for e in t) for x in product((-1,1),repeat=n)}
    assert sum(law.values())==1
    assert all(p>0 for p in law.values())
    # Different projections: spin correlators and path bond identities.
    for i in range(n):
        for j in range(n):
            got=mean(law,lambda x:x[i]*x[j])
            predicted=_prod(t[e] for e in P[(i,j)])
            assert got==predicted
    pairs=list(combinations(range(n),2))
    for a,b in pairs:
        A=P[(a,b)]; avgA=_prod(t[e] for e in A)
        total=Q(0)
        for c,d in pairs:
            B=P[(c,d)]; avgB=_prod(t[e] for e in B)
            cov=mean(law,lambda x:x[a]*x[b]*x[c]*x[d])-avgA*avgB
            pred=_prod(t[e] for e in A^B)*(1-_prod(t[e]*t[e] for e in A&B))
            assert cov==pred,(a,b,c,d,cov,pred)
            total+=abs(cov)
        assert total<=S*S,(n,edges,a,b,total,S*S)
    rng=Random(seed)
    for _ in range(8):
        a={i:rng.randint(-3,3) for i in range(n)}
        b={e:rng.randint(-2,2) for e in pairs}
        f=lambda x:eval_polynomial(x,a,b)
        var=variance(law,f)
        refvar=sum(z*z for z in a.values())+sum(z*z for z in b.values())
        assert var<=S*S*refvar,('variance transfer',n,var,S*S*refvar)
        for i in range(n):
            native=inf(law,f,i)
            refinf=a[i]*a[i]+sum(b[tuple(sorted((i,j))) ]**2 for j in range(n) if j!=i)
            assert native>=vmin/D*refinf,('influence transfer',n,i,native,vmin/D*refinf)
    return {'n':n,'S':str(S),'D':str(D),'v':str(vmin),'transfer_K_over_K0':str(S**4*D/vmin),'edges':[(list(e),str(t[e])) for e in t]}


def _prod(xs):
    v=Q(1)
    for x in xs:v*=x
    return v


def run():
    cases=[(5,[(0,1),(1,2),(2,3),(3,4)]),
           (7,[(0,1),(0,2),(1,3),(1,4),(2,5),(2,6)]),
           (7,[(0,i) for i in range(1,7)]),
           (8,[(0,1),(1,2),(1,3),(3,4),(4,5),(4,6),(6,7)])]
    options=[Q(0),Q(1,4),Q(-1,3),Q(1,5),Q(-1,2),Q(1,7),Q(-1,4)]
    result=[check(n,E,[options[i%len(options)] for i in range(len(E))],20261117+n) for n,E in cases]
    return {'status':'PASS','cases':len(result),'exact_random_quadratics':len(result)*8, 'results':result,
            'scope':'finite exact tests, separate from analytic all-finite-tree proof and Lean certification'}

if __name__=='__main__':
    print(json.dumps(run(),indent=2))
