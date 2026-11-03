#!/usr/bin/env python3
"""Independent finite group voltage-cover controls for Lemnis self-assignment #80.
Only uses Python standard library. Symbolic proof appears in RESEARCH_NOTE.md.
"""
from itertools import combinations
from collections import deque
from random import Random
from hashlib import sha256
import json

# Groups represented as elements 0..n-1 with exact Cayley tables.
def cyclic(n):
    return [[(a+b)%n for b in range(n)] for a in range(n)]

def xor8():
    return [[a^b for b in range(8)] for a in range(8)]

def dihedral8():
    # (r^i s^j) * (r^k s^l) = r^(i+(-1)^j k)s^(j+l)
    return [[((a%4 + (1 if a<4 else -1)*(b%4))%4)+4*((a//4+b//4)%2)
             for b in range(8)] for a in range(8)]

def quaternion8():
    # labels ±1 ±i ±j ±k ; 0-3 positive, 4-7 negative
    table=[[0]*8 for _ in range(8)]
    base={(0,0):(1,0), (0,1):(1,1),(0,2):(1,2),(0,3):(1,3),
          (1,0):(1,1),(2,0):(1,2),(3,0):(1,3),
          (1,1):(-1,0),(2,2):(-1,0),(3,3):(-1,0),
          (1,2):(1,3),(2,3):(1,1),(3,1):(1,2),
          (2,1):(-1,3),(3,2):(-1,1),(1,3):(-1,2)}
    for a in range(8):
        for b in range(8):
            sign, k=base[(a%4,b%4)]
            table[a][b]=k+(0 if sign*(1 if a<4 else -1)*(1 if b<4 else -1)>0 else 4)
    return table

def invs(T):
    n=len(T)
    assert all(T[0][x]==x and T[x][0]==x for x in range(n))
    return [next(y for y in range(n) if T[x][y]==T[y][x]==0) for x in range(n)]

def validate_group(T):
    n=len(T)
    assert all(sorted(row)==list(range(n)) for row in T)
    for x in range(n):
        for y in range(n):
            for z in range(n):
                assert T[T[x][y]][z]==T[x][T[y][z]]
    invs(T)

def order(T,x):
    y=0
    for j in range(1,len(T)+1):
        y=T[y][x]
        if y==0:return j
    raise AssertionError('element order not found')

def baseK4():return [(a,b) for a,b in combinations(range(4),2)]
def baseK33():return [(a,b) for a in range(3) for b in range(3,6)]
def baseC4():return [(0,1),(1,2),(2,3),(0,3)]

def build_cover(vertices,edges,T,labels):
    g=len(T); inverse=invs(T)
    adj=[set() for _ in range(vertices*g)]
    for a,b in edges:
        assert a<b
        h=labels[(a,b)]
        for x in range(g):
            y=T[x][h]
            u=a*g+x; v=b*g+y
            assert u!=v
            adj[u].add(v);adj[v].add(u)
    return adj

def found_cycle(adj, length):
    # Independent literal simple-cycle DFS: early success, only small fixture graphs.
    n=len(adj)
    for root in range(n):
        stack=[(root,[root],1<<root)]
        while stack:
            v,path,seen=stack.pop()
            if len(path)==length:
                if root in adj[v]:return tuple(path)
                continue
            for w in adj[v]:
                if w>root and not (seen>>w)&1:
                    stack.append((w,path+[w],seen|(1<<w)))
    return None

def make_base_cycle(vertices,edges):
    adj={i:set() for i in range(vertices)}
    for u,v in edges:adj[u].add(v);adj[v].add(u)
    assert all((i+1)%4 in adj[i] for i in range(4))
    return [0,1,2,3,0]

def verify_lift(T,edges,labels,base_cycle):
    g=len(T); adj=build_cover(max(max(e) for e in edges)+1,edges,T,labels)
    inverse=invs(T)
    def step(x,a,b):
        if a<b:return T[x][labels[(a,b)]]
        return T[x][inverse[labels[(b,a)]]]
    voltage=0
    for u,v in zip(base_cycle,base_cycle[1:]):voltage=step(voltage,u,v)
    m=order(T,voltage)
    x=0; path=[]
    for _ in range(m):
        for a,b in zip(base_cycle,base_cycle[1:]):
            path.append(a*g+x)
            x=step(x,a,b)
    assert x==0
    assert len(path)==4*m and len(path)==len(set(path))
    assert all(path[(i+1)%len(path)] in adj[v] for i,v in enumerate(path))
    assert found_cycle(adj,4*m)
    return m, len(adj), len(path)

def test():
    rng=Random(20261029)
    groups={'C2^3':xor8(),'D8':dihedral8(),'Q8':quaternion8(), 'C8':cyclic(8)}
    for name,T in groups.items():
        validate_group(T)
        assert all(order(T,i)&(order(T,i)-1)==0 for i in range(len(T)))
    total=0; stats={}
    for name,T in groups.items():
        counts={}
        edges=baseK4()
        for _ in range(20):
            labels={e:rng.randrange(8) for e in edges}
            m,num,cyc=verify_lift(T,edges,labels,[0,1,2,3,0])
            counts[m]=counts.get(m,0)+1
            total+=1
        stats[name]=counts
    # Odd-order counterexample to 2-primary hypothesis: C3 regular cover of C4 becomes C12.
    T=cyclic(3);edges=baseC4()
    labels={e:(1 if e==(0,1) else 0) for e in edges}
    adj=build_cover(4,edges,T,labels)
    assert len(adj)==12
    assert found_cycle(adj,12)
    assert not found_cycle(adj,4) and not found_cycle(adj,8)
    print(json.dumps({'status':'PASS','regular_2group_K4_tests':total,'orders':stats,
                      'odd_order_falsifier':'C3 cover of C4 = C12, no C4/C8'},sort_keys=True))

if __name__=='__main__':test()
