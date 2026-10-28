#!/usr/bin/env python3
"""Exact Cayley-table audit of an involution-shadow encoding. Python stdlib only.
For every supplied finite group instance, verifies group law, automorphism,
right-orbit codewords, distances, full pair spectrum and the claimed optimum.
The universal theorem's proof is in NONABELIAN_SHADOW_THEOREM.md.
"""
from collections import Counter
from pathlib import Path
import json
import sys

def certify(spec):
    table=spec["cayley_table"];sigma=spec["automorphism"];shifts=spec["translations"]
    g=len(table)
    assert g>=2 and all(len(row)==g and set(row)==set(range(g)) for row in table)
    assert len(sigma)==g and sorted(sigma)==list(range(g))
    assert shifts and all(type(t) is int and 0<=t<g for t in shifts)
    es=[e for e in range(g) if all(table[e][x]==table[x][e]==x for x in range(g))]
    assert len(es)==1
    e=es[0]
    assert all(table[table[a][b]][c]==table[a][table[b][c]]
               for a in range(g) for b in range(g) for c in range(g))
    inverses=[]
    for a in range(g):
        candidates=[b for b in range(g) if table[a][b]==table[b][a]==e]
        assert len(candidates)==1
        inverses.append(candidates[0])
    assert sigma!=list(range(g)) and all(sigma[sigma[i]]==i for i in range(g))
    assert all(sigma[table[a][b]]==table[sigma[a]][sigma[b]]
               for a in range(g) for b in range(g))
    H={i for i in range(g) if sigma[i]==i}
    labels=[table[sigma[t]][inverses[t]] for t in range(g)]
    C=set(labels);h=len(H);q=g//h
    assert q*h==g and len(C)==q
    assert all(labels.count(c)==h for c in C)
    n=Counter(labels[t] for t in shifts)
    m=len(shifts)
    expected_distance=m-max(n.values())
    observed=Counter()
    for x in range(g):
        for y in range(g):
            if x==y:continue
            agreement=sum(
                (lambda u,v:u==v or u==sigma[v])(table[x][t],table[y][t])
                for t in shifts
            )
            observed[m-agreement]+=1
    predicted=Counter()
    for c in range(g):
        if c in C:predicted[m-n[c]]+=g-h
        else:predicted[m]+=g
    assert observed==predicted and min(observed)==expected_distance
    claims=spec.get("claims",{})
    values={
        "fixed_subgroup_size":h,
        "label_count":q,
        "actual_minimum_distance":expected_distance,
        "optimal_minimum_distance":m-(m+q-1)//q,
    }
    for key,value in claims.items():
        assert key in values and value==values[key],(key,value,values.get(key))
    return {
        "status":"PASS","group_order":g,"fixed_subgroup_order":h,
        "label_count":q,"measurement_length":m,
        "minimum_distance":expected_distance,
        "maximum_possible_distance_at_this_length":m-(m+q-1)//q,
        "ordered_pair_spectrum":dict(sorted(observed.items())),
        "pairwise_orbit_comparisons":g*(g-1)*m
    }

if __name__=="__main__":
    if len(sys.argv)!=2:raise SystemExit("Usage: certify_nonabelian_instance.py cert.json")
    print(json.dumps(certify(json.loads(Path(sys.argv[1]).read_text())),indent=2))
