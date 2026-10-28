#!/usr/bin/env python3
"""Independent exact proof of Sidon h(B)=17 for the frozen 30-point (4,5) set.

Standard library only. Verifies entire 4-point property, gives explicit
Sidon witness, and exhausts every possible 12-point AP transversal by a
sound memoized branching recurrence with a disjoint-triple lower bound.
"""
from functools import lru_cache
from itertools import combinations
from pathlib import Path
import hashlib
import json
import sys

WITNESS_SHA='dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f'
CHOSEN=(0,7091378,7308461,7782977,7797503,7829255,7830227,7835411,
        7836059,7849019,7874975,7884659,8078339,8466237,8610959,11505399,19465109)


def run(witness):
    raw=Path(witness).read_bytes()
    assert hashlib.sha256(raw).hexdigest()==WITNESS_SHA, 'input identity mismatch'
    a=tuple(map(int,raw.strip().split(b',')))
    assert len(a)==30 and a==tuple(sorted(set(a)))
    for q in combinations(a,4):
        assert len({q[j]-q[i] for i in range(4) for j in range(i+1,4)})>=5
    assert set(CHOSEN)<=set(a) and len(CHOSEN)==17
    sums={u+v for i,u in enumerate(CHOSEN) for v in CHOSEN[i:]}
    assert len(sums)==153
    edges=tuple(sum(1<<i for i in t) for t in combinations(range(30),3)
                if a[t[0]]+a[t[2]]==2*a[t[1]])
    assert len(edges)==28
    states=0

    @lru_cache(maxsize=None)
    def impossible(deleted,budget):
        nonlocal states
        states+=1
        uncovered=[e for e in edges if not (e&deleted)]
        if not uncovered:
            return False
        used=0; lower=0
        for e in uncovered:
            if not (e&used):
                lower+=1; used|=e
        if lower>budget:
            return True
        count=[sum(bool(e & (1<<i)) for e in uncovered) for i in range(30)]
        branch=max(uncovered,key=lambda e:sum(count[i] for i in range(30) if e&(1<<i)))
        return all(impossible(deleted | (1<<i),budget-1)
                   for i in range(30) if branch&(1<<i))

    assert impossible(0,12), 'found a Sidon subset of size >=18'
    return {'status':'PASS','size':len(a),'weak_sidon_four_point_tests':27405,
            'three_term_arithmetic_progressions':len(edges),
            'explicit_sidon_subset':len(CHOSEN),'h_B_upper_bound':17,
            'exact_sidon_number':17,'sound_search_states':states,
            'witness_sha256':WITNESS_SHA,
            'method':'independent exact depth-first AP hitting-set proof; no external solver'}

if __name__=='__main__':
    path=Path(sys.argv[1]) if len(sys.argv)==2 else Path(__file__).with_name('witness_30.txt')
    print(json.dumps(run(path),indent=2))
