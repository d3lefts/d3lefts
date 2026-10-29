#!/usr/bin/env python3
"""Build and independently check affine Singer positive-difference spectra.

Method A: direct differences at K wrap cuts. Method B: independently
sweep all v cuts by toggling the crossing mark's K-1 chords.
Standard Python 3 only; creates states.tsv and prefixes.tsv in given directory.
"""
import argparse
from math import gcd, comb
from pathlib import Path
from hashlib import sha256

SOURCES = {
    31: (12, 16, 18, 21, 28, 29),
    57: (3, 19, 21, 29, 32, 33, 38, 53),
    651: (21, 72, 81, 86, 88, 105, 197, 217, 247, 278, 316, 334,
          357, 360, 368, 405, 430, 434, 440, 462, 483, 498, 525, 537, 538, 584),
}
EXPECTED = {31: (28, 4), 57: (48, 9), 651: (780, 156)}


def verify_perfect(D, v):
    K = len(D)
    assert len(set(D)) == K and all(0 <= x < v for x in D)
    assert K * (K-1) == v-1
    diffs = [(a-b)%v for a in D for b in D if a != b]
    assert len(diffs) == v-1 and set(diffs) == set(range(1, v))


def mask(values):
    B = sorted(values)
    out = 0
    for i, a in enumerate(B):
        for b in B[i+1:]:
            bit = 1 << (b-a)
            assert not out & bit, 'integer Sidon failure'
            out |= bit
    return out


def affine_states(D, v):
    K = len(D)
    states = {}
    for u in range(1, v):
        if gcd(u, v) != 1: continue
        B = [(u*x)%v for x in D]
        events = sorted({(-x)%v for x in B})
        assert len(events) == K
        direct = {}
        for c in events:
            M = mask((x+c)%v for x in B)
            assert M.bit_count() == comb(K,2)
            for d in range(1, (v+1)//2):
                assert ((M>>d)&1) + ((M>>(v-d))&1) == 1
            direct[c] = M
            states.setdefault(M, (u,c))
        # Distinct algorithm: walk EVERY cut and flip K-1 chord orientations
        # whenever one mark passes the integer interval boundary.
        at_event = {(-x)%v:x for x in B}
        current = mask(B)
        encountered = {current}
        for c in range(1, v):
            if c in at_event:
                crossing = at_event[c]
                for other in B:
                    if other == crossing:continue
                    prev = (other+c-1)%v
                    old_diff = v-1-prev
                    current ^= (1<<old_diff) | (1<<(v-old_diff))
                assert current == direct[c], (v,u,c)
            encountered.add(current)
        assert encountered == set(direct.values()), ('missed cut state',v,u)
    return states


def pair_minimum(states, v):
    n=(v-1)//2
    codes=[]
    for M in states:
        C=0
        for d in range(1,n+1):
            if M>>d&1:C |= 1<<(d-1)
        codes.append((M,C))
    best=n+1
    for i,(A,a) in enumerate(codes):
        for B,b in codes[i+1:]:
            direct=(A&B).bit_count()
            assert direct==n-(a^b).bit_count()
            best=min(best,direct)
    return best


def is_sidon(A):
    sums=[x+y for i,x in enumerate(A) for y in A[i:]]
    return len(sums)==len(set(sums))


def main():
    p=argparse.ArgumentParser()
    p.add_argument('--out',type=Path,required=True)
    args=p.parse_args()
    args.out.mkdir(parents=True,exist_ok=True)
    for v,D in SOURCES.items():
        verify_perfect(D,v)
        states=affine_states(D,v)
        assert (len(states),pair_minimum(states,v))==EXPECTED[v]
        if v==57:
            # PR #195 fixes first multiplier=1, so its q7 floor 10 is
            # distinct from our two-sided affine floor 9.
            fixed={mask((x+c)%v for x in D) for c in range(v)}
            assert min((a&b).bit_count() for a in fixed for b in states)==10
        if v==651:
            src_hash=sha256(('\n'.join(map(str,D))+'\n').encode()).hexdigest()
            assert src_hash=='2867af0c52dde5eda18654f69ac00f55cc3e241d7abba9f4cdf123f5b922f74c'
            with (args.out/'states.tsv').open('w') as f:
                for M,(u,c) in sorted(states.items()):
                    f.write(' '.join(map(str,[u,c]+[(M>>(64*j))&((1<<64)-1) for j in range(11)]))+'\n')
            prefixes=[(),(1,23,70,150,200),D[:13],D]
            with (args.out/'prefixes.tsv').open('w') as f:
                for A in prefixes:
                    assert is_sidon(list(A))
                    assert not A or max(A)-min(A)<v
                    P=mask(A)
                    assert P.bit_count()==comb(len(A),2)
                    f.write(' '.join(map(str,[len(A)]+[(P>>(64*j))&((1<<64)-1) for j in range(11)]))+'\n')
        print('PASS',v,'K',len(D),'unique spectra',len(states),'all-affine minimum overlap',EXPECTED[v][1])
    corrupted=list(SOURCES[31]);corrupted[-1]=corrupted[0]
    try:verify_perfect(corrupted,31)
    except AssertionError:pass
    else:raise AssertionError('negative control accepted duplicate mark')
    print('PASS all full-cut sweeps, antipodal transversals, Hamming cross-check, corrupted-source negative control')

if __name__=='__main__':main()
