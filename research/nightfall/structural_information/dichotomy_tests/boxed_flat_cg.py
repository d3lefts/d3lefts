"""Cutting-plane version of boxed_flat.py (same LP, exact): keep only active points S, add the most violated ones.
Usage: boxed_flat_cg.py L t iters"""
import sys, random, numpy as np
from scipy.optimize import linprog
sys.path.insert(0,'.')
from sidon_lp import char_matrix
L=int(sys.argv[1]); t=float(sys.argv[2]); iters=int(sys.argv[3]); X=char_matrix(L); N,n=X.shape
Xc=np.hstack([np.ones((N,1)),X])
def run(sig,W0):
    W=list(W0); bounds=[(None,None)]+[((0,t) if s>0 else (-t,0)) for s in sig]
    while True:
        A=np.vstack([Xc[W],-Xc[W]])
        r=linprog(-np.r_[0.0,sig],A_ub=A,b_ub=np.ones(2*len(W)),bounds=bounds,method='highs')
        x=r.x; F=Xc@x; viol=np.abs(F)-1
        bad=np.argsort(-viol)[:64]; bad=[int(i) for i in bad if viol[i]>1e-9]
        if not bad: c=x[1:]; return float((c*c).sum()), -r.fun, W
        W+=bad
rng=random.Random(L*1000+int(1/t)); sig=np.array([rng.choice((1.,-1.)) for _ in range(n)])
W=list(range(0,N,max(1,N//256)))
best,l1,W=run(sig,W)
for it in range(iters):
    s2=sig.copy()
    for _ in range(rng.choice((1,1,2,3))): j=rng.randrange(n); s2[j]*=-1
    v,l,W2=run(s2,W)
    if v>=best: sig,best,l1,W=s2,v,l,W2
print("L=%d t=%.4f: best Var found=%.4f  sum|c|=%.3f  (all rows at cap would give Var %.3f)"%(L,t,best,l1,n*t*t),flush=True)
