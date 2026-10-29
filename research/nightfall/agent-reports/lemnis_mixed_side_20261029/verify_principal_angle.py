#!/usr/bin/env python3
"""Independent exact physical partial-trace check of a nonorthogonal 2-block Werner witness."""
from itertools import product,combinations
from collections import defaultdict
from fractions import Fraction as F
from math import prod

def outer(u,v):
    return {(a,b):x*y for a,x in u.items() for b,y in v.items()}
def assemble(*X):
    C=defaultdict(int)
    for A in X:
        for key,x in A.items():C[key]+=x
    return {k:v for k,v in C.items() if v}
def trpartial(C,S,n):
    keep=tuple(j for j in range(n) if j not in S)
    out=defaultdict(int)
    for (a,b),x in C.items():
        if all(a[j]==b[j] for j in S):out[(tuple(a[j] for j in keep),tuple(b[j] for j in keep))]+=x
    return out
def cross(A,B,n,t):
    val=F(0)
    for s in range(n+1):
        for S in combinations(range(n),s):
            a,b=trpartial(A,S,n),trpartial(B,S,n)
            val+=(-t)**s *sum(x*b.get(k,0) for k,x in a.items())
    return val
def quad(C,n,t):return cross(C,C,n,t)
for n in [2,3,4,5]:
    q=6;t=F(2,5)
    zero=(0,)*n;one=(1,)*n
    u1={zero:1}
    u2={w:q**sum(w) for w in product(range(2),repeat=n)}
    v1={zero:1};v2={zero:1,one:1}
    X1,X2=outer(u1,v1),outer(u2,v2)
    C=assemble(X1,X2)
    full=quad(C,n,t)
    c=cross(X1,X2,n,t)
    diag=quad(X1,n,t)+quad(X2,n,t)
    assert full==diag+2*c
    # strict rank two because u2 and v2 each contain a nonzero coordinate outside zero
    assert len(C)>1
    mu_upper=F(1,6) # 1/sqrt(37) < 1/6
    L=(1-t)**n;M=t**n;E=(t+mu_upper)**n-M
    A1sq=F(1);A2sq=F((1+q*q)**n*2)
    # bound 2 A1A2 <= A1²+A2², so Q>= (L-M-E)*(A1²+A2²)
    margin=(L-M-E)*(A1sq+A2sq)
    assert margin>0 and full>=margin
    # cross beyond the globally orthogonal case: nonzero proper partial trace
    crossproper=c-(-t)**n*1*1
    assert crossproper!=0
    print('n',n,'nonzero proper-subset cross',crossproper,'Q',full,'certified lower',margin)
print('PASS: all tests are physical trace expansions, without use of operator-sector formula')
# Strict qutrit near-orthogonal class with three-level diagonal support.
# Row support of second block uses all ternary symbols; columns include an
# unbalanced three-diagonal triangle, so Axiom's ambient-PSD coordinate test fails.
n=4; q=5;t=F(2,5)
a=(0,0,0,0);b=(1,1,1,1);c=(2,2,2,0)
u1={a:1}; v1={a:1}
u2={w:q**sum(1 for z in w if z!=0) for w in product(range(3),repeat=n)}
v2={a:1,b:1,c:1}
XX1,XX2=outer(u1,v1),outer(u2,v2)
C=assemble(XX1,XX2)
QQ=quad(C,n,t)
cc=cross(XX1,XX2,n,t)
proper=cc-(-t)**n # traces of both blocks: Tr X1=1, Tr X2=1+q**4+q**3
proper=cc-(-t)**n*(1+q**4+q**3)
assert proper!=0
mu_upper=F(1,7)  # 1/sqrt(1+25+25)=1/sqrt51 < 1/7
L=(1-t)**n;M=t**n;E=(t+mu_upper)**n-M
A1sq=F(1);A2sq=F((1+2*q*q)**n *3)
margin=(L-M-E)*(A1sq+A2sq)
assert margin>0 and QQ>margin
# 3-word diagonal subspace fails ambient-coordinate PSD at endpoint
assert all((w,w) in C for w in [a,b,c])
from itertools import product as pd
vals=[]
for sb,sc in pd((-1,1),repeat=2):
    Z={(a,a):1,(b,b):sb,(c,c):sc}
    vals.append(quad(Z,n,F(1,2)))
assert min(vals)==F(-3,16)
print('strict qutrit n=4, with all 3 local row letters: nonzero proper cross',proper,'Q',QQ,'certified >',margin,'ambient-PSD forbidden')
