"""(★) at row-degree 1, direct test: with every |c_g| <= t, how much variance can a bounded F = c0 + sum c_g chi_g have?
For a sign pattern sigma, LP: maximise sum sigma_g c_g s.t. |F| <= 1, 0 <= sigma_g c_g <= t. Report Var = sum c_g^2 of the
optimum; local search over sigma maximises it. Small t with Var bounded below would refute polylog (★) at d = 1."""
import sys, random, numpy as np
from scipy.optimize import linprog
sys.path.insert(0,'.')
from sidon_lp import char_matrix
L=int(sys.argv[1]); t=float(sys.argv[2]); iters=int(sys.argv[3]); X=char_matrix(L); N,n=X.shape
Xc=np.hstack([np.ones((N,1)),X]); A=np.vstack([Xc,-Xc]); b=np.ones(2*N)
def run(sig):
    bounds=[(None,None)]+[((0,t) if s>0 else (-t,0)) for s in sig]
    r=linprog(-np.r_[0.0,sig],A_ub=A,b_ub=b,bounds=bounds,method='highs')
    c=r.x[1:]; return float((c*c).sum()), -r.fun
rng=random.Random(L*1000+int(1/t)); sig=np.array([rng.choice((1.,-1.)) for _ in range(n)]); best,l1=run(sig)
for it in range(iters):
    s2=sig.copy()
    for _ in range(rng.choice((1,1,2,3))): j=rng.randrange(n); s2[j]*=-1
    v,l=run(s2)
    if v>=best: sig,best,l1=s2,v,l
print("L=%d t=%.4f (t^2=%.4f): best Var found=%.4f  sum|c|=%.3f  rows at cap=%d"%(L,t,t*t,best,l1,int(round(l1/t))))
