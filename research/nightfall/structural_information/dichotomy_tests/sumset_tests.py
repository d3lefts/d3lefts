# NOTE: maxsub returns (best_found, complete). A timed-out search is a lower bound, NOT an exact N_r.
import itertools, random, sys, time
def sumsets(R, rmax, m):
    full=1<<m; layers=[{0}]; cur={0}
    for r in range(1,rmax+1):
        cur = cur | {a^g for a in cur for g in R}
        layers.append(cur)
        if len(cur)==full:
            layers += [cur]*(rmax-r); break
    return layers
def maxsub(S, m, tlimit=20):
    if len(S)==1<<m: return m, True
    t0=time.time(); best=[0]; timed_out=[False]
    Sl=sorted(S-{0})
    def dfs(V, cands, d):
        if d>best[0]: best[0]=d
        if time.time()-t0>tlimit:
            timed_out[0]=True
            return
        # bound
        import math
        if d+int(math.log2(len(cands)/len(V)+1))<=best[0]: return
        for idx,v in enumerate(cands):
            W=V|{x^v for x in V}
            nc=[u for u in cands[idx+1:] if u not in W and all((u^w) in S for w in W)]
            dfs(W,nc,d+1)
    dfs({0},Sl,0)
    return best[0], not timed_out[0]
def gf_mul(a,b,k,poly):
    r=0
    while b:
        if b&1: r^=a
        b>>=1; a<<=1
        if a>>k&1: a^=poly
    return r
POLY={4:0b10011,5:0b100101,6:0b1000011}
def apn(k):
    R=[]
    for x in range(1,1<<k):
        x3=gf_mul(gf_mul(x,x,k,POLY[k]),x,k,POLY[k]); R.append(x|(x3<<k))
    return R,2*k
def bch(k,t):
    R=[]
    for x in range(1,1<<k):
        v=0;p=x
        x2=gf_mul(x,x,k,POLY[k])
        for j in range(t):
            v|=p<<(j*k); p=gf_mul(p,x2,k,POLY[k])
        R.append(v)
    return R,t*k
def rank1(a):
    R=[]
    for x in range(1,1<<a):
        for y in range(1,1<<a):
            v=0
            for i in range(a):
                if x>>i&1: v|=y<<(i*a)
            R.append(v)
    return R,a*a
def randrows(m,n,seed=0):
    rng=random.Random(seed); return [rng.randrange(1,1<<m) for _ in range(n)],m
fams=[("APN x^3, k=4",apn(4)),("APN x^3, k=5",apn(5)),("APN x^3, k=6",apn(6)),
      ("dual BCH t=2, k=5",bch(5,2)),("dual BCH t=2, k=6",bch(6,2)),
      ("rank-one, a=3",rank1(3)),
      ("random n=2m, m=12",randrows(12,24)),("random n=m^2, m=12",randrows(12,144)),("random n=2^(m/2), m=12",randrows(12,64))]
for name,(R,m) in fams:
    L=sumsets(set(R),4,m)
    out=[]
    for r in range(1,5):
        nr, exact = maxsub(L[r],m,15)
        label = "N=%d [EXACT]" % nr if exact else "N>=%d [TIMEOUT/LOWER BOUND]" % nr
        out.append("r=%d |rR|/2^m=%.2f %s"%(r,len(L[r])/2**m,label))
    print(name,"m=%d n=%d |"%(m,len(set(R)))," | ".join(out),flush=True)
