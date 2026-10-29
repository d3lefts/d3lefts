#!/usr/bin/env python3
"""Independent Edmonds Blossom + direct-sum Sidon repair audit. No networkx in solver."""
from collections import defaultdict
from itertools import combinations,product
import random,hashlib

def blossom_maximum_matching(n,edges):
    g=[set() for _ in range(n)]
    ed={(min(a,b),max(a,b)) for a,b in edges}
    for a,b in ed:
        assert 0<=a<n and 0<=b<n and a!=b
        g[a].add(b);g[b].add(a)
    g=[sorted(x) for x in g];mate=[-1]*n
    def find(root):
        parent=[-1]*n;used=[False]*n;base=list(range(n));queue=[root];used[root]=True
        def lca(a,b):
            seen=set()
            while True:
                a=base[a];seen.add(a)
                if mate[a]==-1:break
                a=parent[mate[a]]
            while True:
                b=base[b]
                if b in seen:return b
                if mate[b]==-1:break
                b=parent[mate[b]]
            raise AssertionError("missing blossom LCA")
        def mark(a,b,child,flower):
            while base[a]!=b:
                flower[base[a]]=flower[base[mate[a]]]=True
                parent[a]=child;child=mate[a];a=parent[mate[a]]
        pos=0
        while pos<len(queue):
            v=queue[pos];pos+=1
            for u in g[v]:
                if base[v]==base[u] or mate[v]==u:continue
                if u==root or (mate[u]!=-1 and parent[mate[u]]!=-1):
                    b=lca(v,u);flower=[False]*n
                    mark(v,b,u,flower);mark(u,b,v,flower)
                    for i in range(n):
                        if flower[base[i]]:
                            base[i]=b
                            if not used[i]:used[i]=True;queue.append(i)
                elif parent[u]==-1:
                    parent[u]=v
                    if mate[u]==-1:
                        x=u
                        while x!=-1:
                            p=parent[x];nxt=mate[p] if p!=-1 else -1
                            mate[x]=p
                            if p!=-1:mate[p]=x
                            x=nxt
                        return True
                    t=mate[u]
                    if not used[t]:used[t]=True;queue.append(t)
        return False
    for i in range(n):
        if mate[i]==-1:find(i)
    assert all(j==-1 or (mate[j]==i and (min(i,j),max(i,j)) in ed) for i,j in enumerate(mate))
    return mate

def add(moduli,a,b):return tuple((x+y)%m for x,y,m in zip(a,b,moduli))
def sidon(moduli,S):
    sums=[add(moduli,x,y) for i,x in enumerate(S) for y in S[i:]]
    return len(sums)==len(set(sums))

def direct_supports(moduli,D,E):
    """Enumerate ALL repeated unordered sums; do not use Vesper collision taxonomy."""
    if not sidon(moduli,E):return None
    S=D+E;n=len(D);by=defaultdict(list)
    for i in range(len(S)):
        for j in range(i,len(S)):
            by[add(moduli,S[i],S[j])].append((i,j))
    H=set();Q=set()
    for pairs in by.values():
        for (a,b),(c,d) in combinations(pairs,2):
            t=(a>=n)+(b>=n);u=(c>=n)+(d>=n)
            old=frozenset(x for x in (a,b,c,d) if x<n)
            if (t,u) in ((0,1),(1,0)):H.add(old)
            else:Q.add(old)
    if frozenset() in Q:return None
    return sorted(H,key=lambda s:tuple(sorted(s))),sorted(Q,key=lambda s:tuple(sorted(s)))

def solve(moduli,D,E,F=()):
    D=tuple(D);E=tuple(E);F=set(F)
    assert len(set(D))==len(D) and len(set(E))==len(E) and not set(D)&set(E)
    assert F<=set(D) and sidon(moduli,D)
    fam=direct_supports(moduli,D,E)
    if fam is None:return None
    H,Q=fam;n=len(D)
    incidence=[sum(i in h for h in H) for i in range(n)]
    assert max(incidence,default=0)<=2*len(E)
    core=set(i for i,d in enumerate(incidence) if d>=3)
    for q in Q:core.update(q)
    core=sorted(core);protected={i for i,x in enumerate(D) if x in F}
    best=None
    for bits in range(1<<len(core)):
        chosen={core[i] for i in range(len(core)) if bits>>i&1}
        if chosen&protected or any(not q&chosen for q in Q):continue
        residual=[h for h in H if not h&chosen]
        available=set(range(n))-set(core)-protected
        if any(not h&available for h in residual):continue
        mark_inc=defaultdict(list)
        for j,h in enumerate(residual):
            for i in h&available:mark_inc[i].append(j)
        graph_edges=set();edge_marks={}
        for mark,inc in mark_inc.items():
            assert len(inc)<=2
            if len(inc)==2:
                a,b=sorted(inc);graph_edges.add((a,b));edge_marks.setdefault((a,b),mark)
        mate=blossom_maximum_matching(len(residual),graph_edges)
        deletions=set(chosen)
        for i,j in enumerate(mate):
            if i<j:deletions.add(edge_marks[(i,j)])
        for h in residual:
            if not h&deletions:deletions.add(min(h&available))
        assert len(deletions)==len(chosen)+len(residual)-sum(x!=-1 for x in mate)//2
        assert sidon(moduli,tuple(x for i,x in enumerate(D) if i not in deletions)+E)
        if best is None or len(deletions)<len(best):best=tuple(D[i] for i in sorted(deletions))
    return best

def brute(moduli,D,E,F):
    free=[x for x in D if x not in F]
    for r in range(len(free)+1):
        for R in combinations(free,r):
            if sidon(moduli,tuple(x for x in D if x not in R)+E):return r
    return None

def test():
    import networkx as nx
    rng=random.Random(20261029);count=0
    for n in range(2,39):
        for _ in range(25):
            e=[(i,j) for i in range(n) for j in range(i+1,n)
               if rng.random()<rng.choice([.08,.18,.38,.75])]
            mate=blossom_maximum_matching(n,e)
            g=nx.Graph();g.add_nodes_from(range(n));g.add_edges_from(e)
            assert sum(x!=-1 for x in mate)//2==len(nx.algorithms.matching.max_weight_matching(g,maxcardinality=True))
            count+=1
    print("BLOSSOM",count,"independent networkx comparisons PASS")
    cases=hi=special=0;digest=hashlib.sha256()
    for mods in [(7,),(9,),(11,),(13,),(2,3),(2,4),(3,3),(2,2,2),(2,2,3)]:
        elems=list(product(*(range(x) for x in mods)))
        for _ in range(140):
            D=tuple(x for x in rng.sample(elems,rng.randrange(1,min(6,len(elems)-2))))
            if not sidon(mods,D):continue
            avail=[x for x in elems if x not in D]
            E=tuple(rng.sample(avail,rng.randrange(1,min(5,len(avail))+1)))
            F=tuple(x for x in D if rng.random()<.35)
            expected=brute(mods,D,E,F)
            ans=solve(mods,D,E,F)
            actual=None if ans is None else len(ans)
            assert actual==expected,(mods,D,E,F,expected,ans)
            fam=direct_supports(mods,D,E)
            if fam is not None:
                H,Q=fam
                hi+=any(sum(i in s for s in H)>=3 for i in range(len(D)))
                special+=bool(Q)
                assert len(set().union(*Q) if Q else set())<=(len(E)**3+3*len(E)**2)//2
            digest.update(repr((mods,D,E,F,actual)).encode()+b'\n')
            cases+=1
    assert solve((101,),((50,),),((0,),(1,),(2,))) is None
    print("BATCH",cases,"high-incidence",hi,"exceptional",special,"SHA256",digest.hexdigest(),"PASS")
if __name__=="__main__":test()
