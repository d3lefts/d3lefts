#!/usr/bin/env python3
"""Exact integer rank-branch lower bounds and small GF9 fiber checks.
Independent Lemnis adversarial checker; no producer imports or stochastic data.
"""
from itertools import product
from collections import Counter

def q9_add(a,b):
    return ((a%3+b%3)%3)+3*((a//3+b//3)%3)

def q9_mul(a,b):
    a0,a1=a%3,a//3
    b0,b1=b%3,b//3
    return ((a0*b0+a1*b1)%3)+3*((a0*b1+a1*b0+2*a1*b1)%3)

def square(a): return q9_mul(a,a)
def neg(a): return q9_add(a,a)

def calibration_bucket(k,s):
    out=set()
    for x in product(range(9),repeat=k):
        if all(square(x[i])==1 for i in range(s)):
            nx=tuple(neg(t) for t in x)
            out.add(min(x,nx))
    assert len(out)==2**(s-1)*9**(k-s),(k,s,len(out))
    return out

def first_branch_lower_bound(q,k):
    m=1;M=(q+1)//2
    while M**(m-1)<q**(k-1):m+=1
    return m

def raw_count_lower_bound(q,k):
    n=(q**k+1)//2
    m=0
    while ((q+1)//2)**m<n:m+=1
    return m

def forced_chain(q,k,m):
    M=(q+1)//2
    assert q%2==1
    rows=[]
    if q**(k-1)>M**(m-1):
        return ('NO',1,'first branch exceeds capacity',rows)
    for s in range(1,k):
        dependent=q**(k-s)
        rem=M**(m-s-1)
        rows.append((s,'dependent',dependent,rem))
        if dependent<=rem:
            return ('INCONCLUSIVE',s,'dependent next row may fit',rows)
        independent=2**s*q**(k-s-1)
        rows.append((s+1,'independent',independent,rem))
        if independent>rem:
            return ('NO',s+1,'forced independent branch exceeds capacity',rows)
    return ('INCONCLUSIVE',k,'no contradiction',rows)

def main():
    assert square(1)==1 and square(2)==1
    assert set(map(square,range(9)))=={0,1,2,5,7}
    for k,s in ((2,1),(3,2),(4,1),(4,2),(4,3),(4,4)):
        b=calibration_bucket(k,s)
        print(f'GF9 EXACT ORBITS k={k} s={s} count={len(b)}')
    bucket=calibration_bucket(4,2)
    split=Counter(square(q9_add(x[0],x[1])) for x in bucket)
    assert split=={0:81,1:81},split
    print('Dependent third row classes',dict(split))
    for k,m in ((6,8),(9,12),(12,16)):
        status,step,reason,rows=forced_chain(9,k,m)
        assert status=='NO', (k,status,rows)
        print(f'NO {m}-query protocol at k={k}, at step {step}: {reason}')
        for row in rows:print(' ',row)
    for k in range(2,13):
        raw=raw_count_lower_bound(9,k)
        first=first_branch_lower_bound(9,k)
        m=raw
        while forced_chain(9,k,m)[0]=='NO':m+=1
        upper=k+k//2
        assert m<=upper,(k,m,upper)
        print(f'k={k} alphabet={raw} first={first} rank={m} upper={upper}')
    assert 8*9**2<=6**4
    print('MODEL MUTATION PASS: six-outcome alphabet invalidates GF9 rank-4 contradiction')
    print('PASS: exact arithmetic only; proof of arbitrary adaptive trees is in REVIEW.md')

if __name__=='__main__':main()
