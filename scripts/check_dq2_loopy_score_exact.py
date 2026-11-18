#!/usr/bin/env python3
"""Independent exact-rational audit of dual conditional scores in zero-field Ising graphs."""
from fractions import Fraction as F
from itertools import combinations
from math import prod

def bit(x,i):
    return 1 if (x>>i)&1 else -1

def audit(n, edges, name):
    states=tuple(range(1<<n))
    raw={x:prod(F(1)+t*bit(x,i)*bit(x,j) for i,j,t in edges) for x in states}
    Z=sum(raw.values())
    p={x:q/Z for x,q in raw.items()}
    assert sum(p.values())==1 and min(p.values())>0
    graph={frozenset((i,j)) for i,j,t in edges if t}
    C=[[sum((p[x]*bit(x,i)*bit(x,j) for x in states),F(0)) for j in range(n)] for i in range(n)]
    S=max(sum(row) for row in C)
    Us={}
    for x in states:
        row=[]
        for i in range(n):
            y=x^(1<<i)
            row.append(bit(x,i)*(p[x]+p[y])/(2*p[x]))
        Us[x]=tuple(row)
    E=lambda f:sum((p[x]*f(x) for x in states),F(0))
    dual=[[E(lambda x,i=i,j=j:bit(x,i)*Us[x][j]) for j in range(n)] for i in range(n)]
    assert all(dual[i][j]==int(i==j) for i in range(n) for j in range(n))
    Ucov=[[E(lambda x,i=i,j=j:Us[x][i]*Us[x][j]) for j in range(n)] for i in range(n)]
    assert all(Ucov[i][j]==0 for i in range(n) for j in range(n) if i!=j and frozenset((i,j)) not in graph)
    Drows=[]
    for i in range(n):
        ts=[t for u,v,t in edges if i in (u,v)]
        P=prod((1+t)/(1-t) for t in ts)
        Di=(P+1)**2/(4*P)+P*sum((t/(1+t)**2 for t in ts),F(0))
        Drows.append(Di)
        assert Ucov[i][i]<=(P+1)**2/(4*P)
        for j in range(n):
            if i==j:continue
            t=next((t for u,v,t in edges if set((u,v))==set((i,j))),F(0))
            assert abs(Ucov[i][j])<=P*t/(1+t)**2,(name,i,j,Ucov[i][j])
        assert sum(abs(Ucov[i][j]) for j in range(n))<=Di
    D=max(Drows)
    for trial in range(15):
        v=[F(((i+3)*7+trial*11)%11-5,7) for i in range(n)]
        norm=sum(x*x for x in v)
        cvar=sum(v[i]*C[i][j]*v[j] for i in range(n) for j in range(n))
        qvar=sum(v[i]*Ucov[i][j]*v[j] for i in range(n) for j in range(n))
        assert norm*norm<=cvar*qvar
        assert qvar<=D*norm
        assert D*cvar>=norm
    print('PASS', name, 'n=', n,'S=', S, 'S<2?', S<2, 'Dscore=',D)

if __name__=='__main__':
    audit(4,[(i,(i+1)%4,F(1,2)) for i in range(4)],'strong square')
    audit(8,[(i,(i+1)%8,F(1,2)) for i in range(8)],'strong 8-cycle')
    audit(6,[(i,(i+1)%6,F(3,5)) for i in range(6)],'strong 6-cycle')
    audit(6,[(i,j,F(1,10)) for i,j in combinations(range(6),2)],'K6')
    audit(6,[(i,j,F(1,9) if (i+j)%2 else F(1,11)) for i,j in [(0,1),(1,2),(2,3),(3,0),(1,4),(4,5),(5,2)]],'nonuniform loopy')
    print('PASS exact dual-score constraints; no S<2 required')
