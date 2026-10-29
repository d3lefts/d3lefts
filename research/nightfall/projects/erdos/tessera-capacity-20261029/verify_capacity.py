#!/usr/bin/env python3
"""Source-independent capacity from classical Erdős–Turán–Lindström bound.
All fourth-root/square-root comparisons use rational integer enclosures.
"""
from math import isqrt

def root4floor(n,scale=10**6):
    return isqrt(isqrt(n*scale**4))

def exact_capacity(M,scale=10**6):
    s=isqrt(M*scale*scale)
    t=root4floor(M,scale)
    # Both expressions bound floor(sqrt(M)+M^(1/4)+1) from below/above.
    lo=(s+t+scale)//scale
    hi=(s+t+2+scale)//scale
    assert lo==hi,(M,lo,hi)
    return lo

def audit():
    for q,want in ((5,(11,1)),(7,(14,2)),(25,(43,9)),(1009,(1466,554))):
        v=q*q+q+1;M=2*v;K=q+1
        cap=exact_capacity(M)
        minimum=max(0,2*K-cap)
        assert (cap,minimum)==want
        print('PASS q',q,'v',v,'M',M,'upper Sidon cardinality',cap,
              'minimum mandatory deletions',minimum)
if __name__=='__main__':audit()
