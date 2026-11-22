#!/usr/bin/env python3
"""Exact source-independent nonzero XOR equality Möbius audit.

Enumerates all 8**4 label quadruples in F2^3 including zero.
Uses arbitrary complex Gaussian-rational coefficients to test *grouped*
identities. Deliberately falsifies any asserted zero-frequency extension.
This is not a quantum operator-energy proof.
"""
from fractions import Fraction as F
from itertools import product, combinations
from collections import defaultdict

pairidx=tuple(combinations(range(4),2))
tripleidx=tuple(combinations(range(4),3))

def events(t):
    pair=sum(t[i]==t[j] for i,j in pairidx)
    triple=sum(t[i]==t[j]==t[k] for i,j,k in tripleidx)
    return int(pair>0),pair,triple

def add(lhs,rhs):
    return lhs[0]+rhs[0],lhs[1]+rhs[1]

def times(k,c):
    return k*c[0],k*c[1]

def coeff(t):
    a,b,c,d=t
    return (F(((3*a+5*b+7*c+11*d)%29)-14,11),
            F(((13*a+2*b+19*c+17*d)%31)-15,17))

def main():
    freqs=defaultdict(lambda: [(F(0),F(0)) for _ in range(3)])
    patterns=defaultdict(int)
    for t in product(range(8),repeat=4):
        z=t[0]^t[1]^t[2]^t[3]
        rep,pairs,triples=events(t)
        if z:
            assert rep==pairs-2*triples,(t,rep,pairs,triples)
            patterns[(pairs,triples)]+=1
        c=coeff(t)
        for j,mult in enumerate((rep,pairs,triples)):
            freqs[z][j]=add(freqs[z][j],times(mult,c))
    for z,(rep,pair,triple) in freqs.items():
        if z:
            assert rep==add(pair,times(-2,triple)),z
    assert patterns=={(0,0):1344,(1,0):2016,(3,1):224},patterns
    bad=(1,1,2,2)
    assert (bad[0]^bad[1]^bad[2]^bad[3])==0
    rep,pair,triple=events(bad)
    assert (rep,pair,triple)==(1,2,0)
    # Rational envelopes prove c <= 35 without approximate sqrt evaluation.
    assert 6*F(3,2)+8+4*(1+2*F(7,4))==35
    assert F(3,2)**2>2 and F(7,4)**2>3
    print("NONZERO_XOR_MOBIUS_EXACT_PASS: 3584 ordered tuples, 7 frequencies, complex rational grouping")
    print("ZERO_FREQUENCY_COUNTEREXAMPLE_PASS: aabb gives repetition=1, pair=2, triple=0")
    print("RATIONAL_CONSTANT_35_PASS")
if __name__=="__main__":
    main()
