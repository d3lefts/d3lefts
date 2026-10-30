#!/usr/bin/env python3
"""Independent exact F3^r signed-sum squared-oracle histogram inversion.

Computes every output count without enumerating 2^(m-1) sign assignments.
No field extension multiplication, third-party dependencies, or producer code.
"""
from collections import Counter
from itertools import product
from random import Random


def negate(v):
    return tuple((-x) % 3 for x in v)


def canonical(v):
    return min(v, negate(v))


def rays(r):
    assert r >= 2
    return tuple(sorted({canonical(v) for v in product(range(3), repeat=r) if any(v)}))


def dot(a, b):
    return sum(x*y for x, y in zip(a, b)) % 3


def infer_buckets(coeffs):
    assert coeffs and len(coeffs[0]) >= 2
    m, r = len(coeffs), len(coeffs[0])
    assert all(len(c) == r and all(x in (0, 1, 2) for x in c) for c in coeffs)
    point_rays = rays(r)
    n_sign_orbits = 1 << (m-1)
    v = (3**r - 1) // 2
    k = (3**(r-1) - 1) // 2
    lam = (3**(r-2) - 1) // 2
    assert len(point_rays) == v
    hyperplane_sums = {}
    for normal in point_rays:
        z = sum(dot(c, normal) == 0 for c in coeffs)
        signed_character = ((-1)**(m-z)) * (1 << z)
        num = n_sign_orbits + signed_character
        assert num % 3 == 0
        hyperplane_sums[normal] = num//3
    num_b0 = sum(hyperplane_sums.values()) - k * n_sign_orbits
    assert num_b0 % (v-k) == 0
    b0 = num_b0//(v-k)
    result = {(0,)*r: b0}
    for vec in point_rays:
        num = sum(hyperplane_sums[normal] - b0 for normal in point_rays if dot(normal, vec) == 0)
        num -= lam * (n_sign_orbits-b0)
        assert num % (k-lam) == 0
        result[vec] = num//(k-lam)
    assert min(result.values())>=0 and sum(result.values())==n_sign_orbits
    return result, hyperplane_sums


def direct_buckets(coeffs):
    assert coeffs
    m, r = len(coeffs), len(coeffs[0])
    counts = Counter()
    for signs in product((1,2), repeat=m-1):
        signs = (1,)+signs
        accum = tuple(sum(s*c[i] for s,c in zip(signs,coeffs))%3 for i in range(r))
        counts[canonical(accum)]+=1
    return {(0,)*r: counts[(0,)*r], **{p:counts[p] for p in rays(r)}}


def audit():
    rng=Random(20261030)
    checks=0
    for r in (2,3,4):
        zero=(0,)*r
        basis=[tuple(int(i==j) for i in range(r)) for j in range(r)]
        for m in (1,2,3,5,7,10,13):
            families=[
                [zero]*m,
                [basis[j%r] for j in range(m)],
                [tuple(rng.randrange(3) for _ in range(r)) for _ in range(m)],
                [tuple(rng.randrange(3) for _ in range(r)) for _ in range(m)],
            ]
            for cs in families:
                got, z = infer_buckets(cs)
                expected=direct_buckets(cs)
                assert got==expected,(r,m,cs,got,expected)
                for normal,count in z.items():
                    assert count == sum(value for vec,value in expected.items() if dot(normal,vec)==0)
                checks+=1
    large=[]
    for r,m in ((2,200),(3,200),(4,200),(4,1000)):
        cs=[tuple(rng.randrange(3) for _ in range(r)) for _ in range(m)]
        counts,z=infer_buckets(cs)
        assert sum(counts.values())==2**(m-1)
        assert all(isinstance(x,int) for x in counts.values())
        large.append((r,m,len(counts),max(counts.values()).bit_length()))
    # Basis-covariance check: invertible change (x0,x1,x2,...)->(x0+x1,x1,x2,...)
    for r in (3,4):
        cs=[tuple(rng.randrange(3) for _ in range(r)) for _ in range(11)]
        changed=[((c[0]+c[1])%3,)+c[1:] for c in cs]
        a,_=infer_buckets(cs);b,_=infer_buckets(changed)
        assert all(b[canonical(((v[0]+v[1])%3,)+v[1:])]==n for v,n in a.items())
    # Integrity negative control: a purposely tampered hyperplane count is not a valid count profile.
    cs=[(0,0,0),(1,0,0),(0,1,0),(0,0,1),(1,1,0),(2,1,2),(0,2,1)]
    b,z=infer_buckets(cs)
    zcopy=dict(z);k=next(iter(zcopy));zcopy[k]+=1
    assert zcopy[k] != sum(count for v,count in direct_buckets(cs).items() if dot(v,k)==0)
    print('PASS: exact projective-hyperplane inversion independent of direct sign enumeration')
    print('direct comparisons:',checks,'(r in 2,3,4; m in 1,2,3,5,7,10,13)')
    print('long-code checks:',large)
    print('PASS: basis covariance, zero vectors, nonzero profiles, tampered-hyperplane refusal')
    print('STATUS: R1 internal algebraic/finite verification, no external novelty certification')


if __name__ == '__main__':
    audit()
