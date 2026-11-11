#!/usr/bin/env python3
"""Exact nested-address nonadaptive budget theorem falsification.
Algebraic optimization and independent finite conditional-table replay.
"""
from fractions import Fraction as Q
from itertools import product,combinations
from collections import defaultdict

def exact_table_gain(m,s,addresses,leaves):
    K=m**s
    assert K<=4
    grouped=defaultdict(lambda:[0,0])
    for addr in product(range(m),repeat=s):
        idx=sum(v*m**(s-i-1) for i,v in enumerate(addr))
        for signs in product((-1,1),repeat=K):
            key=(tuple(addr[i] for i in addresses),tuple(signs[i] for i in leaves))
            row=grouped[key]
            row[0]+=1
            row[1]+=signs[idx]
    N=m**s*2**K
    return sum((Q(a*a,c*N) for c,a in grouped.values()),Q())

def gain(m,s,h,q):
    return Q(q,m**(2*s-h))

def optimal_closed(m,s,c):
    if c==0:return Q(0)
    if c<=s+1:return Q(1,m**(2*s-c+1))
    return Q(min(m**s,c-s),m**s)

count=0
for m in range(2,7):
    for s in range(4):
        K=m**s
        for c in range(s+K+3):
            best=max(gain(m,s,h,min(K,c-h))
                     for h in range(min(s,c)+1))
            assert best==optimal_closed(m,s,c),(m,s,c,best)
            count+=1
table=0
for m,s in [(2,1),(3,1),(2,2)]:
    for h in range(s+1):
        for addresses in combinations(range(s),h):
            for mask in range(1<<(m**s)):
                leaves=[i for i in range(m**s) if mask>>i&1]
                assert exact_table_gain(m,s,addresses,leaves)==gain(m,s,h,len(leaves))
                table+=1
print(f"PASS {count} exact query-budget optima, {table} independent conditional-table checks")
print("Finite checks are not a novelty or universal-theorem certificate.")
