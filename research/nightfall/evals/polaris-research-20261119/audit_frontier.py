#!/usr/bin/env python3
"""Independent oracle for the special three-component diagonal-plus-noise family.

Does not import or invoke grade_correlated_influence.py.
"""
from fractions import Fraction as F
from itertools import product

def independent_audit(d):
    n=d["n"]
    cs=d["components"]
    if len(cs)!=3:
        raise ValueError("Three components required")
    weights=[F(c["weight"]) for c in cs]
    p=[[F(v) for v in c["p"]] for c in cs]
    if weights[0]!=weights[1] or weights[0]*2+weights[2]!=1:
        raise ValueError("Invalid weights")
    if p[0]!=[F(0)]*n or p[1]!=[F(1)]*n or p[2]!=[F(1,2)]*n:
        raise ValueError("Unexpected family")
    co=[F(v) for v in d["linear_coefficients"]]
    if len(co)!=n or sorted(co)!=[F(0)]*(n-1)+[F(1)]:
        raise ValueError("Expected one coordinate projection")
    e=weights[2]
    # Conditional influence of the queried projection coordinate:
    # two endpoint fibers each have one high-probability atom and one noise atom;
    # remaining fibers contain two equal noise atoms.
    q=e/F(2**n)
    high=weights[0]+q
    endpoint=2*high*q/(high+q)
    middle=(2**(n-1)-2)*q/F(2)
    influence=endpoint+middle
    variance=F(1,4)
    return {"variance":str(variance),"max_conditional_influence":str(influence),
            "variance_squared_over_max_influence":str(variance**2/influence)}

if __name__=="__main__":
    import json,sys
    print(json.dumps(independent_audit(json.load(open(sys.argv[1]))),sort_keys=True))
