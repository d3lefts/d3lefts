#!/usr/bin/env python3
"""Independent exact 2^n physical-trace verifier for two-sided/one-sided
orthogonal block Werner kernel rigidity. No external packages.
"""
from fractions import Fraction as F
from itertools import product, combinations
from collections import defaultdict
from random import Random
from math import prod
import json

rnd=Random(20813)

def outer(u,v):
    return {(a,b):z*w.conjugate() for a,z in u.items() for b,w in v.items() if z*w}

def add(*Xs):
    out=defaultdict(complex)
    for X in Xs:
        for key,val in X.items(): out[key]+=val
    return {key:z for key,z in out.items() if z}

def trace_data(X,n):
    scores=[]
    for mask in range(1<<n):
        keep=[j for j in range(n) if not mask & (1<<j)]
        drop=[j for j in range(n) if mask & (1<<j)]
        Y=defaultdict(complex)
        for (a,b),z in X.items():
            if all(a[j]==b[j] for j in drop):
                Y[(tuple(a[j] for j in keep),tuple(b[j] for j in keep))]+=z
        score=sum(int(z.real)**2+int(z.imag)**2 for z in Y.values())
        scores.append(score)
    return scores

def q(X,n,ts):
    vals=trace_data(X,n)
    return sum((prod((-ts[j] for j in range(n) if mask>>j & 1),start=F(1))*val for mask,val in enumerate(vals)),F(0))

def norm2(u): return sum(int(z.real)**2+int(z.imag)**2 for z in u.values())
def tr(X): return sum((val for (a,b),val in X.items() if a==b),0j)
def sq(z):return int(z.real)**2+int(z.imag)**2

def test_case(n,r,d,ts,seed):
    R=Random(seed)
    # Each row-factor is supported on a distinct constant-symbol product word.
    # The column factors are unrestricted random complex superpositions.
    universe=list(product(range(d),repeat=n))
    Us=[];Vs=[]
    for i in range(r):
        Ui={(i,)*n:complex(R.choice([1,2,-2]),R.choice([0,1,-1]))}
        Vi={word:complex(R.randint(-2,2),R.randint(-2,2)) for word in R.sample(universe,min(7,len(universe)))}
        Vi={a:z for a,z in Vi.items() if z}
        if not Vi: Vi={(i,)*n:1+0j}
        Us.append(Ui);Vs.append(Vi)
    blocks=[outer(u,v) for u,v in zip(Us,Vs)]
    C=add(*blocks)
    A2=[norm2(u)*norm2(v) for u,v in zip(Us,Vs)]
    tau=[tr(B) for B in blocks]
    L=prod((1-t for t in ts),start=F(1))
    M=prod(ts,start=F(1))
    delta=[q(X,n,ts)-L*A for X,A in zip(blocks,A2)]
    assert min(delta)>=0
    lhs=q(C,n,ts)
    cross=lhs-sum((q(X,n,ts) for X in blocks),F(0))
    expected=(-1)**n*M*(sq(sum(tau))-sum(sq(z) for z in tau))
    assert cross==expected,(n,r,d,cross,expected)
    # Inequality in preceding papers
    assert lhs>=L*sum(A2)+expected
    # The exact decomposition at a SHARP boundary L=(r-1)*M odd, L=M even
    if n%2==0 and L==M:
        rhs=sum(delta)+M*sum(A2[i]-sq(tau[i]) for i in range(r))+M*sq(sum(tau))
        assert rhs==lhs
    if n%2==1 and L==(r-1)*M:
        rhs=sum(delta)+M*(r-1)*sum(A2[i]-sq(tau[i]) for i in range(r)) +M*sum(sq(tau[i]-tau[j]) for i in range(r) for j in range(i+1,r))
        assert rhs==lhs
    # Sharpened spectral gap for all positive 0<t<1
    if all(F(0)<t<F(1) for t in ts):
        gap=min(2*ts[j]*prod((1-ts[h] for h in range(n) if h!=j),start=F(1)) for j in range(n))
        for X,A,defect in zip(blocks,A2,delta):
            scores=trace_data(X,n)
            # P_+ = tensor_j (I+swap_j)/2; projective mass is
            # 2^-n sum_S ||Tr_S X||^2 / ||X||^2
            mass=F(sum(scores),2**n)
            assert mass<=A
            assert defect>=gap*(A-mass),(n,gap,defect,A,mass)
    return {'n':n,'r':r,'d':d,'Q':str(lhs),'trace_cross':str(cross),'delta':list(map(str,delta))}

def diagonal(n,coeff):
    return {((i,)*n,(i,)*n):complex(c,0) for i,c in enumerate(coeff) if c}

checks=[]
for n,r,d in [(2,2,4),(3,3,4),(4,3,4),(2,3,4),(3,2,4),(4,2,4)]:
    for j in range(8):
        checks.append(test_case(n,r,d,[F(1,2)]*n, n*1000+r*100+j))
    checks.append(test_case(n,r,d,[F(2,5),F(1,2),F(1,3),F(3,5)][:n],n*2000+r*100))

# Even zero locus: product projectors with balanced signed amplitudes.
for n,r,coeff in [(2,2,(1,-1)),(4,3,(1,1,-2)),(4,4,(1,1,-1,-1))]:
    C=diagonal(n,coeff)
    assert q(C,n,[F(1,2)]*n)==0
    pert=diagonal(n,[coeff[0]+1,*coeff[1:]])
    assert q(pert,n,[F(1,2)]*n)>0

# Odd endpoint for r>=3: unique aligned equal-weight phase class.
# Choose t algebraic via exact heterogeneous values where L=(r-1)M.
# For r=3,n=3: t=(1/2,1/2,1/3) => L/M=2.
for n,r,ts in [(3,3,[F(1,2),F(1,2),F(1,3)]),(1,3,[F(1,3)])]:
    assert prod((1-t for t in ts),start=F(1))==(r-1)*prod(ts,start=F(1))
    C=diagonal(n,(1,)*r)
    assert q(C,n,ts)==0
    assert q(diagonal(n,(1,)* (r-1)+(2,)),n,ts)>0

# Four-qutrit Lemnis witness: independent 16-trace calculation.
a=(0,0,0,0); c=(2,2,2,0); d=(2,2,2,2);b=(1,1,1,1)
u={a:1+0j,c:1+0j,d:1+0j}
C=add(outer(u,u),diagonal(4,(0,-1))) # diagonal(4,i=1) => b=1111
assert q(C,4,[F(1,2)]*4)==3

print(json.dumps({'status':'PASS','random_complex_exact_checks':len(checks),'even_boundary_zero_tests':3,'odd_boundary_zero_tests':2,'independent_four_qutrit_Q':'3','spectral_gap_bound':'PASS','sample':checks[0]},sort_keys=True,indent=2))
