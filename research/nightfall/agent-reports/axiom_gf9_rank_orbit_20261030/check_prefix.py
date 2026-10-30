#!/usr/bin/env python3
"""Proof-relevant exact integer checks for an adaptive powered-orbit rank barrier.

This is a numerical checker of exact inequalities + independently enumerated
small prefix fibers, NOT a formal proof of the universal adversary argument.
No outside packages, stochastic search, or model queries.
"""
from itertools import product
from math import ceil


def output_alphabet(q, h):
    assert q >= 3 and h > 1 and (q-1)%h==0
    return 1+(q-1)//h


def orbit_count(q, h, k):
    assert k >= 1
    return 1+(q**k-1)//h


def smallest_count_bound(q,h,k):
    L=output_alphabet(q,h)
    target=orbit_count(q,h,k)
    m=0
    while L**m < target:
        m+=1
    return m


def rank_orbit_obstruction(q,h,k,m,t):
    """A t-prefix adversary forces > L^(m-t) classes in one node.

    If any row dependency occurs by depth t, its rank r<=t-1, and a
    nonzero first powered reading makes the fiber contain >=q^(k-r)
    distinct global H-orbits. If all t rows are linearly independent,
    prescribe nonzero powered readings and obtain exactly
    h^(t-1)*q^(k-t) orbits. The first row may be taken nonzero WLOG:
    an identically-zero first query carries no information.
    """
    assert k>=t>=2 and m>=t
    L=output_alphabet(q,h)
    degenerate=q**(k-t+1)
    independent=h**(t-1)*q**(k-t)
    remaining=L**(m-t)
    return {
        "q":q,"h":h,"k":k,"attempted_queries":m,"prefix":t,
        "rank_drop_min":degenerate,
        "all_independent_min":independent,
        "remaining_transcript_capacity":remaining,
        "forbidden":min(degenerate,independent)>remaining,
    }


def lower_bound_by_prefix(q,h,k,search_limit=None):
    basic=smallest_count_bound(q,h,k)
    upper=search_limit or (2*k+2)
    ruled_out=[]
    for m in range(basic,upper):
        certificates=[rank_orbit_obstruction(q,h,k,m,t)
                      for t in range(2,min(k,m)+1)]
        witness=next((c for c in certificates if c["forbidden"]),None)
        if witness is None:
            return {"counting":basic,"prefix_lower":m,
                    "ruled_out":ruled_out}
        ruled_out.append(witness)
    raise AssertionError("search bound insufficient")


def gf9_mul(a,b):
    """GF3[u]/(u²+1), encoded a0+3*a1 (u²=2)."""
    x,y=a%3,a//3; z,w=b%3,b//3
    return ((x*z+2*y*w)%3)+3*((x*w+y*z)%3)


def gf9_square(a):
    return gf9_mul(a,a)


def orbit_rep(vector):
    neg=tuple((-v)%3+3*((-v//3)%3) for v in vector) # overwritten below
    # Correct pair representation; coordinatewise additive inverse in GF9.
    def negate(x):
        return ((-x%3)+3*(-(x//3)%3))
    neg=tuple(negate(z) for z in vector)
    return min(vector,neg)


def independent_prefix_orbits(k=6):
    """Direct concrete GF9 witness: first 4 independent powers each 1."""
    assert k==6
    observed={}
    for signs in product((1,2),repeat=4): # ±1 inside the prime subfield
        assert all(gf9_square(z)==1 for z in signs)
        for tail in product(range(9),repeat=k-4):
            vec=signs+tail
            observed[orbit_rep(vec)]=True
    assert len(observed)==648
    return len(observed)


def dependent_prefix_orbits():
    """First 3 coordinate squares = 1; 4th is (x1+x2+x3)².

    Fourth form is dependent; every branch has at least 9³ orbits.
    This also tests that y=0 is a valid output and is not discarded.
    """
    by_measurement={}
    for signs in product((1,2),repeat=3):
        summed=sum(signs)%3
        fourth=gf9_square(summed)
        for tail in product(range(9),repeat=3):
            v=signs+tail
            rep=orbit_rep(v)
            by_measurement.setdefault(fourth,set()).add(rep)
    sizes={y:len(fiber) for y,fiber in by_measurement.items()}
    assert sizes=={0:729,1:2187},sizes
    return sizes


def self_test():
    assert output_alphabet(9,2)==5
    assert orbit_count(9,2,6)==265721
    assert orbit_count(9,2,9)==193710245
    results={}
    for k,baseline,ours,known_upper,prefix in (
        (6,8,9,9,4),
        (8,11,11,12,None),
        (9,12,13,13,3),
    ):
        item=lower_bound_by_prefix(9,2,k)
        assert (item["counting"],item["prefix_lower"])==(baseline,ours),item
        if prefix:
            c=rank_orbit_obstruction(9,2,k,baseline,prefix)
            assert c["forbidden"]
            item["witness"]=c
        results[k]={"information_lower":baseline,
                    "rank_lower":ours,
                    "known_constructive_upper":known_upper,
                    "optimal_within_recorded_construction":ours==known_upper,
                    "witness":item.get("witness")}
    assert independent_prefix_orbits()==648
    assert dependent_prefix_orbits()=={0:729,1:2187}
    # Perturbation/negative control: the universal condition is sensitive
    # to the exact allowed output alphabet. Falsely counting 6 per query
    # cannot justify the k=6 rank-prefix 8-query impossibility.
    false_alphabet_capacity=6**4
    assert 648 <= false_alphabet_capacity
    # The full powered-output alphabet of GF9 is FIVE, not six.
    assert 5**4==625 <648
    return results


if __name__=="__main__":
    import json
    print(json.dumps(self_test(),indent=2,sort_keys=True))
    print("PASS: exact integer rank-orbit prefix gates and direct GF9 fibers")
