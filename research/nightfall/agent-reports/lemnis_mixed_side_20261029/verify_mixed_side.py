#!/usr/bin/env python3
"""Independent exact physical partial traces; mixed-side orthogonality, rank-2, 4 sites."""
from itertools import product,combinations
from collections import defaultdict
from fractions import Fraction as F

def tensor(*vs):
    v={():1}
    for item in vs:
        v={w+(k,):c*x for w,c in v.items() for k,x in item.items() if c*x}
    return v

def outer(u,v):return {(a,b):x*y for a,x in u.items() for b,y in v.items()}
def reduced(X,S,n):
    R=tuple(j for j in range(n) if j not in S)
    ret=defaultdict(int)
    for (a,b),x in X.items():
        if all(a[j]==b[j] for j in S):
            ret[(tuple(a[j] for j in R),tuple(b[j] for j in R))]+=x
    return ret

def trbilin(X,Y,S,n):
    a,b=reduced(X,S,n),reduced(Y,S,n)
    return sum(x*b.get(k,0) for k,x in a.items())
def Qpair(X,Y,n,t):
    return sum((-t)**len(S)*trbilin(X,Y,S,n)
               for z in range(n+1) for S in combinations(range(n),z))
zero={0:1};one={1:1}; plus={0:1,1:1}
u1=tensor(zero,plus,zero,plus)
u2=tensor(one,plus,one,plus)
v1=tensor(plus,zero,plus,zero)
v2=tensor(plus,one,plus,one)
X1=outer(u1,v1);X2=outer(u2,v2)
t=F(1,2);n=4
for z in range(n):
    S=tuple(i for i in range(n) if i!=z)
    assert trbilin(X1,X2,S,n)==0
proper=[]
for z in range(n):
    for S in combinations(range(n),z):
        val=trbilin(X1,X2,S,n)
        assert val==0,(S,val)
        proper.append(val)
full=trbilin(X1,X2,tuple(range(n)),n)
assert full==1
cross=Qpair(X1,X2,n,t)
assert cross==F(1,16)
q1=Qpair(X1,X1,n,t);q2=Qpair(X2,X2,n,t)
Q=q1+q2+2*cross
assert Q>0
# rank2: left factors independent because disjoint at site1; right factors independent because disjoint at site2
# row span has common + factor on sites 2,4; column span has common + on sites1,3.
print('PASS one-sided theorem excluded by row/column span local intersection; mixed-side admissible')
print('q1',q1,'q2',q2,'cross',cross,'Q',Q,'uniform lower',(F(1,2)**4)*32+2*cross)
# rank-2 negative at t>1/2 using all-left-orth example (subclass) ensures sharpness.
# Analyze site-dependent balanced t=(1/4,1/3,1/2,2/3)
T=[F(1,4),F(1,3),F(1,2),F(2,3)]
def Hpair(X,Y,ts):
    return sum(F((-1)**len(S))*(__import__('math').prod((ts[j] for j in S))) *trbilin(X,Y,S,n)
            for z in range(n+1) for S in combinations(range(n),z))
q=Hpair(X1,X1,T)+Hpair(X2,X2,T)+2*Hpair(X1,X2,T)
assert Hpair(X1,X2,T)==__import__('math').prod(T)
print('heterogeneous exact Q',q,'cross',Hpair(X1,X2,T))
# New d=3, four-site witness with binary cube + 2222 diagonal rainbow obstruction.
# row-orthogonal at 0,2, column-orthogonal at 1,3.
triple={0:1,1:1,2:1}; binary={0:1,1:1}; last={2:1}
UU1=tensor(binary,triple,binary,triple)
UU2=tensor(last,triple,last,triple)
VV1=tensor(triple,binary,triple,binary)
VV2=tensor(triple,last,triple,last)
YY1=outer(UU1,VV1);YY2=outer(UU2,VV2)
q1=Qpair(YY1,YY1,4,F(1,2));q2=Qpair(YY2,YY2,4,F(1,2))
xc=Qpair(YY1,YY2,4,F(1,2))
assert xc==1,(xc,q1,q2)
assert q1+q2-2*xc > 0
assert all(trbilin(YY1,YY2,S,4)==0 for z in range(4) for S in combinations(range(4),z))
print('d3, n4 strict mixed-side: Q1',q1,'Q2',q2,'cross',xc,'Q with adverse sign',q1+q2-2*xc)
# Exact rank-three unbalanced triple which disproves ambient-coordinate PSD of support.
a=(0,0,0,0);b=(0,1,0,0);c=(2,2,2,2)
assert (a,a) in YY1 and (b,b) in YY1 and (c,c) in YY2
neg=outer({a:1},{a:1});neg.update(outer({b:1},{b:1}));neg.update(outer({c:-1},{c:1}))
# Determine phases making two cross contributions negative, since our triangle odd.
from itertools import product
values=[]
for sb,sc in product((-1,1),repeat=2):
    Z={(a,a):1,(b,b):sb,(c,c):sc}
    q=sum((F(-1,2)**len(S))*sum(z*z for z in reduced(Z,S,4).values()) for zsize in range(5) for S in combinations(range(4),zsize))
    values.append((q,sb,sc))
small=min(values)
assert small[0]==F(-3,16),values
print('ambient PSD exclusion triple',small)
# Sharp scope falsifier: global row/column orthogonality without sitewise
# complementarity is insufficient, even with L > M.
Z={( (0,0),(0,0)):1,((1,0),(1,0)):1}
def dq(C,t):
    n=len(next(iter(C))[0]);from itertools import combinations
    return sum((-1)**len(S)*(__import__('math').prod(t[j] for j in S))*sum(abs(x)**2 for x in reduced(C,S,n).values()) for z in range(n+1) for S in combinations(range(n),z))
assert dq(Z,[F(3,4),F(1,10)])==F(-9,10)
assert (1-F(3,4))*(1-F(1,10)) >= F(3,4)*F(1,10)
print('scope falsifier Q=-9/10 with L>=M but one site shares both sides PASS')
