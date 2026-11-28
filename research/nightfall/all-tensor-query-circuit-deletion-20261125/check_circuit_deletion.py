from itertools import product, combinations
from collections import defaultdict
from fractions import Fraction as F
from functools import reduce
from operator import xor
from random import Random
from math import prod
from hashlib import sha256

# Independent checker: circuit recognition via prefix span; direct secret-frequency
# accumulation versus recursive normalized deletion. No use of Markov/BH or proof
# localization for identifying circuits.
def tensor_rows(q,L):
    out=[]
    for factors in product(range(1,2**q), repeat=L):
        v=1; width=1
        for a in factors:
            v=reduce(xor,(v<<(i*width) for i in range(q) if a>>i&1),0)
            width*=q
        out.append((factors,v))
    return out

def independent(vals):
    span={0}
    for v in vals:
        if v in span: return False
        span |= {v^w for w in span}
    return True

def key(s,rows): return reduce(xor,(rows[i][1] for i in s),0)

def circuits(s,rows):
    return [frozenset(c) for k in range(3,len(s)+1) for c in combinations(sorted(s),k)
            if key(c,rows)==0 and independent([rows[i][1] for i in c[:-1]])]

def variations(c,rows):
    return tuple(j for j in range(len(rows[0][0])) if len({rows[i][0][j] for i in c})>1)

def normalized(s,rows,cache):
    if s in cache: return cache[s]
    cs=circuits(s,rows)
    if not cs: out={s:F(1)}
    else:
        out=defaultdict(F)
        for c in cs:
            for t,w in normalized(s-c,rows,cache).items(): out[t]+=w/len(cs)
    cache[s]=out
    return out

def direct_aggregate(poly,rows):
    out=defaultdict(F)
    for s,w in poly.items(): out[key(s,rows)]+=w
    return {k:v for k,v in out.items() if v}

rng=Random(20261125)
monomials=dependent=checks=0
for q,L,d in ((2,1,3),(2,2,6),(2,3,5),(3,1,5)):
    rows=tensor_rows(q,L); cache={}; byfreq=defaultdict(int)
    allsets=[frozenset(s) for k in range(min(d,len(rows))+1) for s in combinations(range(len(rows)),k)]
    for s in allsets:
        cs=circuits(s,rows); dep=not independent([rows[i][1] for i in s]); assert bool(cs)==dep
        for c in cs:
            J=variations(c,rows); assert len(J)<=len(c)-2
            assert len({tuple(rows[i][0][j] for j in range(L) if j not in J) for i in c})==1
        out=normalized(s,rows,cache)
        assert sum(out.values())==1
        assert all(t<=s and independent([rows[i][1] for i in t]) and key(s,rows)==key(t,rows) for t in out)
        if dep: assert all(len(t)<=len(s)-3 for t in out)
        else: assert out=={s:F(1)}; byfreq[key(s,rows)]+=1
        monomials+=1; dependent+=dep
    for _ in range(40):
        P={s:F(rng.randrange(-5,6),7) for s in rng.sample(allsets,min(50,len(allsets)))}
        G=defaultdict(F)
        for s,c in P.items():
            for t,w in normalized(s,rows,cache).items(): G[t]+=c*w
        assert direct_aggregate(P,rows)==direct_aggregate(G,rows)
        checks+=1
    print('q,L,d',q,L,d,'monomials',len(allsets),'max primitive fiber',max(byfreq.values()))

# Explicit exact local matrices for each 3-variable circuit-count/deletion map.
# On one block, compute each entry from action on all Walsh monomials;
# verify uniform-mixing positivity and preservation of constants.
pts=list(product((-1,1),repeat=3)); B=range(3)
walsh=lambda x,s:prod(x[i] for i in s)
allsubs=[tuple(s) for k in range(4) for s in combinations(B,k)]
local=0
for mode in ('count','delete'):
    A=[]
    for x in pts:
        row=[]
        for y in pts:
            # only full 3-row circuit contributes, count retains, deletion erases
            target=walsh(x,tuple(B)) if mode=='count' else 1
            row.append(F(target*walsh(y,tuple(B)),8))
        A.append(row)
    assert all(sum(r)==0 for r in A)
    c=8*max(sum(abs(z) for z in r) for r in A)
    T=[[F(1,8)+v/c for v in r] for r in A]
    assert all(sum(r)==1 and min(r)>=0 for r in T)
    for s in allsubs:
        for i,x in enumerate(pts):
            expected=(walsh(x,s) if mode=='count' else 1) if len(s)==3 else 0
            assert sum(A[i][j]*walsh(y,s) for j,y in enumerate(pts))==expected
            local+=1
print('PASS',monomials,'monomials;',dependent,'dependent;',checks,'signed polynomial equivalences;',local,'local operator checks')
