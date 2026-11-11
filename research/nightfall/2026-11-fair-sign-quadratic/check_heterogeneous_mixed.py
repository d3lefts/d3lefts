#!/usr/bin/env python3
"""Exact finite adversarial replay of heterogeneous-X / fair-Z mixed control theorem.

Nonfloat Fraction computations independently test:
* law-free vector additivity and mixed bi-degree (1,1) variance coefficient < 5;
* odd/even block decompositions, influence monotonicity and exact energies;
* the same vector quadratic guarantee at every positive-probability posterior.

Finite verification is not a universal mathematical proof.
"""
from fractions import Fraction as F
from itertools import product
from random import Random

RNG = Random(20261111)
DOMAINS = ((0, 1, 2), (0, 1), (-1, 1), (-1, 1))
LAWS = (
    (F(1, 2), F(1, 3), F(1, 6)),
    (F(3, 4), F(1, 4)),
    (F(1, 2), F(1, 2)),
    (F(1, 2), F(1, 2)),
)
FEATURES = (
    ((1, -1, -1), (0, 1, -2)),
    ((1, -3),),
)
assert all(sum((p*a for p, a in zip(LAWS[i], f)), F()) == 0
           for i in range(2) for f in FEATURES[i])

STATES = list(product(*DOMAINS))
WEIGHTS = {}
for x in STATES:
    p = F(1)
    for i, z in enumerate(x):
        p *= LAWS[i][DOMAINS[i].index(z)]
    WEIGHTS[x] = p
assert sum(WEIGHTS.values(), F()) == 1


def make_coeff():
    return [
        (RNG.randrange(-3, 4), [RNG.randrange(-3, 4) for _ in range(3)],
         [RNG.randrange(-3, 4) for _ in range(2)],
         [[RNG.randrange(-3, 4) for _ in range(2)] for _ in range(3)])
        for _ in range(3)
    ]


def vector(coeff, x):
    fs = [FEATURES[0][0][x[0]], FEATURES[0][1][x[0]],
          FEATURES[1][0][x[1]]]
    return tuple(c + sum(a*f for a, f in zip(lin, fs))
                 + sum(a*z for a, z in zip(zlin, x[2:]))
                 + sum(w[j]*fs[i]*x[2+j]
                       for i,w in enumerate(cross) for j in range(2))
                 for c, lin, zlin, cross in coeff)


def stats(table, observations=None):
    t = observations or {}
    rows = [(x, p, table[x]) for x,p in WEIGHTS.items()
            if all(x[i] == val for i,val in t.items())]
    mass = sum((p for x,p,v in rows), F())
    rows = [(x,p/mass,v) for x,p,v in rows]
    K = len(rows[0][2])
    mean = [sum((p*v[a] for x,p,v in rows), F()) for a in range(K)]
    W = sum((p*sum((v[a]-mean[a])**2 for a in range(K))
             for x,p,v in rows), F())
    influences = {}
    for i in range(4):
        if i in t: continue
        groups = {}
        for x,p,v in rows:
            key = x[:i] + x[i+1:]
            total,sm,ss=groups.get(key, (F(), [F()]*K, F()))
            groups[key] = (
                total+p,
                [sm[a]+p*v[a] for a in range(K)],
                ss+p*sum(v[a]**2 for a in range(K)))
        influences[i] = sum((ss-sum(z*z for z in sm)/total
                             for total,sm,ss in groups.values()), F())
    return W, influences


def trial():
    coeff = make_coeff()
    g = {x:vector(coeff,x) for x in STATES}
    A = max(sum(abs(y) for y in v) for v in g.values())
    W, inf = stats(g)
    M = max(inf.values())
    assert W*W <= 25 * A*A*M, ("mixed law theorem", W,A,M)

    even, odd, zonly, cross = {}, {}, {}, {}
    for x in STATES:
        flip=x[:2]+(-x[2],-x[3])
        even[x]=tuple(F(a+b, 2) for a,b in zip(g[x],g[flip]))
        odd[x]=tuple(F(a-b, 2) for a,b in zip(g[x],g[flip]))
    for x in STATES:
        # X mean of odd at fixed fair Z, weighted under arbitrary X laws
        v=[F() for _ in range(3)]
        for xp in STATES:
            if xp[2:] != x[2:]:continue
            for a in range(3):
                v[a]+=WEIGHTS[xp]*2*2*odd[xp][a]
        zonly[x]=tuple(v)
        cross[x]=tuple(odd[x][a]-v[a] for a in range(3))
    We,Ie = stats(even)
    Wz,Iz = stats(zonly)
    Wc,Ic = stats(cross)
    assert W == We+Wz+Wc, (W,We,Wz,Wc)
    assert max(sum(abs(v) for v in row) for row in even.values())<=A
    assert max(sum(abs(v) for v in row) for row in odd.values())<=A
    assert We*We <= 2*A*A*M
    assert Wz*Wz <= 2*A*A*M
    assert Wc*Wc <= 4*A*A*M
    assert all(Ie.get(i,F())<=inf[i] and
               Iz.get(i,F())<=inf[i] and
               Ic.get(i,F())<=inf[i] for i in inf)

    transcripts=0
    for mask in range(1 << 4):
        chosen=[i for i in range(4) if mask>>i & 1]
        for vals in product(*(DOMAINS[i] for i in chosen)):
            obs=dict(zip(chosen,vals))
            post, I=stats(g,obs)
            if I:
                assert post*post <= 25*A*A*max(I.values()), (
                    "posterior mixed",obs,post,I,A)
            else: assert post==0
            transcripts+=1
    assert transcripts == 108
    return transcripts


if __name__ == "__main__":
    checks=sum(trial() for _ in range(25))
    print("PASS: 25 random heterogeneous mixed l1-vector tests")
    print("PASS: 2700 exact posterior transcript influence tests =",checks)
    print("SCOPE: finite arithmetic; mixed-Khintchine proof and originality separate")
