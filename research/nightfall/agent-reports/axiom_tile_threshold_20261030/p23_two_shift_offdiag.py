#!/usr/bin/env python3
"""Exact restricted pair-sum audit for p23 axis rectangle + 2 shifts."""
from collections import Counter
P=23;Q=P*P
def add(a,b):return ((a%P+b%P)%P)+P*((a//P+b//P)%P)
def sub(a,b):return ((a%P-b%P)%P)+P*((a//P-b//P)%P)
for nx,ny,expected in ((8,8,12800),(16,4,21160),(4,16,21160)):
    base=[x+P*y for x in range(nx) for y in range(ny)]
    bc=Counter(add(x,y) for x in base for y in base)
    tile=[sum(1<<add(z,a) for a in base) for z in range(Q)]
    corners=[m for m in range(Q) if bc[m]==1]
    valid=0;unique=0
    for v in range(1,Q):
        vv=add(v,v)
        for w in range(v+1,Q):
            vw=add(v,w);ww=add(w,w)
            if (tile[0]|tile[v]|tile[w]|tile[vw]).bit_count()!=256:continue
            valid+=1
            shifts=(0,v,w,vv,vw,ww,add(vv,w),add(v,ww),add(vv,ww))
            coeffs=(1,2,2,1,4,1,2,2,1)
            extremes=(0,vv,ww,shifts[-1])
            # An ordered pair sum represented exactly once must be a
            # base sum with multiplicity 1 and a shift pair with weight 1.
            candidates={add(z,t) for z in extremes for t in corners}
            for m in candidates:
                count=0
                for sh,c in zip(shifts,coeffs):
                    count+=c*bc.get(sub(m,sh),0)
                    if count>=2:break
                if count==1:
                    unique+=1
                    raise AssertionError(("restricted sumset hole",nx,ny,v,w,m))
    assert valid==expected,(nx,ny,valid,expected)
    print("PASS",nx,ny,"valid",valid,"unique-ordered-sum-candidates",unique)
print("No restricted pair-sum holes in the three axis-rectangle/two-shift families.")
