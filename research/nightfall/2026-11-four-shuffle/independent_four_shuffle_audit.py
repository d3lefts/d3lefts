#!/usr/bin/env python3
"""Independent finite four-shuffle N4=20 certificate.
Perfect-matching recursion on inversion/noninversion graphs, finite partial
comparison forcing, and exact-cover test; no imports from source verifier.
"""
from itertools import permutations, combinations
from collections import deque, defaultdict
from functools import lru_cache
W=(1,17,2,4,16,15,14,8,9,10,11,12,7,6,5,13,18,3,19)

def std(v):
    s=sorted(v)
    return tuple(s.index(x) for x in v)

@lru_cache(None)
def match_mask(adj, remaining):
    if not remaining:return True
    low=remaining&-remaining;i=low.bit_length()-1
    cand=remaining & adj[i]
    while cand:
        b=cand&-cand
        if match_mask(adj,remaining^low^b):return True
        cand-=b
    return False

def same_pair_shuf(v):
    n=len(v)
    if n%2:return False
    for invert in (True,False):
        adj=[]
        for i in range(n):
            mask=0
            for j in range(n):
                if i!=j and ((i-j)*(v[i]-v[j])>0)==(not invert):
                    mask |= 1<<j
            adj.append(mask)
        if match_mask(tuple(adj),(1<<n)-1):return True
    return False

def exact_cover(mask_choices,remaining):
    if not remaining:return True
    e=remaining&-remaining
    for mask in mask_choices:
        if (mask & e) and (mask & remaining)==mask and exact_cover(mask_choices,remaining^mask):
            return True
    return False

def shuffle_general(seq):
    sz=len(seq)
    assert sz%4==0
    d=sz//4
    pool=defaultdict(list)
    for inds in combinations(range(sz),d):
        pool[std([seq[i] for i in inds])].append(sum(1<<i for i in inds))
    return any(exact_cover(masks,(1<<sz)-1) for masks in pool.values())

def build_graph():
    vtx=list(permutations(range(7)))
    index={p:i for i,p in enumerate(vtx)}
    graph=[[] for _ in vtx]
    indeg=[0]*len(vtx)
    for i,v in enumerate(vtx):
        for j in range(8):
            eight=tuple(x+(x>=j) for x in v)+(j,)
            if same_pair_shuf(eight):continue
            k=index[std(eight[1:])]
            graph[i].append((k,j))
            indeg[k]+=1
    assert sum(map(len,graph))==2632
    todo=deque(i for i in range(len(vtx)) if indeg[i]==0)
    order=[]
    while todo:
        i=todo.popleft();order.append(i)
        for k,_ in graph[i]:
            indeg[k]-=1
            if not indeg[k]:todo.append(k)
    assert len(order)==5040
    tail=[0]*5040
    for i in reversed(order):
        if graph[i]:tail[i]=1+max(tail[k] for k,j in graph[i])
    assert max(tail)==18
    return vtx,graph,tail

def paths(vtx,graph,tail):
    def extend(i,p,rs):
        if len(rs)==13:
            yield (p,rs)
        else:
            for k,r in graph[i]:
                if tail[k] >= 12-len(rs):
                    yield from extend(k,p,rs+(r,))
    for i,p in enumerate(vtx):
        if tail[i]>=13:
            yield from extend(i,p,())

def forced_triples(start,ranks):
    cmp={}
    state=start
    for off,r in enumerate(ranks):
        eighth=tuple(x+(x>=r) for x in state)+(r,)
        for i in range(8):
            for j in range(i+1,8):
                key=(off+i,off+j)
                value=eighth[i]<eighth[j]
                if key in cmp:assert cmp[key]==value
                cmp[key]=value
        state=std(eighth[1:])
    for off in range(9):
        bypat=defaultdict(list)
        for inds in combinations(range(12),3):
            orig=[off+v for v in inds]
            if any((orig[a],orig[b]) not in cmp for a,b in [(0,1),(0,2),(1,2)]):continue
            rks=[]
            for a in range(3):
                rks.append(sum((cmp[orig[b],orig[a]] if b<a else not cmp[orig[a],orig[b]]) for b in range(3) if b!=a))
            bypat[tuple(rks)].append(sum(1<<x for x in inds))
        for masks in bypat.values():
            if exact_cover(masks,4095):return True
    return False

def main():
    vs,g,tail=build_graph()
    count=0
    for start,rs in paths(vs,g,tail):
        assert forced_triples(start,rs), (start,rs)
        count+=1
    assert count==302,count
    nr=0
    for width in (8,12,16):
        for off in range(20-width):
            assert not shuffle_general(W[off:off+width]),(width,off)
            nr+=1
    assert nr==24
    print({'states':len(vs),'bad_eight_edges':sum(map(len,g)),'longest_edge_walk':max(tail),'length20_walks_checked':count,'witness_length':len(W),'witness_windows':nr,'status':'EXACT PASS'})
if __name__=='__main__':main()
