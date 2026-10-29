#!/usr/bin/env python3
"""Independent mathematical and finite exact audit of Axiom's 2026-10-29 prefix bound."""
from fractions import Fraction as F
from math import ceil, floor, isqrt, comb
from itertools import combinations_with_replacement, combinations
import json

A=(1,2,4,8,13)
q=101
L=q*q-1
r=len(A)
N=max(A)
# Extension GF(101)[u]/(u^2-2), 2 is non-square modulo 101.
assert pow(2,(q-1)//2,q)==q-1

def mul(x,y):
    a,b=x; c,d=y
    return ((a*c+2*b*d)%q,(a*d+b*c)%q)

def powf(x,n):
    acc=(1,0)
    while n:
        if n&1:acc=mul(acc,x)
        x=mul(x,x);n>>=1
    return acc

def is_generator(theta):
    return all(powf(theta,L//p)!=(1,0) for p in (2,3,5,17))
# Factoring 101^2-1 = 2^3*3*5^2*17.
assert L==2**3*3*5**2*17
G=next((a,b) for b in range(1,q) for a in range(q) if is_generator((a,b)))
seen=set(); S=[];x=(1,0)
for k in range(L):
    assert x not in seen
    seen.add(x)
    # θ^k = θ+t iff the u coefficient equals that of θ.
    if x[1]==G[1]:S.append(k)
    x=mul(x,G)
assert x==(1,0) and len(seen)==L and len(S)==q
assert len(set((a+b)%L for a,b in combinations_with_replacement(S,2)))==q*(q+1)//2
assert len(set(a+b for a,b in combinations_with_replacement(A,2)))==r*(r+1)//2

# δ=1/(20r), implement ceil/floor rationally using integer arithmetic.
delta=F(1,20*r)
J=ceil(delta*L)+N+2
Tmin=ceil((1-delta)*L)
Tmax=floor((1-delta/2)*L)
I=list(range(Tmin,Tmax+1))
W=F(q*(2*J+1),L)
assert I and 2*J+1<L
# Exactly sum endpoint counts across all L possible rotations.
minvh=9999;selected=None;sumvh=0
for shift in range(L):
    rotated=[(x+shift)%L for x in S]
    v=sum(x<=J for x in rotated)
    h=sum(x>=L-J for x in rotated)
    sumvh+=v+h
    if v+h<minvh:
        minvh=v+h;selected=shift
assert F(sumvh,L)==W,(sumvh,W)
assert minvh<=W
Srot=sorted((x+selected)%L for x in S)
low=[x for x in Srot if x<=J]
high=[x for x in Srot if x>=L-J]
# Independent literal collision count for each translation.
counts=[]
for T in I:
    ss=set(Srot)
    collisions=[]
    for a in A:
        for h in high:
            for i,j in combinations_with_replacement(low,2):
                if T==a+h-i-j:
                    collisions.append((h,i,j,a))
    counts.append((len(collisions),T,collisions))
cnt,T,triples=min(counts)
upper=F(comb(r,2),1)+F(r,len(I))*(F(2,27)*W**3+F(1,8)*W**2)
assert cnt <= F(r,len(I))*(F(2,27)*W**3+F(1,8)*W**2)
Sprime=set(Srot)
for h,i,j,a in triples:Sprime.discard(h)
# Remove a designated endpoint for each difference collision.
diffs={}
for x,y in combinations(Sprime,2):
    diffs.setdefault(x-y,set()).add((x,y))
# Rather than trust modular difference selection, derive literal remaining A+B collisions.
Rdiff=0
for x,y in combinations(sorted(Sprime),2):
    if any(x-y==d or y-x==d for d in {a-b for a,b in combinations(A,2)}):
        Sprime.discard(x)
        Rdiff+=1
# Above loop over snapshot can revisit removed mark; harmless check.
B=sorted(T+s for s in Sprime)
U=sorted(set(A)|set(B))
sums=[x+y for x,y in combinations_with_replacement(U,2)]
assert len(set(sums))==len(sums)
assert max(U)<=F(2,1)*L-delta*L/2
assert q-len(Sprime)<=upper

# Check exact asymptotic certificate at a spread of r.
for rr in (1,2,3,4,5,10,100,1000):
    coef=1-F(2,675*rr)
    denom=2-F(1,40*rr)
    gain=2*coef**2-denom
    check=F(71,5400*rr)+F(8,455625*rr*rr)
    assert gain==check and gain>0

print(json.dumps({'status':'PASS','q':q,'r':r,'field_generator':G,
 'modular_marks':len(S),'shift':selected,'endpoint_v_plus_h':minvh,
 'exact_mean_W':str(W),'T':T,'number_of_translations':len(I),
 'dangerous_triples':cnt,'difference_deletions':Rdiff,
 'final_size':len(U),'max_coordinate':max(U),
 'exact_deletion_bound':str(upper),
 'distinct_integer_sums':len(sums),
 'coefficient_identity':'PASS'},sort_keys=True))
