#!/usr/bin/env python3
"""Independent finite Sidon boundary construction; no import of Axiom's original builder.
Checks every unordered pair sum directly after all deletions, including diagonals.
"""
from fractions import Fraction as F
from itertools import combinations
from math import ceil, floor, comb
import hashlib, json

def build_bose(q):
    nonres=next(z for z in range(2,q) if pow(z,(q-1)//2,q)==q-1)
    def mul(x,y): return ((x[0]*y[0]+nonres*x[1]*y[1])%q,(x[0]*y[1]+x[1]*y[0])%q)
    def exp(x,n):
        b=(1,0)
        while n:
            if n&1:b=mul(b,x)
            x=mul(x,x);n>>=1
        return b
    L=q*q-1
    divisors=[p for p in range(2,L+1) if L%p==0 and all(p%d for d in range(2,int(p**.5)+1))]
    alpha=next((a,b) for b in range(1,q) for a in range(q) if all(exp((a,b),L//p)!=(1,0) for p in divisors))
    z=(1,0);S=[]
    for e in range(L):
        if z[1]==alpha[1]:S.append(e)
        z=mul(z,alpha)
    assert len(S)==q
    # Difference uniqueness follows from pair sum; independently test on this bounded source.
    sums={}
    for j,a in enumerate(S):
        for b in S[j:]:
            key=(a+b)%L
            assert key not in sums, ('source not Sidon modulo L',key)
            sums[key]=(a,b)
    return L,S,nonres,alpha

def direct_oracle(A):
    sums={}
    for j,a in enumerate(A):
        for b in A[j:]:
            k=a+b
            if k in sums:return False, {'sum':k,'pair1':sums[k],'pair2':(a,b)}
            sums[k]=(a,b)
    return True,len(sums)

def one_test(q,prefix,delta_override=None,require_both=False):
    r=len(prefix);L,S0,d,alpha=build_bose(q)
    delta=delta_override if delta_override is not None else F(3,64*r);eps=F(1,3)
    J=ceil(delta*L)+max(prefix)+2
    assert 2*J+1<L
    W=F(q*(2*J+1),L)
    # Optimize cyclic shift exactly against the endpoint population objective.
    shifts=[]
    for shift in range(L):
        S=sorted((v+shift)%L for v in S0)
        low=[v for v in S if v<=J]
        high=[v for v in S if v>=L-J]
        
        if not require_both or (low and high):
            shifts.append((len(low)+len(high),shift,low,high,S))
    count,shift,lo,hi,S=min(shifts,key=lambda t:(t[0],t[1]))
    assert F(count)<=W, ('averaging violated',count,W)
    I=list(range(ceil((1-delta)*L),floor((1-(1-eps)*delta)*L)+1))
    assert I
    allcounts={t:0 for t in I}; by_t={t:set() for t in I}
    for a in prefix:
      for h in hi:
       for j,v in enumerate(lo):
        for w in lo[j:]:
          t=a+h-v-w
          if t in allcounts:
           allcounts[t]+=1;by_t[t].add(h)
    T=min(I,key=lambda t:(allcounts[t],t))
    raw=allcounts[T]
    positive_T=sum(1 for v in allcounts.values() if v>0)
    total_raw=sum(allcounts.values())
    assert F(raw)<=F(r,len(I))*(F(2,27)*W**3+F(1,8)*W**2), ('upper bound invalid',raw)
    removed=set(by_t[T])
    rest=sorted(set(S)-removed)
    # Block A+B versus A+B. For each old pair, there is at most one residual pair
    # at the old-mark difference. Verify this property rather than assume it.
    extra=[]
    for a,b in combinations(prefix,2):
        matches=[(v,w) for v in rest for w in rest if v-w==b-a]
        assert len(matches)<=1
        if matches:
            v,w=matches[0];removed.add(v);rest.remove(v);extra.append((a,b,v,w))
    final=sorted(set(prefix)|{T+v for v in rest})
    assert min(T+v for v in rest)>max(prefix)
    good,how=direct_oracle(final)
    assert good,(q,prefix,T,shift,how)
    assert len(removed)<=raw+comb(r,2)
    assert len(removed)<=comb(r,2)+F(r,len(I))*(F(2,27)*W**3+F(1,8)*W**2)
    assert max(final)<= (2-F(1,32*r))*L+2, (max(final),L)
    # Mutation control: a duplicated point in coordinates would violate strict pair-sum uniqueness.
    # Instead tamper with one coordinate to guarantee a duplicate element (as a list).
    bad=sorted(final+[final[0]])
    assert not direct_oracle(bad)[0]
    return dict(q=q,prefix=prefix,modulus=L,theta=list(alpha),nonresidue=d,shift=shift,translation=T,
                endpoints=count,ceiling_W=str(W),interval_length=len(I),raw_collisions=raw,translations_with_collisions=positive_T,total_raw_collisions=total_raw,
                deletion_count=len(removed),final_size=len(final),max_element=max(final),
                pair_sums=how,pair_sum_sha256=hashlib.sha256(','.join(map(str,final)).encode()).hexdigest())

if __name__=='__main__':
    import sys
    tests=[(31,[1],None,False),(43,[1,2,4],None,False),(61,[1,2,4,8,13],None,False),(83,[1,2,4,8,13],None,False),(43,[1,2,4],F(1,5),True),(61,[1,2,4,8,13],F(1,5),True),(83,[1,2,4,8,13],F(1,5),True)]
    results=[one_test(q,p,d,b) for q,p,d,b in tests]
    print(json.dumps({'status':'PASS','cases':results,'boundary':'finite cases independently checked; asymptotic proof in theorem'},indent=2))
