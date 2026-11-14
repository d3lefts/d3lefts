#!/usr/bin/env python3
"""Independent Fraction audit: controlled correlated perturbations of products.

Checks exact variance/conditional-influence comparison, hereditary density
bounds and the nonproduct total-influence drift identity. All laws and
numbers are rational. A finite audit is not a proof of the universal theorem.
"""
from fractions import Fraction as F
from itertools import product, combinations
from random import Random

RNG=Random(26110913)

def variance(P,f):
    mean=sum((p*f[x] for x,p in P.items()),F(0))
    return sum((p*(f[x]-mean)**2 for x,p in P.items()),F(0))

def inf(P,f,i):
    groups={}
    for x,p in P.items():
        z=x[:i]+x[i+1:]
        groups.setdefault(z,[]).append((p,f[x]))
    val=F(0)
    for rows in groups.values():
        m=sum((p for p,_ in rows),F(0))
        if not m: continue
        t=sum((p*y for p,y in rows),F(0))/m
        val+=sum((p*(y-t)**2 for p,y in rows),F(0))
    return val

def conditional(mu,nu,states,S,assignment):
    filt=lambda x: all(x[i]==assignment[i] for i in S)
    a={x:mu[x] for x in states if filt(x)}
    b={x:nu[x] for x in states if filt(x)}
    zm=sum(a.values(),F(0));zn=sum(b.values(),F(0))
    assert zm>0 and zn>0
    return {x:p/zm for x,p in a.items()},{x:p/zn for x,p in b.items()}

def enum_model(n,alphabet=2):
    states=list(product(range(alphabet),repeat=n))
    masses=[]
    for i in range(n):
        nums=[RNG.randint(1,6) for _ in range(alphabet)]
        masses.append([F(x,sum(nums)) for x in nums])
    mu={x:F(1) for x in states}
    for x in states:
        for i in range(n):
            mu[x]*=masses[i][x[i]]
    w={x:F(RNG.randint(1,12),RNG.choice([1,2,3])) for x in states}
    norm=sum((mu[x]*w[x] for x in states),F(0))
    nu={x:mu[x]*w[x]/norm for x in states}
    a=min(w.values())/norm;b=max(w.values())/norm
    R=b/a
    # f has reference Hoeffding degree <=2 by construction.
    phi=[{j:F(j)-sum((F(t)*masses[i][t] for t in range(alphabet)),F(0))
          for j in range(alphabet)} for i in range(n)]
    ci=[F(RNG.randint(-4,4),RNG.choice([1,2])) for i in range(n)]
    cij={(i,j):F(RNG.randint(-3,3),RNG.choice([1,2]))
         for i in range(n) for j in range(i+1,n)}
    f={}
    for x in states:
        f[x]=sum((ci[i]*phi[i][x[i]] for i in range(n)),F(0))+sum(
            (v*phi[i][x[i]]*phi[j][x[j]] for (i,j),v in cij.items()),F(0))
    B=max(abs(v) for v in f.values())
    assert sum(mu.values(),F(0))==sum(nu.values(),F(0))==1
    return states,mu,nu,f,B,a,b,R

def main():
    counts={'product_perturbations':0,'posterior_cases':0,'drift_equalities':0,
            'tv_variation_checks':0,'nonproduct_witnesses':0}
    for n in (2,3,4):
        for t in range(36 if n!=4 else 10):
            states,mu,nu,f,B,a,b,R=enum_model(
                n,2 if n==4 else RNG.randint(2,3))
            assert a*variance(mu,f)<=variance(nu,f)<=b*variance(mu,f)
            for i in range(n):
                assert a*inf(mu,f,i)<=inf(nu,f,i)<=b*inf(mu,f,i)
            T_mu=sum((inf(mu,f,i) for i in range(n)),F(0))
            assert variance(mu,f)<=T_mu<=2*variance(mu,f)
            T_nu=sum((inf(nu,f,i) for i in range(n)),F(0))
            assert T_nu<=R*2*variance(nu,f)
            TV=sum((abs(mu[x]-nu[x]) for x in states),F(0))/2
            assert abs(variance(mu,f)-variance(nu,f))<=4*B*B*TV
            for i in range(n):
                assert abs(inf(mu,f,i)-inf(nu,f,i))<=4*B*B*TV
            counts['tv_variation_checks']+=1
            for k in range(n):
                for subset in combinations(range(n),k):
                    S=set(subset)
                    seen=set(tuple(x[i] for i in subset) for x in states)
                    for vals in seen:
                        assignment=dict(zip(subset,vals))
                        m,p=conditional(mu,nu,states,S,assignment)
                        rat=[p[x]/m[x] for x in m]
                        amin=min(rat);bmax=max(rat)
                        assert bmax/amin<=R
                        Vp=variance(p,f);Vm=variance(m,f)
                        assert amin*Vm<=Vp<=bmax*Vm
                        free=[j for j in range(n) if j not in S]
                        Ti=sum((inf(p,f,j) for j in free),F(0))
                        assert Ti<=R*2*Vp
                        for i in free:
                            assert amin*inf(m,f,i)<=inf(p,f,i)<=bmax*inf(m,f,i)
                            after=F(0)
                            probs={u:sum((v for x,v in p.items() if x[i]==u),F(0))
                                   for u in set(x[i] for x in p)}
                            for u,prob in probs.items():
                                p2={x:v/prob for x,v in p.items() if x[i]==u}
                                after+=prob*sum(
                                    (inf(p2,f,j) for j in free if j!=i),F(0))
                            assert after==Ti-inf(p,f,i),(
                                'drift',n,subset,i,after,Ti-inf(p,f,i))
                            counts['drift_equalities']+=1
                        counts['posterior_cases']+=1
            counts['product_perturbations']+=1
            if any(nu[x]/mu[x]!=nu[y]/mu[y] for x in states for y in states):
                counts['nonproduct_witnesses']+=1
    # A singular correlated law can have variance but no heat-bath influence.
    q={(0,0):F(1,2),(0,1):F(0),(1,0):F(0),(1,1):F(1,2)}
    g={x:F(x[0]) for x in q}
    assert variance(q,g)==F(1,4)
    assert inf(q,g,0)==inf(q,g,1)==0
    print({**counts,'perfect_correlation_obstruction':'passed',
           'result':'all exact tests passed'})

if __name__=='__main__':
    main()
