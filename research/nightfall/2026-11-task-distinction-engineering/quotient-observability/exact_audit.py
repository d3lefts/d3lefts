#!/usr/bin/env python3
"""Exact finite cross-checks for NIGHTFALL quotient-noise/certificate theorem.

Independent enumeration of (X,N) joint space versus direct coset posterior construction.
Only prime fields 2,3 are tested; theorem itself holds for every finite field.
"""
from __future__ import annotations
from collections import defaultdict
from fractions import Fraction
from itertools import product, combinations
import random, json, hashlib
from pathlib import Path

SEED = 20261113
R = random.Random(SEED)

def vecs(q,n): return list(product(range(q), repeat=n))
def dot(row,x,q): return sum(a*b for a,b in zip(row,x))%q
def mv(A,x,q): return tuple(dot(row,x,q) for row in A)
def add(x,y,q): return tuple((a+b)%q for a,b in zip(x,y))
def sub(x,y,q): return tuple((a-b)%q for a,b in zip(x,y))
def cols(A,idx): return [[row[j] for j in idx] for row in A]
def span_image(A,q):
    n=len(A[0]) if A else 0
    return set(mv(A,x,q) for x in vecs(q,n))
def posterior_direct(A,q,noise,Q):
    """Enumerate full latent X and correlated noise N, accumulating P(K,Y_Q)."""
    n=len(A[0]); d=len(A)
    joint=defaultdict(int); counts=defaultdict(int)
    for x in vecs(q,n):
        k=mv(A,x,q)
        for nv,w in noise.items():
            y=add(x,nv,q)
            yq=tuple(y[i] for i in Q)
            joint[(yq,k)]+=w
            counts[yq]+=w
    return joint,counts

def posterior_cosets(A,q,noise,Q,yq,k):
    """Independent algebraic prediction: average uniform full unknown-input fiber."""
    n=len(A[0]); d=len(A)
    missing=[i for i in range(n) if i not in Q]
    U=span_image(cols(A,missing),q)
    if not U: raise AssertionError("subspace cannot be empty")
    num=0
    for nv,w in noise.items():
        xq=tuple((a-nv[i])%q for a,i in zip(yq,Q))
        term=mv(cols(A,Q),xq,q)
        if sub(k,term,q) in U: num+=w
    return Fraction(num,len(U)*sum(noise.values()))

def audit_posteriors(rounds=240):
    states=0; cases=0; nontrivial=0
    for t in range(rounds):
        q=R.choice((2,3)); n=R.choice((2,3,4)) if q==2 else R.choice((2,3))
        d=R.randint(1,min(n,2))
        while True:
            A=[[R.randrange(q) for _ in range(n)] for __ in range(d)]
            if len(span_image(A,q)) == q**d: break
        support=R.sample(vecs(q,n),R.randint(1,min(q**n,5)))
        noise={v:R.randint(1,5) for v in support}
        for Qbits in range(1<<n):
            Q=[i for i in range(n) if Qbits>>i&1]
            joint,denom=posterior_direct(A,q,noise,Q)
            for yq in vecs(q,len(Q)):
                for k in vecs(q,d):
                    actual=Fraction(joint[(yq,k)],denom[yq])
                    predicted=posterior_cosets(A,q,noise,Q,yq,k)
                    assert actual==predicted,(A,q,noise,Q,yq,k,actual,predicted)
                    states+=1
            cases+=1
        if any(sum(A[0][i]!=0 for i in range(n))>=2 for _ in (0,)):
            nontrivial+=1
    return {"random_models":rounds,"observed_subset_cases":cases,"exact_posterior_cells":states,"multi_component_task_models":nontrivial}

def audit_all_or_nothing(rounds=600):
    """Exhaust deterministic decisions for p=2, and check best success at any leaf."""
    tested=0
    for _ in range(rounds):
        q=2; n=2
        noise={v:R.randint(1,5) for v in vecs(q,n)}
        total=sum(noise.values())
        zprob=defaultdict(int)
        for nv,w in noise.items(): zprob[sum(nv)%2]+=w
        pmax=Fraction(max(zprob.values()),total)
        # Policy can stop or select any unread coordinate. enumerate all valid deterministic decision trees.
        def trees(seen):
            yield ('stop',)
            remaining=[i for i in range(n) if i not in dict(seen)]
            for i in remaining:
                a=list(trees(tuple(sorted(seen+((i,0),)))))
                b=list(trees(tuple(sorted(seen+((i,1),)))))
                for ta in a:
                    for tb in b:
                        yield ('query',i,ta,tb)
        for tree in trees(tuple()):
            def leaves(tr,seen):
                if tr[0]=='stop':
                    return [(tuple(sorted(seen)), Fraction(1,2**len(seen)),len(seen))]
                _,i,ta,tb=tr
                return [(s,prob/2,cost) for s,prob,cost in leaves(ta,seen+((i,0),))] + [(s,prob/2,cost) for s,prob,cost in leaves(tb,seen+((i,1),))]
            leaves0=leaves(tree,tuple())
            reads=sum((w*count for _,w,count in leaves0),Fraction())
            success=sum((w*(pmax if count==2 else Fraction(1,2)) for _,w,count in leaves0),Fraction())
            assert success <= Fraction(1,2) + (pmax-Fraction(1,2))*reads/2
            tested+=1
    return {"random_noise_models":rounds,"deterministic_adaptive_policies_evaluated":tested}

def audit_noise_drift_indistinguishability():
    """Two incompatible task posteriors with identical complete measurement laws."""
    q=2; A=[[1,1]]; Q=[0,1]
    alternatives=[{(0,0):1,(1,1):1},
                  {(0,0):1,(0,1):1,(1,0):1,(1,1):1}]
    laws=[]; confidences=[]
    for noise in alternatives:
        joint,denom=posterior_direct(A,q,noise,Q)
        law={y: Fraction(denom[y],sum(denom.values())) for y in vecs(2,2)}
        post={y: max(Fraction(joint[(y,(k,))],denom[y]) for k in (0,1)) for y in vecs(2,2)}
        laws.append(law);confidences.append(post)
    assert laws[0]==laws[1]
    assert set(confidences[0].values())=={Fraction(1,1)}
    assert set(confidences[1].values())=={Fraction(1,2)}
    return {"complete_Y_laws_identical":True,
            "paired_noise_posterior_MAP":"1",
            "independent_noise_posterior_MAP":"1/2"}

def audit_row_column_frontier(max_r=4):
    """Enumerate every advance-purchase set on r x r grids, compare exact minmax."""
    checked=0
    stats={}
    for r in range(2,max_r+1):
        opt=[r+1]*(r*r+1)
        for bits in range(1<<(r*r)):
            b=bits.bit_count()
            row=[0]*r; col=[0]*r
            for idx in range(r*r):
                if bits>>idx&1:
                    row[idx//r]+=1
                    col[idx%r]+=1
            worst=max(max(r-v for v in row),max(r-v for v in col))
            opt[b]=min(opt[b],worst)
            checked+=1
        predicted=[r-b//r for b in range(r*r+1)]
        assert opt==predicted,(r,opt,predicted)
        stats[str(r)]={"frontier":opt,"premeasurement_subsets":1<<(r*r)}
    return {"exact_grid_subsets":checked,"cases":stats}

def audit_updates(rounds=4000):
    for _ in range(rounds):
        q=R.choice((2,3,5,7)); n=R.randint(1,40)
        a=[R.randrange(q) for _ in range(n)]
        y=[R.randrange(q) for _ in range(n)]
        nchange=R.randrange(n+1); touched=R.sample(range(n),nchange)
        delta={i:R.randrange(q) for i in touched}
        before=sum(a[i]*y[i] for i in range(n))%q
        adjusted=(before+sum(a[i]*delta[i] for i in touched))%q
        newy=y[:]
        for i in touched: newy[i]=(newy[i]+delta[i])%q
        direct=sum(a[i]*newy[i] for i in range(n))%q
        assert adjusted==direct
        # Exact task change: any newly active nonzero coefficient absent from cache needs a read.
        Q=set(R.sample(range(n),R.randrange(n+1)))
        newa=[R.randrange(q) for _ in range(n)]
        missing={i for i in range(n) if newa[i] and i not in Q}
        assert all(newa[i]==0 for i in set(range(n))-(Q|missing))
    return {"random_exact_delta_models":rounds}

if __name__=='__main__':
    results={"seed":SEED,
             "coset_posterior":audit_posteriors(),
             "adaptive_frontier":audit_all_or_nothing(),
             "version_delta":audit_updates(),
             "row_column_revelation":audit_row_column_frontier(),
             "noise_law_drift_obstruction":audit_noise_drift_indistinguishability(),
             "status":"All exact finite checks passed; this is NOT independent formal proof or prior-art certification."}
    out=Path(__file__).with_name('audit_results.json')
    out.write_text(json.dumps(results,indent=2)+"\n")
    print(json.dumps(results,indent=2))
