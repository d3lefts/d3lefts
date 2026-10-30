#!/usr/bin/env python3
"""GF(49^3) trace-zero Singer source, independent of frozen exponent list."""
from math import gcd
p=7; q=49; v=q*q+q+1
def plus(a,b):
    return ((a%7+b%7)%7)+7*((a//7+b//7)%7)
def minus(a):
    return (-a%7)+7*((-(a//7))%7)
def times(a,b):
    x,y=a%7,a//7; z,w=b%7,b//7
    return ((x*z-y*w)%7)+7*((x*w+y*z)%7)
def power(a,n):
    out=1
    while n:
        if n&1:out=times(out,a)
        a=times(a,a); n//=2
    return out
def add3(a,b):return tuple(plus(x,y) for x,y in zip(a,b))
# alpha satisfies X^3+(3+u)X^2+2=0 over GF(7)[u]/(u^2+1).
coeff=(2,0,10)
def mul3(a,b):
    z=[0]*5
    for i in range(3):
        for j in range(3): z[i+j]=plus(z[i+j],times(a[i],b[j]))
    for k in (4,3):
        for j in range(3): z[k-3+j]=plus(z[k-3+j],minus(times(z[k],coeff[j])))
    return tuple(z[:3])
def pow3(a,n):
    out=(1,0,0)
    while n:
        if n&1:out=mul3(out,a)
        a=mul3(a,a);n//=2
    return out
def singer():
    # A cubic over a finite field is irreducible iff it has no root.
    assert all(plus(plus(power(x,3),times(10,power(x,2))),2)!=0 for x in range(49))
    X=(0,1,0)
    assert pow3(X,v)[1:]==(0,0)
    for ell in (3,19,43):assert pow3(X,v//ell)[1:]!=(0,0)
    D=[];state=(1,0,0)
    for e in range(v):
        tr=add3(add3(state,pow3(state,q)),pow3(state,q*q))
        if tr==(0,0,0):D.append(e)
        state=mul3(state,X)
    assert state[1:]==(0,0) and len(D)==q+1
    differences={(x-y)%v for x in D for y in D if x!=y}
    assert len(differences)==v-1 and differences==set(range(1,v))
    return tuple(D)
if __name__=="__main__":
    print("PASS independently generated q=49 Singer source",singer())
