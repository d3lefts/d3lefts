#!/usr/bin/env python3
"""Exact finite quotient audit: source law, optimal full rows, primal/dual.
SciPy only proposes vertices; all accepted identities use Fraction.
Not a universal proof of the categorical quotient theorem.
"""
import json, math
from itertools import product
from fractions import Fraction as Q
from scipy.optimize import linprog

def optimum(x, worlds, f):
    n=len(x)
    constraints=[]
    for y in worlds:
        if y==x: continue
        constraints.append(([Q(int(x[i]!=y[i])) for i in range(n)],
                            abs(Q(f(x))-Q(f(y)))))
    A=[[-float(v) for v in a] for a,g in constraints]
    opt=linprog([1.]*n,A_ub=A,b_ub=[-float(g) for a,g in constraints],
                bounds=(0,None),method='highs')
    assert opt.success,(x,opt.message)
    w=[Q(float(v)).limit_denominator(1000000) for v in opt.x]
    ld=[Q(float(-v)).limit_denominator(1000000) for v in opt.ineqlin.marginals]
    assert all(v>=0 for v in w) and all(v>=0 for v in ld)
    assert all(sum((w[i]*a[i] for i in range(n)),Q())>=g for a,g in constraints)
    assert all(sum((ld[j]*constraints[j][0][i] for j in range(len(constraints))),Q())<=1 for i in range(n))
    primal=sum(w,Q())
    dual=sum((ld[j]*g for j,(a,g) in enumerate(constraints)),Q())
    assert primal==dual,(x,primal,dual)
    return primal,len(constraints)*2+n+2

def source_metrics(alph,p,f):
    worlds=list(product(*alph))
    w={x:math.prod((p[i][x[i]] for i in range(len(alph))),start=Q(1))
       for x in worlds}
    assert sum(w.values(),Q())==1
    mu=sum((w[x]*f(x) for x in worlds),Q())
    V=sum((w[x]*(f(x)-mu)**2 for x in worlds),Q())
    I=[]
    for i in range(len(alph)):
        val=Q(1,2)*sum((w[x]*p[i][z]*(f(x)-f(x[:i]+(z,)+x[i+1:]))**2
                     for x in worlds for z in alph[i]),Q())
        I.append(val)
    return V,I

def main():
    # Unequal alphabets, source null letter removed before constructing supports.
    A=[(0,2),(0,1,2),(0,1,2)]
    phi=[{0:0,2:1},{0:0,1:1,2:2},{0:0,1:1,2:1}]
    B=[(0,1),(0,1,2),(0,1)]
    p=[{0:Q(1,3),2:Q(2,3)},
       {0:Q(1,2),1:Q(1,4),2:Q(1,4)},
       {0:Q(1,5),1:Q(3,5),2:Q(1,5)}]
    q=[{z:sum((p[i][a] for a in A[i] if phi[i][a]==z),Q())
        for z in B[i]} for i in range(3)]
    C=list(product(*A));D=list(product(*B))
    tests={
      'mixed_interaction':lambda b:Q(3*b[0]*b[1]-2*b[2]+b[1]*b[2]+b[0]*b[2]),
      'multilevel':lambda b:Q((sum(b))**2-3*sum(b)),
      'nonmonotone':lambda b:Q((-1)**sum(b)+2*b[0]*b[2]-b[1]),
    }
    receipt=[];checks=0
    for name,h in tests.items():
        f=lambda x:h(tuple(phi[i][a] for i,a in enumerate(x)))
        binary={b:optimum(b,D,h) for b in D}
        original={x:optimum(x,C,f) for x in C}
        checks+=sum(v[1] for v in binary.values())+sum(v[1] for v in original.values())
        for x in C:
            b=tuple(phi[i][a] for i,a in enumerate(x))
            assert original[x][0]==binary[b][0],(name,x)
        V,I=source_metrics(A,p,f)
        Vb,Ib=source_metrics(B,q,h)
        assert (V,I)==(Vb,Ib),(name,V,Vb,I,Ib)
        receipt.append({'family':name,
                        'row_cost':str(max(c for c,_ in original.values())),
                        'variance':str(V),'influences':[str(z) for z in I]})
    assert checks==3078
    assert len(receipt)==3
    print(json.dumps({'status':'FINITE_EXACT_PRIMAL_DUAL_AND_SOURCE_ONLY',
                      'checks':checks,'families':receipt,
                      'source_support_count':len(C),'feature_support_count':len(D)},indent=2))
if __name__=='__main__':main()
