#!/usr/bin/env python3
"""PR #279: exact decoder replay + support-stratified pseudorandom QA.

The probability bounds below apply only under an ideal independent-uniform
sampling model. Python's fixed-seed PRNG makes this run reproducible, but
does not itself certify statistical independence or a formal confidence level.
No sampling outcome proves a universally quantified theorem.
"""
from itertools import product
from math import log, sqrt
from random import Random
from hashlib import sha256

P,D,K,N,SEED=53,16,11,2000,27920261031
DELTA=2  # a nonsquare in F53
assert pow(DELTA,(P-1)//2,P)==P-1
Q=P*P
def add(x,y):return ((x%P+y%P)%P)+P*((x//P+y//P)%P)
def mul(x,y):
 a,b=x%P,x//P;c,d=y%P,y//P
 return ((a*c+DELTA*b*d)%P)+P*((a*d+b*c)%P)
def neg(x):return ((-x%P)+P*((-(x//P))%P))
def sq(x):return mul(x,x)
def pow_field(x,n):
 r=1
 while n:
  if n&1:r=mul(r,x)
  x=mul(x,x);n//=2
 return r
def scale(x,c):return ((x%P*c)%P)+P*(((x//P)*c)%P)

W=[1<<i for i in range(4)]+[P*(1<<i) for i in range(4)]+[D+P*(D//2),D+P*(P-D//2)]
assert len(W)==10
m=(4*D-P-1)+P*(5*D//2-1)
c=scale(neg(m),pow(2,-1,P))
a=[scale(w,pow(2,-1,P)) for w in W]
a0=c
for z in a:a0=add(a0,z)

# Independently verify the complete 1024-word exact sign code and its hole.
T={0}
for w in W:T=T|{add(z,w) for z in T}
assert len(T)==1024
assert m not in {add(u,v) for u in T for v in T}
full={}
for signs in product((1,-1),repeat=10):
 z=a0
 for coeff,sgn in zip(a,signs):
  z=add(z,coeff if sgn==1 else neg(coeff))
 y=sq(z)
 assert y not in full
 full[y]=signs
assert len(full)==1024

# Exact inverse tables for all 1..10 relative-sign block lengths.
lookups={}
for b in range(1,11):
 fixed=a0
 for coeff in a[b:]:fixed=add(fixed,coeff)
 lut={}
 for signs in product((1,-1),repeat=b):
  z=fixed
  for coeff,sgn in zip(a[:b],signs):
   z=add(z,coeff if sgn==1 else neg(coeff))
  y=sq(z)
  assert y not in lut
  lut[y]=signs
 lookups[b]=(fixed,lut)
roots={}
for x in range(Q):roots.setdefault(sq(x),x)
assert len(roots)==(Q+1)//2
invs={x:pow_field(x,Q-2) for x in range(1,Q)}
assert all(mul(x,invs[x])==1 for x in range(1,Q))

def decode(x):
 k=len(x);read=[sq(z) for z in x]
 support=[i for i,y in enumerate(read) if y]
 if not support:return (0,)*k,k
 reps={i:roots[read[i]] for i in support}
 anchor=support[0];out=[0]*k;out[anchor]=reps[anchor]
 for j in range(1,len(support),10):
  block=support[j:j+10];fixed,lut=lookups[len(block)]
  z=mul(fixed,mul(x[anchor],invs[reps[anchor]]))
  for i,coeff in zip(block,a):
   z=add(z,mul(coeff,mul(x[i],invs[reps[i]])))
  signs=lut[sq(z)]
  for i,sgn in zip(block,signs):
   out[i]=reps[i] if sgn==1 else neg(reps[i])
 assert tuple(out)==tuple(x) or tuple(out)==tuple(neg(t) for t in x)
 return tuple(out),k+(len(support)-1+9)//10

rng=Random(SEED);records=[]
for s in range(K+1):
 failures=0
 for _ in range(N):
  x=[0]*K
  for i in rng.sample(range(K),s):x[i]=rng.randrange(1,Q)
  try:
   _,queries=decode(tuple(x))
   if queries!=K+((s-1+9)//10 if s else 0):failures+=1
  except (AssertionError,KeyError):failures+=1
 records.append((s,failures))
 assert failures==0,(s,failures)

alpha=.01;S=K+1
hoeffding=sqrt(log(S/alpha)/(2*N))
exact_zero=1-(alpha/S)**(1/N)
transcript='\n'.join(f'{s},{f},{N}' for s,f in records)+'\n'
print('MODEL GF(53^2), p=53, k=11, b=10')
print('EXACT 1024 squared words, 10 shorter block tables, sumset hole: PASS')
print('SAMPLED 12 support strata x 2000 fixed-seed pseudorandom signals')
print('FAILURES',sum(f for s,f in records))
print('CONDITIONAL_HOEFFDING_FAMILYWISE_99PCT',format(hoeffding,'.9f'))
print('CONDITIONAL_EXACT_BINOMIAL_FAMILYWISE_99PCT',format(exact_zero,'.9f'))
print('TRANSCRIPT_SHA256',sha256(transcript.encode()).hexdigest())
print('STATUS: implementation audit only; no universal or priority certificate')
