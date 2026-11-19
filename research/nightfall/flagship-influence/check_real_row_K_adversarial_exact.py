#!/usr/bin/env python3
"""NIGHTFALL v1: adversarial exact full-row K and degree-weighted singleton R.

Purpose:
  A. Try to falsify the sharp but UNPROVED 4 V² <= K² M full-row claim.
  B. Try to falsify the coefficient-one strengthening
        V² <= d R² M
     of the UNPROVED degree-weighted R bridge. A failure of this sharp
     normalization alone does not disprove existence of some larger c.

Inputs: finite full-support heterogeneous categorical products.
Optimization: deterministic hill climbing over output values and original
integer probability weights, with exact Fraction objective and cost.
Certificate: independent exact primal/dual full-row LP and independent
fresh-resampling formula for every retained extremizer.

No numerical tolerance, external optimizer, float acceptance, or claim
that finite non-refutation constitutes a proof. Static dual packings
are exhaustively enumerated in rational arithmetic.
"""
from fractions import Fraction as F
from itertools import combinations, product
from math import prod
from random import Random


def solve_square(A, b):
    n=len(b)
    q=[[F(x) for x in row]+[F(b[i])] for i,row in enumerate(A)]
    for j in range(n):
        pivot=next((i for i in range(j,n) if q[i][j]),None)
        if pivot is None:
            return None
        q[j],q[pivot]=q[pivot],q[j]
        den=q[j][j]
        q[j]=[v/den for v in q[j]]
        for i in range(n):
            if i!=j:
                scale=q[i][j]
                q[i]=[q[i][k]-scale*q[j][k] for k in range(n+1)]
    return tuple(x[-1] for x in q)


def dual_vertices(n):
    """Exactly every packing-polytope vertex, for n<=4 original sites."""
    assert 1<=n<=4
    masks=range(1,1<<n)
    A=[[F(bool(mask&(1<<i))) for mask in masks] for i in range(n)]
    out={tuple(F() for _ in masks)}
    for k in range(1,n+1):
        for support in combinations(range(len(A[0])),k):
            for tight in combinations(range(n),k):
                x=solve_square([[A[i][j] for j in support] for i in tight],
                               [F(1)]*k)
                if x is None or any(z<0 for z in x):
                    continue
                v=[F() for _ in masks]
                for j,z in zip(support,x):
                    v[j]=z
                if all(sum((A[i][j]*v[j] for j in range(len(v))),F())<=1
                       for i in range(n)):
                    out.add(tuple(v))
    expected={2:5,3:16,4:95}
    if n in expected:
        assert len(out)==expected[n], (n,len(out))
    return tuple(sorted(out))


class ProductRows:
    def __init__(self, shape):
        self.shape=tuple(shape)
        self.n=len(shape)
        assert 2<=self.n<=4
        self.states=list(product(*(range(s) for s in shape)))
        self.N=len(self.states)
        self.index={x:i for i,x in enumerate(self.states)}
        self.masks=[[sum((1<<i for i in range(self.n)
                          if x[i]!=y[i]),0) for y in self.states]
                    for x in self.states]
        self.neighbor=[
            [tuple(self.index[x[:i]+(v,)+x[i+1:]]
                   for v in range(shape[i]))
             for x in self.states]
            for i in range(self.n)]
        self.vertices=dual_vertices(self.n)

    def full_rows(self, f):
        rows=[]
        for x in range(self.N):
            gap=[F()] * ((1<<self.n)-1)
            for y,mask in enumerate(self.masks[x]):
                if mask:
                    gap[mask-1]=max(gap[mask-1],abs(f[x]-f[y]))
            Kx=max(sum((u*v for u,v in zip(gap,lam)),F())
                   for lam in self.vertices)
            rows.append((Kx,gap))
        return rows

    def degree(self, f):
        """Anchored categorical Möbius normal form, valid for full support."""
        d=0
        for supportsize in range(1,self.n+1):
            for S in combinations(range(self.n),supportsize):
                for letters in product(*(range(1,self.shape[i]) for i in S)):
                    total=F()
                    for Bsize in range(len(S)+1):
                        for chosen in combinations(range(len(S)),Bsize):
                            x=[0]*self.n
                            for j in chosen:
                                x[S[j]]=letters[j]
                            total+=((-1)**(len(S)-Bsize))*f[self.index[tuple(x)]]
                    if total:
                        d=max(d,len(S))
        return d

    def metrics(self, values, weights, independent=False):
        f=tuple(F(v) for v in values)
        p=tuple(tuple(F(v,sum(w)) for v in w) for w in weights)
        mass=tuple(prod((p[i][x[i]] for i in range(self.n)),start=F(1))
                   for x in self.states)
        assert all(v>0 for v in mass) and sum(mass,F())==1
        mean=sum((mass[j]*f[j] for j in range(self.N)),F())
        V=sum((mass[j]*(f[j]-mean)**2 for j in range(self.N)),F())
        Rvals=[F() for _ in self.states]
        I=[]
        for i in range(self.n):
            D=[]
            for j in range(self.N):
                Ei=sum((p[i][v]*f[self.neighbor[i][j][v]]
                        for v in range(self.shape[i])),F())
                Dij=f[j]-Ei
                D.append(Dij)
                Rvals[j]+=abs(Dij)
            Icond=sum((mass[j]*D[j]**2 for j in range(self.N)),F())
            I.append(Icond)
            if independent:
                Irep=F(1,2)*sum((
                    mass[j]*p[i][v]*(f[j]-f[self.neighbor[i][j][v]])**2
                    for j in range(self.N) for v in range(self.shape[i])
                ),F())
                assert Icond==Irep
        R=max(Rvals)
        M=max(I)
        rows=self.full_rows(f)
        K=max(c for c,_ in rows)
        d=self.degree(f)
        assert d>=0
        scoreK=4*V*V/(K*K*M) if K and M else F()
        scoreR=V*V/(d*R*R*M) if d and R and M else F()
        if independent:
            # Independent primal row optimization at every actual
            # maximally expensive source world (not using dual vertices).
            kidx=next(i for i,(cost,_) in enumerate(rows) if cost==K)
            _,gap=rows[kidx]
            n=self.n
            A=[[int(bool((mask+1)&(1<<i))) for i in range(n)]
               for mask in range(len(gap))]
            constraints=A+[[int(i==j) for i in range(n)] for j in range(n)]
            thresholds=list(gap)+[F()]*n
            best=None;bestrow=None
            for tight in combinations(range(len(constraints)),n):
                candidate=solve_square([constraints[j] for j in tight],
                                      [thresholds[j] for j in tight])
                if candidate is not None and all(
                   sum((a*b for a,b in zip(row,candidate)),F())>=thresh
                   for row,thresh in zip(constraints,thresholds)):
                    cost=sum(candidate,F())
                    if best is None or cost<best:
                        best=cost;bestrow=candidate
            assert best==K,("primal-dual mismatch",best,K,self.shape)
            assert all(z>=0 for z in bestrow)
        return scoreK,scoreR,(V,M,R,K,d),rows


def additive_control(engine):
    """All components are independent fair ±1 variables."""
    f=[]
    probs=[]
    for s in engine.shape:
        probs.append([1]*(s-1)+[s-1])
    for x in engine.states:
        f.append(sum((1 if x[i]==engine.shape[i]-1 else -1
                      for i in range(engine.n))))
    return f,probs


def adversarial_search(shape, seed, restarts, moves):
    engine=ProductRows(shape)
    rng=Random(seed)
    bestK=None;bestR=None
    checked=0
    for rr in range(restarts):
        if rr==0:
            values,weights=additive_control(engine)
        elif rr==1:
            values=[int(all(x[i]==shape[i]-1 for i in range(engine.n)))
                    for x in engine.states]
            weights=[[1]*(s-1)+[max(1,s-1)] for s in shape]
        else:
            values=[rng.randrange(-3,4) for _ in engine.states]
            weights=[[rng.choice((1,2,3,7,31,127)) for _ in range(s)]
                     for s in shape]
        scoreK,scoreR,info,_=engine.metrics(values,weights)
        checked+=1
        for target in (0,1):
            sv=list(values);sw=[list(w) for w in weights]
            current=(scoreK,scoreR)[target]
            for _ in range(moves):
                nv=list(sv);nw=[list(w) for w in sw]
                if rng.random()<.66:
                    j=rng.randrange(len(nv))
                    nv[j]+=rng.choice((-3,-2,-1,1,2,3))
                else:
                    i=rng.randrange(engine.n)
                    j=rng.randrange(shape[i])
                    nw[i][j]=rng.choice((1,2,3,7,31,127))
                kk,rratio,_,_=engine.metrics(nv,nw)
                checked+=1
                gain=(kk,rratio)[target]
                if gain>current:
                    sv,sw,current=nv,nw,gain
                if bestK is None or kk>bestK[0]:
                    bestK=(kk,list(nv),[list(w) for w in nw])
                if bestR is None or rratio>bestR[0]:
                    bestR=(rratio,list(nv),[list(w) for w in nw])
    assert bestK is not None and bestR is not None
    for score,vals,prob in (bestK,bestR):
        # Independent true-law fresh-resampling and PRIMAL row LP on
        # the selected maximum-cost world, with exact certificates.
        kk,rr,_,_=engine.metrics(vals,prob,independent=True)
        assert score==kk or score==rr
    return engine,checked,bestK,bestR


def main():
    total=0
    for shape,seed,restarts,moves in (
        ((2,2,2),8211,8,95),
        ((2,2,3),8212,8,95),
        ((2,3,3),8213,8,95),
        ((2,2,2,2),8214,4,45),
    ):
        eng,n,bk,br=adversarial_search(shape,seed,restarts,moves)
        total+=n
        print("AUDIT",shape,"worlds",eng.N,
              "dual_vertices",len(eng.vertices),"candidates",n,
              "max_exact_4V²/K²M",bk[0],"float",float(bk[0]),
              "max_exact_V²/dR²M",br[0],"float",float(br[0]))
        # FAIL CLOSED on a discovered sharp-normalization counterexample:
        # expose the finite rational witness with all weights and values.
        if bk[0]>1:
            print("FINITE SHARP K=4 COUNTEREXAMPLE",shape,bk)
            raise SystemExit(2)
        if br[0]>1:
            print("FINITE UNIT d-WEIGHTED R COUNTEREXAMPLE",shape,br)
            raise SystemExit(3)
    assert total>=4000
    print("PASS",total,"exact adversarial rational candidates;",
          "independently rechecked original-resampling and full primal rows")
    print("NEGATIVE TESTS DO NOT PROVE either conjectured inequality.")


if __name__=="__main__":
    main()
