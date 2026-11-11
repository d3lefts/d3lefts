#!/usr/bin/env python3
"""Independent exact-rational falsification checks for the analytic transfer.
Not a proof for arbitrary measurable spaces. No non-stdlib dependencies.
"""
from fractions import Fraction as Q
from itertools import product
from random import Random
from math import factorial, prod


def sq(vec):
    return sum((v*v for v in vec), Q(0))


def exp_upper(x, terms=60):
    """Rigorous rational Taylor-series upper bound for e^x, x>=0."""
    assert 0 <= x < terms+2
    t=sum((x**j/Q(factorial(j)) for j in range(terms+1)), Q(0))
    tail=x**(terms+1)/Q(factorial(terms+1))/(1-x/Q(terms+2))
    return t+tail


def check_psd(seed=20261111, trials=190):
    rng=Random(seed)
    for _ in range(trials):
        n=rng.randrange(1,6)
        ell=rng.randrange(1,n+1)
        X=[[Q(rng.randrange(-3,4)) for _ in range(n)] for _ in range(ell)]
        A=[[sum((X[k][i]*X[k][j] for k in range(ell)), Q(0))
            for j in range(n)] for i in range(n)]
        s=sum((A[i][i] for i in range(n)),Q(0))
        if not s: continue
        upper=Q(0)
        for signs in product((-1,1),repeat=n):
            z=sum((Q(signs[i])*A[i][j]*signs[j]
                   for i in range(n) for j in range(n)),Q(0))
            assert z>=0
            upper+=exp_upper(z/(4*s))
        upper/=2**n
        assert upper*upper<=2, (n, upper)
    return trials


def check_sections(seed=20261111, trials=180):
    rng=Random(seed)
    cases=0
    for _ in range(trials):
        n=rng.randrange(1,5)
        alph=[rng.randrange(2,4) for j in range(n)]
        weights=[]
        for a in alph:
            w=[rng.randrange(0,5) for j in range(a)]
            if not any(w): w[0]=1
            weights.append([Q(t,sum(w)) for t in w])
        xs=list(product(*(range(a) for a in alph)))
        mass={x:prod(weights[i][x[i]] for i in range(n)) for x in xs}
        rank=rng.randrange(1,4)
        F={x:tuple(Q(rng.randrange(-3,4),3) for j in range(rank)) for x in xs}
        means=[]
        for i in range(n):
            means.append({x:tuple(
                sum((weights[i][a]*F[x[:i]+(a,)+x[i+1:]][k]
                     for a in range(alph[i])),Q(0))
                for k in range(rank)) for x in xs})
        infl=[sum((mass[x]*sq(tuple(F[x][k]-means[i][x][k]
                    for k in range(rank))) for x in xs),Q(0))
              for i in range(n)]
        total=sum(infl,Q(0))
        for j in range(n):
            after=Q(0)
            for a in range(alph[j]):
                if weights[j][a]==0: continue
                for i in range(n):
                    if i==j: continue
                    after+=sum((mass[x]*sq(tuple(F[x][k]-means[i][x][k]
                             for k in range(rank))) for x in xs if x[j]==a),Q(0))
            assert after==total-infl[j], (j,after,total-infl[j])
            cases+=1
    return cases


def check_adaptive(seed=20261111, trials=55):
    rng=Random(seed+31)
    cases=0
    for _ in range(trials):
        n=rng.randint(2,4)
        sizes=[rng.randint(2,3) for _ in range(n)]
        weights=[]
        for a in sizes:
            v=[rng.randint(0,5) for _ in range(a)]
            if not any(v): v[0]=1
            weights.append([Q(t,sum(v)) for t in v])
        domain=list(product(*(range(a) for a in sizes)))
        rank=rng.randint(1,3)
        F={x:tuple(Q(rng.randint(-4,4),5) for k in range(rank)) for x in domain}
        def influences(state):
            fixed=dict(state)
            xs=[x for x in domain if all(x[j]==a for j,a in fixed.items())]
            mass={x:prod(weights[i][x[i]] for i in range(n) if i not in fixed)
                  for x in xs}
            assert sum(mass.values(),Q(0))==1
            ans={}
            for i in range(n):
                if i in fixed:continue
                total=Q(0)
                for x in xs:
                    mu=tuple(sum((weights[i][a]*F[x[:i]+(a,)+x[i+1:]][k]
                        for a in range(sizes[i])),Q(0)) for k in range(rank))
                    total+=mass[x]*sq(tuple(F[x][k]-mu[k] for k in range(rank)))
                ans[i]=total
            return ans
        def visit(state):
            nonlocal cases
            I=influences(state)
            if not I:return
            j=min(I,key=lambda i:(-I[i],i))
            total=sum(I.values(),Q(0))
            after=sum((weights[j][a]*sum(influences(state+((j,a),)).values(),Q(0))
                  for a in range(sizes[j])),Q(0))
            assert after==total-I[j], (state,j,after,total-I[j])
            cases+=1
            for a in range(sizes[j]):
                if weights[j][a]>0:visit(state+((j,a),))
        visit(())
    return cases


if __name__=="__main__":
    print("PASS rational posterior step:",check_sections(),"coordinate cases")
    print("PASS rational adaptive tree:",check_adaptive(),"positive histories")
    print("PASS rational PSD exponential upper bound:",check_psd(),"Gram cases")
