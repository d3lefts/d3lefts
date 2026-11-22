#!/usr/bin/env python3
"""Independent stress tests of the two-dimensional robust phase-retrieval bounds.

This checker verifies exact algebraic constants, random geometric perturbations,
and chosen fiber ambiguities. It is NOT a Lean/theorem or independence receipt.
"""
from fractions import Fraction as Q
import math
import random

RNG = random.Random(20261122)
MAX_S = Q(1, 1024)


def exact_constants():
    assert Q(25, 64) + Q(1, 128) == Q(51, 128) < Q(1, 2)
    assert 2 * (1 + 4 * MAX_S) <= Q(17, 8)
    assert Q(16) * MAX_S + 2 * MAX_S == Q(18) * MAX_S
    assert Q(1, 2) - Q(33, 32) * Q(1, 64) - Q(1, 8) * Q(1, 64) > 0
    assert (1 - Q(1, 64)) * Q(3, 2) > 1
    # sqrt(1+u) >= 1+u/3 when 0<=u<=3
    for u in [Q(0), Q(1, 1024*16), Q(1, 16), Q(1), Q(3)]:
        assert 1 + u >= (1 + u/3)**2
    return True


def norm2(v):
    return v[0]*v[0]+v[1]*v[1]


def dot(a,b):
    return a[0]*b[0]+a[1]*b[1]


def dist_pm(x,y):
    return min(math.dist(x,y), math.dist(x,(-y[0],-y[1])))


def geometric_inflate(x,y,s):
    a=math.sqrt(norm2(x))
    b=math.sqrt(norm2(y))
    if b>a:
        x,y=y,x
        a,b=b,a
    if dot(x,y)<0:
        y=(-y[0],-y[1])
    d=dist_pm(x,y)
    assert d>=1-1e-12 and a<=1+1e-12 and b<=1+1e-12
    if b*b<=1-s:
        if b:
            factor=math.sqrt(b*b+s)/b
            yp=(factor*y[0],factor*y[1])
        else:
            yp=(0,math.sqrt(s)) if abs(x[1])<1e-12 else (
                -x[1]/a*math.sqrt(s), x[0]/a*math.sqrt(s))
        mode="radial"
    elif d*d>=1+s/16:
        yp=y
        mode="already"
    else:
        # 2D orientation-preserving representation around x.
        ux,uy=x[0]/a,x[1]/a
        bx,by=y[0]/b,y[1]/b
        cos_angle=max(-1,min(1,ux*bx+uy*by))
        sin_angle=abs(ux*by-uy*bx)
        theta=math.atan2(sin_angle,cos_angle)
        phi=s/8
        side=1 if ux*by-uy*bx>=0 else -1
        yp=(b*(math.cos(theta+phi)*ux-side*math.sin(theta+phi)*uy),
            b*(math.cos(theta+phi)*uy+side*math.sin(theta+phi)*ux))
        mode="rotation"
    assert norm2(yp)<=1+1e-11, (x,y,s,yp,mode)
    assert dist_pm(x,yp)**2>=1+s/16-1e-10,(x,y,s,mode,dist_pm(x,yp))
    # Maximal intensity perturbation over all unit rows is bounded by a
    # Cauchy inequality; probe an additional independent direction.
    for angle in [0, math.pi/4, math.pi/2, RNG.random()*math.pi]:
        row=(math.cos(angle),math.sin(angle))
        discrepancy=abs(dot(row,yp)**2-dot(row,y)**2)
        assert discrepancy<=s+1e-10,(s,mode,discrepancy)
    return mode


def geometric_tests():
    counts={"radial":0,"rotation":0,"already":0}
    for s in [1/1024,1/4096,1/65536]:
        # Degenerate zero and nearly orthogonal case.
        for y in [(0,0),(0,math.sqrt(s)/2)]:
            counts[geometric_inflate((1,0),y,s)]+=1
        # Force the hard near-boundary rotation branch.
        theta=math.acos((2-(1+s/64))/2)
        counts[geometric_inflate((1,0),(math.cos(theta),math.sin(theta)),s)]+=1
        for _ in range(120000):
            a,b=sorted([RNG.random()**0.3,RNG.random()**0.3],reverse=True)
            theta=RNG.uniform(math.pi/3,math.pi/2)
            x=(a,0)
            y=(b*math.cos(theta),b*math.sin(theta))
            if dist_pm(x,y)<1: continue
            counts[geometric_inflate(x,y,s)]+=1
    assert counts["radial"]>100 and counts["rotation"]>=3
    return counts


def observations(x,beta):
    return x[0]**2, (x[0]+beta*x[1])**2/(1+beta*beta)


def fiber_tests():
    s=1/1024
    beta=2*math.sqrt(s)
    delta=4*math.sqrt(s)
    test_pairs=0
    # Construct a genuine nontrivial equal-reading fiber near the axis.
    x=(beta/4,0)
    y=(beta/4,-1/2)
    assert math.dist(observations(x,beta),observations(y,beta))<1e-12
    assert x[0]<=delta and y[0]<=delta
    # Targeted sampled feasible pairs. Far fibers are strongly bounded.
    for _ in range(180000):
        x1=RNG.uniform(0,1)
        x2=RNG.uniform(-math.sqrt(1-x1*x1),math.sqrt(1-x1*x1))
        y1=max(0,min(1,x1+RNG.uniform(-2*math.sqrt(s),2*math.sqrt(s))))
        y2=RNG.uniform(-math.sqrt(1-y1*y1),math.sqrt(1-y1*y1))
        x=(x1,x2); y=(y1,y2)
        p=observations(x,beta); q=observations(y,beta)
        if max(abs(p[i]-q[i]) for i in range(2))>2*s: continue
        test_pairs+=1
        if min(x1,y1)<=delta:
            for z in (x,y):
                assert dist_pm(z,(0,0.5))<=0.5+18*s+1e-12
        else:
            assert dist_pm(x,y)<=51/128+1e-12
    assert test_pairs>10
    # A negative control: beta=0 has a far-axis exact ambiguity.
    root=math.sqrt(.5)
    a=(root,root); b=(root,-root)
    assert observations(a,0)==observations(b,0)
    assert dist_pm(a,b)>0.5
    return test_pairs


if __name__ == "__main__":
    exact_constants()
    counts=geometric_tests()
    fibers=fiber_tests()
    print("PASS exact rational inequalities and square-root lower expansion")
    print("PASS geometry modes:",counts)
    print("PASS compatible two-row sampled fibers:",fibers)
    print("PASS negative control: parallel rows fail")
    print("SCOPE: numerical falsification only; not a proof or review certificate")
