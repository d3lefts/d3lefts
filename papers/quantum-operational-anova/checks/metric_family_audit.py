#!/usr/bin/env python3
"""Seeded complex-matrix audit across SLD, geometric, WY and BKM means."""
import numpy as np
from functools import reduce
from itertools import product
rng=np.random.default_rng(20261111)
N=200
means=('SLD','geometric','Wigner-Yanase','Bogoliubov-Kubo-Mori')
def kp(a):return reduce(np.kron,a,np.ones((1,1),complex))
def mean(x,y,name):
    if name=='SLD':return (x+y)/2
    if name=='geometric':return np.sqrt(x*y)
    if name=='Wigner-Yanase':return ((np.sqrt(x)+np.sqrt(y))/2)**2
    if abs(x-y)<1e-13:return (x+y)/2
    return (x-y)/(np.log(x)-np.log(y))
def score(B,A,metric):
    lam=np.diag(B).real
    w=np.empty((len(lam),len(lam)))
    for i,x in enumerate(lam):
        for j,y in enumerate(lam):w[i,j]=mean(x,y,metric)
    return float((np.abs(A)**2/w).sum())
for it in range(N):
    p=rng.uniform(.15,.85,size=3)
    b=[];d=[];rho=[]
    for i in range(3):
        e=rng.uniform(.04,.46)
        bi=np.diag([1-e,e]).astype(complex)
        theta=rng.uniform(-np.pi,np.pi)
        off=np.sqrt(e*(1-e))*.2*np.exp(1j*theta)
        di=np.array([[rng.uniform(-.1,.1)*min(e,1-e),off],[np.conj(off),0]],complex)
        di[1,1]=-di[0,0]
        r0=bi+p[i]*di;r1=bi-(1-p[i])*di
        assert np.linalg.eigvalsh(r0)[0]>0 and np.linalg.eigvalsh(r1)[0]>0
        assert np.linalg.norm(bi@di-di@bi)>1e-15
        b.append(bi);d.append(di);rho.append((r0,r1))
    c={mask:rng.normal() for mask in range(1,8)}
    v=p*(1-p)
    xs=list(product([0,1],repeat=3))
    def target(x):
        t=np.array([p[i] if x[i]==0 else -(1-p[i]) for i in range(3)])
        return sum(z*np.prod([t[i] for i in range(3) if mask&(1<<i)]) for mask,z in c.items())
    signals={}
    for mask in range(1,8):
        inds=[i for i in range(3) if mask&(1<<i)]
        B=kp([b[i] for i in inds]);A=np.zeros_like(B)
        for x in xs:
            wt=np.prod([p[i] if x[i]==1 else 1-p[i] for i in range(3)])
            A+=wt*target(x)*kp([rho[i][x[i]] for i in inds])
        signals[mask]=(B,A)
    components={}
    for mask,z in c.items():
        inds=[i for i in range(3) if mask&(1<<i)]
        As=z*np.prod([v[i] for i in inds])*kp([d[i] for i in inds])
        components[mask]=(kp([b[i] for i in inds]),As)
    for met in means:
        g={0:0.0}
        for mask in range(1,8):g[mask]=score(*signals[mask],met)
        gamma={mask:score(*pair,met) for mask,pair in components.items()}
        for mask in range(8):
            delta=g[mask]-sum(y for S,y in gamma.items() if (S&mask)==S)
            assert abs(delta)<2e-10*max(1,abs(g[mask])),(it,met,mask,delta)
        for S in range(1,8):
            mob=sum((-1)**((S^T).bit_count())*g[T] for T in range(8) if T&S==T)
            assert abs(mob-gamma[S])<2e-10*max(1,abs(gamma[S])),(it,met,S)
            assert gamma[S]>=0
print(f"PASS {N} seeded noncommuting complex ensembles x 4 symmetric means")
