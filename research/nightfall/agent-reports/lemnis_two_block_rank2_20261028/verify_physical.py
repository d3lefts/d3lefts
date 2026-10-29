#!/usr/bin/env python3
"""Standalone direct partial-trace path; no import from operator/spectral code."""
from fractions import Fraction as F
from itertools import product
from collections import defaultdict

N=4
A=(0,0,0,0); B=(1,1,1,1); C=(2,2,2,0); D=(2,2,2,2)

def Qphys(X,n=N):
    out=F(0)
    for mask in range(1<<n):
        keep=[i for i in range(n) if not (mask>>i)&1]
        gone=[i for i in range(n) if (mask>>i)&1]
        trace=defaultdict(lambda:F(0))
        for (a,b),value in X.items():
            if all(a[j]==b[j] for j in gone):
                key=(tuple(a[i] for i in keep),tuple(b[i] for i in keep))
                trace[key]+=value
        norm=sum(v*v for v in trace.values())
        out+=F((-1)**len(gone),2**len(gone))*norm
    return out

def make(t):
    u={A:F(1),C:F(1),D:t}
    out={(a,b):x*y for a,x in u.items() for b,y in u.items()}
    out[(B,B)]=F(-1)
    return {z:v for z,v in out.items() if v}

for t in (F(0),F(1,10),F(1,4),F(1,2),F(1),F(2),F(-3,2)):
    x=make(t)
    actual=Qphys(x)
    expected=F(13,16)+F(17,8)*t*t+F(1,16)*t**4
    assert actual==expected,(t,actual,expected)
    assert actual>=F(1,16)*(1+t*t)**2
    print('t=',t,'Q=',actual,'rank-two lower=',F(1,16)*(1+t*t)**2)
# Independently polarize the interaction between archived syndrome rectangle U
# and its complement. This uses physical partial traces, never the sparse operator.
S={(i,0) for i in range(3)}; T={(0,i) for i in range(3)}
def syndrome(a):return ((a[2]-a[0]-a[1])%3,(a[3]-a[0]-2*a[1])%3)
full=make(F(1))
base={k:v for k,v in full.items() if syndrome(k[0]) in S and syndrome(k[1]) in T}
outside={k:v for k,v in full.items() if k not in base}
assert Qphys(base)==F(9,16)
assert Qphys(outside)==F(41,16)
assert Qphys(full)-Qphys(base)-Qphys(outside)==F(-1,8)
print('exact physical same-grade cross = -1/8; base Q=9/16; outside Q=41/16')

mutation={(A,A):F(1),(C,C):F(1),(B,B):F(-1)}
assert Qphys(mutation)==F(-3,16)
print('negative rank3 mutation Q=',Qphys(mutation))
print('PASS independent 16-partial-trace polynomial and negative control')
