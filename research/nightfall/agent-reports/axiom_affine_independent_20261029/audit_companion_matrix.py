#!/usr/bin/env python3
"""Independent proof-dependency audit of PR #144, Axiom #142.

Unlike the source ea_inequivalence.py, multiplication uses the companion
matrix of T^3 = T-1 rather than a polynomial-convolution/reduction loop.
We independently check 26 visible affine 7-flats, component recovery,
full F3-linear spans, the intrinsic vertical missing-difference set,
and commutator ranks. This DOES NOT independently re-enumerate all
8,069,620 rank-two dual subspaces: completeness of the 26 flats stays a
separately identified dependency on PR #144's C++ exact checker.
"""
from collections import Counter
from itertools import combinations
import json


def add(a,b):
    return tuple((x+y)%3 for x,y in zip(a,b))


def neg(a):
    return tuple(-x%3 for x in a)


def scale(k,a):
    return tuple(k*x%3 for x in a)


def shift(a):
    # Matrix of multiplication by T on F3[T]/(T^3-T+1).
    # T*(a+bT+cT²) = -c + (a+c)T + bT².
    x,y,z=a
    return ((-z)%3,(x+z)%3,y)


def mul(a,b):
    tb=shift(a)
    t2b=shift(tb)
    return tuple((b[0]*a[i]+b[1]*tb[i]+b[2]*t2b[i])%3 for i in range(3))


ZERO=(0,0,0)
ONE=(1,0,0)
T=(0,1,0)
TT=(0,0,1)
ELEMENTS=[(a,b,c) for c in range(3) for b in range(3) for a in range(3)]


def power(a,n):
    result=ONE
    while n:
        if n&1:result=mul(result,a)
        a=mul(a,a);n//=2
    return result


def rank(vectors):
    if not vectors:return 0
    rows=[list(v) for v in vectors]
    ncol=len(rows[0]);i=0
    for j in range(ncol):
        pivot=next((k for k in range(i,len(rows)) if rows[k][j]),None)
        if pivot is None:continue
        rows[i],rows[pivot]=rows[pivot],rows[i]
        inv=1 if rows[i][j]==1 else 2
        rows[i]=[(inv*x)%3 for x in rows[i]]
        for k in range(len(rows)):
            if k==i:continue
            fac=rows[k][j]
            if fac:rows[k]=[(v-fac*t)%3 for v,t in zip(rows[k],rows[i])]
        i+=1
        if i==len(rows):break
    return i


def graph_function(exponent):
    return {x:power(x,exponent) for x in ELEMENTS}


def audit(exponent):
    f=graph_function(exponent)
    def point(a,b,c):return a+b+c
    P={point(x,f[x],ZERO) for x in ELEMENTS}
    C={point(ZERO,neg(f[z]),z) for z in ELEMENTS}
    S=P|C
    assert len(P)==len(C)==27 and len(S)==53
    assert rank(P)==rank(C)==6  # full 6D component affine spans

    # Build the 13 one-dimensional F3 lines by independent coordinate tuples.
    lines={frozenset((ZERO,x,neg(x))) for x in ELEMENTS if x!=ZERO}
    assert len(lines)==13
    sections=[]
    for L in lines:
        psec=frozenset(v for v in S if v[6:] in L)
        csec=frozenset(v for v in S if v[:3] in L)
        assert len(psec)==len(csec)==29
        sections.append(("P",psec))
        sections.append(("C",csec))
    assert len(sections)==26 and len({p for _,p in sections})==26
    similarities=Counter()
    for (kind1,a),(kind2,b) in combinations(sections,2):
        common=a&b
        size=len(common)
        similarities[(kind1==kind2,size)]+=1
        if kind1==kind2:
            assert size==27 and common==(P if kind1=="P" else C)
        else:
            assert size==5
    assert similarities=={(True,27):156,(False,5):169}

    # Independently recover the intrinsic missing-difference subgroup
    # of each planar graph: exactly the 26 nonzero vertical vectors.
    pairs={(x,f[x]) for x in ELEMENTS}
    diffs=set()
    for (x,fx),(y,fy) in combinations(pairs,2):
        a=add(x,neg(y));b=add(fx,neg(fy))
        assert a!=ZERO
        assert (a,b) not in diffs and (neg(a),neg(b)) not in diffs
        diffs.add((a,b));diffs.add((neg(a),neg(b)))
    assert len(diffs)==702
    assert diffs=={(a,b) for a in ELEMENTS if a!=ZERO for b in ELEMENTS}

    # Invariant under graph affine equivalence: normalized polarization
    # operators N_x = B_f(x, ·) ◦ B_f(1, ·)^(-1).
    def polar(x,y):
        return add(add(f[add(x,y)],neg(f[x])),neg(f[y]))
    lookup={polar(ONE,y):y for y in ELEMENTS}
    assert len(lookup)==27
    def normalized(x,y):return polar(x,lookup[y])
    hist=Counter()
    for x in ELEMENTS:
        if x==ZERO:continue
        for z in ELEMENTS:
            if z==ZERO:continue
            columns=[add(normalized(x,normalized(z,y)),
                         neg(normalized(z,normalized(x,y))))
                     for y in (ONE,T,TT)]
            hist[rank(columns)]+=1
    if exponent==2:
        assert hist=={0:676}
    if exponent==4:
        assert hist=={0:244,2:432}
        assert normalized(T,normalized(TT,T))!=(normalized(TT,normalized(T,T)))
    return {
        "component_count":2,"component_size":27,"ambient_points":53,
        "component_span_rank":6,
        "explicit_large_sections":len(sections),
        "within_class_section_pairs":156,
        "cross_class_section_pairs":169,
        "all_ordered_nonzero_graph_differences":len(diffs),
        "normalized_commutator_rank_histogram":dict(sorted(hist.items())),
    }


def main():
    assert mul(T,TT)==mul(TT,T)
    assert power(T,3)==add(T,neg(ONE))
    # Nonplanar x^3 has degenerate polarization and cannot normalize.
    cube=graph_function(3)
    assert len({add(add(cube[add(ONE,y)],neg(cube[ONE])),
                    neg(cube[y])) for y in ELEMENTS})==1
    out={"quadratic":audit(2),"quartic":audit(4)}
    assert out["quadratic"]["explicit_large_sections"]==26
    assert out["quartic"]["explicit_large_sections"]==26
    print(json.dumps(out,sort_keys=True,indent=2))
    print("PASS: independent component/EA audit; 8,069,620-flat completeness still imported")


if __name__=="__main__":
    main()
