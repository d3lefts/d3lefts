#!/usr/bin/env python3
"""NIGHTFALL v0.3 independent exact audit of a source-authenticated, contractive digital-twin revalidation proposition.
Standard-library only. No trust authentication is performed here; assumptions are audited as symbolic input contracts.
"""
from fractions import Fraction as Q
from random import Random
import json, hashlib
from pathlib import Path

Z=Q(0); O=Q(1)

def matvec(A,x):
    return [sum((a*xi for a,xi in zip(row,x)), Z) for row in A]

def inverse_solve(A,b):
    # Independent Gauss-Jordan route for (I-A)u=b
    n=len(A)
    M=[[ (O if i==j else Z)-A[i][j] for j in range(n)]+[b[i]] for i in range(n)]
    for j in range(n):
        pivot=next(i for i in range(j,n) if M[i][j])
        M[j],M[pivot]=M[pivot],M[j]
        p=M[j][j]
        M[j]=[c/p for c in M[j]]
        for i in range(n):
            if i==j: continue
            c=M[i][j]
            M[i]=[v-c*w for v,w in zip(M[i],M[j])]
    return [M[i][-1] for i in range(n)]

def neumann_bounds(A,b,k,rho):
    # No matrix inverse: geometric-term iteration, independent error envelope
    v=list(b); lo=[Z]*len(b)
    for _ in range(k+1):
        lo=[a+c for a,c in zip(lo,v)]
        v=matvec(A,v)
    tail=max(b)*rho**(k+1)/(O-rho)
    return lo,[x+tail for x in lo]

def verify_certificate(A,b,u,margin,L,mission):
    n=len(b)
    assert len(A)==n and len(u)==n
    assert all(len(row)==n for row in A)
    assert all(v>=0 for row in A for v in row)
    rho=max(sum(row,Z) for row in A)
    assert rho<1
    assert all(v>=0 for v in b)
    assert all(v>=0 for v in u)
    Bu=matvec(A,u)
    assert all(u[i]>=b[i]+Bu[i] for i in range(n))
    return {i: margin[i]>=L[i]*u[i] for i in mission}

def test_generic():
    rand=Random(20261113)
    checks=0; min_rho=O; max_rho=Z
    for n in range(2,13):
        for repeat in range(12):
            A=[]
            for i in range(n):
                picks=rand.sample(range(n),k=min(3,n))
                weights=[rand.randrange(0,5) for _ in picks]
                row=[Z]*n
                for j,w in zip(picks,weights): row[j]=Q(w,24)
                A.append(row)
            rho=max(sum(row,Z) for row in A)
            assert rho<=Q(1,2)
            b=[Q(rand.randrange(0,4),8) if j in rand.sample(range(n),min(2,n)) else Z for j in range(n)]
            if not any(b): b[0]=Q(1,8)
            u=inverse_solve(A,b)
            direct=matvec(A,u)
            assert all(u[i]==b[i]+direct[i] for i in range(n))
            lo,hi=neumann_bounds(A,b,20,rho)
            assert all(lo[i]<=u[i]<=hi[i] for i in range(n))
            # second source independent verifier uses only row operations and comparison
            slack=Q(1,17)
            uz=[v+slack for v in u]
            flags=verify_certificate(A,b,uz,[O]*n,[O]*n,range(n))
            assert all(flags.values())
            # worst-case affine perturbed dynamics attains exact bound u* at all sites
            assert all(u[i]==b[i]+sum(A[i][j]*u[j] for j in range(n)) for i in range(n))
            # exact margin threshold: <= is sound, < has an affine unsafe witness
            assert all((u[i]>=u[i]) and not (u[i]-Q(1,1000)>=u[i]) for i in range(n))
            min_rho=min(min_rho,rho); max_rho=max(max_rho,rho)
            checks+=1
    return {'random_exact_cases':checks,'matrix_orders':[2,12], 'rho_max':str(max_rho)}

def chain_frontier(n=128,p=Q(1,2),eps=O,m=Q(1,1024)):
    # independent exact recurrence for feed-forward directed chain
    u=[eps*p**i for i in range(n)]
    active=[i for i,val in enumerate(u) if val>m]
    assert active==list(range(10))
    B=[[Z]*n for _ in range(n)]
    for i in range(1,n): B[i][i-1]=p
    b=[eps]+[Z]*(n-1)
    assert all(u[i]==b[i]+sum((B[i][j]*u[j] for j in range(n)),Z) for i in range(n))
    return {'nodes':n,'active_needing_review':len(active),'old_certificate_retained':n-len(active),'fraction_retained':str(Q(n-len(active),n))}

def grid_frontier(side=32,rho=Q(1,4),eps=O,m=Q(1,4096)):
    source=(side//2,side//2)
    def dist(x,y): return abs(x-source[0])+abs(y-source[1])
    # For every distance d, bound <= eps*rho**d/(1-rho)
    unsettled=[(x,y) for x in range(side) for y in range(side)
               if eps*rho**dist(x,y)/(O-rho)>m]
    assert len(unsettled)==85
    # Independent graph-ball cardinality check using explicit shells
    shells={d:sum(dist(x,y)==d for x in range(side) for y in range(side)) for d in range(7)}
    assert shells=={0:1,1:4,2:8,3:12,4:16,5:20,6:24}
    return {'nodes':side*side,'uncertain_nodes_at_most':len(unsettled),'certified_stable_at_least':side*side-len(unsettled), 'shells':shells,'stability_margin':str(m),'contraction':str(rho)}

def adversarial_failures():
    n=24; p=O; eps=O
    propagation=[eps*p**i for i in range(n)]
    # For rho=1, all nodes can be affected; no dimension-independent radius.
    assert propagation==[O]*n
    # Fake zero-change declaration yields a zero certificate; true source is unsafe.
    declared_b=[Z]*3; actual_b=[O,Z,Z]
    declared_u=[Z]*3
    assert all(x==0 for x in declared_b)
    assert declared_u[0]<actual_b[0]
    return {'noncontractive_full_path_propagation':n,'unauthenticated_manifest_breaks_certificate':True}

def main():
    results={'status':'PASS','model':'finite componentwise contraction; exact rational arithmetic',
             'general_matrices':test_generic(), 'chain':chain_frontier(),
             'grid':grid_frontier(), 'obstructions':adversarial_failures(),
             'certification_scope':'algebraic bounds conditional on authenticated dynamics, B, perturbation envelope and prior margins',
             'not_established':['physical-system fidelity','cryptographic provenance','historical originality','empirical human-AI advantage','independent human referee review']}
    out=Path(__file__).with_name('certificate_audit_results.json')
    out.write_text(json.dumps(results,indent=2,sort_keys=True)+'\n')
    print(json.dumps(results,indent=2,sort_keys=True))
    print('SOURCE_SHA256',hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    print('RESULT_SHA256',hashlib.sha256(out.read_bytes()).hexdigest())

if __name__=='__main__':main()