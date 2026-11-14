#!/usr/bin/env python3
"""Finite exact evidence selector (candidate). Python stdlib only.

Does NOT infer safe plant physics. Evidence alternatives are trusted, externally
proved assurance contracts supplied in cases.json, not facts established here.
Costs are abstract nonnegative integer work units.
"""
import heapq
import json
import sys
from pathlib import Path


def solve(data, mission):
    evidence = data['evidence']
    ids = [e['id'] for e in evidence]
    if len(set(ids)) != len(ids):
        raise ValueError('duplicate evidence ID')
    if any(not isinstance(e['cost'], int) or e['cost'] < 0 for e in evidence):
        raise ValueError('invalid cost')
    ix = {key: i for i, key in enumerate(ids)}
    usable = {e['id'] for e in evidence if e['available']}
    obligations = [o for o in data['obligations'] if mission in o['missions']]
    if not obligations:
        raise ValueError('mission has no registered assurance obligations')
    if len({o['id'] for o in obligations}) != len(obligations):
        raise ValueError('duplicate obligation')
    clauses = []
    for o in obligations:
        options = []
        for alternative in o['alternatives']:
            if not alternative or any(x not in ix for x in alternative):
                raise ValueError('invalid assurance alternative')
            if set(alternative) <= usable:
                options.append(sum(1 << ix[x] for x in set(alternative)))
        if not options:
            raise ValueError('mission infeasible under source availability: '+o['id'])
        clauses.append(options)
    def authorized(mask):
        return all(any((mask & clause) == clause for clause in alternatives) for alternatives in clauses)
    avail_indices = [i for i, e in enumerate(evidence) if e['available']]
    full_mask = sum(1 << i for i in avail_indices)
    slice_mask = 0
    for alternatives in clauses:
        for clause in alternatives:
            slice_mask |= clause
    if not authorized(full_mask) or not authorized(slice_mask):
        raise AssertionError('bad baseline construction')
    def price(mask):
        return sum(e['cost'] for i,e in enumerate(evidence) if mask & (1 << i))
    # Dijkstra over source-acquisition states. Handles conjunctive complementarity.
    queue = [(0,0)]
    best = {0:0}
    while queue:
        cost, mask = heapq.heappop(queue)
        if cost != best[mask]:
            continue
        if authorized(mask):
            return {
                'mission': mission,
                'obligations':[o['id'] for o in obligations],
                'optimal_cost':cost,
                'optimal_evidence':[e['id'] for i,e in enumerate(evidence) if mask & (1 << i)],
                'full_cost':price(full_mask),
                'union_of_alternatives_cost':price(slice_mask),
                'disclaimer':'Full and union baselines are toy proxies, not FASE implementations or empirical TEP results.'
            }
        for i in avail_indices:
            nxt = mask | (1 << i)
            nc = cost + (0 if nxt == mask else evidence[i]['cost'])
            if nc < best.get(nxt, float('inf')):
                best[nxt] = nc
                heapq.heappush(queue, (nc,nxt))
    raise ValueError('cannot satisfy mission')


if __name__ == '__main__':
    p = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).with_name('cases.json')
    d = json.loads(p.read_text())
    print(json.dumps([{'scenario':s['id'], **solve(d,s['mission'])} for s in d['scenarios']],indent=2))
