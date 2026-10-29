#!/usr/bin/env python3
"""Independent exact six-root walk/homology enumeration for cyclic K3,3 lifts."""
from collections import Counter
from hashlib import sha256
CHORD={(1,4):0,(1,5):1,(2,4):2,(2,5):3}
ADJ={v:tuple(range(3,6)) if v<3 else tuple(range(3)) for v in range(6)}
TARGET={4,6,8,10,12,16}
def increment(u,v):
    sign=1
    if u>v:u,v=v,u;sign=-1
    out=[0]*4
    if (u,v) in CHORD:out[CHORD[(u,v)]]=sign
    return tuple(out)
VOLT={(u,v):increment(u,v) for u in ADJ for v in ADJ[u]}
COUNTS=Counter();ZEROS=Counter();vecs={n:set() for n in TARGET};witness12=None
def enumeration():
    global witness12
    def search(start,walk,total):
        global witness12
        length=len(walk)-1;u=walk[-1]
        if length in TARGET and u==start and walk[1]!=walk[-2]:
            COUNTS[length]+=1
            if total==(0,0,0,0):
                ZEROS[length]+=1
                if length==12 and witness12 is None:
                    fiber=0;seen=set();good=True
                    for a,b in zip(walk,walk[1:]):
                        pt=(a,fiber)
                        if pt in seen:good=False;break
                        seen.add(pt)
                        fiber+=sum(VOLT[(a,b)][i]*5**i for i in range(4))
                    if good and fiber==0:witness12=tuple(walk)
            else:vecs[length].add(total)
        if length>=16:return
        for v in ADJ[u]:
            if length and v==walk[-2]:continue
            d=VOLT[(u,v)]
            search(start,walk+[v],tuple(total[i]+d[i] for i in range(4)))
    for root in range(6):search(root,[root],(0,0,0,0))
enumeration()
assert dict(COUNTS)=={4:72,6:72,8:648,10:1800,12:8712,16:133128}
assert ZEROS=={12:144},ZEROS
assert witness12==tuple(map(int,'0314051304150'))
assert [len(vecs[n]) for n in (4,6,8,10,12,16)]==[18,12,90,120,402,1242]
S=set().union(*(vecs[n] for n in (4,6,8,10,16)))
values={sum(c[i]*5**i for i in range(4)) for c in S}
assert 0 not in values and max(map(abs,values))==500
assert max(abs(c) for v in S for c in v)<=8
print('PASS: no cyclically reduced zero winding at C4,C6,C8,C10,C16')
print('PASS: integer voltage nonzero, absolute value <=500 for all tested vectors')
print('PASS: C12 witness', ''.join(map(str,witness12)))
print('PASS: first power-of-two cycle >=32 for all m>500, with explicit C32 in separate verifier')
print('VECTOR SHA256',sha256(('\n'.join(','.join(map(str,v)) for v in sorted(S))+'\n').encode()).hexdigest())
