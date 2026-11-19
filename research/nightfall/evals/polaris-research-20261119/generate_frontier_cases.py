#!/usr/bin/env python3
"""Reproducible public task variants. Keep private scoring seeds outside git."""
import argparse
import json
import random
from fractions import Fraction as F
from pathlib import Path
from grade_correlated_influence import evaluate

def make_case(seed, n=None):
    rng = random.Random(seed)
    n = n if n is not None else rng.randint(7, 11)
    if not 7 <= n <= 12:
        raise ValueError("n must be 7..12 for this generator")
    # Positive, rational, full-support noise; extreme correlation remains.
    den = rng.choice((50000, 100000, 200000))
    noise = F(1, den)
    half = (1-noise)/2
    j = rng.randrange(n)
    coeff = ["0"]*n
    coeff[j] = "1"
    return {"n":n,"components":[
        {"weight":str(half),"p":["0"]*n},
        {"weight":str(half),"p":["1"]*n},
        {"weight":str(noise),"p":["1/2"]*n}],
        "linear_coefficients":coeff}

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--seed",type=int,required=True)
    ap.add_argument("--n",type=int)
    ap.add_argument("--output",type=Path,required=True)
    a=ap.parse_args()
    case=make_case(a.seed,a.n)
    assert evaluate(case)["valid"], "Generator produced an invalid witness"
    a.output.write_text(json.dumps(case,indent=2)+"\n")
    print("Generated exact-valid witness; do not disclose private seeds or outputs to evaluated agents")

if __name__=="__main__":
    main()
