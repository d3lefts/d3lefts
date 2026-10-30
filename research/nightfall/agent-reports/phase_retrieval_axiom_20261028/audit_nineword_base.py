#!/usr/bin/env python3
"""Independent Axiom nine-word four-qutrit Werner endpoint checker.
Exact integer coefficient equality and rank-three falsification control.
No source constructor import or numerical tolerance.
"""
from itertools import product
from collections import Counter
import json

CODE=tuple((x,y,(x+y)%3,(x+2*y)%3) for x,y in product(range(3),repeat=2))
assert len(set(CODE))==9
assert all(sum(x!=y for x,y in zip(a,b))==3 for a in CODE for b in CODE if a!=b)

def model(d):
    words=tuple(product(range(d),repeat=4))
    groups=[]
    center=tuple((a,a) for a in CODE)
    groups.append(("center",2,frozenset(CODE),frozenset(CODE),center))
    for site,v in product(range(4),range(3)):
        rows=[a for a in CODE if a[site]==v]
        assert len(rows)==3
        for z in range(d):
            if z==v:continue
            pairs=[]
            for a in rows:
                b=list(a);b[site]=z
                pairs.append((a,tuple(b)))
            groups.append((f"{site},{v},{z}",4,frozenset(rows),
                           frozenset(b for _,b in pairs),tuple(pairs)))
    assert len(groups)==1+12*(d-1)
    entries=tuple((a,b) for a in CODE for b in words)
    rectangles={}
    paired={}
    for name,w,R,B,pairs in groups:
        for a in R:
            for b in B:
                rectangles.setdefault((a,b),[]).append(w)
        for a,b in pairs:
            assert (a,b) not in paired
            paired[a,b]=(name,w)
    residual={}
    for a,b in entries:
        h=sum(x!=y for x,y in zip(a,b))
        wg=sum(rectangles.get((a,b),()))
        pw=paired[a,b][1]//2 if (a,b) in paired else 0
        residual[a,b]=2**h-wg+pw
        assert residual[a,b]>=0
    return entries,residual,paired,groups

def K(a,b,c,d):
    t=1
    for j in range(4):
        t*=2*int(a[j]==c[j] and b[j]==d[j])-int(a[j]==b[j] and c[j]==d[j])
    return t

entries,residual,paired,groups=model(3)
assert len(entries)==729
hist=Counter(residual.values())
assert hist==Counter({0:81,4:216,6:72,8:216,12:144}),hist
for i,(a,b) in enumerate(entries):
    for j,(c,d) in enumerate(entries):
        target=K(a,b,c,d)
        if i==j:
            predicted=residual[a,b]
            predicted+=sum(w for _,w,R,B,_ in groups if a in R and b in B)
            if (a,b) in paired:predicted-=paired[a,b][1]//2
        else:
            ga=paired.get((a,b));gb=paired.get((c,d))
            predicted=-(ga[1]//2) if ga and gb and ga[0]==gb[0] else 0
        assert target==predicted,(i,j,target,predicted)
three=CODE[:3]
rank3_16Q=sum(K(a,a,b,b) for a in three for b in three)
assert rank3_16Q==-3
assert K(three[0],three[0],three[1],three[1])==-1
entries4,residual4,paired4,groups4=model(4)
assert len(entries4)==2304 and len(groups4)==37
assert min(residual4.values())>=0
print(json.dumps({
    "status":"PASS",
    "d3_ordered_kernel_coefficients":len(entries)**2,
    "d3_group_count":len(groups),
    "d3_residual_histogram":dict(hist),
    "d4_diagonal_entries_checked":len(entries4),
    "d4_residual_histogram":dict(Counter(residual4.values())),
    "rank_three_negative_control_16Q":rank3_16Q,
    "proof_scope":"finite exact coefficient reconstruction; arbitrary-d proof uses ternary code distance 3 and rank-2 trace inequality",
    "open_gates":["independent expert proof check","novelty priority"]
},sort_keys=True,indent=2))
