#!/usr/bin/env python3
"""NIGHTFALL permission capacity: exact finite two-stage batch theorem.
All actions arrive at first slot; fresh perfect inspection takes one slot,
permission guard can commit only from a prior-slot inspection or valid cache.
Homogeneous independent slots and per-slot capacities. No simulator of agents.
"""
from __future__ import annotations
from functools import lru_cache
from fractions import Fraction
from math import ceil


def capacity_formula(n: int, T: int, m: int, g: int, k: int) -> int:
    assert n >= 0 and T >= 1 and m >= 0 and g >= 0 and 0 <= k <= n
    if T == 1:
        return min(n, k, g)
    return min(n, g*T, k + g*(T-1), k + m*(T-1))


def capacity_greedy(n: int, T: int, m: int, g: int, k: int):
    """Concrete schedule; new inspections are usable only in the next slot."""
    ready, done = k, 0
    schedule=[]
    for t in range(1,T+1):
        admitted = min(g,ready)
        ready -= admitted
        done += admitted
        inspect = min(m, n - done - ready) if t<T else 0
        schedule.append({'slot':t, 'deep_inspections':inspect,
                         'guard_commits':admitted, 'ready_at_start':ready+admitted})
        ready += inspect
    assert done == capacity_formula(n,T,m,g,k)
    return done, schedule


def capacity_brute(n: int, T: int, m: int, g: int, k: int) -> int:
    """Independent exhaustive search of all choices of inspections and commits.
    Does not call the formula or greedy constructor.
    """
    assert 0<=k<=n and T>=1
    @lru_cache(None)
    def solve(t,ready,done):
        if t>T:return done
        best=done
        for committed in range(min(g,ready,n-done)+1):
            left=ready-committed
            examined_max=min(m,n-(done+committed)-left) if t<T else 0
            for inspected in range(examined_max+1):
                score=solve(t+1,left+inspected,done+committed)
                if score>best:best=score
        return best
    return solve(1,k,0)


def minimum_installed_capacity(A:int,T:int,k:int):
    assert A>=0 and T>=2 and 0<=k
    extra=max(0,A-k)
    m_req=ceil(extra/(T-1))
    g_req=max(ceil(A/T),ceil(extra/(T-1)))
    return m_req,g_req


def price_floor(A,T,k,unit_deep,unit_guard,fixed_deep=0,fixed_guard=0):
    """All-safe batch. Fixed/setup capacity paid once, variable check/guard cost."""
    if A<=0:return None
    m_req,g_req=minimum_installed_capacity(A,T,k)
    total=(Fraction(unit_deep)*max(A-k,0)+Fraction(unit_guard)*A+
           Fraction(fixed_deep)*m_req+Fraction(fixed_guard)*g_req)
    return total/Fraction(A)


def robust_capacity(n,T,m,g,k0,invalidation_budget):
    assert 0<=invalidation_budget<=k0<=n
    return capacity_formula(n,T,m,g,k0-invalidation_budget)

if __name__=='__main__':
    n,T,m,g,k = 3,2,2,3,0
    count,schedule = capacity_greedy(n,T,m,g,k)
    print({'capacity':count,'schedule':schedule,'min_installed_for_all_three':minimum_installed_capacity(3,T,k),'unit_price_with_unit_costs':str(price_floor(3,T,k,1,1))})
