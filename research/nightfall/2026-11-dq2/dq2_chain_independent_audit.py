#!/usr/bin/env python3
"""Independent symbolic cross-check of chain interval covariance identities.
Uses direct spin enumeration and SymPy exact matrices (not the Fraction replay).
Does not certify the all-n theorem or replace external peer review.
"""
import itertools
import json
import sympy as S


def run():
    total=0
    summaries=[]
    for n in range(2,7):
        intervals=list(itertools.combinations(range(n),2))
        spins=list(itertools.product((-1,1),repeat=n))
        for t in (S.Rational(1,3),S.Rational(-1,2)):
            r=abs(t)
            w=[S.prod(1+t*x[k]*x[k+1] for k in range(n-1))/2**n for x in spins]
            assert sum(w)==1
            C=S.Matrix(n,n,lambda i,j:sum(w[k]*spins[k][i]*spins[k][j] for k in range(len(spins))))
            assert C==S.Matrix(n,n,lambda i,j:t**abs(i-j))
            for i in range(n):
                assert sum(abs(C[i,j]) for j in range(n)) <= (1+r)/(1-r)
            if n>=2:
                inverse=C.inv()
                assert max(sum(abs(inverse[i,j]) for j in range(n)) for i in range(n)) <= (1+r)/(1-r)
            cov=[]
            for (i,j) in intervals:
                row=[]
                for (k,l) in intervals:
                    direct=sum(w[s]*(x[i]*x[j]-t**(j-i))*(x[k]*x[l]-t**(l-k)) for s,x in enumerate(spins))
                    A=set(range(i,j)); B=set(range(k,l)); d=len(A^B); q=len(A&B)
                    formula=t**d*(1-t**(2*q))
                    assert direct==formula,(n,t,(i,j),(k,l))
                    if q>0 and d>0:
                        assert d==abs(i-k)+abs(j-l)
                    row.append(direct)
                    total+=1
                cov.append(row)
            max_row=max(sum(abs(y) for y in row) for row in cov)
            assert max_row <= ((1+r)/(1-r))**2
            summaries.append({'n':n,'rho':str(t),'max_row':str(max_row),'kappa_bound':str(((1+r)/(1-r))**2)})
    return {'status':'PASS','direct_covariance_entries':total,'summaries':summaries,
            'scope':'independent symbolic finite-n audit only'}

if __name__=='__main__':
    print(json.dumps(run(),indent=2))
