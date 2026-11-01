#!/usr/bin/env python3
"""Independent integer test of Axiom's sharp four-tile sumset transition.

Underlying additive group: Z/pZ x Z/pZ, with p any integer >=3D+2.
For prime p, this is the additive group of F_(p^2), but negative
tests for composite moduli are *not* presented as finite-field oracles.

Separate algorithms:
  (A) nine translated rectangle enumeration for T+T,
  (B) unordered brute force pairs for T+T and off-diagonal T+T,
  (C) actual finite-field squared outputs when p is prime.

Full symbolic universal proof, including off-diagonal coverage, is in
THEOREM.md and is not delegated to these finite tests.
"""
from itertools import product
from math import isqrt


def prime(n):
    return n >= 2 and all(n % d for d in range(2, isqrt(n)+1))


def geometry(D, p):
    assert D >= 4 and D&(D-1) == 0
    v=(2*D-1,D+1)
    w=(-1,D+1)
    I=range(2*D-1)
    tiles=[
        {((i+a*v[0]+b*w[0])%p,(j+a*v[1]+b*w[1])%p)
         for i in range(D) for j in range(D)}
        for a,b in product(range(2),repeat=2)
    ]
    T=set().union(*tiles)
    assert all(len(tile)==D*D for tile in tiles)
    assert len(T)==4*D*D,(D,p,len(T))
    nine={
        ((a*v[0]+b*w[0]+i)%p,(a*v[1]+b*w[1]+j)%p)
        for a,b in product(range(3),repeat=2) for i,j in product(I,repeat=2)
    }
    return T,nine


def brute_pair_sums(T,p,off_diagonal=False):
    """Entire unordered pair sumset, separate from nine rectangles."""
    values=sorted(T)
    sums=set()
    for i,(a,b) in enumerate(values):
        for c,d in values[i+1 if off_diagonal else i:]:
            sums.add(((a+c)%p,(b+d)%p))
    return sums


def actual_square_outputs(D,p,hole):
    assert prime(p)
    T,_=geometry(D,p)
    inv2=pow(2,-1,p)
    c=((-hole[0]*inv2)%p,(-hole[1]*inv2)%p)
    nonsquare=next(z for z in range(2,p)
                   if pow(z,(p-1)//2,p)==p-1)
    outputs=set()
    for a,b in T:
        x=(a+c[0])%p
        y=(b+c[1])%p
        result=((x*x+nonsquare*y*y)%p,(2*x*y)%p)
        assert result not in outputs,(D,p,(a,b),result)
        outputs.add(result)
    assert len(outputs)==4*D*D
    assert 2**(2*(D.bit_length()-1)+2)==len(outputs)
    return nonsquare,len(outputs)


def negative(D,p,brute=True):
    assert 3*D+2 <=p <=4*D-4 and D>=8
    T,S=geometry(D,p)
    assert len(S)==p*p,(D,p,p*p-len(S))
    if brute:
        assert brute_pair_sums(T,p)==S
        # Stronger than full T+T: every m has a DISTINCT pair, so
        # no affine translate avoids opposite-point collisions.
        off=brute_pair_sums(T,p,True)
        assert len(off)==p*p,(D,p,p*p-len(off))
    return {"D":D,"p":p,"tile_size":len(T),
            "pair_sum_holes":0,"off_diagonal_holes":0 if brute else "symbolic"}


def positive(D,p,brute=False):
    assert p >=4*D-3 and prime(p)
    T,S=geometry(D,p)
    hole=(2*D-2,2*D+1)
    assert hole not in S,(D,p,hole)
    if brute:
        assert brute_pair_sums(T,p)==S
    delta,readings=actual_square_outputs(D,p,hole)
    return {"D":D,"p":p,"tile_size":len(T),
            "explicit_hole":hole,"powered_readings":readings,
            "field_nonsquare":delta,
            "one_query_phase_bits":2*(D.bit_length()-1)+2}


def main():
    # Every integer modulus in the sharp lower-side transition for
    # D=8 and D=16; primality is irrelevant to additive obstructions.
    for D in (8,16):
        for p in range(3*D+2,4*D-3):
            print("NEGATIVE",negative(D,p,brute=(D==8 or p in (53,59,60))))
    # Large independent edge controls at D=32.
    for p in (98,101,113,124):
        print("NEGATIVE",negative(32,p,brute=(p==101)))
    # Positive interval: many ordinary primes are covered, not
    # solely the earlier near-Mersenne endpoints.
    for D,ps in (
       (4,(13,17,19,23)),
       (8,(29,31,37,41,43)),
       (16,(61,67,71,73,79)),
       (32,(127,131,137)),
       (64,(257,263))):
        for p in ps:
            if prime(p):
                print("POSITIVE",positive(D,p,brute=(D<=8)))
    # Negative mutation: the same prescribed hole is IN the sumset
    # before the threshold, even though every other sum is too.
    T,S=geometry(16,59)
    assert (2*16-2,2*16+1) in S
    # Baseline 4D-3 and 4D-1 are capacity-tight, but generic
    # p>4D-1 need not be; never sell a nonoptimal code as optimal.
    for D in (4,8,16,32):
        assert (4*D-3)**2+1>=2*(4*D*D)
        assert (4*D-1)**2+1<4*(4*D*D)
        assert (4*D+1)**2+1>=4*(4*D*D)
    print("PASS exact sharp-threshold and off-diagonal negative controls")


if __name__=="__main__":
    main()
