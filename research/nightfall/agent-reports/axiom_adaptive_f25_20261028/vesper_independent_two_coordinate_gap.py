#!/usr/bin/env python3
"""Independent F25 fourth-power 2-coordinate phase-class verification.
Field: F5[u]/(u^2 - 2); theta=u. No imports from NIGHTFALL.
"""
from collections import defaultdict
from hashlib import sha256

F=range(25)
def tup(x): return (x%5,x//5)
def enc(a,b): return (a%5)+5*(b%5)
def plus(x,y):
 a,b=tup(x);c,d=tup(y);return enc(a+c,b+d)
def mult(x,y):
 a,b=tup(x);c,d=tup(y);return enc(a*c+2*b*d,a*d+b*c)
def pow4(x):
 x2=mult(x,x);return mult(x2,x2)
assert len({pow4(x) for x in F}) == 7
mu=[enc(a,0) for a in (1,2,3,4)]
assert all(pow4(z)==1 for z in mu)

def phase_class(x):
 return min(tuple(mult(z,y) for y in x) for z in mu)

def data(rows):
 mapping=defaultdict(set)
 for x in F:
  for y in F:
   xs=(x,y)
   out=tuple(pow4(plus(mult(a,x),mult(b,y))) for a,b in rows)
   mapping[out].add(phase_class(xs))
 bad={o:cs for o,cs in mapping.items() if len(cs)>1}
 return len(mapping),len(bad),len({phase_class((x,y)) for x in F for y in F})

r4=[(1,0),(0,1),(1,1),(1,5)]
r3=[(1,0),(0,1),(1,1)]
print('Fourth-power output alphabet:',len({pow4(x) for x in F}))
print('Phase classes of F25^2:',len({phase_class((x,y)) for x in F for y in F}))
print('Four static rows e1,e2,e1+e2,e1+u*e2:',data(r4))
print('Three static rows e1,e2,e1+e2:',data(r3))

# All third rows after an independent pair normalized to e1,e2.
# Any 3-row spanning design reduces to this coordinate form under a linear change of variables.
max_distinct = 0
best=[]
for a in F:
 for b in F:
  d,nb,nclass=data([(1,0),(0,1),(a,b)])
  if d>max_distinct: max_distinct=d;best=[(a,b)]
  elif d==max_distinct: best.append((a,b))
  if nb==0: raise AssertionError('Unexpected injective 3-row design')
print('All 625 normalized 3-row designs tested; max distinct transcripts:',max_distinct,
      '; examples:',best[:6],'; 157 needed')
# Lower-bound 7^m >= 1+(25^k-1)/4, k>=1
for k in range(1,9):
 targets=1+(25**k-1)//4
 m=0
 while 7**m<targets: m+=1
 print('k=',k, 'classes=',targets,'information_lower_bound=',m,'adaptive_upper_bound=',2*k-1)
