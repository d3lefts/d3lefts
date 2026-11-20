#!/usr/bin/env python3
"""Exact independent finite adversarial audit of Conjecture E cover-to-frame.

All computations use binary masks, integers, and exact rational comparisons.
The GGMT Polynomial Freiman-Ruzsa theorem is EXTERNAL and not verified here.
"""
from itertools import combinations
from math import comb
from random import Random
from hashlib import sha256
from pathlib import Path

rng = Random(20261119)
checks = 0
dense_cases = 0
cover_cases = 0

def check(test, label):
    global checks
    assert test, label
    checks += 1

def rank(vectors):
    pivots = {}
    for v in vectors:
        a = v
        while a:
            bit = a.bit_length() - 1
            if bit in pivots:
                a ^= pivots[bit]
            else:
                pivots[bit] = a
                break
    return len(pivots)

def parity_sign(x):
    return -1 if x.bit_count() % 2 else 1

def dense_fourier_certificate(A, h):
    """Construct Bogolyubov's annihilator V from the *exact* Fourier spectrum."""
    global dense_cases
    M = 1 << h
    A = set(A)
    assert A and all(0 <= a < M for a in A)
    a = len(A)
    shat = [sum(parity_sign(freq & x) for x in A) for freq in range(M)]
    # (shat/M)^2 >= (a/M)^3/2, tested without floating point.
    spectrum = [freq for freq, val in enumerate(shat)
                if 2 * val * val * M >= a**3]
    V = {x for x in range(M)
         if all(parity_sign(freq & x) == 1 for freq in spectrum)}
    check(len(spectrum) * a * a <= 2 * M * M,
          ('spectrum dimension budget', h, a))
    check(len(V) and len(V) & (len(V)-1) == 0, ('subspace order',h,a))
    check(all(x ^ y in V for x in V for y in V), ('subspace closure',h,a))
    check(0 in V, ('subspace zero',h,a))
    check((h - (len(V).bit_length()-1))*a*a <= 2*M*M,
          ('codimension bound',h,a))
    pair = [0]*M
    for x in A:
        for y in A:
            pair[x^y] += 1
    four = {u^v for u in range(M) if pair[u]
                   for v in range(M) if pair[v]}
    check(V <= four, ('Bogolyubov fourfold certificate',h,a,tuple(A)))
    for v in V:
        actual = sum(pair[u]*pair[v^u] for u in range(M))
        # Fourier inversion: sum_x shat(x)^4 chi_x(v) = M * fourfold-tuples(v)
        predicted = sum(shat[z]**4 * parity_sign(z & v) for z in range(M))
        check(predicted == M*actual and actual>0,
              ('exact Fourier fourfold positivity',h,a,v))
    dense_cases += 1
    return V

# All nonempty A subsets of F2^h, h <= 4: exactly 1+3+15+65535.
for h in range(5):
    M=1<<h
    for mask in range(1,1<<M):
        dense_fourier_certificate([x for x in range(M) if mask & (1<<x)],h)

# Explicit dense fibers within affine covers, checking the original-row frame.
# We do not assume the covering subspace H lives inside span(R).
for trial in range(200):
    h = rng.randrange(5)
    m = 7
    M = 1 << h
    cosets = list(range(1 << (m-h)))
    rng.shuffle(cosets)
    selected = cosets[:rng.randrange(1,min(8,len(cosets))+1)]
    R = set()
    for coset in selected:
        # Always place at least one original row in every chosen cover coset.
        R.add((coset<<h) | rng.randrange(M))
        for x in range(M):
            if rng.randrange(4)!=0:
                R.add((coset<<h)|x)
    # The cover-to-frame theorem requires |H| <= |R|.
    for coset in selected:
        for x in range(M):
            if len(R)>=M: break
            R.add((coset<<h)|x)
    check(len(R)>=M,('subspace-size cover hypothesis',trial))
    actual = {row>>h for row in R}
    L = len(actual)
    biggest = max(actual, key=lambda t: sum((r>>h)==t for r in R))
    fiber={row&(M-1) for row in R if row>>h==biggest}
    a=len(fiber)
    check(a*L>=M,('dense cover fiber',trial,a,L,M))
    V = dense_fourier_certificate(fiber,h)
    pair={x^y for x in R for y in R}
    four={x^y for x in pair for y in pair}
    check(V <= four, ('translated fiber lies in 4R',trial))
    rk=rank(R)
    vd=len(V).bit_length()-1
    check(rk<=h+L, ('cover rank bound',trial,rk,h,L))
    check(rk<=vd+2*L*L+L,('actual V controls frame cost',trial))
    # Greedy row basis B subset R has full independence, c'=1.
    basis=[]
    for row in sorted(R):
        if rank(basis+[row])>len(basis):
            basis.append(row)
    check(len(basis)==rk and all(rank(basis[:i]+basis[i+1:])==rk-1
                                 for i in range(rk)),('basis frame',trial))
    cover_cases+=1

# Sparse/high-doubling negative control: cannot omit K by this argument.
n=64
size4=sum(comb(n,j) for j in range(5))
check(size4 < (1<<(n-1)),('sparse independent rank-vs-sumset',n))
check(1+comb(n,2)==2017 and (1+comb(n,2))>20*n,('large doubling basis example',n))
print(f"PASS exact cover-to-frame audit: {checks} assertions, {dense_cases} dense Fourier cases, {cover_cases} cover instances.")
print(f"SPARSE_CONTROL n={n}, rank={n}, |4R|={size4}, N4<={size4.bit_length()-1}, B=R gives c=c'=1.")
print("LIMIT: finite checker does NOT certify external PFR, the universal proof, Lean or novelty.")
print("SHA256", sha256(Path(__file__).read_bytes()).hexdigest())
