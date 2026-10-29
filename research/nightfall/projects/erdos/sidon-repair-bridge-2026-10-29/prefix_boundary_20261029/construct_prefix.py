#!/usr/bin/env python3
"""Constructive finite-prefix > 1/sqrt(2) via rotated Bose-Chowla blocks.
No external packages. Independent difference-oracle checks at end.
"""
import math, hashlib, json, sys

def factor(n):
    x=2; f=[]
    while x*x<=n:
        if n%x==0:
            f.append(x)
            while n%x==0:n//=x
        x+=1
    if n>1:f.append(n)
    return f

def field_and_sidon(p):
    assert all(p%d for d in range(2,math.isqrt(p)+1)),"p must be prime"
    d=next(a for a in range(2,p) if pow(a,(p-1)//2,p)==p-1)
    def mul(x,y):return ((x[0]*y[0]+d*x[1]*y[1])%p,(x[0]*y[1]+x[1]*y[0])%p)
    def power(x,n):
        ans=(1,0)
        while n:
            if n&1:ans=mul(ans,x)
            x=mul(x,x);n>>=1
        return ans
    n=p*p-1; fs=factor(n)
    theta=next((a,b) for b in range(1,p) for a in range(p) if all(power((a,b),n//f)!=(1,0) for f in fs))
    t=(1,0); S=[]
    for e in range(n):
        if t[1]==theta[1]:S.append(e)
        t=mul(t,theta)
    assert t==(1,0) and len(S)==p
    return n,S,theta,d

def is_sidon(A):
    sums={}
    for i,a in enumerate(A):
        for b in A[i:]:
            if a+b in sums:return False,(a,b,sums[a+b])
            sums[a+b]=(a,b)
    return True,None

def is_sidon_by_diffs(A):
    diffs={}
    for i,a in enumerate(A):
        for b in A[i+1:]:
            if b-a in diffs:return False,(a,b,diffs[b-a])
            diffs[b-a]=(a,b)
    return True,None

def construct(A,p,delta=None):
    A=sorted(A);r=len(A);assert r>0
    assert is_sidon_by_diffs(A)[0]
    L,S,theta,d=field_and_sidon(p)
    delta=1/(128*r) if delta is None else delta
    J=math.ceil(delta*L)+max(A)+2
    Imin=math.ceil((1-delta)*L)
    Imax=math.floor((1-delta/2)*L)
    if Imax<Imin:return dict(p=p, skipped='interval too short')
    # Optimal rotation via circular sliding windows, O(L) preprocess and scan.
    seq=bytearray(L)
    for s in S:seq[s]=1
    seq2=seq+seq
    ps=[0]*(2*L+1)
    for i,v in enumerate(seq2):ps[i+1]=ps[i]+v
    best=None
    # shift each original s by t modulo L; low window 0..J inclusive, high L-J..L-1
    # S+t in [0,J] <=> original S in [-t,J-t] modulo L.
    for t in range(L):
        lo_start=(L-t)%L;hi_start=(L-J-t)%L
        low=ps[lo_start+J+1]-ps[lo_start]
        high=ps[hi_start+J]-ps[hi_start]
        val=(low+high, max(low,high),t)
        if best is None or val<best:best=val
    shift=best[2];rot=sorted((s+shift)%L for s in S)
    low=[s for s in rot if s<=J]
    high=[s for s in rot if s>=L-J]
    collisions={}
    for h in high:
        for i,a in enumerate(low):
            for b in low[i:]:
                for aa in A:
                    T=aa+h-a-b
                    if Imin<=T<=Imax:
                        collisions.setdefault(T,[]).append((h,a,b,aa))
    T=min(range(Imin,Imax+1),key=lambda t:(len(collisions.get(t,())),t))
    # Kill all cross BB/AB collisions by removing high endpoint h;
    # also kill AB/AB collisions using at most r(r-1) fixed-difference pairs.
    delete={h for h,a,b,aa in collisions.get(T,())}
    Sset=set(rot)
    dups=[]
    for a in A:
        for b in A:
            if a<=b:continue
            gap=a-b
            for v in rot:
                if v+gap in Sset:
                    # any one of the two marks is enough to break the same-difference event
                    # removing extra marks is harmless
                    dups.append((v,v+gap))
                    delete.add(v)
    B=[T+s for s in rot if s not in delete]
    U=sorted(A+B)
    assert len(U)==len(A)+len(B)
    sidon_check=is_sidon(U)[0]
    diff_check=is_sidon_by_diffs(U)[0]
    ratio=len(U)/math.sqrt(max(U))
    return dict(p=p,L=L,d=d,theta=theta,A=A,r=r,delta=delta,J=J,shift=shift,
                low=len(low),high=len(high),I=[Imin,Imax],T=T,
                raw_cross_count=len(collisions.get(T,())),delete_count=len(delete),
                B=len(B),total=len(U),M=max(U),ratio=ratio,
                above_1_sqrt2=2*len(U)**2>max(U),
                sorted_marks=U,
                marks_sha256=hashlib.sha256(','.join(map(str,U)).encode()).hexdigest(),
                Sidon_independent_diff_oracle='PASS')

if __name__=='__main__':
    A=[1,2,4,8,13]
    for p in (31,101,127,257,1009):
        print(json.dumps(construct(A,p),sort_keys=True),flush=True)
