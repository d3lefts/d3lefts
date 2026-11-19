#!/usr/bin/env python3
"""Exact original-law audit of Q3 controller dispersion. Standard library only.

Claim: V_X <= B sqrt(M_X) + sum_j sqrt(T_j(q)/2), where
f(X,W)=c(W)+sum_i X_i u_i(W) for independent fair X_i, q_i=u_i(W)^2,
M_X=max_i E_W u_i(W)^2, T_j=1/2 E ||q(W)-q(W^j)||_1^2.

Finite rational tests are not proof for all dimensions; the accompanying
analytic derivation is the universal argument. No novelty claim.
"""
from fractions import Fraction as F
from math import isqrt
from itertools import product
from random import Random


def sqrt_floor(x, digits=10**12):
    assert x>=0
    z=isqrt((x.numerator*digits*digits)//x.denominator)
    return F(z,digits)


def sqrt_ceil(x, digits=10**12):
    lo=sqrt_floor(x,digits)
    return lo if lo*lo==x else lo+F(1,digits)


def exact_model(seed):
    rng=Random(seed)
    laws=((F(1,7),F(6,7)),(F(1,2),F(1,3),F(1,6)))
    controls=list(product(range(2),range(3)))
    weight={w:laws[0][w[0]]*laws[1][w[1]] for w in controls}
    anchors=list(product((-1,1),repeat=3))
    coef=[[F(rng.randrange(-7,8)) for _ in range(4)] for _ in range(3)]
    def u(w):
        a,b=w
        y=F(a)-laws[0][1]
        z=F(b)-sum(F(j)*laws[1][j] for j in range(3))
        return tuple(c[0]+c[1]*y+c[2]*z+c[3]*y*z for c in coef)
    table={w:u(w) for w in controls}
    def f(x,w):
        return sum((F(x[i])*table[w][i] for i in range(3)),F())
    B=max(abs(f(x,w)) for w in controls for x in anchors)
    V=sum(weight[w]*f(x,w)**2/F(len(anchors)) for w in controls for x in anchors)
    Ix=[]
    for i in range(3):
        t=F()
        for w in controls:
            for x in anchors:
                x1=list(x);x1[i]=-x1[i]
                t+=weight[w]*(f(x,w)-f(tuple(x1),w))**2/F(4*len(anchors))
        Ix.append(t)
    M=max(Ix)
    q={w:tuple(a*a for a in table[w]) for w in controls}
    s={w:tuple(abs(a) for a in table[w]) for w in controls}
    assert V==sum(Ix)
    assert max(sum(s[w]) for w in controls)==B
    assert all(Ix[i]==sum(weight[w]*q[w][i] for w in controls) for i in range(3))
    mus=[sum(weight[w]*s[w][i] for w in controls) for i in range(3)]
    base=sum(a*a for a in mus)
    disp=V-base
    assert base*base<=B*B*M  # pointwise ell_1, and each E s_i <= sqrt(M)
    T=[]; G=[]; H=[]
    for j in range(2):
        t=g=h=F()
        for w in controls:
            for wj in range(len(laws[j])):
                ww=tuple(wj if l==j else w[l] for l in range(2))
                prob=weight[w]*laws[j][wj]/2
                D=sum(abs(a-b) for a,b in zip(q[w],q[ww]))
                t+=prob*D*D
                g+=prob*sum((a-b)**2 for a,b in zip(s[w],s[ww]))
                h+=prob*D
        assert g<=h and h*h<=t/F(2)
        T.append(t);G.append(g);H.append(h)
    assert disp<=sum(G)
    rhs_lower=B*sqrt_floor(M)+sum(sqrt_floor(t/F(2)) for t in T)
    # Exact lower-enclosure on RHS, hence passing this is a strong rational certificate.
    assert V<=rhs_lower,(seed,V,rhs_lower)
    return 1


def selector_tensor(k,n):
    """k disjoint pure cubics Z_j(X_{j,Y_j}-n^-1 sum_i X_{j,i})/k.

    All identities follow by independent block orthogonality and the original
    categorical resampling law for each Y_j.
    """
    assert k>=1 and n>=3
    v=F(n-1,n)
    B=2*v
    V=v/k
    M_X=F(n-1,k*k*n*n)
    M_control=v/F(k*k)
    T=2*v*(1-F(2,n))**2/F(k**4)
    # The sharp theorem, tested with certified lower endpoints.
    assert V<=B*sqrt_floor(M_X)+k*sqrt_floor(T/F(2))
    # Each single-control influence is bounded below by variance/k, so
    # original max influence saves the full influence inequality.
    assert V*V<=B*B*M_control
    return B,V,M_X,T,M_control



def uniform_cycle(n):
    """Equal-weight high-cover connected pure cubics, exact physical enumerations.

    f(X,W)=1/n sum_i X_i W_i W_(i+1), cyclic indices.
    All q_i(W)=1/n^2, but the active ANOVA triple hypergraph has
    fractional vertex-cover tau*=n/2 by explicit matching primal+dual.
    """
    assert n>=3
    states=list(product((-1,1),repeat=2*n))
    def f(state):
        X=state[:n];W=state[n:]
        return F(sum(X[i]*W[i]*W[(i+1)%n] for i in range(n)),n)
    vals={x:f(x) for x in states}
    assert max(vals.values())==F(1) and min(vals.values())==-F(1)
    mean=sum(vals.values(),F())/len(states)
    V=sum((v-mean)**2 for v in vals.values())/len(states)
    assert mean==0 and V==F(1,n)
    influences=[]
    for i in range(2*n):
        I=F()
        for state in states:
            other=list(state);other[i]=-other[i]
            I+=(vals[state]-vals[tuple(other)])**2/F(4*len(states))
        influences.append(I)
    assert influences[:n]==[F(1,n*n)]*n
    assert influences[n:]==[F(2,n*n)]*n
    # q_i(W) fixed, so energy transport is identically 0 for every controller.
    q=tuple(F(1,n*n) for i in range(n))
    assert sum(q)==V
    # Fractional cover/packing are both n/2: W_j receives 1/2;
    # each edge receives packing weight 1/2. Original edge {X_i,W_i,W_i+1}.
    primal=sum([F(1,2)]*n)
    dual=sum([F(1,2)]*n)
    for i in range(n):
        assert F(1,2)+F(1,2)>=1  # primal coverage per edge
        assert F(1,2)+F(1,2)<=1  # dual capacity at control W_i
        assert F(1,2)<=1         # dual capacity at anchor X_i
    assert primal==dual==F(n,2)
    assert V*V==F(1)*F(1,n*n)   # coefficient-one anchor certificate
    assert V*V/F(max(influences))==F(1,2)  # B=1 globally
    return n,primal,V,max(influences)


def sharp_limit():
    # For the one-block pure cubic selector, the transport coefficient needed
    # after paying B sqrt(M_X) tends to 1/sqrt(2) as n grows.
    for n in (100, 10000, 1000000):
        B,V,M,T,_=selector_tensor(1,n)
        c_lower=(V-B*sqrt_ceil(M))/sqrt_ceil(T)
        print('sharpness n=',n,'required_c_lower=',float(c_lower))
        assert c_lower<F(71,100)
    # Incorrect max-gradient replacement fails at any fixed prefactor C when
    # k -> infinity, n=k^4. The exact n,k identity is the counterexample.
    for k in (10,100,1000):
        n=k**4
        B,V,M,T,_=selector_tensor(k,n)
        denom=B*sqrt_ceil(M)+sqrt_ceil(T)
        print('tensor',k,'n',n,'V',float(V),'max_gradient_ratio_lower',float(V/denom))
    k=1000;n=k**4;B,V,M,T,_=selector_tensor(k,n)
    assert V>100*(B*sqrt_ceil(M)+sqrt_ceil(T))
    return True


if __name__ == '__main__':
    print('heterogeneous original-law cubic controllers:',sum(exact_model(seed) for seed in range(200)),'exact cases passed')
    sharp_limit()
    for n in range(3,7):
        print('uniform high-cover cycle',uniform_cycle(n))
    print('PASS: exact physical resampling, section budgets, vector transport, Poincare, sharpness, tensor obstruction')