#!/usr/bin/env python3
"""Exact rational full-function and quadratic-matrix audit of signed DQ2.

The checks are finite-instance evidence, NOT a Lean or universal proof.
No third-party dependencies.
"""
from fractions import Fraction as F
from itertools import combinations
from math import prod

def spin(s,i): return 1 if (s>>i)&1 else -1

def positive_definite(M):
    n=len(M); L=[[F(0)]*n for _ in range(n)]; D=[]
    for i in range(n):
        v=M[i][i]-sum(L[i][k]**2*D[k] for k in range(i))
        assert v>0,("non-positive LDL pivot",i,v)
        D.append(v);L[i][i]=F(1)
        for j in range(i+1,n):
            L[j][i]=(M[j][i]-sum(L[j][k]*L[i][k]*D[k] for k in range(i)))/v
    return min(D)

def audit(n,edges,label):
    assert len({tuple(sorted((i,j))) for i,j,t in edges})==len(edges)
    assert all(i!=j and abs(t)<1 for i,j,t in edges)
    T=[[F(0) for _ in range(n)] for _ in range(n)]
    for i,j,t in edges:T[i][j]=T[j][i]=t
    alpha=max(sum(abs(T[i][j]) for j in range(n)) for i in range(n))
    assert 0<alpha<1,(label,alpha)
    A=1/(1-alpha)
    states=list(range(2**n))
    raw={s:prod(F(1)+t*spin(s,i)*spin(s,j) for i,j,t in edges) for s in states}
    Z=sum(raw.values());p={s:raw[s]/Z for s in states}
    assert sum(p.values())==1 and all(q>0 for q in p.values())
    E=lambda fn:sum((p[s]*fn(s) for s in states),F(0))
    assert all(E(lambda s,i=i:spin(s,i))==0 for i in range(n))
    L=[[F(0) for _ in states] for _ in states]
    for i in range(n):
        for s in states:
            if spin(s,i)!=1:continue
            t=s^(1<<i);w=p[s]*p[t]/(p[s]+p[t])
            L[s][s]+=w;L[t][t]+=w;L[s][t]-=w;L[t][s]-=w
    V=[[(-p[s]*p[t]+(p[s] if s==t else 0)) for t in states] for s in states]
    # This is an exact universal-in-function Poincare check, restricted
    # only by f(0)=0 to quotient out constants.
    M=[[L[s][t]-(1-alpha)*V[s][t] for t in states[1:]] for s in states[1:]]
    pin=positive_definite(M)
    Us={s:[] for s in states};wspin={s:[] for s in states}
    for s in states:
        for i in range(n):
            t=s^(1<<i)
            mean=spin(s,i)*(p[s]-p[t])/(p[s]+p[t])
            w=1-mean**2
            Us[s].append((spin(s,i)-mean)/w)
            wspin[s].append(w)
    Q=[[E(lambda s,i=i,j=j:Us[s][i]*Us[s][j]) for j in range(n)] for i in range(n)]
    C=[[E(lambda s,i=i,j=j:spin(s,i)*spin(s,j)) for j in range(n)] for i in range(n)]
    assert all(E(lambda s,i=i:Us[s][i])==0 for i in range(n))
    assert all(E(lambda s,i=i,j=j:spin(s,i)*Us[s][j])==int(i==j) for i in range(n) for j in range(n))
    assert all(Q[i][j]==0 for i in range(n) for j in range(n) if i!=j and T[i][j]==0)
    drows=[];vfloors=[]
    for i in range(n):
        ts=[abs(T[i][j]) for j in range(n) if T[i][j]]
        Pi=prod((1+t)/(1-t) for t in ts)
        vi=4*Pi/(1+Pi)**2
        Di=(1+Pi)**2/(4*Pi)+Pi*sum((t/(1+t)**2 for t in ts),F(0))
        vfloors.append(vi);drows.append(Di)
        assert all(wspin[s][i]>=vi for s in states)
        assert Q[i][i]<=(1+Pi)**2/(4*Pi)
        assert sum(abs(q) for q in Q[i])<=Di
        for j in range(n):
            if i!=j and T[i][j]:
                assert abs(Q[i][j])<=Pi*abs(T[i][j])/(1+abs(T[i][j]))**2
    D=max(drows);v=min(vfloors)
    assert v>=1-alpha**2
    assert D<=1/(1-alpha**2)+alpha*(1+alpha)/(1-alpha)
    # The C floor and complete quadratic covariance operator are checked
    # as rational positive-definite matrices, not sampled coefficients.
    positive_definite([[C[i][j]-(1/D if i==j else 0) for j in range(n)] for i in range(n)])
    mons=[(i,) for i in range(n)]+list(combinations(range(n),2))
    vals=[[prod(spin(s,i) for i in mon) for mon in mons] for s in states]
    means=[sum(p[s]*vals[s][k] for s in states) for k in range(len(mons))]
    K=[[sum(p[s]*vals[s][i]*vals[s][j] for s in states)-means[i]*means[j] for j in range(len(mons))] for i in range(len(mons))]
    positive_definite([[2*A*A*(i==j)-K[i][j] for j in range(len(mons))] for i in range(len(mons))])
    # True-site conditional gradient Gram form dominates product gradient.
    for i in range(n):
        ids=[-1]+[j for j in range(n) if j!=i]
        mat=[[E(lambda s,u=u,z=z,i=i:(1 if u==-1 else spin(s,u))*(1 if z==-1 else spin(s,z))*wspin[s][i]) for z in ids] for u in ids]
        positive_definite([[mat[j][k]-(v/D if j==k else 0) for k in range(len(ids))] for j in range(len(ids))])
    factor=4*A**4*D/v
    for seed in range(10):
        coeff=[F(((17*seed+11*i)%23)-11,37) for i in range(len(mons))]
        fs=[sum(coeff[k]*vals[s][k] for k in range(len(mons))) for s in states]
        B=max(abs(q) for q in fs)
        var=sum(p[s]*fs[s]**2 for s in states)-sum(p[s]*fs[s] for s in states)**2
        influences=[]
        for i in range(n):
            influences.append(sum((p[s]*p[s^(1<<i)]/(p[s]+p[s^(1<<i)])*(fs[s]-fs[s^(1<<i)])**2 for s in states if spin(s,i)==1),F(0)))
        assert var**2 <=F(106)*factor*B*B*max(influences)
    print("PASS",label,"n",n,"edges",len(edges),"negative",sum(t<0 for i,j,t in edges),"alpha",alpha,"factor",float(factor),"LDLpivot",str(pin)[:20])

if __name__=="__main__":
    audit(3,[(0,1,F(1,5)),(1,2,F(1,7)),(0,2,F(-1,6))],"frustrated triangle")
    audit(4,[(0,1,F(-1,5)),(1,2,F(1,8)),(2,3,F(1,7)),(3,0,F(1,9))],"frustrated square")
    audit(4,[(0,1,F(-1,7)),(1,2,F(-1,8)),(2,3,F(1,9)),(3,0,F(-1,10)),(0,2,F(1,11))],"signed square chord")
    audit(5,[(0,1,F(-1,9)),(1,2,F(1,10)),(2,3,F(-1,8)),(3,4,F(-1,11)),(4,0,F(1,12)),(0,2,F(1,13))],"frustrated pentagon chord")
    audit(4,[(i,j,F(-1,13) if (i+j)%2 else F(1,15)) for i,j in combinations(range(4),2)],"signed K4")
    print("PASS all exact full-function Poincare and complete quadratic PSD audits")


def cubic_barrier():
    # Independent bond-variable calculation for connected Ising chain.
    # The attachment spin X0 is correlated with Y1, so its native
    # conditional variance contributes the factor (1-r*r).
    from itertools import product
    r=F(1,3)
    for k in (2,3,4,6,10):
        val=F(0)
        for signs in product((-1,1),repeat=k):
            law=prod((1+r*z)/2 for z in signs)
            val+=law*F(sum(signs)**2,k*k)
        expected=r*r+(1-r*r)/k
        assert val==expected,(k,val,expected)
        assert val*k == 1+(k-1)*r*r
        influence_X0=(1-r*r)*val
        assert influence_X0>0
        print("PASS exact cubic degree-transfer obstruction k",k,
              "Var_nu",val,"Var_mu",F(1,k),
              "ratio",k*val,"actual Inf_X0",influence_X0)
    print("PASS exact connected-chain cubic covariance-transfer no-go tests")

if __name__=="__main__":
    cubic_barrier()
