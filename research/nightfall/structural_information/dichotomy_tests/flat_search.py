"""Flat functions with spectrum in subcube characters: F = c0 + t*sum_g sigma_g chi_g.
D(sigma) = (max - min)/2 of sum_g sigma_g chi_g; the best flat F has every |c_g| = 1/D and Var = n/D^2.
(★) at row-degree 1 fails if D(sigma) = O(sqrt n) for some sigma (constant variance, flat coefficients)."""
import sys, random, numpy as np
sys.path.insert(0,'.'); from sidon_lp import char_matrix
L=int(sys.argv[1]); iters=int(sys.argv[2]); X=char_matrix(L).astype(np.int32); n=X.shape[1]
rng=random.Random(1); best=None
for restart in range(4):
    sig=np.array([rng.choice((1,-1)) for _ in range(n)],dtype=np.int32); v=X@sig
    D=(v.max()-v.min())/2
    for it in range(iters):
        j=rng.randrange(n); v2=v-2*sig[j]*X[:,j]; D2=(v2.max()-v2.min())/2
        if D2<=D: sig[j]*=-1; v=v2; D=D2
    best=D if best is None else min(best,D)
print("L=%d n=%d best D=%.1f  sqrt(n)=%.2f  ratio D/sqrt(n)=%.2f  => best flat Var=n/D^2=%.3f"%(L,n,best,n**.5,best/n**.5,n/best**2))
