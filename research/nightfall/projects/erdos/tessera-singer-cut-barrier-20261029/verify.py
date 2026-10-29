#!/usr/bin/env python3
"""TESSERA #95: cut-uniform Singer source-reuse deletion barrier.
All-source difference audit, literal AB/AB sum oracle, exhaustive cut sweep.
"""
from bisect import bisect_left
from collections import defaultdict
from hashlib import sha256
from math import ceil
import json

def singer1009():
    p=1009;v=p*p+p+1
    a,b,c=1,0,0;D=[]
    for e in range(v):
        if c==0:D.append(e)
        a,b,c=(2*a-2*c)%p,(a+2*b)%p,(b+2*c)%p
    assert (b,c)==(0,0) and len(D)==p+1
    return v,D

def singer25():
    p=5; f=(1,1,1,0,0,0)
    one=(1,0,0,0,0,0);root=(1,3,0,0,0,0)
    def mul(x,y):
        z=[0]*11
        for i in range(6):
            for j in range(6):z[i+j]=(z[i+j]+x[i]*y[j])%p
        for k in range(10,5,-1):
            t=z[k]
            for j in range(6):z[k-6+j]=(z[k-6+j]-t*f[j])%p
        return tuple(z[:6])
    def power(x,n):
        y=one
        while n:
            if n&1:y=mul(y,x)
            x=mul(x,x);n>>=1
        return y
    def add(x,y):return tuple((a+b)%p for a,b in zip(x,y))
    q=25;v=q*q+q+1;state=one;D=[]
    for e in range(v):
        if add(add(state,power(state,q)),power(state,q*q))==(0,)*6:D.append(e)
        state=mul(state,root)
    assert len(D)==q+1
    return v,D

def audit_differences(v,D):
    assert len(set(D))==len(D)
    seen=bytearray(v)
    for i,x in enumerate(D):
        for y in D[:i]:
            diff=(x-y)%v
            assert diff and not seen[diff] and not seen[v-diff]
            seen[diff]=seen[v-diff]=1
    assert sum(seen)==v-1

def best_arc(v,D):
    width=(v-1)//2-4
    double=D+[x+v for x in D]
    best=(-1,-1);end=0
    for i,d in enumerate(D):
        end=max(end,i)
        while end<i+len(D) and double[end]-d<width:end+=1
        if end-i>best[0]:best=(end-i,d)
    m,origin=best
    Q=sorted((d-origin)%v for d in D)
    P=tuple(d for d in Q if d<width)
    assert len(P)==m and m*v>=len(D)*width
    return width,origin,Q,P

def direct_ab_graph(A,Q,v,cut,T):
    B=tuple(T+(d-cut)%v for d in Q)
    sums=defaultdict(list)
    for i,a in enumerate(A):
        for j,b in enumerate(B):
            sums[a+b].append((i,j))
    edges=set()
    for group in sums.values():
        if len(group)>1:
            assert len(group)==2
            (i,j),(k,l)=group
            assert i!=k and j!=l
            edges.add(tuple(sorted((j,l))))
    return edges

def verify(q,source):
    v,D=source()
    K=len(D)
    audit_differences(v,D)
    width,origin,Q,P=best_arc(v,D)
    A=tuple(1+d for d in P)
    m=len(A);N=max(A);h=1;T=v-1
    assert h<v/4 and v-h>2*N and 2*(h+N+1)<v
    assert v-h<=T<=v-(h+1)//2
    assert m>=ceil(K*width/v)
    for cut in (0,P[m//2],width//2,width+1,v-1):
        lo=tuple(i for i,d in enumerate(P) if d<cut)
        hi=tuple(i for i,d in enumerate(P) if d>=cut)
        predicted={tuple(sorted((i,j))) for group in (lo,hi)
                   for i in group for j in group if i<j}
        assert direct_ab_graph(A,Q,v,cut,T)==predicted
        assert sum(max(0,len(g)-1) for g in (lo,hi))>=m-2
    # Every cyclic cut is checked by a distinct order-statistic sweep.
    count=0;minimum=K;maximum=-1;hist=defaultdict(int)
    for cut in range(v):
        while count<m and P[count]<cut:count+=1
        cover=max(0,count-1)+max(0,m-count-1)
        assert cover>=m-2
        minimum=min(minimum,cover)
        maximum=max(maximum,cover)
        hist[cover]+=1
    assert minimum==m-2 and maximum==m-1
    # Invalid source is rejected by difference verifier.
    invalid=list(D);invalid[0]=invalid[1]
    try:
        audit_differences(v,invalid)
    except AssertionError:
        pass
    else:
        raise AssertionError("negative control unexpectedly accepted")
    digest=sha256((''.join(f'{x}\n' for x in A)).encode()).hexdigest()
    print(f'PASS q={q}, v={v}, Singer={K}, arc={width}, origin={origin}')
    print(f'PASS prefix={m}, max A={N}, uniform cut deletion >= {minimum}')
    print(f'PASS all {v} cuts; literal AB/AB oracle on 5 cuts')
    print(f'PASS SHA256 {digest}; histogram {dict(sorted(hist.items()))}')
    return {"q":q,"v":v,"source":K,"arc":width,"origin":origin,
            "prefix_size":m,"prefix_max":N,"min_deletions":minimum,
            "max_deletions":maximum,"cover_histogram":dict(sorted(hist.items())),
            "prefix_sha256":digest}

if __name__=="__main__":
    results=[verify(25,singer25),verify(1009,singer1009)]
    print("RECEIPT "+json.dumps(results,sort_keys=True,separators=(",",":")))
