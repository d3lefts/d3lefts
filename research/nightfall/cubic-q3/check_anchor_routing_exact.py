#!/usr/bin/env python3
"""Independent exact sharpness of anchor-only degree-d exponent-two.

Full truth-table enumeration for d=1,2,3,4. The infinite d statement
is proved algebraically in the accompanying note, not by enumeration.
"""
from fractions import Fraction
from itertools import product


def audit(d):
    m=d-1
    addrs=list(product((-1,1),repeat=m))
    n_anchor=1<<m
    n_sign=2*m
    assert len(addrs)==n_anchor
    def eval_f(x):
        a=x[:n_anchor]
        controls=x[n_anchor:]
        row=tuple(controls[2*r]*controls[2*r+1] for r in range(m))
        s=addrs.index(row)
        return a[s] * (1 if m==0 else __import__('math').prod(controls[2*r] for r in range(m)))
    total=1<<(n_anchor+n_sign)
    values={}
    for x in product((-1,1),repeat=n_anchor+n_sign):
        y=eval_f(x)
        assert abs(y)==1
        values[x]=y
    mean=sum(values.values())
    assert mean==0
    var=Fraction(sum(v*v for v in values.values()),total)
    infs=[]
    for i in range(n_anchor+n_sign):
        sum_influence=0
        for x,v in values.items():
            flip=x[:i]+(-x[i],)+x[i+1:]
            sum_influence+=((v-values[flip])//2)**2
        infs.append(Fraction(sum_influence,total))
    assert var==1
    assert all(q==Fraction(1,n_anchor) for q in infs[:n_anchor]),infs
    assert all(q==Fraction(1,2) for q in infs[n_anchor:]),infs
    B=1
    M_anchor=max(infs[:n_anchor])
    anchor_ratio=var**2/(B*B*M_anchor)
    assert anchor_ratio==2**m
    global_ratio=var**2/max(infs)
    print(f'PASS d={d}, full states={total}, V=1, B=1, anchor I={M_anchor}, anchor ratio={anchor_ratio}, global ratio={global_ratio}')


if __name__=='__main__':
    for d in (1,2,3,4):
        audit(d)
    print('SCOPE: exact finite sharpness witnesses; universal d follows from analytic construction')
