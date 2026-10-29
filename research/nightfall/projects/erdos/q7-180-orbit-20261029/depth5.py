#!/usr/bin/env python3
"""NIGHTFALL Q7 five-deletion exact exclusion against 180 published 304-edge seeds.
No floating point, randomization or solver status in the mathematical certificate.
The historical 180-representative dataset is NOT a classification of all 304-edge Q7 graphs.
"""
from __future__ import annotations
from collections import Counter
from itertools import combinations
from pathlib import Path
import hashlib
import json
import time

BASE=Path(__file__).resolve().parent
MASKS=BASE/"canonical_180.txt"

def cube():
    # Independent canonical construction: x increases first, then direction.
    edges=[(v,v | (1<<d)) for v in range(128) for d in range(7) if not v & (1<<d)]
    idx={e:i for i,e in enumerate(edges)}
    squares=[]
    for v in range(128):
        for a in range(7):
            if v & (1<<a): continue
            for b in range(a+1,7):
                if v & (1<<b): continue
                u=v | (1<<a); w=v | (1<<b); z=u | (1<<b)
                squares.append(tuple(sorted((idx[v,u],idx[v,w],idx[u,z],idx[w,z]))))
    assert len(edges)==448 and len(set(edges))==448
    assert len(squares)==672 and len(set(squares))==672
    incidence=[[] for _ in edges]
    for sq in squares:
        for e in sq: incidence[e].append(sq)
    assert all(len(x)==6 for x in incidence)
    return edges,squares,incidence

def decode(text,old_index):
    assert len(text)==112
    raw=bytes.fromhex(text)
    bits=[bool(raw[k//8] & (128>>(k%8))) for k in range(448)]
    assert sum(bits)==304
    return {old_index[k] for k,v in enumerate(bits) if v}

def transverse(blocks,limit):
    """Return an exact <=limit-edge transversal, or None if impossible.
    Every failure branch is exhaustive: an uncovered triple must be hit by
    one of its three selected original edges. The disjoint-block bound prunes
    only where a transversal would need >remaining selected edges.
    """
    if any(not b for b in blocks): return None
    B=tuple(sum(1<<e for e in group) for group in blocks)
    seen=set()
    def rec(chosen):
        unhit=[b for b in B if not b&chosen]
        if not unhit:return chosen
        room=limit-chosen.bit_count()
        if room<=0 or chosen in seen:return None
        # Greedy packing of mutually edge-disjoint uncovered blockers.
        packed=0;count=0
        for b in unhit:
            if not b&packed:
                packed|=b;count+=1
                if count>room:
                    seen.add(chosen)
                    return None
        # Most constraining block first (fewest intersecting other blocks).
        pick=min(unhit,key=lambda b:sum(bool(b&h) for h in unhit))
        while pick:
            bit=pick & -pick
            pick-=bit
            found=rec(chosen|bit)
            if found is not None:return found
        seen.add(chosen)
        return None
    return rec(0)

def k_cliques(neighbors,k):
    """All increasing k-cliques from a necessary pair-compatibility graph."""
    def rec(current,candidates,depth):
        if depth==0:
            yield tuple(current)
            return
        while candidates.bit_count()>=depth:
            bit=candidates & -candidates
            candidates^=bit
            v=bit.bit_length()-1
            yield from rec(current+[v],candidates & neighbors[v],depth-1)
    yield from rec([], (1<<len(neighbors))-1,k)

def verify_one(seed,edges,squares,incidence):
    assert len(seed)==304
    edge_set=set(seed)
    assert all(len(edge_set.intersection(sq))<=3 for sq in squares)
    # Independent C4 invariant: two vertices distance two have <=one
    # length-two path in selected subgraph.
    nbr=[set() for _ in range(128)]
    for e in edge_set:
        u,v=edges[e]
        nbr[u].add(v);nbr[v].add(u)
    for v in range(128):
        for w in range(v+1,128):
            if (v^w).bit_count()==2:
                assert len(nbr[v].intersection(nbr[w]))<=1
    missing=[e for e in range(448) if e not in edge_set]
    assert len(missing)==144
    blockers={}
    for e in missing:
        groups=[tuple(x for x in sq if x!=e) for sq in incidence[e]
                if len(edge_set.intersection(sq))==3]
        assert all(len(g)==3 and all(x in edge_set for x in g) for g in groups)
        assert len(set().union(*map(set,groups)))==3*len(groups)
        blockers[e]=groups
    # No edge with >=6 disjoint tight triples can be added after five removals.
    active=[e for e in missing if len(blockers[e])<=5]
    link=[0]*len(active)
    pair_count=0
    for a in range(len(active)):
        for b in range(a+1,len(active)):
            # Exact necessary and sufficient condition for a PAIR of missing
            # edges to be simultaneously individually addable after <=5 drops.
            if transverse(blockers[active[a]]+blockers[active[b]],5) is not None:
                link[a]|=1<<b;link[b]|=1<<a
                pair_count+=1
    clique6=0
    joint6=0
    possible_witness=None
    for cl in k_cliques(link,6):
        clique6+=1
        groups=[g for j in cl for g in blockers[active[j]]]
        drop=transverse(groups,5)
        if drop is None:continue
        joint6+=1
        # A joint transversal is necessary, not sufficient: six newly
        # inserted edges can form fresh C4s. Independently check every 6-subset.
        assert drop.bit_count()<=5
        additions=[active[j] for j in cl]
        trial=(edge_set-set(i for i in range(448) if (drop>>i)&1))|set(additions)
        if len(trial)>=305 and all(len(trial.intersection(sq))<=3 for sq in squares):
            possible_witness={"selected":sorted(trial),"dropped":sorted(i for i in range(448) if (drop>>i)&1),
                              "inserted":additions}
            break
    return {
        "blockerHistogram":dict(sorted(Counter(map(len,blockers.values())).items())),
        "activeAbsent":len(active),"compatiblePairs":pair_count,
        "sixCliques":clique6,"jointSix":joint6,"witness":possible_witness
    }

def run():
    t0=time.monotonic()
    text=MASKS.read_bytes()
    lines=text.decode("ascii").splitlines()
    assert len(lines)==180 and len(set(lines))==180
    expected_sha="2c4a0bfdcbac0d2751a6d2ab3b8b345cd6d4dd2febe437d63cadc2af960168a1"
    assert hashlib.sha256(text).hexdigest()==expected_sha,"Frozen canonical mask bytes changed"
    edges,squares,incidence=cube()
    # The frozen catalogue uses direction-major edges, not the above ordering.
    old_edges=[(v,v|(1<<d)) for d in range(7) for v in range(128) if not v&(1<<d)]
    new_id={e:i for i,e in enumerate(edges)}
    permutation=[new_id[e] for e in old_edges]
    globalstats=Counter()
    records=[]
    for k,mask in enumerate(lines):
        seed=decode(mask,permutation)
        result=verify_one(seed,edges,squares,incidence)
        records.append(result)
        globalstats["compatiblePairs"]+=result["compatiblePairs"]
        globalstats["sixCliques"]+=result["sixCliques"]
        globalstats["jointSix"]+=result["jointSix"]
        if result["witness"] is not None:
            globalstats["possible305"]+=1
            print("POSSIBLE_305",k,json.dumps(result["witness"]),flush=True)
            break
        if (k+1)%20==0:
            print("checked",k+1,"of 180; pair compatibilities",globalstats["compatiblePairs"],flush=True)
    proof={
      "format":"nightfall-q7-five-deletion-pair-compatibility-v1",
      "seedCatalogue":"Minamo Minamoto canonical 180 Q7 304-edge representatives",
      "inputSha256":hashlib.sha256(text).hexdigest(),
      "checked":len(records),"cubeVertices":128,"cubeEdges":448,"cubeSquares":672,
      "pairCompatibilities":globalstats["compatiblePairs"],
      "sixCliques":globalstats["sixCliques"],"jointSix":globalstats["jointSix"],
      "found305":globalstats["possible305"]>0,
      "runtimeSeconds":round(time.monotonic()-t0,3),
      "status":("COMPLETE_5_DELETION_EXCLUSION" if len(records)==180 and globalstats["jointSix"]==0
                 else "FURTHER_ADJACENCY_CHECK_REQUIRED"),
      "scope":"180 published seeds and their cube automorphism images only; not all 304-edge Q7 graphs"
    }
    print(json.dumps(proof,indent=2))
    if len(records)!=180 or globalstats["jointSix"]!=0:raise SystemExit(2)

if __name__=="__main__":
    run()
