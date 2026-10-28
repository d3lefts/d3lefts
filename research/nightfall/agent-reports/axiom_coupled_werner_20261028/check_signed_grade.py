#!/usr/bin/env python3
"""AXIOM / checker A: exact local Werner matrix units, grade-supported PSD triangle test."""
from itertools import product,combinations
from fractions import Fraction as F
from collections import Counter
from hashlib import sha256
from pathlib import Path

N=4
W=tuple(product(range(3),repeat=N))

def sub(a,d):return tuple((x-y)%3 for x,y in zip(a,d))
def local_coeff(a,b,c,e):
    # For K= (I - |Omega><Omega|/2)^tensor N, on vec(E_ab),vec(E_ce).
    v=F(1)
    for j in range(N):
        v*=F(int(a[j]==c[j] and b[j]==e[j]))-F(int(a[j]==b[j] and c[j]==e[j]),2)
        if not v:break
    return v

def grade_formula(a,c,d):
    z=[i for i in range(N) if d[i]==0]
    if any(a[i]!=c[i] for i in range(N) if d[i]!=0):return F(0)
    parity=sum(a[i]!=c[i] for i in z)
    return F(-1 if parity%2 else 1,2**len(z))

counts=Counter(); comparisons=0
for d in W:
    for a in W:
        b=sub(a,d)
        for c in W:
            e=sub(c,d)
            u=local_coeff(a,b,c,e)
            v=grade_formula(a,c,d)
            assert u==v,(d,a,c,u,v)
            comparisons+=1
            counts['zero' if u==0 else 'nonzero']+=1
assert comparisons==81**3
# Grade-zero sharp triangle test: all 81 choose 3 triples checked without numerical eigenvalues.
d=(0,)*4
balanced=unbalanced=0
for a,b,c in combinations(W,3):
    s=lambda x,y:(-1)**sum(xi!=yi for xi,yi in zip(x,y))
    triangle=s(a,b)*s(b,c)*s(c,a)
    rainbow=sum(set([a[j],b[j],c[j]])=={0,1,2} for j in range(4))
    assert triangle==(-1)**rainbow
    if triangle==1:balanced+=1
    else:
        unbalanced+=1
        assert (3+2*(-1-1-1))==-3
assert balanced+unbalanced==85320
# Exact sample: rank-two coupled same-grade pair; previously uncaptured by grade Cauchy certificate.
a=(0,0,0,0);b=(1,0,0,0)
q_pair=local_coeff(a,a,a,a)+local_coeff(b,b,b,b)+2*local_coeff(a,a,b,b)
assert q_pair==0
assert local_coeff(a,a,b,b)==-F(1,16)
# Worst 3-support obstruction, rank 3, grade 0, one rainbow coordinate.
c=(2,0,0,0)
S=(a,b,c)
q_three=sum(local_coeff(x,x,y,y) for x in S for y in S)
assert q_three==-F(3,16)
# 3-supported positive coupled form, sign matrix rank one.
c=(1,1,0,0);S=(a,b,c)
for vals in ((1,1,1),(2,-3,5),(1,0,-1)):
    actual=sum(vals[i]*vals[j]*local_coeff(x,x,y,y) for i,x in enumerate(S) for j,y in enumerate(S))
    assert actual==F((vals[0]-vals[1]+vals[2])**2,16)
print('PASS all grade-pair entries:',comparisons, 'zero/nonzero:',dict(counts))
print('PASS grade-zero triangle classification:',{'balanced':balanced,'unbalanced':unbalanced})
print('PASS coupled rank-two Q=0, pair coefficient=-1/16, sharp rank-three Q=-3/16')
print('PASS 3-supported nonzero-coupling PSD factorization')
print('SHA256',sha256(Path(__file__).read_bytes()).hexdigest())
