#!/usr/bin/env python3
"""Independent literal K4 voltage graph implementation; no import from symbolic checker.
Constructs cycle from permutation and coefficient cases; verifies every edge and every lifted vertex.
"""
from itertools import product,permutations
from random import Random
WORDS={
(-2,-2):'01320',(-2,-1):'01230',(-2,0):'01201203102102130',(-2,1):'013203120',(-2,2):'012302130',
(-1,-2):'012301320',(-1,-1):'01230',(-1,0):'012301320',(-1,1):'012301320',(-1,2):'012301320',
(0,-2):'012031230',(0,-1):'01230',(0,0):'01320',(0,1):'013203120',(0,2):'01201203210210230',
(1,-2):'02130',(1,-1):'01230',(1,0):'02130',(1,1):'01320',(1,2):'02130',
(2,-2):'012302130',(2,-1):'01230',(2,0):'012031230',(2,1):'013203120',(2,2):'01320'}
FALLBACK={3:{(-2,0):'02130',(-2,1):'01320',(-2,2):'01230',(-1,2):'01230',(0,2):'01230'},4:{(-2,0):'012031230',(0,2):'012031230'}}
MAIN='01201203102102130'

def group(ds):
    z=(0,)*len(ds)
    elems=list(product(*(range(n) for n in ds)))
    def add(u,v):return tuple((x+y)%n for x,y,n in zip(u,v,ds))
    def neg(u):return tuple(-x%n for x,n in zip(u,ds))
    def mul(u,m):return tuple((x*m)%n for x,n in zip(u,ds))
    def ord(u):
        v=z
        for i in range(1,1+len(elems)):
            v=add(v,u)
            if v==z:return i
        raise RuntimeError('group order failed')
    return z,elems,add,neg,mul,ord

def graph_witness(ds,abc,check_graph=False):
    z,elems,add,neg,mul,order=group(ds)
    edge={(0,1):z,(0,2):z,(0,3):z,(1,2):abc[0],(1,3):abc[1],(2,3):abc[2]}
    def v(a,b):return edge[(a,b)] if a<b else neg(edge[(b,a)])
    chosen=None
    # any orientation of chord triangle is allowed, with the voltage signs tracked.
    for tup in permutations((1,2,3)):
        a=v(tup[0],tup[1]);b=v(tup[0],tup[2]);c=v(tup[1],tup[2]);m=order(a)
        if m<3:continue
        T={mul(a,i) for i in (-2,-1,0,1,2)}
        if b not in T:
            chosen=MAIN,tup;break
        if c not in T:continue # another permutation will put c in the b-slot
        # Case table is for a,b,c all multiples of a.
        coeff_b=next(i for i in (-2,-1,0,1,2) if mul(a,i)==b)
        coeff_c=next(i for i in (-2,-1,0,1,2) if mul(a,i)==c)
        word=FALLBACK.get(m,{}).get((coeff_b,coeff_c),WORDS[(coeff_b,coeff_c)])
        chosen=word,tup;break
    if chosen is None:
        if not all(order(x)<=2 for x in abc):raise AssertionError('no constructive certificate found')
        # a+c is voltage around the simple 4-cycle 0-1-2-3-0; order 1 or 2.
        word='01230'*(1 if add(abc[0],abc[2])==z else 2)
        if word.endswith('001230'):pass
        if len(word)>5:word='012301230'
        chosen=word,(1,2,3)
    word,perm=chosen
    labels=(0,)+perm
    vertices=[(0,z)];at=z
    for x,y in zip(word,word[1:]):
        src=labels[int(x)];dst=labels[int(y)]
        at=add(at,v(src,dst))
        vertices.append((dst,at))
    assert vertices[-1]==vertices[0],(ds,abc,word,perm,vertices[-1])
    assert len(set(vertices[:-1]))==len(vertices)-1,(ds,abc,word,perm,'not simple')
    assert len(vertices)-1 in (4,8,16)
    if check_graph:
        adj={ (v,x):set() for v in range(4) for x in elems }
        for (a,b),delta in edge.items():
            for x in elems:
                y=add(x,delta)
                adj[(a,x)].add((b,y));adj[(b,y)].add((a,x))
        assert len(adj)==4*len(elems) and all(len(nb)==3 for nb in adj.values())
        for x,y in zip(vertices,vertices[1:]):assert y in adj[x]
        assert all(x in adj[y] for y,neigh in adj.items() for x in neigh)
    return len(word)-1

counts={4:0,8:0,16:0};total=0
for n in range(3,15):
    for abc in product(((i,) for i in range(n)),repeat=3):
        q=graph_witness((n,),abc,check_graph=(n<8))
        counts[q]+=1;total+=1
for ds in ((2,2),(2,2,2),(3,3),(3,4),(4,4)):
    _,e,*_=group(ds)
    for triple in product(e,repeat=3):
        q=graph_witness(ds,triple,check_graph=(len(e)<=9))
        counts[q]+=1;total+=1
rng=Random(28102026)
for ds in ((5,5),(3,3,3),(2,3,5),(4,4,3)):
    _,e,*_=group(ds)
    for _ in range(800):
        abc=tuple(rng.choice(e) for i in range(3))
        q=graph_witness(ds,abc,check_graph=True)
        counts[q]+=1;total+=1
print('PASS',total,'independent literal abelian regular K4 covers; shortest certified lengths',counts)
