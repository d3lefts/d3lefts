#!/usr/bin/env python3
"""General rank/phase palette recurrence for exact GF9 adaptive lower bounds.

An adaptive prefix with first nonzero squared reading has rank r and N
compatible relative sign assignments (one global sign anchored). New
independent row with chosen square 1: (r,N)->(r+1,2N).
Dependent row: (r,N)->(r,at least ceil(N/5)).
Each sign represents 9^(k-r) distinct global sign-orbits.
Enumerate ALL I/D branch-rank histories for one fixed prefix length.
"""
from itertools import product


def audit_dimension(k, attempted, prefix, known_upper):
    assert k>=prefix>=2
    capacity=5**(attempted-prefix)
    minimum=None
    minimizer=None
    cnt=0
    for decisions in product((0,1),repeat=prefix-1):
        rank=1
        phase=1
        for is_independent in decisions:
            if is_independent:
                rank+=1
                phase*=2
            else:
                phase=(phase+4)//5
        surviving=phase*9**(k-rank)
        if minimum is None or surviving<minimum:
            minimum=surviving
            minimizer=decisions
        cnt+=1
    assert cnt==2**(prefix-1)
    assert minimum>capacity,(k,attempted,minimum,capacity)
    assert known_upper==attempted+1
    return {"k":k,"attempted_queries":attempted,
            "prefix":prefix,"branch_rank_histories":cnt,
            "minimum_orbit_fiber":minimum,
            "remaining_output_capacity":capacity,
            "witness_minimizing_rank_schedule": "".join(
                "I" if j else "D" for j in minimizer),
            "lower_bound":attempted+1,
            "known_constructive_upper":known_upper,
            "conditional_exact":attempted+1}


def main():
    results=(audit_dimension(6,8,4,9),
             audit_dimension(9,12,3,13),
             audit_dimension(11,15,7,16),
             audit_dimension(13,18,13,19))
    assert results[0]["minimum_orbit_fiber"]==648
    assert results[1]["minimum_orbit_fiber"]==2125764
    # Deliberate negative control: GF9 square queries have five,
    # not nine or six, possible outputs; a weaker comparison can fail.
    assert results[2]["minimum_orbit_fiber"]<=9**(15-7)
    for item in results:
        print("PASS",item)
    print("Status: R1 exact arithmetic corollaries; external review open")


if __name__=="__main__":
    main()
