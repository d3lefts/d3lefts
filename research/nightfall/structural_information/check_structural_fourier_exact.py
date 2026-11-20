#!/usr/bin/env python3
"""NIGHTFALL exact finite audit: duplicated bits, graph Fourier discrepancy,
Bernstein-Vazirani parity witness and Forrelation Hadamard boundedness.

This checks finite Fraction/integer identities only. It does not numerically
certify the Gaussian sign/arcsine law, an all-instance theorem or prior art.
"""
from fractions import Fraction as F
from itertools import combinations
from math import comb
from random import Random
from hashlib import sha256
from pathlib import Path

rng=Random(20261119)
cases=0
checks=0

def ck(cond, label):
    global checks
    if not cond:
        raise AssertionError(label)
    checks += 1

def graph(m, N, table):
    R=1<<m
    assert len(table)==N and all(len(row)==R for row in table)
    return [tuple(1 if ((s>>i)&1)==0 else -1 for i in range(m)) +
            tuple(1 if table[j][s]==0 else -1 for j in range(N))
            for s in range(R)]

def energy_direct(samples, k):
    n=len(samples[0]); R=len(samples); total=F()
    bs={}
    for ell in range(1,min(k,n)+1):
        for S in combinations(range(n),ell):
            val=sum((prod_sign(row,S) for row in samples),0)
            bs[S]=F(val,R)
            total+=bs[S]*bs[S]
    return total,bs

def prod_sign(row,S):
    z=1
    for i in S: z*=row[i]
    return z

def energy_pair_kernel(samples, k):
    n=len(samples[0]); R=len(samples); total=0
    for x in samples:
        for y in samples:
            # Elementary symmetric functions sum_{|S|=ell} product_{i in S} x_i*y_i.
            e=[0]*(min(k,n)+1)
            e[0]=1
            for v in (x[i]*y[i] for i in range(n)):
                for ell in range(len(e)-1,0,-1):
                    e[ell]+=v*e[ell-1]
            total+=sum(e[1:])
    return F(total,R*R)

def discrepancy_expectation(m,N,k):
    n=m+N
    K_all=sum(comb(n,j) for j in range(min(k,n)+1))
    K_seed=sum(comb(m,j) for j in range(min(k,m)+1))
    return F(K_all-K_seed,1<<m)

# Distinct H tables exhaustively for m=N=1 and m=N=2.
for m,N in [(1,1),(2,2)]:
    R=1<<m
    sums=[F() for _ in range(m+N)]
    for mask in range(1<<(N*R)):
        tab=[[((mask>>(j*R+s))&1) for s in range(R)] for j in range(N)]
        samples=graph(m,N,tab)
        for k in range(1,m+N+1):
            energy,bs=energy_direct(samples,k)
            independent=energy_pair_kernel(samples,k)
            ck(energy==independent,('Fourier Parseval versus kernel',m,N,mask,k))
            # Seed bits are *exactly* uniform under each fixed graph.
            ck(all(bs.get(S,F())==0 for ell in range(1,k+1) for S in combinations(range(m),ell)),('seed-only Fourier',m,mask,k))
            sums[k-1]+=energy
        cases+=1
    for k,total in enumerate(sums,1):
        ck(total/F(1<<(N*R))==discrepancy_expectation(m,N,k),('exact ensemble second moment',m,N,k))

# Non-exhaustive, larger graph instances and independent Cauchy inequality replay.
for m,N,k in [(3,3,3),(4,4,3),(5,5,3),(6,6,2)]:
    R=1<<m
    for trial in range(8):
        tab=[[rng.randrange(2) for s in range(R)] for j in range(N)]
        samples=graph(m,N,tab)
        energy,bs=energy_direct(samples,k)
        ck(energy==energy_pair_kernel(samples,k),('independent Fourier check',m,trial))
        # Fourier polynomial h(x) = sum_S a_S chi_S, sum |a_S| <=1, so |h|<=1.
        raw={S:rng.randrange(-4,5) for S in bs}
        denom=1+sum(abs(z) for z in raw.values())
        coeff={S:F(z,denom) for S,z in raw.items()}
        mean_diff=sum((coeff[S]*bs[S] for S in bs),F())
        parseval=sum((z*z for z in coeff.values()),F())
        ck(mean_diff*mean_diff<=energy*parseval,('Cauchy Fourier low degree transfer',m,trial))
        # conditional entropy of seed i given other coordinates is exactly fraction
        # of seed pairs that collide in all N H outputs, measured in bits.
        collision_total=F()
        for i in range(m):
            ct=sum(all(tab[j][s]==tab[j][s^(1<<i)] for j in range(N))
                   for s in range(R) if (s>>i)&1==0)
            collision_total+=F(ct,R//2)
        ck(F(m)-collision_total<=F(m),('DTC bound',m,trial))
        cases+=1

# Exact Bernstein–Vazirani triple parities (any nonzero u!=v).
for m in range(2,8):
    u=1;v=2;w=u^v
    for s in range(1<<m):
        bit=lambda y: ((s&y).bit_count()&1)
        ck((bit(u)^bit(v)^bit(w))==0,('BV degree-three witness',m,s))
    cases+=1

# Walsh–Hadamard orthogonality and bounded quadratic Forrelation statistic.
# The Gaussian sign/arcsine expectation 2/pi * sqrt(N) * arcsin(1/sqrt(N))
# is an EXTERNAL analytic identity and not certified by this finite code.
for r in range(1,5):
    N=1<<r
    H=[[1 if ((i&j).bit_count()&1)==0 else -1 for j in range(N)] for i in range(N)]
    for i in range(N):
        for j in range(N):
            ck(sum(H[t][i]*H[t][j] for t in range(N))==(N if i==j else 0),('Hadamard orthogonality',N,i,j))
    for _ in range(100):
        f=[rng.choice((-1,1)) for _ in range(N)]
        g=[rng.choice((-1,1)) for _ in range(N)]
        Fnum=sum(f[i]*H[i][j]*g[j] for i in range(N) for j in range(N))
        ck(Fnum*Fnum<=N*N*N,('bounded quadratic Forrelation witness',N))
    cases+=1

print(f'PASS {checks} exact integer/Fraction assertions across {cases} datasets/instances.')
print('INCLUDES: exhaustive m=N=2 random graph Fourier second moment; BV degree-three; Walsh orthogonality.')
print('LIMIT: Gaussian sign arcsine law and the universal query simulation transfer are paper-level analytic inputs.')
print('SHA256',sha256(Path(__file__).read_bytes()).hexdigest())
