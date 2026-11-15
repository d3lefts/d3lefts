#!/usr/bin/env python3
"""NIGHTFALL exact finite audit: influence is not individual decision information.
Includes one-coordinate source-law replacement and operational support distinction.
Finite regression only; not an all-model proof. Standard library only.
"""
from fractions import Fraction as Q
from itertools import product
from hashlib import sha256

def f(t, a, r):
    return int((t+a) % r == 0)

def certifies(r, queries, support):
    for t0,a0 in product(support,range(r)):
        if not f(t0,a0,r):
            continue
        for t,a in product(support,range(r)):
            if f(t,a,r):
                continue
            if all(
                (t==t0 if q=='T' else a==a0 if q=='A' else f(t,a,r)==f(t0,a0,r))
                for q in queries
            ):
                return False
    return True

def moment_test(r):
    mean=Q(sum(f(t,a,r) for t,a in product(range(r),repeat=2)),r*r)
    variance=mean*(1-mean)
    def influence_t():
        return sum(
            (
                sum((Q(f(t,a,r))-Q(1,r))**2 for t in range(r))
                for a in range(r)
            ),Q(0)
        )/Q(r*r)
    def influence_a():
        return sum(
            (
                sum((Q(f(t,a,r))-Q(1,r))**2 for a in range(r))
                for t in range(r)
            ),Q(0)
        )/Q(r*r)
    assert (mean,variance,influence_t(),influence_a()) == (
        Q(1,r),Q(r-1,r*r),Q(r-1,r*r),Q(r-1,r*r))
    assert all(sum(f(t,a,r) for a in range(r))==1 for t in range(r))
    assert all(sum(f(t,a,r) for t in range(r))==1 for a in range(r))
    # Under T=0 Dirac source, A alone identifies mission; T source influence 0.
    assert Q(sum(f(0,a,r) for a in range(r)),r)==Q(1,r)
    assert certifies(r,('A',),(0,))
    assert not certifies(r,('A',),range(r))
    assert any(f(t,a,r)!=f(0,a,r) for t,a in product(range(r),repeat=2))
    assert not certifies(r,(),range(r))
    assert not certifies(r,('T',),range(r))
    assert certifies(r,('T','A'),range(r))
    assert certifies(r,('D',),range(r))

def main():
    h=sha256();count=0
    for r in range(2,16):
        moment_test(r)
        for cT,cA,cD,cG in product(range(1,5),repeat=4):
            costs=[]
            for t,a,d in product((False,True),repeat=3):
                queries=tuple(q for q,yes in zip(('T','A','D'),(t,a,d)) if yes)
                if certifies(r,queries,range(r)):
                    costs.append(cG+cT*t+cA*a+cD*d)
            optimum=min(costs)
            assert optimum==cG+min(cT+cA,cD)
            count+=1
            h.update(f'{r}|{cT}|{cA}|{cD}|{cG}|{optimum}\n'.encode())
    print('status PASS')
    print('independent cost configurations',count)
    print('r range 2..15')
    print('sha256',h.hexdigest())
    assert count==3584
    assert h.hexdigest()=='7e31b88a96cbfe9b757edcf7fd8fbf8af12730175994ba32516681b48da7c74f'

if __name__=='__main__':
    main()
