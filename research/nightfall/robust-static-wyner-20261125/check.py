from itertools import product, combinations
from collections import defaultdict
from fractions import Fraction as F
from functools import reduce
from operator import xor
from math import prod
from random import Random
rng=Random(20261125)
# independent mode inequality: exhaustive ternary 2-coordinate isolated sets,
# integer product masses; all binary 3-coordinate isolated sets.
modes=0
for dims in [(2,2,2),(3,3)]:
    pts=list(product(*(range(n) for n in dims)))
    for mask in range(1<<len(pts)):
        U=[z for i,z in enumerate(pts) if mask>>i&1]
        if any(sum(a!=b for a,b in zip(x,y))==1 for x,y in combinations(U,2)): continue
        for weights in product(*(list(w for w in product(range(3),repeat=n) if sum(w)) for n in dims)):
            mode=tuple(max(range(n),key=lambda i:w[i]) for n,w in zip(dims,weights))
            mass=lambda z:prod(w[i] for w,i in zip(weights,z))
            assert sum(mass(z) for z in U if z!=mode)<=prod(map(sum,weights))-sum(map(mass,U))
            modes+=1
# primitive tensor fibers: compare every irredundant subset to a reference
# through disjoint circuit peeling; check actual local variation count.
def rows(L):
    for a in product((1,2,3),repeat=L):
        v=1; width=1
        for x in a:
            v=(v if x&1 else 0) ^ ((v<<width) if x&2 else 0); width*=2
        yield a,v
subsets=pairs=0; maxima={}
for L in range(1,4):
    R=list(rows(L)); groups=defaultdict(list)
    for k in range(1, min(5,len(R))+1):
        for A in combinations(range(len(R)),k):
            span={0}
            for i in A:
                v=R[i][1]
                if v in span: break
                span|={u^v for u in span}
            else:
                f=reduce(xor,(R[i][1] for i in A),0); groups[f].append(A); subsets+=1
    maxima[L]=max(map(len,groups.values()))
    for Aset in groups.values():
        B=set(Aset[0])
        for A in Aset:
            A=set(A); diff=A^B; sites=set(); anchor={i:i for i in A&B}; c=0
            while diff:
                C=next(set(S) for k in range(1,len(diff)+1) for S in combinations(sorted(diff),k) if reduce(xor,(R[i][1] for i in S),0)==0)
                assert C&A and C&B
                varying={j for j in range(L) if len({R[i][0][j] for i in C})>1}
                assert len(varying)<=len(C)-2
                sites|=varying;c+=1
                for i in C&A: anchor[i]=min(C&B)
                diff-=C
            assert len(sites)<=max(0,len(A^B)-2*c)
            assert all(all(R[i][0][j]==R[a][0][j] for j in range(L) if j not in sites) for i,a in anchor.items())
            pairs+=1
# exact scalar leaf domination Schur formula including equality boundaries
risk=0
for p0,p1,m0,m1,v0,v1,k in product([F(1,4),F(1,2),F(3,4)],[F(1,4),F(1,2),F(3,4)],[F(0),F(1,2),F(1)],[F(0),F(1,2),F(1)],[F(0),F(1,4)],[F(0),F(1,4)],[F(1),F(2),F(4)]):
    a=k*p0-p1; d=m0-m1
    if a<=0: continue
    # exact maximum of p1*(t-m1)^2-k*p0*(t-m0)^2
    peak=m0+p1*d/a
    direct=lambda t:p1*(t-m1)**2-k*p0*(t-m0)**2
    predicted=k*p0*p1*d*d/a
    assert direct(peak)==predicted
    assert all(direct(peak+s)<=predicted for s in (F(-3),F(-1,2),F(0),F(1,3),F(5)))
    risk+=1
print('mode rectangle cases:',modes,'primitive subsets:',subsets,'reference comparisons:',pairs,'maxima:',maxima,'risk cases:',risk)
# Online rank compiler against all secrets under random adaptive policies.
# A leaf's full consistent secret set is enumerated, no Gaussian elimination.
rank_cases=0
for k in range(1,7):
    for trial in range(100):
        tables=[[rng.randrange(1<<k) for _ in range(1<<j)] for j in range(5)]
        for s in range(1<<k):
            h=0; span={0}; tape=[]; requested=[]
            for tab in tables:
                a=tab[h]; bit=(a&s).bit_count()%2; requested.append(a)
                if a not in span:
                    tape.append(bit); span|={a^x for x in span}
                h=2*h+bit
            consistent=[z for z in range(1<<k) if all((a&(s^z)).bit_count()%2==0 for a in requested)]
            assert len(consistent)*(1<<len(tape))==1<<k
            rank_cases+=1
# Geometric terminal tolerance allocation: p=2, rho=1/8 and c=1.
# w_j=2^(-3*j) gives exact rational powers w_j^(1/3), w_j^(2/3).
allocation=0
for horizon,eps in product(range(1,31),[F(1,64),F(1,16),F(1,4),F(1,2)]):
    weights=[F(1,8**j) for j in range(horizon)]
    S=sum(F(1,4**j) for j in range(horizon))
    e=[min(F(1,2),eps*2**j/S) for j in range(horizon)]
    assert sum(w*x for w,x in zip(weights,e))<=eps
    assert sum(1/x**2 for x in e if x<F(1,2))<=S**3/eps**2
    assert all(x>=min(F(1,2),eps/S) for x in e)
    allocation+=1
# Exact zero-sum padding counterexample: many nonprimitive 4-row supports
# f plus a 3-row local circuit away from f; primitive bound cannot count these.
padding=[]
for L in range(2,8):
    f=(1,)*L; supports=set()
    for tail in product((1,2,3),repeat=L-1):
        if tail==f[1:]: continue
        supports.add(frozenset([f,(1,)+tail,(2,)+tail,(3,)+tail]))
    assert len(supports)==3**(L-1)-1
    padding.append(len(supports))
print('online rank cases:',rank_cases,'exact tolerance allocations:',allocation,'padding counts:',padding)
