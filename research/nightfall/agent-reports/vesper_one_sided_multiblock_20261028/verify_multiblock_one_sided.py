#!/usr/bin/env python3
"""Independent exact partial-trace check of the Vesper one-sided r-block theorem.
Uses the physical Q definition, Python standard library and only exact Fractions.
No imports from the Lemnis or Axiom Werner checkers.
"""
from collections import defaultdict
from fractions import Fraction as F
from itertools import product
from math import prod

def physical(t, terms):
    n=len(t); Q=F(0)
    for mask in range(1<<n):
        reduced=defaultdict(lambda:F(0))
        for row,col,val in terms:
            if any(row[j]!=col[j] for j in range(n) if mask&(1<<j)):
                continue
            rr=tuple(row[j] for j in range(n) if not mask&(1<<j))
            cc=tuple(col[j] for j in range(n) if not mask&(1<<j))
            reduced[rr,cc]+=F(val)
        coefficient=F((-1)**mask.bit_count())
        for j in range(n):
            if mask&(1<<j):coefficient*=t[j]
        Q+=coefficient*sum(x*x for x in reduced.values())
    return Q

def diagonal(n,amps):
    return [((i,)*n,(i,)*n,F(a)) for i,a in enumerate(amps)]

def predicted(n,t,amps):
    L=prod(1-x for x in t); M=prod(t)
    return L*sum(a*a for a in amps)+(-1)**n*M*(sum(amps)**2-sum(a*a for a in amps))

def main():
    examples=[
        (1,[F(1,2)],[1,1,1],F(-3,2)),
        (3,[F(1,2)]*3,[1,1,1],F(-3,8)),
        (3,[F(1,4),F(1,2),F(3,5)],[1,1,1],None),
        (2,[F(3,5)]*2,[1,1,-2],F(-6,5)),
        (4,[F(1,2)]*4,[1,1,-2],F(0)),
        (2,[F(1,2)]*2,[1,-1],F(0)),
        (4,[F(1,2)]*4,[1,-1],F(0)),
    ]
    for n,t,a,expected in examples:
        got=physical(t,diagonal(n,a))
        assert got==predicted(n,t,a),(n,t,a,got)
        if expected is not None:assert got==expected,(n,t,a,got,expected)
    # u0=|00>, u1=|11>; v0=|00>+|11>, v1=2|00>−|11>.
    # Both columns share sitewise supports; rank(C)=2.
    one_sided=[
        ((0,0),(0,0),1),((0,0),(1,1),1),
        ((1,1),(0,0),2),((1,1),(1,1),-1)
    ]
    got=physical([F(2,5)]*2,one_sided)
    assert got==F(27,5),got
    L=F(3,5)**2;M=F(2,5)**2
    lower=(L-M)*F(7)+M*(F(1)-F(1))**2
    assert lower==F(7,5) and got>lower
    # Deliberately mutate the physical matrix and show exact change, while
    # refusing to treat a changed witness as the original certificate.
    corrupted=one_sided[:-1]+[((1,1),(1,1),1)]
    assert physical([F(2,5)]*2,corrupted)!=got
    count=0
    for n in range(1,5):
        for ts in product((F(0),F(1,4),F(1,2),F(3,5)),repeat=n):
            L=prod(1-x for x in ts);M=prod(ts)
            for amplitudes in ((1,1),(1,-1),(1,1,1),(1,1,-2)):
                q=physical(ts,diagonal(n,amplitudes))
                assert q==predicted(n,ts,amplitudes)
                r=len(amplitudes); sumsq=sum(z*z for z in amplitudes)
                threshold=(L-M) if n%2==0 else (L-(r-1)*M)
                assert q>=threshold*sumsq
                count+=1
    assert count==1360,count
    print(f"PASS: {count} exact multi-block cases, physical partial traces, "+
          "one-sided overlapping-column strict witness, parity obstructions "+
          "and a rejected mutation")
if __name__=="__main__":main()
