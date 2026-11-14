"""Independent finite enumeration of the authored tree and exception-set results.

Run: python3 audit.py
All arithmetic for costs and bounds uses fractions.Fraction.
No source trust, cryptographic authentication, or real safety claim is tested.
"""
from itertools import combinations
from fractions import Fraction as F
from random import Random
from tree_certificate import (
    optimal_certificate, subtree_packing_greedy, worst_margin_tree,
    witness_after_update)
from exceptional_dependencies import (
    analyze_modulator, check_branch_certificate)

R = Random(20261113)


def all_updates(n, k):
    for z in range(min(n,k)+1):
        for U in combinations(range(n),z):
            yield set(U)


def random_tree(n):
    return [None]+[R.randrange(v) for v in range(1,n)]


def random_core(parent):
    n = len(parent)
    adj = [set() for _ in range(n)]
    for v,p in enumerate(parent):
        if p is not None:
            adj[v].add(p)
            adj[p].add(v)
    core = {R.randrange(n)}
    for _ in range(R.randrange(n)):
        choices = set().union(*(adj[v] for v in core))-core
        if choices:
            core.add(R.choice(sorted(choices)))
    return frozenset(core)


def brute_margin(rows, n, k):
    if not rows:
        return None
    return min(max(row['b']-(row['delta'] if U.intersection(row['support']) else 0)
                   for row in rows) for U in all_updates(n,k))


def brute_opt(rows,n,k,gamma,cap):
    eligible = [r for r in rows if r['t']<=cap]
    best = None
    for z in range(1,len(eligible)+1):
        for subset in combinations(eligible,z):
            if all(any(row['b']-(row['delta'] if U.intersection(row['support']) else 0)
                       >= gamma for row in subset)
                   for U in all_updates(n,k)):
                cost = sum((row['e'] for row in subset),F(0))
                if best is None or cost<best:
                    best=cost
    return best


def brute_packing(rows):
    result=0
    for z in range(len(rows)+1):
        for subset in combinations(rows,z):
            sites=set()
            for row in subset:
                if sites.intersection(row['support']):
                    break
                sites.update(row['support'])
            else:
                result=max(result,z)
    return result


def brute_piercing(rows,n):
    if not rows:
        return 0
    for z in range(n+1):
        for H in combinations(range(n),z):
            if all(set(H).intersection(r['support']) for r in rows):
                return z
    raise AssertionError


counts = {'tree_margin':0,'tree_packing_dual':0,'tree_cost':0,'exceptions':0}
for trial in range(3500):
    n=R.randint(1,7); parent=random_tree(n)
    rows=[]
    for i in range(R.randint(0,8)):
        rows.append({'id':i,'support':random_core(parent),
                     'b':F(R.randint(-2,8),R.choice([1,2,3])),
                     'delta':F(R.randint(0,8),R.choice([1,2,3])),
                     'e':F(R.randint(0,15),R.choice([1,2,3])),
                     't':F(R.randint(0,6))})
    k=R.randint(0,min(n,3))
    b=brute_margin(rows,n,k)
    assert worst_margin_tree(parent,rows,k)==b
    counts['tree_margin']+=1
    pack,hit=subtree_packing_greedy(parent,rows)
    assert len(pack)==len(hit)==brute_packing(rows)==brute_piercing(rows,n)
    counts['tree_packing_dual']+=1
    if trial % 2 == 0:
        gamma=F(R.randint(1,4),R.choice([1,2]))
        cap=F(R.randint(0,6))
        cost,ids=optimal_certificate(parent,rows,k,gamma,cap)
        assert cost==brute_opt(rows,n,k,gamma,cap)
        if cost is not None:
            selected=[r for r in rows if r['id'] in ids]
            assert sum((r['e'] for r in selected),F(0))==cost
            for U in all_updates(n,k):
                assert witness_after_update(selected,U,gamma)[0] is not None
        counts['tree_cost']+=1

for trial in range(3500):
    n=R.randint(1,7); s=R.randint(0,3)
    parent=random_tree(n); rows=[]
    for i in range(R.randint(1,9)):
        core=set() if R.randrange(4)==0 else set(random_core(parent))
        extra={n+j for j in range(s) if R.randrange(2)==0}
        support=core|extra
        if not support:
            support={n+R.randrange(s)} if s else {R.randrange(n)}
        rows.append({'id':i,'support':frozenset(support)})
    k=R.randint(0,min(n+s,4))
    cert=analyze_modulator(parent,rows,s,k)
    robust=not any(all(U.intersection(r['support']) for r in rows)
                   for U in all_updates(n+s,k))
    assert cert['resilient']==robust
    assert check_branch_certificate(parent,rows,s,k,cert)
    counts['exceptions']+=1

print(counts)
