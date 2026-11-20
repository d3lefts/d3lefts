#!/usr/bin/env python3
"""Deterministic exact finite regression for graphic short-sum obstruction.

All computations use Python integers and finite sets. The universal N_r bound
and S(X)=rank for bridgeless graphs are mathematical arguments, not established
by finite replay. No general-frame lower bound is claimed.
"""
from itertools import combinations
from fractions import Fraction
from hashlib import sha256
from pathlib import Path


def rank(gens):
    pivot = {}
    for original in gens:
        x = original
        while x:
            p = x.bit_length() - 1
            if p in pivot:
                x ^= pivot[p]
            else:
                pivot[p] = x
                break
    return len(pivot)


def grid(L):
    edges = set()
    for a in range(L):
        for b in range(L):
            u = a*L+b
            if b+1<L: edges.add((u,u+1))
            if a+1<L: edges.add((u,u+L))
    return sorted(edges)


def rows(edges):
    return {1<<u ^ 1<<v for u,v in edges}


def at_most_r(R,r):
    S={0}
    for j in range(1,r+1):
        S |= {x^v for x in tuple(S) for v in R}
        assert all(x.bit_count()%2==0 and x.bit_count()<=2*j for x in S)
    return S


def run():
    assertions=0
    for L in (2,3,4,6,8,10):
        E=grid(L); R=rows(E); m=L*L; n=2*L*(L-1)
        assert len(E)==len(R)==n and rank(R)==m-1
        assertions+=1
        RR={a^b for a in R for b in R}
        K=Fraction(len(RR),len(R))
        if L%2==0:
            match={(a*L+b,a*L+b+1) for a in range(L) for b in range(0,L,2)}
            assert len(match)==m//2 and match<=set(E)
            distinct_pair_sums={a^b for a,b in combinations(rows(match),2)}
            assert len(distinct_pair_sums)==len(match)*(len(match)-1)//2
            assert K >= Fraction(len(distinct_pair_sums),len(R))
            assert K >= Fraction(L*(L*L-2), 16*(L-1))
            assertions+=4
        if L<=4:
            for r in (1,2,3,4):
                S=at_most_r(R,r)
                assert all(v.bit_count()<=2*r for v in S)
                assertions+=1
        # Every edge belongs to a four-cycle and is determined by other edges.
        squares=[]
        for a in range(L-1):
            for b in range(L-1):
                u=a*L+b; v=u+1; w=u+L; z=w+1
                sq={(u,v),(u,w),(v,z),(w,z)}
                assert sq<=set(E)
                parity=0
                for p,q in sq: parity ^= (1<<p) ^ (1<<q)
                assert parity==0
                squares.append(sq)
                assertions+=2
        covered=set().union(*squares)
        assert covered==set(E)
        assertions+=1
        print(f'GRID L={L} vertices={m} edges={n} rank={rank(R)} '
              f'doubling={K} fourcycles={(L-1)**2} Wyner_bits={m-1} '
              f'N_r_upper=2r')
    for m in range(3,12):
        complete_R=rows(list(combinations(range(m),2)))
        star={1<<0 ^ 1<<u for u in range(1,m)}
        assert star<=complete_R and rank(star)==m-1
        assert all(x in star or any(x==a^b for a,b in combinations(star,2))
                   for x in complete_R)
        path_R=rows([(u,u+1) for u in range(m-1)])
        assert rank(path_R)==len(path_R)==m-1
        assertions+=3
    print(f'PASS {assertions} exact graphic-row finite assertions; '
          f'complete-graph frame (c,cprime)=(2,1); path frame=(1,1)')
    print('SHA256',sha256(Path(__file__).read_bytes()).hexdigest())


if __name__=='__main__':run()
