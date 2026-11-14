#!/usr/bin/env python3
"""Independent direct 3-state/source exhaustive checker for finite contracts.

No imports from lifecycle.py for constructing oracle or verifying proof, except
an explicit candidate comparison at end. This is code independence, not peer review.
"""
import copy
import itertools
import json
import random
from pathlib import Path

DATA=json.loads(Path(__file__).with_name('lifecycle_cases.json').read_text())


def independent_opt(data, sc):
    closure=set(sc['changes'])
    queue=list(sc['changes'])
    while queue:
        node=queue.pop(0)
        for dst in data['change_impact_graph'].get(node,[]):
            if dst not in closure:
                closure.add(dst)
                queue.append(dst)
    sources=data['evidence']
    obligations=[o for o in data['obligations'] if sc['mission'] in o['missions']]
    possible=[]
    for e in sources:
        modes=[('skip',0)]
        if e['available'] is True and e['new_authenticated'] is True:
            modes.append(('reacquire',e['new_cost']))
        p=e.get('prior',{})
        if (p.get('authenticated') is True and p.get('contract_version')==data['contract_version']
                and p.get('digest')==e['digest'] and type(p.get('valid_through_step')) is int
                and p['valid_through_step']>=sc['step']
                and not closure.intersection(e['depends_on'])):
            modes.append(('reuse',e['reuse_check_cost']))
        possible.append(modes)
    cheapest=None
    winner=None
    for selection in itertools.product(*possible):
        obtained={e['id'] for e,(mode,_) in zip(sources,selection) if mode!='skip'}
        if not all(any(set(bundle).issubset(obtained) for bundle in ob['alternatives']) for ob in obligations):
            continue
        cost=sum(c for _,c in selection)
        if cheapest is None or cost<cheapest:
            cheapest=cost
            winner=selection
    return cheapest,winner


def independently_check_certificate(data,sc,cert):
    try:
        if cert['scenario']!=sc or cert['contract_version']!=data['contract_version']:
            return False
        found={}
        for item in cert['actions']:
            sid=item['source']
            if sid in found:
                return False
            found[sid]=(item['action'],item['cost'])
        if sum(cost for mode,cost in found.values())!=cert['total_abstract_cost']:
            return False
        allsources={e['id']:e for e in data['evidence']}
        if set(found)-set(allsources):
            return False
        closure=set(sc['changes'])
        todo=list(closure)
        while todo:
            for neighbor in data['change_impact_graph'].get(todo.pop(),[]):
                if neighbor not in closure:
                    closure.add(neighbor)
                    todo.append(neighbor)
        if set(cert['closure'])!=closure:
            return False
        for sid,(mode,cost) in found.items():
            e=allsources[sid]
            if mode=='reacquire':
                if not (e['available'] is True and e['new_authenticated'] is True and cost==e['new_cost']):
                    return False
            elif mode=='reuse':
                p=e.get('prior',{})
                if not (p.get('authenticated') is True and p.get('contract_version')==data['contract_version']
                        and p.get('digest')==e['digest'] and type(p.get('valid_through_step')) is int
                        and p['valid_through_step']>=sc['step'] and not closure.intersection(e['depends_on'])
                        and cost==e['reuse_check_cost']):
                    return False
            else:
                return False
        relevant=[o for o in data['obligations'] if sc['mission'] in o['missions']]
        if cert['obligations']!=[x['id'] for x in relevant]:
            return False
        return all(any(set(bundle).issubset(found) for bundle in o['alternatives']) for o in relevant)
    except (KeyError,TypeError,ValueError):
        return False


from lifecycle import solve,check
rng=random.Random(20261113)
count=0
for scenario in DATA['scenarios']:
    oracle,winner=independent_opt(DATA,scenario)
    result=solve(DATA,scenario)
    assert result['total_abstract_cost']==oracle
    assert independently_check_certificate(DATA,scenario,result)
    assert check(DATA,scenario,result)
    count+=3

# Adversarial metamorphic tests: mutate prior authenticity, digest, freshness, cost,
# availability and change scope. Compare exact cost and independently replay.
for i in range(96):
    test=copy.deepcopy(DATA)
    sc=copy.deepcopy(rng.choice(DATA['scenarios']))
    src=rng.choice(test['evidence'])
    op=rng.choice(['deny_new','deny_old','stale','wrong_epoch','wrong_digest','raise_reuse_cost','change'])
    if op=='deny_new': src['new_authenticated']=False
    elif op=='deny_old': src['prior']['authenticated']=False
    elif op=='stale': src['prior']['valid_through_step']=sc['step']-1
    elif op=='wrong_epoch': src['prior']['contract_version']='stale-epoch'
    elif op=='wrong_digest': src['prior']['digest']='tampered-digest'
    elif op=='raise_reuse_cost': src['reuse_check_cost']=100
    else: sc['changes'].append(rng.choice(['reactor_controller','quality_sensor','valve_controller']))
    expected,_=independent_opt(test,sc)
    try:
        candidate=solve(test,sc)
        assert expected is not None
        assert candidate['total_abstract_cost']==expected
        assert independently_check_certificate(test,sc,candidate)
    except ValueError:
        assert expected is None
    count+=1

# Fail-closed proof object: cost tampering, omitted conjunct, switched mission, fabricated source.
sc=DATA['scenarios'][0]
original=solve(DATA,sc)
for kind in ['cost','drop','mission','fake','mode']:
    cert=copy.deepcopy(original)
    if kind=='cost': cert['total_abstract_cost']+=1
    if kind=='drop': cert['actions'].pop()
    if kind=='mission': cert['scenario']['mission']='quality'
    if kind=='fake': cert['actions'].append({'source':'unknown','action':'reuse','cost':0})
    if kind=='mode': cert['actions'][0]['action']='reuse-invalid'
    assert not independently_check_certificate(DATA,sc,cert)
    count+=1
print(f'Independent finite lifecycle audit passed: {count} assertions (3 base scenarios, 96 mutations, 5 proof corruptions).')
