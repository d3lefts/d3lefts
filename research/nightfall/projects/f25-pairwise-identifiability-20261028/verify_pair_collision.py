#!/usr/bin/env python3
"""Independent exact audit of uniform F25 fourth-power information-theoretic injectivity.
No Python packages, network, randomness outside deterministic local fixture generation,
or invocation of an existing NIGHTFALL phase-retrieval implementation.
"""
from fractions import Fraction
from itertools import product
from math import ceil

Q=25
RHO=Fraction(97,625)
def add(x,y):
    return (x[0]+y[0])%5, (x[1]+y[1])%5
def mul(x,y):
    return ((x[0]*y[0]+2*x[1]*y[1])%5,
            (x[0]*y[1]+x[1]*y[0])%5)
def pow4(x):
    y=mul(x,x)
    return mul(y,y)
E=[(a,b) for b in range(5) for a in range(5)]
O=[(a,0) for a in range(1,5)]
Z=(0,0)
def dot(row,x):
    out=Z
    for a,b in zip(row,x):out=add(out,mul(a,b))
    return out
def phase_class(x):
    return min(tuple(mul(o,v) for v in x) for o in O)
def collision_count(x,y):
    assert len(x)==len(y)
    return sum(pow4(dot(row,x))==pow4(dot(row,y))
               for row in product(E,repeat=len(x)))
def check_matrix(rows,expected=None):
    signatures={}
    for x in product(E,repeat=2):
        key=tuple(pow4(dot(row,x)) for row in rows)
        signatures.setdefault(key,set()).add(phase_class(x))
    ambiguous=[v for v in signatures.values() if len(v)>1]
    if expected is not None:assert bool(ambiguous)==expected
    return {'preimages':625,'measurement_classes':len(signatures),
            'ambiguous_signatures':len(ambiguous)}
def generated_rows(seed, count):
    state=seed&((1<<32)-1)
    out=[]
    for _ in range(count):
        row=[]
        for j in range(4):
            state=(1664525*state+1013904223)&((1<<32)-1)
            row.append(state%5)
        out.append(((row[0],row[1]),(row[2],row[3])))
    return out
def main():
    assert 97**7==80798284478113
    assert 5**20==95367431640625
    assert 97**7<5**20
    assert 97**83<625**59
    assert all(pow4(mul(o,a))==pow4(a) for o in O for a in E)
    assert len(set(O))==4
    assert sum(pow4(u)==pow4(v) for u in E for v in E)==97
    assert collision_count(((1,0),Z),(Z,(1,0)))==97
    assert collision_count(((1,0),Z),((0,1),Z))==25 # u is a genuine nonphase scalar
    for k in range(1,8):
        # Phase-orbit count is exact, not a heuristic 1/32 factor.
        p=(Q**k-1)*(Q**k-Q)//32
        if k>1: assert 32*p==(Q**k-1)*(Q**k-Q)
        else: assert p==0
        for s in (1,2,5):
            m=(83*k+23)//24+s
            lines=(Q**k-1)//24
            bound=Fraction(lines,Q**m)+p*RHO**m
            assert bound<Fraction(1,5**s),(k,s,bound)
    # Adversarial designs: known ambiguous outputs.
    identity=check_matrix([((1,0),Z),(Z,(1,0))],expected=True)
    zero=check_matrix([(Z,Z)],expected=True)
    assert identity['measurement_classes']==49
    assert zero['measurement_classes']==1
    # A seeded, genuinely finite exact design: exhaustive 625-signal test.
    selected=None
    for seed in range(1729,1750):
        rows=[((1,0),Z),(Z,(1,0))]+generated_rows(seed,6)
        result=check_matrix(rows)
        if result['ambiguous_signatures']==0:
            selected={'seed':seed,'rows':rows,'result':result}
            break
    assert selected is not None,"no 8-row injective fixture in frozen deterministic search"
    assert selected['result']['measurement_classes']==157
    import json
    print(json.dumps({'status':'PASS','scope':'fixed-q exact finite pair collision and deterministic k=2 injectivity',
                      'q':25,'per_row_independent_collision_numerator':97,
                      'per_row_dependent_nonphase_collision_numerator':25,
                      'required_integer_inequality':'97^83 < 625^59',
                      'identity_two_row_control':identity,'one_zero_row_control':zero,
                      'injective_eight_row_design':selected,
                      'certification':'independent exact finite test; theorem follows from supplied counting proof'},sort_keys=True,indent=2))
if __name__=='__main__':main()
