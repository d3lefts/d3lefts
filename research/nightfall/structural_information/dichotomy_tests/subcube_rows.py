import sys, itertools
sys.path.insert(0,'.'); from sumset_tests import sumsets, maxsub
def subcube_rows(L):
    R=[]
    for spec in itertools.product((0,1,2),repeat=L):  # 0: z_i=0, 1: z_i=1, 2: free
        v=0
        for z in range(1<<L):
            if all(spec[i]==2 or ((z>>i)&1)==spec[i] for i in range(L)): v|=1<<z
        R.append(v)
    return R,1<<L
for L in (3,4):
    R,m=subcube_rows(L); Ls=sumsets(set(R),5,m)
    print("subcube parities L=%d m=%d n=%d |"%(L,m,len(R))," | ".join("r=%d dens=%.3f N=%d"%(r,len(Ls[r])/2**m,maxsub(Ls[r],m,60)) for r in range(1,6)),flush=True)
