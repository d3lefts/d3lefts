#!/usr/bin/env python3
"""Finite exact falsification of witness-width * block-rank adaptive bound.
Domain: total Boolean sensor systems n=1,2,3 exhaustively and named 4,5-bit controls.
Discovery cost is number of sensor queries, not computational search cost.
"""
from functools import lru_cache
from itertools import combinations
from collections import defaultdict
import json

def sample(n, truth):
    X=range(1<<n)
    groups={}
    for obs in range(1<<n):
        for x in X:
            key=x&obs
            groups[(obs,key)]=tuple(z for z in X if (z&obs)==key)
    @lru_cache(None)
    def optimal(obs,key):
        fiber=groups[(obs,key)]
        if len({truth[z] for z in fiber})<=1:return 0
        return 1 + min(max(optimal(obs|(1<<i),key|(b<<i)) for b in (0,1))
                 for i in range(n) if not (obs>>i)&1)
    D=optimal(0,0)
    w=0
    for (obs,key),fiber in groups.items():
        if len({truth[z] for z in fiber})<=1:continue
        found=None
        for bsz in range(1,n+1):
            for ix in combinations((i for i in range(n) if not obs>>i&1),bsz):
                B=sum(1<<i for i in ix)
                if all(any(truth[z]!=truth[x] and ((x^z)&~B)==0 for z in fiber)
                       for x in fiber):
                    found=bsz;break
            if found is not None:break
        assert found is not None
        w=max(w,found)
    ranks=[]
    for x in X:
        sens=tuple(B for B in range(1,1<<n)
                   if any(truth[y]!=truth[x] and ((x^y)&~B)==0 for y in X))
        @lru_cache(None)
        def rank(used):
            return max((1+rank(used|B) for B in sens if B&used==0),default=0)
        ranks.append(rank(0))
    r=max(ranks)
    assert D<=w*r,(n,truth,D,w,r)
    return D,w,r

stats=defaultdict(int);tight=[]
for n in (1,2,3):
    for bits in range(1<<(1<<n)):
        truth=tuple((bits>>z)&1 for z in range(1<<n))
        D,w,r=sample(n,truth)
        stats[(n,D,w,r)]+=1
        if D==w*r and D>1:tight.append((n,bits,D,w,r))

examples={}
for n in (4,5):
    functions={"parity":tuple(z.bit_count()%2 for z in range(1<<n)),
               "or":tuple(int(z!=0) for z in range(1<<n)),
               "address":tuple((z>>1>>(z&1))&1 for z in range(1<<n))}
    examples[n]={name:dict(zip(("D","w","r"),sample(n,truth)))
                 for name,truth in functions.items()}

out={"status":"PASS",
     "exhaustive":{str(n):sum(v for (nn,*_),v in stats.items() if nn==n) for n in (1,2,3)},
     "examples":examples,"tight_examples":len(tight),
     "max_D":max(key[1] for key in stats)}
assert out["exhaustive"]=={"1":4,"2":16,"3":256}
assert out["examples"][4]["parity"]=={"D":4,"w":1,"r":4}
assert out["examples"][4]["or"]=={"D":4,"w":4,"r":4}
assert out["examples"][4]["address"]=={"D":2,"w":2,"r":2}
print(json.dumps(out,indent=2))
