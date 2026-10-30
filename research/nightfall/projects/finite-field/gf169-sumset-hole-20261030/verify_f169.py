#!/usr/bin/env python3
"""Exact GF169 6-sign powered-oracle certificate and all-support regression.

Producer field: F13[t]/(t^2-2), integer a+13b = a+bt.
Independent check: F13[u]/(u^2-11), with t=5u (25*11=2 mod13).
All computations exact in the standard library.
"""
from collections import Counter
from hashlib import sha256
from itertools import combinations, product
from random import Random

P, Q = 13, 169
def add(x,y):
    return ((x%P+y%P)%P)+P*((x//P+y//P)%P)
def neg(x):
    return (-(x%P))%P+P*((-(x//P))%P)
def mul(x,y):
    a,b=x%P,x//P; c,d=y%P,y//P
    return ((a*c+2*b*d)%P)+P*((a*d+b*c)%P)
def square(x): return mul(x,x)
def total(values):
    z=0
    for v in values: z=add(z,v)
    return z
assert all(v*v%P!=2 and v*v%P!=11 for v in range(1,P))
assert len({square(x) for x in range(Q)})==85

W=(1,13,2,26,7+5*13,12+5*13)
T={total(W[i] for i,b in enumerate(bits) if b)
   for bits in product((0,1),repeat=6)}
assert len(T)==64
twice={add(v,w) for v in T for w in T}
holes=set(range(Q))-twice
assert holes=={6+9*13,12+4*13}, holes
c=10+2*13
assert neg(add(c,c)) in holes
A=(7,7*13,1,13,10+9*13,6+9*13)
anchor=8+2*13
assert add(c,total(A))==anchor

def observe(coeff,phase):
    return square(total([coeff[0]]+
           [mul(a,h) for a,h in zip(coeff[1:],phase,strict=True)]))

tables={}
for b in range(1,7):
    coeff=(total((anchor,)+A[b:]),)+A[:b]
    dictionary={}
    for phase in product((1,12),repeat=b):
        y=observe(coeff,phase)
        assert y not in dictionary,(b,phase,dictionary.get(y))
        dictionary[y]=phase
    assert len(dictionary)==2**b
    tables[b]=(coeff,dictionary)

# Independent field representation F13[u]/(u^2-11), mapping t -> 5u.
def altmul(x,y):
    a,b=x%P,x//P; c,d=y%P,y//P
    return ((a*c+11*b*d)%P)+P*((a*d+b*c)%P)
def alternative(x):
    return x%P+P*((5*(x//P))%P)
assert len({alternative(x) for x in range(Q)})==Q
assert all(alternative(add(x,y))==((alternative(x)%P+alternative(y)%P)%P)
                +P*((alternative(x)//P+alternative(y)//P)%P)
           for x in range(Q) for y in range(Q))
assert all(alternative(mul(x,y))==altmul(alternative(x),alternative(y))
           for x in range(Q) for y in range(Q))
alt_outputs={}
for phase in product((1,12),repeat=6):
    y=0
    for a,h in zip((anchor,)+A,(1,)+phase,strict=True):
        z=altmul(alternative(a),alternative(h))
        y=(y%P+z%P)%P+P*((y//P+z//P)%P)
    y=altmul(y,y)
    assert y not in alt_outputs,(phase,alt_outputs.get(y))
    alt_outputs[y]=phase
assert len(alt_outputs)==64
assert {alternative(v):phase for v,phase in tables[6][1].items()}==alt_outputs

roots={z:min(v for v in range(Q) if square(v)==z)
       for z in {square(v) for v in range(Q)}}
inverses={v:next(w for w in range(1,Q) if mul(v,w)==1) for v in range(1,Q)}

def decode(x):
    k=len(x)
    readings=[square(v) for v in x]
    support=[i for i,v in enumerate(readings) if v]
    if not support:return (0,)*k,k
    reps={i:roots[readings[i]] for i in support}
    t=support[0]
    out=[0]*k
    out[t]=reps[t]
    n=k
    for start in range(0,len(support)-1,6):
        js=support[1+start:1+start+6]
        coeff,lookup=tables[len(js)]
        row=[0]*k
        row[t]=mul(coeff[0],inverses[reps[t]])
        for j,a in zip(js,coeff[1:],strict=True):
            row[j]=mul(a,inverses[reps[j]])
        y=square(total(mul(row[i],x[i]) for i in range(k)))
        for j,sign in zip(js,lookup[y],strict=True):
            out[j]=mul(sign,reps[j])
        n+=1
    assert tuple(out)==tuple(x) or tuple(neg(v) for v in out)==tuple(x)
    assert n==k+(len(support)+4)//6
    return tuple(out),n

hist=Counter()
for x in product(range(Q),repeat=2):
    _,queries=decode(x)
    hist[queries]+=1
assert hist=={2:337,3:28224}
count=0
for s in range(1,8):
    for support in combinations(range(7),s):
        for phases in product((1,12),repeat=s-1):
            x=[0]*7
            for j,h in zip(support,(1,)+phases,strict=True): x[j]=h
            assert decode(tuple(x))[1]<=8
            count+=1
assert count==1093
rng=Random(13261030)
for _ in range(20000):
    assert decode(tuple(rng.randrange(Q) for _ in range(7)))[1]<=8

transcript='\n'.join(
    ''.join('+' if h==1 else '-' for h in phase)+','+str(y)
    for y,phase in sorted(tables[6][1].items()))+'\n'
print('PASS: 64/64 squared readings unique in two field representations')
print('PASS: |T|=64, |T+T|=167, holes=(6+9t,12+4t)')
print('PASS: all 6 proper subblock code tables')
print('PASS: GF169^2 all 28,561 signals; k7 1,093 support/phase sectors')
print('PASS: 20,000 deterministic arbitrary k7 signals')
print('EXACT_TABLE_SHA256',sha256(transcript.encode()).hexdigest())
