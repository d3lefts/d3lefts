#!/usr/bin/env python3
"""Exact finite F16 cubic-power oracle replay for Paper C. Stdlib only.

Finite checks and explicit signal decoder, NOT a worldwide novelty determination
or a proof of the unbounded measurable-product analytic claims.
"""
from collections import Counter
from itertools import combinations, product
import hashlib, json

P=0b10011
H=(1,6,7)
FIXED=((14,12,15,3,7),(15,4,9,6,8),(5,5,3,14,6))
FIRST=(1,2,3,4)
BRANCH={0:(0,0,0,1),1:(1,0,2,8),8:(0,1,4,8),
        10:(0,1,2,4),12:(0,1,8,4),15:(0,1,2,4)}

def mul(a,b):
    x=0
    while b:
        if b&1:x^=a
        a<<=1;b>>=1
    for d in range(x.bit_length()-1,3,-1):
        if x>>d&1:x^=P<<(d-4)
    assert 0<=x<16
    return x
def cube(a):return mul(mul(a,a),a)
def query(row,x):
    y=0
    for a,b in zip(row,x):y^=mul(a,b)
    return cube(y)

assert {cube(x) for x in range(16)}=={0,1,8,10,12,15}
assert {x for x in range(16) if cube(x)==1}==set(H)
assert all(cube(mul(h,x))==cube(x) for h in H for x in range(16))
s4=list(product(H,repeat=4))
fixed=[tuple(query(row,(1,)+s) for row in FIXED) for s in s4]
assert len(set(fixed))==81
distance=min(sum(a!=b for a,b in zip(t,u)) for t,u in combinations(fixed,2))
assert distance==1
s3=list(product(H,repeat=3))
table={};fibers=Counter()
for s in s3:
    y=query(FIRST,(1,)+s);assert y in BRANCH
    z=query(BRANCH[y],(1,)+s)
    assert (y,z) not in table
    fibers[y]+=1;table[y,z]=s
assert len(table)==27
assert dict(sorted(fibers.items()))=={0:1,1:5,8:5,10:6,12:5,15:5}
rows=[tuple([0]*i+[1]+list(t)) for i in range(4) for t in product(range(16),repeat=3-i)]
assert len(rows)==4369
pairs=list(combinations(range(27),2));masks=set()
for row in rows:
    ys=[query(row,(1,)+s) for s in s3]
    masks.add(sum((1<<k) for k,(i,j) in enumerate(pairs) if ys[i]==ys[j]))
assert len(masks)==439
mincoll=min((a&b).bit_count() for a in masks for b in masks)
assert mincoll==4
roots={y:min(x for x in range(16) if cube(x)==y) for y in {cube(v) for v in range(16)}}
inv={x:next(y for y in range(1,16) if mul(x,y)==1) for x in range(1,16)}
single={query((1,2),(1,e)):e for e in H};assert len(single)==3

def recover(x):
    k=len(x);ys=[cube(v) for v in x]
    support=[i for i,z in enumerate(ys) if z!=0]
    if not support:return (0,)*k,k
    u=[roots[v] for v in ys];anchor=support[0];found={anchor:1};cost=k
    def observe(group,row):
        y=0
        for i,a in zip((anchor,)+tuple(group),row):
            y^=mul(a,mul(x[i],inv[u[i]]))
        return cube(y)
    others=support[1:]
    for j in range(0,len(others),3):
        block=others[j:j+3]
        if len(block)==3:
            y=observe(block,FIRST)
            z=observe(block,BRANCH[y])
            found.update(zip(block,table[y,z]));cost+=2
        else:
            for i in block:found[i]=single[observe((i,),(1,2))];cost+=1
    est=tuple(mul(found[i],u[i]) if i in found else 0 for i in range(k))
    assert any(all(mul(h,est[i])==x[i] for i in range(k)) for h in H)
    return est,cost

dist=Counter()
for x in product(range(16),repeat=4):
    _,m=recover(x);dist[m]+=1
assert dict(sorted(dist.items()))=={4:61,5:1350,6:64125}
sectors=0
for size in range(1,8):
    for active in combinations(range(7),size):
        for phases in product(H,repeat=size-1):
            x=[0]*7
            for i,v in zip(active,(1,)+phases):x[i]=v
            assert recover(tuple(x))[1]<=11
            sectors+=1
assert sectors==5461
for k,m in ((4,6),(5,8),(7,11)):
    count=1+(16**k-1)//3
    assert 6**(m-1)<count<=6**m
receipt={
 "status":"PASS",
 "model":"F16 cubic-power oracle; global F4* equivalence",
 "fixed_81_distinct":81,
 "fixed_block_min_output_Hamming_distance":distance,
 "adaptive_27_distinct":27,
 "first_fibers":{str(k):v for k,v in sorted(fibers.items())},
 "canonical_fixed_rows":4369,
 "distinct_collision_masks":439,
 "minimal_fixed_pair_collision_pairs":mincoll,
 "exhaustive_k4_signals":sum(dist.values()),
 "k4_query_distribution":{str(k):v for k,v in sorted(dist.items())},
 "k7_support_phase_classes":sectors,
 "sharp_worst_case_queries":{"4":6,"5":8,"7":11},
 "limitations":"Finite exact arithmetic and decoder replay; no peer-review or global novelty clearance",
}
# Canonicalize numeric dictionary keys before hashing. Otherwise JSON reload
# turns them into strings, changing sorted-key serialization and the digest.
receipt["certificate_sha256"]=hashlib.sha256(json.dumps(receipt,sort_keys=True,separators=(',',':')).encode()).hexdigest()
with open("replay_f16_receipt.json","w") as f:
    json.dump(receipt,f,indent=2,sort_keys=True)
    f.write("\\n")
with open("replay_f16_receipt.json",encoding="utf-8") as f:
    saved=json.load(f)
saved_hash=saved.pop("certificate_sha256")
assert saved_hash==hashlib.sha256(json.dumps(saved,sort_keys=True,separators=(',',':')).encode()).hexdigest(), "Unverifiable serialized receipt"
print(json.dumps(receipt,indent=2))
