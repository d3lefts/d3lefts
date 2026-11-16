#!/usr/bin/env python3
"""Independent auditor using transcript partitions, not conflict-pair covers.
Checks every query portfolio against actual all-ballot lookup tables and compares
minimum portfolio costs with semantic_reuse.py. Privacy checked by orbit enumeration.
"""
import itertools
import json
from math import inf
from semantic_reuse import BALLOTS, Q, RULES, TALLY, optimal_cover, eligible_queries


def admissible_group_perms(group):
    if group == 'none':
        return [(0,1,2,3)]
    allperms=list(itertools.permutations((0,1,2,3)))
    if group == 'all': return allperms
    return [p for p in allperms if set(p[:2]) == {0,1}]


def group_safe(fn,group):
    perms=admissible_group_perms(group)
    return all(fn(b) == fn(tuple(b[j] for j in perm)) for perm in perms for b in BALLOTS)


def oracle_cost(rule, group):
    allowed=tuple(k for k,(_,f) in Q.items() if group_safe(f,group))
    good=[]
    for n in range(len(allowed)+1):
        for keys in itertools.combinations(allowed,n):
            signature_results={}
            possible=True
            for ballot in BALLOTS:
                signature=(TALLY(ballot),)+(tuple(Q[key][1](ballot) for key in keys))
                verdict=rule(ballot)
                if signature in signature_results and signature_results[signature]!=verdict:
                    possible=False
                    break
                signature_results[signature]=verdict
            if possible: good.append((sum(Q[key][0] for key in keys),keys))
    return min((c for c,_ in good), default=inf)


def masking_test():
    # Conditional on public tally=1, b is first voter's choice; b in {0,1} equally likely.
    # Private shared randomness r is uniform. Each marginal looks uniform, joint reveals b.
    cases=[(b,r,r,r^b) for b in (0,1) for r in (0,1)]
    for msgindex in (2,3):
        for b in (0,1):
            assert sorted(row[msgindex] for row in cases if row[0]==b)==[0,1]
    assert all((m1^m2)==b for b,r,m1,m2 in cases)
    return len(cases)


def main():
    n=0
    outcomes={}
    for group in ('all','within_groups','none'):
        for name,rule in RULES.items():
            x=oracle_cost(rule,group)
            y,_=optimal_cover(rule,group)
            assert x==y,(group,name,x,y)
            n+=1
            outcomes[f'{group}/{name}'] = None if x==inf else x
        # Cover all 2^5 tally predicates and 2^3 group predicates and all their pairs
        for mask in range(32):
            rule=lambda b,mask=mask: ((mask>>sum(b))&1,)
            assert oracle_cost(rule,group)==optimal_cover(rule,group)[0]
            n+=1
        for mask in range(8):
            rule=lambda b,mask=mask: ((mask>>(b[0]+b[1]))&1,)
            assert oracle_cost(rule,group)==optimal_cover(rule,group)[0]
            n+=1
        for m in range(3):
            for k in range(3):
                rule=lambda b,m=m,k=k:(int(b[0]+b[1]>=m),int(b[0]+b[1]>=k))
                assert oracle_cost(rule,group)==optimal_cover(rule,group)[0]
                n+=1
    assert outcomes['all/revised_count_threshold']==0
    assert outcomes['all/group_A_any'] is None
    assert outcomes['within_groups/group_A_any']==3
    assert outcomes['within_groups/group_A_all']==3
    assert outcomes['within_groups/both_A_actions']==4
    assert outcomes['within_groups/named_voter_0'] is None
    assert outcomes['none/named_voter_0']==2
    assert masking_test()==4
    receipt={'auditor':'independent partition enumeration', 'checked_rule_group_instances':n, 'ballots':len(BALLOTS), 'query_types':len(Q), 'masking_worlds':4, 'outcomes':outcomes, 'status':'PASS', 'limitations':'Finite exact deterministic toy model; not new cryptography, legal opinion, or novelty audit.'}
    print(json.dumps(receipt,indent=2,sort_keys=True))
    with open('semantic_reuse_receipt.json','w') as f:json.dump(receipt,f,indent=2,sort_keys=True)

if __name__=='__main__': main()
