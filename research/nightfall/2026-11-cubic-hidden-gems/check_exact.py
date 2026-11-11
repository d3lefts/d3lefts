#!/usr/bin/env python3
"""Independent exact finite checker for selector projection and weighted cubic cover.
Standard-library fractions, no numerical fitting. Finite checks are not proofs.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random
from math import sqrt

rng=Random(20261110)

def vavg(table, states, weights):
    mu=sum((weights[s]*table[s] for s in states),Q(0))
    return sum((weights[s]*(table[s]-mu)**2 for s in states),Q(0))

def anova(table, doms, weights):
    n=len(doms)
    states=list(product(*doms))
    def conditional(S):
        res={}
        for st in states:
            z=Q(0)
            for other in states:
                if all(st[i]==other[i] for i in S):
                    z+=weights[other]*table[other]
            ps=sum((weights[other] for other in states
                    if all(st[i]==other[i] for i in S)),Q(0))
            res[st]=z/ps
        return res
    cond={S:conditional(S) for sz in range(n+1)
          for S in combinations(range(n),sz)}
    h={}
    for sz in range(n+1):
        for S in combinations(range(n),sz):
            h[S]={st:cond[S][st]-sum((h[T][st] for ts in range(sz)
                           for T in combinations(S,ts)),Q(0)) for st in states}
    return h

for t in range(14):
    n=4
    doms=[tuple(range(m)) for m in (2,3,2,2)]
    probs=[]
    for dom in doms:
        masses=[rng.randint(1,8) for _ in dom]
        probs.append({a:Q(v,sum(masses)) for a,v in zip(dom,masses)})
    states=list(product(*doms))
    weights={st:Q(1) for st in states}
    for st in states:
        for i,a in enumerate(st): weights[st]*=probs[i][a]
    phi=[]
    for i,dom in enumerate(doms):
        vals={a:Q(rng.randint(-4,4)) for a in dom}
        mean=sum((probs[i][a]*vals[a] for a in dom),Q(0))
        phi.append({a:vals[a]-mean for a in dom})
    coeff={S:Q(rng.randint(-5,5),rng.randint(1,4))
           for z in range(1,4) for S in combinations(range(n),z)}
    f={st:sum((c*__import__('math').prod(phi[i][st[i]] for i in S)
              for S,c in coeff.items()),Q(0)) for st in states}
    B=max(abs(x) for x in f.values())
    h=anova(f,doms,weights)
    assert all(v==0 for v in h[(0,1,2,3)].values())
    energies={S:sum((weights[st]*v*v for st,v in h[S].items()),Q(0)) for S in h}
    V=sum((energies[S] for S in energies if S),Q(0))
    total_I=[sum((energies[S] for S in energies if i in S),Q(0))
             for i in range(n)]
    assert V==vavg(f,states,weights)
    projections=[]
    for mask in range(1<<n):
        leaves={i for i in range(n) if mask&(1<<i)}
        keep=[S for S in h if len(set(S)&leaves)==1]
        qf={st:sum((h[S][st] for S in keep),Q(0)) for st in states}
        vq=vavg(qf,states,weights)
        assert vq==sum((energies[S] for S in keep),Q(0))
        assert max(abs(x) for x in qf.values())<=18*B
        for i in range(n):
            assert sum((energies[S] for S in keep if i in S),Q(0))<=total_I[i]
        projections.append(vq)
    p=Q(2,5)
    expected=sum((projections[mask]*p**mask.bit_count()*
                  (1-p)**(n-mask.bit_count()) for mask in range(1<<n)),Q(0))
    predicted=sum((E*len(S)*p*(1-p)**(len(S)-1)
                    for S,E in energies.items() if S),Q(0))
    assert expected==predicted
    assert expected>=Q(2,5)*V

alpha=1-1/sqrt(3)
assert abs(3*alpha*(1-alpha)**2-alpha)<1e-14
assert 2*alpha*(1-alpha)>alpha
assert abs(18/alpha-(27+9*sqrt(3)))<1e-12

for k in range(3,45):
    e={}
    for j in range(k):
        for z in (j,(j+1)%k):
            S=frozenset((('x',j),('y',j),('z',z)))
            assert S not in e
            e[S]=Q(1,2*k)
    assert len(e)==2*k
    E={S:c*c for S,c in e.items()}
    V=sum(E.values(),Q(0))
    idx={i for S in e for i in S}
    influences={i:sum((E[S] for S in e if i in S),Q(0)) for i in idx}
    assert V==Q(1,2*k)
    assert all(v==Q(1,2*k*k) for v in influences.values())
    H={('x',j) for j in range(k)}
    assert all(S&H for S in e)
    assert sum((influences[i] for i in H),Q(0))==Q(1,2*k)
    assert max(sum(i in S for S in e) for i in idx)==2

print('PASS: 14 mixed-alphabet exact ANOVA tables, 16 partitions per table')
print('PASS: influence contraction, random-color variance identity, norm bound')
print('PASS: symbolic cubic constant and exact cyclic families k=3..44')
print('LIMIT: finite arithmetic only; no unrestricted cubic result or novelty verification')
