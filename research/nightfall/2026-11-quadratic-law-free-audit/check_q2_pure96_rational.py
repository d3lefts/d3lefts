#!/usr/bin/env python3
"""Exact algebra audit of the restricted original-source Q2 C<96 candidate.

Proves formal polynomial/algebra identities, NOT source probability premises
nor an end-to-end Lean theorem. Python standard library only.
"""
from fractions import Fraction as F
from decimal import Decimal, getcontext

# Numbers a+b*tau in Q[tau]/(tau^2+tau-1),
# where tau=(sqrt(5)-1)/2.
def add(a,b): return a[0]+b[0], a[1]+b[1]
def neg(a): return -a[0],-a[1]
def sub(a,b): return add(a,neg(b))
def mul(a,b):
    x,y=a;u,v=b
    return (x*u+y*v, x*v+y*u-y*v)
def power(a,n):
    out=(F(1),F(0))
    for _ in range(n): out=mul(out,a)
    return out
def val(x): return (F(x),F(0))
tau=(F(0),F(1));one=val(1)
assert power(tau,2)==sub(one,tau)
assert power(tau,5)==sub(mul(val(5),tau),val(3))
gamma_sq=mul(power(tau,5),val(F(1,3)))

def psum(*args):
    out={}
    for p in args:
        for k,v in p.items():out[k]=add(out.get(k,val(0)),v)
    return {k:v for k,v in out.items() if v!=val(0)}
def pmul(*args):
    out={(0,0):val(1)}
    for p in args:
        tmp={}
        for (i,j),a in out.items():
            for (k,l),b in p.items():
                idx=(i+k,j+l)
                tmp[idx]=add(tmp.get(idx,val(0)),mul(a,b))
        out=tmp
    return {k:v for k,v in out.items() if v!=val(0)}
def scaled(p,a):return {k:mul(v,a) for k,v in p.items()}
X={(1,0):one};Y={(0,1):one}
left=psum(scaled(pmul(X,X,psum(X,Y)),mul(val(3),gamma_sq)),
          scaled(pmul(Y,Y,psum(X,scaled(Y,val(-1)))),val(-1)))
right=pmul(psum(Y,scaled(X,neg(tau))),
           psum(Y,scaled(X,neg(tau))),
           psum(Y,scaled(X,power(tau,3))))
assert left==right, (left,right)

t=F(2,5)
assert t*(1-t)==F(6,25)
assert F(1)/(t*(1-t))==F(25,6)
assert t/(1-t)==F(2,3)
for d in (F(0),F(1),F(-13,7)):
    for q in (F(0),F(2,3),F(-9,8)):
        delta_t=d*t+q*t*t
        delta_1=d+q
        assert delta_t-t*t*delta_1==d*t*(1-t)
assert 2*(F(25,6)+F(2,3))==F(29,3)
assert F(161,72)**2>5
assert (5*F(161,72)-11)/6==F(13,432)<F(7,40)**2
assert F(26,15)**2>3
assert F(29,6)*F(26,15)+8*F(7,40)==F(88,9)
assert F(88,9)**2==F(7744,81)<96

getcontext().prec=45
s2=Decimal(2).sqrt();s3=Decimal(3).sqrt()
gamma=((5*Decimal(5).sqrt()-11)/6).sqrt()
k=(s3*Decimal(29)/6+8*gamma)**2
k_sharp=(2*s3*(1+s2)+8*gamma)**2
k99=(2*s3*(1+s2)+Decimal(8)/5)**2
assert k_sharp<k<96<k99
print('PASS: Q(tau) golden dual polynomial SOS')
print('PASS: rational 2/5 biased switching identity and 29/6 scalar budget')
print('PASS: rational enclosure K<7744/81<96')
print('pure-sector K=',k)
print('pure-sector sharp-section conditional K=',k_sharp)
print('unrestricted conditional comparator K99=',k99)
print('SCOPE: algebra certificate only; source/Lean end-to-end gates remain')
