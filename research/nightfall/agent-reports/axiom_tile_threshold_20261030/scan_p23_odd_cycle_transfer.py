#!/usr/bin/env python3
"""Exact integer scan: odd-cycle bit-capacity deficits, all primes p<=200000; d=2..4."""
LIMIT=200000
sieve=bytearray([1])*(LIMIT+1)
sieve[0:2]=bytes((0,0))
for x in range(2,int(LIMIT**.5)+1):
    if sieve[x]: sieve[x*x::x]=bytes(((LIMIT-x*x)//x)+1)
expected={2:[23],3:[13,3251],4:[3,5,4871,55109]}
for d in (2,3,4):
    hits=[]
    for p in range(3,LIMIT+1,2):
        if not sieve[p]:continue
        q=p**d
        alphabet=(q+1)//2
        symmetry=p**(d-1)*(p-1)//2+1
        if symmetry.bit_length()<alphabet.bit_length():
            hits.append(p)
            print('CAPACITY DROP', 'p',p,'d',d,'alphabet',alphabet,'symmetric_max',symmetry,
                  'bits',alphabet.bit_length()-1,'->',symmetry.bit_length()-1)
    assert hits==expected[d], (d,hits)
print('PASS exact prime scan p<=200000, dimensions 2,3,4')
