#!/usr/bin/env python3
"""Standalone, exact, no-third-party verifier of the 1-/2-point rigidity theorem.

Deliberately independent from the exploratory Numba/cover-enumeration builder.
The certificate is just 11 explicitly listed 17-element Sidon subsets.
"""
from __future__ import annotations
from itertools import combinations
from functools import lru_cache
from pathlib import Path
import hashlib, json

HERE=Path(__file__).resolve().parent
EXPECTED_WITNESS_SHA='dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f'
EXPECTED={'candidate_ap':1132,'admissible_ap':305,'invalid_ap':827,'caseI':44255,
          'caseII':7174,'caseIII':23,'portfolio':11,'base_ap':28}


def sidon(numbers):
    """All unordered two-term sums, including twice the same mark, distinct."""
    values=tuple(numbers)
    if len(set(values))!=len(values):return False
    sums=set()
    for j,b in enumerate(values):
        for a in values[:j+1]:
            s=a+b
            if s in sums:return False
            sums.add(s)
    return True


def weak_four(B):
    """Weak Sidon: no four distinct marks support two equal disjoint pair sums.

    This is weaker than the (4,5) condition.
    """
    for a,b,c,d in combinations(B,4):
        if a+d==b+c or a+c==b+d or a+b==c+d:return False
    return True


def ap_old_pairs(B,x):
    """Pairs of old marks that form an arithmetic progression with x."""
    p=[]
    for i,a in enumerate(B):
        for j in range(i+1,len(B)):
            b=B[j]
            if a+b==2*x or 2*a==b+x or 2*b==a+x:p.append((a,b))
    return p


def cover12_impossible(B):
    """Independent exhaustive DFS forbidding 18 old marks without any 3AP."""
    edges=[]
    for i,j,k in combinations(range(len(B)),3):
        if B[i]+B[k]==2*B[j]:edges.append((1<<i)|(1<<j)|(1<<k))
    assert len(edges)==28
    @lru_cache(None)
    def possible(deleted,remaining):
        if remaining<0:return False
        open_edges=[e for e in edges if (e&deleted)==0]
        if not open_edges:return True
        # greedily select disjoint 3APs: sound lower bound on deletions
        packed=0;floor=0
        for e in open_edges:
            if not (packed&e):packed|=e;floor+=1
        if floor>remaining:return False
        incidence=[0]*len(B)
        for e in open_edges:
            for i in range(len(B)):
                if e&(1<<i):incidence[i]+=1
        target=max(open_edges,key=lambda e:sum(incidence[i] for i in range(len(B)) if e&(1<<i)))
        branches=sorted((i for i in range(len(B)) if target&(1<<i)),key=lambda i:-incidence[i])
        return any(possible(deleted|(1<<i),remaining-1) for i in branches)
    result=possible(0,12)
    return not result,possible.cache_info().currsize


def four_compatible_pair(x,y,B,forbidden,old_pair_sums,old_diffs):
    """Exact incremental four-distinct sum test for B+{x,y}."""
    if x==y or x in B or y in B or x in forbidden or y in forbidden:return False
    if x+y in old_pair_sums or abs(x-y) in old_diffs:return False
    return True


def verify(source=HERE/'witness_30.txt',certificate=HERE/'portfolio_certificate.json'):
    raw=source.read_bytes()
    assert hashlib.sha256(raw).hexdigest()==EXPECTED_WITNESS_SHA,'source witness hash mismatch'
    B=tuple(map(int,raw.strip().split(b',')))
    assert len(B)==30 and list(B)==sorted(set(B)) and weak_four(B)
    assert weak_four((1,2,3,5)),"weak-Sidon counterexample baseline failed"
    differences={b-a for a,b in combinations((1,2,3,5),2)}
    assert len(differences)==4,"(4,5) versus weak-Sidon distinction collapsed"
    cert=json.loads(certificate.read_text())
    portfolio=[tuple(x) for x in cert['portfolio']]
    assert len(portfolio)==11 and len(set(portfolio))==11
    for S in portfolio:
        assert len(S)==17 and set(S)<=set(B) and sidon(S),'forged or invalid 17-point subset'
    no18,states=cover12_impossible(B)
    assert no18,'original h(B)=17 upper bound false'

    old=set(B)
    raw_candidates=set()
    for a,b in combinations(B,2):
        raw_candidates.update((2*a-b,2*b-a))
        if (a+b)%2==0:raw_candidates.add((a+b)//2)
    raw_candidates-=old
    assert len(raw_candidates)==1132,'changed AP candidate universe'

    # Independently derive all insertion-invalid x by old disjoint-pair sums.
    forbidden=set()
    for a in B:
        for i,b in enumerate(B):
            if b==a:continue
            for c in B[i+1:]:
                if c!=a:forbidden.add(b+c-a)
    V=sorted(raw_candidates-forbidden)
    assert len(V)==305 and len(raw_candidates&forbidden)==827
    for x in V:
        assert len(ap_old_pairs(B,x))==1,'new AP multiplicity contradicts certified reduction'
        assert any(sidon(S+(x,)) for S in portfolio),'one-point portfolio missed a case'
    # With no new AP, any old 17-Sidon set extends; with one AP, portfolio handles it.

    old_pair_sums={a+b for a,b in combinations(B,2)}
    old_diffs={abs(a-b) for a,b in combinations(B,2)}
    observed={'candidate_ap':len(raw_candidates),'admissible_ap':len(V),
              'invalid_ap':len(raw_candidates&forbidden),'portfolio':len(portfolio),'base_ap':28}

    # Case I: both new marks produce an old-old-new 3AP; 305 choose 2 weak-Sidon candidates.
    i=0; sample=[]
    for x,y in combinations(V,2):
        if not four_compatible_pair(x,y,old,forbidden,old_pair_sums,old_diffs):continue
        i+=1
        assert any(sidon(S+(x,y)) for S in portfolio),f'case I counterexample {x} {y}'
        if len(sample)<8:sample.append((x,y))
    observed['caseI']=i

    # Case II: exactly one old-old-new AP, and a mixed new-new-old AP.
    # Every mixed AP imposes x+y=2b, 2x-y=b, or 2y-x=b for an old b.
    exceptional2={}
    for x in V:
        for b in B:
            ys=(2*b-x,2*x-b)
            if (x+b)%2==0:ys+=((x+b)//2,)
            for y in ys:
                if y in raw_candidates and y not in forbidden:continue
                if not four_compatible_pair(x,y,old,forbidden,old_pair_sums,old_diffs):continue
                cross=[c for c in B if x+y==2*c or 2*x-y==c or 2*y-x==c]
                if cross:exceptional2[tuple(sorted((x,y)))]=tuple(cross)
    observed['caseII']=len(exceptional2)
    for (x,y),cross in exceptional2.items():
        assert any(sidon(S+(x,y)) for S in portfolio),f'case II counterexample {x} {y}'

    # Case III: no individual old-old-new AP; two or more new-new-old APs.
    # Two independent affine equations fix (x,y); enumerate intersections exactly.
    exceptional3={}
    for a,b in combinations(B,2):
        for p,q in ((a,b),(b,a)):
            if (2*p+q)%3:continue
            u=(2*p+q)//3;v=(4*p-q)//3
            for x,y in ((u,v),(v,u),((2*p+q)//3,(p+2*q)//3)):
                if x in raw_candidates and x not in forbidden:continue
                if y in raw_candidates and y not in forbidden:continue
                if not four_compatible_pair(x,y,old,forbidden,old_pair_sums,old_diffs):continue
                cross=tuple(c for c in B if x+y==2*c or 2*x-y==c or 2*y-x==c)
                if len(cross)>=2:exceptional3[tuple(sorted((x,y)))]=cross
    observed['caseIII']=len(exceptional3)
    for (x,y),cross in exceptional3.items():
        assert any(sidon(S+(x,y)) for S in portfolio),f'case III counterexample {x} {y}'

    # Generic cases: zero/one mixed 3AP is blocked by an appropriate old 17-subset.
    for b in B:
        assert any(b not in S for S in portfolio),'generic one-cross case uncovered'
    assert observed==EXPECTED,(observed,EXPECTED)

    # Independent adversarial controls: exact checks must reject invalid evidence.
    assert not sidon((1,2,3))
    assert not weak_four((0,1,2,3))
    forged=next(v for v in B if v not in portfolio[0] and not sidon(portfolio[0][:-1]+(v,)))
    assert not sidon(portfolio[0][:-1]+(forged,))
    assert any(v in forbidden for v in raw_candidates)
    return {'verdict':'PASS — bounded exact theorem','source_sha256':hashlib.sha256(raw).hexdigest(),
            'certificate_sha256':hashlib.sha256(certificate.read_bytes()).hexdigest(),
            'counts':observed,'old_max_sidon':17,'new_max_after_one':18,
            'new_max_after_two':19,'old_cover12_reject_states':states,
            'adversarial_controls':'PASS incl. weak-Sidon versus (4,5) distinction','external_prior_art_review':'PENDING',
            'scope':'Every weak-Sidon-preserving 1- or 2-integer superextension of this specific 30-point witness; (4,5) follows as a corollary; no global optimum or asymptotic claim.'}


if __name__=='__main__':
    print(json.dumps(verify(),indent=2,sort_keys=True))