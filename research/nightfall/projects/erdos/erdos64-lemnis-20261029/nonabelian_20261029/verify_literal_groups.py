#!/usr/bin/env python3
"""Independent literal graph oracle: nonabelian deck-factor lifts of a K3,3 cyclic 147-cover."""
from collections import Counter
from itertools import permutations
from hashlib import sha256
import json

W = {(1,4):1,(1,5):5,(2,4):17,(2,5):64}
C12='031405130415'
C32='03140523041325140314031403140314'

def D8():
    els=[(r,s) for r in range(4) for s in range(2)]
    unit=(0,0)
    mul=lambda a,b:((a[0]+((-1)**a[1])*b[0])%4,(a[1]+b[1])%2)
    return 'D8',els,unit,mul,(1,0),(0,1)

def S3():
    els=list(permutations(range(3)))
    unit=(0,1,2)
    mul=lambda a,b:tuple(a[b[i]] for i in range(3))
    return 'S3',els,unit,mul,(1,2,0),(1,0,2)

def analyze(group,m=147):
    name, els, unit, mul, gh, gk=group
    inv={a: next(b for b in els if mul(a,b)==unit and mul(b,a)==unit) for a in els}
    ix={a:i for i,a in enumerate(els)}
    # a, b, h vertex indices: base 0..5, cyclic mod m, group D8 or S3
    def encode(b,x,h):return ((b*m+x)*len(els)+ix[h])
    def decode(v):
        b,x=divmod(v//len(els),m)
        return (b,x,els[v%len(els)])
    edgevolt={(1,4):unit,(1,5):unit,(2,4):gh,(2,5):gk}
    adj=[[] for _ in range(6*m*len(els))]
    for a in range(3):
        for b in range(3,6):
            wg=W.get((a,b),0);hg=edgevolt.get((a,b),unit)
            for x in range(m):
                for h in els:
                    v=encode(a,x,h);t=encode(b,(x+wg)%m,mul(h,hg))
                    adj[v].append(t);adj[t].append(v)
    assert all(len(set(nei))==3 for nei in adj)
    seen={0}; stack=[0]
    while stack:
        v=stack.pop()
        for t in adj[v]:
            if t not in seen:seen.add(t);stack.append(t)
    assert len(seen)==len(adj),('disconnected',name,len(seen),len(adj))

    def trace(word):
        vv=[];x=0;h=unit
        bas=list(map(int,word))
        for a,b in zip(bas,bas[1:]+bas[:1]):
            vv.append(encode(a,x,h))
            lo,hi=min(a,b),max(a,b)
            assert lo<3<=hi
            w=W.get((lo,hi),0);hh=edgevolt.get((lo,hi),unit)
            if a<3:x=(x+w)%m;h=mul(h,hh)
            else:x=(x-w)%m;h=mul(h,inv[hh])
        assert (x,h)==(0,unit),('not closed',name,len(word),x,h)
        assert len(set(vv))==len(word),('not simple',name,len(word))
        assert all(vv[(i+1)%len(vv)] in adj[vv[i]] for i in range(len(vv)))
        return len(vv)
    assert trace(C12)==12
    assert trace(C32)==32
    counts=Counter()
    def walk(root,prev,u,d,seen):
        if d>=16:return
        for v in adj[u]:
            if v==root:
                if d+1>=3:counts[d+1]+=1
                continue
            if v==prev or v in seen:continue
            seen.add(v)
            walk(root,u,v,d+1,seen)
            seen.remove(v)
    for base in range(6):
        root=encode(base,0,unit)
        walk(root,-1,root,0,{root})
    assert all(counts[k]==0 for k in (4,6,8,10,16)),(name,counts)
    assert counts[12]>0
    result={'group':name,'m':m,'vertices':len(adj),'edges':len(adj)*3//2,
            'cycles_rooted_directed':[ [k,counts[k]] for k in (4,6,8,10,12,14,16) ],
            'witness12':C12,'witness32':C32,'connected':True,'simple_cubic':True}
    return result
if __name__=='__main__':
    out=[analyze(g) for g in [D8(),S3()]]
    for r in out:print(json.dumps(r,sort_keys=True))
    print('SCRIPT SHA256:', sha256(open(__file__,'rb').read()).hexdigest())
