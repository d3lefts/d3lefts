"""K for tensor-product sign patterns sigma(v1 x ... x vL) = prod_i s_i(v_i), s_i: {e0,e1,f} -> ±1."""
import sys, itertools, numpy as np
sys.path.insert(0,'.'); from sidon_lp import char_matrix, K
L=int(sys.argv[1]); X=char_matrix(L)
specs=list(itertools.product((0,1,2),repeat=L))  # same order as rows(): spec values 0,1,2(free)
pats=list(itertools.product((1,-1),repeat=3))
choices = itertools.product(pats,repeat=L) if L<=3 else ([p]*L for p in pats)
best=(0,None)
for ch in choices:
    sig=[int(np.prod([ch[i][spec[i]] for i in range(L)])) for spec in specs]
    v=K(X,sig)
    if v>best[0]+1e-9: best=(v,ch)
print("L=%d best tensor-pattern K=%.4f  (1.5^L=%.4f)  pattern=%s"%(L,best[0],1.5**L,best[1][0]))
