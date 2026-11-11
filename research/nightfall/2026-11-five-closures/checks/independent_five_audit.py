#!/usr/bin/env python3
"""NIGHTFALL Five Closure Audits: exact, dependency-free finite falsification.
This script does NOT prove universal inequalities or infinite-product measurability.
"""
from itertools import combinations, product
from collections import defaultdict
from random import Random
from fractions import Fraction as Q

rng=Random(20261111)

# P1: exact Holder inequality, selecting b_j=a_j**5 and squaring.
p1=0
for r in range(1,15):
    for _ in range(90):
        a=[rng.randrange(8) for j in range(r)]
        if not any(a): continue
        assert sum(v**6 for v in a)**5 <= r*r*sum(v**10 for v in a)**3
        p1+=1

# P2: for pure order-three Hoeffding energy v_S, the fractional
# primal vertex cover x_i=1/3 and dual packing y_S=v_S both cost V.
p2=0
for n in range(3,12):
    edges=list(combinations(range(n),3))
    for _ in range(100):
        v={S:Q(rng.randrange(9),rng.randrange(1,11)) for S in edges}
        I=[sum((v[S] for S in edges if i in S),Q()) for i in range(n)]
        V=sum(v.values(),Q())
        assert Q(sum(I,Q()),3)==V
        assert all(sum((v[S] for S in edges if i in S),Q())==I[i] for i in range(n))
        p2+=1

# P3: finite Walsh-polynomial sections and exact maximal-order recovery.
def eval_f(x,terms):
    return sum(c*(-1 if (S&x).bit_count()%2 else 1) for S,c in terms.items())
def section_terms(terms,A,x):
    out=defaultdict(int)
    for S,c in terms.items():
        out[S&~A] += c*(-1 if (S&A&x).bit_count()%2 else 1)
    return {S:c for S,c in out.items() if c}
p3=0
for n in range(1,8):
    for rep in range(55):
        d=rng.randrange(1,min(n,3)+1)
        terms={sum(1<<i for i in S):rng.randrange(-3,4)
               for k in range(d+1) for S in combinations(range(n),k)}
        terms={s:c for s,c in terms.items() if c}
        if not terms: continue
        values=[eval_f(x,terms) for x in range(1<<n)]
        palette=sorted(set(values))
        if len(palette)<2: continue
        delta=min(b-a for a,b in zip(palette,palette[1:]))
        budget=d*d*min((len(palette)-1)**2,Q(2*(palette[-1]-palette[0]),delta))
        for x in range(1<<n):
            A=0; rounds=0
            while True:
                coef=section_terms(terms,A,x)
                nonzero=[S for S in coef if S]
                if not nonzero:break
                height=max(S.bit_count() for S in nonzero)
                S=min(S for S in nonzero if S.bit_count()==height)
                assert S&A==0
                A|=S;rounds+=1
                assert rounds<=budget
            assert all(eval_f(y,terms)==values[x]
                       for y in range(1<<n) if (y&A)==(x&A))
            p3+=1

# P4: compute Bayes risks directly from finite observation fibers,
# not by substituting the proposed closed form.
def fixed_risk(m,s,obs_addr,obs_leaf):
    K=m**s
    fibers=defaultdict(lambda:[0,0,0])
    for address in product(range(m),repeat=s):
        leaf_index=sum(v*m**(s-i-1) for i,v in enumerate(address))
        for bits in product((-1,1),repeat=K):
            seen=(tuple(address[i] for i in range(s) if obs_addr>>i&1),
                  tuple(bits[i] for i in range(K) if obs_leaf>>i&1))
            row=fibers[seen]; row[0]+=1;row[1]+=bits[leaf_index];row[2]+=1
    total=m**s*2**K
    return Q(sum(v[2] for v in fibers.values()),total)-sum(
        (Q(v[1]**2,v[0]*total) for v in fibers.values()),Q())
p4=0
for s,m in ((1,2),(1,3),(2,2)):
    for amask in range(1<<s):
        for lmask in range(1<<(m**s)):
            h=amask.bit_count();q=lmask.bit_count()
            got=fixed_risk(m,s,amask,lmask)
            expected=1-Q(q,m**(2*s-h))
            assert got==expected,(s,m,amask,lmask,got,expected)
            p4+=1

print('P1 exact rank profiles:',p1)
print('P2 exact cubic fractional primal-dual:',p2)
print('P3 finite exact recovery paths:',p3)
print('P4 exact Bayes risks:',p4)
print('PASS: finite tests only; no universal mathematical promotion')
