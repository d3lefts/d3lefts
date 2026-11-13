"""Exact enumeration of the fixed-adversary randomized query-order theorem.

Enumerates all failure sets of size k and all n! orders, n <= 7, with exact
fractions. This is finite falsification, not a substitute for the analytic
negative-hypergeometric proof or an external novelty review.
"""
from itertools import combinations, permutations
from fractions import Fraction as F
from math import factorial

counts=0
for n in range(1,8):
    for k in range(n):
        expected=F(n+1,n-k+1)
        for bad in combinations(range(n),k):
            unavailable=set(bad)
            steps=0
            for order in permutations(range(n)):
                steps+=next(j+1 for j,item in enumerate(order)
                            if item not in unavailable)
            observed=F(steps,factorial(n))
            assert observed==expected,(n,k,bad,observed,expected)
            counts+=1
print({'fixed_failure_sets_and_permutations':counts,'all_passed':True})
