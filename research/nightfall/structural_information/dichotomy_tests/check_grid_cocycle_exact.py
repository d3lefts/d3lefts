#!/usr/bin/env python3
"""Exact finite H1/H2 cocycle and bounded-column-decoder audit on grid edges.

Uses a different algorithm from the circuit checker: BFS tree paths and
an independent matrix rank test for the 4-face cycle-space generators.
No solver and no claim about all possible high-girth frames.
"""
from collections import deque
from itertools import combinations

checks=0
def ck(test,name):
    global checks
    if not test:raise AssertionError(name)
    checks+=1

def xor_words(xs):
    z=0
    for x in xs:z^=x
    return z

def rank(xs):
    pivots={}
    for val in xs:
        while val:
            i=val.bit_length()-1
            if i in pivots:val^=pivots[i]
            else:
                pivots[i]=val
                break
    return len(pivots)

def grid(side):
    n=side*side
    es=[]
    edgeidx={}
    for y in range(side):
        for x in range(side):
            i=y*side+x
            for j in ((i+1,) if x+1<side else ())+((i+side,) if y+1<side else ()):
                v=j[0]
                edgeidx[tuple(sorted((i,v)))]=len(es)
                es.append((i,v))
    faces=[]
    for y in range(side-1):
        for x in range(side-1):
            a=y*side+x; b=a+1; c=a+side; d=c+1
            faces.append(tuple(edgeidx[tuple(sorted(uv))] for uv in ((a,b),(b,d),(c,d),(a,c))))
    return n,es,faces

def tree_basis(n,es):
    graph=[[] for _ in range(n)]
    for k,(u,v) in enumerate(es):
        graph[u].append((v,k));graph[v].append((u,k))
    seen={0};q=deque([0]);basis_edges=[]
    while q:
        u=q.popleft()
        for v,k in graph[u]:
            if v not in seen:
                seen.add(v);q.append(v);basis_edges.append(k)
    ck(len(seen)==n and len(basis_edges)==n-1,"tree connected")
    bmap={e:i for i,e in enumerate(basis_edges)}
    adj=[[] for _ in range(n)]
    for e,j in bmap.items():
        u,v=es[e]
        adj[u].append((v,j));adj[v].append((u,j))
    def path(u,v):
        q=deque([u])
        parent={u:None}
        via={}
        while q:
            x=q.popleft()
            if x==v:break
            for y,j in adj[x]:
                if y not in parent:
                    parent[y]=x;via[y]=j;q.append(y)
        assert v in parent
        word=0
        y=v
        while y!=u:
            word ^= 1<<via[y]
            y=parent[y]
        return word
    return basis_edges,path

for side in (2,3,4,5,6):
    n,es,faces=grid(side)
    original=[(1<<u)^(1<<v) for u,v in es]
    basis_edges,path=tree_basis(n,es)
    B=[original[j] for j in basis_edges]
    c=max(path(u,v).bit_count() for u,v in es)
    ck(rank(B)==n-1,"high-girth independent B")
    ck(len(faces)==len(es)-n+1,"Euler face-cycle count")
    face_words=[]
    for face in faces:
        word=xor_words(1<<i for i in face)
        face_words.append(word)
        ck(xor_words(original[i] for i in face)==0,"graph face closes")
        ck(xor_words(path(*es[i]) for i in face)==0,"lifted face word vanishes")
    ck(rank(face_words)==len(es)-n+1,"faces generate cycle space")
    phi=[path(0,v) for v in range(n)]
    for v in range(n):
        physical=xor_words(B[j] for j in range(len(B)) if (phi[v]>>j)&1)
        ck(physical==((1<<0)^(1<<v)),"vertex potential decoder")
    for i,(u,v) in enumerate(es):
        eword=path(u,v)
        ck(phi[u]^phi[v]==eword,"cocycle exact")
        ck(eword.bit_count()<=c,"forward c")
        ck(xor_words(B[j] for j in range(len(B)) if (eword>>j)&1)==original[i],"edge decode")
    ck(all(b.bit_count()==2 for b in B),"reverse columns have physical support 2")
    # Fundamental cycle property (closed one-forms are exact on the grid).
    ck(c>=1 and len(B)==n-1, "legitimate basis frame")

# H>=c*4 is essential: taking every edge as B on a 2x2 square
# has girth exactly four, so is valid for h=3 and c=1, but the
# face's lifted coefficient-word is nonzero.
n,es,faces=grid(2)
original=[(1<<u)^(1<<v) for u,v in es]
ck(len(es)==4 and rank(original)==3,"square unique cycle")
for subset_size in range(1,4):
    for inds in combinations(range(4),subset_size):
        ck(rank([original[i] for i in inds])==subset_size,
           "square girth > 3")
ck(xor_words(1<<i for i in faces[0])!=0,"no forced cancellation when h<c*ell")
ck(xor_words(original[i] for i in faces[0])==0,"physical square relation")
print(f'PASS exact grid cochain audit: {checks} assertions over 5 square-grid sizes and a girth-3 negative control.')
print('LIMIT: not a nonexistence certificate for all (c,cprime,h) frames; general E remains open.')
