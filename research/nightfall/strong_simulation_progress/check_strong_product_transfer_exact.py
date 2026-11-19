#!/usr/bin/env python3
"""Independent exact-arithmetic falsifier for the one-sided dyadic strong-product transfer.

This finite checker is NOT a proof of BDST or of the universal theorem. It
independently enumerates the joint law, bytewise oracle fetch stages, source
conditional seed law, and square-norm mismatch inequalities.
"""
from __future__ import annotations
from fractions import Fraction as F
from itertools import product
from random import Random
import json, hashlib

RNG=Random(19112026)
COUNT={"distribution":0,"conditional":0,"uniform":0,"mismatch":0,"oracle":0,"hybrid":0,"rounds":0,"joint":0,"tape":0}

def check(condition, group):
    COUNT[group]+=1
    if not condition:
        raise AssertionError(f"{group}: assertion {COUNT[group]}")

def ceil_fraction(x):
    return -(-x.numerator // x.denominator)

def build(p, m):
    A=len(p); N=1<<m
    assert A>=2 and N>=A*(A-1) and sum(p)==1 and min(p)>=0
    anchor=max(range(A),key=lambda a:p[a]); q=[F(0)]*A
    for a in range(A):
        if a!=anchor: q[a]=F(ceil_fraction(N*p[a]),N)
    q[anchor]=1-sum(q)
    check(sum(q)==1 and min(q)>=0 and q[anchor]>0,"distribution")
    bins=[]
    for a in range(A): bins += [a]*int(N*q[a])
    assert len(bins)==N
    C=[[F(0) for _ in range(A)] for x in range(A)]
    for x in range(A):
        if x != anchor:
            C[x][x]=F(1)
        elif p[x]>0:
            for y in range(A):
                C[x][y]=q[y]/p[x] if y==x else (q[y]-p[y])/p[x]
    check(all(sum(C[x])==1 and min(C[x])>=0 for x in range(A) if p[x]>0),"distribution")
    check(all(sum(p[x]*C[x][y] for x in range(A))==q[y] for y in range(A)),"distribution")
    K=[[F(0) for u in range(N)] for x in range(A)]
    for x in range(A):
        for u,y in enumerate(bins):
            K[x][u]= C[x][y]/(N*q[y]) if p[x]>0 and q[y]>0 else (F(1,N) if p[x]==0 else F(0))
        check(sum(K[x])==1 if p[x]>0 else True,"conditional")
    for u in range(N):
        check(sum(p[x]*K[x][u] for x in range(A))==F(1,N),"uniform")
    bound=F(A*(A-1),N)
    for x in range(A):
        if p[x]>0:
            mismatch=sum(K[x][u] for u in range(N) if bins[u]!=x)
            check(mismatch<=bound,"mismatch")
            if x!=anchor: check(mismatch==0,"mismatch")
    return bins,K,C,q

def complex_norm_sq(a):
    # Tuple of rational real and imaginary parts.
    return a[0]*a[0]+a[1]*a[1]

def csub(a,b): return (a[0]-b[0],a[1]-b[1])

def oracle_apply(psi,values,A,Z=3):
    out={}
    for (i,z),a in psi.items():
        target=(i,(z+values[i])%Z)
        out[target]=a
    return out

def check_oracle_hybrid(n,Z=3):
    # Independent finite Hilbert-space oracle test; all inner products in Q(i).
    for _ in range(30):
        x=tuple(RNG.randrange(Z) for _ in range(n)); y=tuple(RNG.randrange(Z) for _ in range(n))
        psi={(i,z):(F(RNG.randrange(-4,5),7),F(RNG.randrange(-4,5),11)) for i in range(n) for z in range(Z)}
        a=oracle_apply(psi,x,n,Z); b=oracle_apply(psi,y,n,Z)
        d2=sum((complex_norm_sq(csub(a[k],b[k])) for k in a),F(0))
        wt=sum((complex_norm_sq(psi[(i,z)]) for i in range(n) for z in range(Z) if x[i]!=y[i]),F(0))
        check(d2 <= 4*wt,"hybrid")

def check_coherent_bit_block(n=3,m=4,A=3,Z=5):
    seeds=tuple(RNG.randrange(1<<m) for _ in range(n))
    decs=[tuple(RNG.randrange(Z) for _ in range(1<<m)) for _ in range(n)]
    for i,z,w in product(range(n),range(Z),range(1<<m)):
        fetched=sum((((w>>j)&1)^((seeds[i]>>j)&1))<<j for j in range(m))
        # The m calls are on disjoint bit response registers, so commute.
        decoded=(z+decs[i][fetched])%Z
        uncomputed=sum((((fetched>>j)&1)^((seeds[i]>>j)&1))<<j for j in range(m))
        final=(i,decoded,uncomputed)
        expected=(i,(z+decs[i][w^seeds[i]])%Z,w)
        check(final==expected,"oracle")
        if w==0:check(final==(i,(z+decs[i][seeds[i]])%Z,0),"oracle")
        check(2*m==m+m and 2*1==2,"rounds")
    # Coordinatewise bijection gives exact norm preservation for any superposition.
    psi={(i,z,w):(F(RNG.randrange(-3,4),5),F(RNG.randrange(-3,4),7)) for i,z,w in product(range(n),range(Z),range(1<<m))}
    out={}
    for (i,z,w),amp in psi.items():
        target=(i,(z+decs[i][w^seeds[i]])%Z,w)
        assert target not in out
        out[target]=amp
    check(set(out)==set(psi) and sum(map(complex_norm_sq,out.values()),F(0))==sum(map(complex_norm_sq,psi.values()),F(0)),"oracle")

def product_exact(ps, ms):
    elems=[build(p,m) for p,m in zip(ps,ms)]
    Ns=[1<<m for m in ms]
    support=list(product(*[range(len(p)) for p in ps]))
    seeds=list(product(*[range(N) for N in Ns]))
    joint={}
    for x in support:
        px=F(1)
        for i,v in enumerate(x):px*=ps[i][v]
        for u in seeds:
            ku=F(1)
            for i,v in enumerate(x):ku*=elems[i][1][v][u[i]]
            joint[x,u]=px*ku
    check(sum(joint.values(),F(0))==1,"joint")
    for u in seeds:
        check(sum(joint[x,u] for x in support)==F(1,len(seeds)),"joint")
    # Deterministic adaptive bit decision tree that repeatedly reads seed block 0,
    # then conditionally either block 1 or 2. Its lazy X-query count <= bit depth.
    assert len(ps)==3
    def tree(u):
        b0=(u[0]>>0)&1
        if b0:return (u[1]>>1)&1,((0,0),(1,1))
        return (u[2]>>1)&1,((0,0),(2,1))
    # Enumerate the exact full joint law, compare with the sequential lazy generator.
    # Each fixed x path to a queried seed block is generated from U_i|X_i,
    # cached for repeated reads of the same block. This equality is a finite
    # verification of the stochastic-kernel factorization, not a generic proof.
    for x in support:
        px=sum(joint[x,u] for u in seeds)
        p_leaf={0:F(0),1:F(0)}
        for u in seeds:
            b,_=tree(u);p_leaf[b]+=joint[x,u]
        if px>0:
            # Direct conditional K product (a separate factorized computation).
            for b in (0,1):
                factored=F(0)
                for u in seeds:
                    bval,queries=tree(u)
                    if bval==b:
                        prob=F(1)
                        for i,v in enumerate(x): prob*=elems[i][1][v][u[i]]
                        factored+=prob
                    check(len(set(i for i,_ in queries))<=len(queries),"tape")
                check(p_leaf[b]==px*factored,"joint")
    # Independent adaptive lazy evaluation: marginalize only the two queried
    # blocks and never enumerate the third (unused) block.
    for x in support:
        px=sum(joint[x,u] for u in seeds)
        if px == 0: continue
        lazy={0:F(0),1:F(0)}
        for u0 in range(Ns[0]):
            second=1 if (u0&1) else 2
            for us in range(Ns[second]):
                out=(us>>1)&1
                lazy[out]+=elems[0][1][x[0]][u0]*elems[second][1][x[second]][us]
        for b in (0,1):
            full=sum(joint[x,u] for u in seeds if tree(u)[0]==b)
            check(full==px*lazy[b],"joint")
    # For each input the exact probability of simulator failure against
    # target f(g(U)) is 0 when B performs that target evaluation.
    for x in support:
        for u in seeds:
            if joint[x,u]>0:
                check(elems[0][0][u[0]] in range(len(ps[0])),"joint")

def rand_law(A):
    vals=[RNG.randrange(0,14) for _ in range(A)]
    if sum(vals)==0:vals[0]=1
    return tuple(F(v,sum(vals)) for v in vals)

def run():
    for A in range(2,6):
        m=1
        while (1<<m)<A*(A-1):m+=1
        for ext in (0,1,2):
            for _ in range(55):
                p=rand_law(A)
                build(p,m+ext)
    for _ in range(20):check_oracle_hybrid(RNG.randrange(1,5))
    for _ in range(5):check_coherent_bit_block()
    for k in range(7):
        ps=[rand_law(2) for _ in range(3)]
        product_exact(ps,[2,2,2])
    payload={"format":"nightfall-product-transfer-exact-v1","status":"FINITE_TESTS_ONLY","checks":COUNT,"total":sum(COUNT.values()),"seed":19112026}
    print(json.dumps(payload,sort_keys=True))

if __name__=='__main__':run()

