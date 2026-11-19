#!/usr/bin/env python3
"""Independent exact-rational adversarial replay: candidate binary Q2 fixed rows.

No numerical acceptance thresholds. For each bounded quadratic f, obtain
an *explicit* row-weight certificate when matrix entrywise norm S<=8.
This DOES NOT certify universal Grothendieck factorization, which is an
external analytic theorem. It tests exact Fourier extraction, polarisation,
row-score bounds and quantile-coupled hidden-coordinate identities.
"""
from fractions import Fraction as F
from itertools import product
from random import Random
from hashlib import sha256
from pathlib import Path
rng = Random(20261119)
assertions=0
instances=0
pair_tests=0
switch_tests=0

def ck(cond,tag):
    global assertions
    assert cond,tag
    assertions+=1

def poly(n,linear,B,x):
    return sum((linear[i]*x[i] for i in range(n)),F(0)) + sum((B[i][j]*x[i]*x[j] for i in range(n) for j in range(i+1,n)),F(0))

def build(n,typ):
    if typ=='linear':
        a=[rng.choice([-5,-3,-1,0,1,2,4]) for _ in range(n)]
        b=[[0]*n for _ in range(n)]
    elif typ=='ferromagnetic':
        a=[rng.choice([-2,0,2]) for _ in range(n)]
        b=[[0]*n for _ in range(n)]
        for i in range(n):
            for j in range(i+1,n): b[i][j]=b[j][i]=rng.choice([0,1,2,3])
    else:
        a=[rng.randint(-3,3) for _ in range(n)]
        b=[[0]*n for _ in range(n)]
        for i in range(n):
            for j in range(i+1,n): b[i][j]=b[j][i]=rng.randint(-4,4)
    words=list(product((-1,1),repeat=n))
    g=[poly(n,a,b,x) for x in words]
    lo=min(g);hi=max(g)
    if hi==lo: return None
    scale=F(1,hi-lo)
    fa=tuple(F(ai)*scale for ai in a)
    B=tuple(tuple(F(z)*scale for z in row) for row in b)
    f=tuple((F(v)-lo)*scale for v in g)
    return words,f,fa,B

def check_case(n,typ):
    global instances,pair_tests,switch_tests
    data=build(n,typ)
    if data is None: return
    words,f,a,B=data
    idx={x:j for j,x in enumerate(words)}
    ck(all(0<=z<=1 for z in f),'range')
    ck(sum(map(abs,a),F(0))<=F(1,2),'linear Fourier L1')
    # independently reconstruct Fourier degree <=2 by direct averaging:
    for i in range(n):
        ai=sum((f[j]*x[i] for j,x in enumerate(words)),F(0))/len(words)
        ck(ai==a[i],('Fourier linear',i))
        for k in range(i+1,n):
            bij=sum((f[j]*x[i]*x[k] for j,x in enumerate(words)),F(0))/len(words)
            ck(bij==B[i][k],('Fourier quadratic',i,k))
    even=[(f[idx[x]]+f[idx[tuple(-s for s in x)]])/2 for x in words]
    c=sum(f,F(0))/len(words)
    ck(all(abs(e-c)<=1 for e in even),'even quadratic norm')
    for x in words:
        ck(sum((B[i][j]*x[i]*x[j] for i in range(n) for j in range(i+1,n)),F(0))==even[idx[x]]-c,'quadratic parity')
    bilmax=max(abs(sum((x[i]*B[i][j]*y[j] for i in range(n) for j in range(n)),F(0))) for x in words for y in words)
    ck(bilmax<=4,'bilinear polarisation')
    # Independent *rational* explicit row certificate for instances with S<=8.
    # This certificate is not GP: it uses the stronger entrywise-S condition.
    row=[sum((abs(B[i][j]) for j in range(n)),F(0)) for i in range(n)]
    S=sum(row,F(0))
    if S>8: return
    p=tuple(z/S for z in row) if S else (F(1),)+(F(0),)*(n-1)
    w=tuple(2*abs(a[i])+p[i] for i in range(n))
    ck(sum(p,F(0))==1,'probability weights')
    ck(sum(w,F(0))<=2,'weight budget')
    for xi,x in enumerate(words):
        for yi,y in enumerate(words):
            lhs=(f[xi]-f[yi])**2
            rhs=289*sum((w[i] for i in range(n) if x[i]!=y[i]),F(0))
            ck(lhs<=rhs,('fixed Q2 row',n,typ,x,y,lhs,rhs))
            pair_tests+=1
    # Exact source-coupled latent theta tests, independent of the Fourier check.
    if n<=5:
        M=3
        pri=[F(1,6),F(1,3),F(1,2)]
        # random original Bernoulli component biases, including zeros/ones
        pars=[[rng.choice([F(0),F(1),F(1,4),F(1,2),F(3,4)]) for _ in range(n)] for th in range(M)]
        # Each U_i is a common uniform variable with threshold at each p_theta_i.
        # Exact mass on intervals between all sorted thresholds.
        interval=[]
        for i in range(n):
            boundaries=sorted(set([F(0),F(1)]+[pars[t][i] for t in range(M)]))
            interval.append([( (boundaries[k]+boundaries[k+1])/2, boundaries[k+1]-boundaries[k]) for k in range(len(boundaries)-1)])
        joint=F(0)
        for seeds in product(*interval):
            muw=F(1)
            for _,mass in seeds: muw*=mass
            vals=[]
            for th in range(M):
                xx=tuple(1 if seeds[i][0]<=pars[th][i] else -1 for i in range(n))
                vals.append(f[idx[xx]])
            joint+=muw*sum((pri[t]*pri[s]*abs(vals[t]-vals[s]) for t in range(M) for s in range(M)),F(0))
        pairtv=sum((w[i]*sum((pri[t]*pri[s]*abs(pars[t][i]-pars[s][i]) for t in range(M) for s in range(M)),F(0)) for i in range(n)),F(0))
        ck(joint*joint<=289*pairtv,('exact hidden coupling',n,typ,joint,pairtv))
        switch_tests+=1
    instances+=1

for n in range(2,8):
    for typ in ['linear','ferromagnetic','random']:
        for k in range(8 if n<=5 else 3):
            check_case(n,typ)
print(f'PASS {assertions} exact assertions, {instances} fully certified-instance row weights, {pair_tests} ordered input pairs, {switch_tests} hidden-coordinate coupling cases.')
print('LIMIT: universal GP factorization itself and global FUR/Lemma crux are NOT proved by this finite checker.')
print('SHA256',sha256(Path(__file__).read_bytes()).hexdigest())
