#!/usr/bin/env python3
"""Independent finite checker: direct power-set enumeration; no solver imports."""
import itertools
import json
from pathlib import Path

D = json.loads(Path(__file__).with_name('cases.json').read_text())
from solver import solve  # comparison only; checker builds its own feasibility predicate

def oracle(mission, data):
    sources = data['evidence']
    obligations = [o for o in data['obligations'] if mission in o['missions']]
    allowed = [s for s in sources if s['available']]
    opts = []
    for size in range(len(allowed)+1):
        for combo in itertools.combinations(allowed, size):
            names = {s['id'] for s in combo}
            if all(any(set(group).issubset(names) for group in ob['alternatives']) for ob in obligations):
                opts.append((sum(s['cost'] for s in combo), frozenset(names)))
    return min(opts, key=lambda v:(v[0],sorted(v[1]))) if opts else None

checks = 0
for s in D['scenarios']:
    exact = oracle(s['mission'], D)
    candidate = solve(D,s['mission'])
    assert exact is not None and candidate['optimal_cost'] == exact[0]
    assert candidate['optimal_cost'] <= candidate['union_of_alternatives_cost'] <= candidate['full_cost']
    checks += 3
# One-source impossibility of conjunctions: evidence must be complete, not just one signal.
for evidence in D['evidence']:
    modified = json.loads(json.dumps(D))
    for e in modified['evidence']:
        if e['id'] == evidence['id']:
            e['available'] = False
    for scenario in D['scenarios']:
        truth = oracle(scenario['mission'],modified)
        try:
            out = solve(modified,scenario['mission'])
            assert truth is not None and out['optimal_cost'] == truth[0]
        except ValueError:
            assert truth is None
        checks += 1
# A source unavailable for authentication must make both missions infeasible.
modified = json.loads(json.dumps(D))
next(e for e in modified['evidence'] if e['id']=='attest')['available'] = False
assert all(oracle(s['mission'],modified) is None for s in D['scenarios'])
checks += 1
print(f'Independent exhaustive finite audit passed: {checks} checks; {len(D["evidence"])} evidence sources, {len(D["scenarios"])} missions.')
