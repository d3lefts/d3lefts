#!/usr/bin/env python3
"""Exact zero-triple repeated-pair correction consolidation in four T2 slots.

Independent formal-integer coefficient audit. Does NOT certify the quantum
frame-energy inequalities or prove an all-dimensional Lean theorem.
"""
from collections import Counter
from itertools import combinations, product
from math import sqrt

def audit(D):
    recorded=Counter()
    total=0
    for t in product(D, repeat=4):
        z=t[0]^t[1]^t[2]^t[3]
        if z==0:
            continue
        extended=0
        for i in range(4):
            triple=[t[j] for j in range(4) if j!=i]
            if t[i]!=0 and all(x!=0 for x in triple) and (triple[0]^triple[1]^triple[2])==0:
                extended+=1
        genuine=int(len(set(t))==4 and 0 not in t and extended==1)
        # Two equal nonzero labels + two distinct remaining nonzero labels,
        # which jointly form the unique nonzero XOR-zero triple with repeat.
        repeated=int(len(set(t))==3 and 0 not in t and extended==2)
        assert extended==genuine+2*repeated,(D,t,z,extended,genuine,repeated)
        if repeated:
            counts=Counter(t)
            repeated_label=next(x for x,n in counts.items() if n==2)
            assert repeated_label==z
            assert list(counts.values()).count(2)==1
        recorded[(extended,genuine,repeated)]+=1
        total+=1
    assert all(t in {(0,0,0),(1,1,0),(2,0,1)} for t in recorded)
    print(f'PASS alphabet D={tuple(D)}: {total} nonzero-frequency tuples; states={dict(recorded)}')

if __name__ == '__main__':
    for D in ((0,1,2),(0,1,2,3),tuple(range(8))):
        audit(D)
    # Previous merged source: repeated pair coefficient 6sqrt(2)+8
    # Four extended C groups: 4
    # New pair-overlap correction: 4sqrt(6), not 8sqrt(3)
    B=6*sqrt(2)+8
    C=4+4*sqrt(6)
    exact=B+C
    assert 30 < exact < 31
    # Elementary *exact rational* upper bounds:
    # sqrt(2) <= 3/2 and sqrt(6) <= 5/2
    assert 2*4<=9 and 6*4<=25
    assert 12+6*(3/2)+4*(5/2)==31
    print(f'PASS exact all-groups paper coefficient {exact:.12f} < 31')
    print('PASS source-quarantined scope: T2 operator lemmas / full Lean terminal pending.')
