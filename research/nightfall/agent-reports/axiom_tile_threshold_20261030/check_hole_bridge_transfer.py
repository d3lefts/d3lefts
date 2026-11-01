#!/usr/bin/env python3
"""Exact bridge + spectator certificates. No 2^33/2^47/2^61 enumeration."""
from itertools import product
from math import isqrt

def is_prime(n):
    return n>=2 and all(n%d for d in range(2,isqrt(n)+1))
for p in (3,5,13,23,53,3251,4871,55109):
    assert is_prime(p),p


def diamond(p,D,full=False):
    d=D.bit_length()-1
    assert D==1<<d and d>=2 and 3*D<=p<4*D
    m=(4*D-p-1,5*D//2-1)
    def in_S(point):
        return any(((point[0]-(a+b)*D)%p <= 2*D-2 and
                    (point[1]-(a-b)*(D//2))%p <= 2*D-2)
                   for a in range(3) for b in range(3))
    for j in range(3):
        assert not in_S(((m[0]+j)%p,m[1]))
    s=(3*D-1,D-1)
    u=((m[0]-s[0])%p,(m[1]-s[1])%p)
    assert u==(D,(3*D//2)%p)
    bridge=(u[0],u[1],p-1,0)
    bits=4*d+5
    assert 2**bits<=p**3*(p-1)//2+1
    if full:
        T=set()
        for x,y,v,w in product(range(D),range(D),(0,1),(0,1)):
            point=((x+(v+w)*D)%p,(y+(v-w)*(D//2))%p)
            assert point not in T
            T.add(point)
        assert len(T)==4*D*D
        product_set={a+b for a in T for b in T}
        assert len(product_set)==(4*D*D)**2
        C=product_set|{tuple((v+w)%p for v,w in zip(x,bridge))
                       for x in product_set}
        assert len(C)==2**bits
        c=tuple((-v*pow(2,-1,p))%p for v in m+m)
        E={tuple((v+w)%p for v,w in zip(x,c)) for x in C}
        assert not E.intersection(tuple((-v)%p for v in x) for x in E)
    print("PASS diamond bridge",p,D,"bits",bits,"bridge",bridge,
          "exhaustive" if full else "symbolic 27 rectangle checks")

diamond(13,4,True)
diamond(53,16,False)
diamond(55109,16384,False)

# p3251, dim3: 22-bit diamond + 11-bit spectator; ordinary hole suffices.
p=3251;D=1024
m=(4*D-p-1,5*D//2-1)
for a in range(3):
    for b in range(3):
        assert not ((m[0]-(a+b)*D)%p<=2*D-2 and
                    (m[1]-(a-b)*(D//2))%p<=2*D-2)
assert 2**11<=p
assert 2**33 <= p*p*(p-1)//2+1 < 2**34
print('PASS p3251 dimension3: 33 bits, 9-rectangle plus spectator certificate')

# p4871, dim4: axis generators (12,11,12,12), anchor one in second coordinate.
p=4871
assert sum((12,11,12,12))==47 and 2*2**11<p
assert 2**47<=p**3*(p-1)//2+1<2**48
print('PASS p4871 dimension4: 47 bits, axis interval certificate')

# p3,d4 and p5,d4, and p13,d3: explicit small affine cubes.
def cube(p,anchor,weights):
    d=len(anchor)
    A=set()
    for bits in product((0,1),repeat=len(weights)):
        point=tuple((anchor[j]+sum(bit*w[j] for bit,w in zip(bits,weights)))%p
                    for j in range(d))
        assert point not in A
        A.add(point)
    overlap=A.intersection(tuple((-x)%p for x in a) for a in A)
    assert overlap.issubset({(0,)*d})
    return A
A3=cube(3,(0,0,0,0),[(1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1)])
weights5=[]
for j in range(3):
    for step in (1,2):
        w=[0]*4;w[j]=step;weights5.append(tuple(w))
weights5.append((0,0,0,1))
A5=cube(5,(0,0,0,1),weights5)
A13=cube(13,(12,2,0),[(1,0,0),(2,0,0),(0,1,0),(0,2,0),
                         (4,2,0),(4,-2,0),(0,0,1),(0,0,2),(0,0,4)])
assert len(A3)==16 and len(A5)==128 and len(A13)==512
assert pow(2,4,13)!=1 # irreducibility: 2 not a cube in F13
def sq13(z):
    x,y,w=z
    return ((x*x+4*y*w)%13,(2*x*y+2*w*w)%13,(y*y+2*x*w)%13)
assert len({sq13(z) for z in A13})==512
print('PASS p3^4: 4 bits; p5^4: 7 bits; p13^3: 9 bits, direct 512 field squares')
