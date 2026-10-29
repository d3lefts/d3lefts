import itertools,time,sys,json,hashlib
import numpy as np
# Independent F25 arithmetic and phase geometry, no NIGHTFALL imports
mu=[1,2,3,4]
def p4(a):
 def m(a,b):return ((a%5*(b%5)+2*(a//5)*(b//5))%5)+5*((a%5*(b//5)+(a//5)*(b%5))%5)
 return m(m(a,a),m(a,a))
pi=[p4(a) for a in range(25)]
lookup={v:i for i,v in enumerate(sorted(set(pi)))}
G=np.array([lookup[v] for v in pi],dtype=np.uint8)
phase=np.array(list(itertools.product(mu,repeat=4)),dtype=np.int16)
X=np.concatenate((np.ones((256,1),dtype=np.int16),phase),axis=1)
ROWS=[]
for j in range(5):
 r=np.array(list(itertools.product(range(25),repeat=4-j)),dtype=np.uint8)
 b=np.zeros((len(r),5),dtype=np.uint8)
 b[:,j]=1
 if j<4:b[:,j+1:]=r
 ROWS.append(b)
ROWS=np.vstack(ROWS)
assert len(ROWS)==406901

def resp(row,P=X):
 R=np.array(row,dtype=np.int16)
 return G[((P @ (R%5))%5)+5*((P @ (R//5))%5)]

def dir_enc(p,q):
 v=((q[1:].astype(int)-p[1:].astype(int))%5)
 lead=next(int(x) for x in v if x!=0)
 inv=[0,1,3,2,4][lead]
 a=[int(z)*inv%5 for z in v]
 return a[0]+5*a[1]+25*a[2]+125*a[3]

def all_7_bad(S,group):
 # Return true if all p in a seven-point subset have a repeated slope to the other six points.
 for p in group:
  dirs=[S[p,q] for q in group if q!=p]
  if len(set(dirs))==6:return False
 return True

def classify(first,output,verbose=True):
 allids=np.flatnonzero(resp(first)==output); B=X[allids]
 dmat=np.full((len(B),len(B)),65535,dtype=np.int32)
 for i in range(len(B)):
  for j in range(i+1,len(B)):
   dmat[i,j]=dmat[j,i]=dir_enc(B[i],B[j])
 good=0;starbad=0;harder=0;small=0;minmax=100;witness=None;total=0; t=time.time()
 for off in range(0,len(ROWS),2000):
  R=ROWS[off:off+2000].astype(np.int16)
  z=G[(R%5)@B.T%5+5*((R//5)@B.T%5)]
  cnt=np.stack([(z==c).sum(1) for c in range(7)],axis=1)
  maxima=cnt.max(1)
  minmax=min(minmax,int(min(maxima)))
  # Rows failing with >=8 are rejected by the seven-output capacity of last query.
  ix=np.flatnonzero(maxima<=7)
  good+=len(ix);total+=len(R)
  for j in ix:
   groups=[np.flatnonzero(z[j]==c) for c in range(7)]
   seven=[g for g in groups if len(g)==7]
   if not seven:
    small+=1;witness=off+int(j);continue
   if any(all_7_bad(dmat,g) for g in seven):starbad+=1
   else:
    harder+=1;witness=off+int(j)
 if verbose:print('first',first,'output',output,'size',len(B),'all',total,'minmax',minmax,'good',good,'starbad',starbad,'remaining_not_excluded',harder+small,'harder',harder,'no_7group',small,'seconds',round(time.time()-t,2),'row',witness,flush=True)
 return {'first':first,'output':int(output),'fiber':len(B),'second_rows':total,'good_second':good,'seven_collinearity_obstructed':starbad,'unexcluded_second':harder+small,'without_seven_group':small,'remaining_with_seven':harder,'minmax':minmax,'witness_index':witness}

firsts={
  'A':[1,1,6,6,11],
  'B':[1,1,6,6,0],
  'C':[1,1,6,11,16],
  'D':[1,6,11,16,21],
  'E':[1,6,11,16,0],
  'F':[1,6,11,0,0],
}
results=[]
for name,first in firsts.items():
 y=resp(first);c=np.bincount(y,minlength=7);v=(2 if name=="C" else int(np.argmax(c)))
 results.append({'orbit':name,**classify(first,v)})
print(json.dumps(results,indent=2))
open('/mnt/data/f25_k5_first_orbit_obstruction.json','w').write(json.dumps(results,indent=2))
