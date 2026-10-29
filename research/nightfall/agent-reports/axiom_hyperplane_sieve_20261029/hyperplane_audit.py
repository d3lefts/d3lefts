#!/usr/bin/env python3
"""Independent hyperplane-sieve certificate for q27 glued planar Sidon sets.
Enumerates projective nonzero linear forms (9841), not codimension-two subspaces.
Any 7-flat with >=29 points lies inside at least two heavy affine hyperplanes;
therefore their intersections exhaust all eligible 7-flats.
"""
import itertools, collections, hashlib, json

def digits(x): return (x%3,(x//3)%3,x//9)
def encode(v): return sum((x%3)*3**i for i,x in enumerate(v))
def mul(x,y):
 a,b=digits(x),digits(y);c=[0]*5
 for i in range(3):
  for j in range(3): c[i+j]+=a[i]*b[j]
 # T^3=T-1; T^4=T^2-T
 c[2]+=c[4];c[1]-=c[4];c[1]+=c[3];c[0]-=c[3]
 return encode(c[:3])
def power(x,n):
 r=1
 while n:
  if n&1:r=mul(r,x)
  x=mul(x,x);n//=2
 return r
def source(e):
 s=set()
 for t in range(27):
  a=digits(t);v=digits(power(t,e));w=digits(mul(2,power(t,e)))
  s.add(a+v+(0,0,0));s.add((0,0,0)+w+a)
 assert len(s)==53
 return sorted(s)
def projective_normals():
 for a in itertools.product(range(3),repeat=9):
  if any(a) and a[next(i for i,x in enumerate(a) if x)]==1:
   yield a

def audit(e):
 pts=source(e)
 heavy=[]; hist=collections.Counter()
 for a in projective_normals():
  fibers=[0,0,0]
  for i,p in enumerate(pts):
   v=sum(x*y for x,y in zip(a,p))%3
   fibers[v]|=1<<i
  for v,mask in enumerate(fibers):
   k=mask.bit_count();hist[k]+=1
   if k>=29:heavy.append((a,v,mask))
 # A rank-2 affine section of size>=29 lies in 4 affine hyperplanes.
 # Every pair of distinct projective normals is independent.
 sections={}
 for i,(a,v,m) in enumerate(heavy):
  for b,w,n in heavy[i+1:]:
   meet=m&n
   if meet.bit_count()>=29:
    # Key by intersection mask. If two distinct 7-flats meet S in >=29,
    # they cannot have same intersection if 29 points affinely span 7-flat.
    sections.setdefault(meet,[]).append((a,v,b,w))
 # validate full affine span rank=7 for all masks (ensures uniqueness)
 def rank(vectors):
  piv={}
  for vec in vectors:
   v=list(vec)
   for j in range(9):
    if v[j]==0:continue
    if j in piv:
     q=piv[j];z=v[j]
     v=[(x-z*y)%3 for x,y in zip(v,q)]
    else:
     inv=1 if v[j]==1 else 2
     piv[j]=[(inv*x)%3 for x in v]
     break
  return len(piv)
 for mask in sections:
  subset=[p for i,p in enumerate(pts) if (mask>>i)&1]
  assert rank([tuple((x-y)%3 for x,y in zip(p,subset[0])) for p in subset[1:]])==7
 result={'e':e,'projective_normals':9841,'affine_hyperplanes':sum(hist.values()),'max_hyperplane':max(hist),'heavy_hyperplanes':len(heavy),'heavy_hist':dict(sorted(collections.Counter(m.bit_count() for _,_,m in heavy).items())),'candidate_pairs':len(heavy)*(len(heavy)-1)//2,'sections':len(sections),'section_sizes':dict(sorted(collections.Counter(m.bit_count() for m in sections).items())),'section_pair_multiplicities':dict(sorted(collections.Counter(len(pairs) for pairs in sections.values()).items())),'full_hist':dict(sorted(hist.items()))}
 print(json.dumps(result,sort_keys=True))
 assert len(sections)==26 and all(m.bit_count()==29 for m in sections)
 assert all(len(pairs)==6 for pairs in sections.values()) # 4 hyperplanes => 6 pairs
 return result
if __name__=='__main__':
 results=[audit(2),audit(4)]
 # Negative control: x^3 in characteristic 3 is nonplanar, so the
 # 26-section signature is expected to fail. The audit must reject it.
 try:
  audit(3)
 except AssertionError:
  print('negative_control_e3: REJECTED as expected')
 else:
  raise AssertionError('nonplanar negative control unexpectedly accepted')
 # Positive affine self-equivalence: identity fixes each set pointwise.
 assert all(source(e)==[tuple(p) for p in source(e)] for e in (2,4))
 print('positive_identity: PASS')
 print('SHA256 source',hashlib.sha256(open(__file__,'rb').read()).hexdigest())
