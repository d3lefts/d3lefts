#!/usr/bin/env python3
"""Exact global two-sided chance-constrained recertification LP example.

The optimization and dual certificate are verified using exact Fraction sums.
SciPy/HiGHS is an OPTIONAL independent numerical corroboration, NOT authority.
"""
from fractions import Fraction as F
from itertools import product,combinations
from functools import lru_cache
from collections import defaultdict
import json

# Exact joint distribution on latent safety S and noisy test Y (75% accurate).
worlds={(s,y):(F(3,8) if s==y else F(1,8)) for s,y in product((0,1),repeat=2)}
assert sum(worlds.values())==1
ACTIONS=('noisy','gold')
COST={'noisy':F(1),'gold':F(5)}
def observation(w,a):return w[1] if a=='noisy' else w[0]
def mass(h):return sum((p for w,p in worlds.items() if all(observation(w,a)==o for a,o in h)),F(0))
def unsafe(h):
    z=mass(h)
    return sum((p for w,p in worlds.items() if w[0]==0 and all(observation(w,a)==o for a,o in h)),F(0))/z

# Exact Lagrangian dual: cost + 16*(joint wrong decision probability) >= 5.
@lru_cache(None)
def lagrange(h):
    p=unsafe(h)
    options=[F(16)*p,F(16)*(1-p)]  # immediate authorize, deny
    for a in ACTIONS:
        if a in dict(h):continue
        outcome_sum=F(0)
        for o in (0,1):
            child=tuple(sorted(h+((a,o),)))
            if mass(child):outcome_sum+=(mass(child)/mass(h))*lagrange(child)
        options.append(COST[a]+outcome_sum)
    return min(options)
assert lagrange(())==F(5)

# Construct one optimal randomized policy: flip a fair private coin once.
# Heads: gold test and correct decision, cost 5. Tails: noisy test, classify
# directly from test outcome, cost 1 and misclassification probability 1/4.
# Therefore cost 3, and each conditional direction error 1/8.
coin=(F(1,2),F(1,2))
constructed_cost=coin[0]*COST['gold']+coin[1]*COST['noisy']
false_auth=coin[1]*F(1,4)
false_deny=coin[1]*F(1,4)
assert constructed_cost==3
assert false_auth==F(1,8) and false_deny==F(1,8)
# Our false_auth/deny above are *conditional* rates among unsafe/safe.
# Joint total mistake mass is 1/8, so the dual forces C>=5-16*(1/8)=3.
assert constructed_cost+16*F(1,8)==F(5)

# Full finite history flow-LP representation and exact verifier, conditional
# risk ≤ 1/8 given each true class (global rates, NOT per-history limits).
states=[()]
for k in (1,2):
    for subset in combinations(ACTIONS,k):
        for outcomes in product((0,1),repeat=k):
            h=tuple(sorted(zip(subset,outcomes)))
            if mass(h):states.append(h)
states=sorted(set(states),key=lambda h:(len(h),h))
variables=[(h,a) for h in states for a in ('authorize','deny')+tuple(t for t in ACTIONS if t not in dict(h))]
idx={v:i for i,v in enumerate(variables)}
E=[];rhs=[]
for h in states:
    row=[F(0)]*len(variables)
    for a in ('authorize','deny')+tuple(t for t in ACTIONS if t not in dict(h)):
        row[idx[(h,a)]]+=1
    for p,a in variables:
        if a not in ACTIONS or len(p)+1!=len(h):continue
        if a not in dict(h):continue
        if tuple(sorted(p+((a,dict(h)[a]),)))==h:
            row[idx[(p,a)]]-=mass(h)/mass(p)
    E.append(row);rhs.append(F(int(h==())))
U=[[F(0)]*len(variables) for _ in range(2)]
for (h,a),j in idx.items():
    if a=='authorize':U[0][j]=unsafe(h)
    if a=='deny':U[1][j]=1-unsafe(h)
B=[F(1,16),F(1,16)]
objective=[COST.get(a,F(0)) for h,a in variables]

# Exact hand primal occupancy (the branch reach-masses = 1/4).
plan={((), 'gold'):F(1,2),((), 'noisy'):F(1,2)}
for o in (0,1):
    plan[((('gold',o),), 'authorize' if o else 'deny')]=F(1,4)
    plan[((('noisy',o),), 'authorize' if o else 'deny')]=F(1,4)
x=[plan.get(v,F(0)) for v in variables]
assert all(z>=0 for z in x)
assert all(sum(r[j]*x[j] for j in range(len(x)))==v for r,v in zip(E,rhs))
assert all(sum(r[j]*x[j] for j in range(len(x)))<=v for r,v in zip(U,B))
assert sum(objective[j]*x[j] for j in range(len(x)))==F(3)
assert [sum(r[j]*x[j] for j in range(len(x))) for r in U]==B

# Independent brute-force enumeration of every deterministic contingent policy tree.
# Unlike the occupancy LP, no randomized choices are permitted.
@lru_cache(None)
def deterministic_policy_costs(h):
    from itertools import product as cartesian
    p=unsafe(h)
    items={(F(0),p,F(0)),(F(0),F(0),1-p)}
    for action in ACTIONS:
        if action in dict(h):continue
        nexts=[]
        for o in (0,1):
            child=tuple(sorted(h+((action,o),)))
            if mass(child):nexts.append((mass(child)/mass(h),deterministic_policy_costs(child)))
        for combo in cartesian(*(vals for _,vals in nexts)):
            cost=COST[action]+sum((weight*tuplev[0] for (weight,_),tuplev in zip(nexts,combo)),F(0))
            ea=sum((weight*tuplev[1] for (weight,_),tuplev in zip(nexts,combo)),F(0))
            ed=sum((weight*tuplev[2] for (weight,_),tuplev in zip(nexts,combo)),F(0))
            items.add((cost,ea,ed))
    return frozenset(items)

all_deterministic=deterministic_policy_costs(())
valid=[c for c,ea,ed in all_deterministic if ea<=F(1,16) and ed<=F(1,16)]
assert valid and min(valid)==F(5)

# Numeric solve is independently checked against the exact rational optimum.
try:
    from scipy.optimize import linprog as lp
    res=lp([float(v) for v in objective],A_eq=[[float(z) for z in row] for row in E],
        b_eq=[float(v) for v in rhs],A_ub=[[float(z) for z in row] for row in U],
        b_ub=[float(v) for v in B],bounds=(0,None),method='highs')
    assert res.success and abs(res.fun-3)<1e-9
    numerical='PASS'
except ImportError:
    numerical='not-installed; exact primal-dual still certified'

print(json.dumps({'status':'PASS','optimal_expected_cost':'3',
                   'deterministic_minimum_cost':'5', 'deterministic_policy_triples':len(all_deterministic),
                   'global_false_authorization_rate':'1/8',
                   'global_false_denial_rate':'1/8',
                   'exact_lagrange_dual_at_root':'5',
                   'occupancy_histories':len(states), 'occupancy_variables':len(variables),
                   'exact_occupancy_primal':'PASS','numeric_lp':numerical},sort_keys=True))
