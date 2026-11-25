#!/usr/bin/env python3
"""Exact rational certificate for a semialgebraic half-turn rank-one projector.

Only certifies a finite algebraic witness, not global continuity or query counts.
"""
from fractions import Fraction as F


def row(s):
    s = F(s)
    den = (1-s)**2+s**2
    assert den > 0
    return ((1-2*s)/den, (2*s*(1-s))/den)


def projector(v):
    x, y = v
    return ((x*x,x*y),(x*y,y*y))


def dot(a,b):
    return a[0]*b[0]+a[1]*b[1]


def check():
    # Degree <=4, so five distinct rational zeros certify polynomial identity.
    for k in range(5):
        s=F(k)
        d=(1-s)**2+s*s
        val=(1-2*s)**2+4*s*s*(1-s)**2-d*d
        assert val == 0

    params=[F(0),F(1,3),F(1,2),F(2,3),F(1)]
    V=[row(s) for s in params]
    assert V[0] == (1,0)
    assert V[-1] == (-1,0)
    assert projector(V[0]) == projector(V[-1])
    assert all(dot(v,v) == 1 for v in V)

    # Closing the projector path by the initial sign yields odd sign holonomy.
    loop=V[:-1]+[V[0]]
    signs=[]
    for a,b in zip(loop,loop[1:]):
        c=dot(a,b)
        assert c != 0
        signs.append(1 if c>0 else -1)
    assert signs == [1,1,1,-1]
    assert signs[0]*signs[1]*signs[2]*signs[3] == -1

    for v in V:
        p=projector(v)
        assert p[0][0]+p[1][1] == 1
        assert p[0][0]*p[1][1]-p[0][1]*p[1][0] == 0
        for i in range(2):
            for j in range(2):
                assert sum(p[i][k]*p[k][j] for k in range(2)) == p[i][j]

    print("PASS: exact rational polynomial, projector and -1 sign-cycle witnesses")
    print("SCOPE: does not prove universal continuity, query complexity or novelty")


if __name__ == "__main__":
    check()
