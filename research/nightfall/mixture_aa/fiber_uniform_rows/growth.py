import numpy as np, itertools, sys, time
sys.path.insert(0,'/tmp/fib'); from fiber_lp import lp, pts
rng=np.random.default_rng(int(sys.argv[1]))
for n in [4,5,6,7,8,9]:
    P=np.array(pts(n,2))*2-1
    best=(0,0,0)
    for t in range(3):
        E=np.triu(rng.choice([-1,1],size=(n,n)),1)
        q=np.einsum('pi,ij,pj->p',P,E,P)+P@rng.normal(size=n)*0.5
        if t==2: q=np.cos(np.pi*P.sum(1)/n*2)  # high-degree control (not low degree)
        f=(q-q.min())/(q.max()-q.min())
        a=lp(f,n,2,False); b=lp(f,n,2,True)
        if b/a>best[0]: best=(b/a,a,b)
        print(n,t,"plain %.3f fiber %.3f"%(a,b),flush=True)
