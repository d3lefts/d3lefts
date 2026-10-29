#!/usr/bin/env python3
"""Independently reconstruct the claimed witnesses from literal marks and sums.
Does not import generate.py or trust the bitsets in states.tsv.
The full triple minimum is proved by enumerate.cpp; non-author audit pending.
"""
import argparse
from math import comb
from pathlib import Path

D=(21,72,81,86,88,105,197,217,247,278,316,334,357,360,
   368,405,430,434,440,462,483,498,525,537,538,584)
V=651;K=26
PREFIXES={0:(),5:(1,23,70,150,200),13:D[:13],26:D}
EXPECTED={0:(415,19),5:(425,20),13:(492,23),26:(715,37)}

def positive_differences(A):
    A=sorted(A)
    diffs=[b-a for i,a in enumerate(A) for b in A[i+1:]]
    assert len(diffs)==len(set(diffs))
    return set(diffs)

def minimum_deletions(R):
    # For D deleted marks, maximum removed intra-block differences is
    # 3*C(26,2)-min_balanced_surviving_difference_count.
    for Dtot in range(3*K+1):
        survivors=3*K-Dtot
        a,t=divmod(survivors,3)
        remaining=(3-t)*comb(a,2)+t*comb(a+1,2)
        if 3*comb(K,2)-remaining>=R:return Dtot
    raise AssertionError('unreachable')

def check(path):
    results=[]
    for line in Path(path).read_text().splitlines():
        p=line.split()
        if not p:continue
        if p[0]=='COUNT':
            assert list(map(int,p[1:]))==[780,79396460]
        if p[0]!='RESULT':continue
        assert len(p)==10
        r,R,Dmin,u1,c1,u2,c2,u3,c3=map(int,p[1:])
        assert (R,Dmin)==EXPECTED[r]
        sets=[sorted((u*x+c)%V for x in D) for u,c in ((u1,c1),(u2,c2),(u3,c3))]
        for S in sets:
            assert len(set(S))==K
            assert len({(x-y)%V for x in S for y in S if x!=y})==V-1
        occurrence=[positive_differences(S) for S in sets]
        P=positive_differences(PREFIXES[r])
        all_diffs=P.union(*occurrence)
        assert R==3*comb(K,2)+comb(r,2)-len(all_diffs)
        assert Dmin==minimum_deletions(R)
        assert Dmin>0
        # Literal unordered sums independently falsify the un-repaired
        # union, with intentionally nonresonant block translations.
        full=list(PREFIXES[r])
        for i,S in enumerate(sets):full += [(10**(i+2))*V+x for x in S]
        sums=[a+b for i,a in enumerate(full) for b in full[i:]]
        assert len(sums)>len(set(sums)), 'missed collision negative control'
        results.append(r)
        print('PASS witness r',r,'redundancy',R,'necessary deletions',Dmin,
              'literal-sum collision detected')
    assert sorted(results)==[0,5,13,26]
    print('PASS independent literal reconstruction, prefix differences, integer-sum negative controls')

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('results');check(ap.parse_args().results)
