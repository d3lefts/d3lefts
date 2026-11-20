import itertools
def rows(L):
    out=[]
    for spec in itertools.product((0,1,2),repeat=L):
        v=0
        for z in range(1<<L):
            if all(spec[i]==2 or ((z>>i)&1)==spec[i] for i in range(L)): v|=1<<z
        out.append(v)
    return out
for L in (1,2,3,4):
    R=rows(L); m=1<<L
    dmin=min(sum(bin(S&r).count('1')&1 for r in R) for S in range(1,1<<m))
    print("L=%d m=%d n=%d input-code min distance=%d (2^L=%d)"%(L,m,len(R),dmin,2**L))
