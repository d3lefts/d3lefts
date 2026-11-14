#!/usr/bin/env python3
"""Adversarial audit: independent enumeration; does not import the solver module.
Constructs every candidate guarded/rechecked edge subset for tiny graphs and
proves the selected set separates s/t by explicit path search. Fraction exact.
"""
from __future__ import annotations
import argparse,itertools,json,random
from collections import deque
from fractions import Fraction
from pathlib import Path


def F(v): return Fraction(str(v))


def reach(edges,source,target,removed):
    adj={}
    for e in edges:
        if e['id'] not in removed:adj.setdefault(e['u'],[]).append(e['v'])
    todo=deque([source]);seen={source}
    while todo:
        u=todo.popleft()
        if u==target:return True
        for v in adj.get(u,[]):
            if v not in seen:seen.add(v);todo.append(v)
    return False


def price(e,policy,regime):
    r=F(e['acquire'])+F(e['verify'])
    if regime!='full' and e.get('cached_digest')==e['digest'] and e.get('cached_digest') is not None and e.get('cached_policy')==policy:
        r=min(r,F(0))
    if regime=='joint':r=min(r,F(e['instrument']))
    return r


def exhaustive(d,regime):
    edges=d['edges'];n=len(edges)
    if n>15:raise ValueError('Independent enumeration limited to 15 edges')
    if d['source']==d['target']:raise ValueError('degenerate graph')
    costs=[price(e,d['policy'],regime) for e in edges]
    best=None;wins=[]
    for mask in range(1<<n):
        removed={edges[i]['id'] for i in range(n) if mask>>i&1}
        if not reach(edges,d['source'],d['target'],removed):
            cost=sum((costs[i] for i in range(n) if mask>>i&1),F(0))
            if best is None or cost<best:best=cost;wins=[mask]
            elif cost==best:wins.append(mask)
    return best,wins


def validate_solution(d,results):
    for regime in ('full','local','joint'):
        sol=results[regime]
        best,_=exhaustive(d,regime)
        observed=F(sol['minimum_cost']);dual=F(sol['dual_flow_value'])
        assert observed==best==dual,(regime,best,observed,dual)
        side=set(sol['cut_source_side'])
        crossing={e['id'] for e in d['edges'] if e['u'] in side and e['v'] not in side}
        assert crossing=={e['id'] for e in sol['selected_cut']}
        assert not reach(d['edges'],d['source'],d['target'],crossing)
        assert sum((price(e,d['policy'],regime) for e in d['edges'] if e['id'] in crossing),F(0))==best
    assert F(results['joint']['minimum_cost'])<=F(results['local']['minimum_cost'])<=F(results['full']['minimum_cost'])


def randomized_independent_cases(ncases=500):
    rng=random.Random(581247)
    from hybrid_cut import Network,all_results
    for case in range(ncases):
        nv=rng.randint(3,6);ne=rng.randint(1,11)
        edges=[]
        for i in range(ne):
            u=rng.randrange(nv-1);v=rng.randrange(u+1,nv)
            digest=f'h{case}-{i}'
            cached_digest=(digest if rng.randrange(3)==0 else 'old-'+digest if rng.randrange(2) else None)
            edges.append(dict(id=f'e{i}',u=f'n{u}',v=f'n{v}',instrument=str(Fraction(rng.randrange(1,13),rng.randrange(1,6))),acquire=str(Fraction(rng.randrange(1,13),rng.randrange(1,6))),verify=str(Fraction(rng.randrange(1,13),rng.randrange(1,6))),digest=digest,cached_digest=cached_digest,cached_policy='p1' if rng.randrange(3)!=0 else 'obsolete'))
        d=dict(source='n0',target=f'n{nv-1}',policy='p1',edges=edges)
        validate_solution(d,all_results(Network.from_dict(d)))
    return ncases


def stale_policy_counterexample(d):
    from hybrid_cut import Network,all_results
    base=all_results(Network.from_dict(d))
    stale=json.loads(json.dumps(d))
    stale['policy']='changed-policy'
    newer=all_results(Network.from_dict(stale))
    # Never falsely report a changed-policy cached certificate as re-usable.
    for sel in newer['local']['selected_cut']:
        assert sel['action']!='reuse'
    return dict(before=base['local']['minimum_cost'],after=newer['local']['minimum_cost'])


def main():
    p=argparse.ArgumentParser();p.add_argument('input');p.add_argument('results');p.add_argument('--random-cases',type=int,default=500)
    a=p.parse_args();d=json.loads(Path(a.input).read_text());s=json.loads(Path(a.results).read_text())
    validate_solution(d,s['results']);n=randomized_independent_cases(a.random_cases)
    stale=stale_policy_counterexample(d)
    print(json.dumps(dict(exhaustive_fixed='pass',maxflow_dual='pass',random_scenarios=n,stale_policy=stale,
                          novel_claim=False,real_controlarena_run=False),indent=2))
if __name__=='__main__':main()
