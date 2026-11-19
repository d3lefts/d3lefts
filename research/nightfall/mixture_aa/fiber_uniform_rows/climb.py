import numpy as np, itertools, sys
sys.path.insert(0,'/tmp/fib'); from fiber_lp import lp, pts
rng=np.random.default_rng(int(sys.argv[1])); n,k,d,iters=map(int,sys.argv[2:6])
P=pts(n,k); Ss=list(itertools.combinations(range(n),d))
def build(C):
    f=np.zeros(len(P))
    for S,tab in zip(Ss,C):
        for j,p in enumerate(P): f[j]+=tab[tuple(p[i] for i in S)]
    return (f-f.min())/(f.max()-f.min()+1e-12)
def score(C):
    f=build(C); a=lp(f,n,k,False); b=lp(f,n,k,True); return b/a,a,b
C=[rng.normal(size=(k,)*d)*rng.exponential() for _ in Ss]; best=score(C)
for it in range(iters):
    C2=[c+rng.normal(size=c.shape)*0.3*rng.random() for c in C]
    s=score(C2)
    if s[0]>=best[0]: C,best=C2,s
print(n,k,d,"best ratio %.3f plain %.3f fiber %.3f"%best,flush=True)
