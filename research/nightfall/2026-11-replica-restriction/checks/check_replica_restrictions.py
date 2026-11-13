#!/usr/bin/env python3
"""Exact Fraction enumeration of the weighted-replica spectrum/influence identities.
Independent of the sharpness checker; no third-party packages.
"""
from fractions import Fraction as Q
from itertools import product
from math import prod

def subsets(n):
    return [tuple(i for i in range(n) if mask & (1 << i)) for mask in range(1, 1 << n)]

def expectation(vals, probabilities):
    return sum((vals[k] * probabilities[k] for k in vals), Q(0))

def case(alphabets, source, selectors, f):
    n = len(alphabets)
    words = list(product(*alphabets))
    src_weights = {x: prod(source[i][alphabets[i].index(x[i])] for i in range(n)) for x in words}
    mean = expectation(f, src_weights)
    energies = {}
    for S in subsets(n):
        # Condition by marginalization, including zero-probability source atoms.
        def conditional(x, T):
            return sum(f[y] * prod(source[j][alphabets[j].index(y[j])] for j in range(n) if j not in T)
                       for y in words if all(y[j] == x[j] for j in T))
        h = {x: sum(((-1)**(len(S)-len(T))) * conditional(x, T)
                    for mask in range(1 << len(S))
                    for T in [tuple(S[a] for a in range(len(S)) if mask & (1 << a))])
             for x in words}
        energies[S] = sum(src_weights[x] * h[x]**2 for x in words)
    variance = sum(src_weights[x] * (f[x] - mean)**2 for x in words)
    assert sum(energies.values(), Q(0)) == variance
    orig_inf = []
    for i in range(n):
        s = Q(0)
        for x in words:
            for b,p in zip(alphabets[i], source[i]):
                y = list(x); y[i] = b
                s += src_weights[x] * p * (f[x]-f[tuple(y)])**2 / Q(2)
        assert s == sum((v for S,v in energies.items() if i in S), Q(0))
        orig_inf.append(s)
    counts = [len(pi) for pi in selectors]
    indices = list(product(*[range(k) for k in counts]))
    sel_weights = {u:prod(selectors[i][u[i]] for i in range(n)) for u in indices}
    lambdas = [sum((p*p for p in pi), Q(0)) for pi in selectors]
    target_var = sum((Q(1)-prod(lambdas[i] for i in S))*v for S,v in energies.items())
    target_inf = [(Q(1)-lambdas[i])*orig_inf[i] for i in range(n)]
    arrays = [list(product(A,repeat=k)) for A,k in zip(alphabets,counts)]
    actual_var = Q(0); actual_inf = [Q(0)]*n; cases=0
    for samples in product(*arrays):
        weight = prod(prod(source[i][alphabets[i].index(v)] for v in samples[i]) for i in range(n))
        if not weight: continue
        g = {u:f[tuple(samples[i][u[i]] for i in range(n))] for u in indices}
        gbar = expectation(g,sel_weights)
        actual_var += weight*sum(sel_weights[u]*(g[u]-gbar)**2 for u in indices)
        for i in range(n):
            influence = Q(0)
            for u in indices:
                for j,p in enumerate(selectors[i]):
                    v = list(u);v[i]=j
                    influence += sel_weights[u]*p*(g[u]-g[tuple(v)])**2/Q(2)
            actual_inf[i] += weight*influence
        cases += 1
    assert actual_var == target_var,(actual_var,target_var)
    assert actual_inf == target_inf,(actual_inf,target_inf)
    return cases,target_var,target_inf,lambdas

def main():
    configurations = [
       ([[0,1],[0,1]],[[Q(1,3),Q(2,3)],[Q(2,5),Q(3,5)]],
        [[Q(1,2),Q(1,2)],[Q(1,4),Q(3,4)]],
        lambda x:Q(3)*x[0]-Q(2)*x[1]+Q(5)*x[0]*x[1]),
       ([[0,1]]*3,[[Q(1,2),Q(1,2)] for _ in range(3)],
        [[Q(1,2),Q(1,2)] for _ in range(3)],
        lambda x:Q(2)*x[0]+Q(3)*x[0]*x[1]-Q(5)*x[1]*x[2]+Q(7)*x[0]*x[1]*x[2]),
       ([[0,1,2],[0,1]],[[Q(1,2),Q(1,2),Q(0)],[Q(1,3),Q(2,3)]],
        [[Q(1,2),Q(1,3),Q(1,6)],[Q(3,4),Q(1,4)]],
        lambda x:Q(2)*x[0]**2-Q(1,2)*x[1]+Q(3)*x[0]*x[1]),
       ([[0,1]]*3,[[Q(1,5),Q(4,5)],[Q(1,3),Q(2,3)],[Q(2,7),Q(5,7)]],
        [[Q(1,2),Q(1,3),Q(1,6)],[Q(1,4),Q(3,4)],[Q(2,5),Q(3,5)]],
        lambda x:Q(1)-Q(2)*x[0]+Q(5)*x[1]*x[2]+Q(7)*x[0]*x[1]*x[2]),
       ([[0,1],[0,1]],[[Q(1,2),Q(1,2)],[Q(1,2),Q(1,2)]],
        [[Q(1),Q(0)],[Q(1,2),Q(1,2)]],
        lambda x:Q(5)*x[0]*x[1]+Q(2)*x[1])
    ]
    total=0
    for k,(a,mu,pi,fun) in enumerate(configurations,1):
        f={x:fun(x) for x in product(*a)}
        count,v,ins,lam=case(a,mu,pi,f)
        total+=count
        print(f'CASE {k} PASS | arrays {count} | expected variance {v} | mean influences {ins} | collisions {lam}')
    print(f'PASS: {len(configurations)} independent models, {total} positive-weight replica arrays')

if __name__ == '__main__':
    main()
