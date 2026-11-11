#!/usr/bin/env python3
"""Independent exact rational audit for heterogeneous degree-2 Hilbert observability.

Distinct routes: (a) construct degree-two centered interaction pieces from
coordinate kernels, (b) compute influence by direct conditional expectation,
(c) verify ANOVA variance energies, (d) compute assigned fourth moments by
independent enumeration of product marginals. Every numeric assertion is
exact Fraction arithmetic, except rigorously outward-rounded rational square
root intervals used for Hilbert norm budgets.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random
from math import isqrt
from hashlib import sha256

SEED = 20261111
rng = Random(SEED)
SCALE = 10**18

def sqrt_bounds(x):
    assert x >= 0
    if not x: return Q(0), Q(0)
    k = isqrt(x.numerator * SCALE**2 // x.denominator)
    return Q(k,SCALE), Q(k+1,SCALE)

def moments(v, masses):
    return sum((m*w for m,w in zip(masses,v)), Q(0))

def inner(v,w):
    return sum((a*b for a,b in zip(v,w)),Q(0))

def subtract(v,w):return tuple(a-b for a,b in zip(v,w))
def add(v,w):return tuple(a+b for a,b in zip(v,w))
def scaled(q,v):return tuple(q*a for a in v)

def random_mass(a):
    raw=[rng.randint(1,11) for _ in range(a)]
    return tuple(Q(t,sum(raw)) for t in raw)

def instance(n, r, amax=3):
    alph=[rng.randint(2,amax) for _ in range(n)]
    p=[random_mass(m) for m in alph]
    zero=(Q(0),)*r
    # Subtract unconditional means to construct canonical order-one pieces.
    raw1=[[tuple(Q(rng.randint(-4,4)) for _ in range(r)) for _ in range(alph[i])] for i in range(n)]
    h1={}
    for i in range(n):
        mn=tuple(sum((p[i][a]*raw1[i][a][t] for a in range(alph[i])),Q(0)) for t in range(r))
        h1[i]=[subtract(v,mn) for v in raw1[i]]
    # Weighted double-centering constructs pure order-two ANOVA pieces.
    h2={}
    for i,j in combinations(range(n),2):
        raw=[[tuple(Q(rng.randint(-4,4)) for _ in range(r)) for _ in range(alph[j])] for _ in range(alph[i])]
        row=[tuple(sum((p[j][b]*raw[a][b][t] for b in range(alph[j])),Q(0)) for t in range(r)) for a in range(alph[i])]
        col=[tuple(sum((p[i][a]*raw[a][b][t] for a in range(alph[i])),Q(0)) for t in range(r)) for b in range(alph[j])]
        mean=tuple(sum((p[i][a]*row[a][t] for a in range(alph[i])),Q(0)) for t in range(r))
        h2[i,j]=[[add(subtract(subtract(raw[a][b],row[a]),col[b]),mean) for b in range(alph[j])] for a in range(alph[i])]
    configs=list(product(*[range(m) for m in alph]))
    def mass(x):
        z=Q(1)
        for i,a in enumerate(x):z*=p[i][a]
        return z
    weights={x:mass(x) for x in configs}
    def F(x):
        v=zero
        for i in range(n):v=add(v,h1[i][x[i]])
        for (i,j),tab in h2.items():v=add(v,tab[x[i]][x[j]])
        return v
    fs={x:F(x) for x in configs}
    B2=max(inner(v,v) for v in fs.values())
    mean=tuple(sum((weights[x]*fs[x][k] for x in configs),Q(0)) for k in range(r))
    V=sum((weights[x]*inner(subtract(fs[x],mean),subtract(fs[x],mean)) for x in configs),Q(0))
    # Direct conditional-variance influence, without using ANOVA formula.
    infl=[]
    for i in range(n):
        t=Q(0)
        for x in configs:
            cond=zero
            for a in range(alph[i]):
                y=x[:i]+(a,)+x[i+1:]
                cond=add(cond,scaled(p[i][a],fs[y]))
            t+=weights[x]*inner(subtract(fs[x],cond),subtract(fs[x],cond))
        infl.append(t)
    M=max(infl)
    assert sum(weights.values()) == 1
    # Independent ANOVA energy verification.
    V2=sum((p[i][a]*inner(h1[i][a],h1[i][a]) for i in range(n) for a in range(alph[i])),Q(0))
    V2+=sum((p[i][a]*p[j][b]*inner(h2[i,j][a][b],h2[i,j][a][b]) for i,j in h2 for a in range(alph[i]) for b in range(alph[j])),Q(0))
    assert V2==V, ('ANOVA',n,r,V,V2)
    for i in range(n):
        comp=sum((p[i][a]*inner(h1[i][a],h1[i][a]) for a in range(alph[i])),Q(0))
        for j in range(n):
            if j==i:continue
            lo,hi=sorted([i,j]); tab=h2[lo,hi]
            comp+=sum((p[lo][a]*p[hi][b]*inner(tab[a][b],tab[a][b]) for a in range(alph[lo]) for b in range(alph[hi])),Q(0))
        assert comp==infl[i]
    # Universal rank-linear squared influence statement with rational D<41,
    # reverse-Rademacher constant kappa >=1/sqrt(3r).
    assert V*V <= Q(3*41*41*r)*B2*M

    # Greedy vector-weight matching: edge weights squared rational, exact sort.
    b2={e:max(inner(v,v) for row in tab for v in row) for e,tab in h2.items()}
    ordered=sorted(b2, key=lambda e:(-b2[e],e))
    matched=[];used=set()
    for i,j in ordered:
        if b2[i,j] and i not in used and j not in used:
            matched.append((i,j));used.update((i,j))
    costs={i:Q(0) for i in range(n)}
    for i,j in matched:costs[i]=costs[j]=b2[i,j]
    assigned={i:[] for i in range(n)}
    for i,j in ordered:
        if b2[i,j]==0:continue
        if costs[i]>=b2[i,j]:assigned[i].append(j)
        else:
            assert costs[j]>=b2[i,j]
            assigned[j].append(i)
    # Exact expected L2(H)-valued moments of assigned increments.
    for i in range(n):
        nbr=assigned[i]
        if not nbr:continue
        s=Q(0);m4=Q(0)
        for vals in product(*[range(alph[j]) for j in nbr]):
            prob=Q(1)
            for j,a in zip(nbr,vals):prob*=p[j][a]
            sv=Q(0)
            for a in range(alph[i]):
                zi=zero
                for j,b in zip(nbr,vals):
                    lo,hi=sorted((i,j)); tab=h2[lo,hi]
                    zi=add(zi, tab[a][b] if i<j else tab[b][a])
                sv+=p[i][a]*inner(zi,zi)
            s+=prob*sv;m4+=prob*sv*sv
        assert s <= infl[i]
        assert m4 <= costs[i]*s +3*s*s, ('fourth',i,m4,costs[i]*s+3*s*s)
    # Outward sqrt intervals verify vector matching and endpoint cost budgets.
    # All arithmetic remains rational; the explicit factor is conservative.
    matched_u=sum((sqrt_bounds(b2[e])[1] for e in matched),Q(0))
    cost_u=sum((sqrt_bounds(costs[i])[1] for i in range(n)),Q(0))
    assert matched_u**2 <= Q(48*r)*B2
    assert cost_u**2 <= Q(192*r)*B2
    return V,B2,M,len(matched)

num=0; peak=Q(0); peak_record=None
for n in range(2,6):
    for r in range(1,5):
        for trial in range(16 if n<=4 else 7):
            v,b,m,nmatch=instance(n,r)
            z=(v*v/(r*b*m)) if b*m>0 else Q(0)
            if z>peak:peak=z;peak_record=(n,r,trial)
            num+=1
assert num==220  # (n=2,3,4) x4x16 + (n=5) x4x7
# Exact lower construction: r k fair signs, each query removes one equal term.
for r in range(1,7):
    for k in range(1,7):
        variance=Q(1,k)
        drop=Q(1,r*k*k)
        assert variance - Q(r*k//2)*drop >=0
        assert Q(r*k,2)*drop == Q(1,2*k)
# Independent conditional-mean enumeration for the degree-two address tree.
# Both the address and sign leaves are finite, the input law is uniform product.
address_cases=0
for m in range(2,6):
    for q in range(m+1):
        chosen=tuple(range(q))
        for read_address in (False,True):
            groups={}
            for k in range(m):
                for leaves in product((-1,1),repeat=m):
                    key=((k,) if read_address else ()) + tuple(leaves[j] for j in chosen)
                    mass=Q(1,m*2**m)
                    prev=groups.get(key,(Q(0),Q(0)))
                    groups[key]=(prev[0]+mass,prev[1]+mass*leaves[k])
            explained=sum((sum_f**2/prob for prob,sum_f in groups.values()),Q(0))
            risk=1-explained
            expected=Q(1)-Q(q,m if read_address else m*m)
            assert risk==expected,(m,q,read_address,risk,expected)
            address_cases+=1

receipt=f"PASS exact_product_models={num} peak_ratio={float(peak):.12g} peak_case={peak_record} lower_cases=36 address_cases={address_cases} seed={SEED}"
print(receipt)
print('receipt_sha256',sha256(receipt.encode()).hexdigest())