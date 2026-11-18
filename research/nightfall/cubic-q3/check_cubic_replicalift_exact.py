#!/usr/bin/env python3
"""Exact rational 2-replica fair-cube reduction audit for product functions.

This verifies examples, not the general proof; stdlib only.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from math import comb


def allsubsets(n):
    return [s for k in range(n+1) for s in combinations(range(n),k)]


def audit(ps, func, degree, verbose=True):
    n=len(ps)
    sites=list(product((0,1),repeat=n))
    P={x:__import__('math').prod((ps[i] if b else 1-ps[i]) for i,b in enumerate(x)) for x in sites}
    f={x:func(x) for x in sites}
    mean=sum(P[x]*f[x] for x in sites)
    V=sum(P[x]*(f[x]-mean)**2 for x in sites)
    influence={}
    for i in range(n):
        val=Q(0)
        for x in sites:
            y=list(x);y[i]=1-x[i];y=tuple(y)
            val+=P[x]*ps[i]*(1-ps[i])*(f[x]-f[y])**2
        influence[i]=val
    # Direct source ANOVA decomposition via inclusion-exclusion conditional means.
    cond={}
    for S in allsubsets(n):
        for x in sites:
            cond[S,x]=sum(P[z]*f[z] for z in sites if all(z[i]==x[i] for i in S)) / __import__('math').prod((ps[i] if x[i] else 1-ps[i]) for i in S)
    energy={}
    for S in allsubsets(n):
        component={x:sum((-1)**(len(S)-len(T))*cond[T,x] for T in allsubsets(n) if set(T).issubset(S)) for x in sites}
        energy[S]=sum(P[x]*component[x]**2 for x in sites)
    assert sum(e for S,e in energy.items() if S) == V
    assert all(energy[S]==0 for S in energy if len(S)>degree)
    Evar=Q(0);Einf={i:Q(0) for i in range(n)}
    Evar_Q=Q(0); Einf_Q={i:Q(0) for i in range(n)}
    B=max(abs(v) for v in f.values())
    fair_levels={k:Q(0) for k in range(n+1)}
    maxsum=Q(0)
    for x in sites:
        for z in sites:
            w=P[x]*P[z]
            vals={eps:f[tuple(x[i] if eps[i] else z[i] for i in range(n))] for eps in sites}
            fm=sum(vals.values(),Q(0))/2**n
            vv=sum((t-fm)**2 for t in vals.values())/2**n
            Evar+=w*vv
            J={}
            for i in range(n):
                ss=Q(0)
                for eps in sites:
                    alt=list(eps);alt[i]=1-alt[i];alt=tuple(alt)
                    ss+=(vals[eps]-vals[alt])**2
                J[i]=ss/(4*2**n)
                Einf[i]+=w*J[i]
            maxsum+=w*max(J.values())
            hat={T:sum(((-1)**sum(eps[i] for i in T))*vals[eps] for eps in sites)/2**n for T in allsubsets(n)}
            for T,a in hat.items():
                fair_levels[len(T)]+=w*a*a
                if 1<=len(T)<=2:
                    Evar_Q+=w*a*a
                    for i in T:
                        Einf_Q[i]+=w*a*a
            # The fair quadratic projection is bounded by 5B,
            # from exact Chebyshev interpolation of the cubic term.
            for eps in sites:
                q=sum(((-1)**sum(eps[i] for i in T))*a for T,a in hat.items() if len(T)<=2)
                assert abs(q)<=5*B
            # The 4th fair Fourier coefficient vanishes pointwise for degree <=3.
            if degree<=3 and n==4:
                fourth=sum((-1)**sum(eps)*vals[eps] for eps in sites)
                assert fourth==0
    assert Evar==sum((1-Q(1,2**len(S)))*e for S,e in energy.items() if S)
    assert all(Einf[i]==Q(1,2)*influence[i] for i in range(n))
    for k in range(n+1):
        target=sum(Q(comb(len(S),k),2**len(S))*e for S,e in energy.items() if len(S)>=k)
        assert fair_levels[k]==target, (k,fair_levels[k],target)
    if degree<=3:
        target_Q=sum((Q(1,2) if len(S)==1 else Q(3,4))*e for S,e in energy.items() if S)
        assert Evar_Q==target_Q
        for i in range(n):
            expected=Q(1,2)*influence[i]-Q(1,8)*sum(e for S,e in energy.items() if len(S)==3 and i in S)
            assert Einf_Q[i]==expected,(i,Einf_Q[i],expected)
    if verbose:
        print('Quadratic fair projection: annealed variance=', Evar_Q,'annealed influences=',Einf_Q)
        print('n=',n,'degree<=',degree,'Var=',V,'annealed fair Var=',Evar)
        print('source influences=',influence,'annealed fair influences=',Einf)
        print('source spectrum=',{str(S):str(e) for S,e in energy.items() if e})
        print('annealed fair Walsh-level energies=',fair_levels)
        print('E max fair influence / max E fair influence=', maxsum/max(Einf.values()))
    return V,Evar,influence,Einf,maxsum


def no_go(m):
    """Exact linear f=sum_i (X_i-p)/n, n=m^2, p=1/m."""
    n=m*m; p=Q(1,m);q=2*p*(1-p)
    expected_max=(1-(1-q)**n)/(4*n*n)
    max_expected=q/(4*n*n)
    return expected_max/max_expected

if __name__=='__main__':
    ps=[Q(1,3),Q(2,5),Q(3,7),Q(1,2)]
    # Three- and lower-way interactions (without any 4-way term).
    def f(x):
        a,b,c,d=[Q(2*t-1) for t in x]
        return Q(1,2)*a+b*c-Q(3,4)*a*b*d+Q(2,3)*b*c*d+Q(1,5)*c
    audit(ps,f,3)
    for m in [2,3,4,6,8,12,16,24]:
        print('linear replica maxima m=',m,'n=',m*m,'p=1/m ratio=',float(no_go(m)))
    assert all(no_go(m)>Q(m,5) for m in [6,8,12,16,24])
    print('PASS: exact two-replica binomial spectral energy, variance and influence identities; degree-4 annihilation; unbounded max-exchange loss')
