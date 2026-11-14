#!/usr/bin/env python3
"""Exact finite *contract* recertification, not physical-system safety proof.

Trust boundary: boolean authenticated flags are supplied by an EXTERNAL trusted
attestation/checker. A digest comparison checks consistency only, not authenticity.
Costs are abstract integers; risk constraints and real plant physics are NOT solved.
"""
import heapq
import json
import sys
from pathlib import Path


def impacted(data, changes):
    graph = data['change_impact_graph']
    if any(x not in graph for x in changes):
        raise ValueError('unknown change component; refusing old-evidence reuse')
    if any(v not in graph for succ in graph.values() for v in succ):
        raise ValueError('unknown dependency endpoint')
    reached = set(changes)
    queue = list(changes)
    while queue:
        for successor in graph.get(queue.pop(), []):
            if successor not in reached:
                reached.add(successor)
                queue.append(successor)
    return reached


def options_for(e, data, scenario, closure):
    if type(e['new_cost']) is not int or e['new_cost'] < 0 or type(e['reuse_check_cost']) is not int or e['reuse_check_cost'] < 0:
        raise ValueError('costs must be nonnegative integers')
    alternatives = []
    if e['available'] and e['new_authenticated']:
        alternatives.append(('reacquire', e['new_cost']))
    old = e.get('prior')
    if (old is not None and old.get('authenticated') is True
            and old.get('contract_version') == data['contract_version']
            and old.get('digest') == e['digest']
            and type(old.get('valid_through_step')) is int
            and old['valid_through_step'] >= scenario['step']
            and not (set(e['depends_on']) & closure)):
        alternatives.append(('reuse', e['reuse_check_cost']))
    return alternatives


def prepare(data, scenario):
    src = data['evidence']
    ids = [e['id'] for e in src]
    if len(ids) != len(set(ids)):
        raise ValueError('duplicate evidence id')
    if any(not isinstance(e['available'], bool) or not isinstance(e['new_authenticated'], bool) for e in src):
        raise ValueError('availability/authentication flags must be boolean')
    if type(scenario.get('step')) is not int or scenario['step'] < 0:
        raise ValueError('invalid scenario step')
    if any(any(node not in data['change_impact_graph'] for node in e['depends_on']) for e in src):
        raise ValueError('unregistered evidence dependency; refusing reuse')
    if any(not e['digest'] or not isinstance(e['digest'], str) for e in src):
        raise ValueError('digest missing')
    ix = {s:i for i,s in enumerate(ids)}
    obligations = [o for o in data['obligations'] if scenario['mission'] in o['missions']]
    if not obligations:
        raise ValueError('no declared mission obligation')
    if len(set(o['id'] for o in obligations)) != len(obligations):
        raise ValueError('duplicate obligation')
    clauses = []
    for o in obligations:
        alternatives=[]
        for bundle in o['alternatives']:
            if not bundle or any(s not in ix for s in bundle):
                raise ValueError('invalid alternative')
            alternatives.append(sum(1 << ix[s] for s in set(bundle)))
        if not alternatives:
            raise ValueError('unsatisfiable obligation')
        clauses.append(alternatives)
    closure=impacted(data,scenario['changes'])
    choices = [options_for(e,data,scenario,closure) for e in src]
    return ids, obligations, clauses, choices, closure


def covers(mask, clauses):
    return all(any(mask & option == option for option in alternatives) for alternatives in clauses)


def solve(data, scenario):
    ids, obligations, clauses, choices, closure = prepare(data,scenario)
    bestchoice = [min(c, key=lambda x:(x[1], x[0])) if c else None for c in choices]
    # All nonnegative per-source costs; the cheapest valid action per source
    # dominates more expensive actions because bundles require source identity only.
    frontier = [(0,0)]
    best = {0: 0}
    parent = {0: None}
    while frontier:
        cost,mask=heapq.heappop(frontier)
        if cost != best[mask]:
            continue
        if covers(mask,clauses):
            included = [i for i in range(len(ids)) if mask & (1 << i)]
            actions = [{'source':ids[i], 'action':bestchoice[i][0], 'cost':bestchoice[i][1]}
                       for i in included]
            cert = {
                'status':'synthetic_contract_satisfied_not_plant_safety',
                'contract_version': data['contract_version'],
                'scenario': scenario,
                'closure': sorted(closure),
                'obligations': [o['id'] for o in obligations],
                'actions':actions,
                'total_abstract_cost':cost
            }
            if not check(data,scenario,cert):
                raise AssertionError('own certificate checker rejected candidate')
            return cert
        for i,choice in enumerate(bestchoice):
            if choice is None or mask & (1 << i):
                continue
            nxt = mask | (1 << i)
            val = cost+choice[1]
            if val < best.get(nxt, float('inf')):
                best[nxt]=val
                parent[nxt]=mask
                heapq.heappush(frontier,(val,nxt))
    raise ValueError('cannot satisfy mission under declared trust/availability')


def check(data, scenario, certificate):
    """Deterministic replay in the SAME implementation; not independent review."""
    try:
        ids, obligations, clauses, choices, closure = prepare(data,scenario)
        if certificate['status']!='synthetic_contract_satisfied_not_plant_safety':
            return False
        if certificate['contract_version'] != data['contract_version'] or certificate['scenario']!=scenario:
            return False
        if certificate['closure'] != sorted(closure) or certificate['obligations'] != [o['id'] for o in obligations]:
            return False
        items = certificate['actions']
        if len({x['source'] for x in items}) != len(items):
            return False
        if any(x['source'] not in ids for x in items):
            return False
        index = {s:i for i,s in enumerate(ids)}
        if any((x['action'], x['cost']) not in choices[index[x['source']]] for x in items):
            return False
        if sum(x['cost'] for x in items) != certificate['total_abstract_cost']:
            return False
        mask=sum(1 << index[x['source']] for x in items)
        return covers(mask,clauses)
    except (KeyError, TypeError, ValueError):
        return False


if __name__=='__main__':
    path = Path(sys.argv[1]) if len(sys.argv)>1 else Path(__file__).with_name('lifecycle_cases.json')
    data=json.loads(path.read_text())
    print(json.dumps([solve(data,s) for s in data['scenarios']],indent=2))
