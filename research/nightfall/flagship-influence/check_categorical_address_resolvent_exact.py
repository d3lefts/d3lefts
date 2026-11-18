#!/usr/bin/env python3
"""Exact degree-two categorical selector proof attack on heat-resolvent root sums.
Uniform address A in [m], independent fair-sign leaves Y_j. No UE2 refutation.
"""
from fractions import Fraction as F
from itertools import product


def direct(m):
    leaves=list(product((-1,1), repeat=m))
    wt=F(1,m*2**m)
    Ef=F(0); Ef2=F(0); IA=F(0); IAh=F(0)
    leaf_I=[F(0)]*m; leaf_h=[F(0)]*m
    for ys in leaves:
        fvals=[ys[a] for a in range(m)]
        hvals=[sum((F(1,2*m)+(F(1,2) if a==j else 0))*ys[j] for j in range(m)) for a in range(m)]
        Eaf=sum(fvals,F(0))/m;Eah=sum(hvals,F(0))/m
        IA+=(F(1)-Eaf**2)/2**m
        IAh+=(sum((hv-Eah)**2 for hv in hvals)/m)/2**m
        for a in range(m):
            Ef+=wt*fvals[a];Ef2+=wt*fvals[a]**2
            for j in range(m):
                leaf_I[j]+=wt*(F(1) if a==j else F(0))
                leaf_h[j]+=wt*(F(1,2*m)+(F(1,2) if a==j else 0))**2
    assert Ef==0 and Ef2==1
    assert IA==1-F(1,m)
    assert IAh==F(1,4)*(1-F(1,m))
    assert all(x==F(1,m) for x in leaf_I)
    assert all(x==F(m+3,4*m*m) for x in leaf_h)
    return IA,IAh,leaf_I,leaf_h


def main():
    for m in (2,3,4,5,6,7):
        direct(m)
        print('PASS full-state rational alphabet m=',m)
    # Exact no-floating radical comparison at m=7:
    # [sqrt(10)+sqrt(6/7)]/2 > 2 iff sqrt(60/7)>18/7
    assert F(60,7)>F(18,7)**2
    assert F(5,6)<1 # m=6 budget = (3+sqrt(5/6))/2 <2
    # Leaf-only norm sum = sqrt(m+3)/2, so it exceeds 2 at m=14
    assert F(14+3)>16 and F(13+3)==16
    # Source f has V=B=1, M=1-1/m, d=2
    for m in (2,7,14,100):
        R=F(1,4)*(F(m,m-1))
        assert R<=1
    print('PASS exact categorical degree-2 gradient budget refutation at m=7, unbounded as sqrt(m)')
    print('PASS original UE2(2,1) survives: V^2/(4 B^2 M)=m/(4(m-1))')

if __name__=='__main__':main()
