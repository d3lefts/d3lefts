#!/usr/bin/env python3
"""Independent F25 orbit audit in the alternate irreducible model v²=3."""
from itertools import product

q=25

def add(a,b):return ((a%5+b%5)%5) + 5*((a//5+b//5)%5)
def neg(a):return (-(a%5))%5 + 5*((-(a//5))%5)
def mul(a,b):
  a0,a1=a%5,a//5;b0,b1=b%5,b//5
  return (a0*b0+3*a1*b1)%5+5*((a0*b1+a1*b0)%5)
def power(a,n):
  x=1
  for _ in range(n):x=mul(x,a)
  return x

def scale(v,s):return tuple(mul(t,s) for t in v)
def det(x,y):return add(mul(x[0],y[1]),neg(mul(x[1],y[0])))

def canon(v):return min(scale(v,s) for s in range(1,5))

# Irreducibility: 3 is nonsquare in F5; products give field inverses.
assert {i*i%5 for i in range(5)}=={0,1,4}
assert all(any(mul(a,b)==1 for b in range(1,25)) for a in range(1,25))
assert {a for a in range(1,25) if power(a,4)==1}=={1,2,3,4}
rows=sum(power(a,4)==power(b,4) for a in range(25) for b in range(25))
assert rows==97

# k=1: independent pair set empty, six nonzero phase orbits.
assert len({min(mul(a,s) for s in range(1,5)) for a in range(1,25)})==6

all_vectors=list(product(range(25),repeat=2))
nonzero=[x for x in all_vectors if x!=(0,0)]
reps=sorted({canon(x) for x in nonzero})
assert len(reps)==156
for x in nonzero:
 assert len({scale(x,s) for s in range(1,5)})==4

ordered=0;unordered=0;failed=0
for x in reps:
 for y in reps:
  if det(x,y)==0:continue
  ordered+=1
  if x>=y:continue
  unordered+=1
  # Full group G=(F5* × F5*) semidirect swap, order 32.
  orbit={pair for s in range(1,5) for t in range(1,5)
         for pair in ((scale(x,s),scale(y,t)),(scale(y,t),scale(x,s)))}
  assert len(orbit)==32,(x,y,len(orbit))
assert ordered==156*150==23400
assert unordered==11700
assert unordered*32==(625-1)*(625-25)
assert ((625-1)*(625-25))//32==11700
print({'status':'PASS','field':'F5[v]/(v^2-3)','collision_pairs':rows,'k1_nonzero_orbits':6,'k2_phase_orbits':156,'ordered_independent_phase_orbit_pairs':23400,'unordered_independent_orbit_pairs':11700,'free_action_tests':11700,'raw_independent_pairs':374400})
