#!/usr/bin/env python3
"""Exact complete-signal replay of legal adaptive square-powered linear queries.
GF(p²)=GF(p)[u]/(u²-d), d nonsquare. No third-party dependencies.
"""
from itertools import product
from collections import Counter

def add(a,b,p):return ((a[0]+b[0])%p,(a[1]+b[1])%p)
def neg(a,p):return ((-a[0])%p,(-a[1])%p)
def mul(a,b,p,d):
    return ((a[0]*b[0]+d*a[1]*b[1])%p,
            (a[0]*b[1]+a[1]*b[0])%p)

def coefficients(p):
    d=p.bit_length()-1
    e=((p-1)//2).bit_length()-1
    f=((p+1)//2).bit_length()-1
    if 2*f>=e+d:
        anchor=(2**f-1,2**f-1)
        rows=[(2**i,0) for i in range(f)]+[(0,2**i) for i in range(f)]
    else:
        anchor=(2**e,0)
        rows=[(2**i,0) for i in range(e)]+[(0,2**i) for i in range(d)]
    return anchor,rows

def replay(p,d,k,exhaustive=True,samples=10000):
    assert all((x*x)%p!=d for x in range(p))
    elements=list(product(range(p),repeat=2))
    zero=(0,0);unit=(1,0)
    roots={}
    for x in elements:
        roots.setdefault(mul(x,x,p,d),x)
    assert len(roots)==(p*p+1)//2
    inv={}
    for x in elements[1:]:
        for y in elements:
            if mul(x,y,p,d)==unit:
                inv[x]=y
                break
    assert len(inv)==p*p-1
    anchor,rows=coefficients(p)
    B=len(rows)
    tables={}
    for b in range(1,B+1):
        table={}
        for phases in product((-1,1),repeat=b):
            s=anchor
            for c,sgn in zip(rows,phases):
                s=add(s,c if sgn==1 else neg(c,p),p)
            output=mul(s,s,p,d)
            assert output not in table,(p,b,phases)
            table[output]=phases
        tables[b]=table
    histogram=Counter()
    def test(x):
        measured=[mul(z,z,p,d) for z in x]
        canonical=[roots[z] for z in measured]
        support=[i for i,z in enumerate(measured) if z!=zero]
        if not support:
            assert all(z==zero for z in x)
            histogram[0]+=1
            return
        a=support[0]
        result=[zero]*k
        result[a]=canonical[a]
        used=k
        for off in range(1,len(support),B):
            active=support[off:off+B]
            # Coefficients are functions only of previously observed squares.
            form=[zero]*k
            form[a]=mul(anchor,inv[canonical[a]],p,d)
            for i,c in zip(active,rows):
                form[i]=mul(c,inv[canonical[i]],p,d)
            z=zero
            for aj,xj in zip(form,x):
                z=add(z,mul(aj,xj,p,d),p)
            output=mul(z,z,p,d)
            phases=tables[len(active)][output]
            for i,sgn in zip(active,phases):
                result[i]=canonical[i] if sgn==1 else neg(canonical[i],p)
            used+=1
        assert result==list(x) or [neg(z,p) for z in result]==list(x),(p,k,x,result)
        histogram[used]+=1
    if exhaustive:
        for x in product(elements,repeat=k):test(x)
        assert sum(histogram.values())==(p*p)**k
    else:
        state=17030
        for _ in range(samples):
            x=[]
            for _ in range(k):
                state=(1103515245*state+12345)&0x7fffffff
                x.append(elements[state%(p*p)])
            test(tuple(x))
        assert sum(histogram.values())==samples
    print("PASS",p,p*p,"k",k,"phase block",B,
          "exhaustive" if exhaustive else "sampled",
          dict(sorted(histogram.items())))

if __name__=="__main__":
    replay(3,2,4,True)
    replay(5,2,4,True)
    replay(7,3,3,True)
    replay(7,3,5,False,10000)
    replay(11,2,6,False,10000)
