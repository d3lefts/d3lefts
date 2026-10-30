#!/usr/bin/env python3
"""Independent second checker for rank-two difference-sector positivity certificate.
Computes 16 literal physical partial traces; no use of local K product or
Fourier/Schur/kernel calculations in source check_difference_sectors.py.
"""
from fractions import Fraction as Q
from itertools import combinations,product
from collections import defaultdict
from hashlib import sha256
from pathlib import Path

O=(0,0,0,0)

def add(*pieces):
    v=defaultdict(Q)
    for t in pieces:
        for key,a in t.items(): v[key]+=a
    return {k:a for k,a in v.items() if a}

def unit(a,b,coef=1):return {(tuple(a),tuple(b)):Q(coef)}
def scl(M,t):return {key:t*v for key,v in M.items()}
def diff(key):return tuple((a-b)%3 for a,b in zip(*key))

def q_trace(M):
    total=Q(0)
    for mask in range(16):
        lost=[i for i in range(4) if mask & (1<<i)]
        kept=[i for i in range(4) if not mask & (1<<i)]
        reduced=defaultdict(Q)
        for (r,c),v in M.items():
            if all(r[i]==c[i] for i in lost):
                reduced[(tuple(r[i] for i in kept),tuple(c[i] for i in kept))]+=v
        total+= Q(-1,2)**len(lost)*sum(v*v for v in reduced.values())
    return total

base=unit(O,O,4)
u1=unit(O,(1,1,1,1))
u2=unit((1,0,0,0),(2,1,2,1))
u3=unit(O,(0,1,2,1))
assert len({diff(key) for part in [base,u1,u2,u3] for key in part})==4
assert q_trace(base)==Q(1)
assert q_trace(u1)==Q(1) and q_trace(u2)==Q(1) and q_trace(u3)==Q(1,2)
assert q_trace(add(base,u1,u2,u3))==Q(7,2)
for t in [Q(1,4),Q(1,2),Q(1)]:
    C=add(base,scl(u1,t),scl(u2,t),scl(u3,t))
    actual=q_trace(C)
    by_grade=sum(q_trace(part) for part in [base,scl(u1,t),scl(u2,t),scl(u3,t)])
    assert actual==by_grade==1+Q(5,2)*t*t
    print('PASS independent physical partial traces',str(t),str(actual))

# Negative control: same difference sector CAN have nonzero coupling.
a=unit(O,O)
b=unit((1,1,1,1),(1,1,1,1))
assert diff(next(iter(a)))==diff(next(iter(b)))
interaction=q_trace(add(a,b))-q_trace(a)-q_trace(b)
assert interaction==Q(1,8),(interaction)
print('PASS same-sector cross-term negative control:',interaction)

# Negative control: sector projection need not preserve matrix rank.
# C=sum_{r,c=0}^2 |r000><c000| is rank one (all-ones 3x3 block).
J={((r,0,0,0),(c,0,0,0)):Q(1) for r in range(3) for c in range(3)}
Jzero={key:v for key,v in J.items() if diff(key)==O}
assert len(J)==9 and len(Jzero)==3
# The zero-grade projection is a 3x3 identity, of rank 3.
assert len({a for a,b in Jzero})==3 and len({b for a,b in Jzero})==3
print('PASS rank-inflation control: rank1 full matrix -> rank3 grade-zero component')
print('PASS independent 16-partial-trace path')
print('FILE_SHA256:',sha256(Path(__file__).read_bytes()).hexdigest())
