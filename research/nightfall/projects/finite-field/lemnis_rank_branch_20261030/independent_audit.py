#!/usr/bin/env python3
"""Independent GF9 oracle audit in F3[u]/(u^2+u+2), u^2=2u+1."""
from itertools import product
from collections import Counter

def add(a,b):return ((a%3+b%3)%3)+3*((a//3+b//3)%3)
def neg(a):return add(a,a)
def mul(a,b):
    a0,a1=a%3,a//3
    b0,b1=b%3,b//3
    return ((a0*b0+a1*b1)%3)+3*((a0*b1+a1*b0+2*a1*b1)%3)
def square(a):return mul(a,a)
def dot(row,x):
    out=0
    for a,b in zip(row,x,strict=True):out=add(out,mul(a,b))
    return out

assert len({square(a) for a in range(9)})==5
assert mul(3,3)==7
inverses={a:next(b for b in range(1,9) if mul(a,b)==1) for a in range(1,9)}
roots={s:next(a for a in range(9) if square(a)==s) for s in {square(i) for i in range(9)}}

def decode(secret):
    k=len(secret);calls=0
    def oracle(row):
        nonlocal calls
        assert len(row)==k
        calls+=1
        return square(dot(row,secret))
    reading=[]
    for j in range(k):
        row=[0]*k;row[j]=1
        reading.append(oracle(row))
    supp=[j for j,v in enumerate(reading) if v!=0]
    answer=[0]*k
    if supp:
        vals={j:roots[reading[j]] for j in supp}
        t=supp[0];answer[t]=vals[t]
        for start in range(0,len(supp)-1,2):
            block=supp[1+start:3+start]
            betas=(1,3)[:len(block)]
            row=[0]*k
            z=0
            for beta in betas:z=add(z,beta)
            row[t]=mul(z,inverses[vals[t]])
            for j,beta in zip(block,betas,strict=True):
                row[j]=mul(beta,inverses[vals[j]])
            y=oracle(row)
            lookup={}
            for phases in product((1,2),repeat=len(block)):
                u=0
                for beta,h in zip(betas,phases,strict=True):
                    u=add(u,mul(beta,add(1,h)))
                w=square(u)
                assert w not in lookup
                lookup[w]=phases
            for j,h in zip(block,lookup[y],strict=True):
                answer[j]=mul(h,vals[j])
    assert calls==k+len(supp)//2
    assert tuple(answer)==secret or tuple(neg(z) for z in answer)==secret
    return calls

def main():
    for k in (3,4,5):
        counts=Counter(decode(x) for x in product(range(9),repeat=k))
        expected={3:{3:25,4:704},4:{4:33,5:2432,6:4096},5:{5:41,6:5760,7:53248}}[k]
        assert counts==expected,(k,counts)
        print(f'PASS GF9 k={k} signals={9**k} query_counts={dict(sorted(counts.items()))}')
    # Rank-deficient image is trivially 1D-intersecting yet zero and kernel collide.
    A=((1,0),(1,0),(1,0))
    assert all(square(dot(row,(0,1)))==square(dot(row,(0,0))) for row in A)
    print('NEGATIVE CONTROL PASS: rank-deficient image cannot separate the zero signal')
    A=((1,0),(0,1),(1,1));seen={}
    for x in product(range(9),repeat=2):
        reading=tuple(square(dot(row,x)) for row in A)
        representative=min(x,tuple(neg(v) for v in x))
        if reading in seen:assert seen[reading]==representative
        seen[reading]=representative
    assert len(seen)==41
    print('PASS fixed k=2 three-query separation of all 41 sign orbits')
    four=((1,0,0),(0,1,0),(0,0,1),(1,1,1))
    x,y=(1,2,1),(2,1,1)
    assert x!=tuple(neg(z) for z in y)
    assert tuple(square(dot(row,x)) for row in four)==tuple(square(dot(row,y)) for row in four)
    print('NEGATIVE CONTROL PASS: four fixed queries fail at k=3')
    print('PASS: all tested data and independent field arithmetic')

if __name__=='__main__':main()
