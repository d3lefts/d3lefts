"""Sidon-type constant of subcube characters: K(sigma) = max sum_g sigma_g c_g over |sum_g c_g chi_g| <= 1.
K = max_sigma K(sigma) bounds Var/max|c| for every bounded G with spectrum in R."""
import itertools, sys, numpy as np, random
from scipy.optimize import linprog
def rows(L):
    out=[]
    for spec in itertools.product((0,1,2),repeat=L):
        out.append([z for z in range(1<<L) if all(spec[i]==2 or ((z>>i)&1)==spec[i] for i in range(L))])
    return out
def char_matrix(L):
    R=rows(L); m=1<<L; N=1<<m
    S=np.arange(N,dtype=np.int64)
    X=np.zeros((N,len(R)))
    for j,C in enumerate(R):
        par=np.zeros(N,dtype=np.int64)
        for z in C: par^=(S>>z)&1
        X[:,j]=1-2*par
    return X
def K(X,sigma):
    # free constant term c0 included: |c0 + sum_g c_g chi_g| <= 1 everywhere
    n=X.shape[1]; Xc=np.hstack([np.ones((X.shape[0],1)),X])
    A=np.vstack([Xc,-Xc]); b=np.ones(2*X.shape[0])
    r=linprog(-np.array([0.0]+list(sigma),float),A_ub=A,b_ub=b,bounds=[(None,None)]*(n+1),method='highs')
    return -r.fun
if __name__=='__main__':
    L=int(sys.argv[1]); X=char_matrix(L); n=X.shape[1]; rng=random.Random(L)
    if n<=9:
        best=max(K(X,s) for s in itertools.product((1,-1),repeat=n)); print("L=%d exact K=%.4f (rows %d)"%(L,best,n)); sys.exit()
    best=0; sig=[rng.choice((1,-1)) for _ in range(n)]; cur=K(X,sig)
    for it in range(int(sys.argv[2])):
        s2=list(sig); 
        for _ in range(rng.choice((1,1,2,3))): j=rng.randrange(n); s2[j]*=-1
        v=K(X,s2)
        if v>=cur: sig,cur=s2,v
        best=max(best,cur)
    print("L=%d search K>=%.4f (rows %d; all-plus K=%.4f)"%(L,best,n,K(X,[1]*n)))
    