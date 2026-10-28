#!/usr/bin/env python3
"""Self-contained standard-library exact verification of NIGHTFALL 094."""
from pathlib import Path
from fractions import Fraction
from hashlib import sha256
from decimal import Decimal,localcontext
import json
P=Path(__file__).resolve().parent;N=65536;H=32768;D=1<<70;BITS=160
c=json.loads((P/'certificate.json').read_text());raw=(P/'heights_u70.txt').read_bytes();a=list(map(int,raw.split()))
assert len(a)==N and min(a)>=0 and max(a)<=D and sum(a)==H*D
assert sha256(raw).hexdigest()==c['heights_sha256']
assert int(c['n'])==N and int(c['width_denominator'])==H and int(c['height_denominator'])==D
print('PASS exact mass, box constraints, 65,536 rational heights, SHA-256',flush=True)
# Packed integer polynomial multiplication is EXACT since N*D**2 < 2**160.
# Fixed-width bytes avoid quadratic-time repeated left/right big-integer shifts.
def conv(u,v):
 def packed(w):return int.from_bytes(b''.join(int(t).to_bytes(20,'little') for t in w),'little')
 n=len(u)+len(v)-1
 product=packed(u)*packed(v)
 raw=product.to_bytes(n*20,'little')
 return [int.from_bytes(raw[i*20:(i+1)*20],'little') for i in range(n)]
s=[0]+conv(a,[D-v for v in a[::-1]])+[0]
assert len(s)==2*N+1
mx=max(s);lags=[i-N for i,v in enumerate(s) if v==mx]
score=Fraction(mx,H*D*D);parent=Fraction(c['parent_score_fraction'])
assert score==Fraction(c['score_fraction']) and lags==c['maximizing_lags']
assert score<parent and parent-score==Fraction(c['improvement_fraction'])
print('PASS all 131,073 signed grid events, unique maximizing shift, strict improvement',flush=True)
pre=[0]
for v in a:pre.append(pre[-1]+v)
auto=[0]+conv(a,a[::-1])+[0]
for k in range(N+1):
 assert s[N+k]==D*(pre[N]-pre[k])-auto[N+k]
 assert s[N-k]==D*pre[N-k]-auto[N+k]
print('PASS all 131,074 boundary/autocorrelation identities',flush=True)
for k in sorted(set(lags+[-N,-N//2,-1,0,1,N//2,N])):
 direct=sum(a[i]*(D-a[i-k]) for i in range(max(0,k),min(N,N+k)))
 assert direct==s[N+k]
print('PASS independent direct summations at selected signed grid shifts',flush=True)
if (P/'pairs_decimal.txt').exists():
 with (P/'pairs_decimal.txt').open() as f:
  count=0
  for count,line in enumerate(f,1):
   lo,mid,hi=map(int,line.split())
   assert lo+(mid<<36)+(hi<<72)==s[count-1],count
  assert count==2*N+1
 print('PASS independent C++ 4,294,967,296 ordered-pair table',flush=True)
with localcontext() as ctx:
 ctx.prec=85
 print('EXACT_FRACTION',score,flush=True)
 print('UPPER_BOUND',Decimal(score.numerator)/Decimal(score.denominator),flush=True)
 delta=parent-score
 print('GAIN_OVER_093',Decimal(delta.numerator)/Decimal(delta.denominator),flush=True)
 print('MAXIMIZING_SHIFT',lags[0], '/',H,flush=True)