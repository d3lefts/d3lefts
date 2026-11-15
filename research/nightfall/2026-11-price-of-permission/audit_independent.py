#!/usr/bin/env python3
"""Independent exhaustive certificate for exact two-stage permission capacity.
The exhaustive recursion has no use of the formula's implementation.
Standard library only; no nondeterministic testing.
"""
from fractions import Fraction
from itertools import combinations
from hashlib import sha256
from math import ceil
from permission_capacity import (capacity_formula,capacity_greedy,capacity_brute,
                                 minimum_installed_capacity,price_floor,robust_capacity)

def main():
    digest=sha256(); num=0; impossible=0; purchased=0; allsafe=0
    for n in range(0,7):
      for T in range(1,6):
       for m in range(4):
        for g in range(4):
         for k in range(n+1):
            F=capacity_formula(n,T,m,g,k)
            independent=capacity_brute(n,T,m,g,k)
            greedy,sched=capacity_greedy(n,T,m,g,k)
            assert independent == F == greedy, (n,T,m,g,k,F,independent,greedy)
            assert all(item['deep_inspections']<=m and item['guard_commits']<=g for item in sched)
            for b in range(k+1):
                # Independently enumerate every revoked-cache subset.
                worst=min(capacity_brute(n,T,m,g,k-len(S)) for S in
                          (frozenset(c) for c in combinations(range(k),b)))
                assert worst==robust_capacity(n,T,m,g,k,b)
            if F<n:impossible+=1
            digest.update(f'{n}|{T}|{m}|{g}|{k}|{F}\n'.encode());num+=1
    for n in range(0,10):
      for T in range(2,6):
       for k in range(n+1):
        for A in range(n+1):
            mr,gr=minimum_installed_capacity(A,T,k)
            assert capacity_brute(n,T,mr,gr,k)>=A
            # Each claimed needed capacity independently falsified by exhaustive search.
            if mr>0:assert capacity_brute(n,T,mr-1,gr,k)<A
            if gr>0:assert capacity_brute(n,T,mr,gr-1,k)<A
            # Monetary lower bound: precisely required fresh checks and commits.
            floor=price_floor(A,T,k,Fraction(5,3),Fraction(7,4),Fraction(3,2),Fraction(9,4))
            if A>0:
                nominal = (Fraction(5,3)*max(0,A-k)+Fraction(7,4)*A+
                           Fraction(3,2)*mr+Fraction(9,4)*gr)/A
                assert floor==nominal
            purchased+=1
            digest.update(f'P|{n}|{T}|{k}|{A}|{mr}|{gr}|{floor}\n'.encode())
    # Decisive separation: average monitor budget covers all 3 deep checks,
    # but two-slot burst cannot meet 100% legitimate deadline availability.
    n,T,m,g,k=3,2,2,3,0
    assert capacity_brute(n,T,m,g,k)==2
    assert capacity_brute(n,T,3,g,k)==3
    assert minimum_installed_capacity(3,T,k)==(3,3)
    # Cache invalidation: a single invalidation can change feasibility exactly.
    assert robust_capacity(3,2,2,3,1,0)==3
    assert robust_capacity(3,2,2,3,1,1)==2
    print('cases',num,'capacity_infeasible_cases',impossible,'purchase_tests',purchased)
    print('decisive_example','3 safe actions, 2 deep slots, 3 guard slots, 2-tick deadline -> only 2 can be committed; 3 deep slots suffice')
    print('hash',digest.hexdigest())

if __name__=='__main__':main()
