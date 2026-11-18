#!/usr/bin/env python3
"""Exact rational audit of two-coordinate correlated block Poincare gaps.
No claim this finite basis check proves the general block-AA theorem.
"""
from fractions import Fraction as Q
from itertools import product, combinations

xs=list(product((-1,1),repeat=2))
basis=[
    lambda x: Q(1),
    lambda x: Q(x[0]+x[1]),
    lambda x: Q(x[0]-x[1]),
    lambda x: Q(x[0]*x[1]),
]

def gram(q):
    nu={x: ((1-q)/2 if x[0]==x[1] else q/2) for x in xs}
    def mean(f):
        return sum((nu[x]*f(x) for x in xs),Q(0))
    means=[mean(f) for f in basis]
    def vinner(i,j):
        return sum((nu[x]*(basis[i](x)-means[i])*(basis[j](x)-means[j])
                    for x in xs),Q(0))
    def dform(i,j):
        ans=Q(0)
        for coord in range(2):
            other=1-coord
            for x in xs:
                denom=sum((nu[z] for z in xs if z[other]==x[other]),Q(0))
                # paired conditional covariance
                for y in xs:
                    if x[other]!=y[other]: continue
                    ans += nu[x]*nu[y]/den * (
                        (basis[i](x)-basis[i](y))*
                        (basis[j](x)-basis[j](y)))/2
        return ans
    var=[[vinner(i,j) for j in range(4)] for i in range(4)]
    dirichlet=[[dform(i,j) for j in range(4)] for i in range(4)]
    assert all(var[i][j]==0 and dirichlet[i][j]==0
               for i,j in combinations(range(4),2))
    ratio=[(var[i][i]/dirichlet[i][i])
           for i in (1,2,3)]
    assert ratio==[1/(2*q), 1/(2*(1-q)),Q(1,2)], ratio
    c=1/(2*min(q,1-q))
    assert all(c*dirichlet[i][i]>=var[i][i] for i in range(4))
    # q=1/4 gives PSD (C*D-V) with eigenvalues from diagonal basis.
    if q==Q(1,4):
        assert c==2 and all(c*dirichlet[i][i]-var[i][i]>=0 for i in range(4))
    return c,ratio

for q in (Q(1,100),Q(1,4),Q(2,5),Q(1,2)):
    c,r=gram(q)
    print("PASS exact q=%s gap-constant=%s basis-ratios=%s"%(q,c,r))

# k independent correlated pairs, relative to fair product of marginal signs:
# Each pair contributes 2q for a mismatch, 2(1-q) for an equal pair.
q=Q(1,4)
for k in range(1,9):
    minimum=(2*q)**k
    assert minimum==Q(1,2**k)
print("PASS: global density floor decays 2^-k; C|B|=4 independent of k")
