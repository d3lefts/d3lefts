#!/usr/bin/env python3
"""NIGHTFALL: small original-product full-row LP, EXACT rational arithmetic.

DO NOT use the singleton R in place of K. This solver enumerates all
basic feasible vertices of the genuine per-point row linear program
    min 1^T a
    s.t. a_i>=0; sum_(i:x_i!=y_i) a_i >= |f(x)-f(y)| for all y.
It is intended for <=3 original categorical coordinates, with <=18
positive-support worlds. No SciPy, float or external optimizer.

All influences use the ORIGINAL coordinate resampling laws. For every
candidate, a second independent conditional-variance expression verifies
the source I_i. No finite search proves Turturean's real-row conjecture.
"""
from fractions import Fraction as Q
from itertools import combinations, product
from random import Random


def linear_solve(A,b):
    n=len(b)
    v=[[Q(x) for x in row]+[Q(b[i])] for i,row in enumerate(A)]
    for j in range(n):
        pivot=next((i for i in range(j,n) if v[i][j]),None)
        if pivot is None:
            return None
        v[j],v[pivot]=v[pivot],v[j]
        den=v[j][j]
        v[j]=[z/den for z in v[j]]
        for i in range(n):
            if i!=j:
                factor=v[i][j]
                v[i]=[v[i][k]-factor*v[j][k] for k in range(n+1)]
    return [row[-1] for row in v]


def optimal_full_row(vals,states,x):
    n=len(states[0])
    A=[]; b=[]
    for j,y in enumerate(states):
        if j!=x:
            A.append([int(states[x][i]!=y[i]) for i in range(n)])
            b.append(abs(vals[x]-vals[j]))
    for i in range(n):
        A.append([int(i==j) for j in range(n)])
        b.append(Q(0))
    best=None; witness=None
    # Every minimum of this nonempty, bounded-below polyhedron is
    # achieved at a vertex with n linearly independent tight constraints.
    for tight in combinations(range(len(A)),n):
        a=linear_solve([A[j] for j in tight],[b[j] for j in tight])
        if a is not None and all(
            sum((u*v for u,v in zip(row,a)),Q())>=rhs
            for row,rhs in zip(A,b)):
            cost=sum(a,Q())
            if best is None or cost<best:
                best=cost; witness=a
    assert best is not None and witness is not None
    return best,witness


def original_source_metrics(states,laws,values):
    n=len(laws);N=len(states)
    weights=[
        __import__("math").prod((laws[i][states[j][i]] for i in range(n)),
                                start=Q(1))
        for j in range(N)]
    assert all(x>0 for x in weights) and sum(weights,Q())==1
    mean=sum((weights[j]*values[j] for j in range(N)),Q())
    V=sum((weights[j]*(values[j]-mean)**2 for j in range(N)),Q())
    D=[];I=[]
    for i in range(n):
        groups={}
        for j,x in enumerate(states):
            key=x[:i]+x[i+1:]
            groups.setdefault(key,[]).append(j)
        resid=[Q() for _ in states]
        for inds in groups.values():
            assert len(inds)==len(laws[i])
            avg=sum((laws[i][states[j][i]]*values[j] for j in inds),Q())
            for j in inds:
                resid[j]=values[j]-avg
        I_cond=sum((weights[j]*resid[j]**2 for j in range(N)),Q())
        # Independent two-replica resampling expression, without D.
        I_rep=Q(1,2)*sum((
            weights[j]*laws[i][s]*
            (values[j]-values[states.index(states[j][:i]+(s,)+states[j][i+1:])])**2
            for j in range(N) for s in range(len(laws[i]))
        ),Q())
        assert I_cond==I_rep
        I.append(I_cond);D.append(resid)
    R=max(sum((abs(D[i][j]) for i in range(n)),Q()) for j in range(N))
    row=[optimal_full_row(values,states,j) for j in range(N)]
    K=max(c for c,_ in row)
    M=max(I)
    ratioR=V*V/(R*R*M) if R*M else Q()
    ratioK=V*V/(K*K*M) if K*M else Q()
    assert K>=R
    return V,M,R,K,ratioR,ratioK


def main():
    rng=Random(128)
    total=0
    for shape in ((2,2,2),(3,2,2),(2,3,3)):
        states=list(product(*(range(k) for k in shape)))
        laws=[]
        for k in shape:
            w=[rng.randrange(1,6) for _ in range(k)]
            laws.append([Q(z,sum(w)) for z in w])
        bestR=Q();bestK=Q()
        for trial in range(3):
            f=[Q(rng.randrange(-3,4),2) for _ in states]
            if len(set(f))<2:
                continue
            V,M,R,K,ratioR,ratioK=original_source_metrics(states,laws,f)
            bestR=max(bestR,ratioR);bestK=max(bestK,ratioK)
            assert ratioK<=Q(1,4)
            total+=1
        print("PASS exact full-row LP",shape,"supported states",len(states),
              "bestR",bestR,"bestK",bestK)
    # Additive source control saturates the plausible 4V²<=K²M bridge.
    states=list(product((-1,1),repeat=3))
    laws=[[Q(1,2),Q(1,2)] for _ in range(3)]
    # State labels are -1,1; use law-index states for the LP engine.
    binary=list(product((0,1),repeat=3))
    f=[Q(sum(2*s-1 for s in x)) for x in binary]
    V,M,R,K,rR,rK=original_source_metrics(binary,laws,f)
    assert (V,M,R,K,rR,rK)==(Q(3),Q(1),Q(3),Q(6),Q(1),Q(1,4))
    # The valid all-degree K statement remains an OPEN conjecture.
    print("PASS additive equality control: V=3, M=1, R=3, K=6",
          "V²/(K²M)=1/4")
    assert total==9
    print("PASS 9 independent exact categorical full-row LPs;",
          "NO proof of the general K bridge claimed.")


if __name__=="__main__":
    main()
