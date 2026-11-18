#!/usr/bin/env python3
"""Original-product first-chaos proxy: independent exact categorical source audit.

No theorem for universal LIN-ANNEALED-d is asserted. This tests only finite
fully-supported/zero-atom rational models and the claimed ANOVA spectral
identities, with independent source-pair truth-table and ANOVA engines.

Run:
 python3 -I research/nightfall/flagship-influence/check_product_linear_selector_exact.py
"""
from fractions import Fraction as Q
from itertools import product
from math import prod


def states_of(marginals):
    return list(product(*[tuple(i for i,p in enumerate(m) if p>0) for m in marginals]))


def prob(word, marginals):
    return prod((marginals[i][w] for i,w in enumerate(word)), start=Q(1))


def conditional_tables(marginals, f, states, weights):
    n=len(marginals)
    tables={}
    for s in range(1<<n):
        subset=tuple(i for i in range(n) if s>>i&1)
        numer={};denom={}
        for x in states:
            key=tuple(x[i] for i in subset)
            numer[key]=numer.get(key,Q(0))+weights[x]*f[x]
            denom[key]=denom.get(key,Q(0))+weights[x]
        tables[s]=(subset,{key:numer[key]/denom[key] for key in numer})
    return tables


def native_anova(marginals, f, states, weights):
    n=len(marginals)
    C=conditional_tables(marginals,f,states,weights)
    energy={}
    for s in range(1<<n):
        subtotal=Q(0)
        for x in states:
            z=Q(0)
            for t in range(1<<n):
                if t&s!=t:continue
                subset,table=C[t]
                z+=((-1)**((s^t).bit_count()))*table[tuple(x[i] for i in subset)]
            subtotal+=weights[x]*z*z
        energy[s]=subtotal
    return energy


def true_fresh_influences(marginals, f, states, weights):
    n=len(marginals)
    ans=[]
    for i in range(n):
        acc=Q(0)
        for x in states:
            for letter,p in enumerate(marginals[i]):
                if p==0:continue
                y=x[:i]+(letter,)+x[i+1:]
                acc+=weights[x]*p*(f[x]-f[y])**2/2
        ans.append(acc)
    return ans


def source_pair_direct(marginals, f, states, weights, t):
    """Source X,Y are iid mu; each R_i is a Bernoulli(2t) refresh attempt.
    Independently enumerate selectors sigma: when R_i and sigma_i=-1, use Y_i.
    """
    assert Q(0)<t<=Q(1,2)
    n=len(marginals)
    N=1<<n
    refresh=2*t
    U=Q(0);J=[Q(0)]*n;A=Q(0)
    for x in states:
        for y in states:
            pairmass=weights[x]*weights[y]
            for mask in range(N):
                rmass=refresh**mask.bit_count()*(1-refresh)**(n-mask.bit_count())
                if rmass==0:continue
                vals=[]
                for selector in range(N):
                    w=tuple(y[i] if (mask>>i&1 and selector>>i&1) else x[i]
                            for i in range(n))
                    vals.append(f[w])
                linear=[]
                for i in range(n):
                    alpha=sum((vals[selector]*(-1 if selector>>i&1 else 1)
                               for selector in range(N)), Q(0))/N
                    linear.append(alpha)
                    J[i]+=pairmass*rmass*alpha*alpha
                    U+=pairmass*rmass*alpha*alpha
                A=max(A,sum(map(abs,linear)))
    return U,J,A


def spectral_prediction(energy,n,t):
    U=Q(0);J=[Q(0)]*n
    for s,e in energy.items():
        rank=s.bit_count()
        if rank==0 or e==0:continue
        rate=t*(1-t)**(rank-1)
        U+=e*rank*rate
        for i in range(n):
            if s>>i&1:J[i]+=e*rate
    return U,J


def check_model(label,marginals,func,expect_degree):
    n=len(marginals)
    domain=list(product(*[range(len(m)) for m in marginals]))
    # Evaluate also the null states: their values must *not* affect the result.
    f={x:Q(func(x)) for x in domain}
    states=states_of(marginals)
    weights={x:prob(x,marginals) for x in states}
    assert sum(weights.values(),Q(0))==1
    h=native_anova(marginals,f,states,weights)
    degree=max((s.bit_count() for s,e in h.items() if s and e),default=0)
    assert degree==expect_degree,(label,'wrong degree',degree,expect_degree)
    mean=sum((weights[x]*f[x] for x in states),Q(0))
    V=sum((weights[x]*(f[x]-mean)**2 for x in states),Q(0))
    assert V==sum((e for s,e in h.items() if s),Q(0))
    B=(max(f[x] for x in states)-min(f[x] for x in states))/2
    M=true_fresh_influences(marginals,f,states,weights)
    assert M==[sum((e for s,e in h.items() if s>>i&1),Q(0)) for i in range(n)]
    for t in (Q(1,2),Q(1,4),Q(1,8)):
        direct_u,direct_j,A=source_pair_direct(marginals,f,states,weights,t)
        spec_u,spec_j=spectral_prediction(h,n,t)
        assert direct_u==spec_u,(label,t,'variance',direct_u,spec_u)
        assert direct_j==spec_j,(label,t,'influences',direct_j,spec_j)
        assert A<=degree*B,(label,t,'Bernstein',A,degree*B)
        assert sum(direct_j,Q(0))==direct_u
        assert all(j<=M[i] for i,j in enumerate(direct_j))
    print('PASS',label,'n=',n,'supported_states=',len(states),
          'degree=',degree,'V=',V,'B=',B,'max_original_influence=',max(M))


def main():
    p1=((Q(1,3),Q(2,3)),(Q(1,6),Q(1,3),Q(1,2)),(Q(3,5),Q(2,5)))
    check_model('heterogeneous-degree3',p1,
       lambda x: 7*x[0]-3*x[1]+5*x[2]+2*x[0]*x[1]-4*x[0]*x[1]*x[2],3)
    p2=((Q(1,2),Q(1,2),Q(0)),(Q(1,7),Q(2,7),Q(4,7)),(Q(1,4),Q(3,4)))
    def null_law_f(x):
        if x[0]==2:return 10**9+x[1]*10**7
        return 3*x[0]-2*x[1]+5*x[2]+7*x[0]*x[1]*x[2]
    check_model('null-atom-adversarial-off-support',p2,null_law_f,3)
    p3=((Q(2,5),Q(3,5)),(Q(1,4),Q(1,4),Q(1,2)),(Q(1,3),Q(2,3)))
    check_model('heterogeneous-degree2',p3,
       lambda x: 5*x[0]+3*x[1]-7*x[2]+2*x[0]*x[1]-x[1]*x[2],2)
    print('PASS: 3 independent exact categorical native-ANOVA versus '
          'true original-law paired-refresh/selector enumerations at '
          '3 rational scales, including all supported null-atom controls. '
          'This is NOT a proof of LIN-ANNEALED-d.')


if __name__=='__main__':
    main()
