from fractions import Fraction as Q
from itertools import product

def verify(a,b):
    N=len(a)
    # Independent amplitude route: before final H, each (selector,index)
    # sector has control components proportional to (1, signed phase).
    quantum=[]; classical=[]
    for z in (0,1):
        p=Q(0); hits=0
        for selector,table in enumerate((a,b)):
            for v in table:
                sign = (2*v-1) if selector==0 else (1-2*v)
                # squared unnormalized amplitude after H, per sector
                p += Q((1+(-1)**z*sign)**2,8*N)
                # independent Boolean decision rule
                hits += int((bool(v) if selector==0 else not bool(v)) != bool(z))
        quantum.append(p); classical.append(Q(hits,2*N))
    d=sum(a)-sum(b)
    assert quantum==classical
    assert (quantum[0]+quantum[1])/2==Q(1,2)
    assert (quantum[0]-quantum[1])/2==Q(d,2*N)
    assert (quantum[0]>Q(1,2))==(d>0)
    assert (quantum[0]==Q(1,2))==(d==0)
    assert all(0<=p<=1 for p in quantum)

cases=0
for m in range(4):
    tables=list(product((0,1),repeat=2**m))
    for a in tables:
        for b in tables:
            verify(a,b); cases+=1
print(f'PASS: {cases} ordered truth-table pairs, 2 oracle bits each; exact rational quantum/classical agreement and coefficient signs')
