#!/usr/bin/env python3
"""Independent F25 projective Frobenius incidence audit; F5[w]/(w^2+w+2)."""
from collections import Counter
from fractions import Fraction as F
from math import ceil

def add(x,y):return (x%5+y%5)%5+5*((x//5+y//5)%5)
def neg(x):return (-x%5)+5*((-x//5)%5)
def sub(x,y):return add(x,neg(y))
def mul(x,y):
    a,b=x%5,x//5;c,d=y%5,y//5
    return ((a*c+3*b*d)%5)+5*((a*d+b*c-b*d)%5)
def powf(x,n):
    r=1
    while n:
        if n&1:r=mul(r,x)
        x=mul(x,x);n>>=1
    return r
assert all(powf(x,24)==1 for x in range(1,25))
assert len({powf(x,5) for x in range(25)})==25
T4=[powf(x,4) for x in range(25)]
T5=[powf(x,5) for x in range(25)]
# classify all nonzero polynomial triples by exact number of zero rows
hist=Counter()
for delta in range(25):
    for B in range(25):
        for D in range(25):
            if delta==B==D==0:continue
            c=0
            for t in range(25):
                pt=mul(delta,T5[t]); tt=T4[t]
                for z in range(25):
                    if add(pt,mul(B,T5[z]))==mul(D,mul(tt,z)):c+=1
            hist[c]+=1
assert hist=={1:2880,25:11424,49:600,121:720},hist
assert sum(hist.values())==25**3-1
print('F25 15,624 nonzero triples independently re-enumerated',dict(sorted(hist.items())))
# check exact rank-two form P=delta*t^5 + b1^5 -t^4*b2
for delta in (0,1,5,13):
    zeros=0
    for t in range(25):
        for b1 in range(25):
            expected=add(mul(delta,T5[t]),T5[b1])
            if t:
                # t^4 b2 determined; exactly one b2
                sol=sum(mul(T4[t],b2)==expected for b2 in range(25))
                assert sol==1
                zeros+=1
            elif expected==0:
                zeros+=25
    assert zeros==625,(delta,zeros)
print('Independent-rank zero probability = 625/15625 = 1/25 PASS')
# projective coefficients modulo ordinary F25 scale, independent count in k=2
classes=set()
for de in range(25):
    for b in range(25):
        for d in range(25):
            if de==b==d==0:continue
            classes.add(min((mul(l,de),mul(l,b),mul(l,d)) for l in range(1,25)))
assert len(classes)==651
assert sum(bool(b or d) for de,b,d in classes)==650
print('k2 650 rank<=1 exceptional classes, 1 delta-only class PASS')
# exact projective-class formulas and exact global union, all k,s range
rho=F(121,625)
assert 121**149<625**111
for k in range(1,21):
    n=k-1;N=(25**k-1)//24
    R1=25*(25**n-1)*26//24
    R2=25*(25**n-1)*(25**n-25)//24
    assert R1+R2+1==(25**(2*k-1)-1)//24
    for s in (1,2,5):
        m=(149*k+37)//38+s
        bound=N*(R1*rho**m+F(R2+1,25**m))
        assert bound<F(1,5**s),(k,s,m,bound)
print('k 1..20 projective counts, exponent certificate, finite-s bound PASS')
print('PASS')
