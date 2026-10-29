#!/usr/bin/env python3
"""Independent exact finite test of NIGHTFALL Sidon one-vs-two insertion arity.

No project code imports, external dependencies, or floating-point calculations.
Scope: cyclic difference-set example in Z/91Z, not a general theorem prover.
"""
from collections import Counter
from itertools import combinations, combinations_with_replacement
from hashlib import sha256
import json

V = 91
D = tuple(sorted((0, 1, 3, 9, 27, 49, 56, 61, 77, 81)))
assert len(D) == 10
external = tuple(x for x in range(V) if x not in D)

# Independent classical perfect-difference validation.
differences = [(x - y) % V for x in D for y in D if x != y]
assert sorted(differences) == list(range(1, V))

# Method 1: literal unordered pair sums, every old third point.
by_new = {}
for a in external:
    H = set()
    for i, x in enumerate(D):
        for y in D[i:]:
            for z in D:
                if (x+y-z) % V == a:
                    assert z != x and z != y
                    H.add(frozenset((x,y,z)))
    by_new[a] = H

# Method 2: reconstruct via unique ordered differences, avoiding sum enumeration.
dmap = {(y-z) % V: (y,z) for y in D for z in D if y != z}
assert len(dmap) == V-1
for a in external:
    witness = set()
    for x in D:
        if (a-x) % V in dmap:
            y,z = dmap[(a-x) % V]
            witness.add(frozenset((x,y,z)))
    assert witness == by_new[a], (a, witness ^ by_new[a])

# Individual single-insertion ordinary collision degree is always <= 2.
for a,H in by_new.items():
    degrees=Counter(t for S in H for t in S)
    assert max(degrees.values(), default=0) <= 2, a

# Independent ordinary-support minimum cover using exact subset enumeration.
def min_cover(supports, forced=frozenset()):
    needed = [s for s in supports if not (s & forced)]
    pool = [t for t in D if t not in forced]
    best = len(D)+1
    for mask in range(1 << len(pool)):
        if mask.bit_count() >= best-len(forced):
            continue
        chosen=set(forced)|{pool[j] for j in range(len(pool)) if mask>>j & 1}
        if all(s & chosen for s in needed):
            best=len(chosen)
    return best

def is_sidon(X):
    sums = [(x+y)%V for x,y in combinations_with_replacement(X,2)]
    return len(set(sums)) == len(sums)

# True single-insertion optimum, including 2a=x+y collisions.
def direct_optimum(a):
    for n in range(len(D)+1):
        for removed in combinations(D,n):
            X=tuple(x for x in D if x not in removed)+(a,)
            if is_sidon(X):
                return n
    raise AssertionError('no valid repair')

def cover_optimum(a):
    H=by_new[a]
    diag = [(x,y) for x,y in combinations_with_replacement(D,2) if (x+y)%V == (2*a)%V]
    assert len(diag) <= 1
    if not diag: return min_cover(H)
    x,y=diag[0]
    return min(min_cover(H, frozenset((t,))) for t in set((x,y)))

one_hist=Counter()
for a in external:
    opt1=direct_optimum(a)
    opt2=cover_optimum(a)
    assert opt1==opt2, (a,opt1,opt2)
    one_hist[opt1]+=1

# For all 3240 distinct unordered external pairs, compute high-degree core.
core_hist=Counter(); min_core=999; min_pair=None; max_core=0
for a,b in combinations(external,2):
    H=by_new[a]|by_new[b]
    degrees=Counter(t for S in H for t in S)
    c=sum(d>=3 for d in degrees.values())
    assert max(degrees.values(), default=0)<=4
    assert c >= (len(D)-5+1)//2 # ceil((q-5)/2)=3
    core_hist[c]+=1
    if c < min_core: min_core, min_pair = c, (a,b)
    max_core=max(max_core,c)

special=(4,67)
Hs=by_new[special[0]]|by_new[special[1]]
special_degrees=Counter(t for S in Hs for t in S)
special_core=sorted(t for t,d in special_degrees.items() if d>=3)
assert special_core == [0,3,9,27,61]
assert min_core == 5

report={
 'source':{'v':V,'q':len(D),'D':D,'ordered_nonzero_differences':len(differences)},
 'outside_points':len(external),
 'single_insertion':{'all_optimal_costs_verified':len(external),'ordinary_support_degree_upper_bound':2,'optimal_cost_histogram':dict(sorted(one_hist.items()))},
 'two_insertions':{'all_pairs_checked':sum(core_hist.values()),'proven_general_core_lower_bound':3,'exact_this_source_min_core':min_core,'max_core':max_core,'core_histogram':dict(sorted(core_hist.items())),'first_min_pair':min_pair},
 'named_pair':{'new_marks':special,'core':special_core,'high_incidence_size':len(special_core)},
 'independent_methods':'literal sum triples / ordered difference dictionary / brute full sum / support hitting set',
 'scope':'finite source only; abstract extension/proof review external',
}
raw=json.dumps(report,sort_keys=True,separators=(',',':'))
print(json.dumps(report,indent=2))
print('RECEIPT_SHA256',sha256(raw.encode()).hexdigest())
