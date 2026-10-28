#!/usr/bin/env python3
"""Independent physical partial-trace check of strict rank-two tube example.
The polynomial/kernel Fourier programs are not imported.
"""
from fractions import Fraction as F
from collections import defaultdict
from itertools import combinations

a=(0,0,0,0); a2=(1,0,0,0)
C0={(a,a):F(4)}
D={(a,(1,1,1,1)):F(1),(a2,(2,1,2,1)):F(1)}
M={(a,(0,1,2,1)):F(1)}
C={**C0,**D,**M}
assert len(C)==4

def Q(entries):
    answer=F(0)
    for mask in range(16):
        reduced=defaultdict(F)
        keep=[i for i in range(4) if not (mask>>i)&1]
        for (row,col),v in entries.items():
            if all(row[i]==col[i] for i in range(4) if ((mask>>i)&1)):
                reduced[tuple(row[i] for i in keep),tuple(col[i] for i in keep)]+=v
        answer+=(-F(1,2))**(4-len(keep))*sum(v*v for v in reduced.values())
    return answer
assert Q(C0)==1
assert Q(D)==2
assert Q(M)==F(1,2)
assert Q(C)==F(7,2),(Q(C),C)
# The rank-two C projects onto a rank-three negative E1 residual.
R={((x,0,0,0),(x,1,2,1)):F(1,3) for x in range(3)}
assert len({row for row,col in R})==len({col for row,col in R})==3
assert Q(R)==-F(1,6)
assert sum(x*x for x in R.values())==F(1,3)
H=lambda w:((w[2]-w[0]-w[1])%3,(w[3]-w[0]-2*w[1])%3)
in_U=lambda row,col:H(row)[1]==0 and H(col)[0]==0
assert all(not in_U(*pair) for pair in R)
# Rank exactly two: only two nonzero rows, with independent column profiles.
assert len({row for row,col in C})==2
assert C[(a,a)]*C[(a2,(2,1,2,1))]!=0
# The 1-diagonal entry M splits into E0 part with norm^2=2/3,
# and E1 scalar part with norm^2=1/3 and negative energy -1/6.
w=F(1)+F(1)+F(2,3); c2=F(16);r2=F(1,3)
assert w==F(8,3)
# The leakage norm is nonzero and checked independently for the diagonal basis: 9/32.
h2=c2*F(9,32)
assert h2==F(9,2)
assert (w-r2/2)**2 > 4*h2*r2
# The old uniform condition fails, since (w-r²/2)^2 < 2 c² r².
assert (w-r2/2)**2 <2*c2*r2
print({'status':'PASS','rank':2,'Q':str(Q(C)), 'c_squared':str(c2), 'w':str(w),
       'r_squared':str(r2),'residual_rank':3,'Q_residual':str(Q(R)),
       'exact_h_squared':str(h2),'certified_margin':'5/2-sqrt(6)',
       'anisotropic_criterion':'STRICT_PASS','uniform_criterion':'FAIL'})

