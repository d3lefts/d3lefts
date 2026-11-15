#!/usr/bin/env python3
"""Analytic integer-capacity theorem; exact Python 3 standard library.
Model: N independent modular mission checks, K0 signed current certificates,
up to B pre-window invalidations, H valid verification slots, m reusable workers,
all N atomically guarded commits in one final slot.
"""
from fractions import Fraction as F

def price(N,K0,B,H,m,g,c,d,worker_fee=0,guard_fee=0,effect_fee=0):
    assert 0 <= B <= K0 <= N and N >= 1 and H >= 1
    assert m >= 0 and g >= 0 and 0 <= 2*F(c) < F(d)
    assert min(F(worker_fee),F(guard_fee),F(effect_fee)) >= 0
    R=N-(K0-B)
    if g < N or m*H < R:
        return None
    deep=max(0,2*R-m*H)
    paired=R-deep
    assert 0<=deep<=R
    return {
        'cost':F(N)*F(effect_fee)+F(worker_fee)*m+F(guard_fee)*g+2*F(c)*R+(F(d)-2*F(c))*deep,
        'R':R,'cheap_pair':paired,'deep':deep,'units':2*paired+deep,
        'capacity':m*H,'guard_capacity':g}

def optimized(N,K0,B,H,c,d,worker_fee,guard_fee,effect_fee):
    assert 0<=B<=K0<=N and H>=1
    R=N-(K0-B)
    lo=(R+H-1)//H
    hi=(2*R+H-1)//H
    candidates=[]
    for m in range(lo,hi+1):
        z=price(N,K0,B,H,m,N,c,d,worker_fee,guard_fee,effect_fee)
        if z is not None: candidates.append((z['cost'],m,z))
    return min(candidates) if candidates else None

if __name__=='__main__':
    for B in (0,1):
        print('N3 K1 B',B,'H2 installed optimum',optimized(3,1,B,2,1,5,4,1,1))
    print('Fixed m2 invalidated:',price(3,1,1,2,2,3,1,5,4,1,1))

