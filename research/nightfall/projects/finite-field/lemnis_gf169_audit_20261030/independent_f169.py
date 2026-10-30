#!/usr/bin/env python3
"""F169 signed-query audit in independent shifted basis u=t+1, u²=2u+1.
No imports from Vesper generators, no reliance on hidden linear observations.
"""
from itertools import product
from random import Random
from collections import Counter
P=13; Q=P*P

def encode(x,y):return x%P+P*(y%P)
def coords(x):return (x%P,x//P)
def add(a,b):
    x,y=coords(a); z,w=coords(b)
    return encode(x+z,y+w)
def neg(a):
    x,y=coords(a)
    return encode(-x,-y)
def mul(a,b):
    x,y=coords(a);z,w=coords(b)
    return encode(x*z+y*w,x*w+y*z+2*y*w)
def power(a,n):
    out=1
    while n:
        if n&1:out=mul(out,a)
        a=mul(a,a);n>>=1
    return out

def inverse(a):
    assert a!=0
    out=power(a,Q-2)
    assert mul(out,a)==1
    return out

def from_t(a,b):return encode(a-b,b)
W=[from_t(*x) for x in [(1,0),(0,1),(2,0),(0,2),(7,5),(12,5)]]
A0=from_t(8,2)
A=[from_t(*x) for x in [(7,0),(0,7),(1,0),(0,1),(10,9),(6,9)]]
roots={}
for a in range(Q):roots.setdefault(mul(a,a),a)
assert len(roots)==(Q+1)//2

def total(seq):
    s=0
    for v in seq:s=add(s,v)
    return s

def observe(row,signal):return mul(total(mul(a,x) for a,x in zip(row,signal,strict=True)),total(mul(a,x) for a,x in zip(row,signal,strict=True)))

def word(eps):
    return total(W[j] for j,b in enumerate(eps) if b)

def kernel_check():
    T={word(eps) for eps in product((0,1),repeat=6)}
    assert len(T)==64
    S={add(a,b) for a in T for b in T}
    miss=set(range(Q))-S
    assert len(S)==167 and {coords(x) for x in miss}=={(10,9),(8,4)}  # 6+9t=10+9u; 12+4t=8+4u
    out={}
    for signs in product((1,12),repeat=6):
        code=mul(total([A0]+[mul(a,s) for a,s in zip(A,signs,strict=True)]),total([A0]+[mul(a,s) for a,s in zip(A,signs,strict=True)]))
        assert code not in out,(signs,out.get(code))
        out[code]=signs
    assert len(out)==64
    # Paired zero-avoidance is stronger than required for square injectivity.
    zero=0
    for bits in product((0,1),repeat=6):
        t=word(bits)
        c=from_t(10,2)
        assert add(c,t)!=0
    print('PASS: alternate-field 64 cube words, 167 sumset elements, two holes, 64 distinct squared readings')

def decoder(signal):
    k=len(signal)
    # Count coordinate observations and use only their squared outputs to set coefficients.
    readings=[mul(x,x) for x in signal]
    support=[i for i in range(k) if readings[i]!=0]
    estimate=[0]*k
    count=k
    if not support:return tuple(estimate),count
    canonical={i:roots[readings[i]] for i in support}
    t=support[0]
    estimate[t]=canonical[t]
    for start in range(0,len(support)-1,6):
        block=support[1+start:7+start]
        b=len(block)
        anchor=A0
        for c in A[b:]:anchor=add(anchor,c)
        row=[0]*k
        row[t]=mul(anchor,inverse(canonical[t]))
        for j,idx in enumerate(block):row[idx]=mul(A[j],inverse(canonical[idx]))
        obs=observe(row,signal)
        table={}
        for signs in product((1,12),repeat=b):
            val=total([anchor]+[mul(A[j],signs[j]) for j in range(b)])
            sq=mul(val,val)
            assert sq not in table
            table[sq]=signs
        phases=table[obs]
        for idx,ph in zip(block,phases,strict=True):
            estimate[idx]=mul(ph,canonical[idx])
        count+=1
    assert tuple(estimate)==tuple(signal) or tuple(neg(x) for x in estimate)==tuple(signal)
    assert count==k+(len(support)+4)//6 # ceil((s-1)/6), works s>=1
    return tuple(estimate),count

def main():
    kernel_check()
    h=Counter()
    for signal in product(range(Q),repeat=2):
        _,cost=decoder(signal);h[cost]+=1
    assert sum(h.values())==Q**2
    print('PASS: all 28,561 length-2 signals, queries',dict(h))
    # A six-relative-sign exhaustive partial oracle check, all 64 signs and each b<=6.
    for b in range(1,7):
        for signs in product((1,12),repeat=b):
            decoder((1,)+signs)
    print('PASS: all 126 anchored sign messages, including every partial block')
    random=Random(20261030)
    counts=Counter()
    for _ in range(12000):
        signal=tuple(random.randrange(Q) for _ in range(7))
        _,cost=decoder(signal);counts[cost]+=1
    print('PASS: 12000 seeded seven-coordinate signals incl support variants',dict(counts))
    # Adversarial negative control: changing squared to unsquared outputs changes alphabet cardinality.
    assert len(roots)==85 < 128
    print('PASS: 85-output alphabet precludes 7 anchored signs in one square reading')

if __name__=='__main__':main()
