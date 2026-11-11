#!/usr/bin/env python3
"""NIGHTFALL quadratic-backdoor transfer: exact, independently enumerated tests.

No numerical tolerances or floating-point comparisons. Python standard library only.
The test independently computes moments two ways:
  1. Full enumeration of product outcomes and conditional expectations.
  2. The orthogonal product basis (rational Hoeffding coefficients).
This verifier only falsifies finite instances. It is not a theorem prover, and
it does not certify the input quadratic influence theorem K=5043.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from math import prod
from random import Random
from collections import defaultdict
import hashlib
import json

K=5043
SEED=20261111
BIASES=[Q(1,2),Q(1,3),Q(1,4),Q(2,5),Q(1,17),Q(16,17),Q(1,97)]


def subsets(n):
    return (tuple(s) for j in range(n+1) for s in combinations(range(n),j))


def function_values(n, p, coeff):
    points=list(product((0,1),repeat=n))
    vals={x:sum((a*prod((Q(x[i])-p[i] for i in S))
                 for S,a in coeff.items()),Q(0)) for x in points}
    masses={x:prod(((p[i] if x[i] else 1-p[i]) for i in range(n)))
            for x in points}
    return points,vals,masses


def influence_enumerated(n,i,p,pts,vals,mass):
    res=Q(0)
    for x in pts:
        lo=list(x);lo[i]=0
        hi=list(x);hi[i]=1
        section=(1-p[i])*vals[tuple(lo)]+p[i]*vals[tuple(hi)]
        res+=mass[x]*(vals[x]-section)**2
    return res


def verify_instance(n,p,C,coeff):
    C=set(C)
    assert all(len(set(S)-C)<=2 for S,a in coeff.items() if a)
    points, vals, masses=function_values(n,p,coeff)
    E=sum((masses[x]*vals[x] for x in points),Q(0))
    V=sum((masses[x]*(vals[x]-E)**2 for x in points),Q(0))
    B=max(abs(y) for y in vals.values())
    I=[influence_enumerated(n,i,p,points,vals,masses) for i in range(n)]
    M=max(I)

    # Core conditional expectation, independently enumerated.
    core=sorted(C)
    g={}
    for x in points:
        total=Q(0)
        for y in product((0,1),repeat=len(core)):
            z=list(x)
            q=Q(1)
            for i,v in zip(core,y):
                z[i]=v
                q*=p[i] if v else 1-p[i]
            total+=q*vals[tuple(z)]
        g[x]=total
    Gmean=sum((masses[x]*g[x] for x in points),Q(0))
    A=sum((masses[x]*(g[x]-Gmean)**2 for x in points),Q(0))
    D=sum((masses[x]*(vals[x]-g[x])**2 for x in points),Q(0))

    # Independent Hoeffding-coefficient check: orthogonality under arbitrary biases.
    norms={S:a*a*prod((p[i]*(1-p[i]) for i in S))
           for S,a in coeff.items() if S and a}
    assert V==sum(norms.values(),Q(0))
    assert I==[sum((v for S,v in norms.items() if i in S),Q(0))
               for i in range(n)]
    assert A==sum((v for S,v in norms.items() if C.isdisjoint(S)),Q(0))
    assert D==sum((v for S,v in norms.items() if not C.isdisjoint(S)),Q(0))
    assert E==coeff.get((),Q(0))
    assert V==A+D
    assert D<=sum((I[i] for i in C),Q(0))
    assert D<=len(C)*M
    assert A*A<=K*B*B*M
    assert V*V<=(K+2*len(C))*B*B*M
    if M:
        return Q(V*V,B*B*M)
    assert V==0
    return Q(0)


def verify_defect_instance(n,p,C,coeff):
    C=set(C)
    assert all(len(S)<=3 for S in coeff)
    pts,vals,mass=function_values(n,p,coeff)
    B=max(abs(t) for t in vals.values())
    mu=sum((mass[x]*vals[x] for x in pts),Q(0))
    V=sum((mass[x]*(vals[x]-mu)**2 for x in pts),Q(0))
    I=[influence_enumerated(n,i,p,pts,vals,mass) for i in range(n)]
    M=max(I)
    delt=sum((a*a*prod(p[i]*(1-p[i]) for i in S)
              for S,a in coeff.items() if len(S)==3 and C.isdisjoint(S)),Q(0))
    H=lambda x:sum((a*prod((Q(x[i])-p[i]) for i in S)
                    for S,a in coeff.items() if len(S)==3 and C.isdisjoint(S)),Q(0))
    g=lambda x,t:sum((a*t**len(S)*prod((Q(x[i])-p[i]) for i in S)
                       for S,a in coeff.items() if C.isdisjoint(S)),Q(0))
    for x in pts:
        h=H(x)
        assert h==Q(16,3)*(-g(x,Q(0))+2*g(x,Q(1,4))
                              -2*g(x,Q(3,4))+g(x,Q(1)))
        assert abs(h)<=32*B
        assert abs(g(x,Q(1))-h)<=33*B
    assert (V-delt)**2 <= (1089*K+2*len(C))*B*B*M
    return delt


def verify_parity_leaf_conditional_risk():
    # Direct conditional enumeration, independent of the theoretical risk formula.
    count=0
    for k in range(3):
        for m in range(1,4):
            n=k+2+m
            pts=list(product((-1,1),repeat=n))
            f={x:Q(prod(x[:k+2]),2)+Q(sum(x[k+2:]),2*m) for x in pts}
            for mask in range(1<<n):
                known=[i for i in range(n) if (mask>>i)&1]
                groups=defaultdict(list)
                for x in pts:groups[tuple(x[i] for i in known)].append(f[x])
                err=sum((sum((a-sum(vals,Q(0))/len(vals))**2 for a in vals)
                         for vals in groups.values()),Q(0))/(1<<n)
                p_complete=all(i in known for i in range(k+2))
                q=len([i for i in known if i>=k+2])
                predicted=(Q(0) if p_complete else Q(1,4))+Q(m-q,4*m*m)
                assert err==predicted
                count+=1
    return count


def run():
    rng=Random(SEED)
    ratios=[]
    count=0
    for n in range(3,8):
        for k in range(0,min(n,3)+1):
            for j in range(17):
                C=set(rng.sample(range(n),k))
                p=[rng.choice(BIASES) for _ in range(n)]
                if j==0: p=[Q(1,97) if i%2 else Q(96,97) for i in range(n)]
                coeff={S:Q(rng.randrange(-7,8),rng.choice([1,2,3,5]))
                       for S in subsets(n) if len(set(S)-C)<=2
                       and (not S or rng.randrange(5)!=0)}
                ratio=verify_instance(n,p,C,coeff)
                ratios.append(ratio)
                count+=1
    defect_count=0
    positive_defect=0
    for n in range(4,8):
        for k in range(0,3):
            for j in range(9):
                C=set(rng.sample(range(n),k))
                p=[rng.choice(BIASES) for _ in range(n)]
                coeff={S:Q(rng.randrange(-7,8),rng.choice([1,3,5]))
                       for S in subsets(n) if len(S)<=3}
                delt=verify_defect_instance(n,p,C,coeff)
                if delt:positive_defect+=1
                defect_count+=1
    posterior_masks=verify_parity_leaf_conditional_risk()
    # Deliberately invalid support should be rejected before applying theorem.
    try:
        verify_instance(5,[Q(1,2)]*5,{0},{(1,2,3):Q(1)})
    except AssertionError:
        invalid_rejected=True
    else:
        invalid_rejected=False
    assert invalid_rejected
    out={
        "seed":SEED,
        "instances":count,
        "defect_instances":defect_count,
        "positive_defect_instances":positive_defect,
        "exact_parity_leaf_posterior_masks":posterior_masks,
        "coefficient_arithmetic":"exact-rational",
        "maximum_V_squared_over_B_squared_M":str(max(ratios)),
        "invalid_backdoor_rejected":invalid_rejected,
        "base_quadratic_proof_independently_verified":False,
        "global_novelty_certified":False,
    }
    print("PASS exact_product_models="+str(count))
    print("PASS exact_defect_models="+str(defect_count))
    print("PASS exact_lower_bound_posterior_masks="+str(posterior_masks))
    print(json.dumps(out,sort_keys=True))
    print("audit_digest_sha256",hashlib.sha256(json.dumps(out,sort_keys=True).encode()).hexdigest())

if __name__=="__main__":run()
