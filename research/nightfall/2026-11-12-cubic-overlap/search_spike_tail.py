from fractions import Fraction as F
from itertools import product
from random import Random
rng=Random(131119)
ps=[F(1,2),F(1,3),F(1,8),F(1,32)]
T=0; best=(F(0),None)
for it in range(1600):
  na,nb,nc=2,2,2
  p=[rng.choice(ps) for _ in range(nb+nc)]
  co=[[[rng.randint(-3,3) for c in range(nc)] for b in range(nb)] for a in range(na)]
  if all(not t for a in co for b in a for t in b):continue
  v=[F(0)]*na; q4=[F(0)]*na; B=F(0)
  states=[]
  for bits in product((0,1),repeat=nb+nc):
    x=[F(bits[j])-p[j] for j in range(nb+nc)]
    prob=F(1)
    for j,b in enumerate(bits):prob*=p[j] if b else 1-p[j]
    z=[sum((F(co[a][j][k])*x[j]*x[nb+k] for j in range(nb) for k in range(nc)),F(0)) for a in range(na)]
    B=max(B,sum(map(abs,z)))
    for a in range(na):
      v[a]+=prob*z[a]**2;q4[a]+=prob*z[a]**4
  if B==0: continue
  ib=[sum((F(co[a][j][k])**2*p[j]*(1-p[j])*p[nb+k]*(1-p[nb+k]) for a in range(na) for k in range(nc)), F(0)) for j in range(nb)]
  ic=[sum((F(co[a][j][k])**2*p[j]*(1-p[j])*p[nb+k]*(1-p[nb+k]) for a in range(na) for j in range(nb)), F(0)) for k in range(nc)]
  M=max(v+ib+ic)
  if M==0:continue
  V=sum(v)
  bad=sum((v[a] for a in range(na) if v[a]>0 and q4[a]>3*v[a]**2),F(0))
  ratio2=bad**2/(B**2*M)
  if ratio2>best[0]:best=(ratio2,dict(p=list(map(str,p)),coeff=co,B=str(B),M=str(M),V=str(V),v=list(map(str,v)),kappa=[str(q4[a]/v[a]**2) if v[a] else None for a in range(na)]))
  T+=1
print('EXACT SEARCH 2 A fair-sign fibers, 2 B +2 C skew signs:',T,'cases')
print('max [Wspike(3)/(B sqrt M)]² =',best[0], 'approx',float(best[0])**.5)
print('witness',best[1])
print('STATUS: cannot certify any universal C from finite tests')
# Direct independent 64-state verification of the saved best example, no coefficient-energy identities.
from itertools import product as cart
p0=[F(s) for s in best[1]['p']]
cc=best[1]['coeff']
dom=[(-1,1)]*2+[(0,1)]*4
marg=[{-1:F(1,2),1:F(1,2)}]*2+[{0:1-pj,1:pj} for pj in p0]
rows=[]
for s in cart(*dom):
    pr=F(1)
    for j,x in enumerate(s):pr*=marg[j][x]
    val=sum((F(s[a])*cc[a][j][k]*(F(s[2+j])-p0[j])*(F(s[4+k])-p0[2+k]) for a in range(2) for j in range(2) for k in range(2)),F(0))
    rows.append((s,pr,val))
mu=sum((pr*z for s,pr,z in rows),F(0))
Vdirect=sum((pr*(z-mu)**2 for s,pr,z in rows),F(0))
Idirect=[]
for j in range(6):
    d={}
    for s,pr,z in rows:
        key=s[:j]+s[j+1:]
        x,y=d.get(key,(F(0),F(0)))
        d[key]=(x+pr*z,y+pr)
    Idirect.append(sum((pr*z*z for s,pr,z in rows),F(0))-sum((u*u/w for u,w in d.values()),F(0)))
assert mu==0 and Vdirect==F(best[1]['V'])
assert max(Idirect)==F(best[1]['M'])
assert max(abs(z) for s,pr,z in rows)==F(best[1]['B'])
print('INDEPENDENT 64-state witness replay: B, V and all six influences exact PASS:',*[str(x) for x in Idirect])
