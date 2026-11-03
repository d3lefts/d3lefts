#!/usr/bin/env python3
"""Exact q=25 Singer subfield embedding and collision triangle; stdlib only."""
from itertools import combinations
from collections import defaultdict
from math import gcd
p=5; f=(1,1,1,0,0,0) # x^6+x^2+x+1
one=(1,0,0,0,0,0); alpha=(1,3,0,0,0,0)
def plus(a,b):
    return tuple((x+y)%p for x,y in zip(a,b))
def mul(a,b):
    c=[0]*11
    for i in range(6):
        for j in range(6):
            c[i+j]=(c[i+j]+a[i]*b[j])%p
    for k in range(10,5,-1):
        t=c[k]
        for j in range(6):
            c[k-6+j]=(c[k-6+j]-t*f[j])%p
    return tuple(c[:6])
def power(x,n):
    y=one
    while n:
        if n&1:y=mul(y,x)
        x=mul(x,x);n//=2
    return y
assert power(alpha,15624)==one
assert all(power(alpha,15624//t)!=one for t in (2,3,7,31))
q=25;v=q*q+q+1;s=v//31
D=[];state=one
for e in range(v):
    trace=plus(plus(state,power(state,q)),power(state,q*q))
    if trace==(0,)*6:D.append(e)
    state=mul(state,alpha)
assert len(D)==26
assert sorted((a-b)%v for a in D for b in D if a!=b)==list(range(1,v))
sub=sorted(d//s for d in D if d%s==0)
assert sub==[1,5,17,22,23,25]
assert {((11*x+7)%31) for x in sub}=={0,1,3,8,12,18}
assert gcd(11,v)==1
Dnew=sorted((11*x+7*s)%v for x in D)
assert {x for x in Dnew if x%s==0}=={s*k for k in (0,1,3,8,12,18)}
cut=8*s;T=24*s;h=7*s;A=(s,2*s,4*s);N=max(A);L=h+N+1
assert h<v/4 and v-h>2*N and 2*L<v and v-h<=T<=v-(h+1)//2
Q=sorted((x-cut)%v for x in Dnew)
B=[T+x for x in Q]
assert all(k*s in Q for k in (0,4,10,23,24,26))
index={k:Q.index(k*s) for k in (0,4,10,23,24,26)}
triangle=(index[23],index[24],index[26])
F=list(A)+B;rep=defaultdict(list)
for i,a in enumerate(F):
    for j in range(i,len(F)):
        rep[a+F[j]].append((i,j))
edges=set();m=len(A)
for pairs in rep.values():
    for a,b in combinations(pairs,2):
        e=frozenset(i-m for i in (*a,*b) if i>=m)
        if e:edges.add(e)
assert all(frozenset(e) in edges for e in combinations(triangle,2))
a,b,c=triangle
M=[[int(x in edge) for x in triangle]
   for edge in ((a,b),(b,c),(a,c))]
det=(M[0][0]*(M[1][1]*M[2][2]-M[1][2]*M[2][1])
     -M[0][1]*(M[1][0]*M[2][2]-M[1][2]*M[2][0])
     +M[0][2]*(M[1][0]*M[2][1]-M[1][1]*M[2][0]))
assert abs(det)==2
print('PASS q=25 Singer exact difference set; all 650 nonzero differences')
print('PASS embedded q=5 Singer source; legal boundary geometry')
print('PASS triangle supports at indices',triangle,'; determinant',det)
