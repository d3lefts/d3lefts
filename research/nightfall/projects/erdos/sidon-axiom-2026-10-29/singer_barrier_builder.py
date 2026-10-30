#!/usr/bin/env python3
"""Construction-side arithmetic experiment; no shared verifier routines."""
import json
from collections import Counter
from itertools import combinations

DIFFERENCE_SETS = {
    7: (0, 1, 3),
    13: (0, 1, 3, 9),
    21: (0, 1, 4, 14, 16),
    31: (0, 1, 3, 8, 12, 18),
    57: (0, 1, 3, 13, 32, 36, 43, 52),
    73: (0, 1, 3, 7, 15, 31, 36, 54, 63),
    91: (0, 1, 3, 9, 27, 49, 56, 61, 77, 81),
}

def build():
    out=[]
    for modulus, d in DIFFERENCE_SETS.items():
        k=len(d)
        assert modulus==k*(k-1)+1
        differences=Counter((x-y)%modulus for x in d for y in d if x!=y)
        assert len(differences)==modulus-1 and set(differences.values())=={1}
        deletions=[]
        for a in range(modulus):
            if a in d: continue
            triples=[(x,y,z) for x in d for y in d for z in d if (x+y-z-a)%modulus==0]
            assert len(triples)==k
            min_removed=k
            example=None
            for keep_mask in range(1<<k):
                keep=[x for i,x in enumerate(d) if (keep_mask>>i)&1]
                z=keep+[a]
                sums=[(x+y)%modulus for i,x in enumerate(z) for y in z[i:]]
                if len(sums)==len(set(sums)):
                    removed=k-len(keep)
                    if removed<min_removed:
                        min_removed=removed
                        example=keep
            assert min_removed >= (k+3)//4
            deletions.append({"a":a,"ordered_triples":len(triples),"minimum_deletions":min_removed,"example_survivors":example})
        out.append({"modulus":modulus,"difference_set":list(d),"k":k,
                    "theoretical_deletion_lower_bound":(k+3)//4,
                    "deletions":deletions,
                    "minimum_deletions_across_a":min(z['minimum_deletions'] for z in deletions),
                    "maximum_deletions_across_a":max(z['minimum_deletions'] for z in deletions)})
    return {"schema":"nightfall-singer-deletion-barrier-v1","date":"2026-10-29",
            "scope":"cyclic perfect difference sets only; no solution to Erdős #44/#329",
            "examples":out}

if __name__=='__main__':
    print(json.dumps(build(),indent=2,sort_keys=True))
