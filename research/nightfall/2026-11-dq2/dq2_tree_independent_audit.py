#!/usr/bin/env python3
"""Exact tree geodesic/covariance audit, separate graph code path.
Finite computational tests only; all-size claims require a mathematical proof.
"""
from collections import defaultdict, deque
from fractions import Fraction as F
from itertools import combinations
import json


def paths(n, edges):
    adj={i:[] for i in range(n)}
    for u,v in edges:
        adj[u].append(v);adj[v].append(u)
    def route(a,b):
        prev={a:None}; queue=deque([a])
        while queue and b not in prev:
            x=queue.popleft()
            for y in adj[x]:
                if y not in prev:
                    prev[y]=x;queue.append(y)
        if b not in prev: raise RuntimeError('disconnected')
        out=[]; x=b
        while prev[x] is not None:
            p=prev[x];out.append(tuple(sorted((p,x))));x=p
        return frozenset(out)
    return {(a,b):route(a,b) for a,b in combinations(range(n),2)},adj


def audit(n,edges,q):
    P,adj=paths(n,edges)
    d=max(map(len,adj.values()))
    if d<2: d=2
    assert (d-1)*q<1
    S=1+d*q/(1-(d-1)*q)
    for (a,b),A in P.items():
        for (u,v),B in P.items():
            common=A&B
            if not common: continue
            symdiff=len(A^B)
            # Use unique path lookup, independent of bond covariance calculations.
            dist=lambda x,y: 0 if x==y else len(P[tuple(sorted((x,y)))])
            ways=[dist(a,u)+dist(b,v),dist(a,v)+dist(b,u)]
            assert symdiff in ways,(a,b,u,v,symdiff,ways)
            assert ways.count(symdiff)==1,(a,b,u,v,ways)
    C={}
    for A,pa in P.items():
        C[A]={}
        for B,pb in P.items():
            overlap=len(pa&pb)
            value=q**len(pa^pb)*(1-q**(2*overlap))
            C[A][B]=value
    mx=max(sum(abs(x) for x in row.values()) for row in C.values())
    assert mx<=S*S,(n,edges,mx,S*S)
    return {'n':n,'max_degree':max(map(len,adj.values())),'rho':str(q),'max_interval_covariance_row':str(mx),'bound':str(S*S), 'pairs':len(P)}


def run():
    trees=[('chain8',8,[(i,i+1) for i in range(7)]),
           ('binary7',7,[(0,1),(0,2),(1,3),(1,4),(2,5),(2,6)]),
           ('fork8',8,[(0,1),(1,2),(1,3),(3,4),(4,5),(4,6),(6,7)]),
           ('star7',7,[(0,i) for i in range(1,7)])]
    result=[]
    for label,n,edges in trees:
        for q in (F(1,10),F(1,6)):
            z=audit(n,edges,q);z['graph']=label;result.append(z)
    return {'status':'PASS','graphs':len(trees),'parameterized_checks':len(result),'results':result,
            'scope':'geodesic identities and covariance-row checks for named finite trees, not a formal proof'}

if __name__=='__main__':
    print(json.dumps(run(),indent=2))
