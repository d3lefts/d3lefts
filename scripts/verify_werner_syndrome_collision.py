#!/usr/bin/env python3
"""Independent finite exact audit of 72 qutrit four-copy syndrome collisions.
Two arithmetic representations:
  A: tensor-product local Werner kernel
  B: explicit partial-trace inclusion-exclusion over 16 subsets.
No external arithmetic dependencies or approximate eigenvalues.
"""
from __future__ import annotations
from collections import Counter
from itertools import product
from pathlib import Path
import json
import hashlib

ROOT=Path(__file__).resolve().parent.parent
DATA=ROOT/"research/nightfall/projects/werner-syndrome-collision/72_collision_witnesses.json"
F3=range(3)
WORDS=tuple(product(F3,repeat=4))
H=lambda a: ((a[2]-a[0]-a[1])%3,(a[3]-a[0]-2*a[1])%3)
KEYS=tuple(product(F3,repeat=2))
COS={s:tuple(a for a in WORDS if H(a)==s) for s in KEYS}
S=((0,0),(1,0),(2,0))
T=((0,0),(0,1),(0,2))
BASE={(s,t) for s in S for t in T}
DIFFERENCE=lambda s,t:((s[0]-t[0])%3,(s[1]-t[1])%3)


def local_tensor(a,b,c,d):
    """Return 16 times the exact matrix element, using a local product."""
    p=1
    for k in range(4):
        p*=2*int(a[k]==c[k] and b[k]==d[k])-int(a[k]==b[k] and c[k]==d[k])
    return p


def inclusion_exclusion(a,b,c,d):
    """Separate 16-term signed partial-trace expansion."""
    total=0
    for mask in range(16):
        term=(-1 if mask.bit_count()%2 else 1)*2**(4-mask.bit_count())
        for k in range(4):
            if mask & (1<<k):
                term*=int(a[k]==b[k])*int(c[k]==d[k])
            else:
                term*=int(a[k]==c[k])*int(b[k]==d[k])
        total+=term
    return total


def parse_word(x):
    if not isinstance(x,str) or len(x)!=4 or any(ch not in "012" for ch in x):
        raise ValueError("Invalid F3 word")
    return tuple(map(int,x))


def parse_syndrome(x):
    if not isinstance(x,str) or len(x)!=2 or any(ch not in "012" for ch in x):
        raise ValueError("Invalid syndrome")
    return tuple(map(int,x))


def validate(obj):
    if obj.get("format")!="NIGHTFALL-WERNER-SYNDROME-COLLISION-v1":
        raise ValueError("Certificate type mismatch")
    old_to_diff={DIFFERENCE(s,t):(s,t) for s,t in BASE}
    if len(old_to_diff)!=9 or len(BASE)!=9:
        raise ValueError("The original nine sectors do not have unique differences")
    allkeys={(s,t) for s in KEYS for t in KEYS}
    if len(allkeys-BASE)!=72:
        raise ValueError("Unexpected sector count")
    witnesses=obj.get("witnesses",[])
    if len(witnesses)!=72:
        raise ValueError("Incomplete witness table")
    covered=set()
    hist=Counter()
    examples=0
    for row in witnesses:
        new=(parse_syndrome(row["added"][0]),parse_syndrome(row["added"][1]))
        old=(parse_syndrome(row["collides_with"][0]),parse_syndrome(row["collides_with"][1]))
        if new not in allkeys-BASE or new in covered:
            raise ValueError("Omitted, repeated or invalid additional sector")
        covered.add(new)
        if old!=old_to_diff[DIFFERENCE(*new)]:
            raise ValueError("Collision target is incorrect")
        if parse_syndrome(row["difference"])!=DIFFERENCE(*new):
            raise ValueError("Incorrect difference label")
        a,b,c,d=[parse_word(row[k]) for k in ("a","b","c","d")]
        if H(a)!=old[0] or H(b)!=old[1] or H(c)!=new[0] or H(d)!=new[1]:
            raise ValueError("Basis matrix unit lies outside its sector")
        val_a=local_tensor(a,b,c,d)
        val_b=inclusion_exclusion(a,b,c,d)
        if val_a!=val_b or val_a!=row["numerator"] or abs(val_a)<4:
            raise ValueError("Cross-sector coefficient invalid")
        hist[abs(val_a)]+=1
        examples+=1
    if covered!=allkeys-BASE:
        raise ValueError("A possible extension was missed")
    if hist!=Counter({4:16,8:56}):
        raise ValueError(f"Unexpected exact witness classification: {hist}")
    # Additional independent full 81×81 matrix-unit maximum calculation:
    # uses the product formula, while every selected witness gets the
    # independently derived 16-term signed partial-trace check.
    max_hist=Counter()
    for added in sorted(allkeys-BASE):
        old=old_to_diff[DIFFERENCE(*added)]
        maximum=0
        for a in COS[old[0]]:
            for b in COS[old[1]]:
                for c in COS[added[0]]:
                    for d in COS[added[1]]:
                        q=abs(local_tensor(a,b,c,d))
                        if q>maximum:maximum=q
        max_hist[maximum]+=1
    if max_hist!=Counter({4:16,8:56}):
        raise ValueError("Complete tensor-kernel cross-sector maximum disagrees")
    return {"status":"PASS","baseline_sector_pairs":9,
            "all_outside_sector_pairs":72,"quantitative_rank_two_crossings":examples,
            "minimum_absolute_cross_entry":"1/4",
            "exact_maximum_absolute_entry_counts":{"1/4":16,"1/2":56},
            "independent_coefficient_formula":"16-term partial-trace inclusion-exclusion",
            "rank_two_witness":"Each pair of distinct matrix units has sum rank <=2",
            "scope":"four physical qutrit copies at t=1/2; disproves orthogonal-block additivity for all 72 one-block support extensions; does not disprove positivity"}


def main():
    raw=DATA.read_bytes()
    obj=json.loads(raw)
    print(json.dumps(validate(obj),indent=2,sort_keys=True))
    # Adversarial mutation fixture.
    altered=json.loads(raw)
    altered["witnesses"][0]["numerator"]=0
    try:
        validate(altered)
    except ValueError:
        print("PASS: tampered tensor cross-term was rejected")
    else:
        raise AssertionError("corrupt witness accepted")
    print("certificate_sha256="+hashlib.sha256(raw).hexdigest())


if __name__=="__main__":
    main()
