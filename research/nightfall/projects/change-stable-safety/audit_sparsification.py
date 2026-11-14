"""Finite falsification for the bounded-size evidence sparsification corollary.

Python 3.11+, stdlib only. Uses a separate direct update simulator and
all-subset minimizer, not the structure theorem as its oracle.
"""
from random import Random
from itertools import combinations
from fractions import Fraction as F
from math import comb
from exceptional_dependencies import analyze_modulator, check_branch_certificate

rng=Random(843461)


def updates(n,k):
    for z in range(min(n,k)+1):
        for S in combinations(range(n),z):
            yield set(S)


def brute_robust(rows,n,k):
    return all(any(not T.intersection(row['support']) for row in rows)
               for T in updates(n,k))


def connected_core(parent):
    n=len(parent)
    adj=[set() for _ in range(n)]
    for v,p in enumerate(parent):
        if p is not None:
            adj[v].add(p)
            adj[p].add(v)
    core={rng.randrange(n)}
    for _ in range(rng.randrange(n)):
        frontier=set().union(*(adj[v] for v in core))-core
        if frontier:
            core.add(rng.choice(sorted(frontier)))
    return core


triangle=[
    {'id':0,'support':frozenset({0,2}),'e':F(1)},
    {'id':1,'support':frozenset({1,2}),'e':F(1)},
    {'id':2,'support':frozenset({0,1}),'e':F(1)}
]
assert brute_robust(triangle,3,1)
assert all(not brute_robust(S,3,1) for S in combinations(triangle,2))
tri=analyze_modulator([None,0],triangle,1,1)
assert tri['resilient'] and check_branch_certificate([None,0],triangle,1,1,tri)

count={'robust':0,'bounded_replay':0,'cost_minimum':0}
for _ in range(2400):
    n=rng.randint(1,5)
    s=rng.randint(0,3)
    k=rng.randint(0,min(n+s,3))
    parent=[None]+[rng.randrange(i) for i in range(1,n)]
    rows=[]
    for i in range(rng.randint(1,9)):
        core=connected_core(parent) if rng.randrange(4)>0 else set()
        exc={n+j for j in range(s) if rng.randrange(2)}
        S=core|exc
        if not S:
            S={n+rng.randrange(s)} if s else {rng.randrange(n)}
        rows.append({'id':i,'support':frozenset(S),
                     'e':F(rng.randint(0,9),rng.choice([1,2]))})
    cert=analyze_modulator(parent,rows,s,k)
    if not cert['resilient']:
        continue
    count['robust']+=1
    assert check_branch_certificate(parent,rows,s,k,cert)
    used=set()
    for proof in cert['branch_proofs']:
        if proof['kind']=='outside_exception_witness':
            used.add(proof['witness_id'])
        else:
            used.update(proof['witness_ids'])
    M=sum(comb(s,j)*(k-j+1) for j in range(min(s,k)+1))
    assert len(used)<=M
    reduced=[row for row in rows if row['id'] in used]
    assert brute_robust(reduced,n+s,k)
    count['bounded_replay']+=1
    if len(rows)<=8:
        arbitrary=[]
        restricted=[]
        for j in range(1,len(rows)+1):
            for sub in combinations(rows,j):
                if brute_robust(sub,n+s,k):
                    cost=sum((row['e'] for row in sub),F(0))
                    arbitrary.append(cost)
                    if j<=M:
                        restricted.append(cost)
        assert min(arbitrary)==min(restricted)
        count['cost_minimum']+=1
print(count)
