#!/usr/bin/env python3
"""NIGHTFALL exact rational falsifier: degree-free singleton R bridge.

This is a COUNTEREXAMPLE TO THE PROPOSED R FORM, not to Turturean's
full fractional certificate K conjecture and not to a fixed-degree Q2 bound.

For f=AND of n iid Bernoulli(p) inputs with p=(n-1)/n:
    q=p**n, V=q*(1-q), M=q/n, R=1, K=n
and therefore V**2/(R**2*M)=n*q*(1-q)**2 >= n/16 -> infinity.

Independent full-state original-law (not fair-flip) verification for
n<=8 and exact formula replay for n up to 300. All arithmetic uses Fraction.

Also checks the classical Rubinstein-style fair-cube separation:
K(0)>=m*m whereas R=m, for a disjoint-pair block indicator on
2*m*m unbiased bits. This confirms the R and full-row targets cannot
be substituted for each other (credit Rubinstein sensitivity vs bs).
"""
from fractions import Fraction as Q
from itertools import product


def AND_formula(n):
    assert n >= 2
    p = Q(n-1, n)
    q = p**n
    V = q*(1-q)
    M = q*(1-p)
    R = max(n*(1-p), p)
    K = n
    assert R == 1
    assert M == q/n
    ratio_R = V*V/(R*R*M)
    ratio_K = V*V/(K*K*M)
    assert ratio_R == n*q*(1-q)**2
    # Elementary bounds: n>=2 => 1/4<= (1-1/n)^n <=1/2.
    # Thus n*q*(1-q)^2 >= n/16.
    assert Q(1,4) <= q <= Q(1,2)
    assert ratio_R >= Q(n,16)
    return p, q, V, M, R, K, ratio_R, ratio_K


def original_law_truth_table_AND(n):
    """Three independent source calculations from the full 2^n table.

    (a) physical variance, (b) original-law conditional variance
    and actual pointwise residual, (c) fresh independent replica pair.
    """
    assert 2 <= n <= 8
    p, q, V_formula, M_formula, R_formula, K, _, _ = AND_formula(n)
    X = list(product((0,1), repeat=n))
    w = {x: p**sum(x) * (1-p)**(n-sum(x)) for x in X}
    f = {x: Q(int(all(x))) for x in X}
    assert sum(w.values(), Q())==1
    avg=sum((w[x]*f[x] for x in X), Q())
    var=sum((w[x]*(f[x]-avg)**2 for x in X), Q())
    assert avg==q and var==V_formula

    influence=[]
    residual = {x:Q() for x in X}
    for i in range(n):
        point_res = {}
        for x in X:
            x0=x[:i]+(0,)+x[i+1:]
            x1=x[:i]+(1,)+x[i+1:]
            actual_E_i=(1-p)*f[x0]+p*f[x1]
            point_res[x]=f[x]-actual_E_i
            residual[x]+=abs(point_res[x])
        I_cond=sum((w[x]*point_res[x]**2 for x in X),Q())
        I_replica=Q(1,2)*sum((
            w[x]*((1-p)*(f[x]-f[x[:i]+(0,)+x[i+1:]])**2+
                   p*(f[x]-f[x[:i]+(1,)+x[i+1:]])**2)
            for x in X),Q())
        assert I_cond==I_replica==M_formula
        influence.append(I_cond)
    assert max(residual.values())==R_formula
    assert residual[(1,)*n]==1
    assert all(residual[x]==p for x in X if sum(x)==n-1)
    assert all(residual[x]==0 for x in X if sum(x)<n-1)
    # Construct a full fractional row at EVERY vertex:
    # at top (1,...,1): all weights 1, cost n, necessary by singleton
    # tests. Else: assign 1 to one coordinate where x_i=0 (cost 1);
    # any y with f(y)!=f(x) must differ at that coordinate.
    for x in X:
        if f[x]==1:
            a=(1,)*n
            assert all(f[x]-f[x[:i]+(0,)+x[i+1:]]==1 for i in range(n))
        else:
            j=x.index(0)
            a=tuple(int(i==j) for i in range(n))
        for y in X:
            assert abs(f[x]-f[y]) <= sum(a[i] for i in range(n) if x[i]!=y[i])
    assert max(influence)==M_formula
    return n, len(X)


def rubinstein_family(m):
    """Classical Rubinstein disjoint sensitive-pair family; exact fair cube."""
    assert 1 <= m <= 3
    b=2*m;n=m*b;N=1<<n
    mask=(1<<b)-1
    pair_masks=[3<<(2*r) for r in range(m)]
    def f(s):
        return int(any(((s>>(b*j)) & mask) in pair_masks
                       for j in range(m)))
    table=bytearray(f(s) for s in range(N))
    assert table[0]==0
    sensitivity_max=0
    for s in range(N):
        sensitivity=sum(table[s] != table[s^(1<<i)] for i in range(n))
        sensitivity_max=max(sensitivity,sensitivity_max)
    assert sensitivity_max==2*m
    R=Q(sensitivity_max,2)
    assert R==m
    # At all zeros, m*m DISJOINT two-coordinate sensitive blocks.
    pairs=[(b*j+2*r,b*j+2*r+1) for j in range(m) for r in range(m)]
    assert len(pairs)==m*m and len(set(i for pair in pairs for i in pair))==n
    for u,v in pairs:
        assert table[(1<<u)|(1<<v)]==1
    # Every full row a at zero requires a_u+a_v>=1 for each
    # disjoint pair: sum all constraints => total cost >=m*m.
    # The upper row a_u=1, a_v=0 on each pair is feasible because
    # f(y)=1 only if SOME designated pair is fully activated.
    chosen={u for u,v in pairs}
    for y in range(N):
        if table[y]:
            assert any((y>>u)&1 for u in chosen)
    K_zero=m*m
    assert Q(K_zero)/R == m
    return m,n,N,K_zero,R



def chebyshev(d, z):
    """Exact first-kind T_d on any rational z."""
    if d==0:
        return Q(1)
    if d==1:
        return z
    a,b=Q(1),z
    for _ in range(2,d+1):
        a,b=b,2*z*b-a
    return b


def chebyshev_weighted_R(d,n,p):
    """Exact degree-d symmetric source-world formula, NOT a theorem.

    At Hamming weight k:
      R_k=k(1-p)|t_k-t_(k-1)|+(n-k)p|t_(k+1)-t_k|.
    This includes R on extremely rare but POSITIVE-MASS tail points.
    The constant-slope family and biased degree-d oscillations test
    a distinct high-degree regime from the AND family.
    """
    from math import comb
    assert n>=d>=2 and 0<p<1
    y=[chebyshev(d,Q(2*k-n,n)) for k in range(n+1)]
    w=[Q(comb(n,k))*p**k*(1-p)**(n-k) for k in range(n+1)]
    assert sum(w,Q())==1
    avg=sum((w[k]*y[k] for k in range(n+1)),Q())
    V=sum((w[k]*(y[k]-avg)**2 for k in range(n+1)),Q())
    wother=[Q(comb(n-1,k))*p**k*(1-p)**(n-1-k)
            for k in range(n)]
    M=p*(1-p)*sum((wother[k]*(y[k+1]-y[k])**2
                   for k in range(n)),Q())
    R=max((
        k*(1-p)*(abs(y[k]-y[k-1]) if k else 0)
       +(n-k)*p*(abs(y[k+1]-y[k]) if k<n else 0)
        for k in range(n+1)),default=Q())
    assert R>0 and M>0
    return V*V/(Q(d)*R*R*M),R


def structured_degree_weighted_R_stress():
    """Positive-support exact rational degrees 2...8; no floats."""
    near_bernstein={
        2:Q(17,20),3:Q(14,15),4:Q(25,26),5:Q(39,40),
        6:Q(983,1000),7:Q(99,100),8:Q(199,200)
    }
    checked=0; top=(Q(),None)
    for d in range(2,9):
        n=12*d
        for tag,p in (
            ("fair",Q(1,2)),
            ("biased",near_bernstein[d]),
            ("rare-tail",Q(n-1,n))
        ):
            score,R=chebyshev_weighted_R(d,n,p)
            checked+=1
            if score>top[0]: top=(score,(d,n,tag,p,R))
            assert score<=1,("candidate c=1 weighted R refuted",d,n,p,score)
    print("PASS 21 exact rational Chebyshev degree-weighted R tests;",
          "maximum",top[0],"witness",top[1])
    return checked


def main():
    for n in (2,4,8,10,20,50,100,300):
        p,q,V,M,R,K,cR,cK=AND_formula(n)
        print(f"AND n={n:3d}: p={p}, R={R}, K={K}, "
              f"ratio_R={float(cR):.9f}, ratio_K={float(cK):.9f}")
    for n in (2,3,4,5,6,7,8):
        _, count=original_law_truth_table_AND(n)
        print(f"PASS {count} original-source {n}-bit states: "
              "variance, conditional + 2-replica influences, pointwise R, full K")
    for m in (1,2,3):
        m,n,N,K,R=rubinstein_family(m)
        print(f"PASS classical Rubinstein m={m}, n={n}, worlds={N}: "
              f"R={R} and exact K_at_zero={K}, K/R={m}")
    structured_degree_weighted_R_stress()
    assert AND_formula(8)[6]>1 and AND_formula(100)[6]>14
    # The AND witness has algebraic degree d=n. Its normalized ratio
    # V²/(d R² M) tends to q(1-q)²>0, ruling out every degree exponent <1.
    assert AND_formula(300)[6]/300 >= Q(1,16)
    print("PASS NO-GO: no universal c makes Var² <= c R² max original influence")
    print("FULL fractional-row K bridge remains OPEN; no contradiction asserted.")


if __name__=="__main__":
    main()
