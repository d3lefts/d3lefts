#!/usr/bin/env python3
"""Independent exhaustive slot/action scheduler; exact integer arithmetic.
Uses neither the claimed price formula nor the analytic mode counts in its oracle.
We distinguish left and right readings, allow simultaneous pairs, and allow
wasteful read-then-direct paths to detect hidden schedule assumptions.
"""
from itertools import product, combinations
from functools import lru_cache
from hashlib import sha256
from fractions import Fraction

# 0 unread, 1 left-read, 2 right-read, 3 both-read, 4 direct-read, 5 valid cached.
OPTIONS={
  0:((0,0,0),(1,1,'cheap'),(2,1,'cheap'),(3,2,'pair'),(4,1,'deep')),
  1:((1,0,0),(3,1,'cheap'),(4,1,'deep')),
  2:((2,0,0),(3,1,'cheap'),(4,1,'deep')),
  3:((3,0,0),),4:((4,0,0),),5:((5,0,0),)
}

def exhaustive_schedule(statuses,H,m,c,d):
    assert 0<=m and H>=1 and c>0 and d>2*c
    start=tuple(sorted(statuses))
    inf=10**9
    @lru_cache(None)
    def dp(t,status):
        if t==H:
            return 0 if all(s>=3 for s in status) else inf
        best=inf
        for choices in product(*(OPTIONS[s] for s in status)):
            work=sum(j[1] for j in choices)
            if work>m:continue
            charge=sum((0 if j[2]==0 else 2*c if j[2]=='pair' else c if j[2]=='cheap' else d) for j in choices)
            next_state=tuple(sorted(j[0] for j in choices))
            value=charge+dp(t+1,next_state)
            if value<best:best=value
        return best
    value=dp(0,start)
    return None if value==inf else value

def fail_closed_audit():
    from price_exact import price, optimized
    digest=sha256()
    checked=0;infeasible=0; optimized_checks=0
    for N in range(1,5):
      for H in range(1,4):
       for m in range(0,5):
        for K0 in range(N+1):
         for B in range(K0+1):
          # Actual identities of up to B invalidated caches are adversarial.
          # Exhaust cache-set and invalidation-set, not just their cardinalities.
          costs=[]
          for original in combinations(range(N),K0):
           for victims in combinations(original,B):
            status=tuple(5 if i in original and i not in victims else 0 for i in range(N))
            costs.append(exhaustive_schedule(status,H,m,1,5))
          assert len(set(costs))==1, (N,H,m,K0,B,costs)
          brute=costs[0]
          analytic=price(N,K0,B,H,m,N,1,5)
          exact=None if analytic is None else int(analytic['cost'])
          assert brute==exact,(N,H,m,K0,B,brute,exact)
          checked+=1
          if brute is None:infeasible+=1
          digest.update(f'{N}|{H}|{m}|{K0}|{B}|{brute}\n'.encode())
    # separately exhaustive integer optimize facility quantity with varying costs;
    # no use of the analytic optimized() inside the brute oracle.
    for N,H,K0,B,F in product(range(1,5),range(1,4),range(0,3),range(0,3),range(0,8)):
        if K0>N or B>K0:continue
        costs=[]
        for m in range(0,2*N+1):
            v=exhaustive_schedule(tuple([5]*(K0-B)+[0]*(N-K0+B)),H,m,1,5)
            if v is not None:costs.append((F*m+v,m))
        brute=min(v[0] for v in costs)
        analytic=optimized(N,K0,B,H,1,5,F,0,0)
        assert brute==analytic[0],(N,H,K0,B,F,brute,analytic)
        optimized_checks+=1
        digest.update(f'opt|{N}|{H}|{K0}|{B}|{F}|{brute}\n'.encode())
    # Modular task: one coordinate alone carries zero predictive information;
    # a paired observation or direct predicate test distinguishes every outcome.
    worlds=0
    for r in range(2,14):
        for a in range(r):
            results={(a+b)%r==0 for b in range(r)}
            assert results == {False,True}
        for b in range(r):
            results={(a+b)%r==0 for a in range(r)}
            assert results == {False,True}
        for a,b in product(range(r),repeat=2):
            worlds+=1
            assert ((a+b)%r==0)==(a==(-b)%r)
    return {'slot_cases':checked,'slot_infeasible':infeasible,'facility_checks':optimized_checks,'modular_worlds':worlds,'sha256':digest.hexdigest()}

if __name__=='__main__':
    print(fail_closed_audit())
