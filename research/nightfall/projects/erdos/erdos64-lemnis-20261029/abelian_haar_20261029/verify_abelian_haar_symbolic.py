#!/usr/bin/env python3
"""Finite universal certificate for powers-of-two cycles in abelian cubic Haar graphs.
No graph-generation libraries; checks only reduced words and Z^2 displacement identities.
"""
from itertools import product
from collections import defaultdict

C16=(0,1,0,1,0,1,2,0,1,0,2,0,1,2,1,2)

def coordinates(word):
    x=y=0
    P=[(0,0)]
    for i,z in enumerate(word):
        s=1 if i%2==0 else -1
        x+=s*(z==1); y+=s*(z==2)
        P.append((x,y))
    return P

def reduced(w):
    return len(w)%2==0 and all(w[i]!=w[(i+1)%len(w)] for i in range(len(w)))

assert reduced(C16)
P=coordinates(C16)
assert P[0]==P[-1]
assert len(set((i%2,p) for i,p in enumerate(P[:-1])))==16

short=defaultdict(list)
for length in (4,8):
    for w in product(range(3),repeat=length):
        if reduced(w):
            short[coordinates(w)[-1]].append(w)
assert (0,0) not in short, "short universal 4/8-cycle would make theorem immediate"

# If two vertices on C16 project to one quotient vertex, their parity agrees.
# Separation 2/14 is impossible by distinct symbols, 4/12 and 8 imply a
# cyclically reduced C4 or C8 (C8 may only degenerate to C4).
# Only separation 6/10 needs a *different* short closed nonbacktracking walk.
danger={}
for i in range(16):
    for j in range(i+1,16):
        d=j-i
        if d not in (6,10):continue
        vec=(P[j][0]-P[i][0],P[j][1]-P[i][1])
        assert vec!=(0,0)
        if vec not in short:
            raise AssertionError((i,j,vec))
        cand=min(short[vec],key=lambda w:(len(w),w))
        danger.setdefault(vec,cand)
assert len(danger)==12
print('UNIVERSAL 16 WORD', ''.join(map(str,C16)))
print('DANGEROUS 6/10-CHORD DISPLACEMENTS', len(danger))
for delta,word in sorted(danger.items()):
    assert coordinates(word)[-1]==delta and reduced(word)
    print(delta, '->',len(word),''.join(map(str,word)))
print('PASS: every possible early identification forces a reduced C4/C8 word')

# Mutation: modifying any one symbol makes the fixed 16 certificate fail
# closure, reducedness, or one of its explicit pair-identification gates.
mutated=0
for i in range(16):
    for x in range(3):
        if x==C16[i]:continue
        w=C16[:i]+(x,)+C16[i+1:]
        if (not reduced(w) or coordinates(w)[-1]!=(0,0)
            or len(set((j%2,p) for j,p in enumerate(coordinates(w)[:-1])))<16):
            mutated+=1
assert mutated==32
print('PASS: 32 one-symbol mutation controls rejected')
