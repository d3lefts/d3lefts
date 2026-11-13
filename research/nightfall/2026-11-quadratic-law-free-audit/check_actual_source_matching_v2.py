#!/usr/bin/env python3
"""Independent exact finite source-derived matching falsifier, 2026-11-13.

Recomputes conditional Hoeffding pair kernels from the source f (not from
generator pair coefficients). Dense cross-matching interactions, rare atoms,
and discarded zero-mass symbols. Exact rational arithmetic.
Finite tests are not a universal proof or a Lean certificate.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from random import Random
from collections import Counter

rng = Random(20261113)
counts = Counter()

def mass(p, x):
    v = Q(1)
    for i,a in enumerate(x): v *= p[i][a]
    return v

def choose_model(n, sizes, trial):
    laws = []
    for i, k in enumerate(sizes):
        a = [rng.choice((1,2,3,5,7,31,100003,999983)) for _ in range(k)]
        if trial % 7 == 0: a[rng.randrange(k)] = 0
        if not any(a): a[0] = 1
        total = sum(a)
        laws.append([Q(v,total) for v in a])
    lin = [[rng.randrange(-8,9) for _ in range(k)] for k in sizes]
    quad = {(i,j): [[rng.randrange(-9,10) for _ in range(sizes[j])]
                     for _ in range(sizes[i])]
            for i,j in combinations(range(n),2)}
    c = rng.randrange(-8,9)
    def f(x):
        return Q(c + sum(lin[i][a] for i,a in enumerate(x))
                 + sum(v[x[i]][x[j]] for (i,j),v in quad.items()))
    return laws, f

def check(n, sizes, trial):
    p, f = choose_model(n, sizes, trial)
    supports = [[a for a, prob in enumerate(law) if prob] for law in p]
    xs = list(product(*supports))
    px = {x: mass(p,x) for x in xs}
    fv = {x: f(x) for x in xs}
    B = max(map(abs, fv.values()))
    mean = sum((px[x] * fv[x] for x in xs), Q())
    def conditional(conditions):
        denom = Q(1)
        for i,a in conditions.items(): denom *= p[i][a]
        return sum((px[x]*fv[x] for x in xs if all(x[i]==a for i,a in conditions.items())),Q())/denom
    h1 = {(i,a):conditional({i:a})-mean for i in range(n) for a in supports[i]}
    h2 = {}
    for i,j in combinations(range(n),2):
        for a,b in product(supports[i],supports[j]):
            h2[i,j,a,b] = conditional({i:a,j:b})-h1[i,a]-h1[j,b]-mean
    for x in xs:
        reconstruction = mean + sum(h1[i,x[i]] for i in range(n)) + sum(h2[i,j,x[i],x[j]] for i,j in combinations(range(n),2))
        assert reconstruction == fv[x], ('decomp',n,sizes,trial,x)
        counts['source_anova'] += 1
    edges = list(combinations(range(n),2))
    amplitude = {}
    witness = {}
    for i,j in edges:
        b = max(abs(h2[i,j,a,t]) for a,t in product(supports[i],supports[j]))
        amplitude[i,j] = b
        rectangles = []
        for a0,a1,b0,b1 in product(supports[i],supports[i],supports[j],supports[j]):
            delta = h2[i,j,a0,b0]-h2[i,j,a0,b1]-h2[i,j,a1,b0]+h2[i,j,a1,b1]
            rectangles.append((delta,(a0,a1,b0,b1)))
        delta, corners = max(rectangles, key=lambda d:d[0])
        assert delta >= b >= 0,('rectangle',i,j,n,sizes,trial,b,delta)
        witness[i,j] = (delta,corners)
        counts['source_rectangle'] += 1
        # Verify four-corner identity at two distinct unmatched states.
        a0,a1,b0,b1 = corners
        for base in (xs[0],xs[-1]):
            def put(a,b):
                y = list(base); y[i] = a; y[j] = b
                return f(tuple(y))
            assert put(a0,b0)-put(a0,b1)-put(a1,b0)+put(a1,b1)==delta
            counts['source_rectangle_invariance']+=1
    matchings = []
    for mask in range(1<<len(edges)):
        chosen = [e for k,e in enumerate(edges) if mask>>k&1]
        if len(set(v for e in chosen for v in e))==2*len(chosen):
            matchings.append(chosen)
    for selected in matchings:
        assert sum((amplitude[e] for e in selected),Q()) <= 4*B, ('mass',n,sizes,trial,selected)
        counts['global_matching_mass']+=1
        if not selected:continue
        per_edge=[witness[e] for e in selected]
        parity = []
        for odd in (False, True):
            total = Q()
            for sig in product((0,1),repeat=len(selected)):
                state=list(xs[0])
                for (i,j),(delta,(a0,a1,b0,b1)),bit in zip(selected,per_edge,sig):
                    state[i]=(a0,a1)[bit]
                    state[j]=(b0,b1)[bit ^ int(odd)]
                total+=f(tuple(state))/ (1<<len(selected))
            parity.append(total)
        actual_gap=parity[0]-parity[1]
        expected_gap=sum((e[0] for e in per_edge),Q())/2
        assert actual_gap==expected_gap, ('global_parity',n,sizes,trial,selected,actual_gap,expected_gap)
        assert abs(parity[0])<=B and abs(parity[1])<=B
        counts['actual_source_global_parity']+=1

if __name__=='__main__':
    for n in (2,3,4,5,6):
        for trial in range(18):
            sizes=[rng.choice((2,3)) for _ in range(n)]
            check(n,sizes,trial)
            counts['models']+=1
    print('PASS exact source-derived Q2 matching falsifier')
    for k in sorted(counts): print(k,counts[k])
    print('All statements finite exact Fraction checks, not a universal machine proof.')
