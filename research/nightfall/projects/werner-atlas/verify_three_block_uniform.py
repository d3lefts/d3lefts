#!/usr/bin/env python3
"""Exact rational downstream audit of NIGHTFALL qutrit three-block theorem.
Published two- and three-copy inequalities are imported, not reproduced.
Requires only Python standard library.
"""
from fractions import Fraction as F
from math import factorial, comb

# Four coefficient vectors ordered (constant, a1, a2, a3).
B = (F(1), -F(1), F(1,3), -F(1,27))
D = (F(0), F(3), -F(2), F(1,3))
J2 = (F(2), -F(1), -F(1), F(1,2))
J3 = (F(1), -F(3,2), F(3,4), -F(1,8))
Jc = (F(2), F(0), F(0), -F(1))
def lin(*items):
    return tuple(sum((a*v[i] for a,v in items),F(0)) for i in range(4))
assert lin((F(9),B),(-F(1),D)) == lin((F(2,3),J2),(F(68,9),J3),(F(1,18),Jc))
assert lin((F(1),B),(-F(4,27),(F(1),F(0),F(0),F(0)))) == lin((F(1,9),J2),(F(16,27),J3),(F(1,54),Jc))
w = (F(1),F(4,3),F(5,3),F(2))
ev=lambda p:sum((x*y for x,y in zip(p,w)),F(0))
assert ev(B)==F(4,27) and ev(D)==F(4,3) and all(ev(x)==0 for x in (J2,J3,Jc))

def b(j):
    q,r=divmod(j,3)
    return F(4,27)**q * (F(1),F(1,3),F(2,9))[r]
assert all(b(j)>=F(1,3)**j for j in range(1,250))
def phi_bounds(c):
    partial=3*c+2*sum((c**j/(factorial(j)*b(j)) for j in range(3,19,2)),F(0))
    ratio=(3*c)**2/F(420)
    assert ratio<1
    tail=2*(3*c)**19/factorial(19)/(1-ratio)
    return partial,partial+tail
c=F(7760249,25000000)
lo,hi=phi_bounds(c)
assert hi<1
assert phi_bounds(F(31040997,100000000))[0]>1

def R(k,delta):
    return 3*k*delta+2*sum((F(comb(k,j))*delta**j/b(j) for j in range(3,k+1,2)),F(0))
for k in range(3,101):
    assert R(k,c/k)<1
for k,t in ((24,F(8659,25000)),(25,F(4323,12500)),
            (24,F(346368,1000000)),(25,F(345842,1000000))):
    r=R(k,t-F(1,3))
    assert r<1
    print('k',k,'t',t,'exact normalized floor',b(k)*(1-r))
print('PASS — exact identities, sharp witness, all-k tail, finite-copy margins')
print('uniform c',c,'exact 1−Phi upper',1-hi)
print('NOT CHECKED — source endpoint theorems; non-author review; world novelty')
