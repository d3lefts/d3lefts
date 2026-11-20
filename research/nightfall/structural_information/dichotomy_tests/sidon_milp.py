"""Exact Sidon constant K(L) = max sum_g |c_g| s.t. |c0 + sum_g c_g chi_g(S)| <= 1 for all S, via MILP."""
import sys, numpy as np
from scipy.optimize import milp, LinearConstraint, Bounds
from scipy.sparse import csr_matrix, hstack, vstack, identity, coo_matrix
sys.path.insert(0,'.'); from sidon_lp import char_matrix
L=int(sys.argv[1]); tl=float(sys.argv[2]) if len(sys.argv)>2 else 600
X=char_matrix(L); P,n=X.shape
# variables: c0, c[n], t[n], b[n]
nv=1+3*n
def col(a,b): return slice(a,b)
A=[];lo=[];hi=[]
M=np.hstack([np.ones((P,1)),X,np.zeros((P,2*n))]); A.append(csr_matrix(M)); lo+= [-1]*P; hi+=[1]*P
# t_g - c_g - 2(1-b_g) <= 0  ->  t - c + 2b <= 2 ;  t_g + c_g - 2 b_g <= 0
I=identity(n,format='csr'); Z=csr_matrix((n,1))
A.append(hstack([Z,-I,I,2*I])); lo+=[-np.inf]*n; hi+=[2]*n
A.append(hstack([Z,I,I,-2*I])); lo+=[-np.inf]*n; hi+=[0]*n
A=vstack(A).tocsr()
c=np.zeros(nv); c[1+n:1+2*n]=-1
integ=np.zeros(nv); integ[1+2*n:]=1
bounds=Bounds(np.r_[-1,[-1]*n,[0]*n,[0]*n], np.r_[1,[1]*n,[1]*n,[1]*n])
r=milp(c,constraints=LinearConstraint(A,lo,hi),integrality=integ,bounds=bounds,options={"time_limit":tl,"disp":False})
print("L=%d status=%s K=%.4f  bound=%s  (0.75(L+1)=%.3f, 1.5^L=%.3f)"%(L,r.status,-r.fun if r.x is not None else float('nan'), getattr(r,'mip_dual_bound',None), 0.75*(L+1),1.5**L))
