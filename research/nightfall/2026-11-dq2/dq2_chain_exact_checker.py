#!/usr/bin/env python3
"""DQ2 finite-chain rational replay, deliberately independent of the analytic proof.

Checks the two operator comparisons against directly enumerated Gibbs laws;
these finite tests are not a proof of the all-n theorem.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random
import json, hashlib


def configurations(n):
    return list(product((-1, 1), repeat=n))


def chain_law(n, t):
    # Uniform initial spin and independent transition bonds: normalized exactly.
    return {x: Q(1, 2**n) * _prod([1+t*x[i]*x[i+1] for i in range(n-1)])
            for x in configurations(n)}


def _prod(xs):
    y = Q(1)
    for x in xs:
        y *= x
    return y


def expectation(law, f):
    return sum((p*f(x) for x,p in law.items()), Q(0))


def variance(law, f):
    return expectation(law, lambda x: f(x)**2) - expectation(law, f)**2


def conditional_influence(law, f, excluded):
    excluded=set(excluded)
    groups={}
    for x,p in law.items():
        key=tuple(s for i,s in enumerate(x) if i not in excluded)
        if key not in groups:
            groups[key]=[Q(0),Q(0),Q(0)]
        groups[key][0]+=p
        groups[key][1]+=p*f(x)
        groups[key][2]+=p*f(x)**2
    return sum((s2-s1*s1/p for p,s1,s2 in groups.values()), Q(0))


def poly(coeff1, coeff2, intercept=0):
    def f(x):
        return intercept + sum(a*x[i] for i,a in coeff1.items()) + sum(b*x[i]*x[j] for (i,j),b in coeff2.items())
    return f


def run():
    rng=Random(20261117)
    checks=0
    sample=[]
    for n in (2,3,4,5,6,7):
        for t in (Q(0), Q(1,3), Q(-1,3), Q(1,2), Q(-1,2)):
            law=chain_law(n,t)
            assert sum(law.values()) == 1
            r=abs(t)
            chi=(1+r)/(1-r)
            kappa=chi**2
            alpha=(1-r)/(1+r)
            v=((1-r*r)/(1+r*r))**2
            factor=kappa*kappa/(v*alpha)
            assert factor == ((1+r)**3 * (1+r*r)**2)/(1-r)**7
            assert all(p>0 for p in law.values())
            for seed in range(5):
                a={i:rng.randint(-3,3) for i in range(n)}
                b={(i,j):rng.randint(-2,2) for i,j in combinations(range(n),2)}
                f=poly(a,b,rng.randint(-2,2))
                value_list=[f(x) for x in law]
                B=max(abs(val) for val in value_list)
                var=variance(law,f)
                var_prod=sum((z*z for z in a.values()),Q(0)) + sum((z*z for z in b.values()),Q(0))
                assert var <= kappa*var_prod, (n,t,seed,'quadratic norm transfer',var,kappa*var_prod)
                for i in range(n):
                    inf=conditional_influence(law,f,{i})
                    inf_prod=a[i]**2+sum(b.get((min(i,j),max(i,j)),0)**2 for j in range(n) if j!=i)
                    assert inf >= v*alpha*inf_prod, (n,t,seed,'local influence transfer',i,inf, v*alpha*inf_prod)
                    checks+=1
                # The Q2 inequality follows logically from the product bound,
                # whose separate Lean certificate is NOT re-proved by this checker.
                if seed==0 and n in (2,5,7) and t in (Q(0),Q(1,3),Q(1,2)):
                    sample.append({'n':n,'rho':str(t),'K_over_K0':str(factor),'var':str(var),'max_native_inf':str(max(conditional_influence(law,f,{i}) for i in range(n))), 'B':B})
    # Sharp two-spin degree-one lower witness (also tests local Poincare gap)
    sharp=[]
    for t in (Q(0),Q(1,3),Q(-1,3),Q(1,2),Q(-1,2),Q(9,10)):
        law=chain_law(2,t)
        sign=1 if t>=0 else -1
        f=lambda x:x[0]+sign*x[1]
        infs=[conditional_influence(law,f,{i}) for i in range(2)]
        vr=variance(law,f)
        B=2
        exact_ratio=vr**2/(B**2*max(infs))
        predicted=(1+abs(t))/(1-abs(t))
        assert exact_ratio==predicted, ('sharp degree one',t,exact_ratio,predicted)
        gap=sum(infs)/vr
        assert gap == 1-abs(t), ('sharp Poincare gap',t,gap)
        sharp.append({'rho':str(t),'DQ1_sharp_ratio':str(exact_ratio),'local_gap':str(gap)})
    return {'status':'PASS', 'exact_checks':checks, 'models':6*5*5, 'sharp_witnesses':sharp,
            'samples':sample, 'scope':'finite exact rational tests only; analytic all-n proof separate'}

if __name__=='__main__':
    out=run()
    print(json.dumps(out,indent=2))
