import itertools, numpy as np, sys
from scipy.optimize import linprog
from fractions import Fraction
def setup(L):
    m=1<<L; specs=list(itertools.product((0,1,2),repeat=L))
    R=[[z for z in range(m) if all(s[i]==2 or ((z>>i)&1)==s[i] for i in range(L))] for s in specs]
    N=1<<m; Sv=np.arange(N,dtype=np.int64); X=np.zeros((N,len(R)))
    for j,C in enumerate(R):
        par=np.zeros(N,dtype=np.int64)
        for z in C: par^=(Sv>>z)&1
        X[:,j]=1-2*par
    return specs,X
def solve(X,sig):
    N,n=X.shape; Xc=np.hstack([np.ones((N,1)),X]); A=np.vstack([Xc,-Xc])
    r=linprog(-np.r_[0.0,sig],A_ub=A,b_ub=np.ones(2*N),bounds=[(None,None)]*(n+1),method='highs')
    return -r.fun, r.x
for L,neg in [(1,[]),(2,[(0,2),(1,2)]),(3,[(0,1,2),(0,2,2),(1,0,2),(1,1,2),(2,0,0),(2,0,1)])]:
    specs,X=setup(L); sig=np.array([-1.0 if s in neg else 1.0 for s in specs])
    v,x=solve(X,sig); sym=lambda s:''.join('01*'[t] for t in s)
    print("L=%d K=%.4f const=%s"%(L,v,Fraction(x[0]).limit_denominator(64)))
    print("  ", ", ".join("%s:%s"%(sym(s),Fraction(c).limit_denominator(64)) for s,c in zip(specs,x[1:]) if abs(c)>1e-9))
print("--- values / variance of the extremal functions")
for L,neg in [(1,[]),(2,[(0,2),(1,2)]),(3,[(0,1,2),(0,2,2),(1,0,2),(1,1,2),(2,0,0),(2,0,1)])]:
    specs,X=setup(L); sig=np.array([-1.0 if s in neg else 1.0 for s in specs])
    v,x=solve(X,sig); G=x[0]+X@x[1:]; var=float((x[1:]**2).sum())
    print("L=%d  values=%s  Var=%.4f  max c^2=%.4f  (3(L+1)/(8L)=%.4f, 1/(4L^2)=%.4f)"%(L,sorted(set(np.round(G,6))),var,float((x[1:]**2).max()),3*(L+1)/(8*L),1/(4*L*L)))
