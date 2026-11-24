#!/usr/bin/env python3
"""Exact small-instance falsification tests, not proof or independent peer review."""
from itertools import product
from math import prod
from random import Random

def bits(n):
    return list(product((0,1), repeat=n))

def masses(p, xs):
    return [prod(a if x else 4-a for a,x in zip(p,z)) for z in xs]

def main():
    component_cases = mixture_cases = partition_cases = 0
    rng = Random(20261124)
    for n in range(1,6):
        xs=bits(n); even=[i for i,x in enumerate(xs) if sum(x)%2==0]
        odd=[i for i,x in enumerate(xs) if sum(x)%2]
        M=len(even); den=4**n
        for p in product(range(5), repeat=n):
            q=masses(p,xs)
            mode=max(range(len(xs)),key=q.__getitem__)
            assert sum(q)==den
            assert sum(q[i] for i in even if i!=mode)<=sum(q[i] for i in odd)
            component_cases+=1
        for k in range(1,min(M+2,9)):
            for _ in range(100):
                ws=[rng.randint(1,8) for _ in range(k)]
                qs=[masses([rng.randrange(5) for _ in range(n)],xs) for _ in ws]
                total=sum(ws)*den
                Q=[sum(w*q[i] for w,q in zip(ws,qs)) for i in range(len(xs))]
                # TV numerator over 2*M*total.
                tvnum=sum(abs(M*a-(total if i in even else 0)) for i,a in enumerate(Q))
                assert k*total>=M*total-tvnum
                mixture_cases+=1
    for n in range(2,13):
        for r in range(1,n):
            if r>n-2: continue
            groups=[range(i,min(i+r,n)) for i in range(0,n,r)]
            m=len(groups); counts={}
            for x in bits(n):
                if sum(x)%2: continue
                y=tuple(sum(x[i] for i in g)%2 for g in groups)
                counts[y]=counts.get(y,0)+1
            assert len(counts)==2**(m-1)
            assert set(counts.values())=={2**(n-m)}
            partition_cases+=1
    print(f'PASS: {component_cases} exact product components; {mixture_cases} exact rational mixtures; {partition_cases} parity block partitions')
if __name__=='__main__': main()
