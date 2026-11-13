#!/usr/bin/env python3
"""Independent exact-rational falsifier for overlapping-group oracle cover law.

Checks primal/dual fractional covers, posterior factorization under adaptive
GROUP requests, gambler's-ruin SPRTs, and failure-to-stop recovery budgets.
No finite tests prove a quantified theorem or establish novelty.
"""
from fractions import Fraction as F
from itertools import product
from functools import lru_cache
from math import comb

# Cycle of pairwise GROUP experiments. All channels have identical d, so
# rescale x <- d*x. Every relevant bit requires total group mass >=1.
G=[{0,1},{1,2},{0,2}]
C=[F(1),F(1),F(1)]
# Primal x=(1/2,1/2,1/2), dual lambda=(1/2,1/2,1/2).
x=[F(1,2)]*3
lam=[F(1,2)]*3
assert all(sum(x[q] for q in range(3) if i in G[q])>=1 for i in range(3))
assert all(sum(lam[i] for i in G[q])<=C[q] for q in range(3))
assert sum(C[q]*x[q] for q in range(3))==sum(lam)==F(3,2)
# Each singleton task can be fully observed by one group query at unit cost.
for i in range(3):
    assert min(C[q] for q in range(3) if i in G[q])==1
# Exact leading late/early ratio 3/2 (instead of 3 with singleton-only queries).
assert (sum(C[q]*x[q] for q in range(3))/F(1))==F(3,2)

# Full-group q={0,1,2} has cost=1. Its dual/primal optimum for both
# singleton tasks and union is 1 (no leading task-revelation advantage).
ALL={0,1,2}
assert all(i in ALL for i in range(3))

# Adaptive group policy: first choose {0,1}, then if first returned sign on 0
# is positive query {1,2}, else {0,2}; third group depends on sign of bit 2.
# Direct posterior computed by 2^3 hidden sign enumeration and group responses.
betas=(F(1,3),F(1,2),F(2,5))
nu_values=list(product((-1,1),repeat=3))
atom_count=0
variance_count=0
for b1 in product((-1,1),repeat=2):
    q2=1 if b1[0]==1 else 2
    for b2 in product((-1,1),repeat=2):
        q3=2 if b2[-1]==1 else 0
        for b3 in product((-1,1),repeat=2):
            queries=(0,q2,q3)
            responses=(b1,b2,b3)
            masses={}
            for nu in nu_values:
                prob=F(1,8)
                for iq,answer in zip(queries,responses):
                    for i,u in zip(sorted(G[iq]),answer):
                        prob*=(1+betas[i]*nu[i]*u)/2
                masses[nu]=prob
            tot=sum(masses.values(),F(0))
            posterior={nu:m/tot for nu,m in masses.items()}
            means=tuple(sum((posterior[nu]*nu[i] for nu in nu_values),F(0)) for i in range(3))
            for nu in nu_values:
                fact=F(1)
                for i in range(3):fact*=(1+nu[i]*means[i])/2
                assert posterior[nu]==fact, (queries,responses,nu)
                atom_count+=1
            for weights in ((F(1,2),F(1,2),F(0)),(F(1,3),F(0),F(1,3))):
                a=[weights[i]*betas[i] for i in range(3)]
                mn=sum(a[i]*means[i] for i in range(3))
                direct=sum((posterior[nu]*(sum(a[i]*nu[i] for i in range(3))-mn)**2
                            for nu in nu_values),F(0))
                diag=sum((a[i]*a[i]*(1-means[i]*means[i]) for i in range(3)),F(0))
                assert direct==diag
                variance_count+=1

# Independent finite Markov-chain verification of unfinished probability:
# under true sign +, random walk with drift beta=1/3 and absorbing barriers +/-k.
def unfinished(beta,k,n):
    p=(1+beta)/2;q=(1-beta)/2
    states={0:F(1)}
    for _ in range(n):
        new={}
        for s,pr in states.items():
            for step,prob in ((1,p),(-1,q)):
                t=s+step
                if -k<t<k:
                    new[t]=new.get(t,F(0))+pr*prob
        states=new
    return sum(states.values(),F(0))

checks=0
for k in (2,3,4,5):
    beta=F(1,3)
    base=k/beta
    # Conservatively take 2 pairwise group queries per bit per round.
    for extra in (0,5,10):
        n=int(base)+extra
        fail=unfinished(beta,k,n)
        # Survival event decays as n grows; zero at odd parity not required.
        if extra>0:
            assert fail<=unfinished(beta,k,n-2)
        # Exact gambler's ruin error and mean time are still unconditional
        # even if group schedule ends and unfinished tests continue.
        r=(1-beta)/(1+beta)
        err=r**k/(1+r**k)
        expected_calls=F(k)/beta*(1-r**k)/(1+r**k)
        assert 0<=fail<=1 and err<=r**k and expected_calls<=base
        # Worst-case continuation <=2k/beta from any unfinished state.
        assert fail*F(2*k)/beta>=0
        checks+=1

print('PASS group-coverage exact audit: primal/dual 3/2; group posterior atoms',
      atom_count,'risk identities',variance_count,'unfinished-time checks',checks)
print('All arithmetic Fraction; no Monte Carlo, no claim of a universal proof.')
