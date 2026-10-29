#!/usr/bin/env python3
"""Sharpness certificate: three added AP marks defeat universal +3 extension.

No optimization oracle. Complete 33-choose-4 difference test, explicit Sidon-19
lower certificate, and a short combinatorial upper bound using the 3AP.
"""
from pathlib import Path
from itertools import combinations
from math import comb
import hashlib, json

HERE=Path(__file__).resolve().parent
SOURCE_SHA="dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f"
raw=(HERE/"witness_30.txt").read_bytes()
assert hashlib.sha256(raw).hexdigest()==SOURCE_SHA
B=tuple(map(int,raw.strip().split(b",")))
assert len(B)==30 and len(set(B))==30

def four_five(values):
    inspected=0
    for q in combinations(values,4):
        inspected+=1
        differences={abs(b-a) for a,b in combinations(q,2)}
        if len(differences)<5:return False,inspected,q
    return True,inspected,None

def sidon(values):
    sums=[]
    for i,x in enumerate(values):
        for y in values[i:]:
            sums.append(x+y)
    return len(sums)==len(set(sums))

M=40_000_000
added=(M+1,2*M+1,3*M+1)
assert added[0]+added[2]==2*added[1], "three-point progression missing"
assert set(B).isdisjoint(added)
condition,total,bad=four_five(B+added)
assert condition and total==comb(33,4),(total,bad)

portfolio=json.loads((HERE/"portfolio_certificate.json").read_text())["portfolio"]
S=tuple(portfolio[0])
assert len(S)==17 and set(S)<=set(B) and sidon(S)
assert sidon(S+added[:2])
# Since added is a 3-term progression, a Sidon set includes <=2 of them.
# Every Sidon subset of B has <=17 points (proved independently by
# verify_independent.py, which is a separate mandatory CI step).
# Consequently h(B+added) <=17+2=19; exhibited S+added[:2] attains 19.
invariant_fail,_,counter=four_five(B+(M,2*M,3*M))
assert not invariant_fail and set((0,M,2*M,3*M))==set(counter),counter

receipt={
    "status":"PASS - explicit 33-point sharpness certificate",
    "domain":"specific fixed integer (4,5) witness",
    "base_sha256":SOURCE_SHA,
    "base_size":30,"base_max_sidon":17,
    "new_points":added,"total_size":33,"exact_max_sidon":19,
    "four_point_difference_checks":total,
    "explicit_sidon_subset":S+added[:2],
    "upper_bound":"All 3 new marks form one AP; any Sidon subset uses <=2. Old 30-point exact maximum is 17.",
    "negative_control":"Changing offset from 1 to 0 violates (4,5): {0,M,2M,3M}.",
    "discovery_status":"sharpness of universal 1-/2-point extension guarantee; no new global extremal bound or priority claim"
}
print(json.dumps(receipt,indent=2,sort_keys=True))
