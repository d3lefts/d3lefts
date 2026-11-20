import sys; sys.path.insert(0,'/tmp'); 
exec(open('sidon_extremals.py').read().split("for L,neg in")[0])
from fractions import Fraction as Fr
import numpy as np
from scipy.optimize import linprog
for L,neg in [(1,[]),(2,[(0,2),(1,2)]),(3,[(0,1,2),(0,2,2),(1,0,2),(1,1,2),(2,0,0),(2,0,1)])]:
    specs,X=setup(L); N,n=X.shape; sig=np.array([-1.0 if s in neg else 1.0 for s in specs])
    Xc=np.hstack([np.ones((N,1)),X]); A=np.vstack([Xc,-Xc])
    r=linprog(-np.r_[0.0,sig],A_ub=A,b_ub=np.ones(2*N),bounds=[(None,None)]*(n+1),method='highs')
    y=r.ineqlin.marginals; lam=-(y[:N]-y[N:])   # signed measure
    sup=np.nonzero(np.abs(lam)>1e-9)[0]
    vals=sorted(set(Fr(abs(float(l))).limit_denominator(200) for l in lam[sup]))
    print("L=%d ||lam||=%.4f support=%d of %d  |weights| in %s"%(L,np.abs(lam).sum(),len(sup),N,vals))
    # check constraints
    print("   check: lam_hat(0)=%.2e  max|lam_hat(g)-sigma_g|=%.2e"%(lam.sum(), np.abs(X.T@lam-sig).max()))
    m=1<<L
    print("   support S (truth tables as bit strings over points z=0..m-1):", [format(int(s),'0%db'%m)[::-1] for s in sup][:12])
