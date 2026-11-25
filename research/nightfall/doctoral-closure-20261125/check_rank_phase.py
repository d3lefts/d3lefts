from functools import lru_cache
from itertools import product
from math import gcd

# Exact prime-field decision-tree optimization, no floating-point comparisons.
def optimal(states, rows, evaluate):
    n=len(states)
    partitions=set()
    for a in rows:
        groups={}
        for j,x in enumerate(states):
            y=evaluate(a,x)
            groups[y]=groups.get(y,0)|(1<<j)
        if len(groups)>1:
            partitions.add(tuple(sorted(groups.values())))
    partitions=tuple(partitions)
    M=max((len(p) for p in partitions),default=1)
    @lru_cache(None)
    def feasible(S,h):
        size=S.bit_count()
        if size<=1:return True
        if h==0 or M**h<size:return False
        opts=set()
        for part in partitions:
            children=tuple(sorted(z for b in part if (z:=b&S)))
            if len(children)>1 and max(z.bit_count() for z in children)<=M**(h-1):
                opts.add(children)
        for children in sorted(opts,key=lambda c:(max(z.bit_count() for z in c),sum(z.bit_count()**2 for z in c),c)):
            if all(feasible(z,h-1) for z in sorted(children,key=int.bit_count,reverse=True)):return True
        return False
    for h in range(n):
        if feasible((1<<n)-1,h):return h
    raise AssertionError('unseparable')

def instance(p,d,k):
    H=tuple(a for a in range(1,p) if pow(a,d,p)==1)
    assert len(H)==d
    vectors=tuple(product(range(p),repeat=k))
    orbits=tuple(x for x in vectors if x==min(tuple(a*t%p for t in x) for a in H))
    phases=tuple(product(H,repeat=k-1))
    def eval_row(a,x):return pow(sum(u*v for u,v in zip(a,x))%p,d,p)
    A=optimal(orbits,vectors,eval_row)
    S=optimal(phases,vectors,lambda a,x:eval_row(a,(1,)+x))
    assert A==k+S,(p,d,k,A,S)
    return p,d,k,len(orbits),len(phases),A,S

if __name__=='__main__':
    for p,d,k in [(3,2,1),(3,2,2),(3,2,3),(5,2,1),(5,2,2),(5,2,3),(5,4,2),(5,4,3),(7,2,2),(7,3,2),(7,6,2),(11,2,2),(11,5,2)]:
        print(*instance(p,d,k),flush=True)
