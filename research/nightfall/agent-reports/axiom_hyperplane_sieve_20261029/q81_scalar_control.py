#!/usr/bin/env python3
"""Independent q=81 scalar Gauss-fiber control for the uniform recovery theorem.
F81=F3[T]/(T^4+T^3+T^2+1), exact integer arithmetic.
"""
from collections import Counter
from itertools import product

def digits(a):return [(a//3**i)%3 for i in range(4)]
def encode(a):return sum((v%3)*3**i for i,v in enumerate(a))
def mul(a,b):
 x,y=digits(a),digits(b);c=[0]*7
 for i in range(4):
  for j in range(4):c[i+j]+=x[i]*y[j]
 for k in range(6,3,-1):
  v=c[k];c[k-1]-=v;c[k-2]-=v;c[k-4]-=v
 return encode(c[:4])
def power(a,n):
 z=1
 while n:
  if n&1:z=mul(z,a)
  a=mul(a,a);n//=2
 return z
def add(a,b):return encode([x+y for x,y in zip(digits(a),digits(b))])
def trace(a):
 s=0
 for i in range(4):s=add(s,power(a,3**i))
 assert digits(s)[1:]==[0,0,0]
 return s

def irreducible():
 # P(T)=T^4+T^3+T^2+1. For degree 4, test monic degree 1,2 divisors.
 P=[1,0,1,1,1]
 for degree in (1,2):
  for low in product(range(3),repeat=degree):
   divisor=list(low)+[1];rem=P[:]
   for k in range(4,degree-1,-1):
    v=rem[k]
    for j in range(degree+1):rem[k-degree+j]=(rem[k-degree+j]-v*divisor[j])%3
   if not any(rem[:degree]):return False
 return True

def run():
 assert irreducible()
 assert len({power(a,80) for a in range(1,81)})==1
 hist=Counter()
 for b in range(1,81):
  counts=[0,0,0]
  for t in range(81):
   v=trace(mul(b,mul(t,t)))
   counts[v]+=1
  assert sorted(counts) in ([21,30,30],[24,24,33])
  assert max(counts)<=33
  hist[tuple(counts)]+=1
 # Positive: 80 nonzero scalar projections of planar quadratic x^2.
 assert sum(hist.values())==80
 # Negative: Frobenius t^3 has zero polarization, so is not planar quadratic.
 assert all(power(add(t,h),3)==add(power(t,3),power(h,3)) for t in range(81) for h in range(81))
 print('q81_irreducible: PASS; 80 nonzero scalar projections; max_fiber=33')
 print('fiber_histogram:',sorted(hist.items()))
 print('additive_Frobenius_negative_control: PASS (polar rank zero)')
if __name__=='__main__':run()
