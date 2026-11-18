#!/usr/bin/env python3
"""Exact finite-law replay for all-degree derivative contraction hierarchy.

Uses Fraction throughout, direct 2^n-state sums, and genuine conditional
influences. Verifies each step of the Poincare/derivative recursion on several
signed Ising laws. These checks are NOT an all-n proof or a Lean kernel receipt.
"""
from fractions import Fraction as Q
from itertools import combinations
from math import factorial, prod

def spin(state, i):
    return 1 if state & (1 << i) else -1

def ising_law(n, edges):
    weights = {
        state: prod(Q(1) + t * spin(state, i) * spin(state, j)
                    for i, j, t in edges)
        for state in range(1 << n)
    }
    Z = sum(weights.values())
    law = {state: w / Z for state, w in weights.items()}
    assert sum(law.values()) == 1 and all(w > 0 for w in law.values())
    return law

def eval_poly(coeff, state):
    return sum(
        (a * prod(spin(state, i) for i in supp)
         for supp, a in coeff.items()), Q(0))

def derivative(coeff, site_set):
    sites = set(site_set)
    return {
        tuple(i for i in supp if i not in sites): a
        for supp, a in coeff.items()
        if sites.issubset(supp)
    }

def mean(law, coeff):
    return sum((p * eval_poly(coeff, x) for x, p in law.items()), Q(0))

def variance(law, coeff):
    m = mean(law, coeff)
    return sum((p * (eval_poly(coeff, x) - m)**2
                for x, p in law.items()), Q(0))

def influence(law, coeff, i):
    result = Q(0)
    for x, p in law.items():
        if not (x >> i) & 1:
            continue
        y = x ^ (1 << i)
        q = law[y]
        diff = eval_poly(coeff, x) - eval_poly(coeff, y)
        result += p*q/(p+q) * diff*diff
    return result

def hierarchy(law, coeff, n, A, degree=3):
    energies = []
    variances = []
    for k in range(degree+1):
        E_k = Q(0)
        V_k = Q(0)
        for S in combinations(range(n), k):
            der = derivative(coeff, S)
            expect = mean(law, der)
            v = variance(law, der)
            E_k += factorial(k)*expect*expect
            V_k += factorial(k)*v
            if k < degree:
                totalinf = sum((influence(law, der, i)
                                for i in range(n)), Q(0))
                assert v <= A*totalinf, ('Poincare', n, S, v, A*totalinf)
        energies.append(E_k)
        variances.append(V_k)
    assert variances[degree] == 0
    for k in range(degree):
        assert variances[k] <= A*(energies[k+1]+variances[k+1]), (
            'recursive bound', n, k)
    final = sum((A**k*energies[k] for k in range(1,degree+1)), Q(0))
    assert variances[0] <= final, ('hierarchy bound',n)
    return energies, variances, final

def test_signed():
    samples = [
        (4, [(0,1,Q(1,7)), (1,2,Q(-1,8)), (2,3,Q(1,9)), (3,0,Q(1,10))]),
        (5, [(0,1,Q(-1,10)), (1,2,Q(1,11)), (2,3,Q(-1,12)),
             (3,4,Q(1,13)), (4,0,Q(-1,14)), (0,2,Q(1,15))]),
    ]
    for n, edges in samples:
        alpha = max(sum((abs(t) for i,j,t in edges if site in (i,j)), Q(0))
                    for site in range(n))
        assert alpha < 1
        law = ising_law(n, edges)
        A = 1/(1-alpha)
        for trial in range(4):
            coeff = {}
            for k in range(1,4):
                for S in combinations(range(n),k):
                    coeff[S] = Q(((17*trial + sum(S)*11 + k*7) % 17)-8, 31)
            energies, variances, rhs = hierarchy(law, coeff, n, A)
            print('PASS signed',n,'trial',trial,'Var',variances[0],
                  'bound',rhs,'contracted-grad',energies[1])

def test_chain_cubic():
    r = Q(1,3)
    for k in (2,3,4,5,6):
        n = k+2
        edges = [(i,i+1,r) for i in range(n-1)]
        law = ising_law(n, edges)
        A = 1/(1-2*r)
        coeff = {(0,j,j+1): Q(1,k) for j in range(1,k+1)}
        energies, var_levels, bound = hierarchy(law, coeff, n, A)
        expected = r*r + (1-r*r)/k
        assert var_levels[0] == expected, (k,var_levels[0],expected)
        assert var_levels[0] * k == 1 + (k-1)*r*r
        # Law-adapted Wick correction: cancel every mean first derivative.
        correction = {
            (i,): -sum(
                (a * mean(law, {tuple(j for j in supp if j!=i): Q(1)})
                 for supp,a in coeff.items() if i in supp), Q(0))
            for i in range(n)
        }
        corrected = dict(coeff)
        corrected.update(correction)
        cent_E, cent_V, cent_bound = hierarchy(law, corrected, n, A)
        assert cent_E[1] == 0
        assert cent_E[2] == 0  # zero spin means, pure cubic top sector
        assert cent_bound == 6*A**3/k
        print('PASS cubic k',k,'uncorrected Var',expected,
              'reference Var',Q(1,k),'contracted E1',energies[1],
              'corrected Var',cent_V[0],'corrected upper',cent_bound)

if __name__ == '__main__':
    test_signed()
    test_chain_cubic()
    print('PASS exact derivative hierarchy and contraction negative controls')
