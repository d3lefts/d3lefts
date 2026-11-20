import itertools
from collections import Counter
def rows(L):
    out=[]
    for spec in itertools.product((0,1,2),repeat=L):
        v=0
        for z in range(1<<L):
            if all(spec[i]==2 or ((z>>i)&1)==spec[i] for i in range(L)): v|=1<<z
        out.append(v)
    return out
for L in range(1,6):
    R=rows(L)+[0]   # include the no-query branch
    cnt=Counter(a^b for a in R for b in R if a!=b)
    mx=max(cnt.values()); arg=max(cnt,key=cnt.get)
    print("L=%d rows=%d  max ordered pair multiplicity=%d  (2L+2=%d)  witness weight=%d"%(L,len(R)-1,mx,2*L+2,bin(arg).count('1')),flush=True)
