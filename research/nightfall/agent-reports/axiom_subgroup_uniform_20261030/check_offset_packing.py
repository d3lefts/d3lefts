#!/usr/bin/env python3
"""Exact finite checks for prime-subfield multiplicative-orbit offset packing.

Uses F_p[t]/(t^2-delta) for independent modular arithmetic; every claim is
finite, with no external model or solver. Universal proof is in THEOREM.md.
"""
from itertools import product


def roots(p, h):
    assert h > 1 and (p - 1) % h == 0
    return tuple(x for x in range(1, p) if pow(x, h, p) == 1)


def forbidden(p, H):
    bad = set()
    for g in H:
        if g == 1:
            continue
        inv = pow((1-g) % p, -1, p)
        for u in H:
            for v in H:
                bad.add(((g*v-u)*inv) % p)
    return bad


def orbit_injective(p, H, t):
    """Injectivity of eta -> (t+eta)^h, including the zero value."""
    seen = set()
    for eta in H:
        value = pow((t+eta) % p, len(H), p)
        if value in seen:
            return False
        seen.add(value)
    return True


def nonsquare(p):
    return next(x for x in range(2, p)
                if pow(x, (p-1)//2, p) == p-1)


def mul(x, y, p, d):
    a,b=x; c,e=y
    return ((a*c+b*e*d) % p, (a*e+b*c) % p)


def power(z, h, p, d):
    ans=(1,0)
    while h:
        if h & 1:
            ans=mul(ans,z,p,d)
        z=mul(z,z,p,d)
        h//=2
    return ans


def one_instance(p,h):
    H=roots(p,h)
    assert len(H)==h
    bad=forbidden(p,H)
    good=[t for t in range(p) if orbit_injective(p,H,t)]
    # Sufficient certificate only, not the iff criterion for every offset.
    assert all(t in good for t in range(p) if t not in bad)
    if p > (h-1)*h*h:
        assert len(bad) <= (h-1)*h*h < p
    assert not orbit_injective(p,H,0), "negative control: zero shift"
    assert good, (p,h)
    t=good[0]
    delta=nonsquare(p)
    codes={}
    for word in product(H,repeat=2):
        z=((t+word[0])%p,(t+word[1])%p)
        out=power(z,h,p,delta)
        assert out not in codes, (p,h,t,word,codes.get(out))
        codes[out]=word
    return dict(p=p,h=h,offset=t,good_offsets=len(good),
                forbidden_count=len(bad),injection_count=len(codes),
                two_phase_words=h*h,field_modulus_delta=delta)


def add(x,y,p):
    return ((x[0]+y[0])%p,(x[1]+y[1])%p)


def scale(c,x,p):
    return ((c*x[0])%p,(c*x[1])%p)


def exhaustive_decoder(p,h):
    """All K^3 signals, output up to global H, with chosen legal queries."""
    H=roots(p,h)
    t=next(t for t in range(p) if orbit_injective(p,H,t))
    delta=nonsquare(p)
    q=p*p
    elements=[(a,b) for a in range(p) for b in range(p)]
    roots_by_value={}
    for z in elements:
        roots_by_value.setdefault(power(z,h,p,delta),[]).append(z)
    assert all(len(v)==h for y,v in roots_by_value.items() if y!=(0,0))
    representatives={y:min(rr) for y,rr in roots_by_value.items()}
    inverses={z:power(z,q-2,p,delta) for z in elements if z!=(0,0)}
    basis=((1,0),(0,1))
    zero=(0,0)
    transcripts={}
    for x in product(elements,repeat=3):
        measurements=tuple(power(z,h,p,delta) for z in x)
        support=[i for i,z in enumerate(x) if z!=zero]
        extra=None
        if len(support)>1:
            anchor=support[0]
            mixed=zero
            anchor_coefficient=zero
            for j,i in enumerate(support[1:]):
                beta=basis[j]
                anchor_coefficient=add(anchor_coefficient,scale(t,beta,p),p)
                coeff=mul(beta,inverses[representatives[measurements[i]]],p,delta)
                mixed=add(mixed,mul(coeff,x[i],p,delta),p)
            anchor_coefficient=mul(
                anchor_coefficient,inverses[representatives[measurements[anchor]]],p,delta)
            mixed=add(mixed,mul(anchor_coefficient,x[anchor],p,delta),p)
            extra=power(mixed,h,p,delta)
        transcript=(measurements,extra)
        orbit=min(tuple(scale(c,z,p) for z in x) for c in H)
        if transcript in transcripts:
            assert transcripts[transcript]==orbit, "cross-orbit collision"
        transcripts[transcript]=orbit
    assert len(transcripts)==1+(q**3-1)//h
    return dict(p=p,h=h,signals=q**3,
                global_H_orbits=len(transcripts),
                worst_case_measurements=4)


if __name__=="__main__":
    # A proper-subgroup counter-model is not substituted for a full-phase oracle.
    for p,h in ((3,2),(5,2),(7,3),(19,3),(31,3),(101,5)):
        print("PACKING",one_instance(p,h))
    for p,h in ((3,2),(5,2),(7,3)):
        print("FULL_DECODER",exhaustive_decoder(p,h))
    print("PASS: independent exact finite gate; general theorem review pending")
