#!/usr/bin/env python3
"""Exact template verification: binary tiles -> an antipodal-free squared oracle code.

For p=4*2^d-3 or -1 (p prime), tile pattern with d>=3.
p=13,d=2 is the separately checked exceptional seed.
Each K=GF(p^2) is *its own* fixed square oracle, never equated across p.
"""
from itertools import product

def certificate(p,d):
    D=1<<d
    assert p in (4*D-3,4*D-1)
    assert p>=13 and all(p%a for a in range(2,int(p**0.5)+1))
    def plus(u,v):
        return ((u[0]+v[0])%p,(u[1]+v[1])%p)
    def scale(c,u):
        return ((c*u[0])%p,(c*u[1])%p)
    def dot(u,v):
        return plus(u,v)
    v=(2*D-1,D+1)
    w=(p-1,D+1)
    zero=(0,0)
    shifts=(zero,v,w,plus(v,w))
    cube={( (i+shift[0])%p,(j+shift[1])%p )
          for shift in shifts for i in range(D) for j in range(D)}
    assert len(cube)==4*D*D

    # Exact group identity: the binary 2d+2-cube is a union of four D×D
    # rectangles. Its full pairwise sumset is nine (2D-1)×(2D-1) rectangles.
    fullsum={(((a*v[0]+b*w[0])+i)%p,
              ((a*v[1]+b*w[1])+j)%p)
             for a in (0,1,2) for b in (0,1,2)
             for i in range(2*D-1) for j in range(2*D-1)}
    hole=(2*D-2,2*D+1)
    assert len(fullsum)==(167 if p==13 else p*p-6)
    assert hole not in fullsum
    if p<=31:
        assert fullsum=={plus(a,b) for a in cube for b in cube}

    inv2=pow(2,-1,p)
    translation=scale(-inv2,hole)
    W=tuple((1<<i,0) for i in range(d)) + \
      tuple((0,1<<i) for i in range(d)) + (v,w)
    assert len(W)==2*d+2
    a=tuple(scale(inv2,x) for x in W)
    anchor=translation
    for item in a: anchor=plus(anchor,item)

    # Check the ACTUAL squared oracle in GF(p)[t]/(t²-delta).
    delta=next(z for z in range(2,p) if pow(z,(p-1)//2,p)==p-1)
    def mul(x,y):
        return ((x[0]*y[0]+delta*x[1]*y[1])%p,
                (x[0]*y[1]+x[1]*y[0])%p)
    out=set()
    for signs in product((1,p-1),repeat=len(a)):
        value=anchor
        for c,sgn in zip(a,signs,strict=True):
            value=plus(value,scale(sgn,c))
        squared=mul(value,value)
        assert squared not in out
        out.add(squared)
    assert len(out)==(1<<len(a))
    M=(p*p+1)//2
    assert (1<<len(a))<=M<(1<<(len(a)+1))
    print("PASS",f"p={p}",f"d={d}",f"signs={len(a)}",
          f"|cube|={len(cube)}",f"|cube+cube|={len(fullsum)}",
          f"hole={hole}",f"readings={len(out)}",
          f"alphabet={M}",f"delta={delta}")
    return len(a)

for p,d in ((13,2),(29,3),(31,3),(61,4),(127,5)):
    certificate(p,d)

print("PASS: all five prime fields achieve the one-squared-reading sign alphabet ceiling")
print("STATUS: symbolic all-d lemma is in THEOREM.md; samples are exact finite regressions")
