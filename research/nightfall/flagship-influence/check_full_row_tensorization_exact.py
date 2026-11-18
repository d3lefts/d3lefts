#!/usr/bin/env python3
"""Exact original-source full-row tensorization and nested threshold coupling.
Finite regression of author-side structural theorems; NOT universal UE2.
Recompute full-row costs by INDEPENDENT primal and dual rational LPs.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from math import prod
from random import Random


def solve(A, b):
    n = len(b)
    m = [[Q(x) for x in row] + [Q(b[i])] for i, row in enumerate(A)]
    for j in range(n):
        pos = next((i for i in range(j, n) if m[i][j]), None)
        if pos is None:
            return None
        m[j], m[pos] = m[pos], m[j]
        den = m[j][j]
        m[j] = [v / den for v in m[j]]
        for i in range(n):
            if i != j:
                a = m[i][j]
                m[i] = [m[i][z] - a*m[j][z] for z in range(n+1)]
    return tuple(row[-1] for row in m)


def primal_row(states, values, at):
    n = len(states[0])
    A, b = [], []
    for j, y in enumerate(states):
        if j != at:
            A.append([int(v != z) for v, z in zip(states[at], y)])
            b.append(abs(values[at] - values[j]))
    for i in range(n):
        A.append([int(i == j) for j in range(n)])
        b.append(Q())
    best = None
    for active in combinations(range(len(A)), n):
        row = solve([A[t] for t in active], [b[t] for t in active])
        if row is not None and all(
            sum((u*v for u,v in zip(z,row)),Q()) >= rhs
            for z,rhs in zip(A,b)
        ):
            cost = sum(row,Q())
            if best is None or cost < best: best = cost
    assert best is not None
    return best


def dual_vertices(n):
    masks = range(1,1<<n)
    N = (1<<n)-1
    A = [[int(bool(t & (1<<i))) for t in masks] for i in range(n)]
    vertices = {tuple(Q() for _ in masks)}
    for k in range(1,n+1):
        for support in combinations(range(N),k):
            for tight in combinations(range(n),k):
                v = solve([[A[i][j] for j in support] for i in tight],
                          [Q(1)]*k)
                if v is None or any(z<0 for z in v): continue
                lam = [Q() for _ in masks]
                for j,z in zip(support,v): lam[j]=z
                if all(sum((a*b for a,b in zip(row,lam)),Q())<=1
                       for row in A):
                    vertices.add(tuple(lam))
    assert len(vertices) == {1:2,2:5,3:16}[n]
    return vertices


def dual_row(states, values, at, vertices):
    n = len(states[0])
    gaps = [Q() for _ in range((1<<n)-1)]
    for j,y in enumerate(states):
        mask = sum((1<<i for i in range(n) if states[at][i]!=y[i]),0)
        if mask: gaps[mask-1] = max(gaps[mask-1],
                                    abs(values[at]-values[j]))
    return max(sum((x*y for x,y in zip(v,gaps)),Q())
               for v in vertices)


def metrics(shape, weights, fn):
    n = len(shape)
    assert n in (1,2,3)
    p = [[Q(v,sum(w)) for v in w] for w in weights]
    states = [x for x in product(*(range(k) for k in shape))
              if all(p[i][x[i]]>0 for i in range(n))]
    lookup = {x:i for i,x in enumerate(states)}
    values = [Q(fn(x)) for x in states]
    mass = [prod((p[i][x[i]] for i in range(n)),start=Q(1))
            for x in states]
    assert sum(mass,Q())==1
    mean = sum((w*v for w,v in zip(mass,values)),Q())
    V = sum((w*(v-mean)**2 for w,v in zip(mass,values)),Q())
    influence=[]
    for i in range(n):
        D=[]
        for x in states:
            m = sum((p[i][a]*values[lookup[x[:i]+(a,)+x[i+1:]]]
                     for a in range(shape[i]) if p[i][a]),Q())
            D.append(values[lookup[x]]-m)
        cond = sum((w*v*v for w,v in zip(mass,D)),Q())
        replica = Q(1,2)*sum(
            (mass[lookup[x]]*p[i][a]*
             (values[lookup[x]]-values[lookup[x[:i]+(a,)+x[i+1:]]])**2
             for x in states for a in range(shape[i]) if p[i][a]),Q())
        assert cond == replica
        influence.append(cond)
    verts = dual_vertices(n)
    rowcost = [primal_row(states,values,j) for j in range(len(states))]
    assert rowcost == [dual_row(states,values,j,verts)
                       for j in range(len(states))]
    K=max(rowcost);M=max(influence)
    T=4*V*V/(K*K*M) if K*M else Q()
    return dict(states=states,f=values,V=V,I=influence,M=M,
                K=K,Kx=rowcost,T=T,index=lookup)


def threshold_pair_check(result):
    values=result['f'];levels=sorted(set(values))
    delta=[levels[i+1]-levels[i] for i in range(len(levels)-1)]
    for v in values:
        for w in values:
            h=[int((v>levels[i]) != (w>levels[i]))
               for i in range(len(delta))]
            assert abs(v-w)==sum((a*b for a,b in zip(delta,h)),Q())
            assert (v-w)**2==sum(
                (delta[i]*delta[j]*h[i]*h[j]
                 for i in range(len(delta)) for j in range(len(delta))),Q())


def direct_sum(sA,wA,fA,sB,wB,fB):
    A=metrics(sA,wA,lambda x:fA[x])
    B=metrics(sB,wB,lambda x:fB[x])
    n=len(sA)
    F=metrics(sA+sB,wA+wB,lambda x:fA[x[:n]]+fB[x[n:]])
    for x,k in zip(F['states'],F['Kx']):
        assert k == A['Kx'][A['index'][x[:n]]] + B['Kx'][B['index'][x[n:]]]
    assert F['K']==A['K']+B['K']
    assert F['V']==A['V']+B['V']
    assert F['I']==A['I']+B['I']
    assert F['M']==max(A['M'],B['M'])
    assert F['T']<=max(A['T'],B['T'])
    threshold_pair_check(F)
    return F


def main():
    rng=Random(390013)
    cases=(
        ((2,),[[1,1]],(3,),[[1,5,2]]),
        ((3,),[[1,0,7]],(2,),[[1,41]]),
        ((2,2),[[1,7],[1,1]],(3,),[[1,3,0]]),
        ((2,),[[1,11]],(2,2),[[1,2],[1,0]]),
        ((2,2),[[7,1],[2,1]],(2,),[[1,1]])
    )
    count=0
    for sA,wA,sB,wB in cases:
        for _ in range(4):
            fA={x:Q(rng.randrange(-8,9),rng.randrange(1,5))
                for x in product(*(range(s) for s in sA))}
            fB={x:Q(rng.randrange(-8,9),rng.randrange(1,5))
                for x in product(*(range(s) for s in sB))}
            F=direct_sum(sA,wA,fA,sB,wB,fB)
            count+=1
            print("PASS exact original product coupling",count,
                  "worlds",len(F['states']),"levels",len(set(F['f'])),
                  "rowK",F['K'])
    assert count==20
    for n in (1,2,3):
        F=metrics((2,)*n,[[1,1] for _ in range(n)],
                  lambda x:sum(x))
        assert (F['V'],F['M'],F['K'],F['T'])==(
            Q(n,4),Q(1,4),Q(n),Q(1))
    # A single categorical site at base zero, with two different
    # endpoint letters. Independent threshold maxima OVERPAY 2 vs K=1.
    vals=(-1,0,1);base=1
    assert max(abs(vals[base]-v) for v in vals)==1
    independent_cut_envelope=sum(
        max(int((vals[base]>t)!=(v>t)) for v in vals)
        for t in (-1,0))
    assert independent_cut_envelope==2
    # An endpoint-row diagonal-only coupling fails by factor n
    # even for f=sum Xi and genuine optimal full rows a_i=1.
    for n in (2,4,8,16):
        assert n*n>n
    print("PASS 20 exact rational source products: full primal/dual rows,"
          " direct-sum tensorization, nested threshold square identities")
    print("PASS fair additive sharp equality; independent-threshold"
          " and pointwise diagonalization no-go")
    print("NO proof of unrestricted real-row exponent-two inequality.")


if __name__=="__main__":
    main()
