"""Exact Sidon constant K(L) of subcube characters (with free constant term), L <= 3.
K(L) = max over sign patterns sigma of LP(sigma) = max sum sigma_g c_g s.t. |c0 + sum c_g chi_g| <= 1.
Reductions (each exact): (1) translation S -> S + a multiplies sigma_g by chi_g(a); the point rows
are independent, so every pattern is equivalent to one with all point signs +.
(2) cube automorphisms (coordinate permutations and flips) permute subcubes and fix the point set.
(3) G -> -G maps sigma -> -sigma; re-normalising points by a = all-ones multiplies by (-1)^{|g|}."""
import itertools, sys, numpy as np
from scipy.optimize import linprog
L=int(sys.argv[1]); m=1<<L
specs=list(itertools.product((0,1,2),repeat=L))
def cells(spec): return [z for z in range(m) if all(spec[i]==2 or ((z>>i)&1)==spec[i] for i in range(L))]
R=[cells(s) for s in specs]
pts=[j for j,s in enumerate(specs) if 2 not in s]; oth=[j for j,s in enumerate(specs) if 2 in s]
N=1<<m; Sv=np.arange(N,dtype=np.int64)
X=np.zeros((N,len(R)))
for j,C in enumerate(R):
    par=np.zeros(N,dtype=np.int64)
    for z in C: par^=(Sv>>z)&1
    X[:,j]=1-2*par
Xc=np.hstack([np.ones((N,1)),X]); A=np.vstack([Xc,-Xc]); b=np.ones(2*N)
def lp(sig):
    r=linprog(-np.r_[0.0,sig],A_ub=A,b_ub=b,bounds=[(None,None)]*(len(R)+1),method='highs')
    return -r.fun
# group action on the non-point rows, as permutations of bit positions + optional complement
def spec_image(spec,perm,flip):
    out=[0]*L
    for i in range(L):
        v=spec[i]; out[perm[i]]= v if v==2 else v^flip[i]
    return tuple(out)
idx={s:j for j,s in enumerate(specs)}; pos={j:k for k,j in enumerate(oth)}
size=lambda j: len(R[j])
maps=[]
for perm in itertools.permutations(range(L)):
    for flip in itertools.product((0,1),repeat=L):
        maps.append([pos[idx[spec_image(specs[j],perm,flip)]] for j in oth])
neg_sign=np.array([(-1)**size(j)*-1 for j in oth])  # sigma_g -> -(-1)^{|g|} sigma_g
k=len(oth); codes=np.arange(1<<k,dtype=np.int64)
bits=((codes[:,None]>>np.arange(k))&1).astype(np.int8)        # 1 means sign -1
canon=np.full(1<<k,1<<62,dtype=np.int64)
negflip=(neg_sign<0).astype(np.int8)                           # positions whose sign flips under negation
for mp in maps:
    for neg in (0,1):
        b2=bits^negflip if neg else bits
        img=np.zeros(1<<k,dtype=np.int64)
        for src,dst in enumerate(mp): img|=(b2[:,src].astype(np.int64)<<dst)
        canon=np.minimum(canon,img)
reps=np.unique(canon)
print("L=%d rows=%d patterns=%d orbits=%d"%(L,len(R),1<<k,len(reps)),flush=True)
best=-1; arg=None
for c in reps:
    sig=np.ones(len(R))
    for t,j in enumerate(oth):
        if (c>>t)&1: sig[j]=-1
    v=lp(sig)
    if v>best+1e-9: best,arg=v,c
print("L=%d exact K=%.6f   linear 3(L+1)/4=%.4f   exponential 1.5^L=%.4f"%(L,best,0.75*(L+1),1.5**L))
print("argmax non-point minus-set:",[specs[oth[t]] for t in range(k) if (arg>>t)&1])
