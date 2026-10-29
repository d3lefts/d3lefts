#!/usr/bin/env python3
"""Independent finite verifier: matrix recurrence and integer pair-sum uniqueness.

Does not import builder, use its multiplication, or trust MILP optimization.
"""
import hashlib
import json
import sys


def verify(cert):
    assert cert['schema']=='nightfall-sidon-prefix-bridge-finite-v1'
    p=cert['p']; d=cert['field_u_squared']; theta=cert['theta']
    order=p*p-1
    assert p==1009 and order==cert['modulus']
    assert all(p%j for j in range(2,int(p**0.5)+1))
    assert pow(d,(p-1)//2,p)==p-1  # irreducible u^2-d
    def mul(x,y):
        return ((x[0]*y[0]+d*x[1]*y[1])%p,
                (x[0]*y[1]+x[1]*y[0])%p)
    def power(x,n):
        out=(1,0)
        while n:
            if n&1:out=mul(out,x)
            x=mul(x,x);n//=2
        return out
    for prime_factor in (2,3,5,7,101):
        assert power(tuple(theta),order//prime_factor)!=(1,0)
    # Independent 2x2 multiplication matrix for multiplication by theta.
    a,b=1,0
    logs=[]
    for exponent in range(order):
        if b==theta[1]:logs.append(exponent)
        a,b=((theta[0]*a+d*theta[1]*b)%p,
             (theta[1]*a+theta[0]*b)%p)
    assert (a,b)==(1,0)
    assert len(logs)==p and len(set(logs))==p
    assert logs[0]==1
    modular_sums=set()
    for i,x in enumerate(logs):
        for y in logs[i:]:
            s=(x+y)%order
            assert s not in modular_sums
            modular_sums.add(s)
    excluded=cert['removed_sorted_indices']
    assert len(set(excluded))==len(excluded) and excluded==sorted(excluded)
    assert all(0<=i<len(logs) for i in excluded)
    B=[cert['translation']+x for i,x in enumerate(logs) if i not in set(excluded)]
    A=cert['prefix']
    assert len(A)==len(set(A)) and max(A)<min(B)
    assert len(B)==cert['size_after']==965
    assert len(A)+len(B)==cert['size_with_prefix']==970
    assert max(B)==cert['endpoint_M']==1794316
    assert 2*len(B)**2-max(B)==cert['two_B_squared_minus_M']==68134>0
    digest=hashlib.sha256(json.dumps(B,separators=(',',':')).encode()).hexdigest()
    assert digest==cert['B_json_sha256']
    # Completely independent integer sum test, including diagonals.
    values=sorted(A+B)
    sums=set()
    for i,x in enumerate(values):
        for y in values[i:]:
            z=x+y
            assert z not in sums,('collision',x,y,z)
            sums.add(z)
    assert len(sums)==970*971//2
    print('PASS prefix',A,'B',len(B),'M',max(B),
          '2|B|^2-M',2*len(B)**2-max(B),'sum checks',len(sums),'B SHA256',digest)


if __name__=='__main__':
    with open(sys.argv[1],encoding='utf8') as f:
        verify(json.load(f))
