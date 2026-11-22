#!/usr/bin/env python3
"""Independent local-support coefficient enumerator for primitive XOR tensors.

Exhausts k<=4 and support depth j<=3; all arithmetic is exact Python integer
XOR. This certifies finite coefficients, NOT the all-level tensor splitting
theorem or a quantum simulator. Uses a fresh generator indexed by local factors.
"""
from itertools import product, combinations
def mask(factors):
    coords=[0]
    for x in factors:
        coords=[2*v+b for v in coords for b in
                ((0,1) if x==3 else ((0,) if x==1 else (1,)))]
    return sum(1<<v for v in coords)
def primitive(rows, target):
    x=0
    for r in rows:x^=r
    if x!=target:return False
    for t in range(1,len(rows)):
        for subset in combinations(rows,t):
            q=0
            for r in subset:q^=r
            if q==0:return False
    return True
def exact_coefficient(j,k):
    factors=list(product((1,2,3),repeat=j))
    rs=[mask(t) for t in factors]
    assert len(rs)==len(set(rs))==3**j
    target=mask((1,)*j)
    count=0
    for idx in combinations(range(len(rs)),k):
        if not primitive([rs[i] for i in idx],target):continue
        if any(all(factors[i][site]==1 for i in idx) for site in range(j)):
            continue
        count+=1
    return count
if __name__=="__main__":
    expected={(1,0):1,(2,1):1,(3,2):4,(4,2):5,(4,3):30}
    for k in range(1,5):
        for j in range(4):
            c=exact_coefficient(j,k)
            assert c==expected.get((k,j),0),(k,j,c)
            print(f"k={k} full-variation-support={j} coefficient={c}")
    print("PASS: complete finite local coefficient table k<=4, j<=3.")
