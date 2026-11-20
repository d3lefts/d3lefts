#!/usr/bin/env python3
"""Independent exact finite checker of subcube pair fibers and one-query truncation.

All arithmetic is integer/Fraction; finite tests do not prove the all-L theorem.
"""
from collections import Counter, defaultdict
from fractions import Fraction
from itertools import product

def rows(L):
    out=[]
    for a in product((1,2,3),repeat=L):
        value=0
        for x in range(1<<L):
            if all(a[j] & (1<<((x>>j)&1)) for j in range(L)):
                value |= 1<<x
        out.append(value)
    assert len(out)==3**L and len(set(out))==len(out)
    return out

def check_pair_fibers(L):
    R=rows(L)
    counts=Counter(a^b for a in (0,*R) for b in (0,*R))
    M=max(v for u,v in counts.items() if u)
    assert M==2*L+2,(L,M)
    assert all(counts[u]==2*L+2 for u in R)
    assert all(c in (2,6) for u,c in counts.items() if u and u not in R)
    by_distance=Counter()
    labels=list(product((1,2,3), repeat=L))
    for i,a in enumerate(labels):
        for j,b in enumerate(labels):
            if i==j:continue
            d=sum(x!=y for x,y in zip(a,b))
            by_distance[d]+=1
    assert sum(by_distance.values())==len(R)*(len(R)-1)
    print('EXACT_PAIR_FIBER_PASS',L,'n',len(R),'nonzero_values',len(counts)-1,
          'max',M,'distanced_pairs',sorted(by_distance.items()))

def check_quantum_truncation(L):
    R=[0]+rows(L)
    N=len(R)
    a=[1+(i*7)%5 for i in range(N)]
    b=[1+(i*3+2)%7 for i in range(N)]
    A=sum(z*z for z in a)
    B=sum(z*z for z in b)
    weights=[a[i]*b[i] for i in range(N)]
    p=[Fraction(z*z,A) for z in a]
    tau=Fraction(1,4*N)
    heavy={i for i in range(N) if p[i]>=tau}
    light=set(range(N))-heavy
    assert heavy and light,(L,heavy,light)
    assert len(heavy)<=int(Fraction(1,tau))
    den=A*B
    coeff=defaultdict(int)
    frob=Fraction(0)
    for i in range(N):
        for j in range(N):
            if i==j or (i in heavy and j in heavy):continue
            coeff[R[i]^R[j]]+=weights[i]*weights[j]
            frob+=Fraction(weights[i]**2*weights[j]**2,den**2)
    assert 0 not in coeff
    M=2*L+2
    parseval=Fraction(sum(c*c for c in coeff.values()),den**2)
    assert parseval <= M*frob <= 2*M*tau,(L,parseval,frob,tau)
    full_error=Fraction(0)
    total=1<<(1<<L)
    for s in range(total):
        phases=[1-2*((r&s).bit_count()%2) for r in R]
        whole=sum(w*ph for w,ph in zip(weights,phases))
        hterm=sum(weights[i]*phases[i] for i in heavy)
        f=Fraction(whole**2,den)
        g=Fraction(hterm**2 + sum(weights[i]**2 for i in light),den)
        assert 0<=f<=1 and 0<=g<=1
        error=f-g
        by_fourier=Fraction(sum(c*(1-2*((u&s).bit_count()%2)) for u,c in coeff.items()),den)
        assert error==by_fourier,(L,s,error,by_fourier)
        full_error+=error**2
    full_error/=total
    assert full_error==parseval,(L,full_error,parseval)
    print('EXACT_ONE_QUERY_TRUNCATION_PASS',L,'secrets',total,
          'heavy',len(heavy),'light',len(light),
          'mse',str(parseval),'frob',str(frob))

if __name__=='__main__':
    for L in range(1,6):check_pair_fibers(L)
    for L in range(1,4):check_quantum_truncation(L)
    print('SUBCUBE_ONE_QUERY_SIMULATION_EXACT_AUDIT_PASS')
