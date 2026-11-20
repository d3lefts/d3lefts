# Instance-specific check of the Key Lemma chain:
# E_th E_u |f(h_th(u)) - f(hbar(u))| <= K_f * max_j Pr_th[j in L_th] + S_f * max_{th, j notin L_th} Pr[mismatch]
import numpy as np, itertools, sys
sys.path.insert(0,'/tmp/fib'); from fiber_lp import lp, pts
rng=np.random.default_rng(int(sys.argv[1])); n,k,M=5,2,24
P=pts(n,k); idx={p:i for i,p in enumerate(P)}
def deg2():
    f=np.zeros(len(P))
    for S in itertools.combinations(range(n),2):
        t=rng.normal(size=(k,k))
        for j,p in enumerate(P): f[j]+=t[p[S[0]],p[S[1]]]
    return (f-f.min())/(f.max()-f.min())
f=deg2(); K_f=lp(f,n,k,False)
S_f=max(sum(max(abs(f[idx[p[:i]+(b,)+p[i+1:]]]-f[idx[p[:i]+(c,)+p[i+1:]]]) for b in range(k) for c in range(k)) for i in range(n)) for p in P)
base=rng.dirichlet(np.ones(k),size=n)
mu=np.repeat(base[None],M,0).copy()
for th in range(M):  # spiky: each component strongly moves a random 2-set, small noise elsewhere
    for j in rng.choice(n,2,replace=False): mu[th,j]=rng.dirichlet(0.3*np.ones(k))
    mu[th]+=rng.normal(0,0.01,(n,k)); mu[th]=np.clip(mu[th],1e-9,None); mu[th]/=mu[th].sum(1,keepdims=True)
pi=np.ones(M)/M; nub=(pi[:,None,None]*mu).sum(0)
phi=np.arccos(np.clip(np.sqrt(mu*nub[None]).sum(2),0,1))
def cs(p,draws):  # consistent sampling
    for s,r in draws:
        if r<p[s]: return s
    return int(np.argmax(p))
worst=-1
for eta in [0.05,0.1,0.2,0.4]:
    L=phi>eta; pL=L.mean(0).max()
    lhs=0; mm=np.zeros((M,n)); T=3000
    for t in range(T):
        draws=[list(zip(rng.integers(0,k,400),rng.random(400))) for j in range(n)]
        xb=tuple(cs(nub[j],draws[j]) for j in range(n))
        for th in range(M):
            y=tuple(cs(mu[th,j],draws[j]) for j in range(n))
            lhs+=abs(f[idx[y]]-f[idx[xb]])/M
            mm[th]+=np.array(y)!=np.array(xb)
    lhs/=T; mm/=T
    q=np.where(L,0,mm).max()
    rhs=K_f*pL+S_f*q
    print("eta %.2f  LHS %.4f  RHS %.4f  (K_f %.2f maxPr[L] %.3f  S_f %.2f maxq_small %.3f)"%(eta,lhs,rhs,K_f,pL,S_f,q),flush=True)
