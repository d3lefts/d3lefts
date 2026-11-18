#!/usr/bin/env python3
"""Full fractional row bridge adversarial search; exact dual replay, NO universal proof.

Self-contained standard-library exact primal/dual check. Seeded replay.
No finite search certifies the positive conjecture.
"""
from fractions import Fraction as F
from itertools import combinations, product
from random import Random
from math import prod

def linear_solve(A,b):
    """Independent exact Gaussian elimination, no external LP dependency."""
    n=len(b)
    v=[[F(x) for x in row]+[F(b[i])] for i,row in enumerate(A)]
    for j in range(n):
        pivot=next((i for i in range(j,n) if v[i][j]),None)
        if pivot is None:return None
        v[j],v[pivot]=v[pivot],v[j]
        den=v[j][j];v[j]=[z/den for z in v[j]]
        for i in range(n):
            if i!=j:
                factor=v[i][j];v[i]=[v[i][k]-factor*v[j][k] for k in range(n+1)]
    return [row[-1] for row in v]

def optimal_full_row(vals,states,x):
    """Primal LP by all active constraint bases (independent of dual)."""
    n=len(states[0]);A=[];b=[]
    for j,y in enumerate(states):
        if j!=x:
            A.append([int(states[x][i]!=y[i]) for i in range(n)])
            b.append(abs(vals[x]-vals[j]))
    for i in range(n):
        A.append([int(i==j) for j in range(n)]);b.append(F(0))
    best=None;witness=None
    for tight in combinations(range(len(A)),n):
        a=linear_solve([A[j] for j in tight],[b[j] for j in tight])
        if a is not None and all(sum((u*v for u,v in zip(row,a)),F())>=rhs for row,rhs in zip(A,b)):
            cost=sum(a,F())
            if best is None or cost<best:best=cost;witness=a
    assert best is not None and witness is not None
    return best,witness

def dual_vertices(n):
    """All vertices of {lam>=0: sum_(m contains i) lam[m]<=1}, exact."""
    masks=range(1,1<<n)
    output={tuple(F(0) for _ in masks)}
    for k in range(1,n+1):
        for support in combinations(masks,k):
            for coords in combinations(range(n),k):
                weights=linear_solve([[int((m>>i)&1) for m in support] for i in coords], [F(1)]*k)
                if weights is None or any(z<0 for z in weights):continue
                if any(sum((weights[j] for j,m in enumerate(support) if m>>i&1),F(0))>1 for i in range(n)):continue
                v=[F(0)]*((1<<n)-1)
                for m,z in zip(support,weights):v[m-1]=z
                output.add(tuple(v))
    return tuple(sorted(output))

def prepare(shape):
    states=list(product(*(range(k) for k in shape)))
    n=len(shape)
    masks=[[sum((1<<i) for i in range(n) if x[i]!=y[i]) for y in states] for x in states]
    groups=[]
    for i in range(n):
        g={}
        for j,x in enumerate(states):g.setdefault(x[:i]+x[i+1:],[]).append(j)
        groups.append(tuple(g.values()))
    return states,masks,groups,dual_vertices(n)

def source_metrics(shape,setup,weights,vals,exact=False):
    states,masks,groups,vertices=setup
    Q=F if exact else float
    laws=[[Q(w)/Q(sum(row)) for w in row] for row in weights]
    f=[Q(z) for z in vals]; n=len(shape)
    w=[prod((laws[i][x[i]] for i in range(n)),start=Q(1)) for x in states]
    mean=sum((w[j]*f[j] for j in range(len(states))),Q(0))
    V=sum((w[j]*(f[j]-mean)**2 for j in range(len(states))),Q(0))
    influences=[];residuals=[]
    for i in range(n):
        r=[Q(0) for _ in states]
        for group in groups[i]:
            avg=sum((laws[i][states[j][i]]*f[j] for j in group),Q(0))
            for j in group:r[j]=f[j]-avg
        influences.append(sum((w[j]*r[j]*r[j] for j in range(len(states))),Q(0)))
        residuals.append(r)
    M=max(influences)
    R=max(sum((abs(residuals[i][j]) for i in range(n)),Q(0)) for j in range(len(states)))
    K=Q(0)
    for x in range(len(states)):
        b=[Q(0)]*((1<<n)-1)
        for y,mask in enumerate(masks[x]):
            if mask:
                b[mask-1]=max(b[mask-1],abs(f[x]-f[y]))
        K=max(K,max(sum((Q(z)*v for z,v in zip(lam,b)),Q(0)) for lam in vertices))
    return 4*V*V/(K*K*M) if K and M else Q(0), (V,M,R,K), influences

def source_replica(shape,setup,weights,vals):
    states,_,_,_=setup;n=len(shape);f=list(map(F,vals));laws=[[F(w,sum(row)) for w in row] for row in weights]
    w=[prod((laws[i][x[i]] for i in range(n)),start=F(1)) for x in states]
    index={s:i for i,s in enumerate(states)}
    return [F(1,2)*sum((w[j]*laws[i][s]*(f[j]-f[index[x[:i]+(s,)+x[i+1:]]])**2 for j,x in enumerate(states) for s in range(shape[i])),F(0)) for i in range(n)]

def candidate(shape,setup,rng,t):
    states=setup[0];n=len(shape)
    scalars=(1,2,3,17,100,1000)
    weights=[[rng.choice(scalars) for _ in range(k)] for k in shape]
    mode=t%7
    if mode==0:weights=[[1]*k for k in shape]
    if mode==0 or mode==6:
        coefs=[rng.choice((-9,-3,3,9)) for _ in shape]
        vals=[sum(coefs[i]*x[i] for i in range(n)) for x in states]
        if mode==6:vals=[z+rng.randint(-4,4) for z in vals]
    elif mode==1:vals=[rng.randint(-20,20) for _ in states]
    elif mode==2:vals=[rng.choice((-20,-1,0,1,20)) for _ in states]
    elif mode==3:
        mark=[rng.randrange(k) for k in shape]
        vals=[int(all(x[i]==mark[i] for i in range(n)))*20 for x in states]
    elif mode==4:vals=[rng.randint(-10,10)*rng.choice((0,0,1,4)) for _ in states]
    else:vals=[rng.randint(-9,9)+rng.choice((-1,1))*x[0]*x[-1] for x in states]
    return weights,vals

def audit_exact(shape,setup,weights,vals):
    ratio,detail,cond=source_metrics(shape,setup,weights,vals,exact=True)
    assert source_replica(shape,setup,weights,vals)==cond
    states=setup[0]
    direct=max(optimal_full_row(list(map(F,vals)),states,j)[0] for j in range(len(states)))
    assert direct==detail[3],(shape,direct,detail[3])
    assert ratio<=F(1),(shape,ratio,weights,vals)
    return ratio,detail

def main():
    rng=Random(20261118)
    for shape,count in (((2,2,2),3500),((3,2,2),3000),((2,3,3),2200)):
        setup=prepare(shape);assert len(setup[-1])==16
        best=(-1,None)
        for t in range(count):
            weights,vals=candidate(shape,setup,rng,t)
            score,_,_=source_metrics(shape,setup,weights,vals)
            if score>best[0]:best=(score,(weights,vals))
            if score>1+1e-9:
                print('ALERT numerical candidate',shape,score,weights,vals)
                exact,detail=audit_exact(shape,setup,weights,vals)
                assert exact<=1
        score,(weights,vals)=best
        exact,detail=audit_exact(shape,setup,weights,vals)
        print('PASS exact-dual adversary',shape,'trials',count,'dual',len(setup[-1]),'best',format(float(exact),'.10f'),'V,M,R,K',detail)
    shape=(2,2,2);setup=prepare(shape)
    weights=[[1,1]]*3;vals=[sum(2*s-1 for s in x) for x in setup[0]]
    assert audit_exact(shape,setup,weights,vals)[0]==1
    print('PASS exact additive equality and independent original-law replica audit')
if __name__=='__main__':main()
