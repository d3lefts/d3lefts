#!/usr/bin/env python3
"""Non-importing legal coefficient-row checker for the diamond phase code.

Unlike check_diamond.py this script never constructs the four tiles or
the nine rectangle sumset. It directly evaluates every ± sign word in
the squared K-linear observation a0+sum(aj*eta_j), uses two quadratic
field models related by an explicitly checked isomorphism, tests all
partial sign blocks, and deliberately mutates the anchor to produce
a collision between two known distinct sign words.
"""
from itertools import product
from hashlib import sha256


def nonresidues(p):
    return [a for a in range(2,p) if pow(a,(p-1)//2,p)==p-1]


def field_square(z,delta,p):
    a,b=z
    return ((a*a+delta*b*b)%p,(2*a*b)%p)


def plus(u,v,p):
    return ((u[0]+v[0])%p,(u[1]+v[1])%p)


def scale(a,u,p):
    return ((a*u[0])%p,(a*u[1])%p)


def audit(p,d):
    D=1<<d
    assert 3*D<=p<=4*D-1
    delta1,delta2=nonresidues(p)[:2]
    beta=next(z for z in range(1,p) if (z*z*delta2)%p==delta1)
    iso=lambda z: (z[0],(z[1]*beta)%p)
    weights=tuple((1<<j,0) for j in range(d))+tuple((0,1<<j) for j in range(d))+(
        (D,D//2),(D,-D//2))
    b=2*d+2
    assert len(weights)==b
    hole=(4*D-p-1,5*D//2-1)
    inv2=pow(2,-1,p)
    c=scale(-inv2,hole,p)
    coeff=tuple(scale(inv2,w,p) for w in weights)
    anchor=c
    for a in coeff:
        anchor=plus(anchor,a,p)
    seen={}
    transcript=[]
    for signs in product((1,p-1),repeat=b):
        z=anchor
        for a,sign in zip(coeff,signs,strict=True):
            z=plus(z,scale(sign,a,p),p)
        sq1=field_square(z,delta1,p)
        sq2=field_square(iso(z),delta2,p)
        assert iso(sq1)==sq2
        assert sq1 not in seen,(p,signs,seen[sq1])
        seen[sq1]=signs
        transcript.append(sq1)
    assert len(seen)==1<<b
    # Each prefix of the coefficient row is a legitimate partial block
    # by holding the unused relative signs at +1; no hidden extra query.
    for length in range(1,b):
        partial=set()
        for signs in product((1,p-1),repeat=length):
            z=anchor
            for j,a in enumerate(coeff):
                z=plus(z,scale(signs[j] if j<length else 1,a,p),p)
            powered=field_square(z,delta1,p)
            assert powered not in partial
            partial.add(powered)
        assert len(partial)==1<<length
    # Mutation: choose an anchor that forces the translated binary
    # points 0 and the first generator to be additive opposites.
    bad_c=scale(-inv2,weights[0],p)
    bad_anchor=bad_c
    for a in coeff:
        bad_anchor=plus(bad_anchor,a,p)
    good_a=tuple([p-1]*b)
    good_b=tuple([1]+[p-1]*(b-1))
    def bad_obs(signs):
        z=bad_anchor
        for a,s in zip(coeff,signs,strict=True):
            z=plus(z,scale(s,a,p),p)
        return field_square(z,delta1,p)
    assert bad_obs(good_a)==bad_obs(good_b)
    digest=sha256(",".join(f"{a}.{b}" for a,b in sorted(transcript)).encode()).hexdigest()
    return {"p":p,"D":D,"signs":b,"outputs":len(seen),
            "field_moduli":(delta1,delta2),"isomorphism_beta":beta,
            "partial_prefixes":b-1,"anchor_mutation_rejected":True,
            "power_table_sha256":digest}


if __name__=="__main__":
    for p,d in ((13,2),(29,3),(53,4),(59,4),(61,4),(97,5),(101,5),(127,5),(193,6)):
        print("PASS",audit(p,d))
    print("PASS: all legal powered-linear rows and two irreducible field models")
