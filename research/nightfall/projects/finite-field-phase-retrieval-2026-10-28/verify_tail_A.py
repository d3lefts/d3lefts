#!/usr/bin/env python3
"""Exact rational verifier for the P_11 tail bound, conditional on source span-count lemma."""
from fractions import Fraction as Q
from math import factorial
import json
alpha=Q(1000000,747999)
A=Q(4189,10000)
C=Q(46374,10000)
assert alpha.numerator**10000 < 2**4189*alpha.denominator**10000
pi_up=Q(355,113); e_up=Q(271829,100000); root2_lo=Q(141421,100000)
assert root2_lo**2<2
c1_base_up=pi_up*e_up*(1+1/root2_lo)**2
assert c1_base_up.numerator**5000<2**23187*c1_base_up.denominator**5000
assert factorial(11)>2**25
def g(k,n):
    ell=Q(369,100)*k+Q(46,5)
    return 11*(A*(2*n*n-n)+C*n-2)-25+(n-1-12*k)*ell
def poly_at(scheme):
    z,y,x=[g(k,scheme(k)) for k in (0,1,2)]
    c2=(x-2*y+z)/2;c1=y-z-c2
    return(c2,c1,z)
main=poly_at(lambda k:2*k)
near=poly_at(lambda k:2*k-1)
far=poly_at(lambda k:12)
assert main==(-Q(23,625),-Q(2883,1000),-Q(281,5))
assert near==(-Q(23,625),-Q(217181,5000),-Q(1025877,10000))
assert far==(-Q(1107,25),-Q(6981,100),Q(4845293,2500))
assert all(p[0]<0 and p[1]<0 for p in (main,near,far))
assert g(12,24)==-Q(120119,1250)==-96-Q(119,1250)
assert g(12,23)==-Q(6291213,10000)
assert 24+g(12,23)<-605
assert 24+g(12,12)<-605
assert 15**1250*2**119>16**1250
print(json.dumps({'status':'PASS','main_poly':list(map(str,main)),'tail_near_poly':list(map(str,near)),'tail_far_poly':list(map(str,far)),'k12_main':str(g(12,24)),'k12_tail':str(g(12,23)),'result':'P11(q) < 2^-96 under cited span-count assumptions'},indent=2))
