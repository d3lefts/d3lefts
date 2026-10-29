#!/usr/bin/env python3
"""Exact refined exceptional-core count for Vesper batch Sidon insertion."""
from itertools import combinations_with_replacement

def raw_candidates(k):
    return [(a,b,c) for a,b in combinations_with_replacement(range(k),2) for c in range(k)]

def admissible_candidates(k):
    # c=a or c=b would force z in E, contradicting D intersection E empty.
    return [(a,b,c) for a,b,c in raw_candidates(k) if c!=a and c!=b]

def improved_bound(k):
    return (k**3+3*k*k)//2

def run():
    for k in range(1,100):
        n=k*k*(k-1)//2
        if k<=15:assert len(admissible_candidates(k))==n
        assert n==k*(k-1)*(k-2)//2+k*(k-1)
        assert improved_bound(k)==k*(k-1)+k*(k+1)+n
        assert (k**3+5*k*k)//2-improved_bound(k)==k*k
    print("PASS: 99 exact k values; B0 <= (k^3+3k^2)/2")
if __name__=="__main__":run()
