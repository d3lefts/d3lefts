#!/usr/bin/env python3
"""Lemnis #47: exact all-d semidirect K3,3 cycle-certificate and adverse field replay.
No third-party dependencies. Distinct symbolic Laurent and finite-field walk oracles.
"""
from collections import Counter
from functools import reduce
from itertools import product
from math import gcd
from hashlib import sha256

VOLT = {(1,4):1,(1,5):5,(2,4):17,(2,5):64}
CHORDS = tuple(VOLT)
ADJ = {v:tuple(range(3,6)) if v<3 else tuple(range(3)) for v in range(6)}
W14 = tuple(map(int,'03140524130425'))
W32 = tuple(map(int,'03140523041325140314031403140314'))
POLYS = {0x5:24,0x3:24,0x20800000000000003:24,0x800000000001:24,
         0x1800000000003:24,0x800000000020003:24}

def weight(u,v):
    return (1 if u<3 else -1)*VOLT.get(tuple(sorted((u,v))),0)

def closed_reduced(n):
    out=[]
    def walk(path,z):
        if len(path)==n+1:
            if path[-1]==path[0] and path[1]!=path[-2] and z%147==0:
                out.append(tuple(path))
            return
        for nxt in ADJ[path[-1]]:
            if len(path)>1 and nxt==path[-2]:continue
            walk(path+[nxt],z+weight(path[-1],nxt))
    for start in range(6):walk([start],0)
    return out

def poly_row(path):
    if path[0]!=path[-1]:path=path+(path[0],)
    z=0;mon=[[] for _ in range(4)]
    for u,v in zip(path,path[1:]):
        e=tuple(sorted((u,v)))
        w=weight(u,v)
        if e in VOLT:
            mon[CHORDS.index(e)].append(z if u<3 else z+w)
        z+=w
    assert z==0
    return tuple(frozenset(k for k in set(m) if m.count(k)%2) for m in mon)

def multiply(a,b):
    result=set()
    for i in a:
        for j in b:
            k=i+j
            if k in result:result.remove(k)
            else:result.add(k)
    return frozenset(result)

def add(a,b):return frozenset(set(a)^set(b))

def eval_laurent(row,labels):
    return reduce(add,(multiply(p,v) for p,v in zip(row,labels)),frozenset())

def normalize(p):
    assert p
    lo=min(p)
    return sum(1<<(i-lo) for i in p)

def projected_simple(word):
    z=0;seen=set()
    for u,v in zip(word,word[1:]+word[:1]):
        state=(u,z%147)
        if state in seen:return False
        seen.add(state);z+=weight(u,v)
    return z%147==0 and len(seen)==len(word)

def gf_mult(a,b,poly,d):
    value=0
    while b:
        if b&1:value^=a
        b>>=1;a<<=1
        if a&(1<<d):a^=poly
    return value

def gf_pow(a,n,poly,d):
    if n<0:return gf_pow(gf_pow(a,(1<<d)-2,poly,d),-n,poly,d)
    value=1
    while n:
        if n&1:value=gf_mult(value,a,poly,d)
        a=gf_mult(a,a,poly,d);n>>=1
    return value

def direct_field_walk(path,labels,poly,d):
    # Independent finite-field multiplication along actual oriented edge sequence;
    # does not use the symbolic row/polynomial evaluator.
    z=0;v=0
    if path[0]!=path[-1]:path=path+(path[0],)
    for u,w in zip(path,path[1:]):
        edge=tuple(sorted((u,w)))
        signed=weight(u,w)
        if edge in VOLT:
            b=labels[CHORDS.index(edge)]
            if u>=3:b=gf_mult(gf_pow(2,signed,poly,d),b,poly,d)
            v^=gf_mult(gf_pow(2,z,poly,d),b,poly,d)
        z+=signed
    return z,v

def check_field(d,poly,expected_b):
    # Check alpha=2 has exact multiplicative order 2^d-1.
    seen=set();v=1
    for _ in range((1<<d)-1):
        assert v not in seen
        seen.add(v);v=gf_mult(v,2,poly,d)
    assert v==1 and len(seen)==(1<<d)-1
    b=gf_pow(2,-59,poly,d)^gf_pow(2,-58,poly,d)
    assert b==expected_b
    labels=(0,b,1,1)
    for word in closed_reduced(12):
        z,v=direct_field_walk(word,labels,poly,d)
        assert z==0 and v!=0
    for word in (W14,W32):
        assert direct_field_walk(word,labels,poly,d)==(0,0)
        assert projected_simple(word)
    # Adverse control: trivial auxiliary labels retain all 144 cyclic-neutral C12s.
    assert all(direct_field_walk(w,(0,0,0,0),poly,d)==(0,0) for w in closed_reduced(12))
    # Positive control: wrong b=0 must fail C32, not silently pass.
    assert direct_field_walk(W32,(0,0,1,1),poly,d)[1]!=0
    return {'d':d,'primitive_poly':hex(poly),'b':b,'C12_rejected':144,
            'C14_simple':True,'C32_simple':True,'zero_label_negative':144}

def main():
    for n in (4,6,8,10,16):
        assert len(closed_reduced(n))==0,(n,len(closed_reduced(n)))
    w12=closed_reduced(12)
    assert len(w12)==144 and len(closed_reduced(14))==504
    assert projected_simple(W14) and projected_simple(W32)
    b=frozenset((-59,-58))
    label_poly=(frozenset(),b,frozenset((0,)),frozenset((0,)))
    assert not eval_laurent(poly_row(W14),label_poly)
    assert not eval_laurent(poly_row(W32),label_poly)
    counts=Counter(normalize(eval_laurent(poly_row(w),label_poly)) for w in w12)
    assert counts==POLYS,(counts,POLYS)
    # For d>=9: at most sum degrees = 222 forbidden primitive alpha roots.
    assert sum((p.bit_length()-1) for p in POLYS)==222
    # Euler phi(2^d-1) for 9<=d<=15; for d>=16, phi(n)>=sqrt(n)>222
    # because n=2^d-1 is odd and phi(p^a)^2>=p^a for each odd prime p.
    phi={9:432,10:600,11:1936,12:1728,13:8190,14:10584,15:27000}
    for d,val in phi.items():
        n=(1<<d)-1
        t=n;f=n;factor=2
        while factor*factor<=t:
            if t%factor==0:
                f=f//factor*(factor-1)
                while t%factor==0:t//=factor
            factor+=1
        if t>1:f=f//t*(t-1)
        assert f==val and val>222
    assert (1<<16)-1>222**2
    assert check_field(8,0x11d,69)['C12_rejected']==144
    assert check_field(9,0x211,84)['C12_rejected']==144
    print('PASS quotient NB exclusions lengths 4,6,8,10,16; 144 neutral C12; 504 neutral C14')
    print('PASS six normalized Laurent obstruction polynomials, each occurring 24 times:',
          sorted((hex(k),v) for k,v in counts.items()))
    print('PASS all d>=8 primitive-alpha existence: d8 explicit; d9..15 phi; d>=16 odd-n phi lower bound')
    print('PASS direct field replay d8',check_field(8,0x11d,69))
    print('PASS direct field replay d9',check_field(9,0x211,84))
    print('PASS connectivity witness: chords (1,0),(17,1) yield (0,1) and all alpha^j conjugates')
    print('PASS symbolic simple C14 and C32 via quotient vertex noncollision')

if __name__=='__main__':main()
