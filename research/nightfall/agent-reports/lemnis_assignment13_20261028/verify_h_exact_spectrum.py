#!/usr/bin/env python3
"""Independent exact coordinate audit of the input-sensitive leakage norm.
Enumerates all 729 source coordinate basis tensors and their full off-sector image.
"""
from fractions import Fraction as F
from itertools import product
from collections import Counter,defaultdict
W=list(product(range(3),repeat=4))
H=lambda x: ((x[2]-x[0]-x[1])%3,(x[3]-x[0]-2*x[1])%3)
R=[a for a in W if H(a)[1]==0]; S=[b for b in W if H(b)[0]==0]
assert len(R)==len(S)==27
counts=Counter();n=0
for a in R:
    for b in S:
        diag=[j for j in range(4) if a[j]==b[j]]
        coeff=defaultdict(F)
        for vs in product(range(3),repeat=len(diag)):
            ar=list(a);br=list(b); v=F(1)
            for j,z in zip(diag,vs):
                ar[j]=br[j]=z
                v*=(F(1) if z==a[j] else F(0))-F(1,2)
            coord=(tuple(ar),tuple(br))
            if not (H(coord[0])[1]==0 and H(coord[1])[0]==0):
                coeff[coord]+=v
        h2=sum(c*c for c in coeff.values())
        weight=4-len(diag)
        expected={0:F(9,32),1:F(3,8),2:F(1,2),3:F(1,2),4:F(0)}[weight]
        assert h2==expected,(a,b,weight,h2,expected)
        counts[(weight,str(h2))]+=1;n+=1
assert n==729
print('PASS 729 exact basis-image norms:',dict(sorted((str(k),v) for k,v in counts.items())))

