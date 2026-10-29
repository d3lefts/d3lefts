from collections import Counter
from itertools import product
W={(1,4):1,(1,5):5,(2,4):17,(2,5):64}
CH=list(W)
ADJ={i:tuple(range(3,6)) if i<3 else tuple(range(3)) for i in range(6)}
W32='03140523041325140314031403140314'

def dw(u,v):
    a,b=sorted((u,v));return (1 if u<3 else -1)*W.get((a,b),0)

def enumerate_w(n):
  out=[]
  def rec(path,z):
    l=len(path)-1;cur=path[-1];root=path[0]
    if l==n:
        if cur==root and path[1]!=path[-2] and z%147==0:out.append(tuple(path))
        return
    for y in ADJ[cur]:
        if len(path)>1 and y==path[-2]:continue
        rec(path+[y],z+dw(cur,y))
  for i in range(6):rec([i],0)
  return out
cycles12=enumerate_w(12)
cycles14=enumerate_w(14)
print("zero cyclic quotient length14 words",len(cycles14))
print('zero cyclic quotient length12 words',len(cycles12))

for d in (2,3):
  mod=0b111 if d==2 else 0b1011
  n=2**d
  def mul(a,b):
    c=0
    while b:
        if b&1:c^=a
        b>>=1;a<<=1
        if a&(1<<d):a^=mod
    return c
  def act(power,a):
    fac=1
    for _ in range(power%(n-1)):fac=mul(fac,2)
    return mul(fac,a)
  def eval_path(word,labels):
    z=0;v=0
    for u,vv in zip(word,word[1:]):
      if u<3:
        a=labels.get((u,vv),0);w=dw(u,vv);b=a
      else:
        a=labels.get((vv,u),0);w=dw(u,vv);b=act(w,a)
      v^=act(z,b);z+=w
    return z%147,v
  def eval_full(w,labels):
    seq=tuple(map(int,w));return eval_path(seq+(seq[0],),labels)
  # generate linear coefficient column signatures by testing each basis label independent
  steps=[]
  for w in cycles12:
    cols=tuple(eval_path(w,{e:1})[1] for e in CH)
    steps.append(cols)
  steps=list(set(steps))
  steps14=list(set(tuple(eval_path(w,{e:1})[1] for e in CH) for w in cycles14))
  print('d',d,'distinct linear12 constraints',len(steps),'all-zero',sum(all(v==0 for v in x) for x in steps))
  def term(cols,vec):
    return mul(cols[0],vec[0])^mul(cols[1],vec[1])^mul(cols[2],vec[2])^mul(cols[3],vec[3])
  pos32=tuple(eval_full(W32,{e:1})[1] for e in CH)
  print('32 columns',pos32)
  candidates=[]
  for a in product(range(n),repeat=4):
    if term(pos32,a)!=0:continue
    zeros=sum(term(c,a)==0 for c in steps)
    candidates.append((zeros,sum(term(c,a)==0 for c in steps14),a))
  candidates.sort()
  print('zero12-free C14 constraint distribution',{z:sum(c[0]==0 and c[1]==z for c in candidates) for z in sorted(set(c[1] for c in candidates if c[0]==0))});print('32 closing options',len(candidates),'zero12-free tuples',sum(c[0]==0 for c in candidates),'distribution', {k:sum(v[0]==k for v in candidates) for k in sorted(set(v[0] for v in candidates))},'minimum:',candidates[:10])

