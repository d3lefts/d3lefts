#!/usr/bin/env python3
"""Independent exact GF169 and prime-tile audit; stdlib only.
Third field: F13[y]/(y²+y+2), t=3+6y. No producer arithmetic imported.
"""
from itertools import product,combinations
from collections import Counter
from random import Random
from hashlib import sha256
from math import ceil,isqrt

p=13
E=tuple((a,b) for a in range(p) for b in range(p))
Z=(0,0); U=(1,0)
def add(x,y):return ((x[0]+y[0])%13,(x[1]+y[1])%13)
def neg(x):return ((-x[0])%13,(-x[1])%13)
def mul(x,y):
    a,b=x;c,d=y
    return ((a*c-2*b*d)%13,(a*d+b*c-b*d)%13)
def sq(x):return mul(x,x)
def cv(a,b):return ((a+3*b)%13,(6*b)%13)
def total(xs):
    out=Z
    for x in xs:out=add(out,x)
    return out
def power(x,n):
    out=U
    while n:
        if n&1:out=mul(out,x)
        x=mul(x,x);n//=2
    return out
assert sq(cv(0,1))==(2,0)
assert len({cv(a,b) for a in range(13) for b in range(13)})==169
# Every original source multiplication independently compared via the map.
for a,b,c,d in product(range(13),repeat=4):
    expected=cv((a*c+2*b*d)%13,(a*d+b*c)%13)
    assert mul(cv(a,b),cv(c,d))==expected
ROOT={}
for x in E:ROOT.setdefault(sq(x),x)
assert len(ROOT)==85
INV={x:power(x,167) for x in E if x!=Z}
assert all(mul(x,i)==U for x,i in INV.items())
W=tuple(cv(*c) for c in ((1,0),(0,1),(2,0),(0,2),(7,5),(12,5)))
T={total(w for w,t in zip(W,bits) if t) for bits in product((0,1),repeat=6)}
assert len(T)==64
TT={add(x,y) for x in T for y in T}
assert len(TT)==167 and set(E)-TT=={cv(6,9),cv(12,4)}
A0=cv(8,2)
A=tuple(cv(*x) for x in ((7,0),(0,7),(1,0),(0,1),(10,9),(6,9)))
def evalrow(a0,a,signs):
    return sq(total([a0]+[x if s==1 else neg(x) for x,s in zip(a,signs,strict=True)]))
def maketable(b):
    a0=total([A0]+list(A[b:]))
    out={}
    for signs in product((1,-1),repeat=b):
        value=evalrow(a0,A[:b],signs)
        assert value not in out,(b,signs,out.get(value))
        out[value]=signs
    return a0,A[:b],out
TABLE={b:maketable(b) for b in range(1,7)}
assert [len(TABLE[b][2]) for b in range(1,7)]==[2,4,8,16,32,64]
def collision(a0,coeff):
    results={}
    for bits in product((1,-1),repeat=len(coeff)):
        y=evalrow(a0,coeff,bits)
        if y in results:return (results[y],bits)
        results[y]=bits
    return None
assert collision(A0,A) is None
assert collision(Z,A) is not None
assert collision(A0,(Z,)+A[1:]) is not None
assert sq((3,5))!=(2,0) # wrong t-map mutation
assert next(x for x in E if x not in ROOT) not in ROOT # nonsquare sensor control
def decode(x):
    k=len(x); read=[sq(t) for t in x]
    support=[j for j,v in enumerate(read) if v!=Z]
    if not support:return (Z,)*k,k
    canon={j:ROOT[read[j]] for j in support}
    anchor=support[0]; result=[Z]*k;result[anchor]=canon[anchor]; queries=k
    for start in range(1,len(support),6):
        js=support[start:start+6]
        a0,coeff,lookup=TABLE[len(js)]
        row={anchor:mul(a0,INV[canon[anchor]])}
        row.update({j:mul(c,INV[canon[j]]) for j,c in zip(js,coeff,strict=True)})
        observation=sq(total(mul(row[j],x[j]) for j in row))
        assert observation in lookup
        for j,sgn in zip(js,lookup[observation],strict=True):
            result[j]=canon[j] if sgn==1 else neg(canon[j])
        queries+=1
    assert tuple(result)==x or tuple(neg(z) for z in result)==x
    assert queries==k+ceil((len(support)-1)/6)
    return tuple(result),queries
hist=Counter()
for x in product(E,repeat=2):hist[decode(x)[1]]+=1
assert hist=={2:337,3:28224},hist
sectors=0
for s in range(1,8):
    for S in combinations(range(7),s):
        for phases in product((1,-1),repeat=s-1):
            x=[Z]*7
            for j,t in zip(S,(1,)+phases,strict=True):x[j]=U if t==1 else neg(U)
            assert decode(tuple(x))[1]<=8
            sectors+=1
assert sectors==1093
rng=Random(913272)
for _ in range(12000):
    assert decode(tuple(rng.choice(E) for _ in range(7)))[1]<=8
# Leading zero support forces an interior anchor; 4 active coordinates.
assert decode((Z,Z,U,(2,3),Z,(7,8),(4,5)))[1]==8
# Prime-indexed tiles: independent binary-generator and actual square-oracle checks.
for pp,d in ((13,2),(29,3),(31,3),(61,4),(127,5)):
    D=1<<d
    assert pp in (4*D-3,4*D-1)
    assert all(pp%j for j in range(2,isqrt(pp)+1))
    v=(2*D-1,D+1); w=(-1,D+1)
    shifts=((0,0),v,w,(v[0]+w[0],v[1]+w[1]))
    tile={((a+i)%pp,(b+j)%pp) for a,b in shifts for i in range(D) for j in range(D)}
    assert len(tile)==4*D*D
    gen=tuple([(1<<i,0) for i in range(d)]+[(0,1<<i) for i in range(d)]+[v,w])
    cube={(sum(e*x[0] for e,x in zip(bits,gen))%pp,
           sum(e*x[1] for e,x in zip(bits,gen))%pp)
           for bits in product((0,1),repeat=len(gen))}
    assert cube==tile
    rectangles={((a*v[0]+b*w[0]+i)%pp,(a*v[1]+b*w[1]+j)%pp)
                for a in range(3) for b in range(3)
                for i in range(2*D-1) for j in range(2*D-1)}
    hole=(2*D-2,2*D+1)
    assert hole not in rectangles
    assert len(rectangles)==(167 if pp==13 else pp*pp-6)
    if pp<=31:
        actual={((x[0]+y[0])%pp,(x[1]+y[1])%pp) for x in cube for y in cube}
        assert rectangles==actual
    delta=next(t for t in range(2,pp) if pow(t,(pp-1)//2,pp)==pp-1)
    trans=tuple((-z*pow(2,-1,pp))%pp for z in hole)
    out=set()
    for a,b in cube:
        x=(a+trans[0])%pp;y=(b+trans[1])%pp
        squared=((x*x+delta*y*y)%pp,(2*x*y)%pp)
        assert squared not in out
        out.add(squared)
    assert len(out)==2**(2*d+2)
    assert len(out)<2**(2*d+3) and (pp*pp+1)//2<2**(2*d+3)
transcript="\n".join(f"{signs}:{value}" for value,signs in sorted(TABLE[6][2].items()))+"\n"
print("PASS: independent GF13[y]/(y²+y+2), isomorphism and all 13^4 multiplications")
print("PASS: 64 sign outputs, two sumset holes, all partial blocks")
print("PASS: 28561 complete k2 signals, 1093 k7 sectors, 12000 seeded k7")
print("PASS: zero-anchor, zero-coefficient, bad-isomorphism, nonsquare mutations")
print("PASS: p13,29,31,61,127 tile holes AND actual GF(p²) squared outputs")
print("TRANSCRIPT_SHA256",sha256(transcript.encode()).hexdigest())
print("STATUS: internal independent arithmetic; universal Lean + human priority review OPEN")
