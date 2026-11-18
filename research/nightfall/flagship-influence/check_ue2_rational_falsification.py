#!/usr/bin/env python3
"""Exact rational counterexample certificate checker for UE2 on finite products.

Passing any finite test DOES NOT prove universal influence. A strict
rational violation is a valid falsification of the specified coefficient.
All probabilities are positive, with sum one in each original coordinate.
No third-party dependencies; independent conditional and pairwise influences.
"""
from fractions import Fraction as Q
from itertools import product, combinations
from math import prod
import argparse
import json


def frac(v):
    assert isinstance(v, (str, int)) and not isinstance(v, bool)
    return Q(v)


def subsets(t):
    return (frozenset(z) for k in range(len(t)+1) for z in combinations(t,k))


def analyze(ob):
    p=[[frac(v) for v in row] for row in ob["probabilities"]]
    n=len(p)
    assert n>=1 and all(len(row)>=2 and all(v>0 for v in row)
                        and sum(row)==1 for row in p)
    xs=tuple(product(*(range(len(row)) for row in p)))
    vals=tuple(frac(x) for x in ob["values"])
    assert len(xs)==len(vals)
    f=dict(zip(xs,vals))
    d=int(ob["degree"])
    k=int(ob.get("degree_power",2))
    C=frac(ob.get("constant","1"))
    assert 1<=d and k>=0 and C>=0
    mass={x:prod(p[i][x[i]] for i in range(n)) for x in xs}
    assert sum(mass.values(),Q(0))==1
    mean=sum((mass[x]*f[x] for x in xs),Q(0))
    V=sum((mass[x]*(f[x]-mean)**2 for x in xs),Q(0))
    B=(max(vals)-min(vals))/2

    # Source-law conditional variances, not unweighted table flips.
    influences=[]
    for i in range(n):
        other=tuple(j for j in range(n) if j!=i)
        I=Q(0)
        for rest in product(*(range(len(p[j])) for j in other)):
            x=[0]*n
            for j,a in zip(other,rest): x[j]=a
            weight=prod(p[j][x[j]] for j in other)
            sl=[]
            for a in range(len(p[i])):
                x[i]=a
                sl.append(f[tuple(x)])
            av=sum((p[i][a]*sl[a] for a in range(len(sl))),Q(0))
            I+=weight*sum((p[i][a]*(sl[a]-av)**2
                          for a in range(len(sl))),Q(0))
        influences.append(I)
    M=max(influences)

    # Independent law-free degree audit: anchored Mobius differences.
    degree=0
    for x in xs:
        active=tuple(i for i in range(n) if x[i]!=0)
        h=Q(0)
        for T in subsets(active):
            y=tuple(x[i] if i in T else 0 for i in range(n))
            h+=(-1)**(len(active)-len(T))*f[y]
        if h:
            degree=max(degree,len(active))
    assert degree<=d, f"degree is {degree}, greater than declared {d}"

    # Second, algebraically independent two-replica resampling audit.
    for i in range(n):
        other=tuple(j for j in range(n) if j!=i)
        I=Q(0)
        for rest in product(*(range(len(p[j])) for j in other)):
            x=[0]*n
            for j,a in zip(other,rest): x[j]=a
            weight=prod(p[j][x[j]] for j in other)
            for a in range(len(p[i])):
                for b in range(len(p[i])):
                    x[i]=a
                    fa=f[tuple(x)]
                    x[i]=b
                    fb=f[tuple(x)]
                    I+=weight*p[i][a]*p[i][b]*(fa-fb)**2/2
        assert I==influences[i], "two-replica influence mismatch"

    lhs=V**2
    rhs=C*d**k*B**2*M
    return {"degree":degree,"B":B,"V":V,"M":M,
            "influences":influences,"lhs":lhs,"rhs":rhs,
            "normalized_ratio":lhs/(d**k*B**2*M) if B and M else None,
            "violates":lhs>rhs,"n":n,"states":len(xs)}


def hadamard():
    xs=list(product((0,1),repeat=4))
    def h(x):
        a,b,c,d=(2*t-1 for t in x)
        return a*c+a*d+b*c-b*d
    return {"degree":2,"constant":"1","probabilities":[["1/2","1/2"]]*4,
            "values":[str(h(x)) for x in xs]}


def additive(n=4):
    xs=list(product((0,1),repeat=n))
    return {"degree":1,"constant":"1",
            "probabilities":[["1/2","1/2"]]*n,
            "values":[str(Q(sum(2*t-1 for t in x),n)) for x in xs]}


def tests():
    ob=hadamard()
    a=analyze(ob)
    assert (a["degree"],a["V"],a["B"],a["M"],a["normalized_ratio"]) == (
        2,Q(4),Q(2),Q(2),Q(1,2))
    ob["constant"]="1/4"
    assert analyze(ob)["violates"]
    v=analyze(additive())
    assert v["degree"]==1 and v["normalized_ratio"]==1 and not v["violates"]
    ob=hadamard()
    ob["probabilities"]=[
        ["2/3","1/3"],["3/5","2/5"],["1/4","3/4"],["1/2","1/2"]]
    assert analyze(ob)["degree"]==2
    print("PASS exact original-law conditional and independent two-replica influence")
    print("PASS anchored Mobius degree / positive rational product audit")
    print("PASS degree-one sharp equality; Hadamard; false-C=1/4 negative control")
    # An independent 3-letter address, two 2-letter leaves: a real
    # nonbinary original-law degree-two selector, with all atoms positive.
    xs=list(product(range(3), range(2), range(2)))
    ob={"degree":2,"constant":"1",
        "probabilities":[["1/2","1/3","1/6"],["1/2","1/2"],["1/2","1/2"]],
        "values":[str(2*(x[1] if x[0]!=2 else x[2])-1) for x in xs]}
    assert analyze(ob)["degree"]==2

    # Two disjoint quadratic Hadamard blocks: exact essential radius
    # additivity and equality in the local fractional-cover profile.
    xs=list(product((0,1),repeat=8))
    def had(x):
        a,b,c,d=(2*t-1 for t in x)
        return a*c+a*d+b*c-b*d
    ob={"degree":2,"constant":"1","probabilities":[["1/2","1/2"]]*8,
        "values":[str(Q(had(x[:4]))+Q(1,2)*had(x[4:])) for x in xs]}
    v=analyze(ob)
    assert (v["B"],v["V"],v["M"])==(Q(3),Q(5),Q(2))
    assert v["V"]==Q(2)*Q(2)+Q(1)*Q(1)

    # Fail closed on a true degree-3 input misdeclared as degree 2.
    ob={"degree":2,"constant":"1","probabilities":[["1/2","1/2"]]*3,
        "values":[str((2*x[0]-1)*(2*x[1]-1)*(2*x[2]-1))
                  for x in product((0,1),repeat=3)]}
    try:
        analyze(ob)
        raise AssertionError("incorrect degree accepted")
    except AssertionError as e:
        if str(e)=="incorrect degree accepted":
            raise
    print("PASS categorical 3-letter selector, Hadamard block-range additivity")
    print("PASS high-degree negative control correctly rejected")
    print("PASS heterogeneous rational categorical law; NO universal bound asserted")


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--json",default=None,help="rational categorical witness JSON")
    args=ap.parse_args()
    tests()
    if args.json:
        with open(args.json,encoding="utf8") as fp:
            ob=json.load(fp)
        data=analyze(ob)
        result={}
        for k,v in data.items():
            result[k]=[str(x) for x in v] if isinstance(v,list) else (
                str(v) if isinstance(v,Q) else v)
        print(json.dumps(result,indent=2))
        print("EXACT FINITE COUNTEREXAMPLE" if data["violates"]
              else "No violation in this individual finite instance")


if __name__=="__main__":
    main()
