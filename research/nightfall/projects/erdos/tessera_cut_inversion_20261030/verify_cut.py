#!/usr/bin/env python3
"""Exact cut-inversion lemma and sharp two-block Sidon obstruction.

No solver or dependencies. Sources: q=5,7,25 cyclic perfect difference
sets plus q=49 Singer regenerated from independent GF(7^6) field arithmetic.
"""
from math import comb, gcd
from itertools import combinations
from q49_field import singer

SOURCES={
 31:(0,1,3,8,12,18),
 57:(0,7,16,21,22,24,34,53),
 651:(21,72,81,86,88,105,197,217,247,278,316,334,357,
      360,368,405,430,434,440,462,483,498,525,537,538,584),
}
def source_check(D,v):
    assert len(set(D))==len(D) and all(0<=x<v for x in D)
    seen={(a-b)%v for a in D for b in D if a!=b}
    assert len(seen)==len(D)*(len(D)-1),"not modular Sidon"
    assert len(seen)==v-1 and seen==set(range(1,v))
def positive_diffs(S):
    return {S[j]-S[i] for i in range(len(S)) for j in range(i+1,len(S))}
def ordinary_sidon(S):
    sums=[x+y for i,x in enumerate(S) for y in S[i:]]
    return len(sums)==len(set(sums))
def cut(D,v,c):
    return tuple(sorted((x+c)%v for x in D))
def test_one(D,v):
    K=len(D)
    source_check(D,v)
    masks=[0,1,v//7,v//2,(3*v)//4]
    for c0 in sorted({c%v for c in masks}):
        ref=cut(D,v,c0);old=positive_diffs(ref)
        assert len(old)==comb(K,2)
        for c1 in range(v):
            new=cut(D,v,c1)
            delta=(c1-c0)%v
            crosses=sum(1 for x in D if (x+c0)%v >=v-delta) if delta else 0
            actual=len(old&positive_diffs(new))
            predicted=comb(K,2)-crosses*(K-crosses)
            assert actual==predicted, (v,c0,c1,crosses,actual,predicted)
    ref=cut(D,v,0);old=positive_diffs(ref)
    minpred=comb(K,2)-K*K//4
    matching_shift=next(s for s in range(1,v)
                        if sum(x+s>=v for x in D)==K//2)
    other=cut(D,v,matching_shift)
    crossed=[x for x in D if x+matching_shift>=v]
    uncrossed=[x for x in D if x+matching_shift<v]
    assert crossed and uncrossed
    x,y=crossed[0],uncrossed[0]
    I=sorted(((x+matching_shift)%v,(y+matching_shift)%v))
    assert I[1]-I[0] not in old
    final=tuple(sorted(ref+(3*v+I[0],3*v+I[1])))
    assert ordinary_sidon(final)
    assert len(final)==K+2
    assert len(old&positive_diffs(other))==minpred
    # A third retained point must have two labels in one crossing class,
    # hence share an ordinary difference with the full first source.
    count=0
    for triple in combinations(other,3):
        assert old & positive_diffs(triple)
        count+=1
    assert count==comb(K,3)
    print("PASS v",v,"K",K,"all cuts against 5 anchors",5*v,
          "overlap floor",minpred,"sharp shift",matching_shift,
          "K+2 witness maximum",max(final),"pair sums",comb(K+3,2),
          "triple negative controls",count)

def multiplier_negative_control():
    v=31;D=SOURCES[v]
    A=positive_diffs(cut(D,v,23))
    B=positive_diffs(cut(tuple((2*x)%v for x in D),v,25))
    assert len(A&B)==4
    assert 4<comb(len(D),2)-len(D)**2//4
    Q0=cut(D,v,23)
    Q1=cut(tuple(2*x%v for x in D),v,25)
    assert Q0==(0,4,10,23,24,26) and Q1==(0,11,18,22,25,30)
    I=(0,18,25,30)
    assert set(I)<=set(Q1) and not (positive_diffs(Q0)&positive_diffs(I))
    survivor=tuple(sorted(Q0+tuple(3*v+x for x in I)))
    assert len(survivor)==10 and max(survivor)==123
    assert ordinary_sidon(survivor)
    print("PASS changed multiplier escapes K+2: six protected + four new =10,"
          "55 unique sums, maximum 123")
    print("PASS multiplier-change negative control: overlap 4 < same-multiplier floor 6")

if __name__=="__main__":
    SOURCES[2451]=singer()
    for v,D in SOURCES.items():test_one(D,v)
    multiplier_negative_control()
    print("PASS: modular-difference source, cut order, overlap, K+2 sharpness")
