#!/usr/bin/env python3
"""Independent exact rational audit of the six steps of a finite quadratic product theorem.
Uses only Python's standard library. This checks examples, NOT an all-input proof.
"""
from fractions import Fraction as F
from itertools import product, combinations
from random import Random
from math import sqrt

rng=Random(20261111)
total=0
checked={"sections":0, "oscillation":0, "ANOVA":0, "matching":0,
         "parity":0, "Hilbert4":0, "endpoint":0, "additive":0}

def prod(xs):
    a=1
    for x in xs:a*=x
    return a

def finite_model(n, sizes):
    omega=list(product(*(range(s) for s in sizes)))
    rows=[]
    for s in sizes:
        v=[rng.randint(1,11) for _ in range(s)]
        rows.append([F(x,sum(v)) for x in v])
    # Top-degree polynomial table, no assumed ANOVA centering.
    linear=[[rng.randint(-7,7) for _ in range(s)] for s in sizes]
    quad={(i,j):[[rng.randint(-5,5) for _ in range(sizes[j])]
                  for __ in range(sizes[i])] for i,j in combinations(range(n),2)}
    def f(x):
        return F(sum(linear[i][x[i]] for i in range(n))
                 +sum(quad[i,j][x[i]][x[j]] for i,j in quad))
    val={x:f(x) for x in omega}
    B=max(abs(v) for v in val.values())
    masses={x:prod(rows[i][x[i]] for i in range(n)) for x in omega}
    assert sum(masses.values()) == 1
    mean=sum((masses[x]*val[x] for x in omega),F(0))
    h1={}
    for i in range(n):
        for a in range(sizes[i]):
            marg=sum((masses[x]*val[x] for x in omega if x[i]==a),F(0))/rows[i][a]
            h1[i,a]=marg-mean
    h2={}
    for i,j in combinations(range(n),2):
        for a in range(sizes[i]):
            for b in range(sizes[j]):
                marg=sum((masses[x]*val[x] for x in omega if x[i]==a and x[j]==b),
                         F(0))/(rows[i][a]*rows[j][b])
                h2[i,j,a,b]=marg-mean-h1[i,a]-h1[j,b]
    for x in omega:
        assert val[x]==mean+sum(h1[i,x[i]] for i in range(n)) +sum(
            h2[i,j,x[i],x[j]] for i,j in combinations(range(n),2))
    checked["ANOVA"]+=1
    V=sum((masses[x]*(val[x]-mean)**2 for x in omega),F(0))
    I={}
    h1_energy={}
    for i in range(n):
        h1_energy[i]=sum(rows[i][a]*h1[i,a]**2 for a in range(sizes[i]))
        I[i]=h1_energy[i]+sum(
            rows[i][a]*rows[j][b]*h2[i,j,a,b]**2
            for j in range(i+1,n) for a in range(sizes[i]) for b in range(sizes[j])
        )+sum(
            rows[j][a]*rows[i][b]*h2[j,i,a,b]**2
            for j in range(i) for a in range(sizes[j]) for b in range(sizes[i])
        )
    assert V==sum(h1_energy.values())+sum(
        rows[i][a]*rows[j][b]*h2[i,j,a,b]**2
        for i,j in combinations(range(n),2)
        for a in range(sizes[i]) for b in range(sizes[j]))
    for i in range(n):
        # Independent check of resampling influence from the original table.
        e=F(0)
        for x in omega:
            for a in range(sizes[i]):
                y=x[:i]+(a,)+x[i+1:]
                e += F(1,2)*masses[x]*rows[i][a]*(val[x]-val[y])**2
        assert e==I[i]
    M=max(I.values())
    assert V*V <= F(1680)*B*B*M
    checked["endpoint"]+=1

    # Independent switch polynomial, at t=0,1/2,1, for each section extreme.
    for x in omega:
        oscillations=[]
        for i in range(n):
            section=[val[x[:i]+(a,)+x[i+1:]] for a in range(sizes[i])]
            oscillations.append(max(section)-min(section))
        assert sum(oscillations)<=16*B
        checked["oscillation"]+=1
        for direction in (1,-1):
            chosen=[]
            for i in range(n):
                ext=max if direction==1 else min
                a=ext(range(sizes[i]), key=lambda a:direction*val[x[:i]+(a,)+x[i+1:]])
                chosen.append(a)
            y=tuple(chosen)
            d=sum(val[x[:i]+(y[i],)+x[i+1:]]-val[x] for i in range(n))
            avg=sum(val[tuple(y[i] if (mask>>i)&1 else x[i] for i in range(n))]
                    for mask in range(1<<n))*F(1,2**n)
            assert d==-3*val[x]+4*avg-val[y]
            assert abs(d)<=8*B
            checked["sections"]+=1
        # Under independent fresh resampling, interpolate the additive ANOVA projection.
        half=F(0)
        for z in omega:
            prob=prod((F(1,2) if z[i]==x[i] else F(0))+rows[i][z[i]]*F(1,2)
                      for i in range(n))
            half += prob*val[z]
        assert -2*mean+4*half-val[x]==mean+sum(h1[i,x[i]] for i in range(n))
        assert abs(mean+sum(h1[i,x[i]] for i in range(n)))<=7*B
        checked["additive"]+=1

    weights={}
    witnesses={}
    for i,j in combinations(range(n),2):
        b=max(abs(h2[i,j,a,b]) for a in range(sizes[i]) for b in range(sizes[j]))
        weights[i,j]=b
        if b==0:continue
        a0,b0=next((a,b2) for a in range(sizes[i]) for b2 in range(sizes[j])
                   if abs(h2[i,j,a,b2])==b)
        sign=1 if h2[i,j,a0,b0]>0 else -1
        cand=[]
        for a1 in range(sizes[i]):
            for b1 in range(sizes[j]):
                delta=h2[i,j,a0,b0]+h2[i,j,a1,b1]-h2[i,j,a1,b0]-h2[i,j,a0,b1]
                cand.append((sign*delta,(a0,b0,a1,b1),delta))
        magnitude,quadruple,delta=max(cand)
        assert magnitude>=b
        witnesses[i,j]=(quadruple,delta)
    # Exhaust all disjoint edge subsets in this small graph.
    edges=list(weights)
    for mask in range(1<<len(edges)):
        matching=[edges[k] for k in range(len(edges)) if (mask>>k)&1]
        if len({v for edge in matching for v in edge})!=2*len(matching):continue
        assert sum(weights[e] for e in matching)<=4*B
        checked["matching"]+=1
        if not matching or any(e not in witnesses for e in matching):continue
        # Matching parity product law checked against arbitrary interactions.
        ev={}
        for parity in (0,1):
            options=[]
            for e in matching:
                a,b,c,d=witnesses[e][0]
                delta=witnesses[e][1]
                opts=([(a,b),(c,d)] if parity==0 else [(a,d),(c,b)])
                if delta<0:opts=([(a,d),(c,b)] if parity==0 else [(a,b),(c,d)])
                options.append(opts)
            s=F(0)
            for choice in product(*(range(2) for _ in matching)):
                x=[0]*n
                for edge,idx,opts in zip(matching,choice,options):
                    x[edge[0]],x[edge[1]]=opts[idx]
                s+=val[tuple(x)]*F(1,2**len(matching))
            ev[parity]=s
        assert ev[0]-ev[1]==sum(abs(witnesses[e][1]) for e in matching)*F(1,2)
        assert abs(ev[0]-ev[1])<=2*B
        checked["parity"]+=1

    # Greedy chosen edges, endpoint assignment, second and fourth moments.
    eligible={e for e in edges if weights[e]>0}
    assign={i:[] for i in range(n)}
    c=[F(0)]*n
    while eligible:
        e=max(sorted(eligible),key=lambda pair:weights[pair])
        c[e[0]]=c[e[1]]=weights[e]
        hit={p for p in eligible if set(p)&set(e)}
        for pair in hit:
            vertex=next(k for k in pair if k in e)
            assign[vertex].append(pair)
        eligible-=hit
    assert sum(c)<=8*B
    for i in range(n):
        for pair in assign[i]:assert weights[pair]<=c[i]
        other=[pair[1] if pair[0]==i else pair[0] for pair in assign[i]]
        assert len(set(other))==len(other), (i, assign[i], other)
        s=sum((rows[pair[0]][a]*rows[pair[1]][b]*h2[pair[0],pair[1],a,b]**2
               for pair in assign[i] for a in range(sizes[pair[0]])
               for b in range(sizes[pair[1]])),F(0))
        q=F(0)
        for xs in product(*(range(sizes[j]) for j in other)):
            prob=prod(rows[j][a] for j,a in zip(other,xs))
            norm2=F(0)
            for a in range(sizes[i]):
                z=F(0)
                for pair,b in zip(assign[i],xs):
                    if pair[0]==i:z+=h2[i,pair[1],a,b]
                    else:z+=h2[pair[0],i,b,a]
                norm2+=rows[i][a]*z*z
            q+=prob*norm2**2
        assert s<=I[i]
        assert q<=c[i]**2*s+3*s**2
        checked["Hilbert4"]+=1
    return V,B,M

def main():
    samples=[]
    for n in (2,3,4):
        for trial in range(20 if n<4 else 12):
            sizes=[rng.choice((2,3)) for _ in range(n)]
            V,B,M=finite_model(n,sizes)
            samples.append((n,V,B,M))
    print("PASS independent rational audit:",len(samples),"heterogeneous product models")
    for k,v in checked.items():print("PASS",k,v)
    print("All arithmetic assertions exact using fractions; square roots used nowhere in checks.")
    print("Scope: finite tests only, not a global proof nor a Lean kernel certificate.")

if __name__=="__main__":main()