"""Exact constructive recertification for endpoint-complementarity evidence graphs.
Public domain mathematical prototype; Fraction costs and posterior risk.
"""
from __future__ import annotations
from fractions import Fraction as F
from itertools import combinations
from collections import deque


def edges_canonical(edges):
    out=[]
    for (u,v,c) in edges:
        assert isinstance(u,int) and isinstance(v,int) and u!=v
        assert c>=0
        out.append((min(u,v),max(u,v),F(c)))
    assert len({(u,v) for u,v,_ in out})==len(out)
    return tuple(out)

def risk_k(r:int, delta:F, m:int):
    assert r>=2 and F(0)<=delta<F(1)
    k=0
    for t in range(1,m+1):
        if F(1)-F(1,r**t)<=delta:
            k=t
        else:break
    return k

def maximum_closure_mincut(n,edges,weights,cached=()):
    """Minimum certificate cost for zero-risk on supplied edges.
    s->edge cap d_e, edge->endpoint cap huge, vertex->t cap w_v.
    Free cached vertices are automatically readable; return selected vertices.
    """
    edges=edges_canonical(edges)
    assert all(0<=u<n and 0<=v<n for u,v,_ in edges)
    assert len(weights)==n and all(F(w)>=0 for w in weights)
    cached=set(cached)
    assert all(0<=v<n for v in cached)
    # Select cached at zero additional cost, not forced; same optimum.
    w=[F(0) if v in cached else F(weights[v]) for v in range(n)]
    m=len(edges); source=n+m; sink=source+1; N=sink+1
    big=1+sum(w)+sum(e[2] for e in edges)
    capacity=[[F(0) for _ in range(N)] for _ in range(N)]
    original=[[F(0) for _ in range(N)] for _ in range(N)]
    def arc(a,b,c):
        capacity[a][b]+=c
        original[a][b]+=c
    for i,wi in enumerate(w):arc(i,sink,wi)
    for i,(u,v,d) in enumerate(edges):
        e=n+i;arc(source,e,d);arc(e,u,big);arc(e,v,big)
    flow=F(0)
    while True:
        parent={source:None};q=deque([source])
        while q and sink not in parent:
            u=q.popleft()
            for v in range(N):
                if v not in parent and capacity[u][v]>0:
                    parent[v]=u;q.append(v)
        if sink not in parent:break
        path=[];v=sink
        while v!=source:
            u=parent[v];path.append((u,v));v=u
        amount=min(capacity[u][v] for u,v in path)
        for u,v in path:
            capacity[u][v]-=amount;capacity[v][u]+=amount
        flow+=amount
    reachable={source};q=deque([source])
    while q:
        u=q.popleft()
        for v in range(N):
            if v not in reachable and capacity[u][v]>0:
                reachable.add(v);q.append(v)
    S=frozenset(v for v in range(n) if v in reachable)
    # if cached are absent, add them as their reads are available for free.
    S=S|cached
    direct=frozenset(i for i,(u,v,d) in enumerate(edges) if not(u in S and v in S))
    cost=sum(w[v] for v in S)+sum(edges[i][2] for i in direct)
    assert cost==flow,(cost,flow)
    flows=tuple((u,v,original[u][v],original[u][v]-capacity[u][v])
                for u in range(N) for v in range(N) if original[u][v])
    assert all(F(0)<=f<=cap for u,v,cap,f in flows)
    return {"cost":cost,"vertices":tuple(sorted(S)),"direct":tuple(sorted(direct)),
            "maxflow":flow,"mincut":flow,"residual_reachable":tuple(sorted(reachable)),
            "big":big,"flow_arcs":flows,"source":source,"sink":sink,"n_nodes":N}

def exact_risk_optimum(n,edges,weights,cached=(),r=2,delta=F(0)):
    """Enumerate ≤k omitted edge tests and solve a fresh exact minimum cut for each.
    Complexity O(sum_j<=k binom(m,j) * poly(n+m)), fixed parameter k.
    """
    edges=edges_canonical(edges);k=risk_k(r,F(delta),len(edges))
    best=None
    for num in range(k+1):
        for leave in combinations(range(len(edges)),num):
            omitted=frozenset(leave)
            kept=[edge for i,edge in enumerate(edges) if i not in omitted]
            result=maximum_closure_mincut(n,kept,weights,cached)
            S=set(result['vertices'])
            direct=tuple(i for i,(u,v,d) in enumerate(edges)
                         if i not in omitted and not(u in S and v in S))
            uncovered=tuple(i for i,(u,v,d) in enumerate(edges)
                          if i not in direct and not(u in S and v in S))
            assert len(uncovered)<=k
            cost=result['cost']
            candidate=(cost,len(uncovered),len(S),tuple(sorted(S)),direct,uncovered)
            if best is None or candidate<best[0]:best=(candidate,result,tuple(sorted(omitted)))
    (cost,_,_,S,D,U),r0,skips=best
    return {"cost":cost,"vertices":S,"direct":D,"uncovered":U,"uncovered_count":len(U),
            "risk":F(1)-F(1,r**len(U)),"k":k,
            "cut_cost":r0['cost'],"maxflow_dual":r0['maxflow'],
            "closure_certificate":r0,"enumerated_skips":skips}

def brute_risk_optimum(n,edges,weights,cached=(),r=2,delta=F(0)):
    """Independent oracle; enumerate selected vertices and compute top-k edge omission."""
    edges=edges_canonical(edges);k=risk_k(r,F(delta),len(edges))
    cached=set(cached);best=None
    for mask in range(1<<n):
        S={v for v in range(n) if (mask>>v)&1}|cached
        missing=[i for i,(u,v,d) in enumerate(edges) if not({u,v}<=S)]
        # Optimal skip spends risk budget on the most expensive missing direct tests.
        skip=set(sorted(missing,key=lambda i:(-edges[i][2],i))[:k])
        D=set(missing)-skip
        cost=sum(F(weights[v]) for v in S-cached)+sum(edges[i][2] for i in D)
        if best is None or cost<best:best=cost
    return best
