import numpy as np, itertools, sys
from scipy.optimize import minimize
n,d,trials=map(int,sys.argv[1:4])
pts=np.array(list(itertools.product([-1,1],repeat=n)),float)
mons=[S for k in range(1,d+1) for S in itertools.combinations(range(n),k)]
Phi=np.stack([np.prod(pts[:,list(S)],1) for S in mons],1)
flip=[np.array([int(''.join('1' if (b if j!=i else -b)>0 else '0' for j,b in enumerate(x)),2) for x in pts]) for i in range(n)]
idx=np.array([int(''.join('1' if b>0 else '0' for b in x),2) for x in pts]); order=np.argsort(idx)
def ratio(c):
    f=Phi@c; F=np.empty_like(f); F[idx]=f
    B=(f.max()-f.min())/2; V=f.var()
    L=max(np.mean(np.abs(f-F[fl]))/2 for fl in flip)  # resampling L1 influence
    return V/(B*L)
rng=np.random.default_rng(0); best=0
for t in range(trials):
    r=minimize(lambda c:-ratio(c),rng.standard_normal(len(mons)),method='Nelder-Mead',options={'maxiter':20000,'maxfev':20000})
    best=max(best,-r.fun)
print(f"n={n} d={d}: max V/(B*maxL) found = {best:.3f}  (d={d})")
