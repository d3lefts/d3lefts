#!/usr/bin/env python3
"""Exact proof-attack against ℓ1(L2) gradient bound for the inverse degree operator.

Fourier coefficients are rational; n=2^k leaves, k fair address bits.
This disproves a sufficient auxiliary inequality, NOT the UE2 conjecture.
"""
from fractions import Fraction as F
from math import comb
from itertools import product


def address_leaf_budget_squared(k):
    return sum((F(comb(k,j),(j+1)**2) for j in range(k+1)),F(0))


def direct_spectral_small(k):
    assert k in (1,2,3)
    states=list(product((-1,1), repeat=k+2**k))
    leaves=list(product((-1,1),repeat=k))
    def f(x):
        a=x[:k]
        return x[k+leaves.index(a)]
    assert set(map(f,states))=={-1,1}
    coef={}
    for j,s in enumerate(leaves):
        for mask in range(2**k):
            # Walsh coefficient of monomial leaf[j]*prod_{a index in mask} A_a
            c=sum(F(f(x)*x[k+j]*int(__import__('math').prod(x[i] for i in range(k) if mask>>i&1)),len(states)) for x in states)
            assert abs(c)==F(1,2**k)
            coef[(j,mask)]=c
    leaf_square=[]
    for j,s in enumerate(leaves):
        v=sum((c*c/F((mask.bit_count()+1)**2) for (jj,mask),c in coef.items() if jj==j),F(0))
        leaf_square.append(v)
    assert len(set(leaf_square))==1
    got=(2**k)**2*leaf_square[0]
    assert got==address_leaf_budget_squared(k), (got,k)
    return got


def main():
    for k in (1,2,3):
        assert direct_spectral_small(k)==address_leaf_budget_squared(k)
        print('PASS independent whole-state Walsh audit, k=',k)
    s14=address_leaf_budget_squared(14)
    assert s14>15**2
    assert address_leaf_budget_squared(13)<14**2
    print('PASS exact rational: k=14, sum_j C(14,j)/(j+1)^2 >225, k=13 <196')
    print('Exact k=14 squared budget numerator/denominator:',s14)
    for k in (16,20,24,30):
        s=address_leaf_budget_squared(k)
        assert s>(k+1)**2
    # Standard actual source influences for f: leaf = 2^-k;
    # address = 1/2; V=1 and B=1.
    # Hence V²/(d² B² M) =2/(k+1)², never a UE2 counterexample.
    assert F(2,15**2)<1
    print('PASS auxiliary resolvent bridge falsified, original UE2 bound NOT falsified')

if __name__=='__main__':main()
