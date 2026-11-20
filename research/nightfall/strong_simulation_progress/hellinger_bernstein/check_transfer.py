import numpy as np, itertools
rng=np.random.default_rng(0); worst=0
for trial in range(20000):
    n=rng.integers(1,4); k=rng.integers(2,4)
    def rp():
        p=rng.random(k)**rng.choice([1,6]); p[rng.random(k)<0.2]=0
        if p.sum()==0: p[0]=1
        return p/p.sum()
    mu=[rp() for _ in range(n)]; mb=[rp() for _ in range(n)]
    if rng.random()<0.5: mu=[np.clip(m+rng.normal(0,.01,k),0,None) for m in mb]; mu=[m/m.sum() for m in mu]
    f=rng.random((k,)*n)
    if rng.random()<0.5: f=(f>0.5).astype(float)
    def E(ms):
        P=ms[0]
        for m in ms[1:]: P=np.multiply.outer(P,m)
        return (P*f).sum()
    th=max(np.arccos(min(1,np.sqrt(a*b).sum())) for a,b in zip(mu,mb))
    d=abs(E(mu)-E(mb))
    if th>0: worst=max(worst,d/(n*th))
print("max |Δ|/(h·θmax) =",worst)
