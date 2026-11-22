#!/usr/bin/env python3
"""Exact finite c_h sum and outward-rounded twin-prime product certificate."""
from pathlib import Path
from decimal import Decimal, localcontext, ROUND_FLOOR
from fractions import Fraction
from math import isqrt
import json
D=Path(__file__).parent
x={int(h):int(v) for h,v in json.loads((D/'results.json').read_text())['counts'].items()}
assert sorted(x)==list(range(4,83,2))
S=Fraction(0)
primes=[]
for n in range(3,83,2):
 if all(n%p for p in range(3,isqrt(n)+1,2)):
  primes.append(n)
for h,v in sorted(x.items()):
 denom=1
 for q in primes:
  if q>=h:break
  denom*=q-2
 S+=Fraction(v,denom)
assert S==Fraction(178998434470844807631353017,86203290204933715490551875)
B=10_000_000
a=bytearray(b'\x01')*(B+1);a[:2]=b'\x00\x00'
for p in range(2,isqrt(B)+1):
 if a[p]:a[p*p::p]=b'\x00'*(((B-p*p)//p)+1)
with localcontext() as C:
 C.prec=48;C.rounding=ROUND_FLOOR
 PB=Decimal(1);count=0
 for p in range(3,B+1,2):
  if a[p]:
   d=p-1
   PB*=Decimal(d*d-1)/Decimal(d*d);count+=1
 # For omitted primes p>B, Euler factors dominate all integers k>=B.
 # Product_(k>=B)(1-k^(-2)) = (B-1)/B.
 S_floor=Decimal(S.numerator)/Decimal(S.denominator)
 c_lower=Decimal(2)*S_floor*PB*(Decimal(B-1)/Decimal(B))
 print('Exact rational S_82 =',S)
 print('Decimal finite sum =',S_floor)
 print('Included odd primes up to',B,':',count)
 print('Rigorous directed-rounded lower for c =',c_lower)
 assert c_lower>Decimal('2.7416104')
 print('PASS: arithmetic constant lower bound c > 2.7416104')
 print('NOTE: asymptotic frangible prime-gap interpretation is conditional on prime tuples.')
