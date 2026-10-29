#!/usr/bin/env python3
"""Lemnis independent finite-field window proof attack: no import from Ryev/Axiom.
Find a separate Bose--Chowla source over F101^2, prove the endpoint-band rules by
literal collision classification, and check the exact deletion bound.
"""
from fractions import Fraction as F
from math import prod
from itertools import combinations
from collections import defaultdict

q=101; order=q*q-1; prefix=(1,2,4,8,13); r=len(prefix)
alpha=F(3,64*r);beta=F(1,32*r)
J=-( -(alpha*order).numerator//(alpha*order).denominator )+max(prefix)+2
lo=-(-((1-alpha)*order).numerator//((1-alpha)*order).denominator)
hi=((1-beta)*order).numerator//((1-beta)*order).denominator
W=F(q*(2*J+1),order)
BUDGET=F(r*(r-1),2)+F(r,hi-lo+1)*(F(2,27)*W**3+F(1,8)*W**2)
assert (lo,hi,J)==(10105,10136,111)
assert 10 < BUDGET < 11

def mul(x,y,d):
 a,b=x;c,e=y
 return ((a*c+b*e*d)%q,(a*e+b*c)%q)

def power(x,n,d):
 out=(1,0)
 while n:
  if n&1:out=mul(out,x,d)
  x=mul(x,x,d);n//=2
 return out

def primitive_source():
 for d in range(2,q):
  if pow(d,(q-1)//2,q)!=q-1:continue
  for a in range(q):
   for b in range(1,q):
    theta=(a,b)
    if all(power(theta,order//p,d)!=(1,0) for p in (2,3,5,17)):
     x=(1,0);S=[]
     for k in range(order):
      if x[1]==1:S.append(k)
      x=mul(x,theta,d)
     assert x==(1,0) and len(S)==q
     return d,theta,S
 raise RuntimeError('primitive element missing')

def unique_sums(values,mod=None):
 seen={}
 for i,x in enumerate(values):
  for y in values[i:]:
   z=x+y if mod is None else (x+y)%mod
   if z in seen:return False, (seen[z],(x,y),z)
   seen[z]=(x,y)
 return True,seen

d,theta,source=primitive_source()
assert unique_sums(source,order)[0]
print('alternate source F101[t]/(t²-%d) theta=%s, %d unique modular sums'%(d,theta,q*(q+1)//2))
# Independently recompute the minimum endpoint occupancy by literal translation, no sliding window.
best=None
for rotation in range(order):
 shifted=sorted((s+rotation)%order for s in source)
 low=[z for z in shifted if z<=J]
 high=[z for z in shifted if z>=order-J]
 val=(len(low)+len(high),len(high),rotation)
 if best is None or val<best[0]:best=(val,shifted,low,high)
(vh,h,rotation),V,low,high=best
assert vh<=W, (vh,W)
print('min rotation',rotation,'low/high',len(low),len(high),'W',W)
# For every translation all A+B vs B+B clashes must fall in endpoint bands.
for T in range(lo,hi+1):
 B=[T+z for z in V]
 Vset=set(V)
 predicted=set()
 for aa in prefix:
  for z in high:
   for i,u in enumerate(low):
    for w in low[i:]:
     if aa+z==T+u+w:predicted.add((aa,z,u,w))
 actual=set()
 old_cross={aa+v for aa in prefix for v in B}
 block_sums={B[i]+w for i in range(len(B)) for w in B[i:]}
 assert {aa+T+z for aa in prefix for z in V}&block_sums == {aa+T+z for aa,z,u,w in predicted}, (T,'band classification')
 # Verify the actual cross sum multiset has all equalities captured by low/high.
 for aa in prefix:
  for z in V:
   target=aa+T+z
   if target in block_sums:
    assert z in high and any(aa+z==T+u+w for i,u in enumerate(low) for w in low[i:])
 # Back out high positions to delete; then eliminate A+B internal repeat with old pair differences.
 removed={z for _,z,_,_ in predicted}
 survivors=[z for z in V if z not in removed]
 for aa in prefix:
  for bb in prefix:
   if aa>=bb: continue
   diff=bb-aa
   vals=set(survivors)
   for z in tuple(survivors):
    if z+diff in vals: removed.add(z)
 final=sorted(prefix+tuple(T+z for z in V if z not in removed))
 valid,pairs=unique_sums(final)
 assert valid, (T,pairs)
 assert len(removed)<=10,(T,len(removed))
 if T==lo:example=(T,len(removed),len(final),final[-1],len(pairs))
print('q101 each of 32 translations independently verified, first outcome',example,'exact deletion bound',BUDGET)
# Verify symbolic coefficient gain for r=1..20 with exact integer arithmetic.
for r0 in range(1,21):
 old=(1-F(2,675*r0))**2/(2-F(1,40*r0))
 new=(1-F(1,256*r0))**2/(2-F(1,32*r0))
 assert new>old>F(1,2)
 print('r',r0,'gain-squared',new-old) if r0 in (1,5,20) else None
print('PASS independent geometry, mixed collision classes, ceil/floor and strict coefficient comparison')
