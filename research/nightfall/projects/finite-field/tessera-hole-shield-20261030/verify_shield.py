#!/usr/bin/env python3
"""Independent exact checker for all-extension-degree squared-oracle hole shields."""
from itertools import product
from hashlib import sha256

SEEDS=((13,2),(29,3),(31,3),(61,4),(127,5))
def seed(p,d):
    D=1<<d
    w=[(1<<i,0) for i in range(d)]+[(0,1<<i) for i in range(d)]
    w += [(2*D-1,D+1),(-1,D+1)]
    T={(sum(bits[i]*w[i][0] for i in range(len(w)))%p,
        sum(bits[i]*w[i][1] for i in range(len(w)))%p)
       for bits in product((0,1),repeat=len(w))}
    assert len(T)==1<<(2*d+2),(p,"duplicate seed")
    m=((2*D-2)%p,(2*D+1)%p)
    sums={((x[0]+y[0])%p,(x[1]+y[1])%p) for x in T for y in T}
    assert m not in sums,(p,"hole filled")
    return w,m,len(sums)

def cylinder(p,d,r):
    w,m,n=seed(p,d)
    assert r>=2
    weights=[(x,y)+tuple(0 for _ in range(r-2)) for x,y in w]
    for j in range(2,r):
        for t in range(d+1):
            v=[0]*r;v[j]=1<<t;weights.append(tuple(v))
    assert len(weights)==r*(d+1)
    half=(p+1)//2
    c=((-m[0]*half)%p,(-m[1]*half)%p)+tuple(0 for _ in range(r-2))
    words=set()
    for flags in product((0,1),repeat=len(weights)):
        value=tuple((c[j]+sum(f*v[j] for f,v in zip(flags,weights)))%p
                    for j in range(r))
        assert value not in words
        words.add(value)
    assert len(words)==1<<len(weights)
    assert all(tuple((-x)%p for x in v) not in words for v in words)
    print("PASS p",p,"r",r,"bits",len(weights),
          "words",len(words),"seed pair-sums",n)
    return weights,c,words

def field_mul(a,b):
    # GF(13^3)=F13[t]/(t^3-2), irreducible: 2 is not a cube mod 13.
    z=[0]*5
    for i in range(3):
        for j in range(3):z[i+j]=(z[i+j]+a[i]*b[j])%13
    z[0]=(z[0]+2*z[3])%13
    z[1]=(z[1]+2*z[4])%13
    return tuple(z[:3])

def cubic_field_oracle():
    assert all(pow(x,3,13)!=2 for x in range(13))
    weights,c,words=cylinder(13,2,3)
    inv2=7
    phase=[tuple(inv2*v%13 for v in w) for w in weights]
    anchor=tuple((c[j]+sum(a[j] for a in phase))%13 for j in range(3))
    seen=set()
    for flags in product((-1,1),repeat=9):
        x=tuple((anchor[j]+sum(s*a[j] for s,a in zip(flags,phase)))%13 for j in range(3))
        y=field_mul(x,x)
        assert y not in seen
        seen.add(y)
    assert len(seen)==512==len({field_mul(x,x) for x in words})
    print("PASS literal same-oracle GF13^3 squares",len(seen),
          "anchor",anchor,"weights",phase)
    print("CHECKSUM",sha256(repr(sorted(seen)).encode()).hexdigest())

def negative_control():
    T=list(product(range(8),repeat=3))
    sums={(tuple((a[i]+b[i])%13 for i in range(3)))
          for j,a in enumerate(T) for b in T[j+1:]}
    assert len(sums)==2197
    print("PASS unshielded nine-bit cube off-diagonal covers",len(sums),
          "of 2197 residues; no square-injective translate")

if __name__=="__main__":
    for p,d in SEEDS:
        w,m,s=seed(p,d)
        print("PASS tiled seed p",p,"bits",len(w),
              "sumset cardinality",s,"missing",m)
    for p,d,r in ((13,2,2),(13,2,4),(29,3,3),(29,3,4),
                  (31,3,3),(61,4,3),(127,5,3)):
        cylinder(p,d,r)
    cubic_field_oracle()
    negative_control()
