#!/usr/bin/env python3
"""Independent finite algebra / six-root enumerator for semidirect cycle filters.
Not imported by the literal graph oracle; all operations on GF(2)[X]/(p) exact.
"""
from collections import Counter
BASE={u:tuple(range(3,6)) if u<3 else tuple(range(3)) for u in range(6)}
Z={(1,4):1,(1,5):5,(2,4):17,(2,5):64}
EDGES=tuple(Z)
M=147
CASE={2:{"polynomial":0b111,"action_order":3,"aux":(0,1,1,1),"word14":"03140524130425"},
      3:{"polynomial":0b1011,"action_order":7,"aux":(0,1,4,1),"word14":"03142305132415"}}
WORD32="03140523041325140314031403140314"

def gf_mult(a,b,p,n):
    r=0
    while b:
        if b&1:r ^= a
        b>>=1;a<<=1
        if a&(1<<n):a ^= p
    return r

def initialize(n):
    p=CASE[n]["polynomial"]; q=CASE[n]["action_order"]
    # Actions precomputed from field multiplication, unrelated to literal oracle's bit shifts.
    xpow=[1]
    for _ in range(q-1):xpow.append(gf_mult(xpow[-1],2,p,n))
    assert gf_mult(xpow[-1],2,p,n)==1
    def action(k,v):return gf_mult(xpow[k%q],v,p,n)
    aux=dict(zip(EDGES,CASE[n]["aux"]))
    def traverse(u,v,z,k):
        key=tuple(sorted((u,v)))
        w=Z.get(key,0)
        a=aux.get(key,0)
        if u>=3:
            w=-w
            a=action(w,a) # -v = v in characteristic 2, inverse twists by T^{-w}
        return z+w,k ^ action(z,a)
    return traverse,action

def path(n,word):
    traverse,_=initialize(n)
    z=0;k=0;seen=set();base=list(map(int,word))
    for u,v in zip(base,base[1:]+base[:1]):
        assert v in BASE[u]
        point=(u,z%M,k)
        assert point not in seen,('self intersection',n,word,point)
        seen.add(point)
        z,k=traverse(u,v,z,k)
    assert z==0 and k==0,(n,word,z,k)
    return len(seen)

def zero_quotient_words(target):
    counter=Counter();found=[]
    def rec(start,prev,cur,steps,z,walk):
        if steps==target:
            if cur==start and walk[1]!=prev:
                counter['all']+=1
                if z%M==0:found.append(tuple(walk))
            return
        for nxt in BASE[cur]:
            if steps and nxt==prev:continue
            w=Z.get(tuple(sorted((cur,nxt))),0)*(1 if cur<3 else -1)
            rec(start,cur,nxt,steps+1,z+w,walk+[nxt])
    for r in range(6):rec(r,None,r,0,0,[r])
    return counter['all'],found

for n,conf in CASE.items():
    tr,action=initialize(n)
    assert len({action(j,1) for j in range(conf['action_order'])})==conf['action_order']
    assert path(n,conf['word14'])==14
    assert path(n,WORD32)==32
    observed={}
    for length,expected in ((12,8712),(14,None)):
        all_words,candidates=zero_quotient_words(length)
        if expected is not None: assert all_words==expected,(length,all_words)
        zero=0
        for word in candidates:
            z=k=0
            for u,v in zip(word,word[1:]):z,k=tr(u,v,z,k)
            assert z%M==0
            if k==0:zero+=1
        observed[length]=(all_words,len(candidates),zero)
    assert observed[12][1]==144 and observed[12][2]==0
    assert observed[14][2]>0
    print('PASS independent twisted-voltage proof',{'dimension':n,'action':conf['action_order'],'voltage_counts':observed,'C14':conf['word14'],'C32':WORD32})

