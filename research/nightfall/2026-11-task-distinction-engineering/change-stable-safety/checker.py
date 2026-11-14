#!/usr/bin/env python3
"""Finite audit for version-stable safety certificate theorem.

Independently checks two equivalent formulations:
 (A) simulate every allowed update and every hazardous witness;
 (B) enumerate minimum transversals of dependency supports.
This is a finite test, not a proof of the general theorem.
No external dependencies. Python 3.11+.
"""
import itertools
import json
import random
from fractions import Fraction
from pathlib import Path
from hashlib import sha256


def subsets(xs):
    xs = tuple(xs)
    return [frozenset(c) for k in range(len(xs) + 1)
            for c in itertools.combinations(xs, k)]


def robust_direct(chosen, facts, hazards, modules, k):
    for edit in subsets(modules):
        if len(edit) > k:
            continue
        surviving = [i for i in chosen if not (facts[i]['deps'] & edit)]
        for h in hazards:
            if not any(h in facts[i]['covers'] for i in surviving):
                return False
    return True


def hitting_number(chosen, facts, hazard, modules):
    rel = [facts[i]['deps'] for i in chosen if hazard in facts[i]['covers']]
    if not rel:
        return 0
    for edit in sorted(subsets(modules), key=lambda t: (len(t), sorted(t))):
        if all(edit & dep for dep in rel):
            return len(edit)
    return float('inf')


def robust_transversal(chosen, facts, hazards, modules, k):
    return all(hitting_number(chosen, facts, h, modules) > k for h in hazards)


def pareto(facts, hazards, modules, k):
    possible=[]
    for I in subsets(facts):
        if robust_direct(I, facts, hazards, modules, k):
            e=sum((facts[i]['e'] for i in I), Fraction(0))
            v=sum((facts[i]['v'] for i in I), Fraction(0))
            possible.append((e,v,sorted(I)))
    frontier=[(e,v,I) for e,v,I in possible if not any(
        ee<=e and vv<=v and (ee<e or vv<v)
        for ee,vv,_ in possible)]
    return sorted(frontier, key=lambda p:(p[0],p[1],p[2]))


example={
    'd_A': {'covers':{'h1','h2','h3'},'deps':{'A'},'e':1,'v':1},
    'd2_A':{'covers':{'h1','h2','h3'},'deps':{'A'},'e':1,'v':1},
    'b_B': {'covers':{'h2','h3'},'deps':{'B'},'e':1,'v':4},
    'c_C': {'covers':{'h1','h3'},'deps':{'C'},'e':3,'v':1},
    'b2_B':{'covers':{'h2','h3'},'deps':{'B'},'e':3,'v':1}
}
hazards=['h1','h2','h3']
modules=['A','B','C']
F=pareto(example,hazards,modules,1)
assert {(int(e),int(v)) for e,v,_ in F}=={(5,6),(7,3)},F
assert not robust_direct({'d_A','d2_A'},example,hazards,modules,1)
assert robust_direct({'d_A','b_B','c_C'},example,hazards,modules,1)
assert robust_direct({'d_A','b2_B','c_C'},example,hazards,modules,1)

triangle={
    'ab':{'covers':{'hazard'},'deps':{'a','b'},'e':1,'v':1},
    'bc':{'covers':{'hazard'},'deps':{'b','c'},'e':1,'v':1},
    'ac':{'covers':{'hazard'},'deps':{'a','c'},'e':1,'v':1},
    'd': {'covers':{'hazard'},'deps':{'d'},'e':20,'v':1},
}
assert hitting_number({'ab','bc','ac'},triangle,'hazard',['a','b','c','d'])==2
assert robust_direct({'ab','bc','ac'},triangle,['hazard'],['a','b','c','d'],1)
assert not robust_direct({'ab','bc','ac'},triangle,['hazard'],['a','b','c','d'],2)
assert all(triangle[x]['deps'] & triangle[y]['deps'] for x,y in itertools.combinations(('ab','bc','ac'),2))
assert robust_direct({'ab','d'},triangle,['hazard'],['a','b','c','d'],1)

rng=random.Random(20261113)
ncases=0
for trial in range(400):
    M=[f'm{j}' for j in range(rng.randint(1,5))]
    H=[f'h{j}' for j in range(rng.randint(1,4))]
    fs={}
    for j in range(rng.randint(1,7)):
        fs[f'f{j}']={
            'covers':set(h for h in H if rng.getrandbits(1)),
            'deps':set(m for m in M if rng.getrandbits(1)),
            'e':Fraction(rng.randint(1,9)),
            'v':Fraction(rng.randint(1,9))}
    for chosen in subsets(fs):
        for k in range(len(M)+1):
            a=robust_direct(chosen,fs,H,M,k)
            b=robust_transversal(chosen,fs,H,M,k)
            assert a==b,{'trial':trial,'I':sorted(chosen),'k':k,'direct':a,'transversal':b}
            ncases+=1

result={
  'audit':'finite exhaustive-update vs independent transversal identity',
  'random_seed':20261113,
  'random_instances':400,
  'parameterized_subset_cases':ncases,
  'sample_pareto':[{'trusted_evidence':str(e),'trusted_atom_checks':str(v),'facts':I} for e,v,I in F],
  'triangle_edit_resilience':2,
  'triangle_disjoint_support_pairs':0,
  'limitations':'Finite randomized audit only. Trust assumptions and complete dependency declarations are not empirically validated.'
}
base=Path(__file__).parent
(base/'audit_results.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(result,indent=2))
