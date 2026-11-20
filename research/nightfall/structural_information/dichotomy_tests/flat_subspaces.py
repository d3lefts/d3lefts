"""Exact largest subspace contained in R ∪ {0} (N_1) for subcube rows, L <= 5. No time limit."""
import itertools
def rows(L):
    out=set()
    for spec in itertools.product((0,1,2),repeat=L):
        v=0
        for z in range(1<<L):
            if all(spec[i]==2 or ((z>>i)&1)==spec[i] for i in range(L)): v|=1<<z
        out.add(v)
    return out
def n1(R):
    S=R|{0}; best=0
    def dfs(V,cands,d):
        nonlocal best
        best=max(best,d)
        for i,v in enumerate(cands):
            W=V|{x^v for x in V}
            dfs(W,[u for u in cands[i+1:] if u not in W and all(u^w in S for w in W)],d+1)
    dfs({0},sorted(R),0); return best
for L in range(1,6):
    R=rows(L); print("L=%d rows=%d  N_1 (largest subspace inside R∪{0}) = %d"%(L,len(R),n1(R)),flush=True)
