#!/usr/bin/env python3
"""Independent hand-built exact Q(sqrt(2)) check of a *shared-neighbor* quadratic.

Uses direct all-state enumeration, NOT the ANOVA/moment-algebra routines of
check_q2_soft_ownership_exact.py. This is a small adversarial control.
"""
from fractions import Fraction as F
from itertools import product

class Z2:
    def __init__(self,a=0,b=0): self.a,self.b=F(a),F(b)
    def __add__(self,o):
        o=o if isinstance(o,Z2) else Z2(o)
        return Z2(self.a+o.a,self.b+o.b)
    __radd__=__add__
    def __neg__(self):return Z2(-self.a,-self.b)
    def __sub__(self,o):return self+-o if isinstance(o,Z2) else self+Z2(-o)
    def __mul__(self,o):
        o=o if isinstance(o,Z2) else Z2(o)
        return Z2(self.a*o.a+2*self.b*o.b,self.a*o.b+self.b*o.a)
    __rmul__=__mul__
    def __pow__(self,n):
        a=Z2(1)
        for i in range(n):a=a*self
        return a
    def __eq__(self,o):
        o=o if isinstance(o,Z2) else Z2(o)
        return self.a==o.a and self.b==o.b
    def __repr__(self):return f'{self.a}+({self.b})sqrt(2)'

# f(x)=x0 x1+x0 x2+x1 x2, all independent fair.
# Matching chooses edge (0,1). c=(1,1,0). Soft weights:
# lambda_01=lambda_10=sqrt(2)/2; lambda_02=lambda_12=1.
r=Z2(0,F(1,2))
assert r*r==Z2(F(1,2))
space=list(product((-1,1),repeat=3))

def f(x):return x[0]*x[1]+x[0]*x[2]+x[1]*x[2]

def U(i,a,x):
    z=list(x);z[i]=a
    value=f(z)
    z[i]=-a
    return Z2(value-f(z),0)*F(1,2) # conditional section (univariate fair)

def H(i,a,x):
    if i==0:return Z2(a*x[2])+r*(a*x[1])
    if i==1:return Z2(a*x[2])+r*(a*x[0])
    return Z2(0)

assert all(U(i,a,x)==Z2(a*sum(x[j] for j in range(3) if j!=i)) for i in range(3) for a in (-1,1) for x in space)
# Direct Hilbert squared and fourth norm, using fresh original source states.
for i in (0,1):
    values=[]
    for x in space:
        hs=F(1,2)*sum((H(i,a,x)**2 for a in (-1,1)),Z2(0))
        values.append(hs)
    s=sum(values,Z2(0))*F(1,len(space))
    q4=sum((v*v for v in values),Z2(0))*F(1,len(space))
    assert s==F(3,2) and q4==F(17,4)
    assert q4.a<=F(33,4) and q4.b==0

# Markov noise equality at the *same original source words*. For owner 0
# resample X1 with keep weight r, retain X2 (weight 1).
for x in space:
    for a in (-1,1):
        # Q U = r U(x) +(1-r) E_X1[U(x_0,X1,x_2)]
        resampled=F(1,2)*sum((U(0,a,(x[0],v,x[2])) for v in (-1,1)),Z2(0))
        transformed=r*U(0,a,x)+(Z2(1)-r)*resampled
        assert transformed==H(0,a,x)

# The *global* martingale-increment independence shortcut is false.
# Revealing x0, x1, x2 in order yields D1=x0*x1 and D2=x2*(x0+x1),
# so D2^2=2(1+D1): dependent despite mean-zero/orthogonality.
for x in space:
    D1=x[0]*x[1];D2=x[2]*(x[0]+x[1])
    assert D2*D2==2*(1+D1)
print('PASS independent Q(sqrt2) exact shared-neighbor fourth moment, Markov/source identity and martingale negative control')
print('STATUS: small exact witness; not a universal proof or Lean receipt')
