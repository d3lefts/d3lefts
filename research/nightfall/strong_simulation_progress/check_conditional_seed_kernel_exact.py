#!/usr/bin/env python3
"""Independent exact-rational audit of conditional source→seed disintegration.

Checks Markov composition, zero-atom rows, original-source seed marginals,
and tensorized joint seed law against separate finite enumerations.
Finite tests are NOT a proof; Lean must certify the general identities.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random
from hashlib import sha256
from pathlib import Path

rng = Random(20261119)
checks = 0
zero_cases = 0

def row(n):
    a = [rng.choice([0, 0, 0, 1, 2, 3, 7, 11]) for _ in range(n)]
    if sum(a) == 0:
        a[rng.randrange(n)] = 1
    return [Q(v, sum(a)) for v in a]

def ck(cond, msg):
    global checks
    assert cond, msg
    checks += 1

for X,Y,U,n in [(2,2,3,1),(2,3,2,2),(3,2,2,2),(3,3,3,3)]:
    for trial in range(60):
        p = [row(X) for _ in range(n)]
        C = [[row(Y) for _ in range(X)] for _ in range(n)]
        D = [[row(U) for _ in range(Y)] for _ in range(n)]
        q = [[sum(p[i][x]*C[i][x][y] for x in range(X))
              for y in range(Y)] for i in range(n)]
        r = [[sum(q[i][y]*D[i][y][u] for y in range(Y))
              for u in range(U)] for i in range(n)]
        K = [[[sum(C[i][x][y]*D[i][y][u] for y in range(Y))
               for u in range(U)] for x in range(X)] for i in range(n)]
        zero_cases += any(v==0 for pp in p for v in pp)
        zero_cases += any(v==0 for qq in q for v in qq)
        for i in range(n):
            for x in range(X):
                ck(sum(K[i][x])==1, ('row', X,Y,U,n,trial,i,x))
                for u in range(U):
                    ck(K[i][x][u]>=0, ('nonnegative',i,x,u))
                    ck(K[i][x][u]==sum(C[i][x][y]*D[i][y][u]
                                       for y in range(Y)),('compose',i,x,u))
            for u in range(U):
                ck(sum(p[i][x]*K[i][x][u] for x in range(X))==r[i][u],
                   ('single push',i,u))
                ck(sum(p[i][x]*sum(C[i][x][y]*D[i][y][u]
                                    for y in range(Y)) for x in range(X))
                    ==sum(q[i][y]*D[i][y][u] for y in range(Y)),
                   ('independent Fubini',i,u))
        # Joint pushforward is checked by enumerating all original strings
        # without factorizing the expectation in the checker.
        for us in product(range(U),repeat=n):
            direct=sum(
                (Q(1)*__import__('math').prod([p[i][xs[i]]*K[i][xs[i]][us[i]]
                                              for i in range(n)]))
                for xs in product(range(X),repeat=n))
            independent=Q(1)
            for i in range(n):
                independent*=r[i][us[i]]
            ck(direct==independent,('joint push',X,Y,U,n,trial,us))
print(f"PASS {checks} exact-rational identities; {zero_cases} zero-atom source/target cases")
print("SHA256",sha256(Path(__file__).read_bytes()).hexdigest())
