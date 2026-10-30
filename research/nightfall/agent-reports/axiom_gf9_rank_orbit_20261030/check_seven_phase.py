#!/usr/bin/env python3
"""Exact 38-type signed-sum obstruction in F3^2, for GF9 k=8 adaptive recovery.

No finite-field multiplication or imported search data: powered readings
identify +/- additive elements, so five orbit labels are enough. All 7
coefficient sign-classes reduce via PGL2(3) = S4 and order symmetry to
38 sorted occupancy profiles of 0 plus four projective directions.

This finite checker is a component of an R1 theorem candidate, not Lean.
"""
from collections import Counter
from itertools import product

LINE_REPS=((1,0),(0,1),(1,1),(1,2))
ZERO=(0,0)


def add(a,b):
    return ((a[0]+b[0])%3,(a[1]+b[1])%3)


def negative(a):
    return ((-a[0])%3,(-a[1])%3)


def orbit(a):
    return min(a,negative(a))


def bucket_counts(profile):
    assert len(profile)==5 and sum(profile)==7
    vectors=[ZERO]*profile[0]
    for count, vector in zip(profile[1:],LINE_REPS):
        vectors.extend([vector]*count)
    counts={a:0 for a in ((x,y) for x in range(3) for y in range(3))}
    counts[ZERO]=1
    for vector in vectors:
        nxt={a:0 for a in counts}
        for a,n in counts.items():
            nxt[add(a,vector)]+=n
            nxt[add(a,negative(vector))]+=n
        counts=nxt
    assert sum(counts.values())==128
    # All 128 complete sign patterns occur in +/- pairs, with the
    # same squared output. Division by 2 gives the 64 global-phase words.
    out=Counter()
    for a,n in counts.items():
        out[orbit(a)]+=n
    assert len(out)==5
    assert all(value%2==0 for value in out.values())
    result=sorted((value//2 for value in out.values()),reverse=True)
    assert sum(result)==64
    return tuple(result)


def profiles():
    # PGL_2(F3) acts as S4 on four projective directions.
    # Normalize their multiplicities n1 >= n2 >= n3 >= n4.
    for zero_count in range(8):
        remaining=7-zero_count
        for n1 in range(remaining+1):
            for n2 in range(n1+1):
                for n3 in range(n2+1):
                    n4=remaining-n1-n2-n3
                    if 0<=n4<=n3:
                        yield (zero_count,n1,n2,n3,n4)



def adaptive_rank_schedules():
    """All 128 possible independent/dependent schedules after a nonzero root.

    In the adversarial chosen branch, each independent row is assigned
    nonzero powered outcome 1, adding one relative sign bit. Each
    dependent reading partitions the retained sign set into at most
    5 observable values. Choose its largest nonempty bucket.
    """
    exceptions=[]
    for pattern in product((1,0),repeat=7):
        rank=1
        phases=1
        for independent in pattern:
            if independent:
                rank+=1
                phases*=2
            else:
                phases=(phases+4)//5
        orbits=phases * (9**(8-rank))
        if orbits<=5**3:
            exceptions.append({
                "pattern":"I"+"".join("I" if z else "D" for z in pattern),
                "rank":rank,
                "phase_count_from_pigeonhole":phases,
                "orbit_count_from_pigeonhole":orbits,
            })
    assert exceptions==[{
        "pattern":"IIIIIIID","rank":7,
        "phase_count_from_pigeonhole":13,
        "orbit_count_from_pigeonhole":117,
    }],exceptions
    # In the ONLY surviving rank pattern, seven independent rows with
    # nonzero squared readings give 64 anchored signs and one GF9 free
    # coordinate. Exact phase classification raises 13 to 14:
    assert 14*9==126 > 5**3==125
    return {"total_rank_schedules":2**7,
            "pigeonhole_survivors":exceptions,
            "sharp_last_row_phase_capacity":14,
            "certified_final_orbits":126,
            "remaining_three_query_capacity":125}



def audit():
    results={p:bucket_counts(p) for p in profiles()}
    assert len(results)==38
    smallest=min(b[0] for b in results.values())
    assert smallest==14,smallest
    unique=[(p,b) for p,b in results.items() if b[0]==smallest]
    assert unique==[((1,2,2,2,0),(14,14,14,12,10))],unique
    # The orbit class of the unique best profile contains
    # 7!/(1!2!2!2!) * 4 choices of the missing direction.
    assert (5040//8)*4==2520
    schedule=adaptive_rank_schedules()
    return {
        "adaptive_schedules":schedule,
        "field_additive_group":"F3^2",
        "coefficient_projective_directions":4,
        "coefficient_orbit_types":len(results),
        "normalized_coefficient_words":5**7,
        "minimum_max_bucket":smallest,
        "sharp_profile":unique[0][0],
        "sharp_bucket_sizes":unique[0][1],
        "sharp_normalized_words":2520,
        "status":"EXACT_INTERNAL_38_TYPE_CERTIFICATE"
    }


if __name__=="__main__":
    print("PASS",audit())
