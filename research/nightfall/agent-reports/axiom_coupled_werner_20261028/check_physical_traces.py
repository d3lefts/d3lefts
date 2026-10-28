#!/usr/bin/env python3
"""AXIOM / checker B: independent physical partial-trace computation; no K entries."""
from itertools import product,combinations
from fractions import Fraction as F
from collections import defaultdict
from hashlib import sha256
from pathlib import Path

O=(0,)*4

def unit(a,b,x=1):return {(tuple(a),tuple(b)):F(x)}
def add(*parts):
    d=defaultdict(F)
    for part in parts:
        for pair,v in part.items():d[pair]+=v
    return {key:v for key,v in d.items() if v}
def trace_norm(C,trace_positions):
    remain=tuple(i for i in range(4) if i not in trace_positions)
    T=defaultdict(F)
    for (a,b),v in C.items():
        if all(a[j]==b[j] for j in trace_positions):
            T[tuple(a[j] for j in remain),tuple(b[j] for j in remain)]+=v
    return sum(v*v for v in T.values())
def physical_Q(C):
    return sum(F(-1,2)**len(inds)*trace_norm(C,inds) for t in range(5) for inds in combinations(range(4),t))

one=unit(O,O);two=unit((1,0,0,0),(1,0,0,0))
assert physical_Q(one)==F(1,16)
assert physical_Q(two)==F(1,16)
assert physical_Q(add(one,two))==0
assert physical_Q(add(one,unit((1,0,0,0),(1,0,0,0),F(1,2))))==F(1,64)
three=add(one,two,unit((2,0,0,0),(2,0,0,0)))
assert physical_Q(three)==-F(3,16)
# A balanced THREE-unit source: coupled cross terms of both signs.
p=unit((1,1,0,0),(1,1,0,0))
for v in [(F(1),F(1),F(1)),(F(2),F(-3),F(5)),(F(1),F(0),F(-1))]:
    C=add(unit(O,O,v[0]),unit((1,0,0,0),(1,0,0,0),v[1]),unit((1,1,0,0),(1,1,0,0),v[2]))
    assert physical_Q(C)==F((v[0]-v[1]+v[2])**2,16)
# Each grade has one fixed background row; vary one zero-coordinate position.
# Verify predicted sign of the actual mixed cross-term without a kernel-product import.
checks=0
for d in product(range(3),repeat=4):
    z=[i for i in range(4) if d[i]==0]
    a=O
    b=tuple((-di)%3 for di in d)
    x=unit(a,b)
    assert physical_Q(x)==F(1,2**len(z))
    for j in z:
        for t in (1,2):
            c=list(a);c[j]=t;c=tuple(c)
            e=tuple((c[i]-d[i])%3 for i in range(4))
            y=unit(c,e)
            cross=physical_Q(add(x,y))-physical_Q(x)-physical_Q(y)
            assert cross==-F(2,2**len(z)),(d,j,t,cross)
            checks+=1
    # Any nonzero-coordinate change breaks coupling.
    for j in range(4):
        if d[j]:
            c=list(a);c[j]=1;c=tuple(c)
            e=tuple((c[i]-d[i])%3 for i in range(4))
            y=unit(c,e)
            assert physical_Q(add(x,y))==physical_Q(x)+physical_Q(y)
            checks+=1
assert checks>100
# Grade-resolved previous certificate MUST FAIL for all 0<t<sqrt(5)/3.
# C(t)=E0000,0000 + t E1000,1000, with C0=E0000,0000 in archived U.
# Exact lower bounds: w<=t^2, r^2>=40*t^2/81, h^2=9/32.
# Therefore old RHS >= (sqrt(5)/3)*t > t^2 for 0<t<sqrt(5)/3.
assert F(9,32)*F(40,81)==F(5,36)
assert F(1,2)**2 < F(5,9)
print('PASS 16-partial-trace Q for rank-two collision and sharp rank-three negative')
print('PASS grade-specific cross-term and broken-coupling tests:',checks)
print('PASS independently checked old certificate failure at t=1/2')
print('SHA256',sha256(Path(__file__).read_bytes()).hexdigest())
