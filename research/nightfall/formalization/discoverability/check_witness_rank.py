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
    # Constructive nonanticipating greedy algorithm: from the observation fiber
    # choose the first minimum-width block common to ALL consistent states.
    @lru_cache(None)
    def greedy(obs,key):
        fiber=groups[(obs,key)]
        if len({truth[z] for z in fiber})<=1:
            return 0
        for bsz in range(1,n+1):
            for ix in combinations((i for i in range(n) if not (obs>>i)&1),bsz):
                B=sum(1<<i for i in ix)
                if all(any(truth[z]!=truth[x] and ((x^z)&~B)==0
                           for z in fiber) for x in fiber):
                    outcomes={z&B for z in fiber}
                    return bsz + max(greedy(obs|B,key|outcome)
                                     for outcome in outcomes)
        assert False, "unresolved fiber must admit a witness"
    G=greedy(0,0)
    assert D<=G<=w*r,(n,truth,D,G,w,r)
    return D,w,r,G

stats=defaultdict(int);tight=[];greedy_tight=[]
for n in (1,2,3):
    for bits in range(1<<(1<<n)):
        truth=tuple((bits>>z)&1 for z in range(1<<n))
        D,w,r,G=sample(n,truth)
        stats[(n,D,w,r)]+=1
        if G==w*r and G>1:greedy_tight.append((n,bits,G,w,r))
        if D==w*r and D>1:tight.append((n,bits,D,w,r))

examples={}
for n in (4,5):
    functions={"parity":tuple(z.bit_count()%2 for z in range(1<<n)),
               "or":tuple(int(z!=0) for z in range(1<<n)),
               "address":tuple((z>>1>>(z&1))&1 for z in range(1<<n))}
    examples[n]={name:dict(zip(("D","w","r","greedy"),sample(n,truth)))
                 for name,truth in functions.items()}

# Constrained counterexample calculated independently of the Boolean-cube sample:
# admissible states differ on both sensors, yet either one distinguishes outputs.
constrained_states=((1,0),(0,1))
constrained_labels=(0,1)
def constrained_sensitive(B,x):
    return any(constrained_labels[y]!=constrained_labels[x] and
               all(constrained_states[y][i]==constrained_states[x][i]
                   for i in range(2) if not (B>>i)&1)
               for y in range(2))
constrained_width=min(B.bit_count() for B in range(1,4) if
                      all(constrained_sensitive(B,x) for x in range(2)))
constrained_rank=max(1 if any(constrained_sensitive(B,x)
                for B in range(1,4)) else 0 for x in range(2))
constrained_D=min(1 for i in range(2) if
                  constrained_states[0][i]!=constrained_states[1][i])
assert (constrained_width,constrained_rank,constrained_D)==(2,1,1)

out={"status":"PASS",
     "exhaustive":{str(n):sum(v for (nn,*_),v in stats.items() if nn==n) for n in (1,2,3)},
     "examples":examples,"tight_examples":len(tight),
     "max_D":max(key[1] for key in stats),
     "greedy_saturations":len(greedy_tight),
     "constrained_negative_control":{"states":["10","01"],
       "labels":[0,1], "w":constrained_width, "r":constrained_rank, "optimal_D":constrained_D}}
assert out["exhaustive"]=={"1":4,"2":16,"3":256}
assert out["examples"][4]["parity"]=={"D":4,"w":1,"r":4,"greedy":4}
assert out["examples"][4]["or"]=={"D":4,"w":4,"r":4,"greedy":4}
assert out["examples"][4]["address"]=={"D":2,"w":2,"r":2,"greedy":2}
print(json.dumps(out,indent=2))
