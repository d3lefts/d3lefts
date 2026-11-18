#!/usr/bin/env python3
"""Exact rational audit of the BIASED Bernstein degree-two saturation family.

This is an independently derived finite computation for the existing
PR #805 Bernstein construction, not a proof of the universal C=4 UPPER bound
and not a Lean certificate of the asymptotic limit.

For Xi ~ Bernoulli(p), K=sum Xi, f=T_2(2K/n-1)=1-8K(n-K)/n^2.
For even n, B=(max f-min f)/2=1 exactly (all atoms full support).
V=64q/n^3 * ((n-1)^2 t^2+2(n-1)q)
M=64q/n^4 * ((n-1)^2 t^2+4(n-1)q),
where q=p(1-p), t=1-2p, and M is original RESAMPLING influence.
Hence V^2/(B^2 M) -> 64q*t^2.
At p=17/20 this is 2499/625=3.9984.
At the exact optimum t^2=1/2, q=1/8, the limit is 4.
"""
from fractions import Fraction as Q
from math import comb


def cheb2_at_k(n, k):
    return Q(1) - Q(8*k*(n-k), n*n)


def closed_moments(n, p):
    assert n >= 2 and n % 2 == 0 and Q(0) < p < Q(1)
    q = p*(1-p)
    t = 1-2*p
    V = Q(64)*q/Q(n**3)*((n-1)**2*t*t+2*(n-1)*q)
    M = Q(64)*q/Q(n**4)*((n-1)**2*t*t+4*(n-1)*q)
    return V, M


def original_source_binomial_moments(n, p):
    """Direct binomial variance and coordinate conditional variance."""
    y = [cheb2_at_k(n,k) for k in range(n+1)]
    assert y[0] == y[n] == 1 and y[n//2] == -1
    B = Q(max(y)-min(y), 2)
    assert B == 1
    pn = [Q(comb(n,k))*p**k*(1-p)**(n-k) for k in range(n+1)]
    assert sum(pn)==1
    mean = sum((a*b for a,b in zip(y,pn)),Q(0))
    V = sum((pn[k]*(y[k]-mean)**2 for k in range(n+1)),Q(0))
    pq=p*(1-p)
    pn_1=[Q(comb(n-1,k))*p**k*(1-p)**(n-1-k) for k in range(n)]
    assert sum(pn_1)==1
    M=pq*sum((pn_1[k]*(y[k+1]-y[k])**2 for k in range(n)),Q(0))
    return B,V,M


def independent_ANOVA_moments(n,p):
    """Independent algebraic decomposition into Bernoulli ANOVA sectors.

    f-Ef= a*sum_i (Xi-p)+b*sum_{i<j}(Xi-p)(Xj-p)
    with a=-8(n-1)(1-2p)/n^2, b=16/n^2.
    """
    q=p*(1-p)
    a=Q(-8*(n-1),n*n)*(1-2*p)
    b=Q(16,n*n)
    var=n*q*a*a+Q(n*(n-1),2)*q*q*b*b
    influence=q*a*a+(n-1)*q*q*b*b
    return var,influence


def main():
    p=Q(17,20)
    ratios=[]
    for n in (4,10,30,100,300):
        B,V,M=original_source_binomial_moments(n,p)
        assert (V,M)==closed_moments(n,p)
        assert (V,M)==independent_ANOVA_moments(n,p)
        ratio=V*V/(B*B*M)
        assert ratio>Q(9,4) and ratio<Q(4)
        ratios.append(ratio)
        print(f"n={n:3d} p=17/20 B=1 "
              f"V2/B2M={float(ratio):.12f} exact_num_bits={ratio.numerator.bit_length()}")
    assert all(x<y for x,y in zip(ratios,ratios[1:]))
    assert ratios[0]>Q(9,4)
    q=p*(1-p)
    t=1-2*p
    limit=64*q*t*t
    assert limit == Q(2499,625)
    assert limit == Q(4)-Q(1,625)
    assert ratios[-1]>Q(397,100)
    # Fair inputs of the same T2 symmetric polynomial have vanishing
    # asymptotic ratio; this explicitly tests bias dependence.
    assert 64*Q(1,2)*Q(1,2)*(1-2*Q(1,2))**2==0
    for n in (10,100,300):
        B,V,M=original_source_binomial_moments(n,Q(1,2))
        assert (V,M)==closed_moments(n,Q(1,2))
        assert V*V/(B*B*M)<Q(4,n-1)
    # Exact SEMIALGEBRAIC sharpness identity: for t in [-1,1],
    # p=(1+t)/2, q=(1-t^2)/4, and the limiting ratio is
    # 16t^2(1-t^2)=4-4(2t^2-1)^2. At t^2=1/2 it equals 4.
    t2=Q(1,2)
    assert 16*t2*(1-t2)==4
    assert Q(4)-4*(2*t2-1)**2==4
    assert 64*Q(1,8)*Q(1,2)==4
    print("PASS independent exact binomial vs source-ANOVA vs closed moments")
    print("PASS bias-tuned limiting lower bound 4: exact algebraic extremal identity")
    print("LIMIT STATUS: analytic delta method in PR #805; no universal C<=4 proof")


if __name__=="__main__":
    main()
