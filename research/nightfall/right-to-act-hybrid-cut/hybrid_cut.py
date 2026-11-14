#!/usr/bin/env python3
"""NIGHTFALL finite source-valid hybrid assurance cut.

IMPORTANT: abstract atomic effect semantics; NOT a production security monitor.
Costs are nonnegative exact rationals. Each selected cut edge is guarded or
has a CURRENT, independently valid safety certificate. Complete effect graph,
atomic promotion, and sound guarding/certification are explicit assumptions.
"""
from __future__ import annotations
import argparse
import json
from collections import deque
from dataclasses import dataclass
from fractions import Fraction
from pathlib import Path
from typing import Literal


def F(v):
    if isinstance(v, Fraction): return v
    return Fraction(str(v))


def show(x: Fraction) -> str:
    return str(x)


@dataclass(frozen=True)
class Edge:
    id: str
    u: str
    v: str
    instrument: Fraction
    acquire: Fraction
    verify: Fraction
    digest: str
    cached_digest: str | None = None
    cached_policy: str | None = None

    @classmethod
    def from_dict(cls, d):
        return cls(id=str(d['id']), u=str(d['u']), v=str(d['v']),
                   instrument=F(d['instrument']), acquire=F(d['acquire']),
                   verify=F(d['verify']), digest=str(d['digest']),
                   cached_digest=d.get('cached_digest'), cached_policy=d.get('cached_policy'))

    def reusable(self, current_policy: str):
        return (self.cached_digest is not None and self.cached_digest == self.digest
                and self.cached_policy == current_policy)

    def option(self, current_policy: str, regime: Literal['full','local','joint']):
        assert regime in ('full', 'local', 'joint')
        all_options = [('recheck', self.acquire+self.verify)]
        if regime != 'full' and self.reusable(current_policy):
            all_options.append(('reuse', Fraction(0)))
        if regime == 'joint':
            all_options.append(('guard', self.instrument))
        # Reproducible tie policy: reuse, guard, recheck, not mathematically essential.
        priority = {'reuse':0,'guard':1,'recheck':2}
        return min(all_options,key=lambda o:(o[1],priority[o[0]]))


@dataclass(frozen=True)
class Network:
    source: str
    target: str
    policy: str
    edges: tuple[Edge,...]

    @classmethod
    def from_dict(cls,d):
        edges=tuple(Edge.from_dict(e) for e in d['edges'])
        ids=[e.id for e in edges]
        if len(set(ids)) != len(ids): raise ValueError('Duplicate edge IDs')
        if any(e.instrument<0 or e.acquire<0 or e.verify<0 for e in edges):
            raise ValueError('Negative edge costs forbidden')
        if d['source']==d['target']: raise ValueError('Source equals target')
        return cls(str(d['source']),str(d['target']),str(d['policy']),edges)


def _nodes(net):
    return sorted({net.source,net.target}|{e.u for e in net.edges}|{e.v for e in net.edges})


def solve(net:Network, regime:str):
    """Exact rational Edmonds-Karp; independent brute-force verifier is separate."""
    nodes=_nodes(net)
    capacities={e.id:e.option(net.policy,regime)[1] for e in net.edges}
    adj={u:[] for u in nodes}
    # Edge-indexed arcs keep parallel edges independent.
    arcs=[]
    for e in net.edges:
        k=len(arcs)
        arcs.append([e.u,e.v,capacities[e.id],k+1])
        arcs.append([e.v,e.u,F(0),k])
        adj[e.u].append(k);adj[e.v].append(k+1)
    flow=F(0)
    while True:
        seen={net.source:None}
        q=deque([net.source])
        while q and net.target not in seen:
            u=q.popleft()
            for idx in adj[u]:
                v=arcs[idx][1]
                if v not in seen and arcs[idx][2]>0:
                    seen[v]=idx;q.append(v)
        if net.target not in seen:break
        path=[];v=net.target
        while v!=net.source:
            idx=seen[v];path.append(idx);v=arcs[idx][0]
        delta=min(arcs[i][2] for i in path)
        assert delta>0
        for idx in path:
            arcs[idx][2]-=delta
            arcs[arcs[idx][3]][2]+=delta
        flow+=delta
    side={net.source}
    q=deque([net.source])
    while q:
        for i in adj[q.popleft()]:
            if arcs[i][2]>0 and arcs[i][1] not in side:
                side.add(arcs[i][1]);q.append(arcs[i][1])
    cut=[e for e in net.edges if e.u in side and e.v not in side]
    assert net.target not in side
    total=sum((capacities[e.id] for e in cut),F(0))
    assert total==flow
    return {'regime':regime,'minimum_cost':show(total),'dual_flow_value':show(flow),
            'cut_source_side':sorted(side),
            'selected_cut':[{'id':e.id,'u':e.u,'v':e.v,
                             'action':e.option(net.policy,regime)[0],
                             'cost':show(capacities[e.id]),
                             'source_digest':e.digest} for e in cut],
            'source_policy':net.policy,'vertices':len(nodes),'edges':len(net.edges)}


def all_results(net):
    return {reg:solve(net,reg) for reg in ('full','local','joint')}


def main():
    p=argparse.ArgumentParser()
    p.add_argument('input')
    p.add_argument('--output')
    args=p.parse_args()
    d=json.loads(Path(args.input).read_text())
    net=Network.from_dict(d)
    result={'model':d['name'],'assumptions':d.get('assumptions',[]),'results':all_results(net)}
    s=json.dumps(result,indent=2,sort_keys=True)+'\n'
    if args.output:Path(args.output).write_text(s)
    print(s)

if __name__=='__main__':main()
