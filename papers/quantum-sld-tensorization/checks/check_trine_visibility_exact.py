#!/usr/bin/env python3
"""Exact Q(omega) Fourier and SLD trine saturation checks.
Scope: only pure-trine families, not the unrestricted qubit conjecture.
"""
from fractions import Fraction as F
from itertools import product
from math import prod

class C3:
    """a + b*w, where w*w + w + 1 = 0."""
    def __init__(self, a=0, b=0): self.a,self.b=F(a),F(b)
    def __add__(self,v):
        if not isinstance(v,C3): v=C3(v)
        return C3(self.a+v.a,self.b+v.b)
    __radd__=__add__
    def __mul__(self,v):
        if not isinstance(v,C3): v=C3(v)
        return C3(self.a*v.a-self.b*v.b,self.a*v.b+self.b*v.a-self.b*v.b)
    __rmul__=__mul__
    def __truediv__(self,v): return C3(self.a/F(v),self.b/F(v))
    def __eq__(self,v):
        if not isinstance(v,C3): v=C3(v)
        return (self.a,self.b)==(v.a,v.b)

W=(C3(1),C3(0,1),C3(-1,-1))

def check(p_list):
    s=len(p_list)
    assert 1<=s<=4 and all(F(1,2)<=p<1 for p in p_list)
    q_list=[1-p for p in p_list]
    for u in product((0,1),repeat=s):
        for v in product((0,1),repeat=s):
            z=C3()
            for x in product((0,1,2),repeat=s):
                f=F(1) if sum(x)%3==0 else F(-1,2)
                phase=sum((u[i]-v[i])*x[i] for i in range(s))%3
                z=z+f*W[phase]
            z=z/F(3**s)
            expected=C3(F(1,2)) if (u==tuple([0]*s) and v==tuple([1]*s)) or (u==tuple([1]*s) and v==tuple([0]*s)) else C3()
            assert z==expected,(s,u,v)
    a=[2*p*q for p,q in zip(p_list,q_list)]
    gamma=prod(p*q for p,q in zip(p_list,q_list))/(prod(p_list)+prod(q_list))
    c=2*gamma
    phi=2*prod(a)/(prod(2*p for p in p_list)+prod(2*q for q in q_list))
    assert c==phi
    return gamma,c

if __name__=="__main__":
    profiles=[
        (F(1,2),),(F(3,4),),
        (F(3,4),F(3,4)),(F(3,4),F(2,3)),
        (F(3,4),F(3,4),F(3,4)),
        (F(3,4),F(2,3),F(4,5)),
        (F(3,4),F(2,3),F(4,5),F(5,6))
    ]
    for p in profiles:
        gamma,c=check(p)
        print(f"PASS s={len(p)}, gamma={gamma}, c=Phi={c}")
    assert F(3,8)**2/(2*(1-F(3,8)))==F(9,80)
    assert check((F(3,4),F(3,4)))[0]*F(2,3)**4==F(1,90)
    print("PASS exact quadratic coefficient and noisy trine gain")
    print("SCOPE: saturation only; unrestricted qubit conjecture UNPROVED")
