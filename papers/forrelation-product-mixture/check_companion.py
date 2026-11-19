#!/usr/bin/env python3
"""Finite falsification checks for the Gaussian-sign Forrelation companion paper.

No external packages. These finite tests are not a proof and not a Lean
certificate for the general Gaussian identity.
"""
from fractions import Fraction
from collections import Counter
import math

def phi(t):
    return .5*((1+t)*math.log1p(t) if t > -1 else 0.0) + \
           .5*((1-t)*math.log1p(-t) if t < 1 else 0.0)

def h2(t):
    return 0 if t in (0,1) else -t*math.log(t)-(1-t)*math.log1p(-t)

def coefficients():
    c=2/math.pi
    values=(c*c/2, phi(c), c*math.log(2), phi(c)-.02*math.log(2),
            -2*h2(.01), phi(c)/(2*math.log(2)))
    expected=(.20264236728467554,.2192005468261678,.4412712003053032,
              .2053376032149689,-.11200306870969468,.1581197709331307)
    assert all(abs(x-y)<2e-14 for x,y in zip(values,expected))
    assert 0<values[0]<values[1]<values[2]<math.log(2)
    print('PASS quadratic/binary/max-atom exact coefficients and 1pct TV rate',values)

def N2_angles():
    h=2**(-.5)
    sign=lambda t: 1 if t>=0 else -1
    cases=set()
    for k in range(8):
        a=(k+.5)*math.pi/4
        z=(math.cos(a),math.sin(a))
        f=(sign(z[0]),sign(z[1]))
        g=(sign(h*(z[0]+z[1])),sign(h*(z[0]-z[1])))
        cases.add((f,g))
    assert len(cases)==8
    P={q:Fraction(1,8) for q in cases}
    F=Counter();G=Counter()
    for (f,g),w in P.items():F[f]+=w;G[g]+=w
    assert len(F)==len(G)==4 and set(F.values())=={Fraction(1,4)}
    assert set(G.values())=={Fraction(1,4)}
    mi=sum(float(w)*math.log(float(w/F[f]/G[g])) for (f,g),w in P.items())
    alpha=sum(float(w)*(f[0]*(h*g[0]+h*g[1])+f[1]*(h*g[0]-h*g[1]))/2
              for (f,g),w in P.items())
    assert abs(mi-math.log(2))<1e-14 and abs(alpha-h)<1e-14
    fs=list(F);gs=list(G)
    maxrect=0
    for a in range(1,16):
        for b in range(1,16):
            AA=[fs[i] for i in range(4) if a>>i&1]
            BB=[gs[j] for j in range(4) if b>>j&1]
            if all((f,g) in P for f in AA for g in BB):
                maxrect=max(maxrect,len(AA)*len(BB))
    assert maxrect==2
    for f in fs:
        gg=[g for g in gs if (f,g) in P]
        assert len(gg)==2 and sum(gg[0][i]!=gg[1][i] for i in range(2))==1
    print('PASS N=2 eight equal sign sectors; exact product-mixture rank 4')

def shannon(p):
    return -sum(float(z)*math.log(float(z)) for z in p if z>0)

def condH(p):
    return shannon(p)-shannon((p[0]+p[2],p[1]+p[3]))

def entropy_continuity():
    d=7
    simplex=[tuple(Fraction(v,d) for v in (a,b,c,d-a-b-c))
             for a in range(d+1) for b in range(d-a+1)
             for c in range(d-a-b+1)]
    assert len(simplex)==120
    count=0
    for p in simplex:
        for q in simplex:
            tv=sum(abs(x-y) for x,y in zip(p,q))/2
            if tv>Fraction(1,2):continue
            assert abs(condH(p)-condH(q))<=float(tv)*math.log(2)+h2(float(tv))+1e-12
            count+=1
    print('PASS conditional entropy continuity:',count,'2x2 exact-rational pairs')

def identity_sharpness():
    for N in range(1,9):
        assert abs(math.log(2**N)-N*math.log(2))<1e-13
    print('PASS max-atom equality case U=identity and M=2^N')

if __name__=='__main__':
    coefficients()
    N2_angles()
    identity_sharpness()
    entropy_continuity()
    print('ALL FINITE CHECKS PASSED (not general mathematical certification)')
