#!/usr/bin/env python3
"""RYEV #140: exact integer cross-checks, with finite counterexamples.
The universal Q7 conclusion follows from THEOREM.md, not a Q7 exhaustive search."""
from collections import Counter
from itertools import combinations
from hashlib import sha256
import json

def make_cube(n):
    E=[(v,v^(1<<i)) for i in range(n) for v in range(1<<n) if v&(1<<i)==0]
    lookup={frozenset(e):i for i,e in enumerate(E)}
    faces=[]
    for i,j in combinations(range(n),2):
        for v in range(1<<n):
            if v&((1<<i)|(1<<j)):continue
            q=(v,v^(1<<i),v^(1<<j),v^(1<<i)^(1<<j))
            faces.append(tuple(lookup[frozenset((q[a],q[b]))]
                      for a,b in ((0,1),(0,2),(1,3),(2,3))))
    stars=[0]*len(E)
    for k,s in enumerate(faces):
        for e in s:stars[e]^=1<<k
    return E,faces,stars

def check_q4():
    E,F,S=make_cube(4)
    assert (len(E),len(F))==(32,24)
    pivots={}
    for x in S:
        while x:
            p=x.bit_length()-1
            if p not in pivots:
                pivots[p]=x;break
            x^=pivots[p]
    assert len(pivots)==17
    syndromes={0}
    for x in pivots.values():
        syndromes|={a^x for a in tuple(syndromes)}
    assert len(syndromes)==131072
    count=Counter(x.bit_count() for x in syndromes)
    assert count[1]==count[2]==0 and count[3]==32 and count[4]==102
    pair_w4={S[a]^S[b] for a,b in combinations(range(32),2)
             if (S[a]^S[b]).bit_count()==4}
    other={x for x in syndromes if x.bit_count()==4}-pair_w4
    assert len(pair_w4)==96 and len(other)==6
    s=S[0]^S[1]^S[2]^S[3]
    assert s in other and s.bit_count()==4
    cuts=Counter()
    # Fix one vertex's membership, enumerating all cuts modulo complement.
    for U in range(1<<15):
        cuts[sum(((U>>a)^(U>>b))&1 for a,b in E)]+=1
    assert cuts[0]==1 and cuts[4]==16 and cuts[6]==32
    assert not any(cuts[k] for k in (1,2,3,5))
    return dict(rank=17,syndromes=131072,weight3=32,weight4=102,
                two_edge_weight4=96,exceptional_weight4=6,
                q4_singleton_cuts=16,q4_adjacent_pair_cuts=32,
                exceptional_edge_witness=[E[i] for i in (0,1,2,3)])

def independent_faces(n):
    # A separate vertex/four-set enumerator, never using make_cube face logic.
    vertices=range(1<<n)
    edge_set={tuple(sorted((v,v^(1<<i)))) for v in vertices for i in range(n)}
    faces=set()
    for v in vertices:
        for i,j in combinations(range(n),2):
            p=frozenset((v,v^(1<<i),v^(1<<j),v^(1<<i)^(1<<j)))
            faces.add(p)
    return edge_set,{frozenset(tuple(sorted((a,b))) for a,b in combinations(q,2)
                       if (a^b).bit_count()==1) for q in faces}

def check_q7():
    E,F,S=make_cube(7)
    E2,F2=independent_faces(7)
    assert (len(E),len(F))==(448,672)
    assert set(E)==E2 and {frozenset(E[e] for e in q) for q in F}==F2
    assert all(s.bit_count()==6 for s in S)
    cofacial=set();syndromes=set();adjacent=opposite=0
    for sq in F:
        for e,f in combinations(sq,2):
            pair=tuple(sorted((e,f)))
            assert pair not in cofacial
            cofacial.add(pair)
            v=S[e]^S[f]
            assert v.bit_count()==10 and v not in syndromes
            syndromes.add(v)
            if set(E[e]).intersection(E[f]):adjacent+=1
            else:opposite+=1
    assert (len(cofacial),len(syndromes),adjacent,opposite)==(4032,4032,2688,1344)
    w10=w12=0
    for e,f in combinations(range(448),2):
        w=(S[e]^S[f]).bit_count()
        assert w in (10,12)
        assert (w==10)==((e,f) in cofacial)
        if w==10:w10+=1
        else:w12+=1
    assert (w10,w12)==(4032,96096)
    for v in range(128):
        incident=[e for e,(a,b) in enumerate(E) if a==v or b==v]
        assert len(incident)==7
        parity=0
        for e in incident:parity^=S[e]
        assert parity==0
    return dict(vertices=128,edges=448,squares=672,cofacial_pair_syndromes=4032,
                adjacent_pairs=adjacent,opposite_pairs=opposite,
                all_edge_pairs=100128,noncofacial_negative=96096,
                vertex_switches=128)

def check_small_odd():
    # Full Q3 enumeration: verifies saturation and cofacial-safe exclusion.
    E,F,S=make_cube(3)
    odd=[h for h in range(1<<len(E))
         if all(sum((h>>e)&1 for e in sq)%2==1 for sq in F)]
    assert len(odd)==128
    M=max(h.bit_count() for h in odd)
    assert M==9
    face_pairs={frozenset((a,b)) for sq in F for a,b in combinations(sq,2)}
    maxima=near=0
    for h in odd:
        safe=[e for e in range(len(E)) if not (h>>e)&1 and
              all(sum((h>>j)&1 for j in sq)!=3 for sq in F if e in sq)]
        if h.bit_count()==M:
            assert safe==[]
            maxima+=1
        if h.bit_count()==M-1:
            assert all(frozenset((a,b)) not in face_pairs
                       for a,b in combinations(safe,2))
            near+=1
    assert (maxima,near)==(8,24)
    return dict(odd_graphs=128,M3=9,maxima=8,nearmax=24)

if __name__=="__main__":
    result=dict(q4=check_q4(),q7=check_q7(),q3_negative=check_small_odd(),
                claim="Internal finite consistency only; no Q7 305 witness/UNSAT",
                exact_only=True)
    print(json.dumps(result,sort_keys=True,indent=2))
    print("PASS: exact second-shell controls; independent mathematical review OPEN.")
