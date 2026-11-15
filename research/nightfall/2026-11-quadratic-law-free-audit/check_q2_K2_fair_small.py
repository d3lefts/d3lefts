#!/usr/bin/env python3
"""Exact exhaustive integer Walsh audit, all Boolean degree<=2 functions, n=1..4.
Only an exhaustive finite-small-domain check, NOT a universal inequality proof.
"""
from fractions import Fraction

def walsh(xs):
    a=list(xs)
    s=1
    while s<len(a):
        for i in range(0,len(a),2*s):
            for j in range(i,i+s):
                x,y=a[j],a[j+s]
                a[j],a[j+s]=x+y,x-y
        s*=2
    return a

def audit(n):
    N=1<<n
    count=0
    max_num,max_den=0,1
    for mask in range(1<<N):
        v=[1 if (mask>>j)&1 else -1 for j in range(N)]
        h=walsh(v)
        if any(h[S] for S in range(N) if S.bit_count()>2):
            continue
        count+=1
        V=N*N-h[0]*h[0]
        if V==0: continue
        infl=[sum(h[S]**2 for S in range(N) if S>>i&1) for i in range(n)]
        den=N*N*max(infl)
        num=V*V
        assert num<=2*den,(n,mask,num,den)
        if num*max_den>max_num*den:
            max_num,max_den=num,den
    return count,Fraction(max_num,max_den)

assert [audit(n) for n in range(1,5)]==[
    (4,Fraction(1)),(16,Fraction(9,8)),
    (70,Fraction(2)),(222,Fraction(2))]

# Exact 3-bit selector: f=(x1-x3-x1*x2-x2*x3)/2 in {-1,+1}.
v=[]
for mask in range(8):
    a,b,c=(1 if mask&(1<<k) else -1 for k in (2,1,0))
    z=(a-c-a*b-b*c)//2
    assert z in (-1,1)
    v.append(z)
h=walsh(v)
assert h[0]==0 and all(h[S]==0 for S in range(8) if S.bit_count()>2)
assert [sum(h[S]**2 for S in range(8) if S>>i&1) for i in range(3)]==[32]*3
print("PASS: exact K>=2 witness and all n<=4 fair Boolean degree<=2 checks")
