"""Alternative exact dynamic-programming audit of synthetic design cost.
Reads the stated model from finite_costs but does not use its search or its result.
"""
from finite_costs import OPTIONS,THRESH
from fractions import Fraction as F
from json import loads
from pathlib import Path
# State tuple is bounded scores and exact min cost, updated one option at a time.
dp={(0,0,0,0):F(0)}
for name,cost,gains in OPTIONS:
    new=dict(dp)
    for scores,previous_cost in dp.items():
        after=tuple(min(cap,s+gain) for cap,s,gain in zip(THRESH,scores,gains))
        proposed=previous_cost+cost
        if after not in new or proposed < new[after]:
            new[after]=proposed
    dp=new
assert THRESH in dp
receipt=loads(Path(__file__).with_name('cost_receipt.json').read_text())
assert dp[THRESH]==F(receipt['optimal_synthetic_cost'])
print('Independent exact DP: optimum =', dp[THRESH],'; reachable capped states =',len(dp),'; matches enumeration')
