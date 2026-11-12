#!/usr/bin/env python3
"""Independent exact finite-model falsifier for the quadratic influence paper.

Checks Efron-Stein identities, Hoeffding energy, matching budgets,
Hilbert fourth-moment assignment, posterior weighted drift, sharpness,
and addressing.  All tested probabilities and arithmetic are rational.
Passing is NOT a proof of the general theorem.
"""
from fractions import Fraction as F
from itertools import product, combinations
from random import Random
from math import prod

RNG = Random(20261112)


def all_tuples(probs):
    return list(product(*(range(len(p)) for p in probs)))


def probability(probs, x, free=None):
    if free is None:
        free = range(len(probs))
    return prod((probs[i][x[i]] for i in free), start=F(1))


def make_model(n, seed):
    rng = Random(seed)
    banks = [(F(1, 2), F(1, 2)), (F(1, 3), F(1, 2), F(1, 6)),
             (F(1, 4), F(3, 4)), (F(2, 5), F(1, 5), F(2, 5))]
    probs = [banks[(seed+i) % len(banks)] for i in range(n)]
    contrasts = []
    for p in probs:
        means = [sum((p[x]*F(x**k) for x in range(len(p))), F()) for k in (1, 2)]
        contrasts.append([[F(x**k)-means[k-1] for x in range(len(p))] for k in (1, 2)])
    h1 = {}
    h2 = {}
    for i in range(n):
        a, b = rng.randint(-3, 3), rng.randint(-2, 2)
        h1[i] = tuple(a*contrasts[i][0][x]+b*contrasts[i][1][x] for x in range(len(probs[i])))
    for i, j in combinations(range(n), 2):
        c = [[rng.randint(-2, 2) for _ in range(2)] for _ in range(2)]
        h2[(i, j)] = tuple(tuple(sum((F(c[k][l])*contrasts[i][k][xi]*contrasts[j][l][xj]
                                     for k in range(2) for l in range(2)), F())
                                 for xj in range(len(probs[j])))
                           for xi in range(len(probs[i])))
    xs = all_tuples(probs)
    def f(x):
        return sum((h1[i][x[i]] for i in range(n)), F()) + sum((h2[i, j][x[i]][x[j]] for i,j in h2), F())
    vals = {x:f(x) for x in xs}
    return probs, h1, h2, xs, vals


def mean(vals, probs, xs):
    return sum((probability(probs,x)*vals[x] for x in xs), F())


def variance(vals, probs, xs):
    m=mean(vals,probs,xs)
    return sum((probability(probs,x)*(vals[x]-m)**2 for x in xs),F())


def conditional_influence(probs, vals, transcript, i):
    n=len(probs)
    Q=set(transcript)
    assert i not in Q
    free=[j for j in range(n) if j not in Q]
    xs=product(*(range(len(probs[j])) for j in free))
    result=F()
    for tup in xs:
        x=[None]*n
        for j,a in transcript.items(): x[j]=a
        for j,a in zip(free,tup): x[j]=a
        weight=probability(probs,x,free)
        fval=vals[tuple(x)]
        m=F()
        for ai,pi in enumerate(probs[i]):
            y=x.copy(); y[i]=ai
            m+=pi*vals[tuple(y)]
        result+=weight*(fval**2-m**2)
    return result


def posterior_p(probs, vals, transcript):
    return sum((conditional_influence(probs, vals, transcript, i)
                for i in range(len(probs)) if i not in transcript), F())


def fourth_moment_assignment(probs,h2):
    n=len(probs)
    edges=[]
    for (i,j),arr in h2.items():
        b=max(abs(z) for row in arr for z in row)
        if b: edges.append((b,i,j))
    edges.sort(reverse=True)
    selected=[]; used=set()
    for b,i,j in edges:
        if i not in used and j not in used:
            selected.append((b,i,j)); used.update((i,j))
    c=[F() for _ in range(n)]
    for b,i,j in selected: c[i]=b; c[j]=b
    assigned={i:[] for i in range(n)}
    for b,i,j in edges:
        k=i if c[i]>=b else j
        assert c[k]>=b
        assigned[k].append((i,j))
    for i in range(n):
        neigh=[j if i==k else k for k,j in assigned[i]]
        assert len(set(neigh))==len(neigh)
        s=F()
        for j in neigh:
            k,l=sorted((i,j))
            arr=h2[k,l]
            s+=sum((probs[k][x]*probs[l][y]*arr[x][y]**2
                    for x in range(len(probs[k])) for y in range(len(probs[l]))),F())
        fourth=F()
        for y in product(*(range(len(probs[j])) for j in neigh)):
            w=prod((probs[j][a] for j,a in zip(neigh,y)),start=F(1))
            norm2=F()
            for xi,pi in enumerate(probs[i]):
                z=F()
                for j,xj in zip(neigh,y):
                    k,l=sorted((i,j))
                    z+=h2[k,l][xi][xj] if k==i else h2[k,l][xj][xi]
                norm2+=pi*z*z
            fourth+=w*norm2*norm2
        assert fourth<=c[i]**2*s+3*s*s, (i, fourth, c[i]**2*s+3*s*s)
    return edges,selected,c


def audit_one(n, seed):
    probs,h1,h2,xs,vals=make_model(n,seed)
    B=max(abs(v) for v in vals.values())
    assert B>0
    V=variance(vals,probs,xs)
    I=[conditional_influence(probs,vals,{},i) for i in range(n)]
    assert sum(I)<=2*V
    additive=sum((probs[i][x]*h1[i][x]**2 for i in range(n)
                  for x in range(len(probs[i]))),F())
    pair=F()
    for (i,j),arr in h2.items():
        z=sum((probs[i][x]*probs[j][y]*arr[x][y]**2
               for x in range(len(probs[i])) for y in range(len(probs[j]))),F())
        pair+=z
        assert z>=0
    assert V==additive+pair,(V,additive,pair)
    for i in range(n):
        expected=sum((probs[i][x]*h1[i][x]**2 for x in range(len(probs[i]))),F())
        for (j,k),arr in h2.items():
            if i in (j,k):
                expected+=sum((probs[j][x]*probs[k][y]*arr[x][y]**2
                               for x in range(len(probs[j])) for y in range(len(probs[k]))),F())
        assert expected==I[i],(i,expected,I[i])
    # Test the theorem against a strictly smaller rational coefficient (1228 < C2).
    assert V*V<=F(1228)*B*B*max(I)
    edges,selected,c=fourth_moment_assignment(probs,h2)
    for mask in range(1<<len(edges)):
        es=[edges[k] for k in range(len(edges)) if mask&(1<<k)]
        endpoints=[i for _,i,j in es for i in (i,j)]
        if len(endpoints)==len(set(endpoints)):
            assert sum((b for b,_,_ in es),F())<=4*B
    assert sum(c)<=8*B
    drift_cases=0
    for k in range(n):
        for Q in combinations(range(n),k):
            for xq in product(*(range(len(probs[i])) for i in Q)):
                h=dict(zip(Q,xq)); p=posterior_p(probs,vals,h)
                for i in range(n):
                    if i in h: continue
                    after=sum((probs[i][xi]*posterior_p(probs,vals,{**h,i:xi})
                               for xi in range(len(probs[i]))),F())
                    assert p-after==conditional_influence(probs,vals,h,i), (seed,Q,xq,i,p,after)
                    drift_cases+=1
    return drift_cases


def sharpness():
    for m in range(1,6):
        probs=[(F(1,2),F(1,2)) for _ in range(2*m)]
        xs=all_tuples(probs)
        vals={x:sum(((2*x[2*k]-1)*(2*x[2*k+1]-1) for k in range(m)),F())/m for x in xs}
        assert variance(vals,probs,xs)==F(1,m)
        assert all(conditional_influence(probs,vals,{},i)==F(1,m*m) for i in range(2*m))


def addressing():
    for m in range(3,8):
        probs=[tuple(F(1,m) for _ in range(m))]+[(F(1,2),F(1,2)) for _ in range(m)]
        xs=all_tuples(probs)
        vals={x:F(2*x[x[0]+1]-1) for x in xs}
        assert variance(vals,probs,xs)==1
        for s in range(m+1):
            Q={0,*range(1,s+1)}
            # Bayes risk E[Var(f | observed Q)] = Var(f)-Var(E[f | Q]).
            p=F()
            for xq in product(*(range(len(probs[i])) for i in sorted(Q))):
                h=dict(zip(sorted(Q),xq));w=prod((probs[i][xi] for i,xi in h.items()),start=F(1))
                v=F()
                for x in xs:
                    if all(x[i]==xi for i,xi in h.items()):
                        v+=probability(probs,x,[j for j in range(m+1) if j not in Q])*vals[x]
                p+=w*v*v
            assert 1-p==F(m-s,m)


def main():
    total=0
    for n in (2,3,4):
        for seed in range(7):
            total+=audit_one(n,1000+100*n+seed)
        print(f"PASS n={n}: seven heterogeneous rational models")
    sharpness();print("PASS five exact quadratic sharpness examples")
    addressing();print("PASS five exact addressing risk curves")
    print(f"PASS {total} exact posterior drift identities across models")
    print("PASS all tested matching, Hoeffding, fourth-moment, and influence identities")
    print("SCOPE: finite falsification only; no general proof or Lean kernel certification")

if __name__=='__main__': main()
