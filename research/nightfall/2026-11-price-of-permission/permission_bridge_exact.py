#!/usr/bin/env python3
"""NIGHTFALL exact independent small-model audit of influence vs. information vs.
permission, including a one-coordinate law replacement and strict pointwise
versus source-support distinction. Finite regression only; not a general proof.

Standard library only. Deterministic, ordered Fraction/integer receipt.
"""
from fractions import Fraction as Q
from itertools import product
from hashlib import sha256


def mission(t, a, r):
    return int((t + a) % r == 0)


def certifies_all_safe(r, queries, allowed_t):
    """Every safe state distinguishable from every unsafe state on queried outputs."""
    for t0, a0 in product(allowed_t, range(r)):
        if mission(t0, a0, r) != 1:
            continue
        for t, a in product(allowed_t, range(r)):
            if mission(t, a, r) == 1:
                continue
            outputs_match = all(
                (t0 == t if q == 'T' else
                 a0 == a if q == 'A' else
                 mission(t0, a0, r) == mission(t, a, r))
                for q in queries
            )
            if outputs_match:
                return False
    return True


def first_source_moments(r):
    # Both marginals uniform, exact first/second moments and ES influences.
    vals = [Q(mission(t, a, r)) for t, a in product(range(r), repeat=2)]
    mean = sum(vals, Q(0)) / (r*r)
    var = sum((x - mean)**2 for x in vals) / (r*r)
    influence_T = Q(0)
    influence_A = Q(0)
    for a in range(r):
        row = [Q(mission(t,a,r)) for t in range(r)]
        avg = sum(row)/r
        influence_T += sum((x-avg)**2 for x in row) / (r*r)
    for t in range(r):
        row = [Q(mission(t,a,r)) for a in range(r)]
        avg = sum(row)/r
        influence_A += sum((x-avg)**2 for x in row) / (r*r)
    return mean, var, influence_T, influence_A


def second_source_moments(r):
    # T=0 with probability one, A uniform. Genuine source-based influences.
    mean = sum((Q(mission(0,a,r)) for a in range(r)), Q(0))/r
    var = sum((Q(mission(0,a,r))-mean)**2 for a in range(r))/r
    influence_T = Q(0)
    influence_A = var
    # Pointwise new-law pair projector h_TA^q(t,a)=f(t,a)-f(0,a).
    pair_is_nonzero = any(mission(t,a,r)-mission(0,a,r) for t,a in product(range(r),repeat=2))
    return mean,var,influence_T,influence_A,pair_is_nonzero


def main():
    receipt = sha256()
    checked = 0
    for r in range(2,16):
        mean, var, it, ia = first_source_moments(r)
        assert (mean,var,it,ia) == (Q(1,r),Q(r-1,r*r),Q(r-1,r*r),Q(r-1,r*r))
        assert all(sum(mission(t,a,r) for a in range(r))==1 for t in range(r))
        assert all(sum(mission(t,a,r) for t in range(r))==1 for a in range(r))
        # K itself is individually uniform given either input; jointly determined.
        assert all({(t+a)%r for a in range(r)} == set(range(r)) for t in range(r))
        assert not certifies_all_safe(r,(),range(r))
        assert not certifies_all_safe(r,('T',),range(r))
        assert not certifies_all_safe(r,('A',),range(r))
        assert certifies_all_safe(r,('T','A'),range(r))
        assert certifies_all_safe(r,('D',),range(r))
        new_mean,new_var,new_it,new_ia,nonzero = second_source_moments(r)
        assert (new_mean,new_var,new_it,new_ia,nonzero)==(mean,var,Q(0),var,True)
        assert certifies_all_safe(r,('A',),(0,))
        assert not certifies_all_safe(r,('A',),range(r))
        for cT,cA,cD,cG in product(range(1,5),repeat=4):
            achievable=[]
            for selected in product((0,1),repeat=3):
                queries=tuple(q for q,enabled in zip(('T','A','D'),selected) if enabled)
                if certifies_all_safe(r,queries,range(r)):
                    cost=cG+sum(c for c,flag in zip((cT,cA,cD),selected) if flag)
                    achievable.append(cost)
            brute=min(achievable)
            formula=cG+min(cT+cA,cD)
            assert brute == formula,(r,cT,cA,cD,cG,brute,formula)
            checked+=1
            receipt.update(f'{r}|{cT}|{cA}|{cD}|{cG}|{brute}\n'.encode())
    print('status PASS')
    print('independent cost configurations',checked)
    print('r range 2..15')
    print('sha256',receipt.hexdigest())

if __name__=='__main__':main()
