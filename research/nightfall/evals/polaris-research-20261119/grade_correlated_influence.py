#!/usr/bin/env python3
"""Exact finite-product-mixture counterexample grader. No external dependencies.

Tests a deliberately FALSE distribution-free influence inequality. It is not
an audit of the product-law Aaronson--Ambainis theorem.
"""
import itertools
import json
import sys
from fractions import Fraction as F
from pathlib import Path

def rat(x):
    if isinstance(x, bool) or isinstance(x, float):
        raise ValueError("Use exact rational strings or integers, never floats")
    return F(x)

def evaluate(data, minimum_ratio=1000, max_n=12):
    n = data["n"]
    if not isinstance(n, int) or isinstance(n, bool) or not (3 <= n <= max_n):
        raise ValueError("n must be an integer in [3, 12]")
    comps = data["components"]
    if not 2 <= len(comps) <= 4:
        raise ValueError("Use 2 to 4 product components")
    weights = []
    for comp in comps:
        w = rat(comp["weight"])
        ps = [rat(v) for v in comp["p"]]
        if len(ps) != n or w <= 0 or any(p < 0 or p > 1 for p in ps):
            raise ValueError("Invalid component weights or Bernoulli probabilities")
        weights.append(w)
    if sum(weights) != 1:
        raise ValueError("Mixture weights must sum to 1")
    if not all(any(0 < rat(c["p"][j]) < 1 for c in comps) for j in range(n)):
        raise ValueError("Each coordinate must have a nondegenerate component")
    coeff = [rat(v) for v in data["linear_coefficients"]]
    offset = rat(data.get("offset", "0"))
    if len(coeff) != n or sum(abs(c) for c in coeff) == 0:
        raise ValueError("Nonconstant linear polynomial required")
    states = list(itertools.product((0, 1), repeat=n))
    mass, value = {}, {}
    for x in states:
        prob = F(0)
        for c in comps:
            p = [rat(v) for v in c["p"]]
            term = rat(c["weight"])
            for j, bit in enumerate(x):
                term *= p[j] if bit else (1-p[j])
            prob += term
        mass[x] = prob
        value[x] = offset + sum((coeff[j]*x[j] for j in range(n)), F(0))
    if any(p <= 0 for p in mass.values()):
        raise ValueError("Full support required: all 2^n atoms positive")
    if min(value.values()) < 0 or max(value.values()) > 1:
        raise ValueError("f must be [0,1]-valued on entire cube")
    mean = sum((mass[x]*value[x] for x in states), F(0))
    var = sum((mass[x]*(value[x]-mean)**2 for x in states), F(0))
    influences = []
    for j in range(n):
        inf = F(0)
        for other in itertools.product((0,1), repeat=n-1):
            lo = list(other); lo.insert(j,0); lo=tuple(lo)
            hi = list(other); hi.insert(j,1); hi=tuple(hi)
            a,b=mass[lo],mass[hi]
            inf += a*b/(a+b)*(value[hi]-value[lo])**2
        influences.append(inf)
    imax = max(influences)
    ratio = var**2/imax if imax else None
    ok = var > 0 and imax > 0 and ratio >= minimum_ratio
    return {
        "valid": bool(ok), "n": n, "degree": 1, "full_support": True,
        "variance": str(var), "max_conditional_influence": str(imax),
        "variance_squared_over_max_influence": str(ratio),
        "threshold": minimum_ratio
    }

def main():
    if len(sys.argv) not in (2,3):
        raise SystemExit("usage: python3 grade_correlated_influence.py witness.json [threshold]")
    d=json.loads(Path(sys.argv[1]).read_text())
    out=evaluate(d,int(sys.argv[2]) if len(sys.argv)==3 else 1000)
    print(json.dumps(out,sort_keys=True))
    return 0 if out["valid"] else 1

if __name__=="__main__":
    sys.exit(main())
