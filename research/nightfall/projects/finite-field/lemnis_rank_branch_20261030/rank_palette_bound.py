#!/usr/bin/env python3
"""Exact rank–palette transcript lower bounds for the GF9 square oracle.
This is an arithmetic verifier of a separate universal mathematical proof.
"""
from itertools import product

def lower(q,h,k,m,t):
    L=1+(q-1)//h
    assert 1<=t<=min(k,m) and (q-1)%h==0
    return min(
        ((h**(r-1)+L**(t-r)-1)//L**(t-r))*q**(k-r)
        for r in range(1,t+1)
    ),L**(m-t)

def information(q,h,k):
    L=1+(q-1)//h
    n=1+(q**k-1)//h
    m=0
    while L**m<n:m+=1
    return m

def scan(k):
    raw=information(9,2,k)
    n=raw
    while any(lower(9,2,k,n,t)[0]>lower(9,2,k,n,t)[1] for t in range(1,min(k,n)+1)):
        n+=1
    return raw,n

def main():
    expected={6:(8,9,4,648,625),8:(11,11,None,None,None),
              9:(12,13,3,2125764,1953125),
              11:(15,16,7,413343,390625),
              13:(18,19,13,3321,3125),
              14:(19,20,5,6198727824,6103515625)}
    for k,(raw,improved,t,left,right) in expected.items():
        assert scan(k)==(raw,improved),(k,scan(k))
        if t is not None:
            assert lower(9,2,k,improved-1,t)==(left,right)
        print(f'k={k} alphabet_lower={raw} palette_lower={improved} '
              f'upper={k+k//2}')
    # Fourteen, not thirteen, is forced unless the dependent row is last.
    assert [2**(6-j)*((2**j+4)//5) for j in range(7)]==[64,32,16,16,16,14,13]
    # All 256 interleavings through nine steps obey the closed palette bound.
    for t in range(1,10):
        for bits in product((0,1),repeat=t-1):
            N=1;r=1
            for independent in bits:
                if independent:N*=2;r+=1
                else:N=(N+4)//5
            formula=(2**(r-1)+5**(t-r)-1)//5**(t-r)
            assert N>=formula
    assert lower(9,2,6,8,4)==(648,625) and 648<6**4
    print('PASS: all exact model-constrained integer certificates')

if __name__=='__main__':main()
