#!/usr/bin/env python3
"""Separate exact checks for off-diagonal-vs-full sumset and boundary leakage."""
from itertools import product
T={0,1,2,3};q=7
S={(x+y)%q for x,y in product(T,repeat=2)}
So={(x+y)%q for x,y in product(T,repeat=2) if x!=y}
assert S==set(range(7)) and set(range(7))-So=={0,6}
c=4
translated={(c+x)%q for x in T}
assert translated=={0,4,5,6}
assert len({x*x%q for x in translated})==4
assert 0 in translated
print('PASS: sumset hole only sufficient; off-diagonal hole necessary/sufficient')
# D=4 p13 alternate candidate m=(6,7) actually occurs as a pair sum.
D=4;p=13;v=(7,5);w=(-1,5)
T={( (x+a*v[0]+b*w[0])%p,(y+(a+b)*5)%p)
   for x,y,a,b in product(range(D),range(D),(0,1),(0,1))}
assert (6,7) in {((x+xx)%p,(y+yy)%p) for (x,y),(xx,yy) in product(T,repeat=2)}
print('PASS: D=4 alternate hole rejected')
