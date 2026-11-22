#!/usr/bin/env python3
"""Independent exact *finite witness* for reachable-history detector holonomy.

Checks rational projector nodes and the rank-loss matrix on four
cardinal directions.  The universal lifting/stability theorems are
paper proofs, not established by these checks.  No external packages.
"""
from fractions import Fraction as F


def projector(v):
    x,y = [F(t) for t in v]
    denom=x*x+y*y
    assert denom
    return ((x*x/denom,x*y/denom),(x*y/denom,y*y/denom))


def det(M):
    return M[0][0]*M[1][1]-M[0][1]*M[1][0]


def sign(x):
    assert x
    return 1 if x>0 else -1


def rank_loss_on_axes(z):
    x,y=z
    # For the cardinal points (and the origin) only, r=|x|+|y|.
    r=F(abs(x)+abs(y))
    return (((r+x)/(2*(1+r)),F(y,2*(1+r))),
            (F(y,2*(1+r)),(r-x)/(2*(1+r))))


def main():
    # Analytic half-angle loop: four 45-degree arcs, with a full return
    # in the UNORIENTED projective line after 180 degrees of row angle.
    vectors=[(1,0),(1,1),(0,1),(-1,1),(1,0)]
    P=[projector(v) for v in vectors]
    assert P[0]==P[-1]
    for p in P:
        assert det(p)==0 and p[0][0]+p[1][1]==1
        assert p[0][0]>=0 and p[1][1]>=0

    signs=[]
    for a,b in zip(vectors,vectors[1:]):
        d=a[0]*b[0]+a[1]*b[1]
        norms=(a[0]*a[0]+a[1]*a[1])*(b[0]*b[0]+b[1]*b[1])
        assert F(d*d,norms)>0  # adjacent unoriented lines not orthogonal
        signs.append(sign(d))
    assert signs==[1,1,1,-1]
    product=1
    for s in signs:product*=s
    assert product==-1

    # On a radius-1 circle around an interior point of the orthant,
    # Q equals P/2. At the central rank-zero point Q is the zero matrix.
    circle=[(1,0),(0,1),(-1,0),(0,-1)]
    for z,p in zip(circle,P[:-1]):
        q=rank_loss_on_axes(z)
        assert det(q)==0
        assert q[0][0]>=0 and q[1][1]>=0
        assert q[0][0]+q[1][1]==F(1,2)
        assert q==tuple(tuple(v/F(2) for v in row) for row in p)
    assert rank_loss_on_axes((0,0))==((F(0),F(0)),(F(0),F(0)))
    print('PASS: exact rational rank-one projector nodes and -1 holonomy')
    print('SCOPE: finite witness only; no query-complexity/continuity proof')


if __name__=='__main__':
    main()
