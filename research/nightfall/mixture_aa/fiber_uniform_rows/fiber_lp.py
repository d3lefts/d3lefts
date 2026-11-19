import numpy as np, itertools, sys
from scipy.optimize import linprog
from scipy.sparse import lil_matrix, csr_matrix
def pts(n,k): return list(itertools.product(range(k),repeat=n))
def lp(fv,n,k,fiber):
    P=pts(n,k); idx={p:i for i,p in enumerate(P)}
    # variables: fiber: alpha[i, x_{-i}] ; plain: a[i,x]
    if fiber:
        sub=pts(n-1,k); sidx={s:j for j,s in enumerate(sub)}
        var=lambda i,x: i*len(sub)+sidx[x[:i]+x[i+1:]]; nv=n*len(sub)
    else:
        var=lambda i,x: i*len(P)+idx[x]; nv=n*len(P)
    rows=[];rhs=[]
    for x in P:
        for y in P:
            dlt=abs(fv[idx[x]]-fv[idx[y]])
            if dlt<1e-12: continue
            D=[i for i in range(n) if x[i]!=y[i]]
            rows.append(([var(i,x) for i in D],-1.0)); rhs.append(-dlt)
    for x in P:  # cost <= t
        rows.append(([var(i,x) for i in range(n)]+[nv],None)); rhs.append(0)
    A=lil_matrix((len(rows),nv+1))
    for r,(vs,s) in enumerate(rows):
        if s is None:
            for v in vs[:-1]: A[r,v]=1
            A[r,nv]=-1
        else:
            for v in vs: A[r,v]=-1
    c=np.zeros(nv+1);c[nv]=1
    res=linprog(c,A_ub=csr_matrix(A),b_ub=np.array(rhs),bounds=[(0,1)]*nv+[(0,None)],method='highs')
    return res.fun
def deg_poly(n,k,d,rng):
    P=pts(n,k); f=np.zeros(len(P))
    for S in itertools.combinations(range(n),d):
        tab=rng.normal(size=(k,)*d)
        for j,p in enumerate(P): f[j]+=tab[tuple(p[i] for i in S)]
    f=(f-f.min())/(f.max()-f.min()); return f
if __name__=="__main__":
    rng=np.random.default_rng(int(sys.argv[1]) if len(sys.argv)>1 else 0)
    worst=(0,None)
    for n,k,d in [(4,2,2),(5,2,2),(4,3,2),(5,2,3),(6,2,2),(4,3,3),(6,2,3)]:
        for t in range(12 if n<6 else 4):
            f=deg_poly(n,k,d,rng)
            if t%3==1: f=np.round(f)            # Boolean degree<=d? (rounding raises degree; still bounded) skip ratio
            if t%3==1: continue
            if t%3==2:  # sharpen: Chebyshev-like amplification of a degree-1 sum
                P=pts(n,k); s=np.array([sum(p) for p in P],float); s=s/s.max()
                T=np.polynomial.chebyshev.Chebyshev([0]*d+[1])
                f=(T(2*s-1)+1)/2
            a=lp(f,n,k,False); b=lp(f,n,k,True)
            r=b/max(a,1e-9); 
            if r>worst[0]: worst=(r,(n,k,d,a,b))
            print(n,k,d,"plain %.3f fiber %.3f ratio %.2f"%(a,b,r),flush=True)
    print("WORST",worst)
