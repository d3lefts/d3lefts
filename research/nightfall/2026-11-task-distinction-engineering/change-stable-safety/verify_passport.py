#!/usr/bin/env python3
"""Toy version transport verifier: validates finite structured obligations.
Not a cryptographic verifier and not evidence of real-world hazard coverage.
Usage: python verify_passport.py [--update A] [--new-hazard h4] [--incomplete]
"""
import argparse, itertools, json
from pathlib import Path

p=argparse.ArgumentParser()
p.add_argument('--update',nargs='*',default=[],metavar='MODULE')
p.add_argument('--new-hazard',default=None)
p.add_argument('--incomplete',action='store_true')
args=p.parse_args()
cert=json.loads((Path(__file__).parent/'passport.json').read_text())
hazards=set(cert['hazard_envelope'])
mods=set(cert['mutable_components'])
facts=cert['evidence']
selected=cert['selected_evidence']
k=cert['max_changed_components']
assert set(selected)<=set(facts)
assert len(selected)==len(set(selected))
assert all(set(x['covers'])<=hazards and set(x['deps'])<=mods for x in facts.values())
assert all(x['evidence_cost']>=0 and x['check_cost']>=0 for x in facts.values())

costs={"evidence":sum(facts[i]['evidence_cost'] for i in selected),
       "trusted_checks":sum(facts[i]['check_cost'] for i in selected)}
assert costs==cert['claimed_cost'],costs

def safe(I,T,H):
    still=[i for i in I if not (set(facts[i]['deps'])&T)]
    return H<=set().union(*(set(facts[i]['covers']) for i in still))

def update_subsets(max_k):
    for r in range(max_k+1):
        for c in itertools.combinations(sorted(mods),r):
            yield set(c)

assert all(safe(selected,T,hazards) for T in update_subsets(k))
frontier=[]
names=sorted(facts)
for r in range(len(names)+1):
    for c in itertools.combinations(names,r):
        if all(safe(c,T,hazards) for T in update_subsets(k)):
            pair=(sum(facts[i]['evidence_cost'] for i in c),
                  sum(facts[i]['check_cost'] for i in c))
            frontier.append(pair)
pareto={p for p in frontier if not any(q[0]<=p[0] and q[1]<=p[1] and q!=p for q in frontier)}
assert pareto=={tuple(x) for x in cert['claimed_pareto_costs']},pareto

T=set(args.update)
if not T<=mods:
    print('FAIL-CLOSED: unknown modified component',sorted(T-mods))
    raise SystemExit(2)
if args.incomplete:
    print('FAIL-CLOSED: update completeness not attested')
    raise SystemExit(2)
H=hazards|({args.new_hazard} if args.new_hazard else set())
if not H<=hazards:
    print('FAIL-CLOSED: hazard outside certified envelope', sorted(H-hazards))
    raise SystemExit(2)
accepted=safe(selected,T,H)
print(json.dumps({"version":cert['version_id'],"action":cert['action'],
 "update":sorted(T),"certified_for_update":accepted,
 "scope":"synthetic model only", "costs":costs,
 "pareto_costs":sorted(map(list,pareto))},indent=2))
if not accepted:
    raise SystemExit(1)
