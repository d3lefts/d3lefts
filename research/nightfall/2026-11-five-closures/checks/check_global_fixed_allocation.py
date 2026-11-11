#!/usr/bin/env python3
"""Exact global nested-address fixed-budget optimization and convexity audit."""
from fractions import Fraction as Q

def g(m,s,c):
    K=m**s
    if c<=0:return Q(0)
    if c<=s+1:return Q(1,m**(2*s-c+1))
    return Q(min(K,c-s),K)

count=0
for m in range(2,6):
    for s in range(4):
        L=s+m**s
        if L>32:continue
        incr=[g(m,s,c)-g(m,s,c-1) for c in range(1,L+1)]
        assert incr==sorted(incr),(m,s,incr)
        for n in range(1,6):
            prev={0:Q(0)}
            for _ in range(n):
                cur={}
                for q,v in prev.items():
                    for c in range(L+1):
                        t=q+c
                        cur[t]=max(cur.get(t,Q(-1)),v+g(m,s,c))
                prev=cur
            for Qbudget in range(n*L+1):
                full,partial=divmod(Qbudget,L)
                assert prev[Qbudget]==full+g(m,s,partial)
                count+=1
print("PASS exact global allocation comparisons:",count)
print("PASS discrete convexity and concentration into full replicas")
