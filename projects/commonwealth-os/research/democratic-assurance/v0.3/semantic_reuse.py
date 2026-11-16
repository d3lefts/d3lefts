#!/usr/bin/env python3
"""Finite exact conflict-cover implementation of DAP-CR1/CR2.
Not a cryptographic election or legal validity checker. Python 3 standard library.
"""
from itertools import combinations, permutations
from math import inf

BALLOTS = tuple((a,b,c,d) for a in (0,1) for b in (0,1) for c in (0,1) for d in (0,1))
TALLY = lambda b: sum(b)
Q = {
    'a_any': (3, lambda b: int(b[0]+b[1]>=1)),
    'a_all': (3, lambda b: int(b[0]+b[1]==2)),
    'a_count': (4, lambda b: b[0]+b[1]),
    'b_count': (4, lambda b: b[2]+b[3]),
    'individual_0': (2, lambda b: b[0]),
    'individual_1': (2, lambda b: b[1]),
}

def perms(kind):
    if kind=='all': return list(permutations(range(4)))
    if kind=='within_groups': return [(x[0],x[1],y[0],y[1]) for x in permutations((0,1)) for y in permutations((2,3))]
    if kind=='none': return [tuple(range(4))]
    raise ValueError(kind)

def swap_invariant(f, group):
    return all(f(tuple(b[p[i]] for i in range(4)))==f(b) for b in BALLOTS for p in perms(group))

def eligible_queries(group):
    return {name: (cost, f) for name,(cost,f) in Q.items() if swap_invariant(f,group)}

def conflicts(rule):
    return [(a,b) for a,b in combinations(BALLOTS,2) if TALLY(a)==TALLY(b) and rule(a)!=rule(b)]

def optimal_cover(rule, group):
    elig=eligible_queries(group)
    items=list(elig)
    pairs=conflicts(rule)
    if not pairs: return (0,())
    best=(inf,())
    for r in range(len(items)+1):
        for subset in combinations(items,r):
            if all(any(elig[name][1](a)!=elig[name][1](b) for name in subset) for a,b in pairs):
                score=sum(elig[name][0] for name in subset)
                if score < best[0] or (score==best[0] and subset<best[1]):
                    best=(score,subset)
    return best

RULES = {
    'revised_count_threshold': lambda b: (int(sum(b)>=3),),
    'group_A_any': lambda b: (int(b[0]+b[1]>=1),),
    'group_A_all': lambda b: (int(b[0]+b[1]==2),),
    'both_A_actions': lambda b: (int(b[0]+b[1]>=1),int(b[0]+b[1]==2)),
    'named_voter_0': lambda b: (b[0],),
    'parity': lambda b: (sum(b)%2,),
}

if __name__=='__main__':
    import json
    for group in ('all','within_groups','none'):
        print(group, json.dumps({name: {'min_extra_cost': (c if c!=inf else None), 'queries': s} for name,rule in RULES.items() for c,s in [optimal_cover(rule,group)]},sort_keys=True))
