"""Exact full-Bayes nonadaptive physical vertex-read frontier on binary Ising paths.
Root sign uniform, independent edge increments with arbitrary means t_e in [-1,1].
Target f=c+sum_e c_e*U_e. Supports degenerate and biased edge transitions.
"""
from fractions import Fraction as F

def interval_gains(means,coeff):
    """w[i][j] = Var(E[sum_{e=i+1..j} c_e U_e | product U_e])."""
    assert len(means)==len(coeff)
    n=len(means)+1
    w=[[F(0) for j in range(n)] for i in range(n)]
    for i in range(n):
        T=F(1);C=F(0)
        for j in range(i+1,n):
            t=F(means[j-1]);c=F(coeff[j-1])
            assert -1<=t<=1
            C=C*t+c*(1-t*t)*T
            T=T*t
            denom=F(1)-T*T
            assert denom>=0
            if denom==0:
                assert C==0
                w[i][j]=F(0)
            else:
                w[i][j]=C*C/denom
    return w

def exact_risk(means,coeff,selected):
    n=len(means)+1
    selected=sorted(set(selected))
    assert all(isinstance(i,int) and 0<=i<n for i in selected)
    V=sum((F(c)**2*(1-F(t)**2) for t,c in zip(means,coeff)),F(0))
    w=interval_gains(means,coeff)
    return V-sum((w[i][j] for i,j in zip(selected,selected[1:])),F(0))

def optimum_nonadaptive_sites(means,coeff,budget):
    """Exact (minimum full Bayes risk, selected vertices); O(n^2*budget) arithmetic."""
    n=len(means)+1
    assert 0<=budget<=n
    V=sum((F(c)**2*(1-F(t)**2) for t,c in zip(means,coeff)),F(0))
    if budget<=1:return V,()
    w=interval_gains(means,coeff)
    prev={j:(F(0),(j,)) for j in range(n)}
    best=(F(0),())
    for k in range(2,budget+1):
        cur={}
        for j in range(n):
            options=[(gain+w[i][j],sites+(j,))
                     for i,(gain,sites) in prev.items() if i<j]
            if not options:continue
            cur[j]=min(options,key=lambda x:(-x[0],x[1]))
            cand=cur[j]
            if cand[0]>best[0] or (cand[0]==best[0] and cand[1]<best[1]):
                best=cand
        prev=cur
    return V-best[0],best[1]
