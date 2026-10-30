#!/usr/bin/env python3
"""Exact independent signed-digit orbit checks: 7 odd primes, r=1..4."""
from itertools import product

def neg(v,p):
    return tuple((-x)%p for x in v)

def coefficients(p,r,mode):
    d=p.bit_length()-1
    e=((p-1)//2).bit_length()-1
    f=((p+1)//2).bit_length()-1
    if mode=="oriented":
        widths=[f]*r
        anchor=[2**f-1]*r
    else:
        widths=[e]+[d]*(r-1)
        anchor=[2**e]+[0]*(r-1)
    rows=[]
    for j,w in enumerate(widths):
        for t in range(w):
            rows.append(tuple(2**t if i==j else 0 for i in range(r)))
    return tuple(anchor),rows

def inspect(p,r,mode):
    anchor,rows=coefficients(p,r,mode)
    seen=set()
    for signs in product((-1,1),repeat=len(rows)):
        v=tuple((anchor[j]+sum(row[j]*s for row,s in zip(rows,signs)))%p
                for j in range(r))
        orbit=min(v,neg(v,p))
        assert orbit not in seen,(p,r,mode,signs)
        seen.add(orbit)
    assert len(seen)==2**len(rows)
    return len(rows)

def square(x,p,d):
    a,b=x
    return ((a*a+d*b*b)%p,(2*a*b)%p)

if __name__=="__main__":
    count=0
    for p in (3,5,7,11,13,17,31):
        for r in range(1,5):
            for mode in ("oriented","strict"):
                inspect(p,r,mode)
                count+=1
    assert count==56
    expected={3:2,5:3,7:4,11:5}
    for p,d,mode in ((3,2,"oriented"),(5,2,"strict"),
                     (7,3,"oriented"),(11,2,"strict")):
        anchor,rows=coefficients(p,2,mode)
        values=set()
        for signs in product((-1,1),repeat=len(rows)):
            v=tuple((anchor[j]+sum(row[j]*s for row,s in zip(rows,signs)))%p
                    for j in (0,1))
            reading=square(v,p,d)
            assert reading not in values
            values.add(reading)
        assert len(values)==2**expected[p]
        # Adversarial mutation: dropping anchor must produce a collision.
        broken=set()
        for signs in product((-1,1),repeat=len(rows)):
            v=tuple(sum(row[j]*s for row,s in zip(rows,signs))%p
                    for j in (0,1))
            broken.add(square(v,p,d))
        assert len(broken)<len(values)
        print("PASS GF",p*p,"signs",expected[p],"square outputs",len(values),
              "zero-anchor mutation rejected")
    print("PASS 56 independent prime/dimension/family orbit exhaustions")
