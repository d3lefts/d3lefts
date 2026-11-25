#!/usr/bin/env python3
"""Independent finite attacks on the isolated-support mode bound and syndrome count."""
from itertools import product
from math import prod
from random import Random

def tuples(q,n): return list(product(range(q),repeat=n))
def isolated_sets(xs):
    conflicts=[sum(1<<j for j,y in enumerate(xs) if sum(a!=b for a,b in zip(x,y))==1) for x in xs]
    def visit(i,mask,forbidden):
        if i==len(xs):
            yield mask; return
        yield from visit(i+1,mask,forbidden)
        if not (forbidden>>i)&1:
            yield from visit(i+1,mask|(1<<i),forbidden|conflicts[i])
    return list(visit(0,0,0))
def compositions(m,q):
    if q==1:
        yield (m,); return
    for v in range(m+1):
        for t in compositions(m-v,q-1): yield (v,)+t

def rank(cols):
    basis={}
    for a in cols:
        while a:
            b=a.bit_length()-1
            if b in basis: a^=basis[b]
            else: basis[b]=a; break
    return len(basis)
def syndrome(cols,x):
    s=0
    for a,b in zip(cols,x):
        if b: s^=a
    return s

def main():
    checks=0
    for q,n,den in [(2,1,4),(2,2,4),(2,3,4),(2,4,3),(3,1,4),(3,2,3)]:
        xs=tuples(q,n); ss=isolated_sets(xs); total=den**n
        for ps in product(list(compositions(den,q)),repeat=n):
            mass=[prod(p[a] for p,a in zip(ps,x)) for x in xs]
            mode=max(range(len(xs)),key=mass.__getitem__)
            assert sum(mass)==total
            for s in ss:
                w=sum(a for j,a in enumerate(mass) if (s>>j)&1)
                assert 2*w-(mass[mode] if (s>>mode)&1 else 0)<=total
                checks+=1
    rng=Random(20261124); code_cases=0
    for n in range(1,10):
        xs=tuples(2,n)
        for _ in range(80):
            cols=[rng.randrange(8) for _ in range(n)]
            sizes=[]; rem=n
            while rem:
                z=rng.randint(1,rem); sizes.append(z); rem-=z
            bounds=[0]
            for z in sizes: bounds.append(bounds[-1]+z)
            blocks=[slice(a,b) for a,b in zip(bounds,bounds[1:])]
            counts={}
            for x in xs:
                if syndrome(cols,x): continue
                y=tuple(syndrome(cols[s],x[s]) for s in blocks)
                counts[y]=counts.get(y,0)+1
            expected=2**(sum(rank(cols[s]) for s in blocks)-rank(cols))
            assert len(counts)==expected
            assert set(counts.values())=={2**(n-sum(rank(cols[s]) for s in blocks))}
            for a in counts:
                for j in range(len(a)):
                    for b in range(8):
                        if b!=a[j]: assert a[:j]+(b,)+a[j+1:] not in counts
            code_cases+=1
    print(f'PASS: {checks} exact isolated-set/product-law pairs; {code_cases} GF(2) syndrome partitions')
if __name__=='__main__': main()
