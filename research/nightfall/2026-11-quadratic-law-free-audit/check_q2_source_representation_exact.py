#!/usr/bin/env python3
"""Independent exact-rational falsification of the Swansea Q2 source representation.

Finite exhaustive input replay, NOT an infinite-product Lean certificate.
No numeric floating-point tolerances.
"""
from fractions import Fraction as F
from functools import lru_cache
from itertools import combinations, product
from random import Random
import json

rng=Random(20261112)
checks=0
models=0
sizes=[]

for n, alphabet, trials in [(2,2,5), (2,3,5), (3,2,5), (3,3,3), (4,2,4), (4,3,2)]:
    points=list(product(range(alphabet),repeat=n))
    subsets=[tuple(i for i in range(n) if mask&(1<<i)) for mask in range(1<<n)]
    for trial in range(trials):
        # Zero atoms are included deliberately, without conditioning or division.
        raw=[[rng.randrange(0,5) for _ in range(alphabet)] for _ in range(n)]
        for row in raw:
            if sum(row)==0: row[0]=1
        laws=tuple(tuple(F(a,sum(row)) for a in row) for row in raw)
        offset=F(rng.randrange(-2,3),3)
        single={(i,a):F(rng.randrange(-4,5),5) for i in range(n) for a in range(alphabet)}
        pairs={(i,j,a,b):F(rng.randrange(-5,6),7)
               for i in range(n) for j in range(i+1,n)
               for a in range(alphabet) for b in range(alphabet)}
        def f(x):
            return offset+sum((single[i,x[i]] for i in range(n)),F(0))+sum((pairs[i,j,x[i],x[j]] for i in range(n) for j in range(i+1,n)),F(0))
        masses={x:__import__('math').prod((laws[i][x[i]] for i in range(n))) for x in points}
        @lru_cache(maxsize=None)
        def condexp(U,x):
            return sum((masses[y]*f(tuple(x[i] if i in U else y[i] for i in range(n))) for y in points),F(0))
        @lru_cache(maxsize=None)
        def escomp(S,x):
            return sum(((-1)**(len(S)-len(U))*condexp(U,x)
                        for l in range(len(S)+1) for U in combinations(S,l)),F(0))
        selected={S:next(((i,j) for i in range(n) for j in range(i+1,n) if set(S)<={i,j}), (0,1)) for S in subsets}
        base=(0,)*n
        for x in points:
            lhs=f(x)
            rhs=F(0)
            for S in subsets:
                i,j=selected[S]
                if len(S)<=2:
                    y=list(base);y[i]=x[i];y[j]=x[j]
                    rhs+=escomp(S,tuple(y))
                    checks+=1
                else:
                    assert escomp(S,x)==0, (n,alphabet,trial,S,x,'high-degree')
                    checks+=1
            assert lhs==rhs,(n,alphabet,trial,x,lhs,rhs)
            checks+=1
        sizes.append((n,alphabet,trial))
        models+=1

print(json.dumps({'status':'EXACT_FINITE_REPLAY_PASSED','models':models,
                  'assertions':checks,'dimension_alphabet_trials':sizes,
                  'checker':'Python 3 fractions.Fraction (no tolerance)',
                  'scope':'all finite input points in constructed random quadratic models; not a universal proof'},indent=2))
