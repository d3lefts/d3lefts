#!/usr/bin/env python3
"""Finite falsification of conditional-section duality, independent of its proof.
Uses exact fractions for product probabilities, conditional risks and influences;
high-precision Decimal is used only for square roots. Not a theorem checker.
"""
from decimal import Decimal, localcontext
from fractions import Fraction as F
from itertools import combinations, product
from random import Random
from math import prod
R = Random(20261112)

def dec(x):
    return Decimal(x.numerator) / Decimal(x.denominator)

def run_model(fair, trial):
    n = R.randrange(2, 7) if fair else R.randrange(2, 6)
    sizes = [2 if fair else R.choice((2, 3)) for _ in range(n)]
    mu = []
    for k in sizes:
        weights = [1] * k if fair else [R.randint(1, 10) for _ in range(k)]
        mu.append([F(w, sum(weights)) for w in weights])
    space = list(product(*(range(k) for k in sizes)))
    edges = list(combinations(range(n), 2))
    u = {(i, a): R.randint(-4, 4) for i in range(n) for a in range(sizes[i])}
    v = {(i, j, a, b): R.randint(-3, 3) for i, j in edges for a in range(sizes[i]) for b in range(sizes[j])}
    val = {x: F(sum(u[i, x[i]] for i in range(n)) + sum(v[i, j, x[i], x[j]] for i, j in edges)) for x in space}
    mid = (min(val.values()) + max(val.values())) / 2
    val = {x: z - mid for x, z in val.items()}
    B = max(map(abs, val.values()))
    if not B:
        return
    mass = {x: prod(mu[i][x[i]] for i in range(n)) for x in space}
    mean = sum((mass[x] * val[x] for x in space), F())
    V = sum((mass[x] * (val[x] - mean)**2 for x in space), F())
    influence, section = [], []
    with localcontext() as ctx:
        ctx.prec = 72
        for i in range(n):
            means = {}
            localvar = {}
            for x in space:
                key = x[:i] + x[i+1:]
                if key not in means:
                    arr = [val[x[:i] + (a,) + x[i+1:]] for a in range(sizes[i])]
                    m = sum((mu[i][a]*arr[a] for a in range(sizes[i])), F())
                    means[key] = m
                    localvar[key] = sum((mu[i][a]*(arr[a]-m)**2 for a in range(sizes[i])), F())
            I = sum((mass[x]*(val[x]-means[x[:i]+x[i+1:]])**2 for x in space), F())
            A = sum((dec(mass[x])*dec(localvar[x[:i]+x[i+1:]]).sqrt() for x in space), Decimal(0))
            influence.append(I)
            section.append(A)
        nonzero = [i for i, v in enumerate(influence) if v]
        beta = min(section[i]/dec(influence[i]).sqrt() for i in nonzero)
        L = sum((dec(i).sqrt() for i in influence), Decimal(0))
        assert sum(section) <= Decimal(8)*dec(B) + Decimal('1e-48')
        assert L*beta <= Decimal(8)*dec(B) + Decimal('1e-48')
        order = sorted(range(n), key=lambda i:influence[i], reverse=True)
        for q in range(1, n+1):
            chosen = order[:q]
            groups = {}
            for x in space:
                key = tuple(x[j] for j in chosen)
                if key not in groups:
                    groups[key] = [F(), F()]
                groups[key][0] += mass[x]
                groups[key][1] += mass[x]*val[x]
            risk = V - sum((m*m/p for p,m in groups.values()), F()) + mean*mean
            assert risk >= 0
            assert risk <= sum(influence[j] for j in order[q:])
            assert dec(risk) <= L*L/Decimal(4*q)+Decimal('1e-48')
            assert dec(risk) <= Decimal(16)*dec(B)*dec(B)/(beta*beta*q)+Decimal('1e-48')
            if fair:
                assert risk <= 32*B*B/q
        if fair:
            assert beta*beta >= Decimal('0.5')-Decimal('1e-48')

def run_address(b,k):
    dims = [range(k) if t==0 else range(2) for j in range(b) for t in range(k+1)]
    space = list(product(*dims)); N = len(space)
    vals = {x:F(sum(2*x[j*(k+1)+1+x[j*(k+1)]]-1 for j in range(b)),b) for x in space}
    assert sum((z*z for z in vals.values()),F())/N == F(1,b)
    for mask in range(1<<len(dims)):
        S = [i for i in range(len(dims)) if mask>>i&1]
        groups = {}
        for x,z in vals.items():
            key = tuple(x[i] for i in S)
            if key not in groups: groups[key] = [0,F()]
            groups[key][0] += 1; groups[key][1] += z
        explained = sum((tot*tot/F(num) for num,tot in groups.values()),F()) / N
        expected = F()
        for j in range(b):
            gate = j*(k+1)
            leaves = sum((gate+1+t in S for t in range(k)))
            expected += F(leaves,b*b*(k if gate in S else k*k))
        assert explained == expected
        assert F(1,b)-explained >= F(1,b)-F(len(S),b*b*k)
    return 1<<len(dims)

if __name__ == '__main__':
    for is_fair,count in ((False,60),(True,120)):
        for trial in range(count): run_model(is_fair,trial)
        print('PASS model family', 'fair signs' if is_fair else 'heterogeneous', count)
    masks = sum(run_address(b,k) for b,k in ((1,4),(2,2),(2,3)))
    assert masks == 352
    print('PASS exact address-subset checks', masks)
    print('PASS all 180 finite product models and 352 exact query subsets')
