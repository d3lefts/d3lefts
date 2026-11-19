#!/usr/bin/env python3
"""Exact Fraction audit of the orbit-averaged full fractional-row LP.

SciPy generates candidate primal and dual vertices, but ACCEPTANCE uses
independent Fraction feasibility and equality, not floating-point tolerances.
Small n also independently solves every full-cube primal row LP.
Scope: finite test only, NOT Turturean §9.5.
"""
import json, math
from fractions import Fraction as Q
import numpy as np
from scipy.optimize import linprog

def candidates(n):
    k = np.arange(n+1)
    return {
      'linear': [Q(int(a)) for a in k],
      'parity': [Q(-1 if a%2 else 1) for a in k],
      'majority': [Q(int(a>=n//2)) for a in k],
      'square': [Q(int(2*a-n)**2) for a in k],
      'alternating_affine': [Q(int(a)+((-1)**int(a))*3) for a in k],
    }

def exact_reduced(n, h):
    costs=[]; checks=0
    for k in range(n+1):
        constraints=[(r,s,abs(h[k]-h[k-r+s]))
            for r in range(k+1) for s in range(n-k+1) if r+s]
        P=np.array([[-r,-s] for r,s,g in constraints],dtype=float)
        gaps=np.array([float(g) for r,s,g in constraints])
        opt=linprog([k,n-k],A_ub=P,b_ub=-gaps,bounds=(0,None),method='highs')
        assert opt.success,(n,k,opt.message)
        u,v=[Q(float(z)).limit_denominator(1000000) for z in opt.x]
        ld=[Q(float(z)).limit_denominator(1000000) for z in -opt.ineqlin.marginals]
        # Exact primal.
        assert all(z>=0 for z in (u,v))
        assert all(r*u+s*v>=g for r,s,g in constraints)
        # Exact dual of min c·(u,v) s.t. A(u,v)>=g, u,v>=0.
        assert all(l>=0 for l in ld)
        assert sum((l*r for l,(r,s,g) in zip(ld,constraints)),Q())<=k
        assert sum((l*s for l,(r,s,g) in zip(ld,constraints)),Q())<=n-k
        primal=k*u+(n-k)*v
        dual=sum((l*g for l,(r,s,g) in zip(ld,constraints)),Q())
        assert primal==dual,(n,k,primal,dual)
        costs.append(primal)
        checks+=len(constraints)*2+6
    return max(costs),checks

def original_full_cube(n,h):
    N=1<<n
    masks=list(range(1,N))
    A=np.array([[int(mask>>i&1) for i in range(n)] for mask in masks])
    costs=[]
    for x in range(N):
        gaps=[float(abs(h[x.bit_count()]-h[(x^mask).bit_count()])) for mask in masks]
        opt=linprog(np.ones(n),A_ub=-A,b_ub=-np.array(gaps),
                    bounds=(0,None),method='highs')
        assert opt.success
        costs.append(Q(float(opt.fun)).limit_denominator(1000000))
    return max(costs)

def source_metrics(n,h,K):
    weights=[Q(math.comb(n,k),2**n) for k in range(n+1)]
    mu=sum((weights[k]*h[k] for k in range(n+1)),Q())
    V=sum((weights[k]*(h[k]-mu)**2 for k in range(n+1)),Q())
    M=Q(1,4)*sum((Q(math.comb(n-1,k),2**(n-1))*
                  (h[k+1]-h[k])**2 for k in range(n)),Q())
    return {'V':str(V),'M':str(M),'K':str(K),'K2M_over_V2':str(K*K*M/(V*V)) if V else None}

def main():
    receipt={'status':'FINITE_EXACT_PRIMAL_DUAL_ONLY','cases':[],
             'exact_constraints':0,'full_cube_matches':0}
    for n in [3,4,5,6,8,12,16,24]:
        for name,h in candidates(n).items():
            K,num=exact_reduced(n,h)
            if n<=6:
                assert K==original_full_cube(n,h),(n,name)
                receipt['full_cube_matches']+=1
            entry={'n':n,'family':name,**source_metrics(n,h,K)}
            assert Q(entry['K2M_over_V2'])>=4,entry
            receipt['cases'].append(entry);receipt['exact_constraints']+=num
    assert len(receipt['cases'])==40
    assert receipt['exact_constraints']==48810
    assert receipt['full_cube_matches']==20
    assert min(Q(v['K2M_over_V2']) for v in receipt['cases'])==4
    print(json.dumps(receipt,indent=2))
if __name__=='__main__':main()
