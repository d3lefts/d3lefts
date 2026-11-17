#!/usr/bin/env python3
"""Exact full-support finite-regime construction: m factor in dependent Q2 is necessary."""
from itertools import product
from fractions import Fraction

def sharp_witness(m):
    delta=Fraction(1,8*m)
    states=list(product(range(m),range(m),product((-1,1),repeat=m)))
    def labelp(observed,z):
        return 1-delta if observed==z else delta/(m-1)
    def conditional_p(x,z):
        return labelp(x[0],z)*labelp(x[1],z)*Fraction(1,2**m)
    law={x:sum((conditional_p(x,z)/m for z in range(m)),Fraction(0)) for x in states}
    assert all(v>0 for v in law.values()) and sum(law.values())==1
    f=lambda x:x[2][x[0]]
    ef=sum(law[x]*f(x) for x in states)
    variance=sum(law[x]*(f(x)-ef)**2 for x in states)
    assert ef==0 and variance==1
    def inf_label(i):
        buckets={}
        for x in states:
            other=x[:i]+x[i+1:]
            p,v=buckets.get(other,(Fraction(0),Fraction(0)))
            buckets[other]=(p+law[x],v+law[x]*f(x))
        out=Fraction(0)
        for x in states:
            other=x[:i]+x[i+1:]
            p,v=buckets[other]
            out+=law[x]*(f(x)-v/p)**2
        return out
    inf_label1=inf_label(0); inf_label2=inf_label(1)
    assert inf_label2==0 and inf_label1<=4*delta
    inf_y=[]
    for j in range(m):
        buckets={}
        for x in states:
            other=(x[0],x[1],x[2][:j]+x[2][j+1:])
            p,v=buckets.get(other,(Fraction(0),Fraction(0)))
            buckets[other]=(p+law[x],v+law[x]*f(x))
        out=Fraction(0)
        for x in states:
            other=(x[0],x[1],x[2][:j]+x[2][j+1:])
            p,v=buckets[other]
            out+=law[x]*(f(x)-v/p)**2
        assert out==Fraction(1,m)
        inf_y.append(out)
    assert max(inf_label1,inf_label2,*inf_y)==Fraction(1,m)
    for z in range(m):
        mz=sum((conditional_p(x,z)*f(x) for x in states),Fraction(0))
        assert mz==0
    print(f'PASS m={m}, δ={delta}, I_L1={inf_label1}, I_L2={inf_label2}, I_Yj=1/{m}, Var=1, ratio=m')

if __name__=='__main__':
    for m in (2,3,4,5):
        sharp_witness(m)
    print('Result: full-support mixtures require a coefficient at least m.')
