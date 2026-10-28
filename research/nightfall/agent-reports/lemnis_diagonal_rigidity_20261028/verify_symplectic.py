#!/usr/bin/env python3
"""Exact finite refutation / classification controls for ternary parity-Hamming kernel."""
from itertools import combinations, product
from collections import Counter

def eps(x,y): return -1 if sum(a!=b for a,b in zip(x,y))%2 else 1

def frustrated(x,y,z): return eps(x,y)*eps(y,z)*eps(x,z)==-1

def good(S): return all(not frustrated(x,y,z) for x,y,z in combinations(S,3))

def box(S,k):
   if len(S)!=2**k: return False
   return all(len({x[i] for x in S})==2 for i in range(k))

def symp(x,y):
    return sum((a==1 and b==2) or (a==2 and b==1) for a,b in zip(x,y))%2

for k in range(1,3):
    words=list(product(range(3), repeat=k))
    good_stats=Counter();maxima=[]
    for m in range(len(words)+1):
        for ids in combinations(range(len(words)),m):
            S=[words[i] for i in ids]
            psd=good(S)
            good_stats[m]+=int(psd)
            if psd and m==2**k:maxima.append(S)
    assert max(m for m,count in good_stats.items() if count)>0 and max(m for m,count in good_stats.items() if count)==2**k,good_stats
    assert all(box(S,k) for S in maxima)
    assert len(maxima)==3**k,(k,len(maxima))
    print(f'k={k}: exhaustive 2^(3^k) support subsets; maximum {2**k}, extremal {3**k}, distribution {dict(good_stats)}')

k=3
nodes=list(product(range(3),repeat=k))
base=(0,)*k
# Independent standard-library Bron-Kerbosch enumeration of maximal cliques.
vertices=nodes[1:]
adj={x:{y for y in vertices if y!=x and symp(x,y)==0} for x in vertices}
cliques=[]
def bronk(R,P,X):
    if not P and not X:
        cliques.append(R)
        return
    pivot=max(P|X,key=lambda u:len(P&adj[u]),default=None)
    candidates=P-(adj[pivot] if pivot is not None else set())
    for v in tuple(candidates):
        bronk(R+(v,),P&adj[v],X&adj[v])
        P.remove(v)
        X.add(v)
bronk((),set(vertices),set())
maxm=max(len(c) for c in cliques)+1
big=[c for c in cliques if len(c)==maxm-1]
assert maxm==2**k
assert len(big)==2**k,(len(big),big)
assert all(box(list(c)+[base],k) for c in big)
print('k=3: independent anchored GF2 bilinear compatibility graph maximal cliques',len(cliques),'; maximum including anchor',maxm,'; extremizers with anchor',len(big))

k=4
X=list(product(range(3),repeat=k)); base=X[0]
# canonical maximum 16-point binary subcube, all 65 outside points give explicit frustrated triple
B=list(product(range(2),repeat=k))
assert good(B) and len(B)==16
for y in set(X)-set(B):
    bad=next(((a,b,y) for a,b in combinations(B,2) if frustrated(a,b,y)),None)
    assert bad is not None,y
    num=sum(frustrated(a,b,y) for a,b in combinations(B,2))
    assert num==4**(k-1),(y,num)
print('k=4: 16-vertex binary cube PSD; every one of 65 external words induces exactly 64 frustrated rank-three triples')

# Source 9-word code contains a rank-3 obstruction and supports exact Q=-3/16
A=[(x,y,(x+y)%3,(x+2*y)%3) for x in range(3) for y in range(3)]
for a,b,c in combinations(A,3):
    assert frustrated(a,b,c)
    # choose coefficients ±1 that turn all three cross signs negative
    signs=(1,-eps(a,b),-eps(a,c))
    val=sum(signs[i]*signs[j]*eps(t[i],t[j]) for i in range(3) for j in range(3) for t in [(a,b,c)])
    assert val==-3
print('k=4: all 84 triples from [4,2,3] code yield exact Q=-3/16 with signed rank-three diagonal witness')
print('PASS')
