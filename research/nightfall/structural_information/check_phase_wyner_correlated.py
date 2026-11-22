#!/usr/bin/env python3
"""Exact rational controls for correlated phase-block Wyner separation.

Reconstructs #1084's literal eight integer signal representatives and four
squared-linear sensor rows, then enumerates B=1,2,3 hidden product mixtures.
No C_W optimization or general-B Lean theorem is claimed here.
"""
from collections import defaultdict
from fractions import Fraction
from itertools import combinations, product
from math import log2
import json

SIGNALS = ((0,1),(1,-2),(1,0),(1,2),(3,-2),(3,2),(2,1),(2,3))
SENSORS = ((1,0),(0,1),(1,1),(1,-1))
CODE = tuple(tuple((a*x+b*y)**2 for a,b in SENSORS) for x,y in SIGNALS)

def hamming(a,b):
    return sum(x!=y for x,y in zip(a,b))

def conditional(symbol,w):
    return Fraction(3,16) if (symbol//4)==w else Fraction(1,16)

def joint(words):
    return sum((Fraction(1,2) *
               prod([conditional(s,w) for s in words])
               for w in (0,1)),Fraction(0))

def prod(vals):
    out=Fraction(1)
    for p in vals:
        out*=p
    return out

def encode(words):
    return tuple(v for s in words for v in CODE[s])

def entropy(p):
    return -sum(float(x)*log2(float(x)) for x in p if x)

def run():
    assert len(set(CODE)) == 8
    assert all(0<=v<=25 for code in CODE for v in code)
    assert all(len({tuple(row[j] for j in cols) for row in CODE}) == 8
               for cols in combinations(range(4),3))
    assert min(hamming(x,y) for x,y in combinations(CODE,2))==2
    assert all(sum(conditional(i,w) for i in range(8))==1 for w in (0,1))
    assert all((conditional(i,0)+conditional(i,1))/2==Fraction(1,8)
               for i in range(8))
    target=Fraction(5,16)
    both=sum((joint((i,j)) for i in range(4) for j in range(4)),Fraction(0))
    assert both==target and both>Fraction(1,4)

    records=[]
    hcond=2+(-Fraction(1,4)*log2(1/4)-Fraction(3,4)*log2(3/4))
    for B in (1,2,3):
        words=tuple(product(range(8),repeat=B))
        law={x:joint(x) for x in words}
        assert sum(law.values(),Fraction())==1
        assert all(q>0 for q in law.values())
        encoded={encode(x):q for x,q in law.items()}
        assert len(encoded)==8**B
        assert min(hamming(x,y) for x,y in combinations(encoded,2))==2
        H=entropy(law.values())
        assert B*(float(hcond))-1e-11 <= H <= B*(float(hcond))+1+1e-11
        records.append({
            "B":B,
            "positive_words":len(words),
            "raw_coordinates":4*B,
            "minimum_raw_hamming":2,
            "joint_mass_exact":"1/1",
            "raw_entropy_bits_display":round(H,9),
            "conditional_entropy_lower_bits_display":round(B*float(hcond),9),
            "decoded_wyner_upper_bits_from_shared_latent":1,
        })

    print(json.dumps({
        "schema":"nightfall.correlated-phase-wyner-finite.v1",
        "model":"literal #1084 integer raw squared-linear sensors",
        "single_block_marginal":"1/8 per symbol",
        "pair_event_exact":"5/16",
        "pair_event_independence_reference":"1/4",
        "shared_latent_entropy_bits":1,
        "all_B_wyner": "paper_support_rectangle_entropy_proof_not_finite_optimization",
        "finite_B_checks":records,
        "lean_terminal_certified":False,
        "novelty_certified":False,
    },sort_keys=True))
if __name__=="__main__":
    run()
