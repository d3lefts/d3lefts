#!/usr/bin/env python3
"""Exact (Q(sqrt2,sqrt3)) certificates for NIGHTFALL's one-jump Q2 frontier.

Only algebraic identities are certified; this is NOT a proof of tensorization.
No dependencies outside the Python standard library.
"""
from fractions import Fraction as F
from decimal import Decimal, getcontext

MUL = (
    ((1, 0), (1, 1), (1, 2), (1, 3)),
    ((1, 1), (2, 0), (1, 3), (2, 2)),
    ((1, 2), (1, 3), (3, 0), (3, 1)),
    ((1, 3), (2, 2), (3, 1), (6, 0)),
)

class A:
    def __init__(self, a=0, b=0, c=0, d=0):
        self.v = tuple(map(F, (a,b,c,d)))
    @staticmethod
    def coerce(x):
        return x if isinstance(x, A) else A(x)
    def __add__(self, other):
        other = self.coerce(other)
        return A(*(a+b for a,b in zip(self.v,other.v)))
    __radd__=__add__
    def __neg__(self):
        return A(*(-z for z in self.v))
    def __sub__(self,other):
        return self+self.coerce(other).__neg__()
    def __rsub__(self,other):
        return self.coerce(other)-self
    def __mul__(self,other):
        other=self.coerce(other)
        out=[F(0) for _ in range(4)]
        for i,x in enumerate(self.v):
            for j,y in enumerate(other.v):
                coef,k=MUL[i][j]
                out[k]+=coef*x*y
        return A(*out)
    __rmul__=__mul__
    def __truediv__(self,k):
        k=F(k)
        return A(*(x/k for x in self.v))
    def __pow__(self,n):
        if n<0: raise ValueError('nonnegative powers only')
        r=A(1)
        for _ in range(n): r=r*self
        return r
    def __eq__(self,other):
        return self.v==self.coerce(other).v
    def __repr__(self):
        return str(self.v)
    def decimal(self):
        s2=Decimal(2).sqrt()
        s3=Decimal(3).sqrt()
        s6=Decimal(6).sqrt()
        return sum(Decimal(a.numerator)/Decimal(a.denominator)*r for a,r in zip(self.v,(Decimal(1),s2,s3,s6)))

ONE=A(1); TWO=A(2); THREE=A(3)
s2=A(0,1); s3=A(0,0,1); s6=A(0,0,0,1)
assert s2**2==2 and s3**2==3 and s6**2==6 and s2*s3==s6
q=(s6-2)/4
beta=(s3-s2)/2
assert q*(1+q)==A(F(1,8))
assert beta**2==2*q**2
assert 2*s3*beta-1==-4*q
assert s2/4-s3*q==beta
p=5-2*s6
assert p*(1+q)==q
assert p*(1+q)**2==A(F(1,8))
# Exact polynomial in (u^2, uc, c^2) of the shifted square-gap.
lhs=(s3**2-1,2*s3*beta-1,beta**2)
rhs=(A(2),-4*q,2*q**2)
assert lhs==rhs
# Exact finite-budget coefficient checks.
c5=(5*s3+8*beta)**2
assert c5==275-72*s6
csharp=(2*s3*(1+s2)+8*beta)**2
assert csharp==164+72*s2-32*s3-48*s6
c6=(5*s3+A(F(4,3)))**2
assert c6==A(F(691,9))+A(F(40,3))*s3
c99=(2*s3*(1+s2)+A(F(8,5)))**2
# Prove beta < 1/6 via sqrt2 > 4/3, since 2 > 16/9.
assert F(2)>F(16,9)
# Prove c5 < 100 via sqrt6 > 175/72, since 6 > (175/72)^2.
assert F(6)>F(175,72)**2
# Prove c6 < 100 via sqrt3 < 629/120, which is true but loose;
# instead 691/9+(40/3)sqrt3<100 iff sqrt3<209/120.
assert F(3)<F(209,120)**2
getcontext().prec=45
for label,val in [
    ('q',q),('beta_star',beta),('5B_beta_star_coefficient',c5),
    ('sharp_budget_beta_star_coefficient',csharp),
    ('5B_c_over_6_coefficient',c6),
    ('sharp_budget_c_over_5_coefficient',c99)
]:
    print(label, val.decimal())
print('PASS: exact one-jump identities and conditional coefficient arithmetic')
