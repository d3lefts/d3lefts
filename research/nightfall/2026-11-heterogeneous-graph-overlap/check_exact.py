#!/usr/bin/env python3
"""Exact rational heterogeneous quadratic graph-overlap falsification.

Recomputes two-coordinate ANOVA by conditional expectations; checks matching
amplitude, centered-additive 7B bound, edge-color influence bound, weighted
core deletion, and greedy posterior ANOVA drift. No fair-sign or atom floor.
Finite checks are NOT a proof of the unrestricted dense-overlap theorem.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random

R = Random(20261111)
D = ((0, 1, 2), (0, 1), (0, 1, 2), (0, 1), (0, 1, 2))
GRAPHS = (
 ((0,1),(1,2),(2,3),(3,4)),
 ((0,1),(1,2),(2,3),(3,4),(0,3)),
 ((0,1),(0,3),(0,4),(1,2),(2,3)),
 ((0,1),(0,3),(1,2),(2,3),(2,4)),
)

def colors(edges):
    if not edges: return []
    for k in range(1,len(edges)+1):
        a=[]
        def rec(i):
            if i == len(edges): return True
            for j in range(k):
                if all(a[l]!=j or not (set(edges[i])&set(edges[l]))
                       for l in range(i)):
                    a.append(j)
                    if rec(i+1):return True
                    a.pop()
            return False
        if rec(0): return [[e for e,c in zip(edges,a) if c==j] for j in range(k)]
    raise AssertionError

def make(edges):
    laws=[]
    for i,d in enumerate(D):
        q=[R.randint(1,10) for _ in d]
        if i == 2:q[0]=1
        laws.append([Q(u,sum(q)) for u in q])
    features=[]
    for i,d in enumerate(D):
        fs=[]
        for _ in range(2):
            raw=[R.randint(-4,4) for _ in d]
            avg=sum((laws[i][j]*v for j,v in enumerate(raw)),Q())
            fs.append([Q(v)-avg for v in raw])
        features.append(fs)
    linear=[R.randint(-2,2) for i in D]
    quadratic={e:[R.randint(-3,3) for _ in range(4)] for e in edges}
    rows=[]
    for s in product(*D):
        p=Q(1)
        for i,a in enumerate(s):p*=laws[i][a]
        z=Q(2)+sum((linear[i]*features[i][0][s[i]] for i in range(5)),Q())
        for u,v in edges:
            for a in range(2):
                for b in range(2):
                    z+=quadratic[u,v][2*a+b]*features[u][a][s[u]]*features[v][b][s[v]]
        rows.append((s,p,z))
    assert sum((p for s,p,z in rows),Q()) == 1
    return rows

def post(rows,t):
    subset=[(s,p,z) for s,p,z in rows if all(s[i]==v for i,v in t.items())]
    mass=sum((p for s,p,z in subset),Q())
    assert mass>0
    return [(s,p/mass,z) for s,p,z in subset]

def stats(rows):
    mean=sum((p*z for s,p,z in rows),Q())
    V=sum((p*(z-mean)**2 for s,p,z in rows),Q())
    influences={}
    for i in range(5):
        groups={}
        for s,p,z in rows:
            key=s[:i]+s[i+1:]
            mass,m1,m2=groups.get(key,(Q(),Q(),Q()))
            groups[key]=(mass+p,m1+p*z,m2+p*z*z)
        influences[i]=sum((m2-m1*m1/mass
                            for mass,m1,m2 in groups.values()),Q())
    return V,influences

def audit(rows,edges):
    n=5
    B=max(abs(z) for s,p,z in rows)
    mu=sum((p*z for s,p,z in rows),Q())
    law=[{a:sum((p for s,p,z in rows if s[i]==a),Q())
          for a in D[i]} for i in range(n)]
    one=[{} for _ in range(n)]
    for i in range(n):
        for a in D[i]:
            one[i][a]=sum((p*z for s,p,z in rows if s[i]==a),Q())/law[i][a]-mu
    h={}
    for u,v in edges:
        hm={}
        for a in D[u]:
            for b in D[v]:
                pair=sum((p*z for s,p,z in rows if s[u]==a and s[v]==b),Q())/(law[u][a]*law[v][b])
                hm[a,b]=pair-one[u][a]-one[v][b]-mu
        h[u,v]=hm
    for s,p,z in rows:
        reconstructed=mu+sum((one[i][s[i]] for i in range(n)),Q())+sum((h[e][s[e[0]],s[e[1]]] for e in edges),Q())
        assert reconstructed==z
    assert max(abs(mu+sum((one[i][s[i]] for i in range(n)),Q())) for s,p,z in rows)<=7*B
    sup={e:max(abs(v) for v in h[e].values()) for e in edges}
    for matching in colors(edges):
        assert sum((sup[e] for e in matching),Q())<=4*B
    V,I=stats(rows)
    M=max(I.values())
    c=len(colors(edges))
    assert V*V <= (7+4*c)**2 * B*B*M
    kappa=min((len(H)+4*len(colors([e for e in edges if e[0] not in H and e[1] not in H]))
               for mask in range(1<<5)
               for H in [{i for i in range(5) if mask&(1<<i)}]))
    assert V*V <= (7+kappa)**2 * B*B*M
    return kappa

def drift(rows):
    nstates=ndrift=0
    for mask in range(1<<5):
        idx=[i for i in range(5) if mask&(1<<i)]
        for vals in product(*(D[i] for i in idx)):
            t=dict(zip(idx,vals))
            pr=post(rows,t)
            V,I=stats(pr)
            T=sum(I.values(),Q())
            assert V<=T<=2*V
            nstates+=1
            for i in range(5):
                if i in t:continue
                law={a:sum((p for s,p,z in pr if s[i]==a),Q()) for a in D[i]}
                expected=Q()
                for a,pa in law.items():
                    next_t=dict(t);next_t[i]=a
                    expected+=pa*sum(stats(post(rows,next_t))[1].values(),Q())
                assert expected==T-I[i]
                ndrift+=1
    return nstates,ndrift

def main():
    certs=[]
    for graph in GRAPHS:
        for _ in range(12):
            certs.append(audit(make(graph),graph))
    states,steps=drift(make(GRAPHS[0]))
    assert (states,steps)==(576,816)
    print('PASS: 48 exact heterogeneous quadratic models; core certificate costs',sorted(set(certs)))
    print('PASS: matching/ANOVA and',states,'posterior states,',steps,'one-step drifts')
    print('SCOPE: finite examples only; no unrestricted density or priority proof')

if __name__=='__main__':main()
