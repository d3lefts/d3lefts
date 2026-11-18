#!/usr/bin/env python3
"""Exact finite-instance checker for Wick-centered cubic vertex-cover transfer.

It does NOT certify the all-size Poincare or quadratic coercivity premises.
Zero-field signed Ising examples; full-state Fraction arithmetic, exact
quadratic covariance Gram coercivity via LDL and native site influences.
"""
from fractions import Fraction as Q
from itertools import combinations
from math import prod

def spin(s,i): return 1 if (s>>i)&1 else -1

def law_of(n,edges):
    raw={s:prod((1+t*spin(s,i)*spin(s,j) for i,j,t in edges),start=Q(1)) for s in range(1<<n)}
    Z=sum(raw.values())
    return {s:w/Z for s,w in raw.items()}

def moment(p, inds):
    return sum((w*prod((spin(s,i) for i in inds),start=1) for s,w in p.items()),Q(0))

def positive_definite(mat):
    size=len(mat)
    L=[[Q(0)]*size for _ in range(size)]
    diag=[]
    for i in range(size):
        d=mat[i][i]-sum((L[i][k]*L[i][k]*diag[k] for k in range(i)),Q(0))
        if d<=0:return False
        diag.append(d)
        L[i][i]=Q(1)
        for j in range(i+1,size):
            L[j][i]=(mat[j][i]-sum((L[j][k]*L[i][k]*diag[k] for k in range(i)),Q(0)))/d
    return True

def audit(n, edges, H, tag):
    p=law_of(n,edges)
    assert sum(p.values())==1 and min(p.values())>0
    alpha=max(sum((abs(t) for i,j,t in edges if v in (i,j)),Q(0)) for v in range(n))
    assert 0<=alpha<1
    A=1/(1-alpha)
    pairs=list(combinations(range(n),2))
    # Full quadratic covariance matrix; extract an independently certified
    # rational coercivity beta with full PSD check.
    C2=[[moment(p,tuple(sorted(set(a)^set(b))))-moment(p,a)*moment(p,b)
         for b in pairs] for a in pairs]
    beta=Q(1)
    while not positive_definite([[C2[i][j]-(beta if i==j else 0)
                                  for j in range(len(pairs))] for i in range(len(pairs))]):
        beta/=2
        assert beta>Q(1,2**80)
    v=min(
        4*p[s]*p[s^(1<<i)]/(p[s]+p[s^(1<<i)])**2
        for i in range(n) for s in p if (s>>i)&1
    )
    assert v>0
    # Each cubic support touches H. No pair or constant terms.
    cubics={T:Q((((sum(T)+1)*13+max(T)*5)%13)-6,17)
            for T in combinations(range(n),3) if any(i in H for i in T)}
    assert cubics
    def M(s):
        return sum((c*prod((spin(s,i) for i in T),start=1) for T,c in cubics.items()),Q(0))
    # Correct all mean physical gradients, including outside H.
    linear={
        i:-sum((c*moment(p,tuple(j for j in T if j!=i))
                for T,c in cubics.items() if i in T),Q(0))
        for i in range(n)
    }
    def f(s):return M(s)+sum((a*spin(s,i) for i,a in linear.items()),Q(0))
    def gradient(s,i):
        return linear[i]+sum(
            (c*prod((spin(s,j) for j in T if j!=i),start=1)
             for T,c in cubics.items() if i in T),Q(0))
    assert all(sum((p[s]*gradient(s,i) for s in p),Q(0))==0 for i in range(n))
    m=sum((p[s]*f(s) for s in p),Q(0))
    V=sum((p[s]*(f(s)-m)**2 for s in p),Q(0))
    I=[]
    for i in range(n):
        val=Q(0)
        for s in p:
            if not (s>>i)&1:continue
            other=s^(1<<i)
            val+=p[s]*p[other]/(p[s]+p[other])*(f(s)-f(other))**2
        I.append(val)
        # Verify exact conditional variance coefficient and beta-coercivity
        gi_var=sum((p[s]*gradient(s,i)**2 for s in p),Q(0))
        ci_sq=sum((c*c for T,c in cubics.items() if i in T),Q(0))
        assert val >=v*gi_var
        assert gi_var >=beta*ci_sq
    mass=sum((c*c for c in cubics.values()),Q(0))
    assert V<=6*A**3*mass
    assert mass<=sum((sum((c*c for T,c in cubics.items() if i in T),Q(0))
                      for i in H),Q(0))
    Mx=max(I)
    C=6*A**3*len(H)/(v*beta)
    assert V<=C*Mx
    B=max(abs(f(s)) for s in p)
    assert V*V<=C*B*B*Mx
    print('PASS',tag,'n',n,'cover',len(H),'alpha',alpha,
          'beta',beta,'v',v,'cubic-var',V,'Imax',Mx,'C',float(C))
    
if __name__=='__main__':
    audit(4,[(0,1,Q(1,7)),(1,2,Q(-1,8)),(2,3,Q(1,9)),(3,0,Q(-1,10))],(0,),'signed square')
    audit(5,[(0,1,Q(1,9)),(1,2,Q(-1,10)),(2,3,Q(1,11)),(3,4,Q(-1,12)),(4,0,Q(1,13)),(0,2,Q(-1,14))],(0,),'signed pentagon')
    audit(6,[(0,1,Q(1,12)),(1,2,Q(-1,13)),(2,3,Q(1,14)),(3,4,Q(-1,15)),(4,5,Q(1,16)),(5,0,Q(-1,17)),(0,3,Q(1,18))],(0,1),'signed six-cycle')
    print('PASS all full quadratic-coercivity and centered cubic native influence audits')
