"""Verifier A: independent exact local-kernel Gram calculation.
Uses the explicit F3 affine code and local 2I-J kernel. No traces.
"""
from fractions import Fraction as F
from itertools import combinations,product
words=[(x,y,(x+y)%3,(x+2*y)%3) for x,y in product(range(3),repeat=2)]
assert len(set(words))==9
for a,b in combinations(words,2):
    assert sum(u!=v for u,v in zip(a,b))==3
K=[[F(1,16) if a==b else -F(1,16) for b in words] for a in words]
for r in range(1,10):
    expected=F(r*(2-r),16)
    for ind in combinations(range(9),r):
        v=sum(K[i][j] for i in ind for j in ind)
        assert v==expected,(r,ind,v,expected)
    print('PASS',r,'terms:',expected,'number of subsets',__import__('math').comb(9,r))
print('PASS: minimum negative rank on code-diagonal family = 3, with Q=-3/16')

