#!/usr/bin/env python3
"""Exact Singer 1009 finite example: source, rotation, repair and final sums."""
from collections import defaultdict,Counter
from math import comb,isqrt
p=1009;v=p*p+p+1;A=(1,2,4,8,13)
assert all(p%d for d in range(2,isqrt(p)+1))
assert all((x**3+2)%p for x in range(p))
state=(1,0,0);D=[]
for i in range(v):
    if state[2]==0:D.append(i)
    a,b,c=state
    state=((2*a-2*c)%p,(a+2*b)%p,(b+2*c)%p)
assert state[1:]==(0,0) and len(D)==1010
used=bytearray(v)
for i,a in enumerate(D):
    for b in D[:i]:
        t=(a-b)%v
        assert 0<t<v and not used[t] and not used[v-t]
        used[t]=used[v-t]=1
assert sum(used)==v-1
h=int(v/(16*len(A)));L=h+max(A)+1
diff=[0]*(v+1)
def cover(a,b):
    a%=v;b%=v
    if a<=b:diff[a]+=1;diff[b+1]-=1
    else:
        diff[0]+=1;diff[b+1]-=1;diff[a]+=1;diff[v]-=1
for d in D:
    cover(-d,L-1-d)
    cover(v-L-d,v-1-d)
current=0;integral=0;minimum=(3000,-1)
for shift in range(v):
    current+=diff[shift]
    integral+=current
    if current<minimum[0]:minimum=(current,shift)
assert integral==2*len(D)*L
C,shift=minimum
Q=sorted((d+shift)%v for d in D)
low=[x for x in Q if x<L]; high=[x for x in Q if x>=v-L]
assert C==len(low)+len(high)==8
lo=v-h;hi=v-(h+1)//2
triple=Counter()
for a in A:
    for i,x in enumerate(low):
        for y in low[i:]:
            for z in high:
                t=a+z-x-y
                if lo<=t<=hi:triple[t]+=1
T=min(range(lo,hi+1),key=lambda t:triple[t])
R=2*len(D)*L/v
E=len(A)*((2/27)*R**3+(1/8)*R**2)/(hi-lo+1)
assert triple[T]<=int(E)
F=list(A)+[T+x for x in Q]
pair_sums=defaultdict(list)
for i,a in enumerate(F):
    for j in range(i,len(F)):pair_sums[a+F[j]].append((i,j))
collisions=[v for v in pair_sums.values() if len(v)>1]
assert len(collisions)==10 and triple[T]==0
removed=set()
for reps in collisions:
    assert len(reps)==2
    removed.add(next(j-len(A) for i,j in reps if j>=len(A)))
result=sorted(list(A)+[T+x for i,x in enumerate(Q) if i not in removed])
assert len(result)==1005 and result[-1]==2024920
sums=set()
for i,a in enumerate(result):
    for b in result[i:]:
        assert a+b not in sums
        sums.add(a+b)
assert len(sums)==comb(1006,2)==505515
print('PASS q=1009 Singer 1010, differences',sum(used))
print('PASS rotation',shift,'boundary',C,'translation',T)
print('PASS repaired',len(result),'endpoint',result[-1],'sums',len(sums))
