#!/usr/bin/env python3
"""Small independent group/graph oracle for semidirect K3,3 voltage lifts.
No dependencies beyond Python stdlib.
"""
from collections import deque, Counter

M=147
BASE_ADJ={u:(3,4,5) if u<3 else (0,1,2) for u in range(6)}
CHORD={(1,4):(1,0),(1,5):(5,0),(2,4):(17,1),(2,5):(64,0)}
C12='031405130415'
C32='03140523041325140314031403140314'

def make(n, aux=None):
    assert n in (2,3)
    if aux is None: aux=(0,1,1,1) if n==2 else (0,1,4,1)
    nmask=2**n-1
    def t_once(v):
        if n==2:
            a,b=v&1,(v>>1)&1
            return b | ((a^b)<<1)
        a,b,c=v&1,(v>>1)&1,(v>>2)&1
        return c | ((a^c)<<1)|(b<<2)
    order=3 if n==2 else 7
    def act(z,v):
        for _ in range(z%order):v=t_once(v)
        return v
    assert act(order,1)==1
    assert len({act(k,1) for k in range(order)})==order
    def mul(g,h):
        x,v=g;y,w=h
        return ((x+y)%M,v^act(x,w))
    def inv(g):
        x,v=g
        return ((-x)%M,act(-x,v))
    labels={}
    ext=dict(zip(((1,4),(1,5),(2,4),(2,5)), aux))
    for u in range(3):
        for v in range(3,6):
            zz=CHORD.get((u,v),(0,0))[0]
            g=(zz,ext.get((u,v),0))
            labels[u,v]=g
            labels[v,u]=inv(g)
    states=[(x,v) for x in range(M) for v in range(2**n)]
    code={g:i for i,g in enumerate(states)}
    V=len(states);N=V*6
    # Neighbor generator built from multiplication, no assumptions on shortcuts
    adj=[[] for _ in range(N)]
    for u in range(3):
        for g in states:
            i=u*V+code[g]
            for v in range(3,6):
                h=mul(g,labels[u,v])
                j=v*V+code[h]
                adj[i].append(j);adj[j].append(i)
    assert all(len(x)==3 and len(set(x))==3 for x in adj)
    assert all(i in adj[j] for i,ns in enumerate(adj) for j in ns)
    starts=[u*V+code[(0,0)] for u in range(6)]
    vis=bytearray(N); q=deque([starts[0]]);vis[starts[0]]=1
    while q:
        x=q.popleft()
        for y in adj[x]:
            if not vis[y]:vis[y]=1;q.append(y)
    assert sum(vis)==N,(sum(vis),N)
    def checkword(word):
        g=(0,0); seen=set()
        for u,v in zip(word,word[1:]+word[:1]):
            assert v in map(str,BASE_ADJ[int(u)])
            s=(int(u),g)
            assert s not in seen,('repeated',word,s)
            seen.add(s)
            g=mul(g,labels[int(u),int(v)])
        assert g==(0,0),('nonclosing word',word,g)
        return len(seen)
    assert checkword(C32)==32
    # independent *simple* graph DFS, rooted at a representative of each base fiber
    ct=Counter()
    word14=None
    def dfs(root,cur,depth,path):
        nonlocal word14
        if depth==16:return
        for nxt in adj[cur]:
            if nxt==root:
                if depth+1>=4 and (depth+1)%2==0:
                    ct[depth+1]+=1
                    if depth+1==14 and word14 is None:word14=''.join(str(x//V) for x in path)
            elif not used[nxt]:
                used[nxt]=1;dfs(root,nxt,depth+1,path+[nxt]);used[nxt]=0
    for root in starts:
        used=bytearray(N);used[root]=1;dfs(root,root,0,[root])
    for length in (4,6,8,10,16):assert ct[length]==0,(length,ct)
    assert ct[12]==0
    assert ct[14]>0
    return {"n":n,"action_order":order,"group_order":V,"graph_vertices":N,"graph_edges":3*N//2,"cycle_root_counts":{k:ct[k] for k in (4,6,8,10,12,14,16)},"C12":0,"C32":32,"aux":aux,"witness14":word14}

if __name__=='__main__':
    for n in (2,3):print('PASS',make(n))

