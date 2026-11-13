#!/usr/bin/env python3
"""Independent exact rare-event sharpness certificate.
No imports from the spectrum checker; no floating-point comparisons.
"""
from fractions import Fraction as Q
from itertools import product

def check(weights):
    n=len(weights)
    R=sum(map(len,weights))
    predicted=sum((Q(1)-sum((v*v for v in w),Q(0)) for w in weights),Q(0))
    first_order=Q(0)
    finite_p_value=Q(0)
    p=Q(1,100)
    for bits in product((0,1), repeat=R):
        offset=0
        variances=[]
        for w in weights:
            sample=bits[offset:offset+len(w)]
            offset+=len(w)
            avg=sum((a*x for a,x in zip(w,sample)),Q(0))
            variances.append(sum((a*(x-avg)**2 for a,x in zip(w,sample)),Q(0)))
        maximum=max(variances)
        if sum(bits)==1:
            first_order+=maximum
        finite_p_value+=maximum*p**sum(bits)*(1-p)**(R-sum(bits))
    assert first_order==predicted,(first_order,predicted)
    assert finite_p_value<=p*(1-p)*predicted
    print(f'PASS | n={n} | slots={R} | sharp constant={predicted} | one-hot coefficient={first_order} | finite-p ratio={finite_p_value/(p*(1-p))}')

def main():
    check([[Q(1,2),Q(1,2)] for _ in range(3)])
    check([[Q(1,2),Q(1,3),Q(1,6)],[Q(1,4),Q(3,4)],[Q(2,5),Q(3,5)]])
    check([[Q(1),Q(0)],[Q(1,3),Q(2,3)]])
    check([[Q(1,4)]*4,[Q(1,2),Q(1,2)]])
    print('PASS: exact one-hot sharpness and finite-p bounds, independent of the spectrum checker')

if __name__ == '__main__':
    main()
