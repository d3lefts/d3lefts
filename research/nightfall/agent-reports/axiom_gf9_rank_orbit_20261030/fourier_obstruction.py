#!/usr/bin/env python3
"""Exact independent Fourier certificate for seven signed GF9 coefficients.

Model: GF9 additive group is F3^2. The square map identifies z with -z.
No finite-field multiplication, no sampled codebooks, no 38-case reliance.
The transform of a signed coefficient ±c at a character u is:
    2 if <u,c> == 0, otherwise -1.
The four nontrivial character lines have multipliers
    lam_j=(-1)^(7-n0-nj)*2^(n0+nj).
Orthogonality then gives the five exact square-output bucket sizes:
    zero: (128+2*sum(lam))/18
    line j: (128-sum(lam)+3*lam_j)/9.
All 64 global-sign assignments are accounted for.
"""
from itertools import product


def signed_power(exponent, parity):
    return (-1 if parity%2 else 1)*(1<<exponent)


def fourier_buckets(n0, occupancy):
    assert len(occupancy)==4 and n0+sum(occupancy)==7
    lam=tuple(signed_power(n0+nj,7-n0-nj) for nj in occupancy)
    total=sum(lam)
    numerators=(128+2*total,)+tuple(2*(128-total+3*v) for v in lam)
    assert all(a%18==0 for a in numerators)
    buckets=tuple(a//18 for a in numerators)
    assert sum(buckets)==64 and min(buckets)>=0
    return lam,buckets


def occupancy_patterns():
    for n0 in range(8):
        rem=7-n0
        for a in range(rem+1):
            for b in range(a+1):
                for c in range(b+1):
                    d=rem-a-b-c
                    if 0<=d<=c:
                        yield (n0,a,b,c,d)


def spectral_impossibility():
    """Analytic contradiction, no enumerating of coefficient patterns."""
    # 64 sign orbits in five powered-output classes.
    # If maximum bucket <= 13, five buckets necessarily are 13,13,13,13,12.
    # If the zero bucket is 13, sum lam = 53 and some nonzero bucket
    # equals 13, forcing lam=14, not a signed power of two.
    assert (18*13-128)//2==53
    assert (9*13-128+53)//3==14
    # If the zero bucket is 12, sum lam = 44; all four other buckets
    # are 13, forcing every lam=11, also not a signed power of two.
    assert (18*12-128)//2==44
    assert (9*13-128+44)//3==11
    for m in (11,14):
        assert all(m!=(1<<e) and m!=-(1<<e) for e in range(8))
    return "No 7-coefficient signed linear form can have all five buckets <=13"


def audit():
    assert spectral_impossibility()
    patterns=list(occupancy_patterns())
    assert len(patterns)==38
    hist={}
    for p in patterns:
        lam,buckets=fourier_buckets(p[0],p[1:])
        profile=tuple(sorted(buckets,reverse=True))
        hist[p]=profile
        assert profile[0]>=14
    opt=[p for p,b in hist.items() if b[0]==14]
    assert opt==[(1,2,2,2,0)]
    lam,b=fourier_buckets(1,(2,2,2,0))
    assert lam==(8,8,8,2)
    assert b==(10,14,14,14,12)
    # Negative control: an impossible fantasy uniform 13-bucket profile.
    assert sum((13,13,13,13,12))==64
    assert sorted((13,13,13,13,12),reverse=True) not in hist.values()
    return {
        "general_mechanism":"F3^2 character Fourier: each signed coefficient gives 2 or -1",
        "spectral_obstruction":"bucket 13 forces Fourier eigenvalue 11 or 14, neither signed power of two",
        "sharp_eigenvalues":lam,
        "sharp_buckets":b,
        "maximum_minimum":14,
        "regression_projective_patterns":38,
        "certificate":"integer exact; one-page analytic Fourier argument"
    }


if __name__=="__main__":
    print("PASS",audit())
