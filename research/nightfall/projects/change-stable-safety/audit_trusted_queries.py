"""Exhaustive optimal deterministic positive-receipt checking game.

Oracle: each query cost is paid, YES terminates, NO can occur at most k
times and any k distinct NO rows are achievable by some fixed update.
No randomization, manifest, or unchecked-output shortcut is allowed.
"""
from functools import lru_cache
from fractions import Fraction as F
from random import Random


@lru_cache(None)
def minimax(costs, failures_remaining):
    assert len(costs) >= failures_remaining + 1
    return min(cost + (minimax(costs[:i]+costs[i+1:], failures_remaining-1)
                       if failures_remaining else F(0))
               for i, cost in enumerate(costs))


rng=Random(66013)
for trial in range(10000):
    n=rng.randint(1,8)
    k=rng.randrange(n)
    costs=tuple(F(rng.randint(0,15),rng.choice((1,2,3))) for _ in range(n))
    exact=minimax(costs,k)
    closed=sum(sorted(costs)[:k+1],F(0))
    assert exact==closed,(costs,k,exact,closed)
print({'deterministic_positive_receipt_minimax_trials':10000,'all_passed':True})
