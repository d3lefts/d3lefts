#!/usr/bin/env python3
"""Exact standalone finite proof of consecutive 4-shuffle threshold N4=20.
Python 3.10+, standard library only. Not an external referee or priority audit.
"""
from collections import defaultdict,deque
from functools import lru_cache
from itertools import combinations,permutations
WITNESS=(1,17,2,4,16,15,14,8,9,10,11,12,7,6,5,13,18,3,19)
def pat(seq):
    d={x:i for i,x in enumerate(sorted(seq))}
    return tuple(d[x] for x in seq)
@lru_cache(None)
def pairings(mask):
    if not mask:return ((),)
    bit=mask&-mask;i=bit.bit_length()-1
    return tuple(((i,j),)+rest for j in range(i+1,mask.bit_length())
                 if mask>>j&1 for rest in pairings(mask^bit^(1<<j)))
PAIRS=pairings(255)
assert len(PAIRS)==105
def is_sh8(p):
    return any(all((p[a]<p[b])==(p[t[0][0]]<p[t[0][1]]) for a,b in t) for t in PAIRS)
def build():
    verts=list(permutations(range(7)))
    ids={v:i for i,v in enumerate(verts)}
    graph=[[]for _ in verts];indeg=[0]*len(verts)
    for i,v in enumerate(verts):
        for k in range(8):
            w=tuple(a+(a>=k) for a in v)+(k,)
            if is_sh8(w):continue
            j=ids[pat(w[1:])]
            graph[i].append((j,k));indeg[j]+=1
    assert len(verts)==5040 and sum(map(len,graph))==2632
    queue=deque(i for i,d in enumerate(indeg) if d==0);order=[]
    while queue:
        i=queue.popleft();order.append(i)
        for j,_ in graph[i]:
            indeg[j]-=1
            if indeg[j]==0:queue.append(j)
    assert len(order)==len(verts),"Cycle in avoidance graph"
    tail=[0]*len(verts)
    for i in reversed(order):
        tail[i]=max([0]+[1+tail[j] for j,_ in graph[i]])
    assert max(tail)==18
    return verts,graph,tail
def walks(verts,graph,tail):
    def rec(i,start,ranks):
        if len(ranks)==13:
            yield start,ranks;return
        for j,k in graph[i]:
            if tail[j]+len(ranks)+1>=13:
                yield from rec(j,start,ranks+(k,))
    for i,v in enumerate(verts):
        if tail[i]>=13:yield from rec(i,v,())
def forced12(start,ranks):
    # Known local comparisons only; distant comparisons remain UNKNOWN.
    signs=[[0]*20 for _ in range(20)];state=start
    for off,k in enumerate(ranks):
        win=tuple(a+(a>=k) for a in state)+(k,)
        for i in range(8):
            for j in range(i+1,8):
                a,b=off+i,off+j;sgn=1 if win[i]<win[j] else -1
                assert signs[a][b] in (0,sgn)
                signs[a][b]=sgn;signs[b][a]=-sgn
        state=pat(win[1:])
    for off in range(9):
        choices=defaultdict(list)
        for triple in combinations(range(12),3):
            pos=[off+i for i in triple]
            if any(signs[a][b]==0 for a,b in combinations(pos,2)):continue
            key=tuple(sum(signs[pos[i]][pos[j]]<0 for j in range(3) if i!=j) for i in range(3))
            choices[key].append(sum(1<<i for i in triple))
        for triples in choices.values():
            bybit=[[]for _ in range(12)]
            for mask in triples:
                for i in range(12):
                    if mask>>i&1:bybit[i].append(mask)
            @lru_cache(None)
            def cover(rest):
                if not rest:return True
                i=(rest&-rest).bit_length()-1
                return any(mask&rest==mask and cover(rest^mask) for mask in bybit[i])
            if cover(4095):return True
    return False
def shuffle(seq):
    n=len(seq);k=n//4
    groups=defaultdict(list)
    for inds in combinations(range(n),k):
        key=pat(tuple(seq[i] for i in inds))
        groups[key].append(sum(1<<i for i in inds))
    for masks in groups.values():
        if len(masks)<4:continue
        bybit=[[]for _ in range(n)]
        for mask in masks:
            for i in range(n):
                if mask>>i&1:bybit[i].append(mask)
        @lru_cache(None)
        def cover(rest):
            if not rest:return True
            i=(rest&-rest).bit_length()-1
            return any(mask&rest==mask and cover(rest^mask) for mask in bybit[i])
        if cover((1<<n)-1):return True
    return False
def main():
    verts,graph,tail=build();count=0
    for start,ranks in walks(verts,graph,tail):
        assert forced12(start,ranks),(start,ranks)
        count+=1
    assert count==302
    assert len(WITNESS)==19 and sorted(WITNESS)==list(range(1,20))
    tested=0
    for n in (8,12,16):
        for i in range(20-n):
            assert not shuffle(WITNESS[i:i+n]),(i,n)
            tested+=1
    assert tested==24
    print("PASS 5040 states; 2632 bad-eight edges; 302/302 length-20 paths force a length-12 shuffle")
    print("PASS 19-entry witness avoids 24/24 eligible factors (8,12,16)")
    print("Exact finite N4=20; external peer review and novelty remain open")
if __name__=="__main__":main()
